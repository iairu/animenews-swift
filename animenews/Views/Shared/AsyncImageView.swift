import SwiftUI

/// A reusable view for loading and displaying an image from a URL asynchronously.
/// It handles loading, success, and failure states.
struct AsyncImageView: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    ProgressView()
                }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure(let error):
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                    
                    VStack(spacing: 8) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 40))
                        Text("Image load failed")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                .onAppear {
                    print("ERROR: Image loading failed for URL \(url?.absoluteString ?? "nil"): \(error.localizedDescription)")
                }

            @unknown default:
                EmptyView()
            }
        }
    }
}

struct AsyncImageView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncImageView(url: URL(string: Anime.placeholder.imageUrl))
            .frame(width: 200, height: 300)
            .cornerRadius(10)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
