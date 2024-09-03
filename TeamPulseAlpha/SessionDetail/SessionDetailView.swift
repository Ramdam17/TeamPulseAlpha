//
//  SessionDetailView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import CoreData
import SwiftUI

/// The `SessionDetailView` class is responsible for displaying detailed session data.
/// This includes sensor data, matrix data, and cluster state data.
/// The view also provides functionality to export session data as a JSON file.
struct SessionDetailView: View {
    @State private var selectedTab: Int = 0  // Tracks the currently selected tab
    let sessionID: SessionEntity  // The session entity for which data is being displayed

    // Arrays to store various types of session data
    @State private var hrDataArray: [[String: Any]] = []
    @State private var ibiDataArray: [[String: Any]] = []
    @State private var hrvDataArray: [[String: Any]] = []
    @State private var proximityMatrixArray: [[String: Any]] = []
    @State private var correlationMatrixArray: [[String: Any]] = []
    @State private var crossEntropyMatrixArray: [[String: Any]] = []
    @State private var conditionalEntropyMatrixArray: [[String: Any]] = []
    @State private var mutualInformationMatrixArray: [[String: Any]] = []
    @State private var clusterStateArray: [[String: Any]] = []

    @State private var isLoading: Bool = true  // Tracks whether data is still loading
    @State private var sensors: [SensorEntity] = []  // Stores the associated sensors for the session
    @State private var sessionJSONData: Data?  // Stores the session data in JSON format

    var body: some View {
        ZStack {
            Color("CustomYellow").ignoresSafeArea()  // Background color

            if isLoading {
                // Loading indicator shown while data is being fetched
                ProgressView("Loading session data...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .foregroundColor(.black)
                    .scaleEffect(1.5)
            } else {
                VStack {
                    // TabView for swipeable navigation between different data views
                    TabView(selection: $selectedTab) {
                        // Sensor Data View
                        SessionSensorDataDetailView(
                            hrDataArray: hrDataArray,
                            ibiDataArray: ibiDataArray,
                            hrvDataArray: hrvDataArray
                        )
                        .tag(0)
                        .padding()

                        // Matrix Data View
                        SessionMatriceDataDetailView(
                            correlationMatrixArray: correlationMatrixArray,
                            crossEntropyMatrixArray: crossEntropyMatrixArray,
                            conditionalEntropyMatrixArray: conditionalEntropyMatrixArray,
                            mutualInformationMatrixArray: mutualInformationMatrixArray
                        )
                        .tag(1)
                        .padding()

                        // Cluster Data View
                        SessionClusterDataDetailView(
                            clusterStateArray: clusterStateArray,
                            proximityMatrixArray: proximityMatrixArray
                        )
                        .tag(2)
                        .padding()
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                    // Bottom menu for tab navigation and export button
                    HStack {
                        Spacer()

                        // Sensor Data Tab Button
                        Button(action: { selectedTab = 0 }) {
                            Text("Sensor Data")
                                .font(.headline)
                                .padding()
                                .foregroundColor(selectedTab == 0 ? .black : .gray)
                        }
                        Spacer()

                        // Matrix Data Tab Button
                        Button(action: { selectedTab = 1 }) {
                            Text("Matrices")
                                .font(.headline)
                                .padding()
                                .foregroundColor(selectedTab == 1 ? .black : .gray)
                        }
                        Spacer()

                        // Cluster Data Tab Button
                        Button(action: { selectedTab = 2 }) {
                            Text("Clusters")
                                .font(.headline)
                                .padding()
                                .foregroundColor(selectedTab == 2 ? .black : .gray)
                        }
                        Spacer()

                        // Export Session Data Button
                        Button(action: { exportSession() }) {
                            Text("Export")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color("CustomYellow"))
                                .cornerRadius(5)
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                    .frame(height: 10)
                    .padding()
                    .background(Color.white.opacity(0.8))
                }
            }
        }
        .onAppear {
            // Load session data and associated sensor data when the view appears
            loadSessionData(sessionID: sessionID)
            fetchSensorEntities()
            sessionJSONData = jsonData(from: createSessionJSON())
        }
    }

    /// Fetches the sensor entities associated with the session from Core Data.
    private func fetchSensorEntities() {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<SensorEntity> = SensorEntity.fetchRequest()

        do {
            sensors = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch sensors: \(error)")
        }
    }

    /// Loads session data from Core Data, including sensor events, matrix data, and cluster data.
    /// - Parameter sessionID: The session entity for which data is being fetched.
    private func loadSessionData(sessionID: SessionEntity) {
        let context = CoreDataStack.shared.context

        // Fetch sensor data events
        fetchSensorDataEvents(sessionID: sessionID, context: context)

        // Fetch matrix data events
        fetchMatrixDataEvents(sessionID: sessionID, context: context)

        // Fetch cluster data events
        fetchClusterDataEvents(sessionID: sessionID, context: context)

        isLoading = false  // Data loading complete
    }

    /// Fetches sensor data events for the specified session.
    /// - Parameters:
    ///   - sessionID: The session entity for which data is being fetched.
    ///   - context: The Core Data context.
    private func fetchSensorDataEvents(sessionID: SessionEntity, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<SensorDataEvent> = SensorDataEvent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "session == %@", sessionID)

        do {
            let events = try context.fetch(fetchRequest)
            for event in events {
                if let timestamp = event.timestamp {
                    hrDataArray.append([
                        "timestamp": timestamp,
                        "sensorUUID": event.sensor?.uuid ?? "",
                        "hrValue": event.hrData,
                    ])
                    ibiDataArray.append([
                        "timestamp": timestamp,
                        "sensorUUID": event.sensor?.uuid ?? "",
                        "ibiValue": event.ibiData,
                    ])
                    hrvDataArray.append([
                        "timestamp": timestamp,
                        "sensorUUID": event.sensor?.uuid ?? "",
                        "hrvValue": event.hrvData,
                    ])
                }
            }
        } catch {
            print("Failed to fetch sensor data events: \(error)")
        }
    }

    /// Fetches matrix data events for the specified session.
    /// - Parameters:
    ///   - sessionID: The session entity for which data is being fetched.
    ///   - context: The Core Data context.
    private func fetchMatrixDataEvents(sessionID: SessionEntity, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<MatrixDataEvent> = MatrixDataEvent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "session == %@", sessionID)

        do {
            let events = try context.fetch(fetchRequest)
            for event in events {
                if let timestamp = event.timestamp {
                    appendMatrixData(event: event, timestamp: timestamp)
                }
            }
        } catch {
            print("Failed to fetch matrix data events: \(error)")
        }
    }

    /// Fetches cluster data events for the specified session.
    /// - Parameters:
    ///   - sessionID: The session entity for which data is being fetched.
    ///   - context: The Core Data context.
    private func fetchClusterDataEvents(sessionID: SessionEntity, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<ClusterDataEvent> = ClusterDataEvent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "session == %@", sessionID)

        do {
            let events = try context.fetch(fetchRequest)
            for event in events {
                if let timestamp = event.timestamp {
                    appendClusterData(event: event, timestamp: timestamp)
                }
            }
        } catch {
            print("Failed to fetch cluster data events: \(error)")
        }
    }

    /// Appends matrix data to the appropriate arrays based on the event type.
    /// - Parameters:
    ///   - event: The matrix data event containing the data to append.
    ///   - timestamp: The timestamp associated with the data.
    private func appendMatrixData(event: MatrixDataEvent, timestamp: Date) {
        if let proximityData = event.proximityMatrix {
            let proximityMatrix = ArrayTransformer().reverseTransformDataToMatrix(proximityData) ?? []
            proximityMatrixArray.append(["timestamp": timestamp, "matrix": proximityMatrix])
        }

        if let correlationData = event.correlationMatrix {
            let correlationMatrix = ArrayTransformer().reverseTransformDataToMatrix(correlationData) ?? []
            correlationMatrixArray.append(["timestamp": timestamp, "matrix": correlationMatrix])
        }

        if let crossEntropyData = event.crossEntropyMatrix {
            let crossEntropyMatrix = ArrayTransformer().reverseTransformDataToMatrix(crossEntropyData) ?? []
            crossEntropyMatrixArray.append(["timestamp": timestamp, "matrix": crossEntropyMatrix])
        }

        if let conditionalEntropyData = event.conditionalEntropyMatrix {
            let conditionalEntropyMatrix = ArrayTransformer().reverseTransformDataToMatrix(conditionalEntropyData) ?? []
            conditionalEntropyMatrixArray.append(["timestamp": timestamp, "matrix": conditionalEntropyMatrix])
        }

        if let mutualInformationData = event.mutualInformationMatrix {
            let mutualInformationMatrix = ArrayTransformer().reverseTransformDataToMatrix(mutualInformationData) ?? []
            mutualInformationMatrixArray.append(["timestamp": timestamp, "matrix": mutualInformationMatrix])
        }
    }

    /// Appends cluster state data to the appropriate array.
    /// - Parameters:
    ///   - event: The cluster data event containing the data to append.
    ///   - timestamp: The timestamp associated with the data.
    private func appendClusterData(event: ClusterDataEvent, timestamp: Date) {
        if let clusterStateData = event.clusterState {
            let clusterState = ArrayTransformer().reverseTransformDataToClusterState(clusterStateData) ?? []
            clusterStateArray.append(["timestamp": timestamp, "clusterState": clusterState])
        }
    }

    /// Saves the session data as a JSON file and presents a share sheet for exporting the file.
    private func exportSession() {
        guard let jsonData = sessionJSONData else {
            print("Failed to create JSON data.")
            return
        }

        if let fileURL = saveJSONToFile(data: jsonData) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let topController = windowScene.windows.first?.rootViewController {

                let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceView = topController.view  // Setting the source view
                    popoverController.sourceRect = CGRect(
                        x: topController.view.bounds.midX,
                        y: topController.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }

                topController.present(activityViewController, animated: true, completion: nil)
            }
        }
    }

    /// Creates a JSON representation of the session data, including metadata, sensor data, and matrices.
    /// - Returns: A dictionary representing the session data in JSON format.
    private func createSessionJSON() -> [String: Any] {
        var sessionData: [String: Any] = [:]

        // Metadata section
        var metadata: [String: Any] = [:]

        // Session information
        if let startTime = sessionID.startTime, let endTime = sessionID.endTime {
            metadata["session"] = [
                "startTime": dateFormatter.string(from: startTime),
                "endTime": dateFormatter.string(from: endTime),
            ]
        }

        // Sensor entities information
        let sensorInfo = sensors.compactMap { sensor -> [String: String]? in
            guard let name = sensor.name, let uuid = sensor.uuid else {
                return nil
            }
            return ["name": name, "uuid": uuid]
        }
        metadata["sensors"] = sensorInfo

        sessionData["metadata"] = metadata

        // Convert and add sensor data arrays
        sessionData["hrData"] = formatDataArray(hrDataArray)
        sessionData["ibiData"] = formatDataArray(ibiDataArray)
        sessionData["hrvData"] = formatDataArray(hrvDataArray)

        // Convert and add matrix arrays
        sessionData["proximityMatrix"] = formatMatrixArray(proximityMatrixArray)
        sessionData["correlationMatrix"] = formatMatrixArray(correlationMatrixArray)
        sessionData["crossEntropyMatrix"] = formatMatrixArray(crossEntropyMatrixArray)
        sessionData["conditionalEntropyMatrix"] = formatMatrixArray(conditionalEntropyMatrixArray)
        sessionData["mutualInformationMatrix"] = formatMatrixArray(mutualInformationMatrixArray)

        // Convert and add cluster state array
        sessionData["clusterState"] = formatClusterStateArray(clusterStateArray)

        return sessionData
    }

    /// Saves the session data as a JSON file in the document directory.
    /// - Parameter data: The JSON data to save.
    /// - Returns: The URL of the saved file, or `nil` if the save failed.
    private func saveJSONToFile(data: Data) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let formattedDate = dateFormatter.string(from: sessionID.startTime ?? Date())
        let fileName = "session-\(formattedDate).json"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save JSON to file: \(error)")
            return nil
        }
    }

    /// Formats a data array for inclusion in the JSON output.
    /// - Parameter dataArray: The data array to format.
    /// - Returns: A formatted array where timestamps are converted to strings.
    private func formatDataArray(_ dataArray: [[String: Any]]) -> [[String: Any]] {
        return dataArray.map { dict -> [String: Any] in
            var formattedDict = dict
            if let date = dict["timestamp"] as? Date {
                formattedDict["timestamp"] = dateFormatter.string(from: date)
            }
            return formattedDict
        }
    }

    /// Formats a matrix array for inclusion in the JSON output.
    /// - Parameter matrixArray: The matrix array to format.
    /// - Returns: A formatted array where timestamps are converted to strings.
    private func formatMatrixArray(_ matrixArray: [[String: Any]]) -> [[String: Any]] {
        return matrixArray.map { dict -> [String: Any] in
            var formattedDict = dict
            if let date = dict["timestamp"] as? Date {
                formattedDict["timestamp"] = dateFormatter.string(from: date)
            }
            formattedDict["matrix"] = dict["matrix"] ?? []
            return formattedDict
        }
    }

    /// Formats a cluster state array for inclusion in the JSON output.
    /// - Parameter clusterStateArray: The cluster state array to format.
    /// - Returns: A formatted array where timestamps are converted to strings.
    private func formatClusterStateArray(_ clusterStateArray: [[String: Any]]) -> [[String: Any]] {
        return clusterStateArray.map { dict -> [String: Any] in
            var formattedDict = dict
            if let date = dict["timestamp"] as? Date {
                formattedDict["timestamp"] = dateFormatter.string(from: date)
            }
            formattedDict["clusterState"] = dict["clusterState"] ?? []
            return formattedDict
        }
    }

    /// Converts a dictionary to JSON data.
    /// - Parameter dictionary: The dictionary to convert.
    /// - Returns: The JSON data, or `nil` if conversion failed.
    private func jsonData(from dictionary: [String: Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
    }

    /// A date formatter for converting dates to strings in ISO8601 format.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"  // ISO8601 format
        return formatter
    }()
}

struct SessionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock or placeholder `SessionEntity` for the preview
        let context = CoreDataStack.shared.context
        let mockSession = SessionEntity(context: context)
        mockSession.id = UUID()
        mockSession.startTime = Date()

        return SessionDetailView(sessionID: mockSession)
    }
}
