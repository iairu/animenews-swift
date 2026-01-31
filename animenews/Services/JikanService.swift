import Foundation

class JikanService {

    private let baseURL = URL(string: Constants.JikanAPI.baseUrl)!
    private let decoder: JSONDecoder
    private let session: URLSession

    init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        session = URLSession(configuration: .default)
    }
    
    /// Fetches the top all-time anime.
    func fetchTopAnime() async throws -> [Anime] {
        let url = baseURL.appendingPathComponent("top/anime")
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode(JikanResponse<[Anime]>.self, from: data)
        return response.data
    }

    /// Fetches a single anime by its ID.
    func getAnimeDetails(id: Int) async throws -> Anime {
        let url = baseURL.appendingPathComponent("anime/\(id)")
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode(JikanResponse<Anime>.self, from: data)
        return response.data
    }

    /// Searches for anime by a query.
    func searchAnime(query: String) async throws -> [Anime] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }
        var components = URLComponents(url: baseURL.appendingPathComponent("anime"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode(JikanResponse<[Anime]>.self, from: data)
        return response.data
    }

    /// Fetches the current season's anime.
    func fetchCurrentSeasonAnime() async throws -> [Anime] {
        let url = baseURL.appendingPathComponent("seasons/now")
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode(JikanResponse<[Anime]>.self, from: data)
        return response.data
    }
}
