//
//  LineChartHRVComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/20/24.
//

import SwiftUI
import Charts

struct LineChartHRVComponent: View {

    var data: [UUID: [HRVDataPoint]]
    let colors: [Color]  // Colors for each line
    let names = ["Blue", "Green", "Red"]

    var body: some View {
        VStack {
            Text("Heart Rate Variability Over Time")
                .font(.headline)
                .padding(.bottom, 10)

            Chart {
                // Iterate over each sensor ID and its corresponding HR data
                ForEach(Array(data.keys.enumerated()), id: \.offset) { index, sensorID in
                    if let sensorData = data[sensorID] {
                        // Ensure we're only taking the last 60 values
                        let last60Data = Array(sensorData.suffix(60))
                        
                        // Use a `ForEach` to create a distinct series for each sensor
                        ForEach(last60Data.indices, id: \.self) { pointIndex in
                            let hrValue = last60Data[pointIndex].hrvValue
                            let color = colors[index % colors.count]
                            let sensorSeriesID = sensorID.uuidString  // Convert UUID to String
                            let name = names[index % colors.count]

                            LineMark(
                                x: .value("Time", pointIndex),  // X value as index
                                y: .value("Heart Rate Variability", hrValue*1000)  // Y value as HR value
                            )
                            .interpolationMethod(.catmullRom)  // Apply smoothing using Catmull-Rom interpolation
                            .lineStyle(StrokeStyle(lineWidth: 2))
                            .foregroundStyle(by: .value("Sensor", name))  // Distinguish lines by sensorID String
                            .foregroundStyle(color)  // Color based on sensorID
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 1.0), value: data)
            .chartYScale(domain: 0...800)  // Example range for heart rate variability values
            .frame(height: 200)
            .padding()
        }
    }
}


struct LineChartHRVComponent_Previews: PreviewProvider {
    static var previews: some View {
        // Example HR data for preview purposes
        let exampleHRVData: [UUID: [HRVDataPoint]] = [
            UUID(): (0..<60).map { HRVDataPoint(timestamp: Date().addingTimeInterval(Double($0) * 60), hrvValue: Double.random(in: 0...1)) },
            UUID(): (0..<60).map { HRVDataPoint(timestamp: Date().addingTimeInterval(Double($0) * 60), hrvValue: Double.random(in: 0...1)) },
            UUID(): (0..<60).map { HRVDataPoint(timestamp: Date().addingTimeInterval(Double($0) * 60), hrvValue: Double.random(in: 0...1)) }
        ]
        
        return LineChartHRVComponent(
            data: exampleHRVData,
            colors: [.blue, .green, .red]
        )
        .frame(height: 300)
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
