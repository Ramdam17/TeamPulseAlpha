//
//  AnimationComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import SwiftUI

/// The main view for displaying animation and related components like Bluetooth status, dashboard, and session management.
struct AnimationView: View {
    // Access the SensorDataProcessor from the environment to use the sensor data in the view.
    @Environment(SensorDataProcessor.self) var sensorDataProcessor
    @Environment(BluetoothManager.self) var bluetoothManager
    @Environment(SessionManager.self) var sessionManager

    @State private var isFullScreen = false

    var body: some View {
        ZStack {
            Color("CustomYellow").ignoresSafeArea()  // Set yellow background that fills the screen

            if isFullScreen {
                // Fullscreen mode
                ZStack {
                    // Animation Component takes full screen in fullscreen mode
                    AnimationComponent()
                        .ignoresSafeArea()

                    // Fullscreen toggle button at the top right
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
                }
            } else {
                // Normal mode
                VStack(spacing: 0) {
                    // Top Menu with recording status and buttons
                    HStack {

                        // Sensor status indicators
                        BluetoothStatusComponent()
                            .padding()

                        Spacer()

                        SessionRecordingComponent()

                        Spacer()

                        // add a navigation link with an exit icon that will be disabled if session is recording
                        NavigationLink(destination: sessionManager.isRecording ? nil : MainMenuView()) {
                            Image(
                                systemName: "arrow.backward.circle"
                            )
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(sessionManager.isRecording ? Color("CustomGrey") : .black)
                            .padding()
                            .cornerRadius(10)
                        }
                        .padding()

                    }
                    .frame(height: UIScreen.main.bounds.height / 12)  // 1/5 of the height
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding([.leading, .trailing])

                    Spacer()

                    HStack(spacing: 0) {
                        // Left dashboard
                        AnimationLeftDashboardComponent()
                            .frame(
                                width: UIScreen.main.bounds.width / 4,
                                height: 8 * UIScreen.main.bounds.height / 12
                            )  // 1/4 of the width
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                            .padding([.leading, .trailing])

                        Spacer()

                        // Animation Component
                        ZStack {
                            // Animation Component takes full screen in fullscreen mode
                            AnimationComponent()
                                .ignoresSafeArea()

                            // Fullscreen toggle button at the top right
                            HStack {
                                Spacer()
                                VStack {
                                    ToggleFullScreenButton(
                                        isFullScreen: $isFullScreen
                                    )
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

                    // Bottom dashboard
                    AnimationBottomDashboardComponent()
                        .frame(height: 2*UIScreen.main.bounds.height / 12)  // 1/3 of the height
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .padding([.leading, .trailing])
                }
            }
        }
        .onChange(of: bluetoothManager.hasNewValues) { oldValue, newValue in
            // Trigger sensor data update when new Bluetooth values are received
            if oldValue == false && newValue == true {
                let valuesToUnpack = bluetoothManager.getLatestValues()
                sensorDataProcessor.updateHRData(
                    sensorID: valuesToUnpack.id,
                    hr: valuesToUnpack.hr,
                    ibiArray: valuesToUnpack.ibis, isRecording: sessionManager.isRecording
                )
            }
        }
        .navigationBarHidden(true)  // Hide navigation bar to manage custom navigation
    }
}

// Preview provider for AnimationView
struct AnimationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // iPhone 15 Pro Preview
            AnimationView()
                .environment(SensorDataProcessor())  // Inject a mock SensorDataProcessor
                .environment(BluetoothManager())  // Inject a mock BluetoothManager
                .environment(SessionManager())  // Inject a mock SessionManager
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
                .previewDisplayName("iPhone 15 Pro")

            // iPad Pro 11-inch Preview
            AnimationView()
                .environment(SensorDataProcessor())  // Inject a mock SensorDataProcessor
                .environment(BluetoothManager())  // Inject a mock BluetoothManager
                .environment(SessionManager())  // Inject a mock SessionManager
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (11-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 11-inch")

            // iPad Pro 13-inch Preview
            AnimationView()
                .environment(SensorDataProcessor())  // Inject a mock SensorDataProcessor
                .environment(BluetoothManager())  // Inject a mock BluetoothManager
                .environment(SessionManager())  // Inject a mock SessionManager
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (12.9-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 13-inch")
        }
    }
}

/// A reusable component for the fullscreen toggle button.
struct ToggleFullScreenButton: View {
    @Binding var isFullScreen: Bool

    var body: some View {
        Button(action: {
            isFullScreen.toggle()
        }) {
            Image(
                systemName: isFullScreen
                    ? "arrow.down.right.and.arrow.up.left"
                    : "arrow.up.left.and.arrow.down.right"
            )
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundColor(Color("CustomYellow"))
        }
    }
}

/// A reusable component for displaying sensor status as a dot.
struct SensorStatusDot: View {
    let sensorName: String
    let isConnected: Bool

    var body: some View {
        Circle()
            .fill(isConnected ? Color(sensorName) : Color.gray)
            .frame(width: 20, height: 20)
    }
}
