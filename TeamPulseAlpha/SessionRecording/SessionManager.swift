//
//  SessionManager.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import CoreData
import Foundation

/// Manages the creation, management, and deletion of sessions within the TeamPulseAlpha app.
class SessionManager: ObservableObject {
    /// The currently active session, if any, published to notify observers.
    @Published var currentSession: SessionEntity?
    var sensorDataProcessor: SensorDataProcessor

    init(sensorDataProcessor: SensorDataProcessor) {
        self.sensorDataProcessor = sensorDataProcessor
    }

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

    /// Deletes the current session and all its associated data.
    func deleteCurrentSession() {
        if let session = currentSession {
            let context = CoreDataStack.shared.context

            // Deleting the session will also delete all associated events due to the cascade delete rule.
            context.delete(session)

            // Save the context to commit the delete operation.
            do {
                try context.save()
            } catch {
                print("Failed to delete session and its events: \(error)")
            }

            currentSession = nil
        }
    }

    /// Save data for a sensor during the session.
    func saveData(for sensor: SensorEntity) {
        guard let session = currentSession else { return }
        sensorDataProcessor.saveDataToCoreData(
            session: session, sensorID: sensor.id!)
    }
}
