import SwiftUI

/// Custom image cache for anime poster images
actor ImageCache {
    static let shared = ImageCache()
    
    private var cache: [URL: Image] = [:]
    private var loadingTasks: [URL: Task<Image?, Never>] = [:]
    private let maxCacheSize = 100
    
    private init() {}
    
    /// Gets an image from cache or loads it
    func image(for url: URL) async -> Image? {
        // Check cache first
        if let cached = cache[url] {
            return cached
        }
        
        // Check if already loading
        if let existingTask = loadingTasks[url] {
            return await existingTask.value
        }
        
        // Start new loading task
        let task = Task<Image?, Never> {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                #if os(macOS)
                if let nsImage = NSImage(data: data) {
                    let image = Image(nsImage: nsImage)
                    await store(image, for: url)
                    return image
                }
                #else
                if let uiImage = UIImage(data: data) {
                    let image = Image(uiImage: uiImage)
                    await store(image, for: url)
                    return image
                }
                #endif
            } catch {
                print("Failed to load image: \(error.localizedDescription)")
            }
            return nil
        }
        
        loadingTasks[url] = task
        let result = await task.value
        loadingTasks.removeValue(forKey: url)
        
        return result
    }
    
    private func store(_ image: Image, for url: URL) {
        // Simple LRU-ish eviction when cache is full
        if cache.count >= maxCacheSize {
            // Remove oldest entry (first key)
            if let firstKey = cache.keys.first {
                cache.removeValue(forKey: firstKey)
            }
        }
        cache[url] = image
    }
    
    /// Clears the entire cache
    func clearCache() {
        cache.removeAll()
        loadingTasks.values.forEach { $0.cancel() }
        loadingTasks.removeAll()
    }
    
    /// Returns current cache count
    var count: Int {
        cache.count
    }
}

/// Cached async image view with placeholder
struct CachedAsyncImage: View {
    let url: URL?
    @State private var image: Image?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        }
                    }
            }
        }
        .clipped()
        .task(id: url) {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = url else { return }
        
        isLoading = true
        image = await ImageCache.shared.image(for: url)
        isLoading = false
    }
}
