//
//  SensorDataProcessing.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

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

/// Class responsible for processing and managing sensor data such as heart rate and related metrics.
class SensorDataProcessor: ObservableObject {

    /// Stores the last recorded HR value for each sensor.
    @Published var lastHR: [UUID: Double] = [:]

    /// Stores the last recorded instantaneous HR value for each sensor.
    @Published var lastInstantaneousHR: [UUID: Double] = [:]

    /// Stores an array of the last 100 HR data points (with timestamps) for each sensor.
    @Published var hrArray: [UUID: [HRDataPoint]] = [:]

    /// Stores an array of the last 100 HRV values for each sensor.
    @Published var hrvArray: [UUID: [Double]] = [:]

    /// Stores an array of the last 100 IBI values for each sensor.
    @Published var ibiArray: [UUID: [Double]] = [:]

    /// Stores the last computed distance matrix.
    private var lastDistanceMatrix: [[Double]] = []

    /// Stores the last computed proximity matrix.
    private var lastProximityMatrix: [[Double]] = []

    /// Stores the last computed correlation matrix.
    private var lastCorrelationMatrix: [[Double]] = []

    /// Stores the last computed crossentropy matrix.
    private var lastCrossEntropyMatrix: [[Double]] = []

    /// Stores the last computed mutual information matrix.
    private var lastMutualInformationMatrix: [[Double]] = []

    // Containers for cluster states
    private var currentClusterState = ClusterState()

    // Threshold for proximity to determine clusters
    private let threshold: Double = 0.025

    private var currentSession: SessionEntity?

    /// Initializes the data processor with an array of sensor IDs.
    /// Sets up the `hrArray` for each sensor with 100 initial HR values set to 60.
    /// Sets up the `hrvArray` for each sensor with 100 initial HRV values set to 0.
    ///
    /// - Parameter sensorIDs: An array of UUIDs representing the sensors being monitored.
    init(sensorIDs: [UUID]) {
        for id in sensorIDs {
            // Initialize the HR array with 100 entries, all set to HR value of 60.
            hrArray[id] = Array(
                repeating: HRDataPoint(timestamp: Date(), hrValue: 60.0),
                count: 100)
            // Initialize the HRV array with 100 entries, all set to 0.
            hrvArray[id] = Array(repeating: 0.0, count: 100)
            // Initialize the IBI array with 100 entries, all set to 1.
            ibiArray[id] = Array(repeating: 1.0, count: 100)  // Initialize with dummy IBI data

        }
    }

    /// Updates the HR and HRV data for a specific sensor with new IBI values.
    ///
    /// - Parameters:
    ///   - sensorID: The UUID of the sensor.
    ///   - ibiArray: The array of new IBI values received.
    func updateHRData(sensorID: UUID, ibiArray: [Double]) {
        let currentTimestamp = Date()

        for ibi in ibiArray {

            // Update the IBI array
            self.ibiArray[sensorID]?.append(ibi)
            if self.ibiArray[sensorID]!.count > 100 {
                self.ibiArray[sensorID]?.removeFirst()
            }

            // Calculate the instantaneous HR
            let instantaneousHR = 60.0 / ibi

            // Update the last HR and instantaneous HR values
            lastInstantaneousHR[sensorID] = instantaneousHR
            lastHR[sensorID] = instantaneousHR  // Assuming HR is the same as instantaneous HR here

            // Create a new HR data point with the current timestamp
            let newHRDataPoint = HRDataPoint(
                timestamp: currentTimestamp, hrValue: instantaneousHR)

            // Append the new data point to the HR array and remove the oldest if the array exceeds 100 entries
            hrArray[sensorID]?.append(newHRDataPoint)
            if hrArray[sensorID]!.count > 100 {
                hrArray[sensorID]?.removeFirst()
            }

            // Calculate HRV and update the HRV array
            if let hrv = calculateHRV(sensorID: sensorID) {
                hrvArray[sensorID]?.append(hrv)
                if hrvArray[sensorID]!.count > 100 {
                    hrvArray[sensorID]?.removeFirst()
                }
            }
        }

        // After updating HR data, compute the distance and proximity matrices
        lastDistanceMatrix = computeDistancesMatrix(
            sensorIDs: Array(lastInstantaneousHR.keys))
        lastProximityMatrix = computeProximityMatrix(from: lastDistanceMatrix)
        lastCorrelationMatrix = computeCorrelationMatrix(
            sensorIDs: Array(lastInstantaneousHR.keys))
        lastCrossEntropyMatrix = computeCrossEntropyMatrix(
            sensorIDs: Array(lastInstantaneousHR.keys))

        if let session = currentSession {
            saveDataToCoreData(session: session, sensorID: sensorID)
        }
    }

    /// Calculates the Heart Rate Variability (HRV) using the Root Mean Square of Successive Differences (RMSSD) method.
    ///
    /// - Parameter sensorID: The UUID of the sensor.
    /// - Returns: The HRV value or `nil` if there is insufficient data.
    func calculateHRV(sensorID: UUID) -> Double? {
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

    // Other existing methods and getters...

    /// Getter function to retrieve the last 60 IBI values for a specific sensor.
    ///
    /// - Parameter sensorID: The UUID of the sensor.
    /// - Returns: An array of the last 60 IBI values.
    func getIBIData(sensorID: UUID) -> [Double] {
        return ibiArray[sensorID]?.suffix(60) ?? []
    }

    /// Getter function to retrieve the last 60 instantaneous HR values for a specific sensor.
    ///
    /// - Parameter sensorID: The UUID of the sensor.
    /// - Returns: An array of the last 60 instantaneous HR values.
    func getInstantaneousHRData(sensorID: UUID) -> [Double] {
        return hrArray[sensorID]?.suffix(60).map { $0.hrValue } ?? []
    }

    /// Getter function to retrieve the last 60 HRV values for a specific sensor.
    ///
    /// - Parameter sensorID: The UUID of the sensor.
    /// - Returns: An array of the last 60 HRV values.
    func getHRVData(sensorID: UUID) -> [Double] {
        return hrvArray[sensorID]?.suffix(60) ?? []
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

    /// Maps HR values from the range [0, 200] to [0, 1].
    ///
    /// - Parameter hr: The HR value to map.
    /// - Returns: The mapped HR value.
    private func mapHRToUnitInterval(_ hr: Double) -> Double {
        return min(max(hr / 200.0, 0.0), 1.0)
    }

    /// Computes a distance matrix based on the instantaneous HR values between sensors.
    /// HR values are first mapped to the range [0, 1] before calculating distances.
    ///
    /// - Parameter sensorIDs: An array of UUIDs representing the sensors.
    /// - Returns: A 2D array representing the distance matrix.
    func computeDistancesMatrix(sensorIDs: [UUID]) -> [[Double]] {
        var matrix: [[Double]] = []

        for id1 in sensorIDs {
            var row: [Double] = []
            for id2 in sensorIDs {
                if id1 == id2 {
                    row.append(0)  // Distance to self is always 0
                } else {
                    let hr1 = mapHRToUnitInterval(lastInstantaneousHR[id1] ?? 0)
                    let hr2 = mapHRToUnitInterval(lastInstantaneousHR[id2] ?? 0)
                    let distance = abs(hr1 - hr2)
                    row.append(distance)
                }
            }
            matrix.append(row)
        }
        return matrix
    }

    /// Computes a proximity matrix as 1 - distance matrix.
    ///
    /// - Parameter distanceMatrix: The distance matrix.
    /// - Returns: A 2D array representing the proximity matrix.
    func computeProximityMatrix(from distanceMatrix: [[Double]]) -> [[Double]] {
        return distanceMatrix.map { row in
            row.map { 1.0 - $0 }
        }
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

    /// Calculates the correlation between the derivatives of two HR arrays.
    ///
    /// - Parameters:
    ///   - hrArray1: The first HR array.
    ///   - hrArray2: The second HR array.
    /// - Returns: The correlation value, or `nil` if the arrays differ in length.
    private func calculateCorrelation(
        hrArray1: [HRDataPoint], hrArray2: [HRDataPoint]
    ) -> Double? {
        guard hrArray1.count > 1, hrArray2.count > 1 else { return nil }

        let derivative1 = zip(hrArray1.dropFirst(), hrArray1).map {
            $0.hrValue - $1.hrValue
        }
        let derivative2 = zip(hrArray2.dropFirst(), hrArray2).map {
            $0.hrValue - $1.hrValue
        }

        guard derivative1.count == derivative2.count else { return nil }

        let mean1 = derivative1.reduce(0, +) / Double(derivative1.count)
        let mean2 = derivative2.reduce(0, +) / Double(derivative2.count)

        var numerator: Double = 0
        var denominator1: Double = 0
        var denominator2: Double = 0

        for i in 0..<derivative1.count {
            let x = derivative1[i] - mean1
            let y = derivative2[i] - mean2
            numerator += x * y
            denominator1 += x * x
            denominator2 += y * y
        }

        return numerator / sqrt(denominator1 * denominator2)
    }

    /// Computes a correlation matrix based on the derivatives of the HR arrays between sensors.
    ///
    /// - Parameter sensorIDs: An array of UUIDs representing the sensors.
    /// - Returns: A 2D array representing the correlation matrix.
    func computeCorrelationMatrix(sensorIDs: [UUID]) -> [[Double]] {
        var matrix: [[Double]] = []

        for id1 in sensorIDs {
            var row: [Double] = []
            for id2 in sensorIDs {
                if id1 == id2 {
                    row.append(1.0)
                } else {
                    if let correlation = calculateCorrelation(
                        hrArray1: hrArray[id1]!, hrArray2: hrArray[id2]!)
                    {
                        row.append(correlation)
                    } else {
                        row.append(0.0)
                    }
                }
            }
            matrix.append(row)
        }
        return matrix
    }

    /// Getter function to retrieve the last computed correlation matrix.
    ///
    /// - Returns: The last computed correlation matrix.
    func getCorrelationMatrix() -> [[Double]] {
        return lastCorrelationMatrix
    }

    /// Computes a cross-entropy matrix between the HR arrays of different sensors.
    ///
    /// - Parameter sensorIDs: An array of UUIDs representing the sensors.
    /// - Returns: A 2D array representing the cross-entropy matrix.
    func computeCrossEntropyMatrix(sensorIDs: [UUID]) -> [[Double]] {
        var matrix: [[Double]] = []

        for id1 in sensorIDs {
            var row: [Double] = []
            for id2 in sensorIDs {
                if id1 == id2 {
                    row.append(0.0)  // Cross-entropy with self is 0
                } else {
                    if let crossEntropy = calculateCrossEntropy(
                        hrArray1: hrArray[id1]!, hrArray2: hrArray[id2]!)
                    {
                        row.append(crossEntropy)
                    } else {
                        row.append(Double.infinity)  // Use infinity for undefined cross-entropy
                    }
                }
            }
            matrix.append(row)
        }

        lastCrossEntropyMatrix = matrix  // Store the last computed matrix
        return matrix
    }

    /// Helper function to calculate the cross-entropy between two HR arrays.
    ///
    /// - Parameters:
    ///   - hrArray1: The first HR array.
    ///   - hrArray2: The second HR array.
    /// - Returns: The cross-entropy value, or `nil` if the arrays differ in length.
    private func calculateCrossEntropy(
        hrArray1: [HRDataPoint], hrArray2: [HRDataPoint]
    ) -> Double? {
        guard hrArray1.count == hrArray2.count else { return nil }

        let epsilon = 1e-10  // Small constant to prevent log(0)
        var crossEntropy: Double = 0

        for i in 0..<hrArray1.count {
            let p = hrArray1[i].hrValue / 200.0  // Normalize HR to a probability (assuming HR max = 200 BPM)
            let q = hrArray2[i].hrValue / 200.0  // Normalize HR to a probability
            crossEntropy += -p * log(q + epsilon)
        }

        return crossEntropy / Double(hrArray1.count)
    }

    /// Getter function to retrieve the last computed cross-entropy matrix.
    ///
    /// - Returns: The last computed cross-entropy matrix.
    func getCrossEntropyMatrix() -> [[Double]] {
        return lastCrossEntropyMatrix
    }

    // Mutual Information Calculation

    /// Computes the mutual information matrix for the HR arrays between different sensors.
    ///
    /// - Parameter sensorIDs: An array of UUIDs representing the sensors.
    /// - Returns: A 2D array representing the mutual information matrix.
    func computeMutualInformationMatrix(sensorIDs: [UUID], numBins: Int = 10)
        -> [[Double]]
    {
        var matrix: [[Double]] = []

        for id1 in sensorIDs {
            var row: [Double] = []
            for id2 in sensorIDs {
                if id1 == id2 {
                    row.append(0.0)  // Mutual information with self is 0
                } else {
                    if let mutualInformation = calculateMutualInformation(
                        hrArray1: hrArray[id1]!, hrArray2: hrArray[id2]!,
                        numBins: numBins)
                    {
                        row.append(mutualInformation)
                    } else {
                        row.append(0.0)  // Use 0 for undefined mutual information
                    }
                }
            }
            matrix.append(row)
        }

        lastMutualInformationMatrix = matrix  // Store the last computed matrix
        return matrix
    }

    /// Helper function to calculate the mutual information between two HR arrays.
    ///
    /// - Parameters:
    ///   - hrArray1: The first HR array.
    ///   - hrArray2: The second HR array.
    ///   - numBins: The number of bins to discretize the HR values.
    /// - Returns: The mutual information value.
    private func calculateMutualInformation(
        hrArray1: [HRDataPoint], hrArray2: [HRDataPoint], numBins: Int
    ) -> Double? {
        guard hrArray1.count == hrArray2.count else { return nil }

        // Discretize the HR values into bins
        let hr1Bins = discretize(hrArray1.map { $0.hrValue }, numBins: numBins)
        let hr2Bins = discretize(hrArray2.map { $0.hrValue }, numBins: numBins)

        // Calculate the joint and marginal probabilities
        var jointProb: [[Double]] = Array(
            repeating: Array(repeating: 0.0, count: numBins), count: numBins)
        var pX: [Double] = Array(repeating: 0.0, count: numBins)
        var pY: [Double] = Array(repeating: 0.0, count: numBins)

        for i in 0..<hr1Bins.count {
            jointProb[hr1Bins[i]][hr2Bins[i]] += 1
            pX[hr1Bins[i]] += 1
            pY[hr2Bins[i]] += 1
        }

        // Normalize to get probabilities
        let total = Double(hr1Bins.count)
        for i in 0..<numBins {
            pX[i] /= total
            pY[i] /= total
            for j in 0..<numBins {
                jointProb[i][j] /= total
            }
        }

        // Calculate mutual information
        var mutualInformation: Double = 0.0
        for i in 0..<numBins {
            for j in 0..<numBins {
                if jointProb[i][j] > 0 {
                    mutualInformation +=
                        jointProb[i][j]
                        * log(jointProb[i][j] / (pX[i] * pY[j]) + 1e-10)
                }
            }
        }

        return mutualInformation
    }

    /// Discretizes a list of continuous HR values into a specified number of bins.
    ///
    /// - Parameters:
    ///   - hrValues: The list of HR values to discretize.
    ///   - numBins: The number of bins to use for discretization.
    /// - Returns: An array of bin indices corresponding to the HR values.
    private func discretize(_ hrValues: [Double], numBins: Int) -> [Int] {
        guard let minValue = hrValues.min(), let maxValue = hrValues.max(),
            minValue < maxValue
        else {
            return Array(repeating: 0, count: hrValues.count)
        }

        let binSize = (maxValue - minValue) / Double(numBins)
        return hrValues.map { Int(($0 - minValue) / binSize) }
    }

    /// Getter function to retrieve the last computed mutual information matrix.
    ///
    /// - Returns: The last computed mutual information matrix.
    func getMutualInformationMatrix() -> [[Double]] {
        return lastMutualInformationMatrix
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
        event.instantaneousHR = lastInstantaneousHR[sensorID] ?? 0.0
        event.ibi =
            ArrayTransformer().transformedValue(ibiArray[sensorID]) as? Data
        event.distanceMatrix =
            ArrayTransformer().transformedValue(lastDistanceMatrix) as? Data
        event.proximityMatrix =
            ArrayTransformer().transformedValue(lastProximityMatrix) as? Data
        event.correlationMatrix =
            ArrayTransformer().transformedValue(lastCorrelationMatrix) as? Data
        event.crossEntropyMatrix =
            ArrayTransformer().transformedValue(lastCrossEntropyMatrix) as? Data
        event.mutualInformationMatrix =
            ArrayTransformer().transformedValue(lastMutualInformationMatrix)
            as? Data

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

}
