//
//  SessionSensorDataDetailBoxplot.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import SwiftUI
import Charts

/// SwiftUI component to display a boxplot of heart rate (HR) data.
/// The chart includes a customizable title above it and a text line at the bottom showing key statistics.
struct SessionSensorDataDetailBoxplot: View {
    var hrData: [[String: Any]]  // HR data as an array of dictionaries
    let color: Color  // Color for the boxplot components
    let title: String  // Title to display above the chart
    
    var body: some View {
        let stats = computeStatistics(for: hrData)  // Calculate statistics for the HR data
        
        let minValue = stats.first?.min ?? 0
        let maxValue = stats.first?.max ?? 0
        let medianValue = stats.first?.median ?? 0
        let meanValue = stats.first?.mean ?? 0

        return VStack {
            Text(title)  // Chart title
                .font(.headline)
                .padding(.bottom, 10)  // Spacing between the title and the chart

            Chart {
                ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                    let min = stat.min
                    let max = stat.max
                    let median = stat.median
                    let mean = stat.mean
                    
                    let xPositionStart = Double(index) * 33 + 10
                    let xPositionEnd = Double(index) * 33 + 30
                    
                    // Draw the lower part of the box (min to median)
                    RectangleMark(
                        xStart: .value("Sensor", xPositionStart),
                        xEnd: .value("Sensor", xPositionEnd),
                        yStart: .value("Min", min),
                        yEnd: .value("Median", median)
                    )
                    .foregroundStyle(color.opacity(0.3))  // Lighter color for the lower box
                    .cornerRadius(2)
                    
                    // Draw the upper part of the box (median to max)
                    RectangleMark(
                        xStart: .value("Sensor", xPositionStart),
                        xEnd: .value("Sensor", xPositionEnd),
                        yStart: .value("Median", median),
                        yEnd: .value("Max", max)
                    )
                    .foregroundStyle(color.opacity(0.6))  // Darker color for the upper box
                    .cornerRadius(2)
                    
                    // Draw the median as a thick horizontal line
                    RuleMark(
                        xStart: .value("Sensor", xPositionStart - 5),
                        xEnd: .value("Sensor", xPositionEnd + 5),
                        y: .value("Median", median)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 5))  // Thick line for the median
                    .foregroundStyle(color)
                    
                    // Draw the mean as a point in the middle
                    PointMark(
                        x: .value("Sensor", (xPositionStart + xPositionEnd) / 2),
                        y: .value("Mean", mean)
                    )
                    .symbolSize(100)  // Increase the size for visibility
                    .foregroundStyle(color)
                }
            }
            .chartYScale(domain: 0...220)
            .padding()

            // Display the summary statistics below the chart
            Text("Min: \(minValue), Max: \(maxValue), Median: \(medianValue), Mean: \(meanValue)")
                .font(.footnote)
                .padding(.top, 10)  // Spacing between the chart and the statistics text
        }
        .padding()
    }
}

struct SessionSensorDataDetailBoxplot_Previews: PreviewProvider {
    static var previews: some View {
        var previewData: [[String: Any]] = []

        // Generate preview data for testing
        for i in 0...60 {
            previewData.append([
                "timestamp": Date().addingTimeInterval(Double(i)),
                "hrValue": Double.random(in: 40..<200),
            ])
        }

        // Return a preview of the view with sample data
        return SessionSensorDataDetailBoxplot(hrData: previewData, color: .blue, title: "Heart Rate Boxplot")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
