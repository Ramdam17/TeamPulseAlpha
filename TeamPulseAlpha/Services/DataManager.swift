//
//  DataManager.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import CoreData

/// Manages sensor data in the Core Data stack, including initialization, resetting, and updates.
class DataManager {
    // Singleton instance of DataManager
    static let shared = DataManager()

    // Private initializer to ensure the singleton pattern
    private init() {}

    /// Resets all sensor data by deleting all entries from the Core Data store and reinitializing them.
    func resetSensors() {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = SensorEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            // Execute the delete request to remove all sensor entries
            try context.execute(deleteRequest)
            try context.save()
            initializeSensors() // Reinitialize sensors after deletion
        } catch {
            print("Failed to reset sensors: \(error)")
        }
    }

    /// Initializes sensors by checking if they exist and creating them if necessary.
    func initializeSensors() {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<SensorEntity> = SensorEntity.fetchRequest()

        do {
            let sensors = try context.fetch(fetchRequest)
            // Ensure that there are always three sensors in the database
            if sensors.count < 3 {
                createSensor(macAddress: "0F099F27-18D8-8ACC-C895-54AC2C36C790", color: "Blue")
                createSensor(macAddress: "F3742462-63F6-131A-C487-9F78D8A4FCCC", color: "Green")
                createSensor(macAddress: "EA61A349-6EFF-9A05-F9C1-F610C171579F", color: "Red")
            }
        } catch {
            print("Failed to fetch sensors: \(error)")
        }
    }

    /// Creates a new sensor with the specified MAC address and color, and saves it to Core Data.
    /// - Parameters:
    ///   - macAddress: The MAC address of the sensor.
    ///   - color: The color associated with the sensor.
    private func createSensor(macAddress: String, color: String) {
        let context = CoreDataStack.shared.context
        let sensor = SensorEntity(context: context)
        sensor.id = UUID() // Generate a unique ID for the sensor
        sensor.macAddress = macAddress
        sensor.color = color
        sensor.isConnected = false
        CoreDataStack.shared.saveContext() // Save the new sensor to the Core Data store
    }

    /// Updates the MAC address of an existing sensor.
    /// - Parameters:
    ///   - id: The UUID of the sensor to update.
    ///   - newMacAddress: The new MAC address to assign to the sensor.
    func updateSensorMacAddress(id: UUID, newMacAddress: String) {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<SensorEntity> = SensorEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            if let sensor = try context.fetch(fetchRequest).first {
                sensor.macAddress = newMacAddress
                CoreDataStack.shared.saveContext() // Save the updated sensor to the Core Data store
                print("Successfully updated sensor \(sensor.color ?? "No value") with new MAC address: \(newMacAddress)")
            } else {
                print("Sensor with ID \(id) not found.")
            }
        } catch {
            print("Failed to update sensor MAC address: \(error)")
        }
    }
}
