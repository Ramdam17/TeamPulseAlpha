//
//  SensorEntity+CoreDataClass.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//
//

import Foundation
import CoreData

// SensorEntity is a Core Data entity representing a sensor in the app.
// It inherits from NSManagedObject, allowing it to be managed by Core Data.
public class SensorEntity: NSManagedObject {

    // Custom behavior and methods for the SensorEntity can be added here if needed.
    // For example, you could add convenience methods to manipulate the entity's data
    // or computed properties to derive additional information from the entity's attributes.

    // Example of a computed property (optional):
    // var formattedMacAddress: String {
    //     // Format the MAC address if necessary (e.g., adding colons for readability)
    //     return macAddress
    // }
}
