//
//  SensorDataProcessing.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import CoreData
import Foundation

/// Data structure that holds a heart rate (HR) value and its corresponding timestamp.
struct HRDataPoint: Equatable {
    let timestamp: Date  // Timestamp when the HR value was recorded
    let hrValue: Double  // The HR value recorded at the timestamp
}

/// Data structure that holds a heart rate variability (HRV) value and its corresponding timestamp.
struct HRVDataPoint: Equatable {
    let timestamp: Date  // Timestamp when the HRV value was recorded
    let hrvValue: Double  // The HRV value recorded at the timestamp
}

@Observable
class SensorDataProcessor {
    
    /// Flag to trigger a UI update when the data changes.
    var isUpdated: Bool = false {
        didSet {
            // This will trigger onChange in the view
        }
    }

    /// Stores the last recorded HR value for each sensor.
    var lastHR: [String: Double] = [:]

    /// Stores the last recorded instantaneous HR value for each sensor.
    var lastIHR: [String: Double] = [:]

    /// Stores an array of the last 100 HR data points (with timestamps) for each sensor.
    var hrArray: [String: [HRDataPoint]] = [:]

    /// Stores an array of the last 100 IHR data points (with timestamps) for each sensor.
    var ihrArray: [String: [HRDataPoint]] = [:]
    
    /// Stores an array of the last 100 HRV values for each sensor.
    var hrvArray: [String: [HRVDataPoint]] = [:]

    /// Stores an array of the last 100 IBI (Inter-Beat Interval) values for each sensor.
    var ibiArray: [String: [Double]] = [:]

    /// Stores the last computed distance matrix.
    private var lastDistanceMatrix: [[Double]] = []

    /// Stores the last computed proximity matrix.
    private var lastProximityMatrix: [[Double]] = []

    /// Container for cluster states.
    private var currentClusterState: [Bool] = [false, false, false, false, false, false]

    /// Threshold for proximity to determine clusters.
    private let threshold: Double = 0.025

    /// Ordered sensor names: blue, green, red.
    private let sensorOrder: [String] = ["Blue", "Green", "Red"]

    /// The current session being processed.
    private var currentSession: SessionEntity?

    /// Initializes the data processor and sets up arrays for HR, IHR, HRV, and IBI data.
    init() {
        // Initialize the HR, IHR, HRV arrays, and matrices
        for id in sensorOrder {
            lastHR[id] = 0.0
            lastIHR[id] = 0.0

            hrArray[id] = Array(repeating: HRDataPoint(timestamp: Date(), hrValue: 60.0), count: 100)
            ihrArray[id] = Array(repeating: HRDataPoint(timestamp: Date(), hrValue: 60.0), count: 100)
            hrvArray[id] = Array(repeating: HRVDataPoint(timestamp: Date(), hrvValue: 0.0), count: 100)
            ibiArray[id] = Array(repeating: 1.0, count: 100)  // Initialize with dummy IBI data
        }

        // Initialize matrices as 3x3 with zeros
        lastDistanceMatrix = Array(repeating: Array(repeating: 1.0, count: 3), count: 3)
        lastProximityMatrix = Array(repeating: Array(repeating: 0.0, count: 3), count: 3)
    }

    /// Updates the HR and HRV data for a specific sensor with new IBI values.
    ///
    /// - Parameters:
    ///   - sensorID: The identifier of the sensor.
    ///   - hr: The heart rate value to update.
    ///   - ibiArray: The array of new IBI values received.
    func updateHRData(sensorID: String, hr: Double, ibiArray: [Double]) {
        let currentTimestamp = Date()

        // Update the last HR for the sensor
        lastHR[sensorID] = hr
        
        // Create a new HR data point
        let newHRDataPoint = HRDataPoint(timestamp: currentTimestamp, hrValue: hr)

        // Ensure the hrArray exists for the given sensorID
        var sensorHRArray = hrArray[sensorID] ?? []
        sensorHRArray.append(newHRDataPoint)
        if sensorHRArray.count > 100 {
            sensorHRArray.removeFirst(sensorHRArray.count - 100)
        }
        hrArray[sensorID] = sensorHRArray

        // Ensure that the ibiArray exists for the given sensorID; if not, initialize it
        self.ibiArray[sensorID] = (self.ibiArray[sensorID] ?? []) + ibiArray
        if let sensorIBIArray = self.ibiArray[sensorID], sensorIBIArray.count > 100 {
            self.ibiArray[sensorID] = Array(sensorIBIArray.suffix(100))
        }

        // Calculate and update instantaneous HR
        for ibi in ibiArray {
            let instantaneousHR = 60.0 / ibi
            lastIHR[sensorID] = instantaneousHR

            // Create a new HR data point for IHR
            let newIHRDataPoint = HRDataPoint(timestamp: currentTimestamp, hrValue: instantaneousHR)

            // Ensure the ihrArray exists for the given sensorID
            var sensorIHRArray = ihrArray[sensorID] ?? []
            sensorIHRArray.append(newIHRDataPoint)
            if sensorIHRArray.count > 100 {
                sensorIHRArray.removeFirst(sensorIHRArray.count - 100)
            }
            ihrArray[sensorID] = sensorIHRArray

            // Calculate HRV and update the HRV array
            if let hrv = computeHRV(sensorID: sensorID) {
                let newHRVDataPoint = HRVDataPoint(timestamp: currentTimestamp, hrvValue: hrv)

                // Ensure the hrvArray exists for the given sensorID
                var sensorHRVArray = hrvArray[sensorID] ?? []
                sensorHRVArray.append(newHRVDataPoint)
                if sensorHRVArray.count > 100 {
                    sensorHRVArray.removeFirst(sensorHRVArray.count - 100)
                }
                hrvArray[sensorID] = sensorHRVArray
            }
        }

        // After updating HR data, compute the distance and proximity matrices
        updateMatrices()
        
        // After updating distance and proximity matrices, compute the cluster state
        updateClusterState()
        
        // Trigger UI update
        triggerUpdate()
    }

    /// Updates all the matrices (distance, proximity, etc.) in place.
    private func updateMatrices() {
        for i in 0..<sensorOrder.count {
            for j in i..<sensorOrder.count {
                let sensorID1 = sensorOrder[i]
                let sensorID2 = sensorOrder[j]

                // Update Distance Matrix
                let distance = computeDistance(from: lastHR[sensorID1]!, to: lastHR[sensorID2]!)
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

    /// Calculates the distance between two instantaneous HR values.
    ///
    /// - Parameters:
    ///   - hr1: The first heart rate value.
    ///   - hr2: The second heart rate value.
    /// - Returns: The calculated distance between the two HR values.
    private func computeDistance(from hr1: Double, to hr2: Double) -> Double {
        return abs(mapHRToUnitInterval(hr1) - mapHRToUnitInterval(hr2))
    }

    /// Calculates the Heart Rate Variability (HRV) using the Root Mean Square of Successive Differences (RMSSD) method.
    ///
    /// - Parameter sensorID: The identifier of the sensor.
    /// - Returns: The HRV value or `nil` if there is insufficient data.
    func computeHRV(sensorID: String) -> Double? {
        guard let ibis = ibiArray[sensorID], ibis.count > 1 else { return nil }

        // Calculate the successive differences of the IBIs
        let diffIBIs = zip(ibis.dropFirst(), ibis).map { $0 - $1 }

        // Calculate the squared differences
        let squaredDifferences = diffIBIs.map { $0 * $0 }

        // Compute the mean of the squared differences
        let meanSquareDifference = squaredDifferences.reduce(0, +) / Double(squaredDifferences.count)

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
    /// - Parameter sensorID: The identifier of the sensor.
    /// - Returns: An array of the last 60 IBI values.
    func getIBIData(sensorID: String) -> [Double] {
        return Array(ibiArray[sensorID]?.suffix(60) ?? [])
    }

    /// Getter function to retrieve the last 60 HR values for all sensors.
    ///
    /// - Returns: A dictionary with sensor IDs as keys and arrays of the last 60 HR values as values.
    func getInstantaneousHRData() -> [String: [Double]] {
        var result: [String: [Double]] = [:]
        for (sensorID, ihrData) in ihrArray {
            result[sensorID] = Array(ihrData.suffix(60).map { $0.hrValue })
        }
        return result
    }

    /// Getter function to retrieve the last 60 HRV values for all sensors.
    ///
    /// - Returns: A dictionary with sensor IDs as keys and arrays of the last 60 HRV values as values.
    func getHRVData() -> [String: [Double]] {
        var result: [String: [Double]] = [:]
        for (sensorID, hrvData) in hrvArray {
            result[sensorID] = Array(hrvData.suffix(60).map { $0.hrvValue })
        }
        return result
    }

    /// Calculates the minimum, maximum, median, and mean HR values for all sensors.
    ///
    /// - Returns: A dictionary where each sensor ID maps to an array of [min, max, median, mean] values.
    func getStatistics() -> [String: [Double]] {
        var statistics: [String: [Double]] = [:]

        for sensorID in hrArray.keys {
            if let stats = computeStatistics(sensorID: sensorID) {
                statistics[sensorID] = [stats.min, stats.max, stats.median, stats.mean]
            }
        }
        
        return statistics
    }

    /// Calculates the minimum, maximum, median, and mean HR values for a specific sensor.
    ///
    /// - Parameter sensorID: The identifier of the sensor.
    /// - Returns: A tuple containing the minimum, maximum, median, and mean HR values, or `nil` if no data exists.
    private func computeStatistics(sensorID: String) -> (min: Double, max: Double, median: Double, mean: Double)? {
        guard let hrDataPoints = hrArray[sensorID] else { return nil }
        let hrValues = hrDataPoints.map { $0.hrValue }

        let min = hrValues.min() ?? 0
        let max = hrValues.max() ?? 0
        let median = hrValues.sorted()[hrValues.count / 2]
        let mean = hrValues.reduce(0, +) / Double(hrValues.count)

        return (min, max, median, mean)
    }

    /// Updates the cluster state based on the current proximity matrix.
    ///
    /// - Parameters:
    ///   - sensorIDs: An array of sensor IDs.
    ///   - proximityMatrix: A matrix representing the proximity between sensors.
    func updateClusterState() {
        // Reset the active state for all clusters before updatingoximityMatrix)
        var newState: [Bool] = [false, false, false, false, false, false]
        
        newState[1] = lastProximityMatrix[0][1] > 1 - threshold
        newState[2] = lastProximityMatrix[0][2] > 1 - threshold
        newState[3] = lastProximityMatrix[1][2] > 1 - threshold
        
        if newState[1] && newState[2] && newState[3] {
            newState[5] = true
            newState[1] = false
            newState[2] = false
            newState[3] = false
        }
        else if (newState[1] && newState[2]) || (newState[1] && newState[3]) || (newState[2] && newState[3]) {
            newState[4] = true
            newState[1] = false
            newState[2] = false
            newState[3] = false
        }
        
        var flag: Bool = false
        
        for i in 1...newState.count-1 {
            if newState[i] != currentClusterState[i] {
                    flag = true
            }
        }
        
        newState[0] = flag
        
        currentClusterState = newState
        
    }

    /// Getter function to retrieve the current clusters.
    ///
    /// - Returns: An array of `Bool` representing the current clusters.
    func getClusterState() -> [Bool] {
        return currentClusterState
    }

    /// Sets the current session for data processing.
    ///
    /// - Parameter session: The session entity to set as the current session.
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
    ///   - sensorID: The identifier of the sensor being processed.
    func saveDataToCoreData(session: SessionEntity, sensorID: String) {
        let context = CoreDataStack.shared.context

        // Create a new EventEntity for this data point
        let event = EventEntity(context: context)
        event.timestamp = Date()
        event.hr = lastHR[sensorID] ?? 0.0
        event.ibi = ArrayTransformer().transformedValue(ibiArray[sensorID]) as? Data
        event.distanceMatrix = ArrayTransformer().transformedValue(lastDistanceMatrix) as? Data
        event.proximityMatrix = ArrayTransformer().transformedValue(lastProximityMatrix) as? Data

        // Optionally save cluster state
        event.clusters = ArrayTransformer().transformedValue(currentClusterState) as? Data
        event.session = session

        // Save the context
        do {
            try context.save()
        } catch {
            print("Failed to save event data: \(error)")
        }
    }

    /// Triggers a UI update by toggling the `isUpdated` property.
    private func triggerUpdate() {
        isUpdated = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isUpdated = false
        }
    }
}
