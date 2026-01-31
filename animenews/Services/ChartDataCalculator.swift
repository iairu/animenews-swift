import Foundation
import CoreGraphics

struct ChartDataCalculator {
    /// Normalizes an array of data points (e.g., scores, popularity) to a range of 0.0 to 1.0,
    /// suitable for drawing in a chart view where 1.0 represents the maximum height.
    ///
    /// - Parameter data: An array of Double values.
    /// - Returns: An array of CGFloat values normalized between 0.0 and 1.0. Returns an empty array if input is empty.
    static func normalize(_ data: [Double]) -> [CGFloat] {
        guard let maxVal = data.max(), maxVal > 0 else {
            // If all values are 0 or the array is empty, return an array of zeros.
            return data.map { _ in 0.0 }
        }
        
        // To avoid having the minimum value be 0 and sit on the x-axis,
        // find the min value and adjust the normalization range.
        let minVal = data.min() ?? 0.0
        let range = maxVal - minVal
        
        if range == 0 {
            // All elements are the same, so we can represent them as being in the middle of the chart.
            return data.map { _ in 0.5 }
        }

        return data.map { CGFloat(($0 - minVal) / range) }
    }
}
