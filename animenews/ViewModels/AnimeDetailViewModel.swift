import SwiftUI

@MainActor
class AnimeDetailViewModel: ObservableObject {
    private let anime: Anime
    @Published var trackedAnime: TrackedAnime?
    
    @Published var status: TrackedAnime.Status = .planToWatch
    @Published var watchedEpisodes: Int = 0
    @Published var score: Int = 0 // 0 means no score
    
    var isTracked: Bool {
        trackedAnime != nil
    }

    init(anime: Anime) {
        self.anime = anime
        self.fetchTrackedStatus()
    }
    
    func fetchTrackedStatus() {
        self.trackedAnime = StorageService.shared.getTrackedAnime(id: anime.id)
        
        if let tracked = trackedAnime {
            self.status = tracked.status
            self.watchedEpisodes = tracked.watchedEpisodes
            self.score = tracked.score ?? 0
        }
    }
    
    func toggleTracking() {
        if isTracked {
            // Remove from tracking
            StorageService.shared.delete(id: anime.id)
            self.trackedAnime = nil
        } else {
            // Add to tracking
            let newTrackedAnime = TrackedAnime(
                id: anime.id,
                status: .planToWatch,
                watchedEpisodes: 0,
                score: nil,
                addedDate: Date()
            )
            StorageService.shared.add(anime: newTrackedAnime)
            self.trackedAnime = newTrackedAnime
            fetchTrackedStatus() // To sync the state
        }
    }
    
    func saveChanges() {
        guard var tracked = trackedAnime else { return }
        
        tracked.status = status
        tracked.watchedEpisodes = watchedEpisodes
        tracked.score = score == 0 ? nil : score
        
        StorageService.shared.update(anime: tracked)
        self.trackedAnime = tracked // Update local copy
    }
}
