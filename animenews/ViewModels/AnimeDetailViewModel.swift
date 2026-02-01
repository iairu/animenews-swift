import SwiftUI

@MainActor
class AnimeDetailViewModel: ObservableObject {
    private var anime: Anime?
    @Published var trackedAnime: TrackedAnime?
    
    @Published var status: TrackedAnime.Status = .planToWatch
    @Published var watchedEpisodes: Int = 0
    @Published var score: Int = 0 // 0 means no score
    
    var isTracked: Bool {
        trackedAnime != nil
    }
    
    var currentAnimeId: Int? {
        anime?.malId
    }

    init() {}
    
    func setAnime(_ anime: Anime) {
        // Only update if it's a different anime
        guard self.anime?.malId != anime.malId else { return }
        self.anime = anime
        self.fetchTrackedStatus()
    }
    
    func fetchTrackedStatus() {
        guard let anime = anime else { return }
        self.trackedAnime = StorageService.shared.getTrackedAnime(id: anime.malId)
        
        if let tracked = trackedAnime {
            self.status = tracked.status
            self.watchedEpisodes = tracked.watchedEpisodes
            self.score = tracked.score ?? 0
        }
    }
    
    func toggleTracking() {
        guard let anime = anime else { return }
        
        if isTracked {
            // Remove from tracking
            StorageService.shared.delete(id: anime.malId)
            self.trackedAnime = nil
        } else {
            // Add to tracking
            let newTrackedAnime = TrackedAnime(
                id: anime.malId,
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
