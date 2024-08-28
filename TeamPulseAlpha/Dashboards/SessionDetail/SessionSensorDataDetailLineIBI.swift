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
        .chartYScale(domain: 0...2000)  // Set the Y-axis range for heart rate values
    }
}

struct SessionSensorDataDetailLineIBI_Previews: PreviewProvider {
    static var previews: some View {
        var previewData: [[String: Any]] = []

        for i in 0...60 {
            previewData.append([
                "timestamp": Date().addingTimeInterval(Double(i)),
                "ibiValue": Double.random(in: 0..<1),
            ])
        }


        return SessionSensorDataDetailLineIBI(ibiData: previewData, color: .blue)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
