//
//  EventEntity+CoreDataClass.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//
//

import Foundation
import CoreData

// EventEntity is a Core Data class that represents an event in the TeamPulseAlpha app.
// Each instance of EventEntity corresponds to a specific event, such as a heart rate measurement,
// that occurs during a session. This class is linked to the EventEntity entity defined in the Core Data model.
public class EventEntity: NSManagedObject {

    // Additional methods and properties specific to EventEntity can be added here.
    // For example, you might add methods to calculate derived data or format values.
    
    // Example (Optional):
    // func formattedEventDetails() -> String {
    //     return "\(eventType): \(data) at \(timestamp)"
    // }
}
