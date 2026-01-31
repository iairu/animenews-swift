import Foundation
import Combine

// A placeholder service that mimics fetching data from the Jikan API.
// In a real app, this would make network requests to the Jikan API.
class JikanService {

    private let baseURL = URL(string: Constants.JikanAPI.baseUrl)!
    private let decoder = JSONDecoder()

    init() {
        // Jikan API uses snake_case for its keys
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    /// Fetches the top all-time anime from Jikan.
    /// - Returns: A Combine publisher that emits a JikanResponse with an array of Anime, or an error.
    func fetchTopAnime() -> AnyPublisher<JikanResponse<[Anime]>, Error> {
        let request = URLRequest(url: baseURL.appendingPathComponent("top/anime"))
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: JikanResponse<[Anime]>.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Simulates fetching the top seasonal anime.
    func fetchSeasonalAnime(completion: @escaping (Result<[Anime], Error>) -> Void) {
        // Simulate a network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // Return the mock data
            completion(.success(Anime.placeholders))
        }
    }

    /// Simulates searching for anime by a query.
    func searchAnime(query: String, completion: @escaping (Result<[Anime], Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if query.isEmpty {
                completion(.success(Anime.placeholders))
            } else {
                let filtered = Anime.placeholders.filter {
                    $0.title.localizedCaseInsensitiveContains(query)
                }
                completion(.success(filtered))
            }
        }
    }
    
    /// Simulates fetching a single anime by its ID.
    func fetchAnime(id: Int, completion: @escaping (Result<Anime, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let anime = Anime.placeholders.first(where: { $0.id == id }) {
                completion(.success(anime))
            } else {
                // In a real scenario, you'd define a proper error type.
                completion(.failure(NSError(domain: "JikanService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Anime not found."])))
            }
        }
    }
}
