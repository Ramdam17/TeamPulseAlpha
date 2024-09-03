//
//  SessionClusterDataDetailView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import SwiftUI

struct SessionClusterDataDetailView: View {
    let clusterStateArray: [[String: Any]]  // Array containing cluster state data
    let proximityMatrixArray: [[String: Any]]  // Array containing proximity matrix data

    @State var clusterStateArrayRatio: [Double] = [0, 0, 0, 0, 0, 0]  // Array to hold the ratio of cluster states

    var body: some View {
        HStack(spacing: 20) {
            VStack(spacing: 20) {
                if clusterStateArrayRatio.count >= 5 {
                    // Display heatmap with the last 5 cluster state ratios
                    SessionClusterHeatmapChartView(
                        data: Array(clusterStateArrayRatio.suffix(5)), title: "Heatmap of Cluster State Ratios"
                    )
                    // Display bar plot with the last 5 cluster state ratios
                    SessionClusterBarplotChartView(
                        data: Array(clusterStateArrayRatio.suffix(5)), title: "Barplot of Cluster State Ratios"
                    )
                }
            }
            .frame(width: 500)

            VStack(spacing: 20) {
                // Display multiline charts for the proximity matrix
                SessionClusterMultiLineChartView(
                    matrixDataArray: proximityMatrixArray, i: 0, j1: 1, j2: 2, title: "Blue proximity", legendLabels: ["With Green Sensor", "With Red Sensor"]
                )
                SessionClusterMultiLineChartView(
                    matrixDataArray: proximityMatrixArray, i: 1, j1: 0, j2: 2, title: "Green proximity", legendLabels: ["With Red Sensor", "With Blue Sensor"]
                )
                SessionClusterMultiLineChartView(
                    matrixDataArray: proximityMatrixArray, i: 2, j1: 0, j2: 1,
                    title: "Red proximity", legendLabels: ["With Blue Sensor", "With Green Sensor"]
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .onAppear {
            // Calculate the ratio of active clusters for each state
            let arraySummed = clusterStateArray.reduce(
                [Double](repeating: 0, count: 6)
            ) { result, element in
                if let booleanVector = element["clusterState"] as? [Double] {
                    let doubleVector = booleanVector.map { $0 > 0 ? 1.0 : 0.0 }
                    return zip(result, doubleVector).map(+)
                }
                return result
            }

            // Normalize the summed values by the total count
            clusterStateArrayRatio = arraySummed.map {
                $0 / Double(clusterStateArray.count)
            }
        }
    }
}

struct SessionClusterDataDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock data for the preview
        let mockClusterStateArray: [[String: Any]] = [
            ["clusterState": [false, false, false, false, false, true]],
            ["clusterState": [false, false, false, true, false, false]],
            ["clusterState": [false, false, false, false, true, false]],
            ["clusterState": [false, false, true, false, false, false]],
            ["clusterState": [true, true, false, false, false, false]],
        ]

        let mockProximityMatrixArray: [[String: Any]] = [
            [
                "timestamp": Date(),
                "matrix": [
                    [0.1, 0.2, 0.3],
                    [0.4, 0.5, 0.6],
                    [0.7, 0.8, 0.9],
                ],
            ],
            [
                "timestamp": Date(),
                "matrix": [
                    [0.2, 0.3, 0.4],
                    [0.5, 0.6, 0.7],
                    [0.8, 0.9, 1.0],
                ],
            ],
            [
                "timestamp": Date(),
                "matrix": [
                    [0.3, 0.4, 0.5],
                    [0.6, 0.7, 0.8],
                    [0.9, 1.0, 1.1],
                ],
            ],
        ]

        return SessionClusterDataDetailView(
            clusterStateArray: mockClusterStateArray,
            proximityMatrixArray: mockProximityMatrixArray
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
