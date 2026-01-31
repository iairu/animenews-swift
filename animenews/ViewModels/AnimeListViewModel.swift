import SwiftUI

@MainActor
class AnimeListViewModel: ObservableObject {
    @Published var animeList = [Anime]()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let jikanService = JikanService()

    func fetchTopAnime() async {
        isLoading = true
        errorMessage = nil
        do {
            let animes = try await jikanService.fetchTopAnime()
            self.animeList = animes
        } catch {
            self.errorMessage = "Failed to fetch top anime: \(error.localizedDescription)"
            self.animeList = []
            print("Error fetching top anime: \(error)")
        }
        isLoading = false
    }
    
    func searchAnime(query: String) async {
        if query.isEmpty {
            await fetchTopAnime()
            return
        }
        
        isLoading = true
        errorMessage = nil
        do {
            let animes = try await jikanService.searchAnime(query: query)
            self.animeList = animes
        } catch {
            self.errorMessage = "Failed to search for anime: \(error.localizedDescription)"
            self.animeList = []
            print("Error searching anime: \(error)")
        }
        isLoading = false
    }
}
