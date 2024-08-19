//
//  Sensor.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 24/07/2024.
//

import Foundation

// The Sensor struct represents a lightweight model of a sensor, typically used
// for scenarios where a full Core Data object isn't necessary.
// It conforms to the Identifiable protocol, making it easy to use in SwiftUI lists.
struct Sensor: Identifiable {
    
    // The unique identifier for the sensor, represented as a UUID.
    let id: UUID
    
    // The MAC address of the sensor, stored as a String.
    let macAddress: String
    
    // A Boolean indicating whether the sensor is currently connected.
    // This property is mutable, meaning it can be updated after the sensor is created.
    var isConnected: Bool = false
    
    // Additional functionality or computed properties can be added here as needed.
    // For example, you might add a method to update the sensor's connection status.
    
    // Example (Optional):
    // mutating func updateConnectionStatus(isConnected: Bool) {
    //     self.isConnected = isConnected
    // }
}
