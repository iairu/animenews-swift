import SwiftUI

struct MyAnimeListView: View {
    @StateObject private var viewModel = MyAnimeListViewModel()
    @State private var searchQuery = ""
    @State private var sortOption: SortOption = .title
    @State private var showOnlyWithProgress = false

    var body: some View {
        VStack {
            VStack {
                Picker("Status", selection: $viewModel.statusFilter) {
                    Text("All").tag(nil as TrackedAnime.Status?)
                    ForEach(TrackedAnime.Status.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(Optional(status))
                    }
                }
                .pickerStyle(.segmented)

                HStack {
                    Picker("Sort by", selection: $sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)

                    Spacer()

                    Toggle("Has Progress", isOn: $showOnlyWithProgress)
                        .toggleStyle(.button)
                }
            }
            .padding()

            if viewModel.isLoading {
                ProgressView()
                Spacer()
            } else if viewModel.trackedAnime.isEmpty {
                Text("No tracked anime found.")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                List(sortedAnime) { anime in
                    NavigationLink(destination: AnimeDetailView(anime: anime)) {
                        MyAnimeRow(anime: anime)
                    }
                }
            }
        }
        .navigationTitle("My Anime")
        .searchable(text: $searchQuery, prompt: "Search My Anime")
        .task {
            await viewModel.filterAndFetchAnime()
        }
    }

    private var filteredAnime: [Anime] {
        let initialList: [Anime]
        if searchQuery.isEmpty {
            initialList = viewModel.trackedAnime
        } else {
            initialList = viewModel.trackedAnime.filter {
                $0.title.lowercased().contains(searchQuery.lowercased())
            }
        }

        if showOnlyWithProgress {
            return initialList.filter {
                let progress = StorageService.shared.getTrackedAnime(id: $0.id)?.watchedEpisodes ?? 0
                return progress > 0
            }
        } else {
            return initialList
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

enum SortOption: String, CaseIterable, Identifiable {
    case title = "Title"
    case status = "Status"
    case progress = "Progress"
    var id: Self { self }
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
        .contentShape(Rectangle())
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
