//
//  SessionClusterHeatmapChartView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/27/24.
//

import SwiftUI

struct SessionClusterHeatmapChartView: View {
    let data: [Double]

    var body: some View {
        VStack {
            Text("Heatmap")
                .font(.headline)
                .padding(.top)

            // 6 rows x 5 columns heatmap
            VStack(spacing: 2) {
                ForEach(0..<6, id: \.self) { rowIndex in
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { colIndex in
                            Rectangle()
                                .fill(heatmapColor(for: heatmapValue(row: rowIndex, col: colIndex)))
                                .cornerRadius(4)
                                .overlay(
                                    Text(String(format: "%.2f", heatmapValue(row: rowIndex, col: colIndex) * 100) + " %")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    private func heatmapValue(row: Int, col: Int) -> Double {
        switch (row, col) {

        case (0, 1), (1, 0):
            return data[0]
        case (0, 2), (2, 0):
            return data[1]
        case (1, 2), (2, 1):
            return data[2]
        case (3, 0), (3, 1), (3, 2), (0, 3), (1, 3), (2, 3):
            return data[3]
        case (4, 0), (4, 1), (4, 2), (0, 4), (1, 4), (2, 4):
            return data[4]
        case (5, 0):
            return data[0] + data[1] + data[3] + data[4]
        case (5, 1):
            return data[0] + data[2] + data[3] + data[4]
        case (5, 2):
            return data[1] + data[2] + data[3] + data[4]
        case (5, 3):
            return data[0] + data[1] + data[2] + data[3]
        case (5, 4):
            return data[0] + data[1] + data[2] + data[3] + data[4]
        default:
            return 0.0
        }
    }
    
    private func heatmapColor(for value: Double) -> Color {
            let normalizedValue = max(0, min(1, value*5)) // Ensure the value is within [0, 1]
            return Color(red: normalizedValue, green: 0, blue: 1 - normalizedValue)
        }
}

struct SessionClusterHeatmapChartView_Previews: PreviewProvider {
    static var previews: some View {
        SessionClusterHeatmapChartView(data: [0.01, 0.13, 0.08, 0.002, 0.001])
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
