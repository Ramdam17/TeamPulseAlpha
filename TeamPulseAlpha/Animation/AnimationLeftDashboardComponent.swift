//
//  DashboardComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import Charts
import SwiftUI

/// A SwiftUI view that displays the dashboard, including various charts and statistics related to sensor data.
struct AnimationLeftDashboardComponent: View {

    @Environment(SensorDataProcessor.self) var sensorDataProcessor  // Listen to the sensor data processor

    var body: some View {
        GeometryReader { metrics in
            VStack(spacing: 20) {  // Added spacing between sections for better visual separation
                // Poincare map visualization for IBI data from the sensors.
                
                PoincareMapComponent(
                    data: sensorDataProcessor.ibiArray,
                    colors: [.blue, .green, .red]
                )
                .frame(height: metrics.size.height * 0.75)
                
                // Proximity ring chart showing proximity score.
                ProximityRingChartComponent(
                    data: sensorDataProcessor.computeProximityScore(),
                    color: Color(red: 1.0, green: 0.84, blue: 0.0)
                )
                .frame(height: metrics.size.height * 0.15)
                
            }
            .padding()  // Add padding around the entire VStack for better spacing.
        }
    }
}

struct AnimationLeftDashboardComponent_Previews: PreviewProvider {
    static var previews: some View {
        // Example data for preview purposes
        let exampleHRData: [String: [HRDataPoint]] = [
            "Blue": (0..<60).map {
                HRDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrValue: Double.random(in: 60...100))
            },
            "Green": (0..<60).map {
                HRDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrValue: Double.random(in: 60...100))
            },
            "Red": (0..<60).map {
                HRDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrValue: Double.random(in: 60...100))
            },
        ]

        let exampleHRVData: [String: [HRVDataPoint]] = [
            "Blue": (0..<60).map {
                HRVDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrvValue: Double.random(in: 00...1))
            },
            "Green": (0..<60).map {
                HRVDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrvValue: Double.random(in: 0...1))
            },
            "Red": (0..<60).map {
                HRVDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrvValue: Double.random(in: 0...1))
            },
        ]

        let exampleIBIData: [String: [Double]] = [
            "Blue": [0.85, 0.88, 0.87, 0.86, 0.89, 0.84],
            "Green": [0.78, 0.77, 0.76, 0.75, 0.79, 0.74],
            "Red": [0.92, 0.91, 0.93, 0.94, 0.95, 0.96],
        ]

        // Mock SensorDataProcessor to inject example data
        let mockSensorDataProcessor = SensorDataProcessor()
        mockSensorDataProcessor.hrArray = exampleHRData
        mockSensorDataProcessor.hrvArray = exampleHRVData
        mockSensorDataProcessor.ibiArray = exampleIBIData

        return Group {
            // iPhone 15 Pro Preview
            AnimationLeftDashboardComponent()
                .environment(mockSensorDataProcessor)
                .previewLayout(.sizeThatFits)  // Ensures the preview is sized appropriately
                .padding()
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
                .previewDisplayName("iPhone 15 Pro")

            // iPad Pro 11-inch Preview
            AnimationLeftDashboardComponent()
                .environment(mockSensorDataProcessor)
                .previewLayout(.sizeThatFits)  // Ensures the preview is sized appropriately
                .padding()
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (11-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 11-inch")

            // iPad Pro 13-inch Preview
            AnimationLeftDashboardComponent()
                .environment(mockSensorDataProcessor)
                .previewLayout(.sizeThatFits)  // Ensures the preview is sized appropriately
                .padding()
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (12.9-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 13-inch")
        }
    }
}
