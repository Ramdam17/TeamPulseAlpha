//
//  EventEntity+CoreDataProperties.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//
//

import Foundation
import CoreData

/// This extension of the `EventEntity` class defines the properties that are stored in the Core Data model.
/// It also provides a fetch request method for retrieving instances of `EventEntity`.
extension EventEntity {

    /// A class method to create a fetch request for `EventEntity`.
    ///
    /// - Returns: A fetch request for `EventEntity` instances.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventEntity> {
        return NSFetchRequest<EventEntity>(entityName: "EventEntity")
    }

    // MARK: - Core Data Properties
    
    /// The type of event (e.g., "HR Data").
    @NSManaged public var eventType: String?

    /// The timestamp indicating when the event occurred.
    @NSManaged public var timestamp: Date?

    /// The recorded heart rate (HR) as a `Double`.
    @NSManaged public var hr: Double

    /// The instantaneous heart rate (HR) as a `Double`.
    @NSManaged public var instantaneousHR: Double

    /// The Inter-Beat Interval (IBI) data, stored as binary `Data`.
    @NSManaged public var ibi: Data?

    /// The distance matrix data, stored as binary `Data`.
    @NSManaged public var distanceMatrix: Data?

    /// The correlation matrix data, stored as binary `Data`.
    @NSManaged public var correlationMatrix: Data?

    /// The cross-entropy matrix data, stored as binary `Data`.
    @NSManaged public var crossEntropyMatrix: Data?

    /// The relationship to the `SessionEntity` that this event is associated with.
    @NSManaged public var session: SessionEntity?

}

extension EventEntity: Identifiable {

}
