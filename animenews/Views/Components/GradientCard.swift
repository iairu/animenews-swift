import SwiftUI

struct GradientCard<Content: View>: View {
    let content: Content
    let startColor: Color
    let endColor: Color

    init(startColor: Color, endColor: Color, @ViewBuilder content: () -> Content) {
        self.startColor = startColor
        self.endColor = endColor
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [startColor, endColor]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(15)
    }
}

struct GradientCard_Previews: PreviewProvider {
    static var previews: some View {
        GradientCard(startColor: .blue.opacity(0.4), endColor: .purple.opacity(0.2)) {
            VStack {
                Text("Example Card")
                    .font(.title)
                Text("This is some content inside the gradient card.")
            }
            .foregroundColor(.white)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
