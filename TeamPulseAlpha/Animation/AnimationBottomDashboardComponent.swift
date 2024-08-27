//
//  DashboardComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import Charts
import SwiftUI

/// A SwiftUI view that displays the dashboard, including various charts and statistics related to sensor data.
struct AnimationBottomDashboardComponent: View {

    @Environment(SensorDataProcessor.self) var sensorDataProcessor  // Listen to the sensor data processor

    var body: some View {
        GeometryReader { metrics in
            HStack(spacing: 20) {
                // Line chart showing HR data from the sensors.
                LineChartHRComponent(
                    data: sensorDataProcessor.getHRData(),
                    colors: [.blue, .green, .red]
                )
                .frame(width: metrics.size.width * 0.30, height: .infinity)
                
                Spacer()

                // Line chart showing HRV data from the sensors.
                LineChartHRVComponent(
                    data: sensorDataProcessor.getHRVData(),
                    colors: [.blue, .green, .red]
                )
                .frame(width: metrics.size.width * 0.30, height: .infinity)
                
                Spacer()

                // Box plot showing statistical distribution of HR data.
                BoxPlotComponent(
                    data: sensorDataProcessor.getStatistics(),
                    colors: [.blue, .green, .red]
                )
                .frame(width: metrics.size.width * 0.30, height: .infinity)
            }
            .padding()
        }
    }
}

struct AnimationBottomDashboardComponent_Previews: PreviewProvider {
    static var previews: some View {
        // Example data for preview purposes
        let exampleHRData: [String: [HRDataPoint]] = [
            "Blue": (0..<60).map {
                HRDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrValue: Double.random(in: 60...100)
                )
            },
            "Green": (0..<60).map {
                HRDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrValue: Double.random(in: 60...100)
                )
            },
            "Red": (0..<60).map {
                HRDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrValue: Double.random(in: 60...100)
                )
            },
        ]

        let exampleHRVData: [String: [HRVDataPoint]] = [
            "Blue": (0..<60).map {
                HRVDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrvValue: Double.random(in: 0...1)
                )
            },
            "Green": (0..<60).map {
                HRVDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrvValue: Double.random(in: 0...1)
                )
            },
            "Red": (0..<60).map {
                HRVDataPoint(
                    timestamp: Date().addingTimeInterval(Double($0) * 60),
                    hrvValue: Double.random(in: 0...1)
                )
            },
        ]

        let exampleIBIData: [String: [Double]] = [
            "Blue": [0.85, 0.88, 0.87, 0.86, 0.89, 0.84],
            "Green": [0.78, 0.77, 0.76, 0.75, 0.79, 0.74],
            "Red": [0.92, 0.91, 0.93, 0.94, 0.95, 0.96],
        ]

        // Mock SensorDataProcessor to inject example data
        let mockSensorDataProcessor = SensorDataProcessor()
        mockSensorDataProcessor.setHRArray(hrData: exampleHRData)
        mockSensorDataProcessor.setHRVArray(hrvData: exampleHRVData)
        mockSensorDataProcessor.setIBIArray(ibiData: exampleIBIData)

        return AnimationBottomDashboardComponent()
            .environment(mockSensorDataProcessor)
            .previewLayout(.sizeThatFits)  // Ensures the preview is sized appropriately
            .padding()
    }
}
