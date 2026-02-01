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

#if os(iOS)
/// The main TabView for iOS devices.
struct MainTabView: View {
    @StateObject private var tabManager = TabManager()
    
    var body: some View {
        TabView {
            // Render the first 4 "visible" tabs
            ForEach(tabManager.visibleTabs) { section in
                NavigationStack {
                    contentForSection(section)
                }
                .tabItem {
                    Label(section.title, systemImage: section.icon)
                }
                .tag(section)
            }
            
            // Fixed "More" tab for the rest
            NavigationStack {
                MoreView(tabManager: tabManager)
            }
            .tabItem {
                Label("More", systemImage: "ellipsis")
            }
            .tag(SidebarSection.allCases.first { !tabManager.visibleTabs.contains($0) } ?? .settings) // Unique tag to avoid conflicts, though not strictly needed for this logic
        }
    }
    
    @ViewBuilder
    private func contentForSection(_ section: SidebarSection) -> some View {
        switch section {
        case .dashboard: DashboardView()
        case .news: NewsListView()
        case .database: AnimeListView()
        case .schedule: ScheduleView()
        case .myAnime: MyAnimeListView()
        case .settings: SettingsView()
        }
    }
}
#endif

/// The main NavigationView for macOS, providing adaptive column layout
struct MainNavigationView: View {
    @State private var selectedSection: SidebarSection? = .dashboard
    @State private var selectedAnime: Anime?
    @State private var selectedNewsItem: NewsItem?
    
    var body: some View {
        NavigationView {
            // Column 1: Main Sidebar
            sidebarContent
                .frame(minWidth: 180, idealWidth: 200, maxWidth: 220)
            
            // Column 2: Content (and optionally Column 3 for some views)
            contentArea
        }
        .navigationViewStyle(.columns)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
        }
        .onChange(of: selectedSection) { _ in
            // Clear selections when changing sections
            selectedAnime = nil
            selectedNewsItem = nil
        }
    }
    
    private var sidebarContent: some View {
        List(selection: $selectedSection) {
            Section("Main") {
                ForEach(SidebarSection.mainSections, id: \.self) { section in
                    Label(section.title, systemImage: section.icon)
                        .tag(section)
                }
            }
            
            Section("Library") {
                ForEach(SidebarSection.librarySections, id: \.self) { section in
                    Label(section.title, systemImage: section.icon)
                        .tag(section)
                }
            }
            
            Section {
                Label(SidebarSection.settings.title, systemImage: SidebarSection.settings.icon)
                    .tag(SidebarSection.settings)
            }
        }
        .listStyle(.sidebar)
    }
    
    @ViewBuilder
    private var contentArea: some View {
        switch selectedSection {
        // Two-pane views (Dashboard, Settings) - no detail column
        case .dashboard:
            DashboardView()
                .frame(minWidth: 600)
        case .settings:
            SettingsView()
                .frame(minWidth: 500)
        
        // Three-pane views - content list + detail (wrapped in HStack for horizontal layout)
        case .news:
            HStack(spacing: 0) {
                NewsContentView(selectedItem: $selectedNewsItem)
                    .frame(minWidth: 300, maxWidth: 400)
                newsDetailView
                    .frame(minWidth: 400)
            }
        
        case .database:
            HStack(spacing: 0) {
                AnimeContentView(selectedAnime: $selectedAnime)
                    .frame(minWidth: 300, maxWidth: 400)
                animeDetailView
                    .frame(minWidth: 400)
            }
        
        case .schedule:
            HStack(spacing: 0) {
                ScheduleContentView(selectedAnime: $selectedAnime)
                    .frame(minWidth: 300, maxWidth: 400)
                animeDetailView
                    .frame(minWidth: 400)
            }
        
        case .myAnime:
            HStack(spacing: 0) {
                MyAnimeContentView(selectedAnime: $selectedAnime)
                    .frame(minWidth: 300, maxWidth: 400)
                animeDetailView
                    .frame(minWidth: 400)
            }
        
        case .none:
            Text("Select a section")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private var newsDetailView: some View {
        if let item = selectedNewsItem {
            NewsDetailView(item: item)
        } else {
            DetailPlaceholderView(message: "Select an article to read")
        }
    }
    
    @ViewBuilder
    private var animeDetailView: some View {
        if let anime = selectedAnime {
            AnimeDetailView(anime: anime)
        } else {
            DetailPlaceholderView(message: "Select an anime to view details")
        }
    }
    
    private func toggleSidebar() {
        #if canImport(AppKit)
        NSApp.keyWindow?.firstResponder?.tryToPerform(
            #selector(NSSplitViewController.toggleSidebar(_:)), with: nil
        )
        #endif
    }
}

// MARK: - Sidebar Section Enum



// MARK: - Content Views (Column 2)

/// News content list for column 2
struct NewsContentView: View {
    @StateObject private var viewModel = NewsViewModel()
    @Binding var selectedItem: NewsItem?
    
    var body: some View {
        List(viewModel.newsItems, selection: $selectedItem) { item in
            NewsRow(item: item)
                .tag(item)
        }
        .navigationTitle("Anime News")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                sourceFilterMenu
                refreshButton
            }
        }
        .task {
            if viewModel.newsItems.isEmpty {
                await viewModel.fetchNews()
            }
        }
        .overlay {
            loadingOverlay
        }
    }
    
    private var sourceFilterMenu: some View {
        Menu {
            Button("All Sources", action: {})
            Button("Anime News Network", action: {})
            Button("Crunchyroll", action: {})
            Button("MyAnimeList", action: {})
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
    }
    
    private var refreshButton: some View {
        Button(action: { Task { await viewModel.fetchNews() } }) {
            Image(systemName: "arrow.clockwise")
        }
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading && viewModel.newsItems.isEmpty {
            ProgressView("Loading news...")
        } else if let error = viewModel.errorMessage, viewModel.newsItems.isEmpty {
            ErrorView(message: error) {
                Task { await viewModel.fetchNews() }
            }
        }
    }
}

/// Anime database content list for column 2
struct AnimeContentView: View {
    @StateObject private var viewModel = AnimeListViewModel()
    @Binding var selectedAnime: Anime?
    @State private var searchQuery = ""
    
    var body: some View {
        List(viewModel.animeList, selection: $selectedAnime) { anime in
            AnimeListRow(anime: anime)
                .tag(anime)
        }
        .navigationTitle("Database")
        .searchable(text: $searchQuery, prompt: "Search anime...")
        .onChange(of: searchQuery) { query in
            Task {
                if query.isEmpty {
                    await viewModel.fetchTopAnime()
                } else {
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    await viewModel.searchAnime(query: query)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { Task { await viewModel.fetchTopAnime() } }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .task {
            if viewModel.animeList.isEmpty {
                await viewModel.fetchTopAnime()
            }
        }
        .overlay {
            if viewModel.isLoading && viewModel.animeList.isEmpty {
                ProgressView("Loading anime...")
            }
        }
    }
}

/// Schedule content list for column 2
struct ScheduleContentView: View {
    @StateObject private var viewModel = ScheduleViewModel()
    @Binding var selectedAnime: Anime?
    @State private var selectedDay: DayOfWeek = DayOfWeek.today
    
    var body: some View {
        VStack(spacing: 0) {
            // Compact day picker
            dayPicker
            
            Divider()
            
            // Anime list
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading...")
                Spacer()
            } else if viewModel.scheduledAnime.isEmpty {
                Spacer()
                emptyState
                Spacer()
            } else {
                List(viewModel.scheduledAnime, selection: $selectedAnime) { anime in
                    ScheduleRow(anime: anime)
                        .tag(anime)
                }
            }
        }
        .navigationTitle("Schedule")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { Task { await viewModel.fetchSchedule(for: selectedDay) } }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .task {
            await viewModel.fetchSchedule(for: selectedDay)
        }
    }
    
    private var dayPicker: some View {
        HStack {
            Menu {
                ForEach(DayOfWeek.allCases, id: \.self) { day in
                    Button(action: {
                        selectedDay = day
                        Task { await viewModel.fetchSchedule(for: day) }
                    }) {
                        HStack {
                            Text(day.rawValue)
                            if selectedDay == day {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "calendar")
                    Text(selectedDay.rawValue)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.accentColor.opacity(0.15))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No anime scheduled")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Try selecting a different day")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

/// My Anime list content for column 2
struct MyAnimeContentView: View {
    @StateObject private var viewModel = MyAnimeListViewModel()
    @Binding var selectedAnime: Anime?
    @State private var searchQuery = ""
    @State private var sortOption: SortOption = .title
    
    var body: some View {
        VStack(spacing: 0) {
            // Filters
            filterBar
            
            Divider()
            
            // List
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.trackedAnime.isEmpty {
                Spacer()
                emptyLibraryView
                Spacer()
            } else {
                List(sortedAnime, selection: $selectedAnime) { anime in
                    MyAnimeRow(anime: anime)
                        .tag(anime)
                }
            }
        }
        .navigationTitle("My Anime")
        .searchable(text: $searchQuery, prompt: "Search my anime...")
        .task {
            await viewModel.filterAndFetchAnime()
        }
        .onChange(of: viewModel.statusFilter) { _ in
            Task { await viewModel.filterAndFetchAnime() }
        }
    }
    
    private var filterBar: some View {
        VStack(spacing: 8) {
            HStack {
                Menu {
                    Button("All") { viewModel.statusFilter = nil }
                    Divider()
                    ForEach(TrackedAnime.Status.allCases, id: \.self) { status in
                        Button(status.rawValue) { viewModel.statusFilter = status }
                    }
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(viewModel.statusFilter?.rawValue ?? "All Statuses")
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.accentColor.opacity(0.15))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            
            HStack {
                Picker("Sort", selection: $sortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 150)
                
                Spacer()
            }
        }
        .padding()
    }
    
    private var emptyLibraryView: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.slash")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No tracked anime")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Add anime from the Database")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var filteredAnime: [Anime] {
        if searchQuery.isEmpty {
            return viewModel.trackedAnime
        }
        return viewModel.trackedAnime.filter {
            $0.title.lowercased().contains(searchQuery.lowercased())
        }
    }
    
    private var sortedAnime: [Anime] {
        switch sortOption {
        case .title:
            return filteredAnime.sorted { $0.title < $1.title }
        case .status:
            return filteredAnime.sorted {
                let statusA = StorageService.shared.getTrackedAnime(id: $0.id)?.status.rawValue ?? ""
                let statusB = StorageService.shared.getTrackedAnime(id: $1.id)?.status.rawValue ?? ""
                return statusA < statusB
            }
        case .progress:
            return filteredAnime.sorted {
                let progressA = StorageService.shared.getTrackedAnime(id: $0.id)?.watchedEpisodes ?? 0
                let progressB = StorageService.shared.getTrackedAnime(id: $1.id)?.watchedEpisodes ?? 0
                return progressA > progressB
            }
        }
    }
}

// MARK: - Supporting Views

struct AnimeListRow: View {
    let anime: Anime
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImageView(url: URL(string: anime.images.jpg.imageUrl))
                .frame(width: 50, height: 70)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(anime.title)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    if let score = anime.score {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", score))
                        }
                        .font(.caption)
                    }
                    
                    if let episodes = anime.episodes {
                        Text("\(episodes) eps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let type = anime.type {
                        Text(type)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button(action: {
                copyToClipboard(anime.url)
            }) {
                Label("Copy Link", systemImage: "doc.on.doc")
            }
            
            if let url = URL(string: anime.url) {
                Link(destination: url) {
                    Label("Open in Browser", systemImage: "safari")
                }
            }
        }
    }
    
    private func copyToClipboard(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
}

struct DetailPlaceholderView: View {
    var message: String = "Select an item to view details"
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text(message)
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry", action: retryAction)
                .buttonStyle(.bordered)
        }
    }
}

// MARK: - Previews

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .preferredColorScheme(.dark)
    }
}
