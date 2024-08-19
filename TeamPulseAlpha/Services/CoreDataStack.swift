//
//  CoreDataStack.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import CoreData

/// CoreDataStack is responsible for setting up and managing the Core Data stack in the application.
/// It provides access to the managed object context, which is used to interact with the Core Data store.
class CoreDataStack {
    
    /// Shared instance of the CoreDataStack for easy access throughout the app.
    static let shared = CoreDataStack()

    // Private initializer to enforce the singleton pattern and prevent multiple instances of CoreDataStack.
    private init() {}

    /// The persistent container that encapsulates the Core Data stack, including the managed object context.
    /// The container is initialized with the name of the data model (ensure this matches your .xcdatamodeld file).
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TeamPulseModel") // Ensure this matches your model name
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle the error in production, perhaps logging it and providing a fallback.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    /// The main managed object context for the application.
    /// This context is used to perform operations on the Core Data store on the main thread.
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    /// Saves changes in the context to the persistent store, if there are any changes.
    /// If saving fails, the application will terminate with a fatal error.
    /// In a production environment, you might want to handle this more gracefully.
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately in production.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
