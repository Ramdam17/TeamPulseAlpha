//
//  SensorDataProcessing.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import Foundation

/// Data structure that holds a heart rate (HR) value and its corresponding timestamp.
struct HRDataPoint {
    let timestamp: Date   // Timestamp when the HR value was recorded
    let hrValue: Double   // The HR value recorded at the timestamp
}

/// Class responsible for processing and managing sensor data such as heart rate and related metrics.
class SensorDataProcessor {
    
    /// Stores the last recorded HR value for each sensor.
    var lastHR: [UUID: Double] = [:]
    
    /// Stores the last recorded instantaneous HR value for each sensor.
    var lastInstantaneousHR: [UUID: Double] = [:]
    
    /// Stores an array of the last 100 HR data points (with timestamps) for each sensor.
    var hrArray: [UUID: [HRDataPoint]] = [:]
    
    /// Initializes the data processor with an array of sensor IDs.
    /// Sets up the `hrArray` for each sensor with 100 initial HR values set to 60.
    ///
    /// - Parameter sensorIDs: An array of UUIDs representing the sensors being monitored.
    init(sensorIDs: [UUID]) {
        for id in sensorIDs {
            // Initialize the HR array with 100 entries, all set to HR value of 60.
            hrArray[id] = Array(repeating: HRDataPoint(timestamp: Date(), hrValue: 60.0), count: 100)
        }
    }
    
    /// Updates the HR data for a specific sensor with a new HR value and IBI (Inter-Beat Interval).
    ///
    /// - Parameters:
    ///   - sensorID: The UUID of the sensor.
    ///   - hr: The latest HR value received.
    ///   - ibi: The latest IBI value received.
    func updateHRData(sensorID: UUID, hr: Double, ibi: Double) {
        let currentTimestamp = Date()
        
        // Store the latest HR and instantaneous HR values
        lastHR[sensorID] = hr
        lastInstantaneousHR[sensorID] = 60.0 / ibi
        
        // Create a new HR data point with the current timestamp
        let newHRDataPoint = HRDataPoint(timestamp: currentTimestamp, hrValue: lastInstantaneousHR[sensorID]!)
        
        // Append the new data point to the HR array and remove the oldest if the array exceeds 100 entries
        hrArray[sensorID]?.append(newHRDataPoint)
        if hrArray[sensorID]!.count > 100 {
            hrArray[sensorID]?.removeFirst()
        }
    }
    
    /// Calculates the minimum, maximum, median, and mean HR values for a specific sensor.
    ///
    /// - Parameter sensorID: The UUID of the sensor.
    /// - Returns: A tuple containing the minimum, maximum, median, and mean HR values, or `nil` if no data exists.
    func calculateStatistics(sensorID: UUID) -> (min: Double, max: Double, median: Double, mean: Double)? {
        guard let hrDataPoints = hrArray[sensorID] else { return nil }
        let hrValues = hrDataPoints.map { $0.hrValue }
        
        let min = hrValues.min() ?? 0
        let max = hrValues.max() ?? 0
        let median = hrValues.sorted(by: <)[hrValues.count / 2]
        let mean = hrValues.reduce(0, +) / Double(hrValues.count)
        
        return (min, max, median, mean)
    }
    
    /// Calculates the Heart Rate Variability (HRV) using the Root Mean Square of Successive Differences (RMSSD) method.
    ///
    /// - Parameter sensorID: The UUID of the sensor.
    /// - Returns: The HRV value or `nil` if there is insufficient data.
    func calculateHRV(sensorID: UUID) -> Double? {
        guard let hrDataPoints = hrArray[sensorID] else { return nil }
        // Filter data points to include only those within the last 60 seconds
        let recentData = hrDataPoints.filter { Date().timeIntervalSince($0.timestamp) <= 60 }
        guard recentData.count > 1 else { return nil }
        
        var squaredDifferences: [Double] = []
        for i in 1..<recentData.count {
            let diff = recentData[i].hrValue - recentData[i - 1].hrValue
            squaredDifferences.append(diff * diff)
        }
        
        let meanSquareDifference = squaredDifferences.reduce(0, +) / Double(squaredDifferences.count)
        return sqrt(meanSquareDifference)
    }
    
    /// Computes a distance matrix based on the instantaneous HR values between sensors.
    ///
    /// - Parameter sensorIDs: An array of UUIDs representing the sensors.
    /// - Returns: A 2D array representing the distance matrix.
    func computeDistancesMatrix(sensorIDs: [UUID]) -> [[Double]] {
        var matrix: [[Double]] = []
        
        for id1 in sensorIDs {
            var row: [Double] = []
            for id2 in sensorIDs {
                if id1 == id2 {
                    row.append(0) // Distance to self is always 0
                } else {
                    let distance = abs((lastInstantaneousHR[id1] ?? 0) - (lastInstantaneousHR[id2] ?? 0))
                    row.append(distance)
                }
            }
            matrix.append(row)
        }
        return matrix
    }
    
    /// Computes a correlation matrix based on the HR arrays between sensors.
    ///
    /// - Parameter sensorIDs: An array of UUIDs representing the sensors.
    /// - Returns: A 2D array representing the correlation matrix.
    func computeCorrelationMatrix(sensorIDs: [UUID]) -> [[Double]] {
        var matrix: [[Double]] = []
        
        for id1 in sensorIDs {
            var row: [Double] = []
            for id2 in sensorIDs {
                if id1 == id2 {
                    row.append(1.0) // Correlation with self is always 1
                } else {
                    if let correlation = calculateCorrelation(hrArray1: hrArray[id1]!, hrArray2: hrArray[id2]!) {
                        row.append(correlation)
                    } else {
                        row.append(0.0) // If unable to calculate correlation, append 0
                    }
                }
            }
            matrix.append(row)
        }
        return matrix
    }
    
    /// Helper function to calculate the correlation between two HR arrays.
    ///
    /// - Parameters:
    ///   - hrArray1: The first HR array.
    ///   - hrArray2: The second HR array.
    /// - Returns: The correlation value, or `nil` if the arrays differ in length.
    private func calculateCorrelation(hrArray1: [HRDataPoint], hrArray2: [HRDataPoint]) -> Double? {
        guard hrArray1.count == hrArray2.count else { return nil }
        
        let mean1 = hrArray1.map { $0.hrValue }.reduce(0, +) / Double(hrArray1.count)
        let mean2 = hrArray2.map { $0.hrValue }.reduce(0, +) / Double(hrArray2.count)
        
        var numerator: Double = 0
        var denominator1: Double = 0
        var denominator2: Double = 0
        
        for i in 0..<hrArray1.count {
            let x = hrArray1[i].hrValue - mean1
            let y = hrArray2[i].hrValue - mean2
            numerator += x * y
            denominator1 += x * x
            denominator2 += y * y
        }
        
        return numerator / sqrt(denominator1 * denominator2)
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
                    row.append(0.0) // Cross-entropy with self is 0
                } else {
                    if let crossEntropy = calculateCrossEntropy(hrArray1: hrArray[id1]!, hrArray2: hrArray[id2]!) {
                        row.append(crossEntropy)
                    } else {
                        row.append(Double.infinity) // Use infinity for undefined cross-entropy
                    }
                }
            }
            matrix.append(row)
        }
        return matrix
    }
    
    /// Helper function to calculate the cross-entropy between two HR arrays.
    ///
    /// - Parameters:
    ///   - hrArray1: The first HR array.
    ///   - hrArray2: The second HR array.
    /// - Returns: The cross-entropy value, or `nil` if the arrays differ in length.
    private func calculateCrossEntropy(hrArray1: [HRDataPoint], hrArray2: [HRDataPoint]) -> Double? {
        guard hrArray1.count == hrArray2.count else { return nil }
        
        let epsilon = 1e-10 // Small constant to prevent log(0)
        var crossEntropy: Double = 0
        
        for i in 0..<hrArray1.count {
            let p = hrArray1[i].hrValue / 60.0 // Normalize HR to a probability
            let q = hrArray2[i].hrValue / 60.0 // Normalize HR to a probability
            crossEntropy += -p * log(q + epsilon)
        }
        
        return crossEntropy / Double(hrArray1.count)
    }
}
