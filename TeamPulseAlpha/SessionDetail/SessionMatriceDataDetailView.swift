//
//  SessionMatriceDataDetailView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import SwiftUI

struct SessionMatriceDataDetailView: View {

    let correlationMatrixArray: [[String: Any]]
    let crossEntropyMatrixArray: [[String: Any]]
    let conditionalEntropyMatrixArray: [[String: Any]]
    let mutualInformationMatrixArray: [[String: Any]]

    var body: some View {
        
        GeometryReader { metrics in
            VStack(spacing: 20) {
                SessionMatriceDataDetailRowView(
                    matrixData: correlationMatrixArray, title: "Correlation Matrix"
                )
                .frame(width : metrics.size.width, height: metrics.size.height * 0.2)

                SessionMatriceDataDetailRowView(
                    matrixData: crossEntropyMatrixArray,
                    title: "Cross Entropy Matrix"
                )
                .frame(width : metrics.size.width, height: metrics.size.height * 0.2)

                SessionMatriceDataDetailRowView(
                    matrixData: conditionalEntropyMatrixArray,
                    title: "Conditional Entropy Matrix"
                )
                .frame(width : metrics.size.width, height: metrics.size.height * 0.2)

                SessionMatriceDataDetailRowView(
                    matrixData: mutualInformationMatrixArray,
                    title: "Mutual Information Matrix"
                )
                .frame(width : metrics.size.width, height: metrics.size.height * 0.2)

            }
            .padding()
        }
    }
}

struct SessionMatriceDataDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockMatrix: [[String: Any]] = [
            [
                "matrix": [
                    [0.1, 0.2, 0.3],
                    [0.4, 0.5, 0.6],
                    [0.7, 0.8, 0.9],
                ]
            ]
        ]

        return SessionMatriceDataDetailView(
            correlationMatrixArray: mockMatrix,
            crossEntropyMatrixArray: mockMatrix,
            conditionalEntropyMatrixArray: mockMatrix,
            mutualInformationMatrixArray: mockMatrix
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
