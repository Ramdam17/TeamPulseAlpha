//
//  AnimationComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import SpriteKit
import SwiftUI

struct AnimationComponent: View {
    @Environment(SensorDataProcessor.self) var sensorDataProcessor
    @Environment(BluetoothManager.self) var bluetoothManager

    @State private var isAnimationRunning: Bool = false

    @State private var animationScene: AnimationScene = AnimationScene(
        size: CGSize(width: 300, height: 400))  // Initialize the scene

    var body: some View {

        GeometryReader { metrics in

            SpriteView(scene: animationScene)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.black))
                .cornerRadius(10)
                .ignoresSafeArea()
                .onChange(of: sensorDataProcessor.isUpdated) {
                    oldValue, newValue in

                    if isAnimationRunning {
                        if oldValue == false && newValue == true {
                            updateHeartPositions()
                            updateClusterCircles()
                        }
                    }

                }
                .onAppear {
                    isAnimationRunning = true
                    animationScene.isPaused = false
                    animationScene.size = CGSize(width: metrics.size.width, height: metrics.size.height)
                    animationScene.scaleMode = .aspectFit
                }
                .onDisappear {
                    isAnimationRunning = false
                    animationScene.isPaused = true
                }
        }
    }

    // Function to update heart positions on the scene
    private func updateHeartPositions() {
        DispatchQueue.main.async {
            let lastValues = sensorDataProcessor.getLastHRData()
            animationScene.updateHeartPositions(
                blueHR: lastValues["Blue"]!,
                greenHR: lastValues["Green"]!,
                redHR: lastValues["Red"]!
            )
        }
    }

    private func updateClusterCircles() {
        DispatchQueue.main.async {
            animationScene.updateClusterCircles(
                clusterState: sensorDataProcessor.getClusterState()
            )
        }
    }
}

// Preview provider for SwiftUI previews, allowing for real-time design feedback.
struct AnimationComponent_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            // iPhone 15 Pro Preview
            AnimationComponent()
                .environment(SensorDataProcessor())
                .environment(BluetoothManager())
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
                .previewDisplayName("iPhone 15 Pro")

            // iPad Pro 11-inch Preview
            AnimationComponent()
                .environment(SensorDataProcessor())
                .environment(BluetoothManager())
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (11-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 11-inch")

            // iPad Pro 13-inch Preview
            AnimationComponent()
                .environment(SensorDataProcessor())
                .environment(BluetoothManager())
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (12.9-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 13-inch")
        }
    }
}
