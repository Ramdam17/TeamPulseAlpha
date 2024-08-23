//
//  SensorEntity+CoreDataProperties.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//
//

import Foundation
import CoreData

/// Extension of the `SensorEntity` class defining the properties and methods for interacting with sensor data stored in Core Data.
extension SensorEntity {

    /// A convenience method to create a fetch request for `SensorEntity` objects.
    ///
    /// - Returns: A fetch request configured to retrieve `SensorEntity` instances from the Core Data store.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SensorEntity> {
        return NSFetchRequest<SensorEntity>(entityName: "SensorEntity")
    }

    // MARK: - Core Data Properties
    
    /// The unique identifier of the sensor. Used to distinguish between different sensors in the database.
    @NSManaged public var id: UUID?

    /// The name of the sensor, such as "Blue", "Green", or "Red". Provides a user-friendly way to identify the sensor.
    @NSManaged public var name: String?

    /// A boolean flag indicating whether the sensor is currently connected. Helps manage the connection status in the app.
    @NSManaged public var isConnected: Bool

    /// The MAC address or UUID of the sensor, used to uniquely identify it during Bluetooth communication.
    @NSManaged public var uuid: String?

    /// The sessions associated with this sensor. Represents a one-to-many relationship between `SensorEntity` and `SessionEntity`.
    /// This allows you to track which sessions the sensor has been involved in.
    @NSManaged public var sessions: SessionEntity?
}

extension SensorEntity: Identifiable {
    // This extension makes SensorEntity conform to the Identifiable protocol,
    // which allows it to be easily used in SwiftUI views.
}
