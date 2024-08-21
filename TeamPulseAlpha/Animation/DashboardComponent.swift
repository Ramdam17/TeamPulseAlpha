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

    // Access the SensorDataProcessor from the environment to use the sensor data in the view.
    @Environment(SensorDataProcessor.self) var sensorDataProcessor
    @Environment(BluetoothManager.self) var bluetoothManager

    var body: some View {
        VStack {
            // Display the title of the dashboard.
            Text("Dashboard")
                .font(.headline) // Set the font style for the title
            
            // Display the last recorded heart rate value.
            Text("Last heart rate value: \(sensorDataProcessor.lastIHR.description)")

            // Placeholder for the line chart displaying instantaneous heart rate.
            // Uncomment and configure this section when the LineChartHRComponent is available.
            
            LineChartHRComponent(
                colors: [.blue, .green, .red]
            )

            // Placeholder for the line chart displaying heart rate variability (HRV).
            // Uncomment and configure this section when the LineChartHRVComponent is available.
            /*
            LineChartHRVComponent(
                colors: [.blue, .green, .red]
            )
            */

            // Placeholder for the box plot displaying HR data.
            // Uncomment and configure this section when the BoxPlotComponent is available.
            /*
            BoxPlotComponent(
                data: sensorDataProcessor.getInstantaneousHRData(), // Assuming it returns [UUID: [Double]]
                colors: [.blue, .green, .red]
            )
            */

            // Placeholder for the proximity ring chart displaying sensor proximity.
            // Uncomment and configure this section when the ProximityRingChartComponent is available.
            /*
            ProximityRingChartComponent()
            */
        }
        .onChange(of: bluetoothManager.hasNewValues) { oldValue, newValue in
            if (oldValue == false && newValue == true) {
                let valuesToUnpack = bluetoothManager.getLatestValues()
                sensorDataProcessor.updateHRData(
                    sensorID: valuesToUnpack.uuid,
                    hr: valuesToUnpack.hr,
                    ibiArray: valuesToUnpack.ibis
                )
            }
        }
        .padding() // Add padding around the entire VStack for better spacing.
    }
}
