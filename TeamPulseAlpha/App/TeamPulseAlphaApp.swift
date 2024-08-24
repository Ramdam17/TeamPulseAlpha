//
//  TeamPulseAlphaApp.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 24/07/2024.
//

import CoreData
import SwiftUI

@main
struct TeamPulseAlphaApp: App {

    @State private var sensorDataProcessor = SensorDataProcessor()
    @State private var sessionManager = SessionManager()
    @State private var authManager = AuthenticationManager()  // Manages the authentication state
    @State private var bluetoothManager = BluetoothManager()  // Manages Bluetooth connections and sensor data

    // Custom initial setup
    init() {
        // Register the custom transformer for transforming arrays to and from data in Core Data.
        ValueTransformer.setValueTransformer(
            ArrayTransformer(),
            forName: NSValueTransformerName("ArrayTransformer")
        )
    }

    /// Main entry point for the app, sets up the main scene and injects the CoreData context.
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                    \.managedObjectContext, CoreDataStack.shared.context
                )  // Inject CoreData context
                .environment(sensorDataProcessor)  // Provide SensorDataProcessor to the environment
                .environment(sessionManager)  // Provide SessionManager to the environment
                .environment(authManager)  // Provide AuthenticationManager to the environment
                .environment(bluetoothManager)  // Provide BluetoothManager to the environment
                .onAppear {
                    UIDevice.current.setValue(
                        UIInterfaceOrientation.landscapeLeft.rawValue,
                        forKey: "orientation")
                    AppDelegate.orientationLock = .landscape
                }
        }
    }

    /// Fetches the sensor UUIDs from CoreData.
    private static func fetchSensorUUIDs() -> [UUID] {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<SensorEntity> =
            SensorEntity.fetchRequest()
        do {
            let sensors = try context.fetch(fetchRequest)
            return sensors.compactMap { $0.id }
        } catch {
            print("Failed to fetch sensors: \(error)")
            return []
        }
    }

    /// Resets CoreData by deleting all entries and saving the context.
    func resetCoreData() {
        let context = CoreDataStack.shared.context
        let entityNames =
            context.persistentStoreCoordinator?.managedObjectModel.entities
            .compactMap { $0.name } ?? []

        context.performAndWait {
            for entityName in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
                    entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(
                    fetchRequest: fetchRequest)
                do {
                    try context.execute(deleteRequest)
                } catch {
                    print("Failed to delete entity \(entityName): \(error)")
                }
            }

            do {
                try context.save()
            } catch {
                print("Failed to save context after deletion: \(error)")
            }
        }
    }
}

/// Main content view that controls which view to show based on the authentication status of the user.
struct ContentView: View {

    @Environment(AuthenticationManager.self) var authManager  // Use the authentication manager from the environment

    init() {
        DataManager.shared.initializeSensors()  // Initialize sensors on app launch
    }

    var body: some View {
        NavigationView {
            // Conditional navigation based on the user's authentication status
            if authManager.isAuthenticated {
                AuthenticatedView()  // Show main menu if authenticated
            } else {
                UnauthenticatedView()  // Show authentication view if not authenticated
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .all)
    }
}

/// View displayed when the user is authenticated, providing access to the main menu.
struct AuthenticatedView: View {
    var body: some View {
        MainMenuView()  // Display the main menu
    }
}

/// View displayed when the user is not authenticated, showing the sign-in interface.
struct UnauthenticatedView: View {
    var body: some View {
        AuthView()  // Display the authentication view for signing in
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.landscape

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
