//
//  DashboardComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import SwiftUI
import Charts

/// A SwiftUI view that displays the dashboard, including various charts and statistics related to sensor data.
struct DashboardComponent: View {

    @Environment(SensorDataProcessor.self) var sensorDataProcessor  // Listen to the sensor data processor

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {  // Added spacing between sections for better visual separation
                // Display the title of the dashboard.
                Text("Dashboard")
                    .font(.headline) // Set the font style for the title
                
                // Line chart showing HR data from the sensors.
                LineChartHRComponent(
                    data: sensorDataProcessor.hrArray,
                    colors: [.blue, .green, .red]
                )
                
                // Line chart showing HRV data from the sensors.
                LineChartHRVComponent(
                    data: sensorDataProcessor.hrvArray,
                    colors: [.blue, .green, .red]
                )
                
                // Poincare map visualization for IBI data from the sensors.
                PoincareMapComponent(
                    data: sensorDataProcessor.ibiArray,
                    colors: [.blue, .green, .red]
                )
                
                // Box plot showing statistical distribution of HR data.
                BoxPlotComponent(
                    data: sensorDataProcessor.getStatistics(),
                    colors: [.blue, .green, .red]
                )
                
                // Proximity ring chart showing proximity score.
                ProximityRingChartComponent(
                    data: sensorDataProcessor.computeProximityScore(),
                    color: Color(red: 1.0, green: 0.84, blue: 0.0)
                )
                
            }
            .padding() // Add padding around the entire VStack for better spacing.
        }
    }
}

struct DashboardComponent_Previews: PreviewProvider {
    static var previews: some View {
        // Example data for preview purposes
        let exampleHRData: [String: [HRDataPoint]] = [
            "Blue": (0..<60).map { HRDataPoint(timestamp: Date().addingTimeInterval(Double($0) * 60), hrValue: Double.random(in: 60...100)) },
            "Green": (0..<60).map { HRDataPoint(timestamp: Date().addingTimeInterval(Double($0) * 60), hrValue: Double.random(in: 60...100)) },
            "Red": (0..<60).map { HRDataPoint(timestamp: Date().addingTimeInterval(Double($0) * 60), hrValue: Double.random(in: 60...100)) }
        ]
        
        let exampleHRVData: [String: [HRVDataPoint]] = [
            "Blue": (0..<60).map { HRVDataPoint(timestamp: Date().addingTimeInterval(Double($0) * 60), hrvValue: Double.random(in: 20...40)) },
            "Green": (0..<60).map { HRVDataPoint(timestamp: Date().addingTimeInterval(Double($0) * 60), hrvValue: Double.random(in: 20...40)) },
            "Red": (0..<60).map { HRVDataPoint(timestamp: Date().addingTimeInterval(Double($0) * 60), hrvValue: Double.random(in: 20...40)) }
        ]
        
        let exampleIBIData: [String: [Double]] = [
            "Blue": [0.85, 0.88, 0.87, 0.86, 0.89, 0.84],
            "Green": [0.78, 0.77, 0.76, 0.75, 0.79, 0.74],
            "Red": [0.92, 0.91, 0.93, 0.94, 0.95, 0.96]
        ]

        // Mock SensorDataProcessor to inject example data
        let mockSensorDataProcessor = SensorDataProcessor()
        mockSensorDataProcessor.hrArray = exampleHRData
        mockSensorDataProcessor.hrvArray = exampleHRVData
        mockSensorDataProcessor.ibiArray = exampleIBIData

        return DashboardComponent()
            .environment(mockSensorDataProcessor)
            .previewLayout(.sizeThatFits) // Ensures the preview is sized appropriately
            .padding()
    }
}
