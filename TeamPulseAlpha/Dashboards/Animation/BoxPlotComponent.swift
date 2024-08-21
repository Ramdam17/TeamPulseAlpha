//
//  BoxPlotComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/20/24.
//

import SwiftUI
import Charts

struct BoxPlotComponent: View {
    @Environment var sensorDataProcessor: SensorDataProcessor
    
    let data: [UUID: [Double]]  // Data for each sensor
    let colors: [Color]         // Colors for each line
    
    var body: some View {
        VStack {
            ForEach(Array(data.keys.enumerated()), id: \.element) { index, sensorID in
                if let stats = sensorDataProcessor.calculateStatistics(sensorID: sensorID) {
                    SensorBoxPlotView(
                        sensorID: sensorID,
                        stats: stats,
                        color: colors[index % colors.count],
                        index: index
                    )
                }
            }
        }
        .padding()
    }
}
