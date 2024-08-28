//
//  SessionSensorDataDetailLineHRV.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import SwiftUI
import Charts

struct SessionSensorDataDetailLineHRV: View {
    var hrvData: [[String: Any]]
    let color: Color

    var body: some View {
        Chart {
            ForEach(Array(hrvData.enumerated()), id: \.offset) { index, dataPoint in
                if let timestamp = dataPoint["timestamp"] as? Date,
                   let hrvValue = dataPoint["hrvValue"] as? Double {
                    LineMark(
                        x: .value("Time", timestamp),
                        y: .value("HRV", hrvValue)
                    )
                    .interpolationMethod(.catmullRom)  // Apply Catmull-Rom interpolation for smoother lines
                    .lineStyle(StrokeStyle(lineWidth: 2))  // Set the line width
                    .foregroundStyle(color)  // Apply the color to the line
                }
            }
        }
        .chartXAxisLabel("Time")
        .chartYAxisLabel("Heart Rate Variability (HRV)")
        .chartLegend(.hidden)
        .animation(.easeInOut(duration: 0.1), value: color)  // Animate the chart when data changes
        .chartYScale(domain: 0...0.5)  // Set the Y-axis range for heart rate values
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

        return SessionSensorDataDetailLineHRV(hrvData: previewData, color: .blue)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
