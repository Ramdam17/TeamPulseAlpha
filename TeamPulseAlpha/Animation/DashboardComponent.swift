//
//  DashboardComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import SwiftUI
import Charts

struct DashboardComponent: View {
    @EnvironmentObject var sensorDataProcessor: SensorDataProcessor

    var body: some View {
        VStack {
            Text("Dashboard")
                .font(.headline)

            // Example data access
            LineChartComponent(
                data: sensorDataProcessor.getInstantaneousHRData(),
                colors: [.blue, .green, .red]
            )

            // HRV Chart
            LineChartComponent(
                data: sensorDataProcessor.getHRVData(),
                colors: [.blue, .green, .red]
            )

            // Box Plot
            BoxPlotComponent(data: sensorDataProcessor.calculateStatisticsData())

            // Proximity Ring Chart
            ProximityRingChartComponent(proximityScore: sensorDataProcessor.calculateProximityScore())
        }
        .padding()
    }
}
