//
//  SessionRecordingComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

// Inside SessionRecordingComponent.swift

import SwiftUI

/// A view component responsible for managing the session recording process, including start, stop, save, and delete actions.
struct SessionRecordingComponent: View {
    @EnvironmentObject var sessionManager: SessionManager // Access the SessionManager from the environment
    @EnvironmentObject var sensorDataProcessor: SensorDataProcessor // Access the SensorDataProcessor from the environment
    
    @State private var isRecording = false // Tracks whether the recording is currently active
    @State private var showStopActionSheet = false // Controls the display of the stop recording action sheet
    
    var body: some View {
        VStack {
            if isRecording {
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
                    sessionManager.startNewSession() // Start a new session
                    if let currentSession = sessionManager.currentSession {
                        sensorDataProcessor.setCurrentSession(currentSession) // Set the current session in SensorDataProcessor
                    }
                    isRecording = true // Update the recording state to true
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
                        // Save the session and stop recording
                        sessionManager.stopSession()
                        sensorDataProcessor.clearCurrentSession()
                        isRecording = false
                    },
                    .destructive(Text("Delete")) {
                        // Delete the current session and stop recording
                        sessionManager.deleteCurrentSession()
                        sensorDataProcessor.clearCurrentSession()
                        isRecording = false
                    },
                    .cancel(Text("Cancel")) {
                        // Cancel the action sheet without making changes
                        showStopActionSheet = false
                    }
                ]
            )
        }
    }
}
