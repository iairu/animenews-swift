import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else if viewModel.isLoading && viewModel.trendingAnime.isEmpty {
                ProgressView("Loading Dashboard...")
                    .frame(maxWidth: .infinity, minHeight: 400)
            } else {
                VStack(spacing: 24) {
                    // Header with date
                    headerSection
                    
                    // Quick Stats Row
                    quickStatsSection
                    
                    // Main Grid
                    LazyVGrid(columns: columns, spacing: 20) {
                        // Activity Rings
                        activityRingsCard
                        
                        // Library Overview
                        libraryOverviewCard
                        
                        // Trending Chart
                        trendingChartCard
                        
                        // Trending List
                        trendingListCard
                    }
                    
                    // Seasonal Anime Section
                    seasonalAnimeSection
                    
                    // Upcoming Episodes
                    if !viewModel.upcomingEpisodes.isEmpty {
                        upcomingEpisodesSection
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Summary")
        .toolbar {
            #if os(macOS)
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                }) {
                    Image(systemName: "sidebar.left")
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    Task { await viewModel.fetchDashboardData() }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            #endif
        }
        .task {
            await viewModel.fetchDashboardData()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Your Anime Dashboard")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            // Season Badge
            HStack(spacing: 6) {
                Image(systemName: seasonIcon)
                Text("\(viewModel.currentSeason) \(String(viewModel.currentYear))")
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.accentColor.opacity(0.2))
            .cornerRadius(20)
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    private var seasonIcon: String {
        switch viewModel.currentSeason {
        case "Winter": return "snowflake"
        case "Spring": return "leaf.fill"
        case "Summer": return "sun.max.fill"
        default: return "leaf.fill"
        }
    }
    
    // MARK: - Quick Stats
    private var quickStatsSection: some View {
        HStack(spacing: 16) {
            QuickStatCard(
                title: "Episodes Watched",
                value: "\(viewModel.totalEpisodesWatched)",
                icon: "play.circle.fill",
                color: .blue
            )
            
            QuickStatCard(
                title: "Avg. Score",
                value: viewModel.averageScore > 0 ? String(format: "%.1f", viewModel.averageScore) : "N/A",
                icon: "star.fill",
                color: .yellow
            )
            
            QuickStatCard(
                title: "Completed",
                value: "\(viewModel.completedCount)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            QuickStatCard(
                title: "Plan to Watch",
                value: "\(viewModel.planToWatchCount)",
                icon: "bookmark.fill",
                color: .purple
            )
        }
    }
    
    // MARK: - Activity Rings Card
    private var activityRingsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Seasonal Activity")
                    .font(.title2)
                    .fontWeight(.bold)

                HStack(spacing: 30) {
                    VStack {
                        ActivityRing(
                            progress: viewModel.seasonalProgress,
                            color: .accentColor,
                            lineWidth: 14
                        )
                        .frame(width: 90, height: 90)
                        .overlay(
                            Text("\(viewModel.watchingCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                        )
                        Text("Watching")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    VStack {
                        ActivityRing(
                            progress: viewModel.totalShowsInSeason > 0 ? Double(viewModel.completedCount) / Double(viewModel.totalShowsInSeason) : 0,
                            color: .green,
                            lineWidth: 14
                        )
                        .frame(width: 90, height: 90)
                        .overlay(
                            Text("\(viewModel.completedCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                        )
                        Text("Completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Library Overview Card
    private var libraryOverviewCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Library Overview")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    NavigationLink(destination: MyAnimeListView()) {
                        LibraryStatRow(
                            label: "Currently Watching",
                            value: viewModel.watchingCount,
                            color: .blue,
                            icon: "play.fill"
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(destination: MyAnimeListView()) {
                        LibraryStatRow(
                            label: "Completed",
                            value: viewModel.completedCount,
                            color: .green,
                            icon: "checkmark"
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(destination: MyAnimeListView()) {
                        LibraryStatRow(
                            label: "Plan to Watch",
                            value: viewModel.planToWatchCount,
                            color: .purple,
                            icon: "bookmark"
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                    
                    NavigationLink(destination: MyAnimeListView()) {
                        HStack {
                            Text("Total in Library")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(viewModel.watchingCount + viewModel.completedCount + viewModel.planToWatchCount)")
                                .fontWeight(.bold)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Trending Chart Card
    private var trendingChartCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Top Anime Scores")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Current top 5 by rating")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TrendChart(data: viewModel.trendChartData, color: .accentColor)
                    .frame(height: 100)
                    .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Trending List Card
    @ViewBuilder
    private var trendingListCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Trending Now")
                    .font(.title2)
                    .fontWeight(.bold)

                ForEach(Array(viewModel.trendingAnime.enumerated()), id: \.element.id) { index, anime in
                    NavigationLink(destination: AnimeDetailView(anime: anime).id(anime.id)) {
                        HStack {
                            Text("#\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                            
                            Text(anime.title)
                                .font(.subheadline)
                                .lineLimit(1)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", anime.score ?? 0.0))
                            }
                            .font(.caption.weight(.medium))
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    
                    if index < viewModel.trendingAnime.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }
    
    // MARK: - Seasonal Anime Section
    private var seasonalAnimeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(viewModel.currentSeason) \(String(viewModel.currentYear)) Anime")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(viewModel.totalShowsInSeason) shows")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 130, maximum: 150), spacing: 16)
            ], spacing: 16) {
                ForEach(viewModel.seasonalAnime) { anime in
                    NavigationLink(destination: AnimeDetailView(anime: anime).id(anime.id)) {
                        SeasonalAnimeCard(anime: anime)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Upcoming Episodes Section
    private var upcomingEpisodesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Continue Watching")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                ForEach(viewModel.upcomingEpisodes, id: \.anime.id) { item in
                    HStack {
                        AsyncImageView(url: URL(string: item.anime.images.jpg.imageUrl))
                            .frame(width: 50, height: 70)
                            .cornerRadius(6)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.anime.title)
                                .font(.headline)
                                .lineLimit(1)
                            Text("Episode \(item.nextEpisode)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "play.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Retry") {
                Task { await viewModel.fetchDashboardData() }
            }
            .buttonStyle(.bordered)
            .tint(.accentColor)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
}

// MARK: - Supporting Views

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        #if os(macOS)
        .background(.regularMaterial)
        #else
        .background(Color(.secondarySystemGroupedBackground))
        #endif
        .cornerRadius(12)
    }
}

struct LibraryStatRow: View {
    let label: String
    let value: Int
    let color: Color
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(label)
            
            Spacer()
            
            Text("\(value)")
                .fontWeight(.semibold)
        }
    }
}

struct SeasonalAnimeCard: View {
    let anime: Anime
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImageView(url: URL(string: anime.images.jpg.largeImageUrl))
                .frame(width: 120, height: 170)
                .cornerRadius(8)
            
            Text(anime.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(width: 120, alignment: .leading)
            
            HStack(spacing: 4) {
                if let score = anime.score, score > 0 {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", score))
                } else {
                    Text("Not rated")
                        .foregroundColor(.secondary)
                }
            }
            .font(.caption)
        }
    }
}

// MARK: - Previews

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView()
        }
        .preferredColorScheme(.dark)
    }
}
