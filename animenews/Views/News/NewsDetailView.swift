import SwiftUI

struct NewsDetailView: View {
    let item: NewsItem

    var body: some View {
        if let url = URL(string: item.link) {
            WebView(url: url)
                .navigationTitle(item.source)
                .navigationBarTitleDisplayMode(.inline)
        } else {
            VStack {
                Image(systemName: "xmark.octagon.fill")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                Text("Invalid URL")
                    .font(.title)
                    .padding()
            }
            .navigationTitle("Error")
        }
    }
}

struct NewsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewsDetailView(item: NewsItem.placeholders.first!)
        }
    }
}
