//
//  BluetoothManager.swift.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 24/07/2024.
//

import CoreBluetooth
import CoreData
import Foundation

class BluetoothManager: NSObject, ObservableObject {
    @Published var sensors: [SensorEntity] = []
    @Published var isScanning = false
    
    private var centralManager: CBCentralManager!
    private var discoveredPeripherals: [String: CBPeripheral] = [:]
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        fetchSensors()
    }
    
    func fetchSensors() {
        let fetchRequest: NSFetchRequest<SensorEntity> = SensorEntity.fetchRequest()
        do {
            sensors = try CoreDataStack.shared.context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch sensors: \(error)")
        }
    }
    
    func startScanning() {
        isScanning = true
        centralManager.scanForPeripherals(withServices: [CBUUID(string: "180D")], options: nil)
    }
    
    func stopScanning() {
        isScanning = false
        centralManager.stopScan()
    }
    
    func connectToSensors() {
        for sensor in sensors where discoveredPeripherals[sensor.macAddress] != nil {
            let peripheral = discoveredPeripherals[sensor.macAddress]!
            centralManager.connect(peripheral, options: nil)
        }
    }
}

extension BluetoothManager: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            stopScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let macAddress = peripheral.identifier.uuidString
        if let sensor = sensors.first(where: { $0.macAddress == macAddress }) {
            discoveredPeripherals[macAddress] = peripheral
            sensor.isConnected = true
            stopScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let macAddress = peripheral.identifier.uuidString as String?,
           let sensor = sensors.first(where: { $0.macAddress == macAddress }) {
            sensor.isConnected = true
            peripheral.delegate = self
            peripheral.discoverServices([CBUUID(string: "180D")])
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == CBUUID(string: "180D") {
                    peripheral.discoverCharacteristics([CBUUID(string: "2A37")], for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: "2A37") {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
}
