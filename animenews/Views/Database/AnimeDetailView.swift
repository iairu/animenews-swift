import SwiftUI

struct AnimeDetailView: View {
    let anime: Anime
    @StateObject private var viewModel = AnimeDetailViewModel()
    @State private var showInspector = false

    var body: some View {
        HStack(spacing: 0) {
            mainContent
            
            #if os(macOS)
            if showInspector {
                Divider()
                InspectorPanel(anime: anime, isShowing: $showInspector)
            }
            #endif
        }
        .navigationTitle(anime.title)
        .toolbar { toolbarContent }
        .onAppear {
            viewModel.setAnime(anime)
        }
        .onChange(of: anime.id) { newId in
            viewModel.setAnime(anime)
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showInspector) {
            NavigationView {
                inspectorSheet
            }
        }
        #endif
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    header
                    
                    Divider()
                    
                    // Quick actions
                    actionButtons
                    
                    if let trailerURL = anime.trailer?.url, let url = URL(string: trailerURL) {
                        linksSection(trailerURL: url)
                    }
                    
                    Divider()
                }
                
                Group {
                    if viewModel.isTracked {
                        trackingSection
                        Divider()
                    }
                    
                    synopsisSection
                    
                    Divider()
                    
                    informationSection
                    
                    Divider()
                    
                    detailsSection
                }
            }
            .padding()
        }
        .frame(minWidth: 400, maxWidth: .infinity)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button(action: { viewModel.toggleTracking() }) {
                Image(systemName: viewModel.isTracked ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isTracked ? .pink : .secondary)
            }
            .help(viewModel.isTracked ? "Remove from library" : "Add to library")
            
            // Share button - use available API
            if #available(macOS 13.0, iOS 16.0, *) {
                if let shareURL = URL(string: anime.url) {
                    ShareLink(item: shareURL) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            } else {
                Button(action: copyLinkToClipboard) {
                    Image(systemName: "square.and.arrow.up")
                }
                .help("Copy link")
            }
            
            #if os(macOS)
            Button(action: { showInspector.toggle() }) {
                Image(systemName: "sidebar.trailing")
            }
            .help("Toggle inspector")
            #else
            Button(action: { showInspector = true }) {
                Image(systemName: "info.circle")
            }
            #endif
            
            if let safariURL = URL(string: anime.url) {
                Link(destination: safariURL) {
                    Image(systemName: "safari")
                }
                .help("Open on MyAnimeList")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(anime.title)
                .font(.title2.weight(.bold))
                
            HStack(spacing: 8) {
                if let type = anime.type {
                    Badge(text: type, color: .blue)
                }
                if let year = anime.year {
                    Badge(text: "\(year)", color: .secondary)
                }
                if let episodes = anime.episodes {
                    Badge(text: "\(episodes) eps", color: .secondary)
                }
            }
                
            Text(anime.status ?? "Unknown Status")
                .font(.subheadline)
                .foregroundColor(.secondary)
                
            if let score = anime.score, score > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.2f", score))
                        .font(.headline.weight(.semibold))
                        
                    if let rank = anime.rank {
                        Text("• #\(rank)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 4)
            }

            genres
        }
    }
    
    private var genres: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(anime.genres) { genre in
                    Text(genre.name)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.accentColor.opacity(0.15))
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            if !viewModel.isTracked {
                Button(action: { viewModel.toggleTracking() }) {
                    Label("Add to Library", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            } else {
                statusMenu
            }
            
            Spacer()
        }
    }
    
    private var statusMenu: some View {
        Menu {
            ForEach(TrackedAnime.Status.allCases, id: \.self) { status in
                Button(action: {
                    viewModel.status = status
                    viewModel.saveChanges()
                }) {
                    HStack {
                        Text(status.rawValue)
                        if viewModel.status == status {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
            Divider()
            
            Button(role: .destructive, action: { viewModel.toggleTracking() }) {
                Label("Remove from Library", systemImage: "trash")
            }
        } label: {
            Label(viewModel.status.rawValue, systemImage: statusIcon)
        }
        .buttonStyle(.bordered)
    }
    
    private var statusIcon: String {
        switch viewModel.status {
        case .watching: return "play.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .onHold: return "pause.circle.fill"
        case .dropped: return "xmark.circle.fill"
        case .planToWatch: return "clock.fill"
        }
    }
    
    private func linksSection(trailerURL: URL) -> some View {
        HStack(spacing: 16) {
            Link(destination: trailerURL) {
                HStack(spacing: 6) {
                    Image(systemName: "play.rectangle.fill")
                        .foregroundColor(.red)
                    Text("Watch Trailer")
                        .font(.subheadline.weight(.medium))
                }
            }
            .buttonStyle(.bordered)
        }
    }

    private var synopsisSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Synopsis")
                .font(.title3.weight(.semibold))
            
            Text(anime.synopsis ?? "No synopsis available.")
                .font(.body)
                .lineSpacing(4)
                .foregroundColor(.secondary)
        }
    }
    
    private var informationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Information")
                .font(.title3.weight(.semibold))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                DetailInfoRow(label: "Type", value: anime.type ?? "N/A")
                DetailInfoRow(label: "Episodes", value: anime.episodes != nil ? "\(anime.episodes!)" : "N/A")
                DetailInfoRow(label: "Status", value: anime.status ?? "N/A")
                DetailInfoRow(label: "Year", value: anime.year != nil ? "\(anime.year!)" : "N/A")
                DetailInfoRow(label: "Rating", value: anime.rating ?? "N/A")
                DetailInfoRow(label: "Source", value: anime.source ?? "N/A")
            }
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.title3.weight(.semibold))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                DetailInfoRow(label: "Rank", value: anime.rank != nil ? "#\(anime.rank!)" : "N/A")
                DetailInfoRow(label: "Popularity", value: anime.popularity != nil ? "#\(anime.popularity!)" : "N/A")
                DetailInfoRow(label: "Members", value: formatNumber(anime.members ?? 0))
                DetailInfoRow(label: "Favorites", value: formatNumber(anime.favorites ?? 0))
            }
            
            if let studios = anime.studios, !studios.isEmpty {
                DetailInfoRow(label: "Studios", value: studios.map(\.name).joined(separator: ", "))
            }
            if let producers = anime.producers, !producers.isEmpty {
                DetailInfoRow(label: "Producers", value: producers.prefix(3).map(\.name).joined(separator: ", "))
            }
        }
    }
    
    private var trackingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Progress")
                .font(.title3.weight(.semibold))
            
            VStack(spacing: 12) {
                // Progress bar
                if let totalEpisodes = anime.episodes, totalEpisodes > 0 {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Episodes")
                            Spacer()
                            Text("\(viewModel.watchedEpisodes) / \(totalEpisodes)")
                                .fontWeight(.medium)
                        }
                        .font(.subheadline)
                        
                        ProgressView(value: Double(viewModel.watchedEpisodes), total: Double(totalEpisodes))
                            .tint(progressColor)
                        
                        HStack {
                            Button(action: { 
                                if viewModel.watchedEpisodes > 0 {
                                    viewModel.watchedEpisodes -= 1
                                    viewModel.saveChanges()
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                            }
                            .disabled(viewModel.watchedEpisodes <= 0)
                            
                            Slider(value: Binding(
                                get: { Double(viewModel.watchedEpisodes) },
                                set: { viewModel.watchedEpisodes = Int($0); viewModel.saveChanges() }
                            ), in: 0...Double(totalEpisodes), step: 1)
                            
                            Button(action: { 
                                if viewModel.watchedEpisodes < totalEpisodes {
                                    viewModel.watchedEpisodes += 1
                                    viewModel.saveChanges()
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                            }
                            .disabled(viewModel.watchedEpisodes >= totalEpisodes)
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                    }
                }
                
                HStack {
                    Text("My Score")
                    Spacer()
                    Picker("Score", selection: $viewModel.score) {
                        Text("–").tag(0)
                        ForEach(1...10, id: \.self) { score in
                            HStack {
                                Image(systemName: "star.fill")
                                Text("\(score)")
                            }.tag(score)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: viewModel.score) { _ in viewModel.saveChanges() }
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var progressColor: Color {
        let progress = Double(viewModel.watchedEpisodes) / Double(anime.episodes ?? 1)
        if progress >= 1.0 { return .green }
        if progress >= 0.5 { return .blue }
        return .accentColor
    }
    
    #if os(iOS)
    private var inspectorSheet: some View {
        List {
            Section("Information") {
                DetailInfoRow(label: "Type", value: anime.type ?? "N/A")
                DetailInfoRow(label: "Status", value: anime.status ?? "N/A")
                if let episodes = anime.episodes {
                    DetailInfoRow(label: "Episodes", value: "\(episodes)")
                }
                if let rating = anime.rating {
                    DetailInfoRow(label: "Rating", value: rating)
                }
            }
            
            Section("Genres") {
                ForEach(anime.genres) { genre in
                    Text(genre.name)
                }
            }
            
            Section("Statistics") {
                if let rank = anime.rank {
                    DetailInfoRow(label: "Rank", value: "#\(rank)")
                }
                if let popularity = anime.popularity {
                    DetailInfoRow(label: "Popularity", value: "#\(popularity)")
                }
                if let members = anime.members {
                    DetailInfoRow(label: "Members", value: formatNumber(members))
                }
            }
        }
        .navigationTitle("Details")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { showInspector = false }
            }
        }
    }
    #endif
    
    private func formatNumber(_ num: Int) -> String {
        if num >= 1_000_000 {
            return String(format: "%.1fM", Double(num) / 1_000_000)
        } else if num >= 1_000 {
            return String(format: "%.1fK", Double(num) / 1_000)
        }
        return "\(num)"
    }
    
    private func copyLinkToClipboard() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(anime.url, forType: .string)
        #else
        UIPasteboard.general.string = anime.url
        #endif
    }
}

// MARK: - Supporting Views

struct Badge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundColor(color == .secondary ? .secondary : .white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(color == .secondary ? 0.2 : 1.0))
            .cornerRadius(6)
    }
}

struct DetailInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .lineLimit(2)
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

// MARK: - Simple Detail Image Loader
// A simple image loader that avoids the crash-prone async patterns

struct SimpleDetailImage: View {
    let urlString: String
    
    #if os(macOS)
    @State private var nsImage: NSImage?
    #else
    @State private var uiImage: UIImage?
    #endif
    
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
            
            #if os(macOS)
            if let nsImage = nsImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                ProgressView()
                    .scaleEffect(0.7)
            } else {
                Image(systemName: "photo")
                    .foregroundColor(.secondary)
            }
            #else
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                ProgressView()
                    .scaleEffect(0.7)
            } else {
                Image(systemName: "photo")
                    .foregroundColor(.secondary)
            }
            #endif
        }
        .clipped()
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        // Load on background queue, update on main
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = try? Data(contentsOf: url) else {
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }
            
            #if os(macOS)
            let loadedImage = NSImage(data: data)
            DispatchQueue.main.async {
                nsImage = loadedImage
                isLoading = false
            }
            #else
            let loadedImage = UIImage(data: data)
            DispatchQueue.main.async {
                uiImage = loadedImage
                isLoading = false
            }
            #endif
        }
    }
}
