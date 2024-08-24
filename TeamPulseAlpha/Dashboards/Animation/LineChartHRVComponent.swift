//
//  LineChartHRVComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/20/24.
//

import SwiftUI
import Charts

/// A SwiftUI view that displays a line chart representing heart rate variability (HRV) over time for multiple sensors.
struct LineChartHRVComponent: View {

    // Data source containing HRV data points for different sensors.
    var data: [String: [HRVDataPoint]]
    
    // Colors to represent each sensor line on the chart.
    let colors: [Color]
    
    // Array of sensor names corresponding to the data keys.
    let names = ["Blue", "Green", "Red"]

    var body: some View {
        VStack {

            // The Chart view where HRV data is visualized
            Chart {
                // Iterate over each sensor data entry by its index
                ForEach(Array(data.keys.enumerated()), id: \.offset) { index, sensorID in
                    let name = names[index]  // Get the sensor name based on the index
                    if let sensorData = data[name] {
                        // Only consider the last 60 data points for each sensor
                        let last60Data = Array(sensorData.suffix(60))
                        
                        // For each data point in the last 60, create a LineMark for the chart
                        ForEach(last60Data.indices, id: \.self) { pointIndex in
                            let hrvValue = last60Data[pointIndex].hrvValue  // Scale HRV for better visualization
                            let color = colors[index % colors.count]  // Cycle through colors

                            LineMark(
                                x: .value("Time", pointIndex),  // X-axis represents time (using the index as a proxy)
                                y: .value("Heart Rate Variability", hrvValue)  // Y-axis represents the HRV value
                            )
                            .interpolationMethod(.catmullRom)  // Apply Catmull-Rom interpolation for smoother lines
                            .lineStyle(StrokeStyle(lineWidth: 2))  // Set the line width
                            .foregroundStyle(by: .value("Sensor", name))  // Color lines by sensor name
                            .foregroundStyle(color)  // Apply the color to the line
                        }
                    }
                }
            }
            .chartLegend(.hidden)
            .animation(.easeInOut(duration: 0.1), value: data)  // Animate the chart when data changes
            .chartYScale(domain: 0...2)  // Set the Y-axis range for HRV values
            .frame(height: .infinity)  // Set the height of the chart
            .padding()  // Add padding around the chart for better spacing
        }
    }
}

// Preview provider for SwiftUI previews, allowing real-time design feedback.
struct LineChartHRVComponent_Previews: PreviewProvider {
    static var previews: some View {
        // Example HRV data for preview purposes
        let exampleHRVData: [String: [HRVDataPoint]] = [
            "Blue": (0..<60).map {
                HRVDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrvValue: Double.random(in: 0...1))
            },
            "Green": (0..<60).map {
                HRVDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrvValue: Double.random(in: 0...1))
            },
            "Red": (0..<60).map {
                HRVDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrvValue: Double.random(in: 0...1))
            },
        ]
        
        Group {
            // iPhone 15 Pro Preview
            LineChartHRVComponent(
                data: exampleHRVData,
                colors: [.blue, .green, .red]
            )
            .frame(height: 300)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
            .previewDisplayName("iPhone 15 Pro")

            // iPad Pro 11-inch Preview
            LineChartHRVComponent(
                data: exampleHRVData,
                colors: [.blue, .green, .red]
            )
            .frame(height: 300)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDevice(
                PreviewDevice(
                    rawValue: "iPad Pro (11-inch) (6th generation)")
            )
            .previewDisplayName("iPad Pro 11-inch")

            // iPad Pro 13-inch Preview
            LineChartHRVComponent(
                data: exampleHRVData,
                colors: [.blue, .green, .red]
            )
            .frame(height: 300)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDevice(
                PreviewDevice(
                    rawValue: "iPad Pro (12.9-inch) (6th generation)")
            )
            .previewDisplayName("iPad Pro 13-inch")
        }
    }
}
