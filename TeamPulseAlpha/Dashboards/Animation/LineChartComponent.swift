//
//  LineChartComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/20/24.
//

import SwiftUI
import Charts

struct LineChartComponent: View {
    let data: [UUID: [Double]]  // Data for each sensor
    let colors: [Color]         // Colors for each line

    var body: some View {
        Chart {
            ForEach(data.keys.sorted(), id: \.self) { sensorID in
                if let sensorData = data[sensorID], !sensorData.isEmpty {
                    LineMark(
                        x: .value("Time", Array(0..<sensorData.count)),
                        y: .value("Heart Rate", sensorData)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .foregroundStyle(colors[Int(sensorID.hashValue % colors.count)])
                    .interpolationMethod(.catmullRom)
                }
            }
        }
        .chartYScale(domain: 50...180) // Example range for heart rate values
        .frame(height: 200)
        .padding()
    }
}
