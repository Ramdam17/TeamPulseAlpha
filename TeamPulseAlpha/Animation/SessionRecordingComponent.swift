import SwiftUI

struct SessionRecordingComponent: View {
    @Environment(SessionManager.self) var sessionManager
    @Environment(SensorDataProcessor.self) var sensorDataProcessor

    @State private var showStopActionSheet = false

    var body: some View {
        VStack {
            if sessionManager.isRecording {
                HStack (spacing: 20) {
                    Text("Recording Session...")
                        .font(.headline)
                        .padding()

                    Button(action: {
                        showStopActionSheet = true
                    }) {
                        Text("Stop Recording")
                            .font(.body)
                            .padding(10)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .frame(height: 40)
                }
            } else {
                Button(action: {
                    startRecordingSession()
                }) {
                    Text("Start Recording")
                        .font(.body)
                        .padding(10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .frame(height: 40)
            }
        }
        .actionSheet(isPresented: $showStopActionSheet) {
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
                    },
                ]
            )
        }
    }

    private func startRecordingSession() {
        sessionManager.startNewSession()
        if let currentSession = sessionManager.currentSession {
            sensorDataProcessor.setCurrentSession(currentSession)
        }
    }

    private func stopAndSaveSession() {
        sessionManager.stopSession()
        sensorDataProcessor.clearCurrentSession()
    }

    private func stopAndDeleteSession() {
        sessionManager.deleteCurrentSession()
        sensorDataProcessor.clearCurrentSession()
    }
}
