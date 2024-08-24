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
    @Environment(BluetoothManager.self) var bluetoothManager

    var body: some View {
        HStack(spacing: 20) {
            // Blue sensor status dot
            if let index = bluetoothManager.sensors.firstIndex(where: { $0.name == "Blue" }) {
                StatusDotView(isConnected: bluetoothManager.sensors[index].isConnected, color: .blue)

            }

            // Green sensor status dot
            if let index = bluetoothManager.sensors.firstIndex(where: { $0.name == "Green" }) {
                StatusDotView(isConnected: bluetoothManager.sensors[index].isConnected, color: .green)

            }

            // Red sensor status dot
            if let index = bluetoothManager.sensors.firstIndex(where: { $0.name == "Red" }) {
                StatusDotView(isConnected: bluetoothManager.sensors[index].isConnected, color: .red)
            }
        }
        .padding()  // Add padding around the HStack for better spacing.
    }
}

/// A reusable view component to display a status dot with a glowing effect.
struct StatusDotView: View {
    let isConnected: Bool
    let color: Color

    var body: some View {
        Circle()
            .fill(isConnected ? color : Color.gray)
            .frame(width: 20, height: 20)
            .overlay(
                Circle()
                    .stroke(color.opacity(isConnected ? 0.5 : 0.2), lineWidth: 4)
                    .blur(radius: isConnected ? 2 : 0)
            )
            .shadow(color: color.opacity(isConnected ? 0.7 : 0), radius: 10)
    }
}

// Preview provider for SwiftUI previews, allowing for real-time design feedback.
struct BluetoothStatusComponent_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            // iPhone 15 Pro Preview
            BluetoothStatusComponent()
                .environment(BluetoothManager())  // Provide a mock environment object for preview.
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
                .previewDisplayName("iPhone 15 Pro")

            // iPad Pro 11-inch Preview
            BluetoothStatusComponent()
                .environment(BluetoothManager())  // Provide a mock environment object for preview.
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (11-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 11-inch")

            // iPad Pro 13-inch Preview
            BluetoothStatusComponent()
                .environment(BluetoothManager())  // Provide a mock environment object for preview.
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (12.9-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 13-inch")
        }
    }
}
