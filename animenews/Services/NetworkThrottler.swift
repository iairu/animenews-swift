import Foundation

/// Token bucket rate limiter to respect Jikan's 3 requests/second limit
actor NetworkThrottler {
    static let shared = NetworkThrottler()
    
    private let maxTokens: Int
    private let refillRate: TimeInterval // seconds per token
    private var availableTokens: Int
    private var lastRefillTime: Date
    
    private init(maxTokens: Int = 3, refillRate: TimeInterval = 1.0/3.0) {
        self.maxTokens = maxTokens
        self.refillRate = refillRate
        self.availableTokens = maxTokens
        self.lastRefillTime = Date()
    }
    
    /// Waits if necessary to acquire a request token
    func acquire() async {
        refillTokens()
        
        while availableTokens <= 0 {
            // Calculate wait time until next token
            let waitTime = refillRate - Date().timeIntervalSince(lastRefillTime)
            if waitTime > 0 {
                try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }
            refillTokens()
        }
        
        availableTokens -= 1
    }
    
    private func refillTokens() {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastRefillTime)
        let tokensToAdd = Int(elapsed / refillRate)
        
        if tokensToAdd > 0 {
            availableTokens = min(maxTokens, availableTokens + tokensToAdd)
            lastRefillTime = now
        }
    }
    
    /// Current number of available tokens
    var tokens: Int {
        availableTokens
    }
}

/// Throttled URLSession wrapper
class ThrottledURLSession {
    static let shared = ThrottledURLSession()
    
    private let session: URLSession
    private let throttler = NetworkThrottler.shared
    
    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,  // 50 MB
            diskCapacity: 200 * 1024 * 1024,   // 200 MB
            diskPath: "animenews_cache"
        )
        self.session = URLSession(configuration: config)
    }
    
    /// Performs a throttled data request
    func data(from url: URL) async throws -> (Data, URLResponse) {
        await throttler.acquire()
        return try await session.data(from: url)
    }
    
    /// Performs a throttled data request with URLRequest
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        await throttler.acquire()
        return try await session.data(for: request)
    }
}
