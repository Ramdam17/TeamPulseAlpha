//
//  PointcareMapComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/22/24.
//

import SwiftUI
import Charts

struct PoincareMapComponent: View {

    let data: [UUID: [Double]]
    let colors: [Color]  // Colors for each sensor

    var body: some View {
        VStack {
            Text("Poincaré Maps")
                .font(.headline)
                .padding(.bottom, 10)

            VStack(spacing: 20) {
                ForEach(Array(data.keys.enumerated()), id: \.element) { index, sensorID in
                    if let ibiData = data[sensorID], ibiData.count > 1 {
                        VStack {
                            Text("Sensor \(index + 1)")
                                .font(.subheadline)

                            Chart {
                                // Plot the points with heart symbol
                                plotPointsWithHeart(ibiData: ibiData, color: colors[index % colors.count])
                                
                                // Compute and plot the ellipsoid if there's enough data
                                if let ellipsoid = computeBestFitEllipsoid(for: ibiData) {
                                    plotEllipsoid(ellipsoid: ellipsoid, color: colors[index % colors.count])
                                }
                            }
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
                            .frame(width: 200, height: 200)  // Adjust the size as needed
                        }
                    } else {
                        Text("Not enough data for sensor \(index + 1)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
    }

    // Function to plot the points with heart symbol
    @ChartContentBuilder
    private func plotPointsWithHeart(ibiData: [Double], color: Color) -> some ChartContent {
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

    // Function to plot the ellipsoid
    @ChartContentBuilder
    private func plotEllipsoid(ellipsoid: (centerX: Double, centerY: Double, width: Double, height: Double, angle: Double), color: Color) -> some ChartContent {
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
    private func computeBestFitEllipsoid(for ibiData: [Double]) -> (centerX: Double, centerY: Double, width: Double, height: Double, angle: Double)? {
        guard ibiData.count > 1 else { return nil }

        // Compute the mean of the points
        let meanX = ibiData[0..<ibiData.count - 1].reduce(0, +) / Double(ibiData.count - 1)
        let meanY = ibiData[1..<ibiData.count].reduce(0, +) / Double(ibiData.count - 1)

        // Compute covariance matrix
        var sxx = 0.0, syy = 0.0, sxy = 0.0
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

        return (centerX: meanX, centerY: meanY, width: width, height: height, angle: angle * 180 / .pi)  // Convert angle to degrees
    }
}

struct PoincareMapComponent_Previews: PreviewProvider {
    static var previews: some View {
        // Example IBI data for preview purposes
        let exampleIBIData: [UUID: [Double]] = [
            UUID(): [0.2, 0.85, 0.9, 0.88, 0.87, 0.86, 0.89],
            UUID(): [0.35, 0.78, 0.77, 0.76, 0.75, 0.79, 0.74],
            UUID(): [0.15, 0.92, 0.91, 0.93, 0.94, 0.95, 0.96]
        ]

        PoincareMapComponent(
            data: exampleIBIData,
            colors: [.blue, .green, .red]
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
