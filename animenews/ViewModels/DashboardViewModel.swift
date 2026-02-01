import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    // Activity Rings
    @Published var seasonalProgress: Double = 0.0
    @Published var watchingCount: Int = 0
    @Published var totalShowsInSeason: Int = 0
    @Published var completedCount: Int = 0
    @Published var planToWatchCount: Int = 0
    
    // Trending
    @Published var trendingAnime: [Anime] = []
    @Published var trendChartData: [Double] = []
    
    // Seasonal
    @Published var seasonalAnime: [Anime] = []
    @Published var currentSeason: String = ""
    @Published var currentYear: Int = 2026
    
    // Quick Stats
    @Published var totalEpisodesWatched: Int = 0
    @Published var averageScore: Double = 0.0
    @Published var favoriteGenre: String = "N/A"
    
    // Recently Updated (from user's library)
    @Published var recentlyUpdated: [Anime] = []
    
    // Upcoming from watching list
    @Published var upcomingEpisodes: [(anime: Anime, nextEpisode: Int)] = []
    
    // Loading state
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let jikanService = JikanService()

    func fetchDashboardData() async {
        isLoading = true
        errorMessage = nil
        
        // 1. Fetch user's tracking data from StorageService
        let allTracked = StorageService.shared.getAllTrackedAnimes()
        self.watchingCount = allTracked.filter { $0.status == .watching }.count
        self.completedCount = allTracked.filter { $0.status == .completed }.count
        self.planToWatchCount = allTracked.filter { $0.status == .planToWatch }.count
        
        // Calculate total episodes watched
        self.totalEpisodesWatched = allTracked.reduce(0) { $0 + $1.watchedEpisodes }
        
        // Calculate average user score
        let scoredItems = allTracked.filter { ($0.score ?? 0) > 0 }
        if !scoredItems.isEmpty {
            self.averageScore = Double(scoredItems.reduce(0) { $0 + ($1.score ?? 0) }) / Double(scoredItems.count)
        }
        
        // Determine current season
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        self.currentYear = calendar.component(.year, from: Date())
        self.currentSeason = determineSeason(from: month)
        
        // Concurrently fetch data from API
        do {
            async let topAnimeFetch = jikanService.fetchTopAnime()
            async let seasonalAnimeFetch = jikanService.fetchCurrentSeasonAnime()
            
            // Fetch top anime for trending
            let topAnime = try await topAnimeFetch
            let topFive = Array(topAnime.prefix(5))
            self.trendingAnime = topFive
            self.trendChartData = topFive.map { $0.score ?? 0.0 }.reversed()
            
            // Fetch seasonal anime
            let seasonal = try await seasonalAnimeFetch
            self.seasonalAnime = Array(seasonal.prefix(10))
            self.totalShowsInSeason = seasonal.count
            
            if totalShowsInSeason > 0 {
                self.seasonalProgress = Double(watchingCount) / Double(min(totalShowsInSeason, 20))
            }
            
            // Find upcoming episodes from watching list
            let watchingIds = allTracked.filter { $0.status == .watching }.map { $0.id }
            self.upcomingEpisodes = seasonal
                .filter { watchingIds.contains($0.id) }
                .compactMap { anime in
                    if let tracked = allTracked.first(where: { $0.id == anime.id }),
                       let total = anime.episodes,
                       tracked.watchedEpisodes < total {
                        return (anime: anime, nextEpisode: tracked.watchedEpisodes + 1)
                    }
                    return nil
                }
                .prefix(5)
                .map { $0 }
            
        } catch {
            self.errorMessage = "Failed to fetch dashboard data: \(error.localizedDescription)"
            print("Error fetching dashboard data: \(error)")
        }
        
        isLoading = false
    }
    
    private func determineSeason(from month: Int) -> String {
        switch month {
        case 1...3: return "Winter"
        case 4...6: return "Spring"
        case 7...9: return "Summer"
        default: return "Fall"
        }
    }
}
