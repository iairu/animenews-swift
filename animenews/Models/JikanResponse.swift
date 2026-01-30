import Foundation

// A generic wrapper to mimic the structure of Jikan API responses.
struct JikanResponse<T: Codable>: Codable {
    let data: T
}

struct JikanSearchResponse<T: Codable>: Codable {
    let data: [T]
    let pagination: Pagination
}

struct Pagination: Codable {
    let last_visible_page: Int
    let has_next_page: Bool
}
