//
//  BluetoothManager.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 24/07/2024.
//

import CoreBluetooth
import CoreData
import Foundation

/// A class responsible for managing Bluetooth connections with sensor devices.
class BluetoothManager: NSObject, ObservableObject {
    @Published var sensors: [SensorEntity] = [] // The array of sensors managed by Core Data
    @Published var isScanning = false // Flag to indicate if Bluetooth scanning is in progress

    private var centralManager: CBCentralManager! // Core Bluetooth manager
    private var discoveredPeripherals: [String: CBPeripheral] = [:] // Cache of discovered peripherals
    private var sensorDataProcessor: SensorDataProcessor!  // Instance of SensorDataProcessor

    /// Initializes the Bluetooth manager and sets up necessary configurations.
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil) // Initialize the Bluetooth central manager
        resetSensorConnections() // Reset the connection status of all sensors
        fetchSensors() // Fetch sensors from Core Data
        
        // Initialize the SensorDataProcessor with the sensor IDs, filtering out any nil values
        let sensorIDs = sensors.compactMap { $0.id }
        sensorDataProcessor = SensorDataProcessor(sensorIDs: sensorIDs)
    }

    /// Resets the connection status of all sensors to `false` at the start of the app.
    private func resetSensorConnections() {
        let fetchRequest: NSFetchRequest<SensorEntity> = SensorEntity.fetchRequest()
        do {
            let sensors = try CoreDataStack.shared.context.fetch(fetchRequest)
            for sensor in sensors {
                sensor.isConnected = false // Set all sensors to disconnected
            }
            CoreDataStack.shared.saveContext() // Save changes to Core Data
            self.sensors = sensors // Update the published sensors array
        } catch {
            print("Failed to reset sensor connections: \(error)")
        }
    }

    /// Fetches the sensors from Core Data and updates the sensors array.
    func fetchSensors() {
        let fetchRequest: NSFetchRequest<SensorEntity> = SensorEntity.fetchRequest()
        do {
            sensors = try CoreDataStack.shared.context.fetch(fetchRequest)
            print("Fetched sensors from CoreData: \(sensors.map { $0.macAddress })")
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
    }

    /// Updates the connection status of a sensor and refreshes the UI.
    private func updateSensorConnectionStatus(uuid: String, isConnected: Bool) {
        if let index = sensors.firstIndex(where: { $0.macAddress == uuid }) {
            sensors[index].isConnected = isConnected
            saveContextAndRefreshSensors()
        }
    }

    /// Saves the current context and refreshes the sensors array to trigger UI updates.
    private func saveContextAndRefreshSensors() {
        do {
            try CoreDataStack.shared.saveContext() // Save the Core Data context
            fetchSensors() // Re-fetch sensors to trigger UI updates
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    /// Checks if all sensors are connected and stops scanning if they are.
    private func checkIfAllSensorsConnected() {
        let allConnected = sensors.allSatisfy { $0.isConnected }
        print("Checking if all sensors are connected. Result: \(allConnected)")

        if allConnected {
            print("All sensors connected. Stopping scan.")
            stopScanning()
            DispatchQueue.main.async {
                self.isScanning = false // Ensure UI reflects the stopped scan state
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
        print("Discovered peripheral with UUID: \(peripheralUUID)")

        // Check if the discovered peripheral matches any sensor
        if let sensor = sensors.first(where: { $0.macAddress == peripheralUUID }) {
            print("Matched sensor with UUID: \(peripheralUUID)")
            discoveredPeripherals[peripheralUUID] = peripheral
            
            // Mark the sensor as connected
            updateSensorConnectionStatus(uuid: peripheralUUID, isConnected: true)
            
            // Connect to the peripheral
            centralManager.connect(peripheral, options: nil)
        } else {
            print("Peripheral with UUID \(peripheralUUID) does not match any known sensors.")
        }
    }

    /// Handles successful connection to a Bluetooth peripheral.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let uuid = peripheral.identifier.uuidString
        print("Successfully connected to peripheral with UUID: \(uuid)")

        // Check if the connected peripheral matches any sensor
        if let sensor = sensors.first(where: { $0.macAddress == uuid }) {
            updateSensorConnectionStatus(uuid: uuid, isConnected: true)
            peripheral.delegate = self
            print("Discovering services for peripheral with UUID: \(uuid)")
            peripheral.discoverServices([CBUUID(string: "180D")]) // Heart Rate Service UUID

            // Check if all sensors are connected
            checkIfAllSensorsConnected() // <-- Check and stop scanning here if needed
        } else {
            print("Error: Connected peripheral with UUID \(uuid) does not match any sensor in the list.")
        }
    }

    /// Handles the discovery of services on a connected Bluetooth peripheral.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }

        if let services = peripheral.services {
            for service in services {
                print("Discovered service with UUID: \(service.uuid)")
                if service.uuid == CBUUID(string: "180D") { // Heart Rate Service UUID
                    print("Discovering characteristics for service with UUID: \(service.uuid)")
                    peripheral.discoverCharacteristics([CBUUID(string: "2A37")], for: service) // Heart Rate Measurement UUID
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
                if characteristic.uuid == CBUUID(string: "2A37") { // Heart Rate Measurement UUID
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
            print("Heart Rate: \(heartRate), IBI: \(IBI)")

            // Ensure IBI array has the expected number of elements before accessing
            if !IBI.isEmpty {
                if let sensorID = sensors.first(where: { $0.macAddress == peripheral.identifier.uuidString })?.id {
                    sensorDataProcessor.updateHRData(sensorID: sensorID, ibiArray: IBI)

                    // Print statistics, HRV, and distance matrix
                    if let stats = sensorDataProcessor.calculateStatistics(sensorID: sensorID) {
                        print("Sensor \(sensorID) Stats - Min: \(stats.min), Max: \(stats.max), Median: \(stats.median), Mean: \(stats.mean)")
                    }
                    let hrvArray = sensorDataProcessor.getHRVData(sensorID: sensorID)
                    print("Sensor \(sensorID) HRV Array: \(hrvArray)")
                    let distancesMatrix = sensorDataProcessor.getDistanceMatrix()
                    print("Distances Matrix: \(distancesMatrix)")
                    let correlationMatrix = sensorDataProcessor.getCorrelationMatrix()
                    print("Correlation Matrix: \(correlationMatrix)")
                    let crossEntropyMatrix = sensorDataProcessor.getCrossEntropyMatrix()
                    print("Cross-Entropy Matrix: \(crossEntropyMatrix)")
                    let proximityMatrix = sensorDataProcessor.getProximityMatrix()
                    print("Proximity Matrix: \(proximityMatrix)")
                    let mutualInformationMatrix = sensorDataProcessor.getMutualInformationMatrix()
                    print("Mutual Information Matrix: \(mutualInformationMatrix)")

                    // Update clusters
                    sensorDataProcessor.updateClusterState(sensorIDs: sensors.compactMap { $0.id }, proximityMatrix: proximityMatrix)
                    print("Soft Clusters: \(sensorDataProcessor.getSoftClusters())")
                    print("Hard Clusters: \(sensorDataProcessor.getHardClusters())")
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
}
