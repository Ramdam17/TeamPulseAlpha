//
//  SessionSensorDataDetailLineIBI.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import SwiftUI
import Charts

/// SwiftUI component to display a line chart of inter-beat interval (IBI) data.
/// The chart includes a customizable title above it and no legend.
struct SessionSensorDataDetailLineIBI: View {
    var ibiData: [[String: Any]]  // IBI data as an array of dictionaries
    let color: Color  // Color for the line in the chart
    let title: String  // Title to display above the chart

    var body: some View {
        VStack {
            Text(title)  // Chart title
                .font(.headline)
                .padding(.bottom, 10)  // Spacing between the title and the chart

            Chart {
                ForEach(Array(ibiData.enumerated()), id: \.offset) { index, dataPoint in
                    if let ibiData = extractIBIData(from: dataPoint) {
                        LineMark(
                            x: .value("Time", ibiData.timestamp),
                            y: .value("IBI", ibiData.ibiValue * 1000)  // Convert to ms
                        )
                        .interpolationMethod(.catmullRom)  // Smooth line interpolation
                        .lineStyle(StrokeStyle(lineWidth: 2))  // Customize line width
                        .foregroundStyle(color)  // Apply the provided color
                    }
                }
            }
            .chartXAxisLabel("Time")  // X-axis label
            .chartYAxisLabel("IBI in ms")  // Y-axis label
            .chartLegend(.hidden)  // Hide legend as it's unnecessary
            .animation(.easeInOut(duration: 0.1), value: color)  // Animate color changes
            .chartYScale(domain: 0...2000)  // Y-axis range for IBI values in ms
        }
        .padding()
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

        return SessionSensorDataDetailLineIBI(ibiData: previewData, color: .blue, title: "Inter-beat Interval Over Time")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
