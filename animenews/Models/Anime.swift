import Foundation

// A simplified struct for placeholder data, inspired by the Jikan API.
struct Anime: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let synopsis: String
    let score: Double
    let type: String
    let episodes: Int?
    let status: String
    let year: Int
    let imageUrl: String
    let genres: [String]

    // Placeholder data
    static let placeholder = Anime(
        id: 1,
        title: "Attack on Titan",
        synopsis: "Centuries ago, mankind was slaughtered to near extinction by monstrous humanoid creatures called titans, forcing humans to hide in fear behind enormous concentric walls. What makes these giants truly terrifying is that their taste for human flesh is not born out of hunger but what appears to be out of pleasure. To ensure their survival, the remnants of humanity began living within defensive barriers, resulting in one hundred years without a single titan encounter. However, that calm is soon shattered when a colossal titan manages to breach the supposedly impregnable outer wall, reigniting the fight for survival against the man-eating abominations.",
        score: 8.54,
        type: "TV",
        episodes: 75,
        status: "Finished Airing",
        year: 2013,
        imageUrl: "https://cdn.myanimelist.net/images/anime/10/47347.jpg",
        genres: ["Action", "Drama", "Fantasy", "Mystery"]
    )

    static let placeholders: [Anime] = [
        .placeholder,
        Anime(id: 2, title: "Fullmetal Alchemist: Brotherhood", synopsis: "Synopsis here...", score: 9.15, type: "TV", episodes: 64, status: "Finished Airing", year: 2009, imageUrl: "https://cdn.myanimelist.net/images/anime/12/47348.jpg", genres: ["Action", "Adventure", "Drama", "Fantasy"]),
        Anime(id: 3, title: "Steins;Gate", synopsis: "Synopsis here...", score: 9.09, type: "TV", episodes: 24, status: "Finished Airing", year: 2011, imageUrl: "https://cdn.myanimelist.net/images/anime/13/47349.jpg", genres: ["Drama", "Sci-Fi", "Suspense"]),
        Anime(id: 4, title: "Jujutsu Kaisen", synopsis: "Synopsis here...", score: 8.68, type: "TV", episodes: 24, status: "Currently Airing", year: 2020, imageUrl: "https://cdn.myanimelist.net/images/anime/14/47350.jpg", genres: ["Action", "Supernatural"]),
        Anime(id: 5, title: "Your Name.", synopsis: "Synopsis here...", score: 8.91, type: "Movie", episodes: 1, status: "Finished Airing", year: 2016, imageUrl: "https://cdn.myanimelist.net/images/anime/15/47351.jpg", genres: ["Romance", "Supernatural", "Drama"])
    ]
}
