//
//  ChartHelper.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 9/2/24.
//

import Foundation
import SwiftUI

/// Helper function to safely extract timestamp and heart rate value
func extractHRData(from dataPoint: [String: Any]) -> (
    timestamp: Date, hrValue: Double
)? {
    guard let timestamp = dataPoint["timestamp"] as? Date,
        let hrValue = dataPoint["hrValue"] as? Double
    else {
        return nil
    }
    return (timestamp, hrValue)
}

/// Helper function to safely extract timestamp and HRV value
func extractHRVData(from dataPoint: [String: Any]) -> (
    timestamp: Date, hrvValue: Double
)? {
    guard let timestamp = dataPoint["timestamp"] as? Date,
        let hrvValue = dataPoint["hrvValue"] as? Double
    else {
        return nil
    }
    return (timestamp, hrvValue)
}

/// Helper function to safely extract timestamp and IBI value
func extractIBIData(from dataPoint: [String: Any]) -> (
    timestamp: Date, ibiValue: Double
)? {
    guard let timestamp = dataPoint["timestamp"] as? Date,
        let ibiValue = dataPoint["ibiValue"] as? Double
    else {
        return nil
    }
    return (timestamp, ibiValue)
}

/// Function to calculate basic statistics (min, max, median, mean) from a list of HR values
func computeStatistics(for hrData: [[String: Any]]) -> [(
    min: Double, max: Double, median: Double, mean: Double
)] {
    var stats: [(min: Double, max: Double, median: Double, mean: Double)] = []

    // Extract HR values for each timestamp
    let hrValues = hrData.compactMap { $0["hrValue"] as? Double }

    guard !hrValues.isEmpty else { return stats }

    let sortedValues = hrValues.sorted()
    let min = sortedValues.first ?? 0.0
    let max = sortedValues.last ?? 0.0
    let median = sortedValues[sortedValues.count / 2]
    let mean = sortedValues.reduce(0, +) / Double(sortedValues.count)

    stats.append((min: min, max: max, median: median, mean: mean))

    return stats
}

/// Function to determine the color for a heatmap cell based on the value
func heatmapColor(for value: Double) -> Color {
    let normalizedValue = max(0, min(1, value * 2))  // Ensure the value is within [0, 1]
    return Color(red: normalizedValue, green: 0, blue: 1 - normalizedValue)
}
