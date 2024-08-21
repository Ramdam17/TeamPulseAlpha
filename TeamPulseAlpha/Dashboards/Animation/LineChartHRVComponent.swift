//
//  LineChartHRVComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/20/24.
//

import SwiftUI
import Charts

struct LineChartHRVComponent: View {
    
    @Environment var sensorDataProcessor: SensorDataProcessor  // Listen to the sensor data processor
    let colors: [Color]  // Colors for each line

    var body: some View {
        Chart {
            // Iterate over each sensor ID and its corresponding HR data
            ForEach(Array(sensorDataProcessor.hrvArray.keys.enumerated()), id: \.offset) { index, sensorID in
                if let sensorData = sensorDataProcessor.hrvArray[sensorID] {
                    // Iterate through each HRDataPoint to create a LineMark
                    ForEach(sensorData.indices, id: \.self) { pointIndex in
                        LineMark(
                            x: .value("Time", pointIndex),  // X value as index
                            y: .value("Heart Rate Variability", sensorData[pointIndex].hrvValue*1000)  // Y value as HR value
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .foregroundStyle(colors[index % colors.count])
                    }
                }
            }
        }
        .chartYScale(domain: 0...400)  // Example range for heart rate values
        .frame(height: 200)
        .padding()
    }
}

