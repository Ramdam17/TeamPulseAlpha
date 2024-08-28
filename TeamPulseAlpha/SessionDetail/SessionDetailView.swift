//
//  SessionDetailView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/26/24.
//

import CoreData
import SwiftUI

struct SessionDetailView: View {
    @State private var selectedTab: Int = 0
    let sessionID: SessionEntity

    @State private var hrDataArray: [[String: Any]] = []
    @State private var ibiDataArray: [[String: Any]] = []
    @State private var hrvDataArray: [[String: Any]] = []
    @State private var proximityMatrixArray: [[String: Any]] = []
    @State private var correlationMatrixArray: [[String: Any]] = []
    @State private var crossEntropyMatrixArray: [[String: Any]] = []
    @State private var conditionalEntropyMatrixArray: [[String: Any]] = []
    @State private var mutualInformationMatrixArray: [[String: Any]] = []
    @State private var clusterStateArray: [[String: Any]] = []

    @State private var isLoading: Bool = true
    @State private var sensors: [SensorEntity] = []
    @State private var sessionJSONData: Data?  // Store JSON data

    var body: some View {
        ZStack {
            Color("CustomYellow").ignoresSafeArea()

            if isLoading {
                ProgressView("Loading session data...")  // Shows a loading indicator
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .foregroundColor(.black)
                    .scaleEffect(1.5)
            } else {
                VStack {
                    // Subview container with swipe navigation
                    TabView(selection: $selectedTab) {
                        SessionSensorDataDetailView(
                            hrDataArray: hrDataArray,
                            ibiDataArray: ibiDataArray,
                            hrvDataArray: hrvDataArray
                        )
                        .tag(0)
                        .padding()

                        SessionMatriceDataDetailView(
                            correlationMatrixArray: correlationMatrixArray,
                            crossEntropyMatrixArray: crossEntropyMatrixArray,
                            conditionalEntropyMatrixArray:
                                conditionalEntropyMatrixArray,
                            mutualInformationMatrixArray:
                                mutualInformationMatrixArray
                        )
                        .tag(1)
                        .padding()

                        SessionClusterDataDetailView(
                            clusterStateArray: clusterStateArray,
                            proximityMatrixArray: proximityMatrixArray
                        )
                        .tag(2)
                        .padding()

                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(maxHeight: .infinity)

                    // Bottom menu for navigation
                    HStack {

                        Spacer()
                        Button(action: { selectedTab = 0 }) {
                            Text("Sensor Data")
                                .font(.headline)
                                .foregroundColor(
                                    selectedTab == 0 ? .black : .gray)
                        }
                        Spacer()
                        Button(action: { selectedTab = 1 }) {
                            Text("Matrices")
                                .font(.headline)
                                .foregroundColor(
                                    selectedTab == 1 ? .black : .gray)
                        }
                        Spacer()
                        Button(action: { selectedTab = 2 }) {
                            Text("Clusters")
                                .font(.headline)
                                .foregroundColor(
                                    selectedTab == 2 ? .black : .gray)
                        }
                        Spacer()

                        Button(action: { exportSession() }) {
                            Text("Export")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.yellow)
                                .cornerRadius(10)
                        }
                        Spacer()
                    }
                    .frame(height: 50)
                    .padding()
                    .background(Color.white.opacity(0.9))
                }
            }
        }
        .onAppear {
            loadSessionData(sessionID: sessionID)
            fetchSensorEntities()
            sessionJSONData = jsonData(from: createSessionJSON())
        }

    }

    /// Function to load sensor entities associated with the session
    private func fetchSensorEntities() {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<SensorEntity> =
            SensorEntity.fetchRequest()

        do {
            sensors = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch sensors: \(error)")
        }
    }

    private func loadSessionData(sessionID: SessionEntity) {

        let context = CoreDataStack.shared.context
        let fetchSensorDataEventRequest: NSFetchRequest<SensorDataEvent> =
            SensorDataEvent.fetchRequest()
        fetchSensorDataEventRequest.predicate = NSPredicate(
            format: "session == %@", sessionID)

        do {
            let events = try context.fetch(fetchSensorDataEventRequest)

            for event in events {
                if let timestamp = event.timestamp {
                    // HR Data
                    let hrDict: [String: Any] = [
                        "timestamp": timestamp,
                        "sensorUUID": event.sensor?.uuid ?? "",
                        "hrValue": event.hrData,
                    ]
                    hrDataArray.append(hrDict)

                    // IBI Data
                    let ibiDict: [String: Any] = [
                        "timestamp": timestamp,
                        "sensorUUID": event.sensor?.uuid ?? "",
                        "ibiValue": event.ibiData,
                    ]
                    ibiDataArray.append(ibiDict)

                    // HRV Data
                    let hrvDict: [String: Any] = [
                        "timestamp": timestamp,
                        "sensorUUID": event.sensor?.uuid ?? "",
                        "hrvValue": event.hrvData,
                    ]
                    hrvDataArray.append(hrvDict)

                }
            }
        } catch {
            print("Failed to fetch events for session \(sessionID): \(error)")
        }

        let fetchMatrixDataEventRequest: NSFetchRequest<MatrixDataEvent> =
            MatrixDataEvent.fetchRequest()
        fetchMatrixDataEventRequest.predicate = NSPredicate(
            format: "session == %@", sessionID)

        do {
            let events = try context.fetch(fetchMatrixDataEventRequest)

            for event in events {
                if let timestamp = event.timestamp {

                    // Proximity Matrix
                    if let proximityData = event.proximityMatrix {
                        let proximityMatrix =
                            ArrayTransformer().reverseTransformDataToMatrix(
                                proximityData) ?? []
                        let proximityDict: [String: Any] = [
                            "timestamp": timestamp,
                            "matrix": proximityMatrix,
                        ]
                        proximityMatrixArray.append(proximityDict)
                    }

                    // Correlation Matrix
                    if let correlationData = event.correlationMatrix {
                        let correlationMatrix =
                            ArrayTransformer().reverseTransformDataToMatrix(
                                correlationData) ?? []
                        let correlationDict: [String: Any] = [
                            "timestamp": timestamp,
                            "matrix": correlationMatrix,
                        ]
                        correlationMatrixArray.append(correlationDict)
                    }

                    // Cross Entropy Matrix
                    if let crossEntropyData = event.crossEntropyMatrix {
                        let crossEntropyMatrix =
                            ArrayTransformer().reverseTransformDataToMatrix(
                                crossEntropyData) ?? []
                        let crossEntropyDict: [String: Any] = [
                            "timestamp": timestamp,
                            "matrix": crossEntropyMatrix,
                        ]
                        crossEntropyMatrixArray.append(crossEntropyDict)
                    }

                    // Conditional Entropy Matrix
                    if let conditionalEntropyData = event
                        .conditionalEntropyMatrix
                    {
                        let conditionalEntropyMatrix =
                            ArrayTransformer().reverseTransformDataToMatrix(
                                conditionalEntropyData) ?? []
                        let conditionalEntropyDict: [String: Any] = [
                            "timestamp": timestamp,
                            "matrix":
                                conditionalEntropyMatrix,
                        ]
                        conditionalEntropyMatrixArray.append(
                            conditionalEntropyDict)
                    }

                    // Mutual Information Matrix
                    if let mutualInformationData = event.mutualInformationMatrix
                    {
                        let mutualInformationMatrix =
                            ArrayTransformer().reverseTransformDataToMatrix(
                                mutualInformationData) ?? []
                        let mutualInformationDict: [String: Any] = [
                            "timestamp": timestamp,
                            "matrix": mutualInformationMatrix,
                        ]
                        mutualInformationMatrixArray.append(
                            mutualInformationDict)
                    }
                }
            }
        } catch {
            print("Failed to fetch events for session \(sessionID): \(error)")
        }

        let fetchClusterDataEventRequest: NSFetchRequest<ClusterDataEvent> =
            ClusterDataEvent.fetchRequest()
        fetchClusterDataEventRequest.predicate = NSPredicate(
            format: "session == %@", sessionID)

        do {
            let events = try context.fetch(fetchClusterDataEventRequest)

            for event in events {
                if let timestamp = event.timestamp {

                    // Cluster State
                    if let clusterStateData = event.clusterState {
                        let clusterState =
                            ArrayTransformer()
                            .reverseTransformDataToClusterState(
                                clusterStateData) ?? []
                        let clusterStateDict: [String: Any] = [
                            "timestamp": timestamp,
                            "clusterState": clusterState,
                        ]
                        clusterStateArray.append(clusterStateDict)
                    }
                }
            }
        } catch {
            print("Failed to fetch events for session \(sessionID): \(error)")
        }
    }

    private func saveJSONToFile(data: Data) -> URL? {

        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask
        ).first!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"  // Adjust the format as needed
        let formattedDate = dateFormatter.string(
            from: sessionID.startTime ?? Date())

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

    private func exportSession() {
        guard let jsonData = sessionJSONData else {
            print("Failed to create JSON data.")
            return
        }

        if let fileURL = saveJSONToFile(data: jsonData) {
            if let windowScene = UIApplication.shared.connectedScenes.first
                as? UIWindowScene,
                let topController = windowScene.windows.first?
                    .rootViewController
            {

                let activityViewController = UIActivityViewController(
                    activityItems: [fileURL], applicationActivities: nil)

                if let popoverController = activityViewController
                    .popoverPresentationController
                {
                    popoverController.sourceView = topController.view  // Setting the source view
                    popoverController.sourceRect = CGRect(
                        x: topController.view.bounds.midX,
                        y: topController.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }

                topController.present(
                    activityViewController, animated: true, completion: nil)
            }
        }
    }

    private func createSessionJSON() -> [String: Any] {
        var sessionData: [String: Any] = [:]

        // Metadata section
        var metadata: [String: Any] = [:]

        // Session information
        if let startTime = sessionID.startTime, let endTime = sessionID.endTime
        {
            metadata["session"] = [
                "startTime": dateFormatter.string(from: startTime),
                "endTime": dateFormatter.string(from: endTime),
            ]
        }

        // Sensor entities information
        let sensorInfo =
            sensors.compactMap {
                sensor -> [String: String]? in
                guard let name = sensor.name, let uuid = sensor.uuid else {
                    return nil
                }
                return ["name": name, "uuid": uuid]
            }
        metadata["sensors"] = sensorInfo

        sessionData["metadata"] = metadata

        // Convert and add hrDataArray
        let hrDataArrayFormatted = hrDataArray.map { dict -> [String: Any] in
            var formattedDict = dict
            if let date = dict["timestamp"] as? Date {
                formattedDict["timestamp"] = dateFormatter.string(from: date)
            }
            return formattedDict
        }
        sessionData["hrData"] = hrDataArrayFormatted

        // Convert and add ibiDataArray
        let ibiDataArrayFormatted = ibiDataArray.map { dict -> [String: Any] in
            var formattedDict = dict
            if let date = dict["timestamp"] as? Date {
                formattedDict["timestamp"] = dateFormatter.string(from: date)
            }
            return formattedDict
        }
        sessionData["ibiData"] = ibiDataArrayFormatted

        // Convert and add hrvDataArray
        let hrvDataArrayFormatted = hrvDataArray.map { dict -> [String: Any] in
            var formattedDict = dict
            if let date = dict["timestamp"] as? Date {
                formattedDict["timestamp"] = dateFormatter.string(from: date)
            }
            return formattedDict
        }
        sessionData["hrvData"] = hrvDataArrayFormatted

        // Convert and add proximityMatrixArray
        let proximityMatrixArrayFormatted = proximityMatrixArray.map {
            dict -> [String: Any] in
            var formattedDict = dict
            if let date = dict["timestamp"] as? Date {
                formattedDict["timestamp"] = dateFormatter.string(from: date)
            }
            formattedDict["matrix"] = dict["matrix"] ?? []
            return formattedDict
        }
        sessionData["proximityMatrix"] = proximityMatrixArrayFormatted

        // Convert and add correlationMatrixArray
        let correlationMatrixArrayFormatted = correlationMatrixArray.map {
            dict -> [String: Any] in
            var formattedDict = dict
            if let date = dict["timestamp"] as? Date {
                formattedDict["timestamp"] = dateFormatter.string(from: date)
            }
            formattedDict["matrix"] = dict["matrix"] ?? []
            return formattedDict
        }
        sessionData["correlationMatrix"] = correlationMatrixArrayFormatted

        // Convert and add crossEntropyMatrixArray
        let crossEntropyMatrixArrayFormatted = crossEntropyMatrixArray.map {
            dict -> [String: Any] in
            var formattedDict = dict
            if let date = dict["timestamp"] as? Date {
                formattedDict["timestamp"] = dateFormatter.string(from: date)
            }
            formattedDict["matrix"] = dict["matrix"] ?? []
            return formattedDict
        }
        sessionData["crossEntropyMatrix"] = crossEntropyMatrixArrayFormatted

        // Convert and add conditionalEntropyMatrixArray
        let conditionalEntropyMatrixArrayFormatted =
            conditionalEntropyMatrixArray.map { dict -> [String: Any] in
                var formattedDict = dict
                if let date = dict["timestamp"] as? Date {
                    formattedDict["timestamp"] = dateFormatter.string(
                        from: date)
                }
                formattedDict["matrix"] = dict["matrix"] ?? []
                return formattedDict
            }
        sessionData["conditionalEntropyMatrix"] =
            conditionalEntropyMatrixArrayFormatted

        // Convert and add mutualInformationMatrixArray
        let mutualInformationMatrixArrayFormatted =
            mutualInformationMatrixArray.map { dict -> [String: Any] in
                var formattedDict = dict
                if let date = dict["timestamp"] as? Date {
                    formattedDict["timestamp"] = dateFormatter.string(
                        from: date)
                }
                formattedDict["matrix"] = dict["matrix"] ?? []
                return formattedDict
            }
        sessionData["mutualInformationMatrix"] =
            mutualInformationMatrixArrayFormatted

        // Convert and add clusterStateArray
        let clusterStateArrayFormatted = clusterStateArray.map {
            dict -> [String: Any] in
            var formattedDict = dict
            if let date = dict["timestamp"] as? Date {
                formattedDict["timestamp"] = dateFormatter.string(from: date)
            }
            formattedDict["clusterState"] = dict["clusterState"] ?? []
            return formattedDict
        }
        sessionData["clusterState"] = clusterStateArrayFormatted

        return sessionData
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"  // ISO8601 format
        return formatter
    }()

    private func jsonData(from dictionary: [String: Any]) -> Data? {
        isLoading = false
        return try? JSONSerialization.data(
            withJSONObject: dictionary, options: .prettyPrinted)
    }

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
