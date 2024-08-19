//
//  TeamPulseAlphaApp.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

@main
struct TeamPulseAlphaApp: App {
    // The main entry point for the app. It sets up the main scene and attaches the CoreData context.
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataStack.shared.context) // Injecting CoreData context into the environment
        }
    }
}

// Main content view that controls which view to show based on authentication status.
struct ContentView: View {
    // StateObjects to manage authentication and Bluetooth state across the app.
    @StateObject var authManager = AuthenticationManager()
    @StateObject var bluetoothManager = BluetoothManager()

    // Initializer for the ContentView, responsible for initializing necessary data.
    init() {
        // Initialize the sensors in the Core Data context. Uncomment the line below to reset sensors if needed.
        // DataManager.shared.resetSensors()
        DataManager.shared.initializeSensors()
    }

    var body: some View {
        NavigationView {
            // Conditional navigation based on the user's authentication status
            if authManager.isAuthenticated {
                AuthenticatedView()
                    .environmentObject(authManager)
                    .environmentObject(bluetoothManager)
            } else {
                UnauthenticatedView()
                    .environmentObject(authManager)
            }
        }
        // Ensure that both authManager and bluetoothManager are provided as environment objects
        .environmentObject(authManager)
        .environmentObject(bluetoothManager)
    }
}

// View displayed when the user is authenticated
struct AuthenticatedView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var bluetoothManager: BluetoothManager

    var body: some View {
        MainMenuView() // Show the main menu if the user is authenticated
            .environmentObject(authManager)
            .environmentObject(bluetoothManager)
    }
}

// View displayed when the user is not authenticated
struct UnauthenticatedView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        AuthView() // Show the authentication view if the user is not authenticated
            .environmentObject(authManager)
    }
}

