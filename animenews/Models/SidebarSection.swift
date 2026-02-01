import SwiftUI

enum SidebarSection: String, Hashable, CaseIterable, Codable, Identifiable {
    case dashboard = "Dashboard"
    case news = "News"
    case database = "Database"
    case schedule = "Schedule"
    case myAnime = "My Anime"
    case settings = "Settings"
    
    var id: String { rawValue }
    
    var title: String { rawValue }
    
    var icon: String {
        switch self {
        case .dashboard: return "chart.bar.xaxis"
        case .news: return "newspaper.fill"
        case .database: return "books.vertical.fill"
        case .schedule: return "calendar"
        case .myAnime: return "heart.fill"
        case .settings: return "gear"
        }
    }
    
    static var mainSections: [SidebarSection] {
        [.dashboard, .news, .database, .schedule]
    }
    
    static var librarySections: [SidebarSection] {
        [.myAnime]
    }
}
