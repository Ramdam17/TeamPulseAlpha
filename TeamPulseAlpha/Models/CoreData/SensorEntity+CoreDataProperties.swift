//
//  SensorEntity+CoreDataProperties.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//
//

import Foundation
import CoreData

// This extension to SensorEntity defines the properties and relationships for the Core Data entity.
// The properties are managed by Core Data, and the relationships to other entities (such as SessionEntity)
// are also handled here.
extension SensorEntity: Identifiable {

    // A non-optional class function to create a fetch request for the SensorEntity.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SensorEntity> {
        return NSFetchRequest<SensorEntity>(entityName: "SensorEntity")
    }

    // The unique identifier for each sensor.
    @NSManaged public var id: UUID
    
    // The MAC address of the sensor as a String.
    @NSManaged public var macAddress: String
    
    // The color associated with the sensor (e.g., "Blue", "Green", "Red").
    @NSManaged public var color: String
    
    // A Boolean indicating whether the sensor is currently connected.
    @NSManaged public var isConnected: Bool
    
    // A set of sessions associated with this sensor. NSSet is used to represent a one-to-many relationship.
    @NSManaged public var sessions: NSSet?

}

// MARK: - Accessor Methods for Sessions

// This extension provides generated accessor methods to manage the relationship between
// SensorEntity and SessionEntity. These methods allow you to add or remove SessionEntity objects
// from the relationship.
extension SensorEntity {

    // Adds a single SessionEntity to the sessions set.
    @objc(addSessionsObject:)
    @NSManaged public func addToSessions(_ value: SessionEntity)

    // Removes a single SessionEntity from the sessions set.
    @objc(removeSessionsObject:)
    @NSManaged public func removeFromSessions(_ value: SessionEntity)

    // Adds multiple SessionEntity objects to the sessions set.
    @objc(addSessions:)
    @NSManaged public func addToSessions(_ values: NSSet)

    // Removes multiple SessionEntity objects from the sessions set.
    @objc(removeSessions:)
    @NSManaged public func removeFromSessions(_ values: NSSet)

}
