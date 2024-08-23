//
//  SensorEntity+CoreDataProperties.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//
//

import Foundation
import CoreData

extension SensorEntity {

    /// A convenience method to create a fetch request for `SensorEntity` objects.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SensorEntity> {
        return NSFetchRequest<SensorEntity>(entityName: "SensorEntity")
    }

    /// The unique identifier of the sensor.
    @NSManaged public var id: UUID?

    /// The nameof the sensor.
    @NSManaged public var name: String?

    /// A boolean flag indicating whether the sensor is currently connected.
    @NSManaged public var isConnected: Bool

    /// The MAC address of the sensor, used to uniquely identify it during Bluetooth communication.
    @NSManaged public var uuid: String?

    /// The sessions associated with this sensor. This represents a one-to-many relationship between `SensorEntity` and `SessionEntity`.
    @NSManaged public var sessions: SessionEntity?
}

extension SensorEntity : Identifiable {
    // This extension makes SensorEntity conform to the Identifiable protocol,
    // which allows it to be easily used in SwiftUI views.
}
