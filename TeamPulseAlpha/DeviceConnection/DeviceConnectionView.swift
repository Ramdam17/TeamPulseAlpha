//
//  DeviceConnectionView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

struct DeviceConnectionView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State private var sensorsFound: Int = 0

    var body: some View {
        VStack {
            Text("Device Connection")
                .font(.largeTitle)
                .padding()

            List {
                ForEach(bluetoothManager.sensors) { sensor in
                    HStack {
                        Text("Sensor \(sensor.color)")
                        Spacer()
                        Text(sensor.isConnected ? "Found" : "Searching")
                            .foregroundColor(sensor.isConnected ? .green : .red)
                    }
                }
            }

            if bluetoothManager.isScanning {
                Text("Scanning for sensors...")
                    .padding()
            }

            if sensorsFound == bluetoothManager.sensors.count {
                Button(action: {
                    bluetoothManager.connectToSensors()
                }) {
                    Text("Connect to Sensors")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .onAppear {
            bluetoothManager.startScanning()
        }
        .onChange(of: bluetoothManager.sensors) {
            sensorsFound = bluetoothManager.sensors.filter { $0.isConnected }.count
        }
    }
}
