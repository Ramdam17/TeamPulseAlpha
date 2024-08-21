//
//  SensorBoxPlotView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/20/24.
//

import SwiftUI
import Charts

struct SensorBoxPlotView: View {
    let sensorID: UUID
    let stats: (min: Double, max: Double, median: Double, mean: Double)
    let color: Color
    let index: Int

    var body: some View {
        Chart {
            // Draw the line from min to max
            RuleMark(
                x: .value("Sensor", index),  // Using the index as a simple X-axis value
                yStart: .value("Min", stats.min),
                yEnd: .value("Max", stats.max)
            )
            .foregroundStyle(color)
            .lineStyle(StrokeStyle(lineWidth: 2))
            
            // Draw the median as a line
            LineMark(
                x: .value("Sensor", index),
                y: .value("Median", stats.median)
            )
            .foregroundStyle(color)
            .lineStyle(StrokeStyle(lineWidth: 2))
            
            // Draw the mean as a point
            PointMark(
                x: .value("Sensor", index),
                y: .value("Mean", stats.mean)
            )
            .symbolSize(100)
            .foregroundStyle(color)
        }
        .chartYScale(domain: 0...200) // Adjust the domain based on expected HR values
        .padding()
    }
}
