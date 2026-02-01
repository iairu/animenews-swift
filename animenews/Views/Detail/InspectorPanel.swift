import SwiftUI

/// Collapsible inspector panel for anime metadata
struct InspectorPanel: View {
    let anime: Anime
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("INFORMATION")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Basic Info
                    infoSection
                    
                    Divider()
                    
                    // Genres
                    if !anime.genres.isEmpty {
                        genresSection
                        Divider()
                    }
                    
                    // Studios
                    if let studios = anime.studios, !studios.isEmpty {
                        studiosSection
                        Divider()
                    }
                    
                    // Producers
                    if let producers = anime.producers, !producers.isEmpty {
                        producersSection
                        Divider()
                    }
                    
                    // Statistics
                    statisticsSection
                }
                .padding()
            }
        }
        .frame(width: 280)
        #if os(macOS)
        .background(Color(nsColor: .controlBackgroundColor))
        #else
        .background(Color(uiColor: .secondarySystemBackground))
        #endif
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            InspectorInfoRow(label: "Type", value: anime.type ?? "Unknown")
            InspectorInfoRow(label: "Status", value: anime.status ?? "Unknown")
            
            if let episodes = anime.episodes {
                InspectorInfoRow(label: "Episodes", value: "\(episodes)")
            }
            
            if let year = anime.year {
                InspectorInfoRow(label: "Year", value: "\(year)")
            }
            
            if let rating = anime.rating {
                InspectorInfoRow(label: "Rating", value: rating)
            }
            
            if let source = anime.source {
                InspectorInfoRow(label: "Source", value: source)
            }
            
            if let broadcast = anime.broadcast?.string {
                InspectorInfoRow(label: "Broadcast", value: broadcast)
            }
        }
    }
    
    private var genresSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GENRES")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
            
            // Use LazyVGrid instead of custom FlowLayout for macOS 12 compatibility
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 6)], alignment: .leading, spacing: 6) {
                ForEach(anime.genres) { genre in
                    Text(genre.name)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(6)
                }
            }
        }
    }
    
    private var studiosSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("STUDIOS")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
            
            if let studios = anime.studios {
                ForEach(studios) { studio in
                    Text(studio.name)
                        .font(.subheadline)
                }
            }
        }
    }
    
    private var producersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PRODUCERS")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
            
            if let producers = anime.producers {
                ForEach(producers.prefix(5)) { producer in
                    Text(producer.name)
                        .font(.subheadline)
                }
            }
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("STATISTICS")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
            
            if let score = anime.score {
                HStack {
                    Text("Score")
                        .foregroundColor(.secondary)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.2f", score))
                            .fontWeight(.semibold)
                    }
                }
                .font(.subheadline)
            }
            
            if let rank = anime.rank {
                InspectorInfoRow(label: "Rank", value: "#\(rank)")
            }
            
            if let popularity = anime.popularity {
                InspectorInfoRow(label: "Popularity", value: "#\(popularity)")
            }
            
            if let members = anime.members {
                InspectorInfoRow(label: "Members", value: formatNumber(members))
            }
            
            if let favorites = anime.favorites {
                InspectorInfoRow(label: "Favorites", value: formatNumber(favorites))
            }
        }
    }
    
    private func formatNumber(_ num: Int) -> String {
        if num >= 1_000_000 {
            return String(format: "%.1fM", Double(num) / 1_000_000)
        } else if num >= 1_000 {
            return String(format: "%.1fK", Double(num) / 1_000)
        }
        return "\(num)"
    }
}

struct InspectorInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

struct InspectorPanel_Previews: PreviewProvider {
    static var previews: some View {
        InspectorPanel(anime: .placeholder, isShowing: .constant(true))
    }
}
