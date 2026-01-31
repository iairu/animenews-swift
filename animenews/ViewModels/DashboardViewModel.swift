import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    @Published var seasonalProgress: Double = 0.0
    @Published var watchingCount: Int = 0
    @Published var totalShowsInSeason: Int = 0
    @Published var trendingAnime: [Anime] = []
    @Published var trendChartData: [Double] = []
    @Published var isLoading: Bool = false

    private let jikanService = JikanService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchDashboardData()
    }

    func fetchDashboardData() {
        isLoading = true
        
        // In a real app, this would be more complex.
        // We would fetch user's watchlist and compare with top seasonal anime.
        // For now, we will simulate the data for the activity rings.
        
        // 1. Simulate user's watching data
        self.watchingCount = 7
        self.totalShowsInSeason = 25
        self.seasonalProgress = Double(watchingCount) / Double(totalShowsInSeason)
        
        // 2. Fetch top anime for the "Trending" card and chart
        jikanService.fetchTopAnime()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    // TODO: Better error handling
                    print("Error fetching top anime: \(error)")
                }
            }, receiveValue: { [weak self] response in
                let topFive = Array(response.data.prefix(5))
                self?.trendingAnime = topFive
                // Use the scores of the top anime for the trend chart, reversed for effect
                self?.trendChartData = topFive.map { $0.score }.reversed()
            })
            .store(in: &cancellables)
    }
}
