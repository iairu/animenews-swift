import Foundation

struct Anime: Identifiable, Codable, Hashable {
    let malId: Int
    let url: String
    let images: ImageURLs
    let trailer: Trailer?
    let title: String
    let type: String?
    let source: String?
    let episodes: Int?
    let status: String?
    let rating: String?
    let score: Double?
    let rank: Int?
    let popularity: Int?
    let members: Int?
    let favorites: Int?
    let synopsis: String?
    let year: Int?
    let broadcast: Broadcast?
    let producers: [MalUrl]?
    let licensors: [MalUrl]?
    let studios: [MalUrl]?
    let genres: [MalUrl]
    let themes: [MalUrl]?
    let demographics: [MalUrl]?

    var id: Int { malId }

    struct ImageURLs: Codable, Hashable {
        let jpg: JPGImageURLs
        let webp: WEBPImageURLs?
    }

    struct JPGImageURLs: Codable, Hashable {
        let imageUrl: String
        let smallImageUrl: String
        let largeImageUrl: String
    }

    struct WEBPImageURLs: Codable, Hashable {
        let imageUrl: String?
        let smallImageUrl: String?
        let largeImageUrl: String?
    }
    
    struct Trailer: Codable, Hashable {
        let youtubeId: String?
        let url: String?
        let embedUrl: String?
    }

    struct Broadcast: Codable, Hashable {
        let day: String?
        let time: String?
        let timezone: String?
        let string: String?
    }

    struct MalUrl: Codable, Hashable, Identifiable {
        let malId: Int
        let type: String
        let name: String
        let url: String

        var id: Int { malId }
    }

    static var placeholder: Anime {
        Anime(
            malId: 1,
            url: "https://myanimelist.net/anime/1/Cowboy_Bebop",
            images: .init(
                jpg: .init(
                    imageUrl: "https://cdn.myanimelist.net/images/anime/4/19644.jpg",
                    smallImageUrl: "https://cdn.myanimelist.net/images/anime/4/19644t.jpg",
                    largeImageUrl: "https://cdn.myanimelist.net/images/anime/4/19644l.jpg"
                ),
                webp: nil
            ),
            trailer: .init(youtubeId: "qig4KOK2R2g", url: "https://www.youtube.com/watch?v=qig4KOK2R2g", embedUrl: "https://www.youtube.com/embed/qig4KOK2R2g?enablejsapi=1&wmode=opaque&autoplay=1"),
            title: "Cowboy Bebop",
            type: "TV",
            source: "Original",
            episodes: 26,
            status: "Finished Airing",
            rating: "R - 17+ (violence & profanity)",
            score: 8.75,
            rank: 28,
            popularity: 38,
            members: 1568469,
            favorites: 71991,
            synopsis: "In the year 2071, humanity has colonized several of the planets and moons of the solar system leaving the now uninhabitable surface of planet Earth behind. The Inter Solar System Police attempts to keep peace in the galaxy, aided in part by outlaw bounty hunters, referred to as \"Cowboys.\" The ragtag team aboard the spaceship Bebop are two such individuals.",
            year: 1998,
            broadcast: .init(day: "Saturdays", time: "01:00", timezone: "Asia/Tokyo", string: "Saturdays at 01:00 (JST)"),
            producers: [.init(malId: 23, type: "anime", name: "Bandai Visual", url: "https://myanimelist.net/anime/producer/23/Bandai_Visual")],
            licensors: [.init(malId: 102, type: "anime", name: "Funimation", url: "https://myanimelist.net/anime/producer/102/Funimation")],
            studios: [.init(malId: 14, type: "anime", name: "Sunrise", url: "https://myanimelist.net/anime/producer/14/Sunrise")],
            genres: [.init(malId: 1, type: "anime", name: "Action", url: "https://myanimelist.net/anime/genre/1/Action")],
            themes: [.init(malId: 50, type: "anime", name: "Adult Cast", url: "https://myanimelist.net/anime/genre/50/Adult_Cast")],
            demographics: [.init(malId: 42, type: "anime", name: "Seinen", url: "https://myanimelist.net/anime/genre/42/Seinen")]
        )
    }
    
    static let placeholders: [Anime] = [ .placeholder ]
}