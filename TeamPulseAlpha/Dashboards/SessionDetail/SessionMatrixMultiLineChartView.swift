//
//  SessionMatrixMultiLineChartView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/27/24.
//

import Charts
import SwiftUI

struct SessionMatrixMultiLineChartView: View {
    let matrixDataArray: [[String: Any]]  // The array of elements with "timestamp" and "matrix" fields
    let i: Int
    let j1: Int
    let j2: Int

    let colors: [Color] = [.blue, .green, .red]

    var body: some View {
        Chart {
            // Prepare series data
            let series = extractSeries()

            // Line for (i, j1)
            if let values1 = series[0]["values"] as? [Double] {
                let color1 = colors[j1 % colors.count]

                ForEach(0..<values1.count, id: \.self) { indexJ in
                    LineMark(
                        x: .value("Index", indexJ),
                        y: .value("Value", values1[indexJ])
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    .foregroundStyle(color1.opacity(0.6))
                }
                .foregroundStyle(color1.opacity(0.6)) // Ensure color consistency
                .symbol(by: .value("Series", "Line1")) // Unique identifier
                .symbolSize(0)
            }

            // Line for (i, j2)
            if let values2 = series[1]["values"] as? [Double] {
                let color2 = colors[j2 % colors.count]

                ForEach(0..<values2.count, id: \.self) { indexJ in
                    LineMark(
                        x: .value("Index", indexJ),
                        y: .value("Value", values2[indexJ])
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    .foregroundStyle(color2.opacity(0.6))
                }
                .foregroundStyle(color2.opacity(0.6)) // Ensure color consistency
                .symbol(by: .value("Series", "Line2")) // Unique identifier
                .symbolSize(0)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartLegend(.hidden)
    }

    // Helper function to extract a series from the matrix data
    private func extractSeries() -> [[String: Any]] {
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
            matrixDataArray: mockMatrixDataArray, i: 0, j1: 1, j2: 2
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
