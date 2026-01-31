import Foundation
import Combine

@MainActor
class NewsViewModel: ObservableObject {
    @Published var newsItems = [NewsItem]()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let rssParser = RSSParser()
    
    func fetchNews() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let items = try await rssParser.fetchNews()
            self.newsItems = items.sorted(by: { $0.pubDate > $1.pubDate })
        } catch {
            self.errorMessage = "Failed to fetch news: \(error.localizedDescription)"
            self.newsItems = []
            print("Error fetching news: \(error.localizedDescription)")
        }
        self.isLoading = false
    }
}
