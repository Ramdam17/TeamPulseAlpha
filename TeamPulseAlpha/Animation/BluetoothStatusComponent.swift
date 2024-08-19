//
//  BluetoothStatusComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import SwiftUI

/// A view that displays the Bluetooth connection status of all sensors managed by the `BluetoothManager`.
struct BluetoothStatusComponent: View {
    // Access the BluetoothManager from the environment to track sensor connection status.
    @EnvironmentObject var bluetoothManager: BluetoothManager

    var body: some View {
        VStack(alignment: .leading) {
            // Display the title for the Bluetooth status section.
            Text("Bluetooth Status")
                .font(.headline) // Set the font style for the headline

            // Iterate over the list of sensors managed by the BluetoothManager.
            ForEach(bluetoothManager.sensors) { sensor in
                HStack {
                    // Display the color of the sensor.
                    Text("Sensor \(sensor.color ?? "Unknown")")
                    Spacer() // Add space between the sensor color and the status text.
                    
                    // Display the connection status of the sensor.
                    Text(sensor.isConnected ? "Connected" : "Disconnected")
                        .foregroundColor(sensor.isConnected ? .green : .red) // Set the text color based on connection status.
                }
            }
        }
        .padding() // Add padding around the entire VStack for better spacing.
    }
}

// Preview provider for SwiftUI previews, allowing for real-time design feedback.
struct BluetoothStatusComponent_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothStatusComponent()
            .environmentObject(BluetoothManager()) // Provide a mock environment object for preview.
    }
}
