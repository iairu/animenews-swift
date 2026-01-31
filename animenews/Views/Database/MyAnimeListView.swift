import SwiftUI

struct MyAnimeListView: View {
    @StateObject private var viewModel = MyAnimeListViewModel()

    var body: some View {
        VStack {
            Picker("Status", selection: $viewModel.statusFilter) {
                Text("All").tag(nil as TrackedAnime.Status?)
                ForEach(TrackedAnime.Status.allCases, id: \.self) { status in
                    Text(status.rawValue).tag(status as TrackedAnime.Status?)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            if viewModel.isLoading {
                ProgressView()
                Spacer()
            } else if viewModel.trackedAnime.isEmpty {
                Text("No tracked anime found.")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                List(viewModel.trackedAnime) { anime in
                    NavigationLink(destination: AnimeDetailView(anime: anime)) {
                        MyAnimeRow(anime: anime)
                    }
                }
            }
        }
        .navigationTitle("My Anime")
        .task {
            await viewModel.filterAndFetchAnime()
        }
    }
}

struct MyAnimeRow: View {
    let anime: Anime
    
    private var trackedInfo: TrackedAnime? {
        StorageService.shared.getTrackedAnime(id: anime.id)
    }

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
                
                if let status = trackedInfo?.status {
                    Text(status.rawValue)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(statusColor(for: status))
                }

                if let tracked = trackedInfo, let totalEpisodes = anime.episodes, totalEpisodes > 0, tracked.status == .watching {
                    VStack(alignment: .leading, spacing: 4) {
                        ProgressView(value: Double(tracked.watchedEpisodes), total: Double(totalEpisodes))
                            .tint(Theme.accent)
                        Text("\(tracked.watchedEpisodes) / \(totalEpisodes) episodes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if let score = trackedInfo?.score, score > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Theme.accent)
                            .font(.caption)
                        Text("My Score: \(score)/10")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text(anime.type ?? "N/A")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
    
    private func statusColor(for status: TrackedAnime.Status) -> Color {
        switch status {
        case .watching: return .green
        case .completed: return Theme.accent
        case .onHold: return .orange
        case .dropped: return .red
        case .planToWatch: return Theme.mutedForeground
        }
    }
}

struct MyAnimeListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MyAnimeListView()
        }
        .preferredColorScheme(.dark)
    }
}
