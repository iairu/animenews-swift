import SwiftUI

struct TrendChart: View {
    let data: [Double]
    let color: Color

    private var normalizedData: [CGFloat] {
        ChartDataCalculator.normalize(data)
    }

    var body: some View {
        GeometryReader { geometry in
            let path = Path { path in
                guard !normalizedData.isEmpty else { return }

                // If there's only one point, we can't draw a line, but we can fill the background.
                if normalizedData.count == 1 {
                    path.move(to: CGPoint(x: 0, y: geometry.size.height * (1 - normalizedData[0])))
                } else {
                    let stepX = geometry.size.width / CGFloat(normalizedData.count - 1)
                    
                    path.move(to: CGPoint(x: 0, y: geometry.size.height * (1 - normalizedData[0])))

                    for i in 1..<normalizedData.count {
                        let x = CGFloat(i) * stepX
                        let y = geometry.size.height * (1 - normalizedData[i])
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            
            // Fill the area under the line with a gradient
            path
                .getAreaPath(in: geometry.size)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.4), color.opacity(0.0)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Stroke the line itself
            path.stroke(color, lineWidth: 2.5)
        }
        .animation(.easeOut(duration: 1.0), value: data)
    }
}

// Helper to create a closed path for filling the background area
private extension Path {
    func getAreaPath(in size: CGSize) -> Path {
        var areaPath = self
        guard let lastPoint = self.cgPath.currentPoint else { return areaPath }
        
        areaPath.addLine(to: CGPoint(x: lastPoint.x, y: size.height))
        areaPath.addLine(to: CGPoint(x: 0, y: size.height))
        areaPath.closeSubpath()
        
        return areaPath
    }
}

struct TrendChart_Previews: PreviewProvider {
    static let sampleData: [Double] = [8.1, 8.2, 8.0, 8.3, 8.5, 8.4, 8.7, 8.8, 8.6, 9.0]
    static let flatData: [Double] = [5.0, 5.0, 5.0, 5.0, 5.0]
    static let singleData: [Double] = [7.5]
    static let emptyData: [Double] = []

    static var previews: some View {
        VStack(spacing: 40) {
            Text("Trending Up").font(.headline)
            TrendChart(data: sampleData, color: .green)
                .frame(height: 100)
            
            Text("Flat Trend").font(.headline)
            TrendChart(data: flatData, color: .orange)
                .frame(height: 100)
                
            Text("Single Data Point").font(.headline)
            TrendChart(data: singleData, color: .blue)
                .frame(height: 100)

            Text("Empty Data").font(.headline)
            TrendChart(data: emptyData, color: .red)
                .frame(height: 100)
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .foregroundColor(.white)
    }
}
