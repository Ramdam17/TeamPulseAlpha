//
//  SessionSensorDataDetailView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import CoreData
import SwiftUI

struct SessionSensorDataDetailView: View {
    let hrDataArray: [[String: Any]]  // Array containing heart rate data
    let ibiDataArray: [[String: Any]]  // Array containing IBI data
    let hrvDataArray: [[String: Any]]  // Array containing HRV data

    @State private var sensorUUIDMapping: [String: String] = [:]  // Mapping of sensor names to UUIDs

    var body: some View {
        ScrollView {
            VStack {
                // Display data for the "Blue" sensor, if the UUID is available
                if let blueUUID = sensorUUIDMapping["Blue"] {
                    SessionSensorDataDetailRowView(
                        hrDataArray: filterDataArray(hrDataArray, by: blueUUID),
                        ibiDataArray: filterDataArray(ibiDataArray, by: blueUUID),
                        hrvDataArray: filterDataArray(hrvDataArray, by: blueUUID),
                        color: .blue
                    )
                    .frame(height: 400)
                }

                Spacer()

                // Display data for the "Green" sensor, if the UUID is available
                if let greenUUID = sensorUUIDMapping["Green"] {
                    SessionSensorDataDetailRowView(
                        hrDataArray: filterDataArray(hrDataArray, by: greenUUID),
                        ibiDataArray: filterDataArray(ibiDataArray, by: greenUUID),
                        hrvDataArray: filterDataArray(hrvDataArray, by: greenUUID),
                        color: .green
                    )
                    .frame(height: 400)
                }

                Spacer()

                // Display data for the "Red" sensor, if the UUID is available
                if let redUUID = sensorUUIDMapping["Red"] {
                    SessionSensorDataDetailRowView(
                        hrDataArray: filterDataArray(hrDataArray, by: redUUID),
                        ibiDataArray: filterDataArray(ibiDataArray, by: redUUID),
                        hrvDataArray: filterDataArray(hrvDataArray, by: redUUID),
                        color: .red
                    )
                    .frame(height: 400)
                }
            }
            .padding()
            .onAppear {
                loadSensorUUIDMapping()  // Load sensor UUID mappings when the view appears
            }
        }
    }

    /// Fetch sensors from Core Data and map UUIDs to names (e.g., "Blue", "Green", "Red").
    private func loadSensorUUIDMapping() {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<SensorEntity> = SensorEntity.fetchRequest()

        do {
            let sensors = try context.fetch(fetchRequest)
            var mapping: [String: String] = [:]
            for sensor in sensors {
                if let name = sensor.name, let uuid = sensor.uuid {
                    mapping[name] = uuid
                }
            }
            sensorUUIDMapping = mapping
        } catch {
            print("Failed to fetch sensors: \(error)")
        }
    }

    /// Filters a data array by the provided sensor UUID.
    private func filterDataArray(_ dataArray: [[String: Any]], by uuid: String) -> [[String: Any]] {
        return dataArray.filter { $0["sensorUUID"] as? String == uuid }
    }
}

struct SessionSensorDataDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Creating fake HR, IBI, and HRV data arrays
        var fakeHRDataArray: [[String: Any]] = []
        var fakeIBIDataArray: [[String: Any]] = []
        var fakeHRVDataArray: [[String: Any]] = []

        for i in 0...60 {
            fakeHRDataArray.append([
                "timestamp": Date().addingTimeInterval(Double(i)),
                "sensorUUID": "0F099F27-18D8-8ACC-C895-54AC2C36C790",
                "hrValue": Double.random(in: 40..<200),
            ])
            fakeHRDataArray.append([
                "timestamp": Date().addingTimeInterval(Double(i)),
                "sensorUUID": "BBB",
                "hrValue": Double.random(in: 40..<200),
            ])
            fakeHRDataArray.append([
                "timestamp": Date().addingTimeInterval(Double(i)),
                "sensorUUID": "CCC",
                "hrValue": Double.random(in: 40..<200),
            ])
        }

        for i in 0...60 {
            fakeIBIDataArray.append([
                "timestamp": Date().addingTimeInterval(Double(i)),
                "sensorUUID": "0F099F27-18D8-8ACC-C895-54AC2C36C790",
                "ibiValue": Double.random(in: 0..<1.0),
            ])
            fakeIBIDataArray.append([
                "timestamp": Date().addingTimeInterval(Double(i)),
                "sensorUUID": "BBB",
                "ibiValue": Double.random(in: 0..<1.0),
            ])
            fakeIBIDataArray.append([
                "timestamp": Date().addingTimeInterval(Double(i)),
                "sensorUUID": "CCC",
                "ibiValue": Double.random(in: 0..<1.0),
            ])
        }

        for i in 0...60 {
            fakeHRVDataArray.append([
                "timestamp": Date().addingTimeInterval(Double(i)),
                "sensorUUID": "0F099F27-18D8-8ACC-C895-54AC2C36C790",
                "hrvValue": Double.random(in: 0..<0.5),
            ])
            fakeHRVDataArray.append([
                "timestamp": Date().addingTimeInterval(Double(i)),
                "sensorUUID": "BBB",
                "hrvValue": Double.random(in: 0..<0.5),
            ])
            fakeHRVDataArray.append([
                "timestamp": Date().addingTimeInterval(Double(i)),
                "sensorUUID": "CCC",
                "hrvValue": Double.random(in: 0..<0.5),
            ])
        }

        // Preview with fake data
        return SessionSensorDataDetailView(
            hrDataArray: fakeHRDataArray,
            ibiDataArray: fakeIBIDataArray,
            hrvDataArray: fakeHRVDataArray
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
