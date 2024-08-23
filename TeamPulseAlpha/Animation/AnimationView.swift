//
//  AnimationComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import SwiftUI

/// The main view for displaying animation and related components like Bluetooth status, dashboard, and session management.
struct AnimationView: View {

    // Access the SensorDataProcessor from the environment to use the sensor data in the view.
    @Environment(SensorDataProcessor.self) var sensorDataProcessor
    @Environment(BluetoothManager.self) var bluetoothManager

    var body: some View {
        ScrollView {  // Wrap the entire content in a ScrollView for scrollable content
            VStack {
                // Animation Component placeholder (this will display the actual animation)
                AnimationComponent()
                    .padding()

                // Bluetooth Connection Status Component
                BluetoothStatusComponent()
                    .padding()

                // Dashboard Component - showing charts and stats related to the sensor data
                DashboardComponent()
                    .padding()

                // Session Recording Management Component
                SessionRecordingComponent()
                    .padding(.top, 20)
            }
            .navigationBarTitle("Animation", displayMode: .inline)
        }
        .onChange(of: bluetoothManager.hasNewValues) { oldValue, newValue in
            // Trigger sensor data update when new Bluetooth values are received
            if oldValue == false && newValue == true {
                let valuesToUnpack = bluetoothManager.getLatestValues()
                sensorDataProcessor.updateHRData(
                    sensorID: valuesToUnpack.id,
                    hr: valuesToUnpack.hr,
                    ibiArray: valuesToUnpack.ibis
                )
            }
        }
    }
}

// Preview provider for AnimationView
struct AnimationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Embed in NavigationView for correct navigation bar behavior in preview
            AnimationView()
                .environment(SensorDataProcessor()) // Inject a mock SensorDataProcessor
                .environment(BluetoothManager()) // Inject a mock BluetoothManager
                .environment(SessionManager()) // Inject a mock SessionManager
        }
    }
}
