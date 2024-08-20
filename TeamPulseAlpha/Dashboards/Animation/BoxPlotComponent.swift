//
//  BoxPlotComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/20/24.
//

import SwiftUI
import Charts

struct BoxPlotComponent: View {
    @EnvironmentObject var sensorDataProcessor: SensorDataProcessor
    
    var body: some View {
        Chart {
            ForEach(sensorDataProcessor.statisticsArray.keys.sorted(), id: \.self) { sensorID in
                BoxPlotMark(
                    min: .value("Min", sensorDataProcessor.statisticsArray[sensorID]?.min ?? 0),
                    median: .value("Median", sensorDataProcessor.statisticsArray[sensorID]?.median ?? 0),
                    max: .value("Max", sensorDataProcessor.statisticsArray[sensorID]?.max ?? 0)
                )
                .foregroundStyle(by: .value("Sensor", sensorDataProcessor.getSensorColor(sensorID)))
            }
        }
        .padding()
    }
}
