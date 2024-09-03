//
//  SessionMatriceDataDetailView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import SwiftUI

struct SessionMatriceDataDetailView: View {
    let correlationMatrixArray: [[String: Any]]  // Array containing correlation matrix data
    let crossEntropyMatrixArray: [[String: Any]]  // Array containing cross entropy matrix data
    let conditionalEntropyMatrixArray: [[String: Any]]  // Array containing conditional entropy matrix data
    let mutualInformationMatrixArray: [[String: Any]]  // Array containing mutual information matrix data

    var body: some View {
        ScrollView {
            VStack(spacing: 2) {
                // Row view for the Correlation Matrix
                SessionMatriceDataDetailRowView(
                    matrixData: correlationMatrixArray, title: "Correlation Matrix", isPositive: false
                )
                .frame(height: 400)

                // Row view for the Cross Entropy Matrix
                SessionMatriceDataDetailRowView(
                    matrixData: crossEntropyMatrixArray,
                    title: "Cross Entropy Matrix", isPositive: true
                )
                .frame(height: 400)

                // Row view for the Conditional Entropy Matrix
                SessionMatriceDataDetailRowView(
                    matrixData: conditionalEntropyMatrixArray,
                    title: "Conditional Entropy Matrix", isPositive: true
                )
                .frame(height: 400)

                // Row view for the Mutual Information Matrix
                SessionMatriceDataDetailRowView(
                    matrixData: mutualInformationMatrixArray,
                    title: "Mutual Information Matrix", isPositive: true
                )
                .frame(height: 400)
            }
            .padding()
        }
    }
}

struct SessionMatriceDataDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock data for previewing the view
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
