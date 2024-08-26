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


    var body: some View {
        VStack {
            // Placeholder for cluster data content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
}

struct SessionClusterDataDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SessionClusterDataDetailView(
            clusterStateArray: [],
            proximityMatrixArray: []
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
