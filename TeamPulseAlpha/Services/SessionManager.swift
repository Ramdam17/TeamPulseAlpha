//
//  SessionManager.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import CoreData
import Foundation

/// Manages the creation, management, and deletion of sessions within the TeamPulseAlpha app.
@Observable
class SessionManager {
    
    /// The currently active session, if any, published to notify observers.
    var currentSession: SessionEntity?
    
    /// Starts a new session by creating a `SessionEntity` and setting it as the current session.
    func startNewSession() {
        let context = CoreDataStack.shared.context
        let newSession = SessionEntity(context: context)
        
        newSession.id = UUID()  // Assign a unique identifier to the session.
        newSession.timestamp = Date()  // Set the session's start timestamp to the current date/time.
        
        CoreDataStack.shared.saveContext()  // Save the session in CoreData.
        currentSession = newSession  // Set this as the current session.
    }

    /// Stops the current session, effectively ending it by clearing the session from the manager.
    func stopSession() {
        currentSession = nil  // Set currentSession to `nil` to indicate no active session.
    }

    /// Deletes the current session and all its associated data from Core Data.
    func deleteCurrentSession() {
        guard let session = currentSession else { return }
        let context = CoreDataStack.shared.context

        // Delete the session and all associated events due to cascade delete rule.
        context.delete(session)

        // Save the context to commit the delete operation.
        do {
            try context.save()
        } catch {
            print("Failed to delete session and its events: \(error)")
        }

        // Clear the current session.
        currentSession = nil
    }

    /// Saves the sensor data during the session to Core Data.
    ///
    /// - Parameter sensor: The sensor entity whose data is being saved.
    func saveData(for sensor: SensorEntity) {
        //guard let session = currentSession else { return }
        //sensorDataProcessor.saveDataToCoreData(session: session, sensorID: sensor.id!)
    }
}
