import SwiftUI

struct GradientCard<Content: View>: View {
    var colors: [Color] = [Color.blue, Color.purple]
    var startPoint: UnitPoint = .topLeading
    var endPoint: UnitPoint = .bottomTrailing
    let content: Content

    init(colors: [Color] = [Color.blue, Color.purple], 
         startPoint: UnitPoint = .topLeading, 
         endPoint: UnitPoint = .bottomTrailing, 
         @ViewBuilder content: () -> Content) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.content = content()
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: colors), startPoint: startPoint, endPoint: endPoint)
                .mask(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: colors.first?.opacity(0.3) ?? .clear, radius: 10, x: 0, y: 5)
            
            content
                .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct GradientCard_Previews: PreviewProvider {
    static var previews: some View {
        GradientCard {
            Text("Gradient Card")
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(width: 300, height: 200)
        .padding()
    }
}
