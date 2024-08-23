//
//  BluetoothManager.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 24/07/2024.
//

import CoreBluetooth
import CoreData
import Foundation

/// A structure to hold the data packet that will be sent or received.
struct PacketToSend: Codable {
    var id: String = String()
    var hr: Double = 60.0
    var ibis: [Double] = []
}

/// `BluetoothManager` is responsible for managing Bluetooth connections and interactions with sensor devices.
@Observable
class BluetoothManager: NSObject {

    var packetToSend = PacketToSend()

    var sensors: [SensorEntity] = [] {
        didSet {
            print("Sensors updated: \(sensors.map { "\($0.uuid ?? "Unknown") - Connected: \($0.isConnected)" })")
        }
    }
    
    var isScanning = false {
        didSet {
            print("Scanning state changed: \(isScanning)")
        }
    }

    var isUpdated: Bool = false {
        didSet {
            // This will trigger a view update if needed
        }
    }

    var hasNewValues: Bool = false {
        didSet {
            // This will trigger a view update if new sensor data is available
        }
    }

    private var centralManager: CBCentralManager!  // Core Bluetooth manager instance
    private var discoveredPeripherals: [String: CBPeripheral] = [:]  // Cache of discovered peripherals

    /// Initializes the Bluetooth manager and sets up necessary configurations.
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)  // Initialize the Bluetooth central manager
        resetSensorConnections()  // Reset the connection status of all sensors
        fetchSensors()  // Fetch sensors from Core Data
    }

    /// Resets the connection status of all sensors to `false` at the start of the app.
    private func resetSensorConnections() {
        let fetchRequest: NSFetchRequest<SensorEntity> = SensorEntity.fetchRequest()
        do {
            let sensors = try CoreDataStack.shared.context.fetch(fetchRequest)
            for sensor in sensors {
                sensor.isConnected = false  // Set all sensors to disconnected
            }
            CoreDataStack.shared.saveContext()  // Save changes to Core Data
            self.sensors = sensors  // Update the sensors array
        } catch {
            print("Failed to reset sensor connections: \(error)")
        }
    }

    /// Fetches the sensors from Core Data and updates the sensors array.
    func fetchSensors() {
        let fetchRequest: NSFetchRequest<SensorEntity> = SensorEntity.fetchRequest()
        do {
            sensors = try CoreDataStack.shared.context.fetch(fetchRequest)
            print("Fetched sensors from CoreData: \(sensors.map { $0.name })")
        } catch {
            print("Failed to fetch sensors: \(error)")
        }
    }

    /// Starts scanning for Bluetooth peripherals.
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth is not powered on.")
            return
        }
        isScanning = true
        print("Starting scan for peripherals...")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    /// Stops scanning for Bluetooth peripherals.
    func stopScanning() {
        isScanning = false
        print("Stopping scan for peripherals.")
        centralManager.stopScan()
        triggerUpdate()
    }

    /// Updates the connection status of a sensor and refreshes the UI.
    private func updateSensorConnectionStatus(uuid: String, isConnected: Bool) {
        if let index = sensors.firstIndex(where: { $0.uuid == uuid }) {
            sensors[index].isConnected = isConnected
            saveContextAndRefreshSensors()
            print("Updated sensor \(sensors[index].name ?? "Unknown") to \(isConnected ? "Connected" : "Disconnected")")
            triggerUpdate()
        }
    }

    /// Saves the current context and refreshes the sensors array to trigger UI updates.
    private func saveContextAndRefreshSensors() {
        do {
            try CoreDataStack.shared.saveContext()  // Save the Core Data context
            fetchSensors()  // Re-fetch sensors to trigger UI updates
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    /// Checks if all sensors are connected and stops scanning if they are.
    func checkIfAllSensorsConnected() {
        let allConnected = sensors.allSatisfy { $0.isConnected }
        print("Checking if all sensors are connected. Result: \(allConnected)")

        if allConnected {
            print("All sensors connected. Stopping scan.")
            stopScanning()
            DispatchQueue.main.async {
                self.isScanning = false  // Ensure UI reflects the stopped scan state
                print("Scanning stopped, updating UI.")
            }
        }
    }
}

extension BluetoothManager: CBCentralManagerDelegate, CBPeripheralDelegate {

    /// Handles changes in the Bluetooth central manager's state.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on.")
        } else {
            print("Bluetooth is not available. State: \(central.state.rawValue)")
            stopScanning()
        }
    }

    /// Handles the discovery of Bluetooth peripherals.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let peripheralUUID = peripheral.identifier.uuidString
        //print("Discovered peripheral with name \(peripheral.name ?? "Unknown") and UUID: \(peripheralUUID)")

        // Check if the discovered peripheral matches any sensor
        if let sensor = sensors.first(where: { $0.uuid == peripheralUUID }) {
            print("Matched sensor with UUID: \(peripheralUUID)")
            discoveredPeripherals[peripheralUUID] = peripheral
            updateSensorConnectionStatus(uuid: sensor.uuid!, isConnected: true)
            centralManager.connect(peripheral, options: nil)  // Connect to the peripheral
        } else {
            //print("Peripheral with UUID \(peripheralUUID) does not match any known sensors.")
        }
    }

    /// Handles successful connection to a Bluetooth peripheral.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let uuid = peripheral.identifier.uuidString
        print("Successfully connected to peripheral with UUID: \(uuid)")

        // Check if the connected peripheral matches any sensor
        if let sensor = sensors.first(where: { $0.uuid == uuid }) {
            updateSensorConnectionStatus(uuid: sensor.uuid!, isConnected: true)
            peripheral.delegate = self
            print("Discovering services for peripheral with UUID: \(uuid)")
            checkIfAllSensorsConnected()  // Check and stop scanning here if needed
            peripheral.discoverServices([CBUUID(string: "180D")])  // Heart Rate Service UUID
        } else {
            print("Error: Connected peripheral with UUID \(uuid) does not match any sensor in the list.")
        }
    }

    /// Handles the disconnection of a Bluetooth peripheral.
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let uuid = peripheral.identifier.uuidString
        print("Peripheral with UUID \(uuid) disconnected.")
        updateSensorConnectionStatus(uuid: uuid, isConnected: false)
    }

    /// Handles the discovery of services on a connected Bluetooth peripheral.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }

        if let services = peripheral.services {
            for service in services {
                //print("Discovered service with UUID: \(service.uuid)")
                if service.uuid == CBUUID(string: "180D") {  // Heart Rate Service UUID
                    print("Discovering characteristics for service with UUID: \(service.uuid)")
                    peripheral.discoverCharacteristics([CBUUID(string: "2A37")], for: service)  // Heart Rate Measurement UUID
                }
            }
        }
    }

    /// Handles the discovery of characteristics for a service on a connected Bluetooth peripheral.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }

        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Discovered characteristic with UUID: \(characteristic.uuid)")
                if characteristic.uuid == CBUUID(string: "2A37") {  // Heart Rate Measurement UUID
                    print("Subscribing to notifications for characteristic with UUID: \(characteristic.uuid)")
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }

    /// Handles updates to the value of a characteristic on a connected Bluetooth peripheral.
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating value for characteristic: \(error.localizedDescription)")
            return
        }

        guard let data = characteristic.value else { return }

        if characteristic.uuid == CBUUID(string: "2A37") {
            let (heartRate, IBI) = parseHeartRateMeasurement(data)
            //print("Heart Rate: \(heartRate), IBI: \(IBI)")

            if !IBI.isEmpty {
                if let sensor = sensors.first(where: { $0.uuid == peripheral.identifier.uuidString }) {
                    packetToSend.id = sensor.name ?? "Unknown"
                    packetToSend.hr = Double(heartRate)
                    packetToSend.ibis = IBI
                    triggerHasNewValues()
                }
            } else {
                print("IBI array is empty, skipping updateHRData.")
            }
        }
    }

    /// Parses the heart rate measurement data received from a Bluetooth peripheral.
    private func parseHeartRateMeasurement(_ data: Data) -> (heartRate: Int, IBI: [Double]) {
        let flag = data[0]
        var heartRate = 0
        var IBI: [Double] = []

        if flag & 0x01 == 0 {
            heartRate = Int(data[1])

            if data.count >= 4 {
                let rr = Double(UInt16(data[2]) | UInt16(data[3]) << 8) / 1024.0
                IBI.append(rr)
            }
            if data.count >= 6 {
                let rr = Double(UInt16(data[4]) | UInt16(data[5]) << 8) / 1024.0
                IBI.append(rr)
            }
            if data.count >= 8 {
                let rr = Double(UInt16(data[6]) | UInt16(data[7]) << 8) / 1024.0
                IBI.append(rr)
            }
        } else {
            heartRate = Int(UInt16(data[1]) | UInt16(data[2]) << 8)
        }

        return (heartRate, IBI)
    }

    /// Triggers a UI update by toggling the `isUpdated` property.
    private func triggerUpdate() {
        isUpdated = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isUpdated = false
        }
    }

    /// Triggers a UI update when new values are received by toggling the `hasNewValues` property.
    private func triggerHasNewValues() {
        hasNewValues = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.hasNewValues = false
        }
    }

    /// Returns the latest sensor data as a tuple.
    func getLatestValues() -> (id: String, hr: Double, ibis: [Double]) {
        return (id: packetToSend.id, hr: packetToSend.hr, ibis: packetToSend.ibis)
    }
}
