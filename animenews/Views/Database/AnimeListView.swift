import SwiftUI

struct AnimeListView: View {
    @StateObject private var viewModel = AnimeListViewModel()

    private var listView: some View {
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
                    // This action toggles the sidebar in a multi-column layout.
                    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                }) {
                    Image(systemName: "sidebar.left")
                }
            }
#endif
        }
        .searchable(text: $viewModel.searchQuery, prompt: "Search for anime...")
        .overlay {
            if viewModel.isLoading && viewModel.animeList.isEmpty {
                ProgressView("Fetching Anime...")
            }
        }
    }

    var body: some View {
        #if os(macOS)
        NavigationView {
            listView
            Text("Select an anime to see details.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.secondary)
        }
        #else
        listView
        #endif
    }
}

struct AnimeRow: View {
    let anime: Anime
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImageView(url: URL(string: anime.imageUrl))
                .frame(width: 60, height: 90)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 6) {
                Text(anime.title)
                    .font(.headline)
                    .lineLimit(2)
                Text("\(anime.type) • \(String(anime.year))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.2f", anime.score))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
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
