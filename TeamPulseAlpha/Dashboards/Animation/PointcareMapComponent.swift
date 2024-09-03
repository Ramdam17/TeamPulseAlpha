//
//  PointcareMapComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/22/24.
//

import Charts
import SwiftUI

/// A SwiftUI component that visualizes Poincaré maps for different sensors, representing HRV data.
struct PoincareMapComponent: View {

    let data: [String: [Double]]  // Dictionary holding HRV data for different sensors.
    let colors: [Color]  // List of colors to differentiate sensors.
    let names: [String] = ["Blue", "Green", "Red"]  // Names associated with each sensor.

    var body: some View {

        VStack(spacing: 20) {
            // Loop through each sensor's data and render its Poincaré map.
            ForEach(Array(data.keys.enumerated()), id: \.element) {
                index, sensorID in
                let name = names[index]
                if let ibiData = data[name], ibiData.count > 1 {
                    VStack {
                        Chart {
                            // Plot the IBI points on the chart
                            plotPointsWithHeart(
                                ibiData: ibiData,
                                color: colors[index % colors.count])

                            // If there's enough data, compute and plot the best-fit ellipsoid
                            if let ellipsoid = computeBestFitEllipsoid(
                                for: ibiData)
                            {
                                plotEllipsoid(
                                    ellipsoid: ellipsoid,
                                    color: colors[index % colors.count])
                            }
                        }
                        .chartLegend(.hidden)
                        .chartXAxis {
                            AxisMarks(position: .bottom) {
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel()
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) {
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel()
                            }
                        }
                        .chartXScale(domain: 0...4)  // Set the Y-axis range for heart rate values
                        .chartYScale(domain: 0...4)  // Set the Y-axis range for heart rate values
                    }
                } else {
                    Text("Not enough data for sensor \(index + 1)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }

    /// Function to plot the points on the Poincaré map, using heart symbols to represent each point.
    @ChartContentBuilder
    private func plotPointsWithHeart(ibiData: [Double], color: Color)
        -> some ChartContent
    {
        ForEach(1..<ibiData.count, id: \.self) { i in
            PointMark(
                x: .value("IBI (n)", ibiData[i - 1]),
                y: .value("IBI (n+1)", ibiData[i])
            )
            .symbol {
                Image(systemName: "heart.fill")
                    .fixedSize()
                    .scaleEffect(x: 0.3, y: 0.3)
                    .foregroundColor(color)
            }
            .symbolSize(30)
        }
    }

    /// Function to plot the best-fit ellipsoid on the Poincaré map.
    @ChartContentBuilder
    private func plotEllipsoid(
        ellipsoid: (
            centerX: Double, centerY: Double, width: Double, height: Double,
            angle: Double
        ), color: Color
    ) -> some ChartContent {
        PointMark(
            x: .value("CenterX", ellipsoid.centerX),
            y: .value("CenterY", ellipsoid.centerY)
        )
        .symbol {
            Circle()
                .scaleEffect(x: ellipsoid.width, y: ellipsoid.height)
                .rotationEffect(.degrees(ellipsoid.angle))
                .foregroundStyle(color.opacity(0.5))  // Use a semi-transparent color
        }
    }

    /// Function to compute the best-fit ellipsoid for a given set of IBI data points.
    private func computeBestFitEllipsoid(for ibiData: [Double]) -> (
        centerX: Double, centerY: Double, width: Double, height: Double,
        angle: Double
    )? {
        guard ibiData.count > 1 else { return nil }

        // Compute the mean of the points
        let meanX =
            ibiData[0..<ibiData.count - 1].reduce(0, +)
            / Double(ibiData.count - 1)
        let meanY =
            ibiData[1..<ibiData.count].reduce(0, +) / Double(ibiData.count - 1)

        // Compute covariance matrix
        var sxx = 0.0
        var syy = 0.0
        var sxy = 0.0
        for i in 1..<ibiData.count {
            let x = ibiData[i - 1] - meanX
            let y = ibiData[i] - meanY
            sxx += x * x
            syy += y * y
            sxy += x * y
        }
        sxx /= Double(ibiData.count - 1)
        syy /= Double(ibiData.count - 1)
        sxy /= Double(ibiData.count - 1)

        // Compute eigenvalues and eigenvectors of the covariance matrix
        let trace = sxx + syy
        let det = sxx * syy - sxy * sxy
        let lambda1 = trace / 2 + sqrt(trace * trace / 4 - det)
        let lambda2 = trace / 2 - sqrt(trace * trace / 4 - det)

        let angle = atan2(2 * sxy, sxx - syy) / 2

        let width = 2 * sqrt(lambda1)
        let height = 2 * sqrt(lambda2)

        return (
            centerX: meanX, centerY: meanY, width: width, height: height,
            angle: angle * 180 / .pi
        )  // Convert angle to degrees
    }
}

/// Preview provider for the `PoincareMapComponent`, showcasing the component with sample data.
struct PoincareMapComponent_Previews: PreviewProvider {
    static var previews: some View {
        // Example IBI data for preview purposes
        let exampleIBIData: [String: [Double]] = [
            "Blue": [0.2, 0.85, 0.9, 0.88, 0.87, 0.86, 0.89],
            "Green": [0.35, 0.78, 0.77, 0.76, 0.75, 0.79, 0.74],
            "Red": [0.15, 0.92, 0.91, 0.93, 0.94, 0.95, 0.96],
        ]

        PoincareMapComponent(
            data: exampleIBIData,
            colors: [.blue, .green, .red]
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
