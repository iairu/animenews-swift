import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()

    // Define the grid layout: two columns of flexible width.
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.trendingAnime.isEmpty {
                ProgressView("Fetching Dashboard Data...")
                    .frame(maxWidth: .infinity, minHeight: 400)
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    // Span the activity rings across both columns
                    activityRings
                        .gridCellColumns(2)

                    trendingChart
                    
                    trendingList
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
            #endif
        }
    }
    
    private var activityRings: some View {
        GradientCard(startColor: Color.blue.opacity(0.4), endColor: Color.purple.opacity(0.3)) {
            VStack {
                Text("Seasonal Activity")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 30) {
                    VStack {
                        ActivityRing(
                            progress: viewModel.seasonalProgress,
                            color: .pink,
                            lineWidth: 16
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text("\(viewModel.watchingCount)/\(viewModel.totalShowsInSeason)")
                                .font(.headline)
                        )
                        Text("Watching")
                            .font(.caption)
                    }
                    
                    VStack {
                        // Placeholder until real data source is available
                        ActivityRing(
                            progress: 0.82,
                            color: .green,
                            lineWidth: 16
                        )
                        .frame(width: 100, height: 100)
                        .overlay(Text("82%").font(.headline))
                        Text("Coverage")
                            .font(.caption)
                    }
                }
                .padding(.top)
            }
            .foregroundColor(.white)
        }
    }
    
    private var trendingChart: some View {
        GradientCard(startColor: Color.green.opacity(0.4), endColor: Color.teal.opacity(0.2)) {
            VStack(alignment: .leading) {
                Text("Popularity Trend")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Top 5 Anime Scores")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                TrendChart(data: viewModel.trendChartData, color: .white)
                    .frame(height: 120)
                    .padding(.top, 10)
            }
            .foregroundColor(.white)
        }
    }
    
    private var trendingList: some View {
        GradientCard(startColor: Color.purple.opacity(0.4), endColor: Color.pink.opacity(0.2)) {
            VStack(alignment: .leading) {
                Text("Trending Now")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                ForEach(viewModel.trendingAnime) { anime in
                    HStack {
                        Text(anime.title)
                            .font(.headline)
                            .lineLimit(1)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.2f", anime.score))
                        }
                        .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                    if anime.id != viewModel.trendingAnime.last?.id {
                        Divider().background(Color.white.opacity(0.5))
                    }
                }
            }
            .foregroundColor(.white)
        }
        .gridCellUnsizedAxes([.vertical])
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView()
        }
        .preferredColorScheme(.dark)
    }
}
