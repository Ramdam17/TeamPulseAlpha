//
//  SensorEntity+CoreDataProperties.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//
//
import Foundation
import CoreData

extension SensorEntity: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SensorEntity> {
        return NSFetchRequest<SensorEntity>(entityName: "SensorEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var macAddress: String
    @NSManaged public var color: String
    @NSManaged public var isConnected: Bool
    @NSManaged public var sessions: NSSet?

}

// MARK: Generated accessors for sessions
extension SensorEntity {

    @objc(addSessionsObject:)
    @NSManaged public func addToSessions(_ value: SessionEntity)

    @objc(removeSessionsObject:)
    @NSManaged public func removeFromSessions(_ value: SessionEntity)

    @objc(addSessions:)
    @NSManaged public func addToSessions(_ values: NSSet)

    @objc(removeSessions:)
    @NSManaged public func removeFromSessions(_ values: NSSet)

}
