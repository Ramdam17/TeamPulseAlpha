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
                        y: .value("HR", hrvValue)
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
        .frame(height: .infinity)  // Set the height of the chart
    }
}

struct SessionSensorDataDetailLineHRV_Previews: PreviewProvider {
    static var previews: some View {
        let previewData: [[String: Any]] = [
            ["timestamp": Date(), "hrvValue": 0.13],
            ["timestamp": Date().addingTimeInterval(60), "hrvValue": 0.15],
            ["timestamp": Date().addingTimeInterval(120), "hrvValue": 0.24],
            ["timestamp": Date().addingTimeInterval(180), "hrvValue": 0.30]
        ]

        return SessionSensorDataDetailLineHR(hrData: previewData, color: .blue)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
