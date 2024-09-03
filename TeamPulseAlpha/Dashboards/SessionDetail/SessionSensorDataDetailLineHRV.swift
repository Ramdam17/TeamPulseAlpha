//
//  SessionSensorDataDetailLineHRV.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import SwiftUI
import Charts

/// SwiftUI component to display a line chart of heart rate variability (HRV) data.
/// The chart includes a customizable title above it and no legend.
struct SessionSensorDataDetailLineHRV: View {
    var hrvData: [[String: Any]]  // HRV data as an array of dictionaries
    let color: Color  // Color for the line in the chart
    let title: String  // Title to display above the chart

    var body: some View {
        VStack {
            Text(title)  // Chart title
                .font(.headline)
                .padding(.bottom, 10)  // Spacing between the title and the chart

            Chart {
                ForEach(Array(hrvData.enumerated()), id: \.offset) { index, dataPoint in
                    if let hrvData = extractHRVData(from: dataPoint) {
                        LineMark(
                            x: .value("Time", hrvData.timestamp),
                            y: .value("HRV", hrvData.hrvValue)
                        )
                        .interpolationMethod(.catmullRom)  // Smooth line interpolation
                        .lineStyle(StrokeStyle(lineWidth: 2))  // Customize line width
                        .foregroundStyle(color)  // Apply the provided color
                    }
                }
            }
            .chartXAxisLabel("Time")  // X-axis label
            .chartYAxisLabel("Heart Rate Variability (HRV)")  // Y-axis label
            .chartLegend(.hidden)  // Hide legend as it's unnecessary
            .animation(.easeInOut(duration: 0.1), value: color)  // Animate color changes
            .chartYScale(domain: 0...0.5)  // Y-axis range for HRV values
        }
        .padding()
    }
}

struct SessionSensorDataDetailLineHRV_Previews: PreviewProvider {
    static var previews: some View {
        var previewData: [[String: Any]] = []

        for i in 0...60 {
            previewData.append([
                "timestamp": Date().addingTimeInterval(Double(i)),
                "hrvValue": Double.random(in: 0..<0.5),
            ])
        }

        return SessionSensorDataDetailLineHRV(hrvData: previewData, color: .blue, title: "Heart Rate Variability Over Time")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
