//
//  EventEntity+CoreDataProperties.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//
//

import Foundation
import CoreData

// Extension to define the properties and methods for the EventEntity Core Data model.
// EventEntity represents an event that occurs during a session, such as a heart rate measurement.
extension EventEntity {

    // Fetch request for retrieving EventEntity objects from the Core Data store.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventEntity> {
        return NSFetchRequest<EventEntity>(entityName: "EventEntity")
    }

    // The timestamp when the event occurred.
    @NSManaged public var timestamp: Date
    
    // The type of event (e.g., "heartRate", "stepCount").
    @NSManaged public var eventType: String
    
    // The data associated with the event (e.g., heart rate value, step count).
    @NSManaged public var data: Double
    
    // The session to which this event belongs.
    // This creates a relationship between EventEntity and SessionEntity.
    @NSManaged public var session: SessionEntity?
    
    // Optionally, additional methods or computed properties can be added here
    // to manipulate or format the event data as needed.
    
    // Example of a computed property (Optional):
    // var formattedData: String {
    //     return String(format: "%.2f", data)
    // }
}
