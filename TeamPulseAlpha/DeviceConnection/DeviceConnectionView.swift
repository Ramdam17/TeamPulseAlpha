//
//  DeviceConnectionView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI
import Combine

/// A view that displays the connection status of sensors and provides options to navigate when all sensors are connected.
struct DeviceConnectionView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager // Access the BluetoothManager environment object
    @State private var connectionStatuses: [UUID: Bool] = [:] // Dictionary to track connection statuses of sensors by their UUIDs

    var body: some View {
        VStack {
            Text("Device Connection")
                .font(.largeTitle) // Set the font size of the title
                .padding() // Add padding around the title

            // List of sensors and their connection statuses
            List {
                ForEach(bluetoothManager.sensors) { sensor in
                    HStack {
                        Text("Sensor \(sensor.color)") // Display the color of the sensor
                        Spacer()
                        // Display the connection status of the sensor
                        Text(connectionStatuses[sensor.id] == true ? "Connected" : "Searching")
                            .foregroundColor(connectionStatuses[sensor.id] == true ? .green : .red)
                    }
                }
            }

            // Display scanning status or the "Go to Next Screen" button
            if bluetoothManager.isScanning {
                Text("Scanning for sensors...")
                    .padding()
            } else if connectionStatuses.values.allSatisfy({ $0 == true }) {
                // Show the button only if all sensors are connected
                Button(action: {
                    print("Navigating to the next screen")
                }) {
                    Text("Go to Next Screen")
                        .foregroundColor(.white) // Set the text color of the button
                        .padding() // Add padding around the button text
                        .background(Color.blue) // Set the background color of the button
                        .cornerRadius(10) // Round the corners of the button
                }
                .padding()
            } else {
                // Show a message if not all sensors are connected
                Text("Waiting for all sensors to connect...")
                    .padding()
            }
        }
        .onAppear {
            bluetoothManager.startScanning() // Start scanning for sensors when the view appears
            initializeConnectionStatuses() // Initialize the connection statuses
        }
        .onReceive(bluetoothManager.$sensors) { updatedSensors in
            updateConnectionStatuses(updatedSensors: updatedSensors) // Update the connection statuses when sensors array changes
        }
    }

    /// Initializes the connection statuses for all sensors.
    private func initializeConnectionStatuses() {
        // Create a dictionary mapping sensor UUIDs to their initial connection status
        connectionStatuses = Dictionary(uniqueKeysWithValues: bluetoothManager.sensors.map { ($0.id, $0.isConnected) })
        print("Initial Connection Statuses: \(connectionStatuses)")
    }

    /// Updates the connection statuses based on the latest sensor data.
    private func updateConnectionStatuses(updatedSensors: [SensorEntity]) {
        // Update the connection status for each sensor in the dictionary
        for sensor in updatedSensors {
            connectionStatuses[sensor.id] = sensor.isConnected
        }
        print("Updated Connection Statuses: \(connectionStatuses)")
    }
}

