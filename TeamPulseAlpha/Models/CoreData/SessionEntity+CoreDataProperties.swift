//
//  SessionEntity+CoreDataProperties.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//
//

import Foundation
import CoreData

/// Extension to define the properties of the `SessionEntity` class.
/// This is generated automatically by Core Data based on the data model.
extension SessionEntity {

    /// Fetch request for retrieving `SessionEntity` objects from Core Data.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionEntity> {
        return NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
    }

    /// Unique identifier for the session.
    @NSManaged public var id: UUID?

    /// Timestamp indicating when the session was started.
    @NSManaged public var timestamp: Date?

    /// The associated events data for this session.
    @NSManaged public var events: EventEntity?

    /// The associated sensors for this session.
    @NSManaged public var sensors: SensorEntity?
}

/// Conforms `SessionEntity` to the `Identifiable` protocol to provide a stable identity for use in lists and other SwiftUI views.
extension SessionEntity: Identifiable {
}
