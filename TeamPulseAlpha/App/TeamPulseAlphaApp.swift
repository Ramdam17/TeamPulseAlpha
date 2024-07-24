//
//  TeamPulseAlphaApp.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

@main
struct TeamPulseAlphaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataStack.shared.context)
        }
    }
}


struct ContentView: View {
    @StateObject var authManager = AuthenticationManager()
    @StateObject var bluetoothManager = BluetoothManager()

    init() {
        DataManager.shared.initializeSensors()
    }

    var body: some View {
        NavigationView {
            if authManager.isAuthenticated {
                MainMenuView()
                    .environmentObject(authManager)
                    .environmentObject(bluetoothManager)
            } else {
                AuthView()
                    .environmentObject(authManager)
            }
        }
        .environmentObject(authManager)
        .environmentObject(bluetoothManager) // Ensure BluetoothManager is provided here
    }
}
