//
//  HRVChartComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/20/24.
//

import SwiftUI
import Charts

struct HRVChartComponent: View {
    @EnvironmentObject var sensorDataProcessor: SensorDataProcessor
    
    var body: some View {
        Chart {
            ForEach(sensorDataProcessor.hrArray.keys.sorted(), id: \.self) { sensorID in
                if let hrvData = sensorDataProcessor.calculateHRV(sensorID: sensorID) {
                    ForEach(hrvData.suffix(60), id: \.timestamp) { dataPoint in
                        LineMark(
                            x: .value("Time", dataPoint.timestamp),
                            y: .value("HRV", dataPoint.hrvValue)
                        )
                        .foregroundStyle(by: .value("Sensor", sensorDataProcessor.getSensorColor(sensorID)))
                    }
                }
            }
        }
        .chartYScale(domain: 0...150) // Adjust domain based on expected HRV values
        .padding()
    }
}
