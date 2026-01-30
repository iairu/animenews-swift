import Foundation

// A placeholder service that mimics fetching and parsing an RSS feed.
class RSSParser {

    func fetchNews(completion: @escaping (Result<[NewsItem], Error>) -> Void) {
        // In a real app, this would use a library like FeedKit to parse an XML feed from a URL.
        // For now, we return our static placeholder data after a short delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            completion(.success(NewsItem.placeholders))
        }
    }
}
