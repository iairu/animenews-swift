import Foundation

struct NewsItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let link: String
    let pubDate: Date
    let source: String
    let description: String

    // Placeholder data
    static let placeholders: [NewsItem] = [
        NewsItem(
            title: "Studio Ghibli Announces New Film 'The Last Ember'",
            link: "https://www.animenewsnetwork.com/news/2026-01-30/article.12345",
            pubDate: Date().addingTimeInterval(-3600), // 1 hour ago
            source: "Anime News Network",
            description: "The legendary studio behind Spirited Away and My Neighbor Totoro has revealed its first project in over five years, a fantasy epic directed by a newcomer."
        ),
        NewsItem(
            title: "'Jujutsu Kaisen' Season 3 Officially Confirmed for 2025",
            link: "https://www.crunchyroll.com/news/jujutsu-kaisen-s3-confirmed",
            pubDate: Date().addingTimeInterval(-7200), // 2 hours ago
            source: "Crunchyroll",
            description: "Following the massive success of the Shibuya Incident arc, MAPPA has confirmed that the Culling Game arc will be adapted next year."
        ),
        NewsItem(
            title: "Classic 'Cowboy Bebop' Vinyl Soundtrack Gets Limited Re-release",
            link: "https://www.funimation.com/blog/cowboy-bebop-vinyl-rerelease",
            pubDate: Date().addingTimeInterval(-10800), // 3 hours ago
            source: "Funimation",
            description: "The iconic soundtrack from The Seatbelts is coming back to vinyl for a limited run, featuring a new collector's edition packaging."
        ),
        NewsItem(
            title: "New 'Berserk' Chapter Announcement Excites Fans",
            link: "https://www.example.com/berserk-chapter",
            pubDate: Date().addingTimeInterval(-14400), // 4 hours ago
            source: "Manga Mogul",
            description: "A new chapter of the late Kentaro Miura's masterpiece, 'Berserk,' has been announced, continuing the epic journey of Guts."
        )
    ]
}
