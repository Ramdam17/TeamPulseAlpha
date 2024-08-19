//
//  SessionEntity+CoreDataClass.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//
//

import Foundation
import CoreData

// SessionEntity is a Core Data entity representing a session in the app.
// It inherits from NSManagedObject, which allows it to be managed by Core Data.
public class SessionEntity: NSManagedObject {

    // Custom behavior and methods for the SessionEntity can be added here if needed.
    // For example, you could add convenience methods to manipulate the entity's data
    // or computed properties to derive additional information from the entity's attributes.

    // Example of a computed property (not necessary but illustrative):
    // var formattedTimestamp: String {
    //     let formatter = DateFormatter()
    //     formatter.dateStyle = .short
    //     formatter.timeStyle = .short
    //     return formatter.string(from: self.timestamp)
    // }
}

