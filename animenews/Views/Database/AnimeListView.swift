import SwiftUI

struct AnimeListView: View {
    @StateObject private var viewModel = AnimeListViewModel()

    var body: some View {
        VStack {
            SearchBar(text: $viewModel.searchQuery)
            
            if viewModel.isLoading && viewModel.animeList.isEmpty {
                ProgressView("Fetching Anime...")
                    .frame(maxHeight: .infinity)
            } else {
                List(viewModel.animeList) { anime in
                    NavigationLink(destination: AnimeDetailView(anime: anime)) {
                        AnimeRow(anime: anime)
                    }
                }
            }
        }
        .navigationTitle("Anime Database")
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

struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false

    var body: some View {
        HStack {
            TextField("Search for anime...", text: $text)
                .padding(8)
                .padding(.horizontal, 25)
                .background(Color(.systemGray))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isEditing && !text.isEmpty {
                            Button(action: { self.text = "" }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .onTapGesture {
                    self.isEditing = true
                }
        }
        .padding(.horizontal)
    }
}

struct AnimeListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnimeListView()
        }
    }
}
