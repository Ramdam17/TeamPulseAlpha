//
//  SessionMatriceDataDetailView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import SwiftUI

struct SessionMatriceDataDetailView: View {
    
    let proximityMatrixArray: [[String: Any]]
    let correlationMatrixArray: [[String: Any]]
    let crossEntropyMatrixArray: [[String: Any]]
    let conditionalEntropyMatrixArray: [[String: Any]]
    let mutualInformationMatrixArray: [[String: Any]]

    var body: some View {
        VStack {
            // Placeholder for matrix data content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }

}

struct SessionMatriceDataDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SessionMatriceDataDetailView(
            proximityMatrixArray: [],
            correlationMatrixArray: [],
            crossEntropyMatrixArray: [],
            conditionalEntropyMatrixArray: [],
            mutualInformationMatrixArray: []
        )
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
