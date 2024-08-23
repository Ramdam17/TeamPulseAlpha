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

    @State private var animationScene: AnimationScene = AnimationScene(
        size: CGSize(width: 300, height: 400))  // Initialize the scene
    
    var body: some View {
        SpriteView(scene: animationScene)
            .ignoresSafeArea()
            .onAppear {
                //
            }
            .onChange(of: sensorDataProcessor.isUpdated) { oldValue, newValue in
                
                if oldValue == false && newValue == true {
                    updateHeartPositions()
                    updateClusterCircles()
                }
                
            }
            .frame(width: 400, height: 300)
    }

    // Function to update heart positions on the scene
    private func updateHeartPositions() {
        DispatchQueue.main.async {
            let lastValues = sensorDataProcessor.lastHR
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

#Preview {
    AnimationComponent()
        .environment(SensorDataProcessor())
        .environment(BluetoothManager())
}
