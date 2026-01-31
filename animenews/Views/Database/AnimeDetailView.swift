import SwiftUI

struct AnimeDetailView: View {
    let anime: Anime

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                
                Divider()
                
                synopsisSection
                
                Divider()
                
                informationSection
            }
            .padding()
        }
        .navigationTitle(anime.title)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    // Placeholder for favorite action
                }) {
                    Image(systemName: "heart")
                }
                
                Button(action: {
                    // Placeholder for share action
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImageView(url: URL(string: anime.imageUrl))
                .frame(width: 125, height: 190)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(anime.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(anime.type) • \(String(anime.year))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(anime.status)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.2f", anime.score))
                        .font(.headline)
                        .fontWeight(.medium)
                }
                .padding(.top, 4)

                genres
            }
        }
    }
    
    private var genres: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(anime.genres, id: \.self) { genre in
                    Text(genre)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.pink.opacity(0.2))
                        .cornerRadius(12)
                }
            }
        }
    }

    private var synopsisSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Synopsis")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(anime.synopsis)
                .font(.body)
                .lineSpacing(4)
        }
    }
    
    private var informationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Information")
                .font(.title3)
                .fontWeight(.semibold)

            InfoRow(label: "Type", value: anime.type)
            InfoRow(label: "Episodes", value: anime.episodes != nil ? "\(anime.episodes!)" : "N/A")
            InfoRow(label: "Status", value: anime.status)
            InfoRow(label: "Year", value: String(anime.year))
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.medium)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}


struct AnimeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnimeDetailView(anime: Anime.placeholder)
        }
        .preferredColorScheme(.dark)
    }
}
