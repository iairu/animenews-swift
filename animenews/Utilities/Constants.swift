import Foundation

/// A centralized place for constants used throughout the application.
struct Constants {
    
    /// Constants related to the Jikan API (api.jikan.moe)
    struct JikanAPI {
        static let baseUrl = "https://api.jikan.moe/v4"
    }

    /// URLs for various RSS feeds that provide anime news.
    struct RSSFeeds {
        static let animeNewsNetwork = "https://www.animenewsnetwork.com/all/rss.xml?ann-edition=us"
        static let crunchyroll = "https://www.crunchyroll.com/news/rss"
        // Potential future feeds can be added here.
    }
    
    /// User-facing strings or links
    struct AppInfo {
        static let version = "1.0.0 (Alpha)"
        static let dataAttribution = "Data provided by Jikan API (MyAnimeList). This app is not affiliated with MyAnimeList."
    }
}
