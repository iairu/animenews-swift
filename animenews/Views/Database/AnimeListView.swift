import SwiftUI

struct AnimeListView: View {
    @StateObject private var viewModel = AnimeListViewModel()
    @State private var searchQuery = ""

    var body: some View {
        List(viewModel.animeList) { anime in
            NavigationLink(destination: AnimeDetailView(anime: anime)) {
                AnimeRow(anime: anime)
            }
        }
        .navigationTitle("Anime Database")
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
            
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    Task { await viewModel.fetchTopAnime() }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .searchable(text: $searchQuery, prompt: "Search for anime...")
        .onChange(of: searchQuery) { newValue in
            Task {
                // Debounce the search
                try? await Task.sleep(nanoseconds: 500_000_000)
                await viewModel.searchAnime(query: newValue)
            }
        }
        .overlay {
            if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text(errorMessage)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry") {
                        Task {
                            if searchQuery.isEmpty {
                                await viewModel.fetchTopAnime()
                            } else {
                                await viewModel.searchAnime(query: searchQuery)
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.accentColor)
                }
            } else if viewModel.isLoading && viewModel.animeList.isEmpty {
                ProgressView("Fetching Anime...")
            } else if !viewModel.isLoading && viewModel.animeList.isEmpty && !searchQuery.isEmpty {
                Text("No results for \"\(searchQuery)\"")
                    .foregroundColor(.secondary)
            }
        }
        .task {
            // Fetch initial data only if the list is empty
            if viewModel.animeList.isEmpty {
                await viewModel.fetchTopAnime()
            }
        }
    }
}

struct AnimeRow: View {
    let anime: Anime
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImageView(url: URL(string: anime.images.jpg.largeImageUrl))
                .frame(width: 60, height: 90)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 6) {
                Text(anime.title)
                    .font(.headline)
                    .lineLimit(2)
                Text("\(anime.type ?? "N/A") • \(anime.year != nil ? String(anime.year!) : "N/A")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let score = anime.score, score > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.2f", score))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}

struct AnimeListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnimeListView()
        }
    }
}
