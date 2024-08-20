//
//  AnimationView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import SwiftUI

struct AnimationView: View {

    // Initialize the SensorDataProcessor with actual sensor UUIDs
    @StateObject var sensorDataProcessor: SensorDataProcessor

    var body: some View {
        VStack {
            // Animation Component placeholder (this will display the actual animation)
            AnimationComponent()
                .frame(height: 300)

            // Bluetooth Connection Status Component
            BluetoothStatusComponent()
                .padding()

            // Dashboard Component - showing charts and stats related to the sensor data
            DashboardComponent()
                .environmentObject(sensorDataProcessor) // Pass the sensor data processor to the dashboard component
                .padding()

            // Session Recording Management Component
            SessionRecordingComponent()
                .padding(.top, 20)
        }
        .navigationBarTitle("Animation", displayMode: .inline)
    }
}

// Sample usage of the AnimationView with actual UUIDs
struct AnimationView_Previews: PreviewProvider {
    static var previews: some View {
        // Example sensor UUIDs - replace with actual UUIDs from your app's data
        let sensorUUIDs = [UUID(), UUID(), UUID()]
        AnimationView(sensorDataProcessor: SensorDataProcessor(sensorIDs: sensorUUIDs))
            .environmentObject(SessionManager()) // Ensure SessionManager is passed as an environment object
            .environmentObject(BluetoothManager()) // Ensure BluetoothManager is passed as an environment object
    }
}
