//
//  SessionRecordingView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

/// A view that displays details of the ongoing session, including options to end or pause the recording.
struct SessionDetailView: View {

    @Environment(SessionManager.self) var sessionManager  // Access the session manager from the environment
    @Environment(\.presentationMode) var presentationMode  // Access the presentation mode to dismiss the view

    @State private var isRecording: Bool = true  // State to track if the session is recording
    
    @State var session: SessionEntity?

    var body: some View {
        VStack {
            // Title of the view based on the recording status
            Text(isRecording ? "Recording Session..." : "Session Paused")
                .font(.largeTitle)
                .padding()

            // Placeholder for additional session recording UI (e.g., timers, indicators)
            VStack {
                Text(
                    isRecording
                        ? "Recording in Progress" : "Session has been paused."
                )
                .foregroundColor(.gray)
                // Add additional UI components for session information here
            }
            .padding()

            Spacer()

            // Button to end the session
            Button(action: {
                endSession()
            }) {
                Text("End Session")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationBarTitle("Session Recording", displayMode: .inline)
        .navigationBarItems(
            trailing: Button(action: {
                pauseResumeSession()
            }) {
                Text(isRecording ? "Pause" : "Resume")
            })
    }

    // Function to end the session
    private func endSession() {
        isRecording = false
        sessionManager.stopSession()
        presentationMode.wrappedValue.dismiss()  // Dismiss the view after ending the session
        // Add any additional logic for ending the session, such as saving or processing data
    }

    // Function to pause or resume the session
    private func pauseResumeSession() {
        isRecording.toggle()
        // Add any additional logic for pausing or resuming the session
    }
}

struct SessionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // iPhone 15 Pro Preview
            SessionDetailView()
                .environment(SessionManager())  // Injecting a mock environment object for preview
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
                .previewDisplayName("iPhone 15 Pro")

            // iPad Pro 11-inch Preview
            SessionDetailView()
                .environment(SessionManager())  // Injecting a mock environment object for preview
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (11-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 11-inch")

            // iPad Pro 13-inch Preview
            SessionDetailView()
                .environment(SessionManager())  // Injecting a mock environment object for preview
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (12.9-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 13-inch")
        }
    }
}
