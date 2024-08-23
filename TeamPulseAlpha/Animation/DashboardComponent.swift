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
            VStack {
                // Display the title of the dashboard.
                Text("Dashboard")
                    .font(.headline) // Set the font style for the title
                
                LineChartHRComponent(
                    data: sensorDataProcessor.hrArray,
                    colors: [.blue, .green, .red]
                )
                
                LineChartHRVComponent(
                    data: sensorDataProcessor.hrvArray,
                    colors: [.blue, .green, .red]
                )
                
                PoincareMapComponent(
                    data: sensorDataProcessor.ibiArray,
                    colors: [.blue, .green, .red]
                )
                
                BoxPlotComponent(
                    data: sensorDataProcessor.getStatistics(), // Assuming it returns [UUID: [Double]]
                    colors: [.blue, .green, .red]
                )
                
                
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
        let exampleHRData: [UUID: [HRDataPoint]] = [
            UUID(): (0..<60).map { HRDataPoint(timestamp: Date().addingTimeInterval(Double($0)), hrValue: Double.random(in: 60...100)) },
            UUID(): (0..<60).map { HRDataPoint(timestamp: Date().addingTimeInterval(Double($0)), hrValue: Double.random(in: 60...100)) },
            UUID(): (0..<60).map { HRDataPoint(timestamp: Date().addingTimeInterval(Double($0)), hrValue: Double.random(in: 60...100)) }
        ]
        
        let exampleHRVData: [UUID: [HRVDataPoint]] = [
            UUID(): (0..<60).map { HRVDataPoint(timestamp: Date().addingTimeInterval(Double($0)), hrvValue: Double.random(in: 20...40)) },
            UUID(): (0..<60).map { HRVDataPoint(timestamp: Date().addingTimeInterval(Double($0)), hrvValue: Double.random(in: 20...40)) },
            UUID(): (0..<60).map { HRVDataPoint(timestamp: Date().addingTimeInterval(Double($0)), hrvValue: Double.random(in: 20...40)) }
        ]
        
        let exampleIBIData: [UUID: [Double]] = [
            UUID(): [0.85, 0.88, 0.87, 0.86, 0.89, 0.84],
            UUID(): [0.78, 0.77, 0.76, 0.75, 0.79, 0.74],
            UUID(): [0.92, 0.91, 0.93, 0.94, 0.95, 0.96]
        ]
        

        // Mock SensorDataProcessor to inject example data
        let mockSensorDataProcessor = SensorDataProcessor()
        mockSensorDataProcessor.hrArray = exampleHRData
        mockSensorDataProcessor.hrvArray = exampleHRVData
        mockSensorDataProcessor.ibiArray = exampleIBIData

        return DashboardComponent()
            .environment(mockSensorDataProcessor)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
