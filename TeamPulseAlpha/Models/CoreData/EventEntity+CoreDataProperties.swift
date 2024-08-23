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
    
    /// The type of event (e.g., "HR Data"). This property categorizes the event.
    @NSManaged public var eventType: String?

    /// The timestamp indicating when the event occurred.
    @NSManaged public var timestamp: Date?

    /// The recorded heart rate (HR) as a `Double`.
    @NSManaged public var hr: Double

    /// The Inter-Beat Interval (IBI) data, stored as binary `Data`. This data typically consists of an array of doubles.
    @NSManaged public var ibi: Data?

    /// The distance matrix data, stored as binary `Data`. Represents the pairwise distance between sensor data points.
    @NSManaged public var distanceMatrix: Data?

    /// The correlation matrix data, stored as binary `Data`. Represents the correlation coefficients between different sensors' data.
    @NSManaged public var correlationMatrix: Data?

    /// The cross-entropy matrix data, stored as binary `Data`. Used for calculating dissimilarities between probability distributions.
    @NSManaged public var crossEntropyMatrix: Data?

    /// The mutual information matrix data, stored as binary `Data`. Represents shared information between sensors' data.
    @NSManaged public var mutualInformationMatrix: Data?

    /// The threshold value used for cluster determination, stored as a `Double`.
    @NSManaged public var threshold: Double

    /// The proximity matrix data, stored as binary `Data`. Represents the proximity scores between different sensor data points.
    @NSManaged public var proximityMatrix: Data?

    /// The soft clusters data, stored as binary `Data`. Represents clusters where sensors are loosely grouped based on proximity.
    @NSManaged public var softClusters: Data?

    /// The hard clusters data, stored as binary `Data`. Represents clusters where sensors are tightly grouped based on proximity.
    @NSManaged public var hardClusters: Data?

    /// The relationship to the `SessionEntity` that this event is associated with.
    /// Allows for linking events to specific recording sessions.
    @NSManaged public var session: SessionEntity?

}

/// Extends `EventEntity` to conform to the `Identifiable` protocol, which helps in working with lists in SwiftUI.
extension EventEntity: Identifiable {}
