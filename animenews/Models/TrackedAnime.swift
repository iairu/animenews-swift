import Foundation

struct TrackedAnime: Codable, Identifiable {
    let id: Int // Jikan anime ID
    var status: Status
    var watchedEpisodes: Int
    var score: Int? // User's score, 1-10
    var addedDate: Date

    enum Status: String, Codable, CaseIterable {
        case watching = "Watching"
        case completed = "Completed"
        case onHold = "On Hold"
        case dropped = "Dropped"
        case planToWatch = "Plan to Watch"
    }
}
