import Foundation
import Combine

class NewsViewModel: ObservableObject {
    @Published var newsItems = [NewsItem]()
    @Published var isLoading = false
    
    private let rssParser = RSSParser()
    
    init() {
        fetchNews()
    }
    
    func fetchNews() {
        self.isLoading = true
        rssParser.fetchNews { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let items):
                    self?.newsItems = items.sorted(by: { $0.pubDate > $1.pubDate })
                case .failure(let error):
                    // In a real app, you'd handle this error more gracefully,
                    // perhaps by showing an alert to the user.
                    print("Error fetching news: \(error.localizedDescription)")
                    self?.newsItems = []
                }
            }
        }
    }
}
