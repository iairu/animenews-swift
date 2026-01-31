import SwiftUI

@MainActor
class MyAnimeListViewModel: ObservableObject {
    @Published var trackedAnime: [Anime] = []
    @Published var isLoading = false
    @Published var statusFilter: TrackedAnime.Status? = nil {
        didSet {
            Task {
                await filterAndFetchAnime()
            }
        }
    }
    
    private let jikanService = JikanService()
    
    func filterAndFetchAnime() async {
        isLoading = true
        
        let allTracked = StorageService.shared.getAllTrackedAnimes()
        
        let filteredTracked: [TrackedAnime]
        if let status = statusFilter {
            filteredTracked = allTracked.filter { $0.status == status }
        } else {
            filteredTracked = allTracked
        }
        
        let ids = filteredTracked.map { $0.id }
        
        let animes = await fetchAnimes(ids: ids)
        self.trackedAnime = animes.sorted { $0.title < $1.title }
        self.isLoading = false
    }
    
    private func fetchAnimes(ids: [Int]) async -> [Anime] {
        await withTaskGroup(of: Anime?.self, returning: [Anime].self) { group in
            for id in ids {
                group.addTask {
                    try? await self.jikanService.getAnimeDetails(id: id)
                }
            }
            
            var animes: [Anime] = []
            for await anime in group {
                if let anime = anime {
                    animes.append(anime)
                }
            }
            return animes
        }
    }
}
