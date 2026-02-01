import SwiftUI

struct NewsListView: View {
    @StateObject private var viewModel = NewsViewModel()

    var body: some View {
        List(viewModel.newsItems) { item in
            NavigationLink(destination: NewsDetailView(item: item)) {
                NewsRow(item: item)
            }
        }
        .navigationTitle("Anime News")
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
                Menu {
                    Button("All Sources", action: {})
                    Button("Anime News Network", action: {})
                    Button("Crunchyroll", action: {})
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                
                Button(action: {
                    Task { await viewModel.fetchNews() }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .task {
            if viewModel.newsItems.isEmpty {
                await viewModel.fetchNews()
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
                            await viewModel.fetchNews()
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.accentColor)
                }
            } else if viewModel.isLoading {
                ProgressView()
            }
        }
    }
}

struct NewsRow: View {
    let item: NewsItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.source)
                    .font(.caption.weight(.bold))
                    .foregroundColor(.accentColor)
                
                Spacer()
                
                Text(item.pubDate, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(item.title)
                .font(.headline)
            
            Text(item.description)
                .font(.subheadline)
                .lineLimit(3)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .contextMenu {
            Button(action: {
                copyToClipboard(item.link)
            }) {
                Label("Copy Link", systemImage: "doc.on.doc")
            }
            
            if let url = URL(string: item.link) {
                Link(destination: url) {
                    Label("Open in Browser", systemImage: "safari")
                }
            }
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

struct NewsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewsListView()
        }
    }
}
