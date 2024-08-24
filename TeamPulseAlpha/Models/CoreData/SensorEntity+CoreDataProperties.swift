//
//  SensorEntity+CoreDataProperties.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/24/24.
//
//

import Foundation
import CoreData


extension SensorEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SensorEntity> {
        return NSFetchRequest<SensorEntity>(entityName: "SensorEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isConnected: Bool
    @NSManaged public var name: String?
    @NSManaged public var uuid: String?
    @NSManaged public var sensorDataEvent: NSSet?

}

// MARK: Generated accessors for sensorDataEvent
extension SensorEntity {

    @objc(addSensorDataEventObject:)
    @NSManaged public func addToSensorDataEvent(_ value: SensorDataEvent)

    @objc(removeSensorDataEventObject:)
    @NSManaged public func removeFromSensorDataEvent(_ value: SensorDataEvent)

    @objc(addSensorDataEvent:)
    @NSManaged public func addToSensorDataEvent(_ values: NSSet)

    @objc(removeSensorDataEvent:)
    @NSManaged public func removeFromSensorDataEvent(_ values: NSSet)

}

extension SensorEntity : Identifiable {

}
