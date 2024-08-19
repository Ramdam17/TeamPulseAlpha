//
//  AnimationView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import SwiftUI

struct AnimationView: View {
    var body: some View {
        VStack {
            // Placeholder for the Animation Component
            AnimationComponent()
                .frame(height: 300)
            
            // Placeholder for the Bluetooth Connection Status Component
            BluetoothStatusComponent()
                .padding()
            
            // Placeholder for the Dashboard Component
            DashboardComponent()
                .padding()
            
            // Placeholder for the Session Recording Management Component
            SessionRecordingComponent()
                .padding(.top, 20)
        }
        .navigationBarTitle("Animation", displayMode: .inline)
    }
}

