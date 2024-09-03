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

    @State private var connectionStatus: [UUID: Bool] = [:]  // Tracks the connection status of sensors

    var body: some View {
        VStack {
            VStack(spacing: 20) {

                // Title for the device connection screen
                Text("Device Connection")

                    .font(UIDevice.current.orientation.isLandscape ? .largeTitle : .title)  // Set the font size of the title
                    .padding()  // Add padding around the title

                // White rounded container around the sensor connection information

                Spacer()

                ForEach(bluetoothManager.sensors.compactMap { $0 }) { sensor in
                    if let sensorID = sensor.id {  // Safely unwrap sensor's ID
                        HStack {
                            Text("\(sensor.name ?? "Unknown") Sensor")
                                .foregroundStyle(Color(
                                    sensor.name == "Blue" ? .blue :
                                        sensor.name == "Green" ? .green : .red
                                
                                ))
                            // Display the name of the sensor
                            Spacer()
                            // Display the connection status of the sensor
                            Text(
                                connectionStatus[sensorID] == true
                                    ? "Connected" : "Searching"
                            )
                            .foregroundColor(
                                connectionStatus[sensorID] == true
                                    ? .black : .gray)
                            .italic(connectionStatus[sensorID] == false)
                            
                        }
                        .padding(.horizontal, UIDevice.current.orientation.isLandscape ? 80 : 10)
                    }
                }

                Spacer()

                // Display scanning status or the "Go to Next Screen" button
                if bluetoothManager.isScanning {
                    Text("Scanning for sensors...")
                        .foregroundStyle(Color("CustomDarkGrey"))
                        .padding()
                } else if connectionStatus.values.allSatisfy({ $0 == true }) {
                    // Show the button only if all sensors are connected
                    NavigationLink(destination: AnimationView()) {
                        Text("Go to Animation")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)  // Ensure the button takes the full width
                            .background(Color(.black))  // Grey background color for the button
                            .cornerRadius(10)
                    }
                    .padding()
                } else {
                    // Show a message if not all sensors are connected
                    Text("Waiting for all sensors to connect...")
                        .foregroundStyle(Color("CustomDarkGrey"))
                        .padding()
                }
            }
            .padding(20)
            .frame(
                maxWidth: UIDevice.current.orientation.isLandscape ? UIScreen.main.bounds.width / 2.5 : UIScreen.main.bounds.width * 0.8,
                maxHeight: UIScreen.main.bounds.height / 2
            )
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // Ensure the VStack takes up the full screen width
        .background(Color.yellow)  // Set background color for the entire view
        .edgesIgnoringSafeArea(.all)  // Extend the background to the edges of the screen
        .onAppear {
            bluetoothManager.resetSensorConnections()
            bluetoothManager.startScanning()  // Start scanning for sensors when the view appears
            initializeConnectionStatus()  // Initialize the connection status of sensors
        }
        .onChange(of: bluetoothManager.isUpdated) { _, _ in
            updateConnectionStatus()  // Update the connection status when the BluetoothManager reports changes
        }
    }

    /// Initializes the connection status dictionary with the current sensor states.
    private func initializeConnectionStatus() {
        connectionStatus = [:]
        for sensor in bluetoothManager.sensors {
            if let sensorID = sensor.id {
                connectionStatus[sensorID] = sensor.isConnected
            }
        }
    }

    /// Updates the connection status dictionary with the latest sensor states.
    private func updateConnectionStatus() {
        for sensor in bluetoothManager.sensors {
            if let sensorID = sensor.id {
                connectionStatus[sensorID] = sensor.isConnected
            }
        }
    }
}

// Preview provider for DeviceConnectionView
struct DeviceConnectionView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            // iPhone 15 Pro Preview
            DeviceConnectionView()
                .environment(BluetoothManager())  // Provide a mock BluetoothManager for preview
                .environment(SensorDataProcessor())  // Provide a mock SensorDataProcessor for preview
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
                .previewDisplayName("iPhone 15 Pro")

            // iPad Pro 11-inch Preview
            DeviceConnectionView()
                .environment(BluetoothManager())  // Provide a mock BluetoothManager for preview
                .environment(SensorDataProcessor())  // Provide a mock SensorDataProcessor for preview
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (11-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 11-inch")

            // iPad Pro 13-inch Preview
            DeviceConnectionView()
                .environment(BluetoothManager())  // Provide a mock BluetoothManager for preview
                .environment(SensorDataProcessor())  // Provide a mock SensorDataProcessor for preview
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (12.9-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 13-inch")
        }
    }
}
