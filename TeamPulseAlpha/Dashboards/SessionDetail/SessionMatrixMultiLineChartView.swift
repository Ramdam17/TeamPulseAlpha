//
//  SessionMatrixMultiLineChartView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/27/24.
//

import Charts
import SwiftUI

/// SwiftUI component to display a multiline chart based on matrix data.
/// The chart includes a customizable title above it and a legend on the right.
struct SessionMatrixMultiLineChartView: View {
    let matrixDataArray: [[String: Any]]  // Array of elements with "timestamp" and "matrix" fields
    let i: Int  // Row index for the matrix
    let j1: Int  // First column index
    let j2: Int  // Second column index

    let colors: [Color] = [.blue, .green, .red]  // Array of colors for the lines
    let title: String  // Title to display above the chart
    let legendLabels: [String]  // Legend labels for the lines
    let isPositive: Bool

    var body: some View {
        VStack {
            Text(title)  // Chart title
                .font(.headline)
                .padding(.bottom, 10)  // Spacing between the title and the chart

            Chart {
                // Extract series data from the matrix using the helper function
                let series = extractSeries(from: matrixDataArray, i: i, j1: j1, j2: j2)

                // Plot the first line (i, j1)
                if let values1 = series[0]["values"] as? [Double] {
                    let color1 = colors[j1 % colors.count]

                    ForEach(0..<values1.count, id: \.self) { indexJ in
                        LineMark(
                            x: .value("Index", indexJ),
                            y: .value("Value", values1[indexJ])
                        )
                        .interpolationMethod(.catmullRom)  // Smooth line interpolation
                        .lineStyle(StrokeStyle(lineWidth: 1))  // Set line width
                        .foregroundStyle(color1.opacity(0.6))  // Apply color with opacity
                    }
                    .foregroundStyle(color1.opacity(0.6))  // Ensure color consistency
                    .symbol(by: .value("Series", legendLabels[0]))  // Use the first legend label
                    .symbolSize(0)  // No symbols at data points
                }

                // Plot the second line (i, j2)
                if let values2 = series[1]["values"] as? [Double] {
                    let color2 = colors[j2 % colors.count]

                    ForEach(0..<values2.count, id: \.self) { indexJ in
                        LineMark(
                            x: .value("Index", indexJ),
                            y: .value("Value", values2[indexJ])
                        )
                        .interpolationMethod(.catmullRom)  // Smooth line interpolation
                        .lineStyle(StrokeStyle(lineWidth: 1))  // Set line width
                        .foregroundStyle(color2.opacity(0.6))  // Apply color with opacity
                    }
                    .foregroundStyle(color2.opacity(0.6))  // Ensure color consistency
                    .symbol(by: .value("Series", legendLabels[1]))  // Use the second legend label
                    .symbolSize(0)  // No symbols at data points
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)  // Position the Y-axis on the left
            }
            .chartYScale(domain: isPositive ? 0...10 : -1...1)
            .chartLegend(position: .bottom)  // Position the legend on the right
            .padding()
        }
        .padding()
    }

    /// Helper function to extract a series from the matrix data
    /// - Parameters:
    ///   - matrixDataArray: The array of matrix data.
    ///   - i: The row index for the matrix.
    ///   - j1: The first column index.
    ///   - j2: The second column index.
    /// - Returns: An array of dictionaries containing the extracted series.
    private func extractSeries(from matrixDataArray: [[String: Any]], i: Int, j1: Int, j2: Int) -> [[String: Any]] {
        var series: [[String: Any]] = []
        var serie1: [Double] = []
        var serie2: [Double] = []

        for element in matrixDataArray {
            if let matrix = element["matrix"] as? [[Double]],
               matrix.indices.contains(i), matrix[i].indices.contains(j1),
               matrix[i].indices.contains(j2) {
                serie1.append(matrix[i][j1])
                serie2.append(matrix[i][j2])
            }
        }

        series.append([
            "index": j1,
            "values": serie1
        ])
        series.append([
            "index": j2,
            "values": serie2
        ])

        return series
    }
}

struct SessionMatrixMultiLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        let mockMatrixDataArray: [[String: Any]] = [
            [
                "timestamp": Date(),
                "matrix": [
                    [0.1, 0.9, 0.1],
                    [0.4, 0.5, 0.6],
                    [0.7, 0.8, 0.9],
                ],
            ],
            [
                "timestamp": Date(),
                "matrix": [
                    [0.2, 0.3, 0.8],
                    [0.5, 0.6, 0.7],
                    [0.8, 0.9, 1.0],
                ],
            ],
            // Add more mock data as needed
        ]

        return SessionMatrixMultiLineChartView(
            matrixDataArray: mockMatrixDataArray,
            i: 0,
            j1: 1,
            j2: 2,
            title: "Matrix Multi-Line Chart",
            legendLabels: ["Line 1", "Line 2"],
            isPositive: true
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
