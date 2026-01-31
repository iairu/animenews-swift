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
        .onAppear {
            // This is useful if the data needs to be refreshed when the view appears.
            // The ViewModel already fetches on init, so this is for subsequent appearances.
            if viewModel.newsItems.isEmpty {
                viewModel.fetchNews()
            }
        }
        .overlay {
            if viewModel.isLoading {
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
                .foregroundColor(.pink)
            
            Text(item.title)
                .font(.headline)
            
            Text(item.description)
                .font(.subheadline)
                .lineLimit(3)
                .foregroundColor(.secondary)
            
            Text(item.pubDate, style: .relative)
                .font(.caption)
                .foregroundColor(.gray)
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
