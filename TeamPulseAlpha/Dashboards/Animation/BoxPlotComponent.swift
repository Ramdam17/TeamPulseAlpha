//
//  BoxPlotComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/20/24.
//

import Charts
import SwiftUI

struct BoxPlotComponent: View {

    let data: [UUID: [Double]]  // Data for each sensor
    let colors: [Color]  // Colors for each sensor
    let names = ["Blue", "Green", "Red"]

    var body: some View {
        VStack {
            Text("Box Plot of Heart Rate Statistics")
                .font(.headline)
                .padding(.bottom, 10)

            Chart {
                ForEach(Array(data.keys.enumerated()), id: \.element) {
                    index, sensorID in
                    if let stats = data[sensorID], stats.count == 4 {
                        // Extract statistics
                        let min = stats[0]
                        let max = stats[1]
                        let median = stats[2]
                        let mean = stats[3]
                        let name = names[index]

                        // Set up the X-axis position using a fixed coordinate system
                        let xPositionStart = Double(index) * 30 + 10  // Start of the rectangle
                        let xPositionEnd = Double(index) * 30 + 30  // End of the rectangle

                        // Draw the interquartile range as a rectangle
                        RectangleMark(
                            xStart: .value("Sensor", xPositionStart),
                            xEnd: .value("Sensor", xPositionEnd),
                            yStart: .value("Min", median),
                            yEnd: .value("Max", max)
                        )
                        .foregroundStyle(
                            by: .value("Sensor", name)
                        )
                        .foregroundStyle(
                            colors[index % colors.count].opacity(0.6)
                        )
                        .cornerRadius(2)

                        RectangleMark(
                            xStart: .value("Sensor", xPositionStart),
                            xEnd: .value("Sensor", xPositionEnd),
                            yStart: .value("Min", min),
                            yEnd: .value("Max", median)
                        )
                        .foregroundStyle(
                            by: .value("Sensor", name)
                        )
                        .foregroundStyle(
                            colors[index % colors.count].opacity(0.3)
                        )
                        .cornerRadius(2)

                        // Draw the median as a rule (line)
                        RuleMark(
                            xStart: .value("Sensor", xPositionStart - 5),
                            xEnd: .value("Sensor", xPositionEnd + 5),
                            y: .value("Median", median)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .foregroundStyle(
                            by: .value("Sensor", name)
                        )
                        .foregroundStyle(colors[index % colors.count])

                        // Draw the mean as a point
                        PointMark(
                            x: .value(
                                "Sensor", (xPositionStart + xPositionEnd) / 2),
                            y: .value("Mean", mean)
                        )
                        .symbolSize(100)
                        .foregroundStyle(
                            by: .value("Sensor", name)
                        )
                        .foregroundStyle(colors[index % colors.count])
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(values: Array(stride(from: 0, through: 100, by: 1))) {
                    value in
                }
            }
            .chartYScale(domain: 0...200)  // Adjust this domain based on expected HR range
            .frame(height: 300)
            .padding()
        }
    }
}

struct BoxPlotComponent_Previews: PreviewProvider {
    static var previews: some View {
        // Example data for preview purposes
        let exampleData: [UUID: [Double]] = [
            UUID(): [50, 100, 75, 80],  // Min, Max, Median, Mean
            UUID(): [60, 120, 90, 85],
            UUID(): [55, 110, 80, 82],
        ]

        BoxPlotComponent(
            data: exampleData,
            colors: [.blue, .green, .red]
        )
        .frame(height: 300)
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
