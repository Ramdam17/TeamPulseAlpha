//
//  SessionSensorDataDetailRowView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import SwiftUI

struct SessionSensorDataDetailRowView: View {

    let hrDataArray: [[String: Any]]
    let ibiDataArray: [[String: Any]]
    let hrvDataArray: [[String: Any]]

    let color: Color
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                
                SessionSensorDataDetailLineHR(
                    hrData: hrDataArray,
                    color: color
                )
                SessionSensorDataDetailLineIBI(
                    ibiData: ibiDataArray,
                    color: color
                )
                SessionSensorDataDetailLineHRV(
                    hrvData: hrvDataArray,
                    color: color
                )
                SessionSensorDataDetailBoxplot(
                    hrData: hrDataArray,
                    color: color
                )
                
            }
            .padding()
            .frame(width: .infinity, height: .infinity)
            .ignoresSafeArea(.all)
            Spacer()
        }
        .padding()
        .frame(width: .infinity, height: .infinity)
        .ignoresSafeArea(.all)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct SessionSensorDataDetailRowView_Previews: PreviewProvider {
    static var previews: some View {
        
        var previewData: [[String: Any]] = []

        for _ in 0...60 {
            previewData.append([
                "timestamp": Date(),
                "hrValue": Double.random(in: 40..<200),
                "hrvValue": Double.random(in: 0..<0.5),
                "ibiValue": Double.random(in: 0..<1.0),

            ])
        }

        return SessionSensorDataDetailRowView(
            hrDataArray: previewData, ibiDataArray: previewData, hrvDataArray: previewData, color: .blue
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
