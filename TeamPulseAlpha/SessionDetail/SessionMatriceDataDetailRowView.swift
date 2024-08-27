//
//  SessionMatriceDataDetailRow.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/27/24.
//

import SwiftUI

struct SessionMatriceDataDetailRowView: View {
    let matrixData: [[String: Any]]
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding(.top)
            
            HStack {
                
                // Three multiline charts for the matrix
                SessionMatrixMultiLineChartView(matrixDataArray: matrixData, i: 0, j1: 1, j2: 2)
                SessionMatrixMultiLineChartView(matrixDataArray: matrixData, i: 1, j1: 0, j2: 2)
                SessionMatrixMultiLineChartView(matrixDataArray: matrixData, i: 2, j1: 0, j2: 1)
                
            }            
        }
        .frame(width: .infinity, height: .infinity)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
}
