import SwiftUI

enum NavigationItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case news = "News"
    case database = "Database"
    case settings = "Settings"

    var id: String { self.rawValue }

    @ViewBuilder
    var icon: some View {
        switch self {
        case .dashboard:
            Label(self.rawValue, systemImage: "chart.bar.xaxis")
        case .news:
            Label(self.rawValue, systemImage: "newspaper.fill")
        case .database:
            Label(self.rawValue, systemImage: "books.vertical.fill")
        case .settings:
            Label(self.rawValue, systemImage: "gear")
        }
    }
}
