//
//  SessionEntity+CoreDataProperties.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/24/24.
//
//

import Foundation
import CoreData


extension SessionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionEntity> {
        return NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
    }

    @NSManaged public var endTime: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var startTime: Date?
    @NSManaged public var clusterDataEvent: NSSet?
    @NSManaged public var matrixDataEvent: NSSet?
    @NSManaged public var sensorDataEvent: NSSet?

}

// MARK: Generated accessors for clusterDataEvent
extension SessionEntity {

    @objc(addClusterDataEventObject:)
    @NSManaged public func addToClusterDataEvent(_ value: ClusterDataEvent)

    @objc(removeClusterDataEventObject:)
    @NSManaged public func removeFromClusterDataEvent(_ value: ClusterDataEvent)

    @objc(addClusterDataEvent:)
    @NSManaged public func addToClusterDataEvent(_ values: NSSet)

    @objc(removeClusterDataEvent:)
    @NSManaged public func removeFromClusterDataEvent(_ values: NSSet)

}

// MARK: Generated accessors for matrixDataEvent
extension SessionEntity {

    @objc(addMatrixDataEventObject:)
    @NSManaged public func addToMatrixDataEvent(_ value: MatrixDataEvent)

    @objc(removeMatrixDataEventObject:)
    @NSManaged public func removeFromMatrixDataEvent(_ value: MatrixDataEvent)

    @objc(addMatrixDataEvent:)
    @NSManaged public func addToMatrixDataEvent(_ values: NSSet)

    @objc(removeMatrixDataEvent:)
    @NSManaged public func removeFromMatrixDataEvent(_ values: NSSet)

}

// MARK: Generated accessors for sensorDataEvent
extension SessionEntity {

    @objc(addSensorDataEventObject:)
    @NSManaged public func addToSensorDataEvent(_ value: SensorDataEvent)

    @objc(removeSensorDataEventObject:)
    @NSManaged public func removeFromSensorDataEvent(_ value: SensorDataEvent)

    @objc(addSensorDataEvent:)
    @NSManaged public func addToSensorDataEvent(_ values: NSSet)

    @objc(removeSensorDataEvent:)
    @NSManaged public func removeFromSensorDataEvent(_ values: NSSet)

}

extension SessionEntity : Identifiable {

}
