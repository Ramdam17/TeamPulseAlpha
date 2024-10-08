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

    // MARK: - Properties

    /// Flag to trigger a UI update when the data changes.
    var isUpdated: Bool = false {
        didSet {
            // Triggers the onChange function in the view
        }
    }

    /// Stores the last recorded HR value for each sensor.
    private(set) var lastHR: [String: Double] = [:]

    /// Stores the last recorded instantaneous HR value for each sensor.
    private(set) var lastIHR: [String: Double] = [:]

    /// Stores the last recorded instantaneous HRV value for each sensor.
    private(set) var lastHRV: [String: Double] = [:]
    
    /// Stores an array of the last 100 HR data points (with timestamps) for each sensor.
    private(set) var hrArray: [String: [HRDataPoint]] = [:]

    /// Stores an array of the last 100 IHR data points (with timestamps) for each sensor.
    private(set) var ihrArray: [String: [HRDataPoint]] = [:]

    /// Stores an array of the last 100 HRV values for each sensor.
    private(set) var hrvArray: [String: [HRVDataPoint]] = [:]

    /// Stores an array of the last 100 IBI (Inter-Beat Interval) values for each sensor.
    private(set) var ibiArray: [String: [Double]] = [:]

    /// Stores the last computed distance matrix (3x3).
    private var lastDistanceMatrix: [[Double]] = []

    /// Stores the last computed proximity matrix (3x3).
    private var lastProximityMatrix: [[Double]] = []

    /// Stores the last computed correlation matrix (3x3).
    private var lastCorrelationMatrix: [[Double]] = []

    /// Stores the last computed cross entropy matrix (3x3).
    private var lastCrossEntropyMatrix: [[Double]] = []

    /// Stores the last computed conditional entropy matrix (3x3).
    private var lastConditionalEntropyMatrix: [[Double]] = []

    /// Stores the last computed mutual information matrix (3x3).
    private var lastMutualInformationMatrix: [[Double]] = []

    /// Container for cluster states.
    private var currentClusterState: [Bool] = Array(repeating: false, count: 6)

    /// Threshold for proximity to determine clusters.
    private let threshold: Double = 0.025

    /// Ordered sensor names: blue, green, red.
    private let sensorOrder: [String] = ["Blue", "Green", "Red"]

    /// The current session being processed.
    private var currentSession: SessionEntity?

    // MARK: - Initialization

    /// Initializes the data processor and sets up arrays for HR, IHR, HRV, and IBI data.
    init() {
        reset()
    }

    // MARK: - Public Methods

    /// Resets the sensor data and matrices to their initial state.
    func reset() {
        for id in sensorOrder {
            lastHR[id] = 0.0
            lastIHR[id] = 0.0
            lastHRV[id] = 0.0

            hrArray[id] = Array(
                repeating: HRDataPoint(timestamp: Date(), hrValue: 60.0),
                count: 100)
            ihrArray[id] = Array(
                repeating: HRDataPoint(timestamp: Date(), hrValue: 60.0),
                count: 100)
            hrvArray[id] = Array(
                repeating: HRVDataPoint(timestamp: Date(), hrvValue: 0.0),
                count: 100)
            ibiArray[id] = Array(repeating: 1.0, count: 100)
        }

        lastDistanceMatrix = Array(
            repeating: Array(repeating: 1.0, count: 3), count: 3)
        lastProximityMatrix = Array(
            repeating: Array(repeating: 0.0, count: 3), count: 3)
        lastCorrelationMatrix = Array(
            repeating: Array(repeating: 0.0, count: 3), count: 3)
        lastCrossEntropyMatrix = Array(
            repeating: Array(repeating: 0.0, count: 3), count: 3)
        lastConditionalEntropyMatrix = Array(
            repeating: Array(repeating: 0.0, count: 3), count: 3)
        lastMutualInformationMatrix = Array(
            repeating: Array(repeating: 0.0, count: 3), count: 3)

        currentClusterState = Array(repeating: false, count: 6)
    }

    /// Updates the HR and HRV data for a specific sensor with new IBI values.
    /// - Parameters:
    ///   - sensorID: The identifier of the sensor.
    ///   - hr: The heart rate value to update.
    ///   - ibiArray: The array of new IBI values received.
    ///   - isRecording: A Boolean value that indicates if a session is currently recording.
    func updateHRData(
        sensorID: String, hr: Double, ibiArray: [Double], isRecording: Bool
    ) {
        let currentTimestamp = Date()

        updateLastHR(sensorID: sensorID, hr: hr)
        updateHRArray(sensorID: sensorID, hr: hr, timestamp: currentTimestamp)

        updateIHRArray(
            sensorID: sensorID, ibiArray: ibiArray, isRecording: isRecording, currentTimestamp: currentTimestamp)
    }

    /// Sets the current session for data processing.
    func setCurrentSession(_ session: SessionEntity) {
        self.currentSession = session
    }

    /// Clears the current session when recording stops or is deleted.
    func clearCurrentSession() {
        self.currentSession = nil
    }

    /// Saves a sensor data event to Core Data.
    /// - Parameters:
    ///   - sensorID: The identifier of the sensor.
    ///   - timestamp: The timestamp for the event.
    ///   - session: The session entity associated with this event.
    private func saveSensorDataEvent(sensorID: String, timestamp: Date, session: SessionEntity) {
        let context = CoreDataStack.shared.context
        let event = SensorDataEvent(context: context)
        
        // Fetch the SensorEntity corresponding to the sensorID
        let fetchRequest: NSFetchRequest<SensorEntity> = SensorEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", sensorID)
        
        do {
            if let sensor = try context.fetch(fetchRequest).first {
                event.sensor = sensor
            } else {
                print("No sensor found with ID: \(sensorID)")
            }
        } catch {
            print("Failed to fetch sensor with ID \(sensorID): \(error)")
        }

        // Assign other values to the event
        event.timestamp = timestamp
        event.hrData = lastHR[sensorID] ?? 0.0
        event.hrvData = lastHRV[sensorID] ?? 0.0
        let ihr = lastIHR[sensorID] ?? 60.0
        event.ibiData = 60.0 / ihr
        event.session = session

        do {
            try context.save()
        } catch {
            print("Failed to save sensor data event: \(error)")
        }
    }

    /// Saves a matrix data event to Core Data.
    /// - Parameters:
    ///   - timestamp: The timestamp for the event.
    ///   - session: The session entity associated with this event.
    private func saveMatrixDataEvent(timestamp: Date, session: SessionEntity) {
        let context = CoreDataStack.shared.context
        let event = MatrixDataEvent(context: context)
        
        event.timestamp = timestamp
        event.proximityMatrix = ArrayTransformer().transformedValue(lastProximityMatrix) as? Data
        event.correlationMatrix = ArrayTransformer().transformedValue(lastCorrelationMatrix) as? Data
        event.crossEntropyMatrix = ArrayTransformer().transformedValue(lastCrossEntropyMatrix) as? Data
        event.conditionalEntropyMatrix = ArrayTransformer().transformedValue(lastConditionalEntropyMatrix) as? Data
        event.mutualInformationMatrix = ArrayTransformer().transformedValue(lastMutualInformationMatrix) as? Data
        event.session = session

        do {
            try context.save()
        } catch {
            print("Failed to save matrix data event: \(error)")
        }
    }

    /// Saves a cluster data event to Core Data.
    /// - Parameters:
    ///   - timestamp: The timestamp for the event.
    ///   - session: The session entity associated with this event.
    private func saveClusterDataEvent(timestamp: Date, session: SessionEntity) {
        let context = CoreDataStack.shared.context
        let event = ClusterDataEvent(context: context)
        
        event.timestamp = timestamp
        event.clusterState = ArrayTransformer().transformedValue(currentClusterState) as? Data
        event.session = session

        do {
            try context.save()
        } catch {
            print("Failed to save cluster data event: \(error)")
        }
    }


    // MARK: - Getter Functions

    func getLastHRData() -> [String: Double] {
        return lastHR
    }

    func getLastIHRData() -> [String: Double] {
        return lastIHR
    }

    func getDistanceMatrix() -> [[Double]] {
        return lastDistanceMatrix
    }

    func getProximityMatrix() -> [[Double]] {
        return lastProximityMatrix
    }

    func getCorrelationMatrix() -> [[Double]] {
        return lastCorrelationMatrix
    }

    func getCrossEntropyMatrix() -> [[Double]] {
        return lastCrossEntropyMatrix
    }

    func getConditionalEntropyMatrix() -> [[Double]] {
        return lastConditionalEntropyMatrix
    }

    func getMutualInformationMatrix() -> [[Double]] {
        return lastMutualInformationMatrix
    }

    func getHRData() -> [String: [HRDataPoint]] {
        var result: [String: [HRDataPoint]] = [:]
        for (sensorID, hrData) in hrArray {
            result[sensorID] = Array(hrData.suffix(60))
        }
        return result
    }

    func getIBIData() -> [String: [Double]] {
        var result: [String: [Double]] = [:]
        for (sensorID, ibiData) in ibiArray {
            result[sensorID] = Array(ibiData.suffix(60).map { $0 })
        }
        return result
    }

    func getIHRData() -> [String: [HRDataPoint]] {
        var result: [String: [HRDataPoint]] = [:]
        for (sensorID, ihrData) in ihrArray {
            result[sensorID] = Array(ihrData.suffix(60))
        }
        return result
    }

    func getHRVData() -> [String: [HRVDataPoint]] {
        var result: [String: [HRVDataPoint]] = [:]
        for (sensorID, hrvData) in hrvArray {
            result[sensorID] = Array(hrvData.suffix(60))
        }
        return result
    }

    func getStatistics() -> [String: [Double]] {
        var statistics: [String: [Double]] = [:]
        for sensorID in hrArray.keys {
            if let stats = computeStatistics(sensorID: sensorID) {
                statistics[sensorID] = [
                    stats.min, stats.max, stats.median, stats.mean,
                ]
            }
        }
        return statistics
    }

    func getClusterState() -> [Bool] {
        return currentClusterState
    }

    // MARK: - Setter Functions

    /// Sets the HR array for all sensors at once.
    /// This function initializes or replaces the HR arrays for all specified sensors with the provided data.
    ///
    /// - Parameter hrData: A dictionary where each key is a sensor ID and the value is an array of `HRDataPoint`.
    func setHRArray(hrData: [String: [HRDataPoint]]) {
        for (sensorID, dataPoints) in hrData {
            hrArray[sensorID] = Array(dataPoints.suffix(100))  // Keep only the last 100 entries
        }
    }

    /// Sets the IHR array for all sensors at once.
    /// This function initializes or replaces the IHR arrays for all specified sensors with the provided data.
    ///
    /// - Parameter ihrData: A dictionary where each key is a sensor ID and the value is an array of `HRDataPoint`.
    func setIHRArray(ihrData: [String: [HRDataPoint]]) {
        for (sensorID, dataPoints) in ihrData {
            ihrArray[sensorID] = Array(dataPoints.suffix(100))  // Keep only the last 100 entries
        }
    }

    /// Sets the HRV array for all sensors at once.
    /// This function initializes or replaces the HRV arrays for all specified sensors with the provided data.
    ///
    /// - Parameter hrvData: A dictionary where each key is a sensor ID and the value is an array of `HRVDataPoint`.
    func setHRVArray(hrvData: [String: [HRVDataPoint]]) {
        for (sensorID, dataPoints) in hrvData {
            hrvArray[sensorID] = Array(dataPoints.suffix(100))  // Keep only the last 100 entries
        }
    }

    /// Sets the IBI array for all sensors at once.
    /// This function initializes or replaces the IBI arrays for all specified sensors with the provided data.
    ///
    /// - Parameter ibiData: A dictionary where each key is a sensor ID and the value is an array of `Double`.
    func setIBIArray(ibiData: [String: [Double]]) {
        for (sensorID, dataPoints) in ibiData {
            ibiArray[sensorID] = Array(dataPoints.suffix(100))  // Keep only the last 100 entries
        }
    }

    // MARK: - Private Update Functions

    /// Updates the last HR value for a given sensor.
    private func updateLastHR(sensorID: String, hr: Double) {
        lastHR[sensorID] = hr
    }
    
    /// Updates the last IHR value for a given sensor.
    private func updateLastIHR(sensorID: String, ihr: Double) {
        lastIHR[sensorID] = ihr
    }
    
    /// Updates the last IHR value for a given sensor.
    private func updateLastHRV(sensorID: String, hrv: Double) {
        lastHRV[sensorID] = hrv
    }

    /// Updates the HR array for a given sensor with a new data point.
    private func updateHRArray(sensorID: String, hr: Double, timestamp: Date) {
        var sensorHRArray = hrArray[sensorID] ?? []
        let newHRDataPoint = HRDataPoint(timestamp: timestamp, hrValue: hr)

        sensorHRArray.append(newHRDataPoint)
        if sensorHRArray.count > 100 {
            sensorHRArray.removeFirst(sensorHRArray.count - 100)
        }
        hrArray[sensorID] = sensorHRArray
    }

    /// Updates the IHR array and HRV array for a given sensor with new IBI values.
    private func updateIHRArray(
        sensorID: String, ibiArray: [Double], isRecording: Bool, currentTimestamp: Date
    ) {
        self.ibiArray[sensorID] = (self.ibiArray[sensorID] ?? []) + ibiArray
        if let sensorIBIArray = self.ibiArray[sensorID],
            sensorIBIArray.count > 100
        {
            self.ibiArray[sensorID] = Array(sensorIBIArray.suffix(100))
        }

        for ibi in ibiArray {
            let instantaneousHR = 60.0 / ibi
            lastIHR[sensorID] = instantaneousHR
            let newIHRDataPoint = HRDataPoint(
                timestamp: currentTimestamp, hrValue: instantaneousHR)

            var sensorIHRArray = ihrArray[sensorID] ?? []
            sensorIHRArray.append(newIHRDataPoint)
            if sensorIHRArray.count > 100 {
                sensorIHRArray.removeFirst(sensorIHRArray.count - 100)
            }
            ihrArray[sensorID] = sensorIHRArray

            if let hrv = computeHRV(sensorID: sensorID) {
                updateHRVArray(
                    sensorID: sensorID, hrv: hrv, timestamp: currentTimestamp)
            }
            
            updateMatrices()
            updateClusterState()

            triggerUpdate()

            if isRecording, let currentSession = currentSession {
                saveSensorDataEvent(
                    sensorID: sensorID, timestamp: currentTimestamp,
                    session: currentSession)
                saveMatrixDataEvent(
                    timestamp: currentTimestamp, session: currentSession)
                saveClusterDataEvent(
                    timestamp: currentTimestamp, session: currentSession)
            }

        }
    }

    /// Updates the HRV array for a given sensor.
    private func updateHRVArray(sensorID: String, hrv: Double, timestamp: Date)
    {
        var sensorHRVArray = hrvArray[sensorID] ?? []
        let newHRVDataPoint = HRVDataPoint(timestamp: timestamp, hrvValue: hrv)

        sensorHRVArray.append(newHRVDataPoint)
        if sensorHRVArray.count > 100 {
            sensorHRVArray.removeFirst(sensorHRVArray.count - 100)
        }
        hrvArray[sensorID] = sensorHRVArray
        lastHRV[sensorID] = hrv
    }

    /// Updates all the matrices (distance, proximity, correlation, etc.).
    private func updateMatrices() {
        for i in 0..<sensorOrder.count {
            for j in i..<sensorOrder.count {
                let sensorID1 = sensorOrder[i]
                let sensorID2 = sensorOrder[j]

                // Update Distance Matrix
                let distance = computeDistance(
                    from: lastHR[sensorID1]!, to: lastHR[sensorID2]!)
                lastDistanceMatrix[i][j] = distance
                lastDistanceMatrix[j][i] = distance

                // Update Proximity Matrix
                let proximity = 1.0 - distance
                lastProximityMatrix[i][j] = proximity
                lastProximityMatrix[j][i] = proximity
            }
        }

        updateCorrelationMatrix()
        updateCrossEntropyMatrix()
        updateConditionalEntropyMatrix()
        updateMutualInformationMatrix()
    }

    /// Updates the cluster state based on the current proximity matrix.
    private func updateClusterState() {
        var newState: [Bool] = Array(repeating: false, count: 6)

        newState[1] = lastProximityMatrix[0][1] > 1 - threshold
        newState[2] = lastProximityMatrix[0][2] > 1 - threshold
        newState[3] = lastProximityMatrix[1][2] > 1 - threshold

        if newState[1] && newState[2] && newState[3] {
            newState[5] = true
            newState[1] = false
            newState[2] = false
            newState[3] = false
        } else if (newState[1] && newState[2]) || (newState[1] && newState[3])
            || (newState[2] && newState[3])
        {
            newState[4] = true
            newState[1] = false
            newState[2] = false
            newState[3] = false
        }

        newState[0] = newState[1...5] != currentClusterState[1...5]

        currentClusterState = newState
    }

    // MARK: - Private Matrix Update Functions

    /// Updates the correlation matrix based on derivatives of the IHR array.
    private func updateCorrelationMatrix() {
        for i in 0..<sensorOrder.count {
            for j in i..<sensorOrder.count {
                let derivative1 = computeDerivatives(sensorID: sensorOrder[i])
                let derivative2 = computeDerivatives(sensorID: sensorOrder[j])

                let correlation = computeCorrelation(
                    array1: derivative1, array2: derivative2)
                lastCorrelationMatrix[i][j] = correlation
                lastCorrelationMatrix[j][i] = correlation
            }
        }
    }

    /// Updates the cross entropy matrix based on the IHR array.
    private func updateCrossEntropyMatrix() {
        for i in 0..<sensorOrder.count {
            for j in i..<sensorOrder.count {
                let crossEntropy = computeCrossEntropy(
                    sensorID1: sensorOrder[i], sensorID2: sensorOrder[j])
                lastCrossEntropyMatrix[i][j] = crossEntropy
                lastCrossEntropyMatrix[j][i] = crossEntropy
            }
        }
    }

    /// Updates the conditional entropy matrix based on the IHR array.
    private func updateConditionalEntropyMatrix() {
        for i in 0..<sensorOrder.count {
            for j in i..<sensorOrder.count {
                let conditionalEntropy = computeConditionalEntropy(
                    sensorID1: sensorOrder[i], sensorID2: sensorOrder[j])
                lastConditionalEntropyMatrix[i][j] = conditionalEntropy
                lastConditionalEntropyMatrix[j][i] = conditionalEntropy
            }
        }
    }

    /// Updates the mutual information matrix based on the IHR array.
    private func updateMutualInformationMatrix() {
        for i in 0..<sensorOrder.count {
            for j in i..<sensorOrder.count {
                let mutualInformation = computeMutualInformation(
                    sensorID1: sensorOrder[i], sensorID2: sensorOrder[j])
                lastMutualInformationMatrix[i][j] = mutualInformation
                lastMutualInformationMatrix[j][i] = mutualInformation
            }
        }
    }

    /// Computes the Pearson correlation coefficient between two arrays of derivatives.
    /// The Pearson correlation coefficient measures the linear relationship between two sets of data.
    /// It ranges from -1 to 1, where 1 means a perfect positive linear relationship, -1 means a perfect negative linear relationship, and 0 means no linear relationship.
    ///
    /// - Parameters:
    ///   - array1: The first array of derivatives.
    ///   - array2: The second array of derivatives.
    /// - Returns: The Pearson correlation coefficient between `array1` and `array2`.
    private func computeCorrelation(array1: [Double], array2: [Double])
        -> Double
    {
        guard array1.count == array2.count, array1.count > 1 else {
            return 0.0  // Return 0.0 if arrays are not of equal length or too short to compute
        }

        let mean1 = array1.reduce(0, +) / Double(array1.count)
        let mean2 = array2.reduce(0, +) / Double(array2.count)

        var numerator: Double = 0.0
        var denominator1: Double = 0.0
        var denominator2: Double = 0.0

        for i in 0..<array1.count {
            let diff1 = array1[i] - mean1
            let diff2 = array2[i] - mean2
            numerator += diff1 * diff2
            denominator1 += diff1 * diff1
            denominator2 += diff2 * diff2
        }

        let denominator = sqrt(denominator1 * denominator2)
        return denominator == 0.0 ? 0.0 : numerator / denominator
    }

    private func computeCrossEntropy(sensorID1: String, sensorID2: String, bins: Int = 10) -> Double {
        guard let ihrArray1 = ihrArray[sensorID1],
              let ihrArray2 = ihrArray[sensorID2],
              ihrArray1.count == ihrArray2.count, !ihrArray1.isEmpty else {
            return 0.0  // Return 0.0 if arrays are not of equal length or empty
        }

        // Determine the range of the data (you can adjust this as needed)
        let hrMin = 0.0
        let hrMax = 200.0

        // Create empty histograms
        var histogram1 = [Double](repeating: 0.0, count: bins)
        var histogram2 = [Double](repeating: 0.0, count: bins)

        // Bin the data
        for i in 0..<ihrArray1.count {
            let hr1 = ihrArray1[i].hrValue
            let hr2 = ihrArray2[i].hrValue

            let bin1 = min(Int((hr1 - hrMin) / (hrMax - hrMin) * Double(bins)), bins - 1)
            let bin2 = min(Int((hr2 - hrMin) / (hrMax - hrMin) * Double(bins)), bins - 1)

            histogram1[bin1] += 1.0
            histogram2[bin2] += 1.0
        }

        // Normalize the histograms
        let total1 = histogram1.reduce(0, +)
        let total2 = histogram2.reduce(0, +)

        for i in 0..<bins {
            histogram1[i] = histogram1[i] / total1
            histogram2[i] = histogram2[i] / total2
        }

        // Compute the cross-entropy
        var crossEntropy: Double = 0.0
        let epsilon = 1e-12

        for i in 0..<bins {
            let p1 = histogram1[i] + epsilon
            let p2 = histogram2[i] + epsilon
            crossEntropy -= p1 * log(p2)
        }

        return crossEntropy
    }

    private func computeConditionalEntropy(sensorID1: String, sensorID2: String, bins: Int = 10) -> Double {
        guard let ihrArray1 = ihrArray[sensorID1],
              let ihrArray2 = ihrArray[sensorID2],
              ihrArray1.count == ihrArray2.count, !ihrArray1.isEmpty else {
            return 0.0  // Return 0.0 if arrays are not of equal length or empty
        }

        let epsilon = 1e-12
        var conditionalEntropy: Double = 0.0

        // Define the range for binning (adjust as needed)
        let hrMin = 0.0
        let hrMax = 200.0

        // Create joint and marginal histograms (joint distribution and marginal of series1)
        var jointHistogram = Array(repeating: Array(repeating: 0.0, count: bins), count: bins)
        var marginalHistogram = Array(repeating: 0.0, count: bins)

        for i in 0..<ihrArray1.count {
            let hr1 = ihrArray1[i].hrValue
            let hr2 = ihrArray2[i].hrValue

            let binX = min(Int((hr1 - hrMin) / (hrMax - hrMin) * Double(bins)), bins - 1)
            let binY = min(Int((hr2 - hrMin) / (hrMax - hrMin) * Double(bins)), bins - 1)

            jointHistogram[binX][binY] += 1.0
            marginalHistogram[binX] += 1.0
        }

        // Normalize the histograms to convert counts to probabilities
        let totalJoint = jointHistogram.flatMap { $0 }.reduce(0, +)
        let totalMarginal = marginalHistogram.reduce(0, +)

        for i in 0..<bins {
            marginalHistogram[i] = (marginalHistogram[i] + epsilon) / totalMarginal
            for j in 0..<bins {
                jointHistogram[i][j] = (jointHistogram[i][j] + epsilon) / totalJoint
            }
        }

        // Calculate conditional entropy H(Y|X)
        for i in 0..<bins {
            for j in 0..<bins {
                let jointProbability = jointHistogram[i][j]
                let marginalProbability = marginalHistogram[i]

                if jointProbability > 0.0 && marginalProbability > 0.0 {
                    conditionalEntropy -= jointProbability * log(jointProbability / marginalProbability)
                }
            }
        }

        return conditionalEntropy
    }

    private func computeMutualInformation(sensorID1: String, sensorID2: String, bins: Int = 10) -> Double {
        guard let ihrArray1 = ihrArray[sensorID1],
              let ihrArray2 = ihrArray[sensorID2],
              ihrArray1.count == ihrArray2.count, !ihrArray1.isEmpty else {
            return 0.0  // Return 0.0 if arrays are not of equal length or empty
        }

        let epsilon = 1e-12
        var mutualInformation: Double = 0.0

        // Define the range for binning (adjust as needed)
        let hrMin = 0.0
        let hrMax = 200.0

        // Create joint and marginal histograms
        var jointHistogram = Array(repeating: Array(repeating: 0.0, count: bins), count: bins)
        var marginalHistogram1 = Array(repeating: 0.0, count: bins)
        var marginalHistogram2 = Array(repeating: 0.0, count: bins)

        for i in 0..<ihrArray1.count {
            let hr1 = ihrArray1[i].hrValue
            let hr2 = ihrArray2[i].hrValue

            let binX = min(Int((hr1 - hrMin) / (hrMax - hrMin) * Double(bins)), bins - 1)
            let binY = min(Int((hr2 - hrMin) / (hrMax - hrMin) * Double(bins)), bins - 1)

            jointHistogram[binX][binY] += 1.0
            marginalHistogram1[binX] += 1.0
            marginalHistogram2[binY] += 1.0
        }

        // Normalize the histograms to represent probability distributions
        let totalJoint = jointHistogram.flatMap { $0 }.reduce(0, +)
        let totalMarginal1 = marginalHistogram1.reduce(0, +)
        let totalMarginal2 = marginalHistogram2.reduce(0, +)

        for i in 0..<bins {
            marginalHistogram1[i] = (marginalHistogram1[i] + epsilon) / totalMarginal1
            marginalHistogram2[i] = (marginalHistogram2[i] + epsilon) / totalMarginal2
            for j in 0..<bins {
                jointHistogram[i][j] = (jointHistogram[i][j] + epsilon) / totalJoint
            }
        }

        // Calculate mutual information
        for i in 0..<bins {
            for j in 0..<bins {
                let jointProbability = jointHistogram[i][j]
                let marginalProbability1 = marginalHistogram1[i]
                let marginalProbability2 = marginalHistogram2[j]

                if jointProbability > 0.0 {
                    mutualInformation += jointProbability * log(jointProbability / (marginalProbability1 * marginalProbability2))
                }
            }
        }

        return mutualInformation
    }


    /// Calculates the minimum, maximum, median, and mean HR values for a specific sensor.
    private func computeStatistics(sensorID: String) -> (
        min: Double, max: Double, median: Double, mean: Double
    )? {
        guard let hrDataPoints = hrArray[sensorID] else { return nil }
        let hrValues = hrDataPoints.map { $0.hrValue }

        let min = hrValues.min() ?? 0
        let max = hrValues.max() ?? 0
        let median = hrValues.sorted()[hrValues.count / 2]
        let mean = hrValues.reduce(0, +) / Double(hrValues.count)

        return (min, max, median, mean)
    }

    // MARK: - Private Helper Functions

    /// Calculates the Heart Rate Variability (HRV) using the Root Mean Square of Successive Differences (RMSSD) method.
    private func computeHRV(sensorID: String) -> Double? {
        guard let ibis = ibiArray[sensorID], ibis.count > 1 else { return nil }

        let diffIBIs = zip(ibis.dropFirst(), ibis).map { $0 - $1 }
        let squaredDifferences = diffIBIs.map { $0 * $0 }
        let meanSquareDifference =
            squaredDifferences.reduce(0, +) / Double(squaredDifferences.count)

        return sqrt(meanSquareDifference)
    }

    /// Calculates the distance between two instantaneous HR values.
    private func computeDistance(from hr1: Double, to hr2: Double) -> Double {
        return abs(mapHRToUnitInterval(hr1) - mapHRToUnitInterval(hr2))
    }

    /// Maps HR values from the range [0, 200] to [0, 1].
    private func mapHRToUnitInterval(_ hr: Double) -> Double {
        return min(max(hr / 200.0, 0.0), 1.0)
    }

    /// Computes the derivatives of the IHR array for a given sensor.
    private func computeDerivatives(sensorID: String) -> [Double] {
        guard let ihrArray = ihrArray[sensorID] else { return [] }
        var derivatives: [Double] = []
        for i in 1..<ihrArray.count {
            derivatives.append(ihrArray[i].hrValue - ihrArray[i - 1].hrValue)
        }
        return derivatives
    }

    /// Computes the proximity score, which is the mean of the upper triangular part of the proximity matrix.
    /// The proximity score indicates how close the sensors' heart rates are to each other.
    /// It is calculated as the average of the upper triangle of the proximity matrix.
    ///
    /// - Returns: The proximity score as a `Double`.
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

    /// Triggers a UI update by toggling the `isUpdated` property.
    private func triggerUpdate() {
        isUpdated = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isUpdated = false
        }
    }

}
