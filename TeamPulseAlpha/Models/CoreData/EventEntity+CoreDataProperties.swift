//
//  EventEntity+CoreDataProperties.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//
//

import Foundation
import CoreData

extension EventEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventEntity> {
        return NSFetchRequest<EventEntity>(entityName: "EventEntity")
    }

    @NSManaged public var timestamp: Date
    @NSManaged public var eventType: String
    @NSManaged public var data: Double
    @NSManaged public var session: SessionEntity?

}
