//
//  TeamPulseAlphaApp.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI
import CoreData

@main
struct TeamPulseAlphaApp: App {

    @State private var sensorDataProcessor = SensorDataProcessor()
    @State private var sessionManager = SessionManager()
    @State private var authManager = AuthenticationManager() // Manages the authentication state
    @State private var bluetoothManager = BluetoothManager() // Manages the Bluetooth connections and sensor data

    // Fetch sensor UUIDs and initialize objects lazily
    init() {
        // Register the custom transformer for transforming arrays to and from data in Core Data.
        ValueTransformer.setValueTransformer(ArrayTransformer(), forName: NSValueTransformerName("ArrayTransformer"))
    }

    /// The main entry point for the app. Sets up the main scene and injects the CoreData context.
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataStack.shared.context) // Inject CoreData context into the environment for all views
                .environment(sensorDataProcessor) // Provide SensorDataProcessor to the environment
                .environment(sessionManager) // Provide SessionManager to the environment
                .environment(authManager) // Provide AuthenticationManager to the environment
                .environment(bluetoothManager) // Provide BluetoothManager to the environment
        }
    }

    /// Fetches the sensor UUIDs from CoreData.
    private static func fetchSensorUUIDs() -> [UUID] {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<SensorEntity> = SensorEntity.fetchRequest()
        do {
            let sensors = try context.fetch(fetchRequest)
            return sensors.compactMap { $0.id }
        } catch {
            print("Failed to fetch sensors: \(error)")
            return []
        }
    }
}

/// Main content view that controls which view to show based on the authentication status of the user.
struct ContentView: View {

    @Environment(AuthenticationManager.self) var authManager // Use the authentication manager from the environment

    var body: some View {
        NavigationView {
            // Conditional navigation based on the user's authentication status
            if authManager.isAuthenticated {
                // Show the main menu if the user is authenticated
                AuthenticatedView()
            } else {
                // Show the authentication view if the user is not authenticated
                UnauthenticatedView()
            }
        }
    }
}

/// View displayed when the user is authenticated, providing access to the main menu.
struct AuthenticatedView: View {
    var body: some View {
        // Display the main menu
        MainMenuView()
    }
}

/// View displayed when the user is not authenticated, showing the sign-in interface.
struct UnauthenticatedView: View {
    var body: some View {
        // Display the authentication view for signing in
        AuthView()
    }
}
