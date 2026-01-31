import SwiftUI

struct NewsListView: View {
    @StateObject private var viewModel = NewsViewModel()

    private var listView: some View {
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
                    // This action toggles the sidebar in a multi-column layout.
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
                    // Placeholder for share action
                }) {
                    Image(systemName: "square.and.arrow.up")
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
                        .foregroundColor(Theme.mutedForeground)
                    Text(errorMessage)
                        .foregroundColor(Theme.mutedForeground)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry") {
                        Task {
                            await viewModel.fetchNews()
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(Theme.accent)
                }
            } else if viewModel.isLoading {
                ProgressView()
            }
        }
    }

    var body: some View {
        #if os(macOS)
        NavigationView {
            listView
            Text("Select an article to read.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.secondary)
        }
        #else
        listView
        #endif
    }
}

struct NewsRow: View {
    let item: NewsItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.source)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Theme.accent)
            
            Text(item.title)
                .font(.headline)
            
            Text(item.description)
                .font(.subheadline)
                .lineLimit(3)
                .foregroundColor(.secondary)
            
            Text(item.pubDate, style: .relative)
                .font(.caption)
                .foregroundColor(Theme.muted)
                .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

struct NewsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewsListView()
        }
    }
}
