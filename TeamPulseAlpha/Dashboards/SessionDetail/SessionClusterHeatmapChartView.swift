//
//  SessionClusterHeatmapChartView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/27/24.
//

import SwiftUI

/// SwiftUI component to display a heatmap for session cluster data.
/// The chart includes a customizable title and labels for the first row, first column, and seventh row.
struct SessionClusterHeatmapChartView: View {
    let data: [Double]  // Data values for the heatmap
    let title: String  // Title to display above the heatmap

    var body: some View {
        VStack {
            Text(title)  // Heatmap title
                .font(.headline)
                .padding(.bottom, 10)  // Spacing between the title and the heatmap

            VStack(spacing: 2) {
                // First row with labels
                HStack(spacing: 2) {
                    Color.clear.frame(width: 80, height: 40)  // Placeholder for the corner
                    Text("Blue").frame(width: 80, height: 40).background(Color.gray).foregroundColor(.black)
                    Text("Green").frame(width: 80, height: 40).background(Color.gray).foregroundColor(.black)
                    Text("Red").frame(width: 80, height: 40).background(Color.gray).foregroundColor(.black)
                    Text("Soft").frame(width: 80, height: 40).background(Color.gray).foregroundColor(.black)
                    Text("Hard").frame(width: 80, height: 40).background(Color.gray).foregroundColor(.black)
                }

                // Heatmap rows including the first column with labels
                ForEach(0..<6, id: \.self) { rowIndex in
                    HStack(spacing: 2) {
                        // First column with labels
                        Text(firstColumnLabel(for: rowIndex))
                            .frame(width: 80, height: 40)
                            .background(Color.gray)
                            .foregroundColor(.black)

                        // Heatmap cells
                        ForEach(0..<5, id: \.self) { colIndex in
                            Rectangle()
                                .fill(heatmapColor(for: heatmapValue(row: rowIndex, col: colIndex)))
                                .cornerRadius(4)
                                .overlay(
                                    Text(String(format: "%.2f", heatmapValue(row: rowIndex, col: colIndex) * 100) + " %")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                )
                                .frame(width: 80, height: 40)
                        }
                    }
                }

                // Seventh row with labels
                HStack(spacing: 2) {
                    Text("").frame(width: 80, height: 40)
                    Text("BSH").frame(width: 80, height: 40).background(Color.gray).foregroundColor(.black)
                    Text("GSH").frame(width: 80, height: 40).background(Color.gray).foregroundColor(.black)
                    Text("RSH").frame(width: 80, height: 40).background(Color.gray).foregroundColor(.black)
                    Text("BGRS").frame(width: 80, height: 40).background(Color.gray).foregroundColor(.black)
                    Text("BGRSH").frame(width: 80, height: 40).background(Color.gray).foregroundColor(.black)
                }
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }

    /// Function to get the label for the first column based on the row index
    private func firstColumnLabel(for rowIndex: Int) -> String {
        switch rowIndex {
        case 0: return "Blue"
        case 1: return "Green"
        case 2: return "Red"
        case 3: return "Soft"
        case 4: return "Hard"
        case 5: return "Total"
        default: return ""
        }
    }

    /// Function to calculate the heatmap value based on the row and column index
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

    /// Function to determine the color of the heatmap cell based on the value
    private func heatmapColor(for value: Double) -> Color {
        let normalizedValue = max(0, min(1, value * 5))  // Ensure the value is within [0, 1]
        return Color(red: normalizedValue, green: 0, blue: 1 - normalizedValue)
    }
}

struct SessionClusterHeatmapChartView_Previews: PreviewProvider {
    static var previews: some View {
        SessionClusterHeatmapChartView(data: [0.01, 0.13, 0.08, 0.002, 0.001], title: "Cluster Heatmap")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
