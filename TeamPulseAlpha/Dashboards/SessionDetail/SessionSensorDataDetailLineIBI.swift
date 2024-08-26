//
//  SessionSensorDataDetailLineIBI.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import SwiftUI
import Charts

struct SessionSensorDataDetailLineIBI: View {
    var ibiData: [[String: Any]]
    let color: Color

    var body: some View {
        Chart {
            ForEach(Array(ibiData.enumerated()), id: \.offset) { index, dataPoint in
                if let timestamp = dataPoint["timestamp"] as? Date,
                   let ibiValue = dataPoint["ibiValue"] as? Double {
                    LineMark(
                        x: .value("Time", timestamp),
                        y: .value("HR", ibiValue*1000)
                    )
                    .interpolationMethod(.catmullRom)  // Apply Catmull-Rom interpolation for smoother lines
                    .lineStyle(StrokeStyle(lineWidth: 2))  // Set the line width
                    .foregroundStyle(color)  // Apply the color to the line
                }
            }
        }
        .chartXAxisLabel("Time")
        .chartYAxisLabel("IBI in ms")
        .chartLegend(.hidden)
        .animation(.easeInOut(duration: 0.1), value: color)  // Animate the chart when data changes
        .chartYScale(domain: 0...500)  // Set the Y-axis range for heart rate values
        .frame(height: .infinity)  // Set the height of the chart
    }
}

struct SessionSensorDataDetailLineIBI_Previews: PreviewProvider {
    static var previews: some View {
        let previewData: [[String: Any]] = [
            ["timestamp": Date(), "ibiValue": 272.0],
            ["timestamp": Date().addingTimeInterval(60), "ibiValue": 175.0],
            ["timestamp": Date().addingTimeInterval(120), "ibiValue": 78.0],
            ["timestamp": Date().addingTimeInterval(180), "ibiValue": 180.0]
        ]

        return SessionSensorDataDetailLineIBI(ibiData: previewData, color: .blue)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
