import SwiftUI

struct NewsListView: View {
    @StateObject private var viewModel = NewsViewModel()

    var body: some View {
        List(viewModel.newsItems) { item in
            NewsRow(item: item)
        }
        .navigationTitle("Anime News")
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
