//
//  LineChartHRComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/20/24.
//

import Charts
import SwiftUI

/// A SwiftUI view that displays a line chart representing heart rate data over time for multiple sensors.
struct LineChartHRComponent: View {

    // Data source containing heart rate data points for different sensors.
    var data: [String: [HRDataPoint]]
    
    // Colors to represent each sensor line on the chart.
    let colors: [Color]
    
    // Array of sensor names corresponding to the data keys.
    let names = ["Blue", "Green", "Red"]

    var body: some View {
        VStack {

            // The Chart view where heart rate data is visualized
            Chart {
                // Iterate over each sensor data entry by its index
                ForEach(Array(data.keys.enumerated()), id: \.offset) { index, sensorID in
                    let name = names[index]  // Get the sensor name based on the index
                    if let sensorData = data[name] {
                        // Only consider the last 60 data points for each sensor
                        let last60Data = Array(sensorData.suffix(60))

                        // For each data point in the last 60, create a LineMark for the chart
                        ForEach(last60Data.indices, id: \.self) { pointIndex in
                            let hrValue = last60Data[pointIndex].hrValue
                            let color = colors[index % colors.count]  // Cycle through colors

                            LineMark(
                                x: .value("Time", pointIndex),  // X-axis represents time (using the index as a proxy)
                                y: .value("Heart Rate", hrValue)  // Y-axis represents the heart rate value
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
            .chartYScale(domain: 20...220)  // Set the Y-axis range for heart rate values
            .padding(5)  // Add padding around the chart for better spacing
        }
    }
}

// Preview provider for SwiftUI previews, allowing real-time design feedback.
struct LineChartHRComponent_Previews: PreviewProvider {
    static var previews: some View {
        // Example heart rate data for preview purposes
        let exampleHRData: [String: [HRDataPoint]] = [
            "Blue": (0..<60).map {
                HRDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrValue: Double.random(in: 60...200))
            },
            "Green": (0..<60).map {
                HRDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrValue: Double.random(in: 60...200))
            },
            "Red": (0..<60).map {
                HRDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrValue: Double.random(in: 60...200))
            },
        ]
        
        Group {
            // iPhone 15 Pro Preview
            LineChartHRComponent(
                data: exampleHRData,
                colors: [.blue, .green, .red]
            )
            .frame(height: 300)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
            .previewDisplayName("iPhone 15 Pro")

            // iPad Pro 11-inch Preview
            LineChartHRComponent(
                data: exampleHRData,
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
            LineChartHRComponent(
                data: exampleHRData,
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
