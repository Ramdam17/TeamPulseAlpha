//
//  DataManager.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import CoreData

class DataManager {
    static let shared = DataManager()

    private init() {}

    func initializeSensors() {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<SensorEntity> = SensorEntity.fetchRequest()

        do {
            let sensors = try context.fetch(fetchRequest)
            if sensors.count < 3 {
                createSensor(macAddress: "00:11:22:33:44:55", color: "Blue")
                createSensor(macAddress: "66:77:88:99:AA:BB", color: "Green")
                createSensor(macAddress: "CC:DD:EE:FF:00:11", color: "Red")
            }
        } catch {
            print("Failed to fetch sensors: \(error)")
        }
    }

    private func createSensor(macAddress: String, color: String) {
        let context = CoreDataStack.shared.context
        let sensor = SensorEntity(context: context)
        sensor.id = UUID()
        sensor.macAddress = macAddress
        sensor.color = color
        sensor.isConnected = false
        CoreDataStack.shared.saveContext()
    }
}
