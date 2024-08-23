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
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> =
            SensorEntity.fetchRequest()
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

    /// Initializes sensors by checking if they exist and creating them if necessary.
    func initializeSensors() {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<SensorEntity> =
            SensorEntity.fetchRequest()

        do {
            let sensors = try context.fetch(fetchRequest)
            // Ensure that there are always three sensors in the database
            if sensors.count < 3 {
                createSensor(
                    uuid: "0F099F27-18D8-8ACC-C895-54AC2C36C790", name: "Blue")
                createSensor(
                    uuid: "F3742462-63F6-131A-C487-9F78D8A4FCCC", name: "Green")
                createSensor(
                    uuid: "EA61A349-6EFF-9A05-F9C1-F610C171579F", name: "Red")
            }
        } catch {
            print("Failed to fetch sensors: \(error)")
        }
    }

    /// Creates a new sensor with the specified MAC address and color, and saves it to Core Data.
    /// - Parameters:
    ///   - macAddress: The MAC address of the sensor.
    ///   - color: The color associated with the sensor.print
    private func createSensor(uuid: String, name: String) {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<SensorEntity> =
            SensorEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid)

        do {
            let sensors = try context.fetch(fetchRequest)
            if sensors.isEmpty {
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

    func updateSensorMacAddress(name: String, newUUID: String) {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<SensorEntity> =
            SensorEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "name == %@", name as CVarArg)

        do {
            if let sensor = try context.fetch(fetchRequest).first {
                sensor.uuid = newUUID
                CoreDataStack.shared.saveContext()  // Save the updated sensor to the Core Data store
                print(
                    "Successfully updated sensor \(sensor.name ?? "No value") with new MAC address: \(newUUID)"
                )
            } else {
                print("Sensor with name \(name) not found.")
            }
        } catch {
            print("Failed to update sensor MAC address: \(error)")
        }
    }
}
