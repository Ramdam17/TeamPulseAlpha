import CoreData
import Foundation

/// Structure to represent the state of a soft cluster.
struct SoftClusterInfo {
    var uuids: Set<UUID>  // The set of UUIDs in the cluster
    var isActive: Bool = false  // Whether this cluster is currently active
    var activationCount: Int = 0  // How many times this cluster has been active
}

/// Structure to represent the state of a hard cluster.
struct HardClusterInfo {
    var uuids: Set<UUID>  // The set of UUIDs in the cluster
    var isActive: Bool = false  // Whether this cluster is currently active
    var activationCount: Int = 0  // How many times this cluster has been active
}

/// Structure to encapsulate the current state of clusters.
struct ClusterState {
    var softClusters: [SoftClusterInfo] = []  // Array of soft clusters
    var hardClusters: [HardClusterInfo] = []  // Array of hard clusters
}

/// Data structure that holds a heart rate (HR) value and its corresponding timestamp.
struct HRDataPoint {
    let timestamp: Date  // Timestamp when the HR value was recorded
    let hrValue: Double  // The HR value recorded at the timestamp
}

/// Data structure that holds a heart rate (HR) value and its corresponding timestamp.
struct HRVDataPoint {
    let timestamp: Date  // Timestamp when the HRV value was recorded
    let hrvValue: Double  // The HRV value recorded at the timestamp
}

@Observable
class SensorDataProcessor {

    // will trigger a view update
    var isUpdated: Bool = false {
        didSet {
            // This will trigger onChange in the view
        }
    }
    /// Stores the last recorded HR value for each sensor.
    var lastHR: [UUID: Double] = [:]

    /// Stores the last recorded instantaneous HR value for each sensor.
    var lastIHR: [UUID: Double] = [:]

    /// Stores an array of the last 100 HR data points (with timestamps) for each sensor.
    var hrArray: [UUID: [HRDataPoint]] = [:]

    /// Stores an array of the last 100 HRV values for each sensor.
    var hrvArray: [UUID: [HRVDataPoint]] = [:]

    /// Stores an array of the last 100 IBI values for each sensor.
    var ibiArray: [UUID: [Double]] = [:]

    /// Stores the last computed distance matrix.
    private var lastDistanceMatrix: [[Double]] = []

    /// Stores the last computed proximity matrix.
    private var lastProximityMatrix: [[Double]] = []

    // Containers for cluster states
    private var currentClusterState = ClusterState()

    // Threshold for proximity to determine clusters
    private let threshold: Double = 0.025

    // Ordered sensor UUIDs: blue, green, red
    private let sensorOrder: [UUID]

    private var currentSession: SessionEntity?

    /// Initializes the data processor with an array of sensor IDs.
    /// Sets up the `hrArray` for each sensor with 100 initial HR values set to 60.
    /// Sets up the `hrvArray` for each sensor with 100 initial HRV values set to 0.
    ///
    /// - Parameter sensorIDs: An array of UUIDs representing the sensors being monitored.
    init() {

        // Fetch sensor IDs from CoreData
        let sensorIDs = SensorDataProcessor.fetchSensorUUIDs()

        // Ensure the sensor IDs are ordered: blue, green, red
        sensorOrder = sensorIDs.sorted()

        // Initialize the HR array, HRV array, IBI array, and matrices
        for id in sensorOrder {
            lastHR[id] = 0.0
            lastIHR[id] = 0.0

            hrArray[id] = Array(
                repeating: HRDataPoint(timestamp: Date(), hrValue: 60.0),
                count: 100)
            hrvArray[id] = Array(
                repeating: HRVDataPoint(timestamp: Date(), hrvValue: 0.0),
                count: 100)
            ibiArray[id] = Array(repeating: 1.0, count: 100)  // Initialize with dummy IBI data
        }

        // Initialize matrices as 3x3 with zeros
        lastDistanceMatrix = Array(
            repeating: Array(repeating: 1.0, count: 3), count: 3)
        lastProximityMatrix = Array(
            repeating: Array(repeating: 0.0, count: 3), count: 3)
    }

    /// Fetches the sensor UUIDs from CoreData.
    private static func fetchSensorUUIDs() -> [UUID] {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<SensorEntity> =
            SensorEntity.fetchRequest()
        do {
            let sensors = try context.fetch(fetchRequest)
            return sensors.compactMap { $0.id }
        } catch {
            print("Failed to fetch sensors: \(error)")
            return []
        }
    }

    /// Updates the HR and HRV data for a specific sensor with new IBI values.
    ///
    /// - Parameters:
    ///   - sensorID: The UUID of the sensor.
    ///   - hr: The heart rate value to update.
    ///   - ibiArray: The array of new IBI values received.
    func updateHRData(sensorID: UUID, hr: Double, ibiArray: [Double]) {
        let currentTimestamp = Date()

        // Update the last HR for the sensor
        lastHR[sensorID] = hr

        // Ensure that the ibiArray exists for the given sensorID; if not, initialize it
        if self.ibiArray[sensorID] == nil {
            self.ibiArray[sensorID] = []
        }

        // Update the IBI array for the sensorID
        self.ibiArray[sensorID]?.append(contentsOf: ibiArray)
        if let sensorIBIArray = self.ibiArray[sensorID],
            sensorIBIArray.count > 100
        {
            self.ibiArray[sensorID] = Array(sensorIBIArray.suffix(100))
        }

        // Calculate and update instantaneous HR
        for ibi in ibiArray {
            let instantaneousHR = 60.0 / ibi
            lastIHR[sensorID] = instantaneousHR

            // Create a new HR data point
            let newHRDataPoint = HRDataPoint(
                timestamp: currentTimestamp, hrValue: instantaneousHR)

            // Ensure the hrArray exists for the given sensorID
            guard var sensorHRArray = hrArray[sensorID] else {
                hrArray[sensorID] = [newHRDataPoint]
                continue
            }

            // Update the HR array
            sensorHRArray.append(newHRDataPoint)
            if sensorHRArray.count > 100 {
                sensorHRArray.removeFirst(sensorHRArray.count - 100)
            }
            hrArray[sensorID] = sensorHRArray

            // Calculate HRV and update the HRV array
            if let hrv = computeHRV(sensorID: sensorID) {
                let newHRVDataPoint = HRVDataPoint(
                    timestamp: currentTimestamp, hrvValue: hrv)

                // Ensure the hrvArray exists for the given sensorID
                guard var sensorHRVArray = hrvArray[sensorID] else {
                    hrvArray[sensorID] = [newHRVDataPoint]
                    continue
                }

                // Update the HRV array
                sensorHRVArray.append(newHRVDataPoint)
                if sensorHRVArray.count > 100 {
                    sensorHRVArray.removeFirst(sensorHRVArray.count - 100)
                }
                hrvArray[sensorID] = sensorHRVArray
            }
        }

        // After updating HR data, compute the distance and proximity matrices
        updateMatrices()

        // Trigger UI update
        triggerUpdate()
        print("UI should be updated")
    }

    /// Updates all the matrices (distance, proximity, etc.) in place.
    private func updateMatrices() {
        for i in 0..<sensorOrder.count {
            for j in i..<sensorOrder.count {
                let sensorID1 = sensorOrder[i]
                let sensorID2 = sensorOrder[j]

                // Update Distance Matrix
                let distance = computeDistance(
                    from: lastIHR[sensorID1]!, to: lastIHR[sensorID2]!)
                lastDistanceMatrix[i][j] = distance
                lastDistanceMatrix[j][i] = distance

                // Update Proximity Matrix
                let proximity = 1.0 - distance
                lastProximityMatrix[i][j] = proximity
                lastProximityMatrix[j][i] = proximity

            }
        }
    }

    /// Maps HR values from the range [0, 200] to [0, 1].
    ///
    /// - Parameter hr: The HR value to map.
    /// - Returns: The mapped HR value.
    private func mapHRToUnitInterval(_ hr: Double) -> Double {
        return min(max(hr / 200.0, 0.0), 1.0)
    }

    /// Calculates the distance between two instantaneous HR values
    private func computeDistance(from hr1: Double, to hr2: Double) -> Double {
        return abs(mapHRToUnitInterval(hr1) - mapHRToUnitInterval(hr2))
    }

    /// Calculates the Heart Rate Variability (HRV) using the Root Mean Square of Successive Differences (RMSSD) method.
    ///
    /// - Parameter sensorID: The UUID of the sensor.
    /// - Returns: The HRV value or `nil` if there is insufficient data.
    func computeHRV(sensorID: UUID) -> Double? {
        guard let ibis = ibiArray[sensorID] else { return nil }
        guard ibis.count > 1 else { return nil }

        // Calculate the successive differences of the IBIs
        let diffIBIs = zip(ibis.dropFirst(), ibis).map { $0 - $1 }

        // Calculate the squared differences
        let squaredDifferences = diffIBIs.map { $0 * $0 }

        // Compute the mean of the squared differences
        let meanSquareDifference =
            squaredDifferences.reduce(0, +) / Double(squaredDifferences.count)

        // Return the square root of the mean square difference (RMSSD)
        return sqrt(meanSquareDifference)
    }

    /// Computes the proximity score, which is the mean of the upper triangular part of the proximity matrix.
    ///
    /// - Returns: The proximity score.
    func computeProximityScore() -> Double {
        var sum: Double = 0.0
        var count: Int = 0

        for i in 0..<lastProximityMatrix.count {
            for j in (i + 1)..<lastProximityMatrix[i].count {
                sum += lastProximityMatrix[i][j]
                count += 1
            }
        }

        return count > 0 ? sum / Double(count) : 0.0
    }

    /// Getter function to retrieve the last computed distance matrix.
    ///
    /// - Returns: The last computed distance matrix.
    func getDistanceMatrix() -> [[Double]] {
        return lastDistanceMatrix
    }

    /// Getter function to retrieve the last computed proximity matrix.
    ///
    /// - Returns: The last computed proximity matrix.
    func getProximityMatrix() -> [[Double]] {
        return lastProximityMatrix
    }

    /// Getter function to retrieve the last 60 IBI values for a specific sensor.
    ///
    /// - Parameter sensorID: The UUID of the sensor.
    /// - Returns: An array of the last 60 IBI values.
    func getIBIData(sensorID: UUID) -> [Double] {
        return Array(ibiArray[sensorID]?.suffix(60) ?? [])
    }

    /// Getter function to retrieve the last 60 HR values for all sensors.
    /// - Returns: A dictionary with UUIDs as keys and arrays of the last 60 HR values as values.
    func getInstantaneousHRData() -> [UUID: [Double]] {
        var result: [UUID: [Double]] = [:]
        for (sensorID, hrData) in hrArray {
            result[sensorID] = Array(hrData.suffix(60).map { $0.hrValue })
        }
        return result
    }

    /// Getter function to retrieve the last 60 HRV values for all sensors.
    /// - Returns: A dictionary with UUIDs as keys and arrays of the last 60 HRV values as values.
    func getHRVData() -> [UUID: [Double]] {
        var result: [UUID: [Double]] = [:]
        for (sensorID, hrvData) in hrvArray {
            result[sensorID] = Array(hrvData.suffix(60).map { $0.hrvValue })
        }
        return result
    }

    /// Calculates the minimum, maximum, median, and mean HR values for a specific sensor.
    ///
    /// - Parameter sensorID: The UUID of the sensor.
    /// - Returns: A tuple containing the minimum, maximum, median, and mean HR values, or `nil` if no data exists.
    func calculateStatistics(sensorID: UUID) -> (
        min: Double, max: Double, median: Double, mean: Double
    )? {
        guard let hrDataPoints = hrArray[sensorID] else { return nil }
        let hrValues = hrDataPoints.map { $0.hrValue }

        let min = hrValues.min() ?? 0
        let max = hrValues.max() ?? 0
        let median = hrValues.sorted(by: <)[hrValues.count / 2]
        let mean = hrValues.reduce(0, +) / Double(hrValues.count)

        return (min, max, median, mean)
    }

    /// Updates the cluster state based on the current proximity matrix.
    func updateClusterState(sensorIDs: [UUID], proximityMatrix: [[Double]]) {
        // Reset the active state for all clusters before updating
        resetClusterActiveStates()

        // Generate clusters based on the proximity matrix
        generateClusters(sensorIDs: sensorIDs, proximityMatrix: proximityMatrix)
    }

    /// Resets the active state for all clusters before recalculating.
    private func resetClusterActiveStates() {
        for i in 0..<currentClusterState.softClusters.count {
            currentClusterState.softClusters[i].isActive = false
        }
        for i in 0..<currentClusterState.hardClusters.count {
            currentClusterState.hardClusters[i].isActive = false
        }
    }

    /// Generates clusters (both soft and hard) based on the proximity matrix.
    private func generateClusters(
        sensorIDs: [UUID], proximityMatrix: [[Double]]
    ) {
        let proximityThreshold = 1.0 - threshold

        var includedUUIDs = Set<Set<UUID>>()  // Keep track of UUIDs already included in larger clusters

        // Check for 3-member clusters first (to avoid redundant smaller clusters)
        for i in 0..<sensorIDs.count {
            for j in i + 1..<sensorIDs.count {
                for k in j + 1..<sensorIDs.count {
                    let clusterSet: Set<UUID> = [
                        sensorIDs[i], sensorIDs[j], sensorIDs[k],
                    ]

                    if proximityMatrix[i][j] >= proximityThreshold
                        && proximityMatrix[j][k] >= proximityThreshold
                        && proximityMatrix[i][k] >= proximityThreshold
                    {

                        // Hard cluster
                        updateOrCreateCluster(
                            clusterSet: clusterSet,
                            isHard: true
                        )
                        includedUUIDs.insert(clusterSet)
                    } else if (proximityMatrix[i][j] >= proximityThreshold
                        || proximityMatrix[j][k] >= proximityThreshold
                        || proximityMatrix[i][k] >= proximityThreshold)
                        && !includedUUIDs.contains(clusterSet)
                    {

                        // Soft cluster
                        updateOrCreateCluster(
                            clusterSet: clusterSet,
                            isHard: false
                        )
                        includedUUIDs.insert(clusterSet)
                    }
                }
            }
        }

        // Handle smaller 2-member clusters, avoiding overlaps with existing larger clusters
        for i in 0..<sensorIDs.count {
            for j in i + 1..<sensorIDs.count {
                let pairSet: Set<UUID> = [sensorIDs[i], sensorIDs[j]]
                if proximityMatrix[i][j] >= proximityThreshold
                    && !includedUUIDs.contains(pairSet)
                {
                    updateOrCreateCluster(
                        clusterSet: pairSet,
                        isHard: false
                    )
                    includedUUIDs.insert(pairSet)
                }
            }
        }
    }

    /// Updates an existing cluster or creates a new one if it doesn't exist.
    ///
    /// - Parameters:
    ///   - clusterSet: The set of UUIDs representing the cluster.
    ///   - isHard: Boolean indicating if the cluster is hard or soft.
    private func updateOrCreateCluster(clusterSet: Set<UUID>, isHard: Bool) {
        if isHard {
            // Update or create a hard cluster
            if let index = currentClusterState.hardClusters.firstIndex(where: {
                $0.uuids == clusterSet
            }) {
                currentClusterState.hardClusters[index].isActive = true
                currentClusterState.hardClusters[index].activationCount += 1
            } else {
                currentClusterState.hardClusters.append(
                    HardClusterInfo(
                        uuids: clusterSet, isActive: true, activationCount: 1)
                )
            }
        } else {
            // Update or create a soft cluster
            if let index = currentClusterState.softClusters.firstIndex(where: {
                $0.uuids == clusterSet
            }) {
                currentClusterState.softClusters[index].isActive = true
                currentClusterState.softClusters[index].activationCount += 1
            } else {
                currentClusterState.softClusters.append(
                    SoftClusterInfo(
                        uuids: clusterSet, isActive: true, activationCount: 1)
                )
            }
        }
    }

    /// Getter function to retrieve the current soft clusters.
    ///
    /// - Returns: An array of `SoftClusterInfo` representing the current soft clusters.
    func getSoftClusters() -> [SoftClusterInfo] {
        return currentClusterState.softClusters
    }

    /// Getter function to retrieve the current hard clusters.
    ///
    /// - Returns: An array of `HardClusterInfo` representing the current hard clusters.
    func getHardClusters() -> [HardClusterInfo] {
        return currentClusterState.hardClusters
    }

    /// Sets the current session for data processing.
    func setCurrentSession(_ session: SessionEntity) {
        self.currentSession = session
    }

    /// Clears the current session when recording stops or is deleted.
    func clearCurrentSession() {
        self.currentSession = nil
    }

    /// Saves the processed sensor data to Core Data.
    ///
    /// - Parameters:
    ///   - session: The current session entity to associate this data with.
    ///   - sensorID: The UUID of the sensor being processed.
    func saveDataToCoreData(session: SessionEntity, sensorID: UUID) {
        let context = CoreDataStack.shared.context

        // Create a new EventEntity for this data point
        let event = EventEntity(context: context)
        event.timestamp = Date()
        event.hr = lastHR[sensorID] ?? 0.0
        event.ibi =
            ArrayTransformer().transformedValue(ibiArray[sensorID]) as? Data
        event.distanceMatrix =
            ArrayTransformer().transformedValue(lastDistanceMatrix) as? Data
        event.proximityMatrix =
            ArrayTransformer().transformedValue(lastProximityMatrix) as? Data

        // Optionally save cluster state
        event.softClusters =
            ArrayTransformer().transformedValue(
                currentClusterState.softClusters) as? Data
        event.hardClusters =
            ArrayTransformer().transformedValue(
                currentClusterState.hardClusters) as? Data

        event.session = session

        // Save the context
        do {
            try context.save()
        } catch {
            print("Failed to save event data: \(error)")
        }
    }

    private func triggerUpdate() {
        // This method changes isUpdated to true and then false to trigger a UI update
        isUpdated = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isUpdated = false
        }
    }
}
