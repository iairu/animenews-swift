import SwiftUI

struct NewsSectionView: View {
    var body: some View {
        // This NavigationView allows NewsListView to push to NewsDetailView on macOS.
        // It becomes the view for the second column, and can push to a third.
        NewsListView()
    }
}
