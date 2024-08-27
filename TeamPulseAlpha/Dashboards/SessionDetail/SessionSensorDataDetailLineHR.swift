//
//  SessionSensorDataDetailLineHR.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import Charts
import SwiftUI

struct SessionSensorDataDetailLineHR: View {
    var hrData: [[String: Any]]
    let color: Color

    var body: some View {
        Chart {
            ForEach(Array(hrData.enumerated()), id: \.offset) {
                index, dataPoint in
                if let timestamp = dataPoint["timestamp"] as? Date,
                    let hrValue = dataPoint["hrValue"] as? Double
                {
                    LineMark(
                        x: .value("Time", timestamp),
                        y: .value("HR", hrValue)
                    )
                    .interpolationMethod(.catmullRom)  // Apply Catmull-Rom interpolation for smoother lines
                    .lineStyle(StrokeStyle(lineWidth: 2))  // Set the line width
                    .foregroundStyle(color)  // Apply the color to the line
                }
            }
        }
        .chartXAxisLabel("Time")
        .chartYAxisLabel("Heart Rate (HR)")
        .chartLegend(.hidden)
        .animation(.easeInOut(duration: 0.1), value: color)  // Animate the chart when data changes
        .chartYScale(domain: 40...200)  // Set the Y-axis range for heart rate values
        .frame(height: .infinity)  // Set the height of the chart
    }
}

struct SessionSensorDataDetailLineHR_Previews: PreviewProvider {
    static var previews: some View {
        var previewData: [[String: Any]] = []

        for i in 0...60 {
            previewData.append([
                "timestamp": Date().addingTimeInterval(Double(i)),
                "hrValue": Double.random(in: 40..<200),
            ])
        }

        return SessionSensorDataDetailLineHR(hrData: previewData, color: .blue)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
