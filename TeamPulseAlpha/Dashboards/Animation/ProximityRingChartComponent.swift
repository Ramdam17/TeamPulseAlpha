//
//  ProximityRingChartComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/20/24.
//

import SwiftUI
import Charts

struct ProximityRingChartComponent: View {
    @EnvironmentObject var sensorDataProcessor: SensorDataProcessor
    
    var body: some View {
        RingChart {
            ForEach(sensorDataProcessor.proximityScores.keys.sorted(), id: \.self) { sensorID in
                RingMark(
                    value: sensorDataProcessor.proximityScores[sensorID] ?? 0
                )
                .foregroundStyle(by: .value("Sensor", sensorDataProcessor.getSensorColor(sensorID)))
            }
        }
        .padding()
    }
}
