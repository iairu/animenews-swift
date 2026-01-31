import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var seasonalProgress: Double = 0.0
    @Published var watchingCount: Int = 0
    @Published var totalShowsInSeason: Int = 0
    @Published var trendingAnime: [Anime] = []
    @Published var trendChartData: [Double] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let jikanService = JikanService()

    func fetchDashboardData() async {
        isLoading = true
        errorMessage = nil
        
        // 1. Fetch user's watching data from StorageService
        let allTracked = StorageService.shared.getAllTrackedAnimes()
        self.watchingCount = allTracked.filter { $0.status == .watching }.count
        
        // Concurrently fetch top anime and seasonal anime
        do {
            async let topAnimeFetch = jikanService.fetchTopAnime()
            async let seasonalAnimeFetch = jikanService.fetchCurrentSeasonAnime()
            
            // 2. Fetch top anime for the "Trending" card and chart
            let topAnime = try await topAnimeFetch
            let topFive = Array(topAnime.prefix(5))
            self.trendingAnime = topFive
            self.trendChartData = topFive.map { $0.score ?? 0.0 }.reversed()
            
            // 3. Fetch seasonal anime to calculate progress
            let seasonalAnime = try await seasonalAnimeFetch
            self.totalShowsInSeason = seasonalAnime.count
            
            if totalShowsInSeason > 0 {
                self.seasonalProgress = Double(watchingCount) / Double(totalShowsInSeason)
            }
            
        } catch {
            self.errorMessage = "Failed to fetch dashboard data: \(error.localizedDescription)"
            print("Error fetching dashboard data: \(error)")
        }
        
        isLoading = false
    }
}
