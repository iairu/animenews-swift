import Foundation

class StorageService {
    static let shared = StorageService()
    
    private let fileURL: URL
    
    private var trackedAnimes: [TrackedAnime] = []
    
    private init() {
        // Get the URL for the documents directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        self.fileURL = urls[0].appendingPathComponent("tracked_animes.json")
        
        self.load()
    }
    
    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            self.trackedAnimes = try decoder.decode([TrackedAnime].self, from: data)
        } catch {
            // If file doesn't exist or there's a decoding error, start with an empty array.
            self.trackedAnimes = []
        }
    }
    
    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(trackedAnimes)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Error saving tracked animes: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Public API
    
    func getTrackedAnime(id: Int) -> TrackedAnime? {
        return trackedAnimes.first { $0.id == id }
    }
    
    func getAllTrackedAnimes() -> [TrackedAnime] {
        return trackedAnimes
    }
    
    func add(anime: TrackedAnime) {
        if !trackedAnimes.contains(where: { $0.id == anime.id }) {
            trackedAnimes.append(anime)
            save()
        }
    }
    
    func update(anime: TrackedAnime) {
        if let index = trackedAnimes.firstIndex(where: { $0.id == anime.id }) {
            trackedAnimes[index] = anime
            save()
        }
    }
    
    func delete(id: Int) {
        trackedAnimes.removeAll { $0.id == id }
        save()
    }
}
