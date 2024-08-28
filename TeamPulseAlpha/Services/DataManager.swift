//
//  DataManager.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import CoreData

/// The `DataManager` class is responsible for managing sensor data in the Core Data stack.
/// This includes initialization, resetting, and updates of sensor data.
class DataManager {
    // Singleton instance of DataManager to ensure a single point of access.
    static let shared = DataManager()

    // Private initializer to ensure the singleton pattern is enforced.
    private init() {}
    
    private var defaultUUID: [String: String] = [
        "Blue": "5A69DAD8-AC80-9A25-58CD-586EB3B62E59",
        "Green": "BC8EAD68-9B19-938E-7343-9C375FA5516D",
        "Red": "F4178ECF-E6B7-6303-E68C-5D4C3EF03C16"
    ]

    /// Resets all sensor data by deleting all entries from the Core Data store and reinitializing them.
    func resetSensors() {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = SensorEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            // Execute the delete request to remove all sensor entries
            try context.execute(deleteRequest)
            try context.save()
            initializeSensors()  // Reinitialize sensors after deletion
        } catch {
            print("Failed to reset sensors: \(error)")
        }
    }
    
    func resetSensrsToDefaultValues() {
        resetSensors()
    }
    
    private func setSensorsToDefaultValues() {
        for (key, value) in defaultUUID {
            createSensor(uuid: value, name: key)
        }
    }

    /// Initializes sensors by checking if they exist in the database and creating them if necessary.
    /// Ensures that there are always three sensors with specific UUIDs and names.
    func initializeSensors() {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<SensorEntity> = SensorEntity.fetchRequest()

        do {
            let sensors = try context.fetch(fetchRequest)
            // Ensure that there are always three sensors in the database
            if sensors.count < 3 {
                setSensorsToDefaultValues()
            }
        } catch {
            print("Failed to fetch sensors: \(error)")
        }
    }

    /// Creates a new sensor with the specified UUID and name if it does not already exist in the database.
    /// - Parameters:
    ///   - uuid: The UUID of the sensor, used to uniquely identify it.
    ///   - name: The name associated with the sensor.
    private func createSensor(uuid: String, name: String) {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<SensorEntity> = SensorEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid)

        do {
            let sensors = try context.fetch(fetchRequest)
            if sensors.isEmpty {
                // Only create a new sensor if one with the same UUID does not already exist.
                let sensor = SensorEntity(context: context)
                sensor.id = UUID()  // Generate a unique ID for the sensor
                sensor.uuid = uuid
                sensor.name = name
                sensor.isConnected = false
                CoreDataStack.shared.saveContext()  // Save the new sensor to the Core Data store
            }
        } catch {
            print("Failed to fetch or create sensor: \(error)")
        }
    }

    /// Updates the UUID of a sensor with a specified name.
    /// This can be used to update the MAC address or other identifying UUID of a sensor.
    /// - Parameters:
    ///   - name: The name of the sensor to update.
    ///   - newUUID: The new UUID to assign to the sensor.
    func updateSensorUUID(name: String, newUUID: String) {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<SensorEntity> = SensorEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name as CVarArg)

        do {
            if let sensor = try context.fetch(fetchRequest).first {
                sensor.uuid = newUUID
                CoreDataStack.shared.saveContext()  // Save the updated sensor to the Core Data store
                print("Successfully updated sensor \(sensor.name ?? "No value") with new MAC address: \(newUUID)")
            } else {
                print("Sensor with name \(name) not found.")
            }
        } catch {
            print("Failed to update sensor MAC address: \(error)")
        }
    }
}
