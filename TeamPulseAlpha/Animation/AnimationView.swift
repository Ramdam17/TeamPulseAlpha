import SwiftUI

struct AnimationView: View {
    @Environment(SensorDataProcessor.self) var sensorDataProcessor
    @Environment(BluetoothManager.self) var bluetoothManager
    @Environment(SessionManager.self) var sessionManager

    @State private var isFullScreen = false

    var body: some View {
        ZStack {
            Color("CustomYellow").ignoresSafeArea()

            if isFullScreen {
                ZStack {
                    AnimationComponent()
                        .ignoresSafeArea()

                    HStack {
                        Spacer()
                        VStack {
                            ToggleFullScreenButton(isFullScreen: $isFullScreen)
                                .padding()
                            Spacer()
                        }
                        .padding()
                    }
                    .padding(.trailing, 20)

                    if sessionManager.isRecording {
                        VStack {
                            Spacer()
                            Text(formatElapsedTime(sessionManager.elapsedTime))
                                .font(.title)
                                .foregroundColor(.white)
                                .opacity(0.4)
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity)
                                .transition(.opacity)
                        }
                    }
                }
            } else {
                VStack {
                    HStack {
                        BluetoothStatusComponent()
                            .padding()

                        Spacer()

                        SessionRecordingComponent()
                            .padding()

                        Spacer()

                        NavigationLink(destination: sessionManager.isRecording ? nil : MainMenuView()) {
                            Image(systemName: "arrow.backward.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(sessionManager.isRecording ? Color("CustomGrey") : .black)
                                .padding()
                                .cornerRadius(10)
                        }
                        .padding()

                        if sessionManager.isRecording {
                            Text(formatElapsedTime(sessionManager.elapsedTime))
                                .font(.headline)
                                .padding(.trailing, 20)
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height / 16)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding([.leading, .trailing])

                    Spacer()

                    HStack {
                        AnimationLeftDashboardComponent()
                            .frame(width: UIScreen.main.bounds.width / 4, height: 8 * UIScreen.main.bounds.height / 16)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding([.leading, .trailing])

                        Spacer()

                        ZStack {
                            AnimationComponent()
                                .ignoresSafeArea()

                            HStack {
                                Spacer()
                                VStack {
                                    ToggleFullScreenButton(isFullScreen: $isFullScreen)
                                        .padding()
                                    Spacer()
                                }
                                .padding(.top, 10)
                            }
                            .padding(.trailing, 10)
                        }
                        .padding()
                    }

                    Spacer()

                    AnimationBottomDashboardComponent()
                        .frame(height: 2 * UIScreen.main.bounds.height / 6)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding([.leading, .trailing])
                }
            }
        }
        .onChange(of: bluetoothManager.hasNewValues) { oldValue, newValue in
            if oldValue == false && newValue == true {
                let valuesToUnpack = bluetoothManager.getLatestValues()
                sensorDataProcessor.updateHRData(
                    sensorID: valuesToUnpack.id,
                    hr: valuesToUnpack.hr,
                    ibiArray: valuesToUnpack.ibis,
                    isRecording: sessionManager.isRecording
                )
            }
        }
        .navigationBarHidden(true)
    }

    /// Formats the elapsed time into a human-readable string.
    private func formatElapsedTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// Preview provider for AnimationView
struct AnimationView_Previews: PreviewProvider {
    static var previews: some View {
        AnimationView()
            .environment(SensorDataProcessor())  // Inject a mock SensorDataProcessor
            .environment(BluetoothManager())  // Inject a mock BluetoothManager
            .environment(SessionManager())  // Inject a mock SessionManager
    }
}

/// A reusable component for the fullscreen toggle button.
struct ToggleFullScreenButton: View {
    @Binding var isFullScreen: Bool

    var body: some View {
        Button(action: {
            isFullScreen.toggle()
        }) {
            Image(systemName: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(Color("CustomYellow"))
        }
    }
}
