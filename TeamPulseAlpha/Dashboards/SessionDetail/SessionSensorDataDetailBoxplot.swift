//
//  SessionSensorDataDetailBoxplot.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import SwiftUI
import Charts

struct SessionSensorDataDetailBoxplot: View {
    var hrData: [[String: Any]]
    let color: Color
    
    var body: some View {
        let stats = computeStatistics(for: hrData)
        
        return Chart {
            ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                let min = stat.min
                let max = stat.max
                let median = stat.median
                let mean = stat.mean
                
                let xPositionStart = Double(index) * 33 + 10
                let xPositionEnd = Double(index) * 33 + 30
                
                // Draw the interquartile range as a rectangle (from min to median)
                RectangleMark(
                    xStart: .value("Sensor", xPositionStart),
                    xEnd: .value("Sensor", xPositionEnd),
                    yStart: .value("Min", min),
                    yEnd: .value("Median", median)
                )
                .foregroundStyle(color.opacity(0.3))
                .cornerRadius(2)
                
                // Draw the interquartile range as a rectangle (from median to max)
                RectangleMark(
                    xStart: .value("Sensor", xPositionStart),
                    xEnd: .value("Sensor", xPositionEnd),
                    yStart: .value("Median", median),
                    yEnd: .value("Max", max)
                )
                .foregroundStyle(color.opacity(0.6))
                .cornerRadius(2)
                
                // Draw the median as a rule (line)
                RuleMark(
                    xStart: .value("Sensor", xPositionStart - 5),
                    xEnd: .value("Sensor", xPositionEnd + 5),
                    y: .value("Median", median)
                )
                .lineStyle(StrokeStyle(lineWidth: 5))
                .foregroundStyle(color)
                
                // Draw the mean as a point
                PointMark(
                    x: .value("Sensor", (xPositionStart + xPositionEnd) / 2),
                    y: .value("Mean", mean)
                )
                .symbolSize(100)
                .foregroundStyle(color)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    /// Function to calculate statistics (min, max, median, mean) from HR data
    private func computeStatistics(for hrData: [[String: Any]]) -> [(min: Double, max: Double, median: Double, mean: Double)] {
        var stats: [(min: Double, max: Double, median: Double, mean: Double)] = []
        
        // Extract HR values for each timestamp
        let hrValues = hrData.compactMap { $0["hrValue"] as? Double }
        
        guard !hrValues.isEmpty else { return stats }
        
        let sortedValues = hrValues.sorted()
        let min = sortedValues.first ?? 0.0
        let max = sortedValues.last ?? 0.0
        let median = sortedValues[sortedValues.count / 2]
        let mean = sortedValues.reduce(0, +) / Double(sortedValues.count)
        
        stats.append((min: min, max: max, median: median, mean: mean))
        
        return stats
    }
}

struct SessionSensorDataDetailBoxplot_Previews: PreviewProvider {
    static var previews: some View {
        let previewData: [[String: Any]] = [
            ["timestamp": Date(), "hrValue": 72.0],
            ["timestamp": Date(), "hrValue": 75.0],
            ["timestamp": Date(), "hrValue": 78.0],
            ["timestamp": Date(), "hrValue": 80.0],
            ["timestamp": Date(), "hrValue": 65.0]
        ]
        
        return SessionSensorDataDetailBoxplot(hrData: previewData, color: .blue)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
