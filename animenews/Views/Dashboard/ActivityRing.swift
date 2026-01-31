import SwiftUI

struct ActivityRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.3), lineWidth: lineWidth)

            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // Start from the top
                .animation(.easeOut(duration: 1.0), value: progress)
        }
    }
}

struct ActivityRing_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            ActivityRing(progress: 0.75, color: .teal, lineWidth: 20)
                .frame(width: 150, height: 150)
                .overlay(Text("75%").font(.title).bold())

            ActivityRing(progress: 0.3, color: .pink, lineWidth: 15)
                .frame(width: 100, height: 100)
                .overlay(Text("3/10").font(.headline))
        }
        .padding()
    }
}
