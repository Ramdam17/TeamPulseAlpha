//
//  SensorDataEvent+CoreDataProperties.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/24/24.
//
//

import Foundation
import CoreData


extension SensorDataEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SensorDataEvent> {
        return NSFetchRequest<SensorDataEvent>(entityName: "SensorDataEvent")
    }

    @NSManaged public var hrData: Double
    @NSManaged public var hrvData: Double
    @NSManaged public var ibiData: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var sensor: SensorEntity?
    @NSManaged public var session: SessionEntity?

}

extension SensorDataEvent : Identifiable {

}
