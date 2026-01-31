import SwiftUI

struct RootView: View {
    var body: some View {
        #if os(iOS)
        MainTabView()
        #else
        MainNavigationView()
        #endif
    }
}

/// The main TabView for iOS devices.
struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationView {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.xaxis")
            }
            
            NavigationView {
                NewsListView()
            }
            .tabItem {
                Label("News", systemImage: "newspaper.fill")
            }
            
            NavigationView {
                DatabaseView()
            }
            .tabItem {
                Label("Database", systemImage: "books.vertical.fill")
            }
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

/// The main NavigationView for macOS, providing a sidebar-based layout.
struct MainNavigationView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: DashboardView()) {
                    Label("Dashboard", systemImage: "chart.bar.xaxis")
                }
                NavigationLink(destination: NewsListView()) {
                    Label("News", systemImage: "newspaper.fill")
                }
                NavigationLink(destination: DatabaseView()) {
                    Label("Database", systemImage: "books.vertical.fill")
                }
                Spacer() // Pushes settings to the bottom
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 200, idealWidth: 220, maxWidth: 240)
            
            // Initial Detail View
            Text("Select a category")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.secondary)
        }
    }
}

/// A wrapper view for the anime database section to be used in navigation.
struct DatabaseView: View {
    var body: some View {
        AnimeListView()
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview for iOS
        RootView()
            .preferredColorScheme(.dark)
            .previewDisplayName("iOS Preview")

        // Preview for macOS
        RootView()
            .previewLayout(.fixed(width: 1200, height: 800))
            .environment(\.colorScheme, .light)
            .previewDisplayName("macOS Preview")
    }
}
