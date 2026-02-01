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
    
    /// Fetches anime schedule for a specific day of the week.
    func fetchSchedule(day: String) async throws -> [Anime] {
        let url = baseURL.appendingPathComponent("schedules/\(day)")
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode(JikanResponse<[Anime]>.self, from: data)
        return response.data
    }
    
    /// Fetches random anime recommendations.
    func fetchRecommendations() async throws -> [Anime] {
        // Jikan doesn't have a direct recommendations endpoint for anonymous users
        // So we fetch top anime as recommendations
        let url = baseURL.appendingPathComponent("top/anime")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "order_by", value: "popularity"),
            URLQueryItem(name: "limit", value: "25")
        ]
        guard let finalUrl = components.url else { throw URLError(.badURL) }
        let (data, _) = try await session.data(from: finalUrl)
        let response = try decoder.decode(JikanResponse<[Anime]>.self, from: data)
        return response.data
    }
    
    /// Fetches anime by specific filter.
    func fetchAnimeByFilter(status: String? = nil, type: String? = nil, orderBy: String = "score", limit: Int = 25) async throws -> [Anime] {
        var components = URLComponents(url: baseURL.appendingPathComponent("anime"), resolvingAgainstBaseURL: false)!
        var queryItems = [URLQueryItem]()
        
        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }
        if let type = type {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }
        queryItems.append(URLQueryItem(name: "order_by", value: orderBy))
        queryItems.append(URLQueryItem(name: "sort", value: "desc"))
        queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        
        components.queryItems = queryItems
        
        guard let url = components.url else { throw URLError(.badURL) }
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode(JikanResponse<[Anime]>.self, from: data)
        return response.data
    }
}
