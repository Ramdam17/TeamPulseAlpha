//
//  SessionMatriceDataDetailRow.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/27/24.
//

import SwiftUI

struct SessionMatriceDataDetailRowView: View {
    let matrixData: [[String: Any]]  // Array containing matrix data
    let title: String  // Title for the row view
    let isPositive: Bool

    var body: some View {
        VStack {
            // Title for the row of charts
            Text(title)
                .font(.headline)
                .padding()

            HStack {
                // Three multiline charts for different matrix indices
                SessionMatrixMultiLineChartView(matrixDataArray: matrixData, i: 0, j1: 1, j2: 2, title: "Blue sensor", legendLabels: ["With Green Sensor", "With Red Sensor"], isPositive: isPositive)
                SessionMatrixMultiLineChartView(matrixDataArray: matrixData, i: 1, j1: 2, j2: 0, title: "Green sensor", legendLabels: ["With Red Sensor", "With Blue Sensor"], isPositive: isPositive)
                SessionMatrixMultiLineChartView(matrixDataArray: matrixData, i: 2, j1: 0, j2: 1, title: "Red sensor", legendLabels: ["With Blue Sensor", "With Green Sensor"], isPositive: isPositive)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
}

struct SessionMatriceDataDetailRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample preview data for testing
        let mockMatrixData: [[String: Any]] = [
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

        return SessionMatriceDataDetailRowView(matrixData: mockMatrixData, title: "Matrix Data Detail", isPositive: true)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
