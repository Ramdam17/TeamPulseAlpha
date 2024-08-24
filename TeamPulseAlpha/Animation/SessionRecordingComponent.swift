//
//  SessionRecordingComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import SwiftUI

/// A view component responsible for managing the session recording process, including start, stop, save, and delete actions.
struct SessionRecordingComponent: View {
    @Environment(SessionManager.self) var sessionManager // Access the SessionManager from the environment
    @Environment(SensorDataProcessor.self) var sensorDataProcessor // Access the SensorDataProcessor from the environment
    
    @State private var showStopActionSheet = false // Controls the display of the stop recording action sheet
    
    var body: some View {
        VStack {
            if sessionManager.isRecording {
                // Display a message indicating that the session is currently being recorded
                Text("Recording Session...")
                    .font(.largeTitle)
                    .padding()
                
                // Button to stop the recording and trigger the action sheet for further options
                Button(action: {
                    showStopActionSheet = true
                }) {
                    Text("Stop Recording")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                // Button to start a new recording session
                Button(action: {
                    startRecordingSession()
                }) {
                    Text("Start Recording")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .actionSheet(isPresented: $showStopActionSheet) {
            // Action sheet to handle the stop recording options
            ActionSheet(
                title: Text("Stop Recording"),
                message: Text("Would you like to save or delete the recording?"),
                buttons: [
                    .default(Text("Save")) {
                        stopAndSaveSession()
                    },
                    .destructive(Text("Delete")) {
                        stopAndDeleteSession()
                    },
                    .cancel(Text("Cancel")) {
                        showStopActionSheet = false
                    }
                ]
            )
        }
    }
    
    /// Starts a new recording session and updates the state accordingly.
    private func startRecordingSession() {
        sessionManager.startNewSession() // Start a new session
        if let currentSession = sessionManager.currentSession {
            sensorDataProcessor.setCurrentSession(currentSession) // Set the current session in SensorDataProcessor
        }
    }
    
    /// Stops the current session and saves the recorded data.
    private func stopAndSaveSession() {
        sessionManager.stopSession()
        sensorDataProcessor.clearCurrentSession()
    }
    
    /// Stops the current session and deletes the recorded data.
    private func stopAndDeleteSession() {
        sessionManager.deleteCurrentSession()
        sensorDataProcessor.clearCurrentSession()
    }
}

// Preview provider for the SessionRecordingComponent
struct SessionRecordingComponent_Previews: PreviewProvider {
    static var previews: some View {
        SessionRecordingComponent()
            .environment(SessionManager()) // Injecting a mock environment object for preview
            .environment(SensorDataProcessor()) // Injecting a mock environment object for preview
    }
}
