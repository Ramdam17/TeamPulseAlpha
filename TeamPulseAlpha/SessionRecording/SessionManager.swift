//
//  SessionManager.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import Foundation
import CoreData

/// Manages the creation, management, and deletion of sessions within the TeamPulseAlpha app.
class SessionManager: ObservableObject {
    /// The currently active session, if any, published to notify observers.
    @Published var currentSession: SessionEntity?

    /// Starts a new session by creating a `SessionEntity` and setting it as the current session.
    func startNewSession() {
        let context = CoreDataStack.shared.context
        let newSession = SessionEntity(context: context)
        newSession.id = UUID() // Assign a unique identifier to the session.
        newSession.timestamp = Date() // Set the session's start timestamp to the current date/time.
        CoreDataStack.shared.saveContext() // Save the session in CoreData.
        currentSession = newSession // Set this as the current session.
    }

    /// Stops the current session, effectively ending it by clearing the session from the manager.
    func stopSession() {
        currentSession = nil // Set currentSession to `nil` to indicate no active session.
    }

    /// Saves sensor data associated with the current session.
    ///
    /// - Parameters:
    ///   - sensor: The sensor entity to associate the data with.
    ///   - hr: The heart rate value.
    ///   - instantaneousHR: The instantaneous heart rate (derived from IBI).
    ///   - ibi: The array of inter-beat intervals (IBI).
    ///   - distanceMatrix: The distance matrix computed between sensors.
    ///   - correlationMatrix: The correlation matrix computed between sensors.
    ///   - crossEntropyMatrix: The cross-entropy matrix computed between sensors.
    func saveData(for sensor: SensorEntity, hr: Int, instantaneousHR: Double, ibi: [Double], distanceMatrix: [[Double]], correlationMatrix: [[Double]], crossEntropyMatrix: [[Double]]) {
        // Ensure that there is an active session before saving data.
        guard let session = currentSession else { return }

        let event = EventEntity(context: CoreDataStack.shared.context)
        event.timestamp = Date() // Capture the current timestamp.
        event.eventType = "HR Data" // Mark this event type as heart rate data.
        event.hr = Double(hr) // Store the heart rate.
        event.instantaneousHR = instantaneousHR // Store the instantaneous HR.

        // Convert arrays into `Data` format using the ArrayTransformer.
        let arrayTransformer = ArrayTransformer()

        // Transform and assign the sensor data.
        event.ibi = arrayTransformer.transformedValue(ibi) as? Data
        event.distanceMatrix = arrayTransformer.transformedValue(distanceMatrix) as? Data
        event.correlationMatrix = arrayTransformer.transformedValue(correlationMatrix) as? Data
        event.crossEntropyMatrix = arrayTransformer.transformedValue(crossEntropyMatrix) as? Data

        // Associate the event with the current session.
        event.session = session

        // Save the context with the new event and session data.
        CoreDataStack.shared.saveContext()
    }

    /// Deletes the current session and all its associated events and data.
    func deleteCurrentSession() {
        if let session = currentSession {
            CoreDataStack.shared.context.delete(session) // Delete the session from CoreData.
            CoreDataStack.shared.saveContext() // Save the changes.
            currentSession = nil // Clear the current session.
        }
    }

    /// Fetches the list of saved sessions from CoreData for later review.
    ///
    /// - Returns: An array of `SessionEntity` objects representing saved sessions.
    func fetchSavedSessions() -> [SessionEntity] {
        let fetchRequest: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()
        do {
            // Attempt to fetch saved sessions from CoreData.
            return try CoreDataStack.shared.context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch sessions: \(error)") // Log any errors encountered during fetching.
            return []
        }
    }
}
