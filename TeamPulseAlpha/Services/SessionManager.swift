//
//  SessionManager.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 24/07/2024.
//

import CoreData
import Foundation

/// `SessionManager` is responsible for managing the creation, management, and deletion of sessions
/// within the TeamPulseAlpha app. This includes starting a new session, stopping a session,
/// and deleting a session along with its associated data.
@Observable
class SessionManager {
    
    /// The currently active session, if any. This is published to notify observers of changes.
    var currentSession: SessionEntity?
    
    /// Starts a new session by creating a `SessionEntity` and setting it as the current session.
    /// The session is initialized with a unique identifier and the current timestamp.
    func startNewSession() {
        let context = CoreDataStack.shared.context
        let newSession = SessionEntity(context: context)
        
        newSession.id = UUID()  // Assign a unique identifier to the session.
        newSession.timestamp = Date()  // Set the session's start timestamp to the current date/time.
        
        CoreDataStack.shared.saveContext()  // Save the new session in CoreData.
        currentSession = newSession  // Set this as the active session.
    }

    /// Stops the current session, effectively marking the session as inactive
    /// by clearing the `currentSession` property.
    func stopSession() {
        currentSession = nil  // Clear the current session to indicate no active session.
    }

    /// Deletes the current session and all its associated data from Core Data.
    /// This operation cannot be undone.
    func deleteCurrentSession() {
        guard let session = currentSession else { return }  // Ensure there's a session to delete.
        let context = CoreDataStack.shared.context

        // Delete the session and all associated events due to the cascade delete rule.
        context.delete(session)

        // Save the context to commit the delete operation to the Core Data store.
        do {
            try context.save()
        } catch {
            print("Failed to delete session and its events: \(error)")
        }

        // Clear the current session to reflect that it has been deleted.
        currentSession = nil
    }

    /// Saves the sensor data during the session to Core Data.
    /// This function would typically involve saving sensor readings, events, or other session-related data.
    ///
    /// - Parameter sensor: The sensor entity whose data is being saved.
    func saveData(for sensor: SensorEntity) {
        // Placeholder function for saving sensor data to the current session.
        // Uncomment and implement when ready.
        // guard let session = currentSession else { return }
        // sensorDataProcessor.saveDataToCoreData(session: session, sensorID: sensor.id!)
    }
}
