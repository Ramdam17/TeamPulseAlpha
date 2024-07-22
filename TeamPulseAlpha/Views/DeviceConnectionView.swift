//
//  DeviceConnectionView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

struct DeviceConnectionView: View {
    var body: some View {
        VStack {
            Text("Connecting to Devices...")
                .font(.largeTitle)
                .padding()
            // Add device connection logic and UI here
            NavigationLink(destination: SessionRecordingView()) {
                Text("Proceed to Session Recording")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
            }
        }
        .navigationBarTitle("Device Connection", displayMode: .inline)
    }
}
