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
        SessionSensorDataDetailRowView(
            hrDataArray: [], ibiDataArray: [], hrvDataArray: [], color: .blue
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
