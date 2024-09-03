//
//  SessionSensorDataDetailRowView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import SwiftUI

struct SessionSensorDataDetailRowView: View {
    let hrDataArray: [[String: Any]]  // Array containing heart rate data
    let ibiDataArray: [[String: Any]]  // Array containing IBI data
    let hrvDataArray: [[String: Any]]  // Array containing HRV data
    let color: Color  // Color to be used in the charts

    var body: some View {
        VStack {
            Spacer()

            HStack {
                // Heart Rate Line Chart
                SessionSensorDataDetailLineHR(
                    hrData: hrDataArray,
                    color: color,
                    title: "Heart rate"
                )
                
                // IBI Line Chart
                SessionSensorDataDetailLineIBI(
                    ibiData: ibiDataArray,
                    color: color,
                    title: "Interbeat intervals"
                )
                
                // HRV Line Chart
                SessionSensorDataDetailLineHRV(
                    hrvData: hrvDataArray,
                    color: color,
                    title: "Heart rate variability"
                )
                
                // Boxplot for Heart Rate Data
                SessionSensorDataDetailBoxplot(
                    hrData: hrDataArray,
                    color: color,
                    title: "Statistics for heart rate"
                )
            }
            .padding()
            .ignoresSafeArea(.all)
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct SessionSensorDataDetailRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Generate sample preview data
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
            hrDataArray: previewData,
            ibiDataArray: previewData,
            hrvDataArray: previewData,
            color: .blue
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
