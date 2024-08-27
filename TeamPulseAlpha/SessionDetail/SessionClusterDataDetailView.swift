//
//  SessionClusterDataDetailView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import SwiftUI

struct SessionClusterDataDetailView: View {

    let clusterStateArray: [[String: Any]]
    let proximityMatrixArray: [[String: Any]]

    @State var clusterStateArrayRatio: [Double] = [0, 0, 0, 0, 0, 0]

    var body: some View {

        GeometryReader { metrics in

            HStack(spacing: 20) {

                VStack(spacing: 20) {
                    if clusterStateArrayRatio.count >= 5 {
                        SessionClusterHeatmapChartView(
                            data: Array(clusterStateArrayRatio.suffix(5))
                        )
                        .frame(
                            width: .infinity,
                            height: .infinity
                        )
                        SessionClusterBarplotChartView(
                            data: Array(clusterStateArrayRatio.suffix(5))
                        )
                        .frame(
                            width: .infinity,
                            height: .infinity
                        )
                        
                    }
                }
                .frame(
                    width: metrics.size.width * 0.3,
                    height: metrics.size.height * 1
                )


                VStack(spacing: 20) {
                    SessionClusterMultiLineChartView(
                        matrixDataArray: proximityMatrixArray, i: 0, j1: 1,
                        j2: 2
                    )
                    .frame(
                        width: .infinity,
                        height: .infinity
                    )
                    SessionClusterMultiLineChartView(
                        matrixDataArray: proximityMatrixArray, i: 1, j1: 0,
                        j2: 2
                    )
                    .frame(
                        width: .infinity,
                        height: .infinity
                    )
                    SessionClusterMultiLineChartView(
                        matrixDataArray: proximityMatrixArray, i: 2, j1: 0,
                        j2: 1
                    )
                    .frame(
                        width: .infinity,
                        height: .infinity
                    )
                }
                .frame(
                    width: metrics.size.width * 0.6,
                    height: metrics.size.height * 1
                )
            }
            .frame(
                width: .infinity,
                height: .infinity
            )
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding()
            .onAppear {
                
                let arraySummed = clusterStateArray.reduce(
                    [Double](repeating: 0, count: 6)
                ) { result, element in
                    if let booleanVector = element["clusterState"] as? [Double] {
                        let doubleVector = booleanVector.map { $0 > 0 ? 1.0 : 0.0 }
                        return zip(result, doubleVector).map(+)
                    }
                    return result
                }

                clusterStateArrayRatio = arraySummed.map {
                    $0 / Double(clusterStateArray.count)
                }
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
