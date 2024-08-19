//
//  SessionEntity+CoreDataProperties.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//
//

import Foundation
import CoreData

// This extension to SessionEntity defines the properties and relationships for the Core Data entity.
// The properties are managed by Core Data, and the relationships to other entities (such as EventEntity)
// are also handled here.
extension SessionEntity {

    // A non-optional class function to create a fetch request for the SessionEntity.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionEntity> {
        return NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
    }

    // The unique identifier for each session.
    @NSManaged public var id: UUID
    
    // The timestamp when the session was created.
    @NSManaged public var timestamp: Date
    
    // The sensor associated with this session. It's an optional relationship, meaning a session may or may not have a sensor.
    @NSManaged public var sensor: SensorEntity?
    
    // A set of events associated with this session. NSSet is used to represent a one-to-many relationship.
    @NSManaged public var events: NSSet?
}

// MARK: - Accessor Methods for Events

// This extension provides generated accessor methods to manage the relationship between
// SessionEntity and EventEntity. These methods allow you to add or remove EventEntity objects
// from the relationship.
extension SessionEntity {

    // Adds a single EventEntity to the events set.
    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: EventEntity)

    // Removes a single EventEntity from the events set.
    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: EventEntity)

    // Adds multiple EventEntity objects to the events set.
    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    // Removes multiple EventEntity objects from the events set.
    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}
