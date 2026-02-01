import SwiftUI

/// View showing anime schedule by day of the week
struct ScheduleView: View {
    @StateObject private var viewModel = ScheduleViewModel()
    @State private var selectedDay: DayOfWeek = currentDayOfWeek
    
    var body: some View {
        VStack(spacing: 0) {
            // Day picker dropdown
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
            .padding()
            
            Divider()
            
            // Schedule list
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading schedule...")
                Spacer()
            } else if viewModel.scheduledAnime.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No anime scheduled for \(selectedDay.rawValue)")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                List(viewModel.scheduledAnime) { anime in
                    ScheduleRow(anime: anime)
                }
            }
        }
        .navigationTitle("Schedule")
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
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    Task { await viewModel.fetchSchedule(for: selectedDay) }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .task {
            await viewModel.fetchSchedule(for: selectedDay)
        }
    }
    
    private static var currentDayOfWeek: DayOfWeek {
        let weekday = Calendar.current.component(.weekday, from: Date())
        // Calendar weekday: Sunday = 1, Monday = 2, etc.
        return DayOfWeek.allCases[(weekday - 1) % 7]
    }
}

struct DayButton: View {
    let day: DayOfWeek
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(day.shortName)
                    .font(.caption.weight(.bold))
                Text(day.rawValue)
                    .font(.caption2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct ScheduleRow: View {
    let anime: Anime
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImageView(url: URL(string: anime.images.jpg.imageUrl))
                .frame(width: 50, height: 70)
                .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(anime.title)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    if let episodes = anime.episodes {
                        Text("\(episodes) eps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let score = anime.score, score > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", score))
                        }
                        .font(.caption)
                    }
                }
            }
            
            Spacer()
            
            if anime.status == "Currently Airing" {
                Text("AIRING")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button(action: {
                toggleLibraryStatus(for: anime)
            }) {
                Label(
                    StorageService.shared.getTrackedAnime(id: anime.id) != nil ? "Remove from Library" : "Add to Library",
                    systemImage: StorageService.shared.getTrackedAnime(id: anime.id) != nil ? "trash" : "plus.circle"
                )
            }
            
            Button(action: {
                copyToClipboard(anime.url)
            }) {
                Label("Copy Link", systemImage: "doc.on.doc")
            }
        }
    }
    
    private func toggleLibraryStatus(for anime: Anime) {
        if StorageService.shared.getTrackedAnime(id: anime.id) != nil {
            StorageService.shared.delete(id: anime.id)
        } else {
            let tracked = TrackedAnime(
                id: anime.id,
                status: .planToWatch,
                watchedEpisodes: 0,
                score: 0,
                addedDate: Date()
            )
            StorageService.shared.add(anime: tracked)
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

// MARK: - Day of Week Enum

enum DayOfWeek: String, CaseIterable {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    
    var shortName: String {
        String(rawValue.prefix(3))
    }
    
    var apiValue: String {
        rawValue.lowercased()
    }
    
    static var today: DayOfWeek {
        let weekday = Calendar.current.component(.weekday, from: Date())
        // Calendar weekday: Sunday = 1, Monday = 2, etc.
        return DayOfWeek.allCases[(weekday - 1) % 7]
    }
}

// MARK: - ViewModel

@MainActor
class ScheduleViewModel: ObservableObject {
    @Published var scheduledAnime: [Anime] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let jikanService = JikanService()
    
    func fetchSchedule(for day: DayOfWeek) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let anime = try await jikanService.fetchSchedule(day: day.apiValue)
            // Deduplicate by malId
            var seen = Set<Int>()
            self.scheduledAnime = anime.filter { seen.insert($0.malId).inserted }
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error fetching schedule: \(error)")
        }
        
        isLoading = false
    }
}

// MARK: - Previews

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScheduleView()
        }
    }
}
