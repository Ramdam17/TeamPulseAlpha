//
//  SessionEntity+CoreDataProperties.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//
//

import Foundation
import CoreData

extension SessionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionEntity> {
        return NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var sensor: SensorEntity?
    @NSManaged public var events: NSSet?

}

// MARK: Generated accessors for events
extension SessionEntity {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: EventEntity)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: EventEntity)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}
