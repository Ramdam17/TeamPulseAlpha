//
//  BoxPlotComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/20/24.
//

import Charts
import SwiftUI

/// A SwiftUI component that displays a box plot for heart rate statistics for multiple sensors.
struct BoxPlotComponent: View {

    let data: [String: [Double]]  // Dictionary holding the statistics data for different sensors.
    let colors: [Color]  // Colors to differentiate the sensors in the box plot.
    let names: [String] = ["Blue", "Green", "Red"]  // Names associated with each sensor.

    var body: some View {
        VStack {

            Chart {
                // Loop through each sensor's data and render its box plot.
                ForEach(Array(data.keys.enumerated()), id: \.element) { index, sensorID in
                    
                    let name = names[index]

                    if let stats = data[name], stats.count == 4 {
                        // Extract statistics
                        let min = stats[0]
                        let max = stats[1]
                        let median = stats[2]
                        let mean = stats[3]

                        // Define the X-axis position using a fixed coordinate system
                        let xPositionStart = Double(index) * 33 + 10  // Start of the rectangle
                        let xPositionEnd = Double(index) * 33 + 30  // End of the rectangle

                        // Draw the interquartile range as a rectangle (from min to median)
                        RectangleMark(
                            xStart: .value("Sensor", xPositionStart),
                            xEnd: .value("Sensor", xPositionEnd),
                            yStart: .value("Min", min),
                            yEnd: .value("Median", median)
                        )
                        .foregroundStyle(colors[index % colors.count].opacity(0.3))
                        .cornerRadius(2)

                        // Draw the interquartile range as a rectangle (from median to max)
                        RectangleMark(
                            xStart: .value("Sensor", xPositionStart),
                            xEnd: .value("Sensor", xPositionEnd),
                            yStart: .value("Median", median),
                            yEnd: .value("Max", max)
                        )
                        .foregroundStyle(colors[index % colors.count].opacity(0.6))
                        .cornerRadius(2)

                        // Draw the median as a rule (line)
                        RuleMark(
                            xStart: .value("Sensor", xPositionStart - 5),
                            xEnd: .value("Sensor", xPositionEnd + 5),
                            y: .value("Median", median)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 5))
                        .foregroundStyle(colors[index % colors.count])

                        // Draw the mean as a point
                        PointMark(
                            x: .value("Sensor", (xPositionStart + xPositionEnd) / 2),
                            y: .value("Mean", mean)
                        )
                        .symbolSize(100)
                        .foregroundStyle(colors[index % colors.count])
                    }
                }
            }
            .chartLegend(.hidden)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(values: Array(stride(from: 0, through: 100, by: 1))) {
                    value in
                }
            }
            .chartYScale(domain: 0...200)  // Adjust this domain based on expected HR range
            .frame(height: .infinity)
            .padding()
        }
    }
}

/// Preview provider for the `BoxPlotComponent`, showcasing the component with sample data.
struct BoxPlotComponent_Previews: PreviewProvider {
    static var previews: some View {
        // Example data for preview purposes
        let exampleData: [String: [Double]] = [
            "Blue": [50, 100, 75, 80],  // Min, Max, Median, Mean
            "Green": [60, 120, 90, 85],
            "Red": [55, 110, 80, 82],
        ]
        
        Group {
            // iPhone 15 Pro Preview
            BoxPlotComponent(
                data: exampleData,
                colors: [.blue, .green, .red]
            )
            .frame(height: 300)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
            .previewDisplayName("iPhone 15 Pro")

            // iPad Pro 11-inch Preview
            BoxPlotComponent(
                data: exampleData,
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
            BoxPlotComponent(
                data: exampleData,
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
