import Foundation

// A placeholder service that mimics fetching data from the Jikan API.
// In a real app, this would make network requests to the Jikan API.
class JikanService {

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
