//
//  SessionSensorDataDetailView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import SwiftUI
import CoreData

struct SessionSensorDataDetailView: View {

    let hrDataArray: [[String: Any]]
    let ibiDataArray: [[String: Any]]
    let hrvDataArray: [[String: Any]]

    @State private var sensorUUIDMapping: [String: String] = [:]

    var body: some View {
        GeometryReader { metrics in
            VStack {
                if let blueUUID = sensorUUIDMapping["Blue"] {
                    SessionSensorDataDetailRowView(
                        hrDataArray: filterDataArray(hrDataArray, by: blueUUID),
                        ibiDataArray: filterDataArray(ibiDataArray, by: blueUUID),
                        hrvDataArray: filterDataArray(hrvDataArray, by: blueUUID),
                        color: .blue
                    )
                    .frame(
                        width: metrics.size.width,
                        height: metrics.size.height * 0.3
                    )
                }

                Spacer()
                

                if let greenUUID = sensorUUIDMapping["Green"] {
                    SessionSensorDataDetailRowView(
                        hrDataArray: filterDataArray(hrDataArray, by: greenUUID),
                        ibiDataArray: filterDataArray(ibiDataArray, by: greenUUID),
                        hrvDataArray: filterDataArray(hrvDataArray, by: greenUUID),
                        color: .green
                    )
                    .frame(
                        width: metrics.size.width,
                        height: metrics.size.height * 0.3
                    )
                }

                Spacer()

                if let redUUID = sensorUUIDMapping["Red"] {
                    SessionSensorDataDetailRowView(
                        hrDataArray: filterDataArray(hrDataArray, by: redUUID),
                        ibiDataArray: filterDataArray(ibiDataArray, by: redUUID),
                        hrvDataArray: filterDataArray(hrvDataArray, by: redUUID),
                        color: .red
                    )
                    .frame(
                        width: metrics.size.width,
                        height: metrics.size.height * 0.3
                    )
                }
            }
        }
        .padding()
        .onAppear {
            loadSensorUUIDMapping()
        }
    }

    /// Fetch sensors and map UUIDs to names (e.g., "Blue", "Green", "Red").
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

        let fakeHRDataArray: [[String: Any]] = [
            ["timestamp": Date(), "sensorUUID": "0F099F27-18D8-8ACC-C895-54AC2C36C790", "hrValue": 72.0],
            ["timestamp": Date(), "sensorUUID": "F3742462-63F6-131A-C487-9F78D8A4FCCC", "hrValue": 68.0],
            ["timestamp": Date(), "sensorUUID": "EA61A349-6EFF-9A05-F9C1-F610C171579F", "hrValue": 75.0],
        ]

        let fakeIBIDataArray: [[String: Any]] = [
            ["timestamp": Date(), "sensorUUID": "0F099F27-18D8-8ACC-C895-54AC2C36C790", "ibiValue": 0.85],
            ["timestamp": Date(), "sensorUUID": "F3742462-63F6-131A-C487-9F78D8A4FCCC", "ibiValue": 0.89],
            ["timestamp": Date(), "sensorUUID": "EA61A349-6EFF-9A05-F9C1-F610C171579F", "ibiValue": 0.80],
        ]

        let fakeHRVDataArray: [[String: Any]] = [
            ["timestamp": Date(), "sensorUUID": "0F099F27-18D8-8ACC-C895-54AC2C36C790", "hrvValue": 55.0],
            ["timestamp": Date(), "sensorUUID": "F3742462-63F6-131A-C487-9F78D8A4FCCC", "hrvValue": 60.0],
            ["timestamp": Date(), "sensorUUID": "EA61A349-6EFF-9A05-F9C1-F610C171579F", "hrvValue": 50.0],
        ]

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
