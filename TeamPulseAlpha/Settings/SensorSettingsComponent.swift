//
//  SensorSettingsComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/25/24.
//

import CoreData
import SwiftUI

/// A view component responsible for managing the sensors' UUID settings.
struct SensorSettingsComponent: View {

    @State private var showModalForSensor: SensorType? = nil  // Keeps track of which sensor modal to show
    @State private var showResetAlert = false  // State to manage showing the reset alert

    var body: some View {

        VStack {
            Text("Sensors UUID Management")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 30)

            // Clickable text for Blue sensor
            sensorOption(text: "Update Blue Sensor UUID", color: .blue)
                .onTapGesture {
                    showModalForSensor = .blue
                }
                .sheet(item: $showModalForSensor) { sensor in
                    SensorUUIDModal(sensorType: sensor)
                }

            // Clickable text for Green sensor
            sensorOption(text: "Update Green Sensor UUID", color: .green)
                .onTapGesture {
                    showModalForSensor = .green
                }
                .sheet(item: $showModalForSensor) { sensor in
                    SensorUUIDModal(sensorType: sensor)
                }

            // Clickable text for Red sensor
            sensorOption(text: "Update Red Sensor UUID", color: .red)
                .onTapGesture {
                    showModalForSensor = .red
                }
                .sheet(item: $showModalForSensor) { sensor in
                    SensorUUIDModal(sensorType: sensor)
                }

            // Clickable text to reset all sensors UUID
            HStack {
                Text("Reset all sensors UUID")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            .onTapGesture {
                showResetAlert = true
            }
            .alert(isPresented: $showResetAlert) {
                Alert(
                    title: Text("Reset All UUIDs"),
                    message: Text(
                        "Are you sure you want to reset all sensors UUIDs to their default values?"
                    ),
                    primaryButton: .destructive(Text("Reset")) {
                        resetAllSensorsUUID()
                    },
                    secondaryButton: .cancel()
                )
            }
            .padding(.top, 40)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }

    /// Function to create a sensor option view with colored text and a matching border
    private func sensorOption(text: String, color: Color) -> some View {
        HStack {
            Text(text)
                .foregroundColor(color)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color, lineWidth: 1)
                )
        }
    }

    /// Placeholder function to reset all sensors UUID to default values
    private func resetAllSensorsUUID() {
        // Implement your logic to reset the UUIDs here
        DataManager.shared.resetSensors()
        print("Resetting all sensors UUIDs to default values.")
    }
}

// Enum to define the sensor types
enum SensorType: Identifiable {
    case blue, green, red

    var id: Int {
        hashValue
    }
}

// A modal view for displaying and selecting the UUID
struct SensorUUIDModal: View {
    var sensorType: SensorType
    @Environment(\.presentationMode) var presentationMode
    @Environment(BluetoothManager.self) var bluetoothManager  // Use the environment object for BluetoothManager
    @State private var foundDevices: [(name: String, uuid: String)] = []

    var body: some View {

        VStack {
            Text("Select UUID for \(sensorType.name)")
                .font(.headline)
                .padding()

            // List of found devices
            ScrollView {
                VStack {
                    ForEach(foundDevices, id: \.uuid) { device in
                        HStack {
                            Text(device.name)
                                .frame(width: 80)
                            Spacer()
                            Text(device.uuid)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .onTapGesture {
                            DataManager.shared.updateSensorUUID(
                                name: sensorType.name, newUUID: device.uuid)
                            presentationMode.wrappedValue.dismiss()
                        }
                        Divider()
                    }
                }
            }
            .padding()

            Spacer()

            Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            startScanning()
        }
        .onDisappear {
            bluetoothManager.stopScanning()
        }
    }

    /// Start scanning for peripherals without autoconnecting
    private func startScanning() {
        bluetoothManager.startScanning(autoconnect: false)
        // Simulate discovering peripherals
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.foundDevices = bluetoothManager.discoveredPeripherals.map {
                ($0.value.name ?? "Unknown", $0.key)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.foundDevices = bluetoothManager.discoveredPeripherals.map {
                ($0.value.name ?? "Unknown", $0.key)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.foundDevices = bluetoothManager.discoveredPeripherals.map {
                ($0.value.name ?? "Unknown", $0.key)
            }
            bluetoothManager.stopScanning()
        }
    }
}

extension SensorType {
    var name: String {
        switch self {
        case .blue: return "Blue Sensor"
        case .green: return "Green Sensor"
        case .red: return "Red Sensor"
        }
    }
}

// Preview provider
struct SensorSettingsComponent_Previews: PreviewProvider {
    static var previews: some View {
        SensorSettingsComponent()
            .environment(BluetoothManager())  // Injecting the BluetoothManager as an environment object
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
