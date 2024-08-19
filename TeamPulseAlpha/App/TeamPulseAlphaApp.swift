//
//  TeamPulseAlphaApp.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

@main
struct TeamPulseAlphaApp: App {
    
    /// Initializes the app and registers the custom transformer for Core Data.
    init() {
        // Register the custom transformer for transforming arrays to and from data in Core Data.
        ValueTransformer.setValueTransformer(ArrayTransformer(), forName: NSValueTransformerName("ArrayTransformer"))
    }

    /// The main entry point for the app. Sets up the main scene and injects the CoreData context.
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataStack.shared.context) // Inject CoreData context into the environment for all views
        }
    }
}

/// Main content view that controls which view to show based on the authentication status of the user.
struct ContentView: View {
    // StateObjects to manage authentication, Bluetooth, and session states across the app.
    @StateObject var authManager = AuthenticationManager() // Manages the authentication state
    @StateObject var bluetoothManager = BluetoothManager() // Manages the Bluetooth connections and sensor data
    @StateObject var sessionManager = SessionManager() // Manages the session recording and related data

    /// Initializer for the ContentView, responsible for initializing necessary data.
    init() {
        // Initialize the sensors in the Core Data context. Uncomment the line below to reset sensors if needed.
        // DataManager.shared.resetSensors()
        DataManager.shared.initializeSensors() // Ensure sensors are set up in Core Data
    }

    var body: some View {
        NavigationView {
            // Conditional navigation based on the user's authentication status
            if authManager.isAuthenticated {
                // Show the main menu if the user is authenticated
                AuthenticatedView()
                    .environmentObject(authManager)
                    .environmentObject(bluetoothManager)
                    .environmentObject(sessionManager) // Provide SessionManager to the environment
            } else {
                // Show the authentication view if the user is not authenticated
                UnauthenticatedView()
                    .environmentObject(authManager)
            }
        }
        // Ensure that all necessary environment objects are provided to the navigation view
        .environmentObject(authManager)
        .environmentObject(bluetoothManager)
        .environmentObject(sessionManager) // Provide SessionManager to the environment
    }
}

/// View displayed when the user is authenticated, providing access to the main menu.
struct AuthenticatedView: View {
    @EnvironmentObject var authManager: AuthenticationManager // Access the authentication manager from the environment
    @EnvironmentObject var bluetoothManager: BluetoothManager // Access the Bluetooth manager from the environment

    var body: some View {
        // Display the main menu with access to all necessary environment objects
        MainMenuView()
            .environmentObject(authManager)
            .environmentObject(bluetoothManager)
    }
}

/// View displayed when the user is not authenticated, showing the sign-in interface.
struct UnauthenticatedView: View {
    @EnvironmentObject var authManager: AuthenticationManager // Access the authentication manager from the environment

    var body: some View {
        // Display the authentication view for signing in
        AuthView()
            .environmentObject(authManager)
    }
}
