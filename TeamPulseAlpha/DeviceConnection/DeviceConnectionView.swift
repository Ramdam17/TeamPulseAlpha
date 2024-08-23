//
//  DeviceConnectionView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import Combine
import SwiftUI

/// A view that displays the connection status of sensors and provides options to navigate when all sensors are connected.
struct DeviceConnectionView: View {

    @Environment(BluetoothManager.self) var bluetoothManager  // Access the BluetoothManager from the environment
    @Environment(SensorDataProcessor.self) var sensorDataProcessor  // Access the SensorDataProcessor from the environment

    @State var connectionStatus: [UUID: Bool] = [:]

    var body: some View {
        VStack {
            Text("Device Connection")
                .font(.largeTitle)  // Set the font size of the title
                .padding()  // Add padding around the title

            // List of sensors and their connection statuses
            List {
                ForEach(bluetoothManager.sensors.compactMap { $0 }) { sensor in
                    if let sensorID = sensor.id {  // Safely unwrap sensor's ID
                        HStack {
                            Text("Sensor \(sensor.name ?? "Unknown")")  // Display the color of the sensor
                            Spacer()
                            // Display the connection status of the sensor
                            Text(
                                connectionStatus[sensor.id!] == true
                                    ? "Connected" : "Searching"
                            )
                            .foregroundColor(
                                connectionStatus[sensor.id!] == true
                                    ? .green : .red)
                        }
                    }
                }
            }

            // Display scanning status or the "Go to Next Screen" button
            if bluetoothManager.isScanning {
                Text("Scanning for sensors ...")
                    .padding()
            } else if connectionStatus.values.allSatisfy({ $0 == true }) {
                // Show the button only if all sensors are connected
                NavigationLink(destination: AnimationView()) {
                    Text("Go to Animation")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            } else {
                // Show a message if not all sensors are connected
                Text("Waiting for all sensors to connect...")
                    .padding()
            }
        }
        .onAppear {
            bluetoothManager.startScanning()  // Start scanning for sensors when the view appears
            initializeConnectionStatus()
        }
        .onChange(of: bluetoothManager.isUpdated) { _, _ in
            updateConnectionStatus()
        }

    }

    private func initializeConnectionStatus() {
        for sensor in bluetoothManager.sensors {
            connectionStatus[sensor.id!] = sensor.isConnected
        }
    }

    private func updateConnectionStatus() {
        connectionStatus = [:]
        for sensor in bluetoothManager.sensors {
            connectionStatus[sensor.id!] = sensor.isConnected
        }
    }

}
