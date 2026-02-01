import Foundation

struct NewsItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let link: String
    let pubDate: Date
    let source: String
    let description: String
    
    // Custom Hashable implementation for stable selection
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(link)
        hasher.combine(source)
    }
    
    static func == (lhs: NewsItem, rhs: NewsItem) -> Bool {
        lhs.title == rhs.title && lhs.link == rhs.link && lhs.source == rhs.source
    }

    // Placeholder data (fallback when RSS feeds fail to load)
    static let placeholders: [NewsItem] = [
        NewsItem(
            title: "Studio Ghibli Announces New Film 'The Last Ember'",
            link: "https://www.animenewsnetwork.com/",
            pubDate: Date().addingTimeInterval(-3600), // 1 hour ago
            source: "Anime News Network",
            description: "The legendary studio behind Spirited Away and My Neighbor Totoro has revealed its first project in over five years, a fantasy epic directed by a newcomer."
        ),
        NewsItem(
            title: "'Jujutsu Kaisen' Season 3 Officially Confirmed for 2025",
            link: "https://www.crunchyroll.com/news",
            pubDate: Date().addingTimeInterval(-7200), // 2 hours ago
            source: "Crunchyroll",
            description: "Following the massive success of the Shibuya Incident arc, MAPPA has confirmed that the Culling Game arc will be adapted next year."
        ),
        NewsItem(
            title: "Classic 'Cowboy Bebop' Vinyl Soundtrack Gets Limited Re-release",
            link: "https://myanimelist.net/news",
            pubDate: Date().addingTimeInterval(-10800), // 3 hours ago
            source: "MyAnimeList",
            description: "The iconic soundtrack from The Seatbelts is coming back to vinyl for a limited run, featuring a new collector's edition packaging."
        ),
        NewsItem(
            title: "New 'Berserk' Chapter Announcement Excites Fans",
            link: "https://myanimelist.net/news",
            pubDate: Date().addingTimeInterval(-14400), // 4 hours ago
            source: "MyAnimeList",
            description: "A new chapter of the late Kentaro Miura's masterpiece, 'Berserk,' has been announced, continuing the epic journey of Guts."
        )
    ]
}
