import CoreData
import Foundation

/// `SessionManager` is responsible for managing the creation, management, and deletion of sessions
/// within the TeamPulseAlpha app. This includes starting a new session, stopping a session,
/// and deleting a session along with its associated data.
@Observable
class SessionManager {

    /// The currently active session, if any.
    var currentSession: SessionEntity?
    var isRecording: Bool = false

    /// A timer to update the elapsed time
    private var timer: Timer?

    /// A property to store the elapsed time in seconds
    var elapsedTime: TimeInterval = 0 {
        willSet {
            // This triggers the view to update automatically.
            // The @Observable macro will handle updates to views.
        }
    }

    /// Computed property to get the current elapsed time for the active session
    private var startTime: Date? {
        return currentSession?.startTime
    }

    /// Starts a new session by creating a `SessionEntity` and setting it as the current session.
    /// The session is initialized with a unique identifier and the current timestamp.
    func startNewSession() {
        guard currentSession == nil else {
            print("Session already in progress. Please stop the current session before starting a new one.")
            return
        }
        let context = CoreDataStack.shared.context
        let newSession = SessionEntity(context: context)

        newSession.id = UUID()  // Assign a unique identifier to the session.
        newSession.startTime = Date()  // Set the session's start timestamp to the current date/time.

        // Format the date as "YY-MM-DD-HH-MM"
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd-HH-mm"
        newSession.name = formatter.string(from: newSession.startTime!)

        CoreDataStack.shared.saveContext()  // Save the new session in CoreData.
        currentSession = newSession  // Set this as the active session.
        isRecording = true

        startTimer()
    }

    /// Stops the current session, effectively marking the session as inactive
    /// by clearing the `currentSession` property.
    func stopSession() {
        currentSession?.endTime = Date()  // Record the end time of the session.
        CoreDataStack.shared.saveContext()  // Save the updated session.
        currentSession = nil  // Clear the current session to indicate no active session.
        isRecording = false

        stopTimer()
    }

    /// Deletes the current session and all its associated data from Core Data.
    /// This operation cannot be undone.
    func deleteCurrentSession() {
        guard let session = currentSession else { return }  // Ensure there's a session to delete.
        let context = CoreDataStack.shared.context

        context.delete(session)
        CoreDataStack.shared.saveContext()  // Save the context to commit the delete operation.
        
        currentSession = nil
        isRecording = false

        stopTimer()
    }

    /// Deletes all sessions and their associated events from Core Data.
    func deleteAllSessions() {
        let context = CoreDataStack.shared.context

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = SessionEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()

            currentSession = nil
            isRecording = false

            print("All sessions and their associated events have been successfully deleted.")
        } catch {
            print("Failed to delete all sessions: \(error)")
        }
    }

    /// Starts the timer to update the elapsed time
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime)
        }
    }

    /// Stops the timer
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
