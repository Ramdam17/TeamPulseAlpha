import SwiftUI
import Charts

struct LineChartHRComponent: View {

    @Environment(SensorDataProcessor.self) var sensorDataProcessor  // Listen to the sensor data processor
    let colors: [Color]  // Colors for each line

    var body: some View {
        VStack {
            Text("Last heart rate value: \(sensorDataProcessor.lastIHR)")

            Chart {
                // Iterate over each sensor ID and its corresponding HR data
                ForEach(Array(sensorDataProcessor.hrArray.keys.enumerated()), id: \.offset) { index, sensorID in
                    if let sensorData = sensorDataProcessor.hrArray[sensorID] {
                        // Iterate through each HRDataPoint to create a LineMark
                        ForEach(sensorData.indices, id: \.self) { pointIndex in
                            LineMark(
                                x: .value("Time", pointIndex),  // X value as index
                                y: .value("Heart Rate", sensorData[pointIndex].hrValue)  // Y value as HR value
                            )
                            .lineStyle(StrokeStyle(lineWidth: 2))
                            .foregroundStyle(colors[index % colors.count])
                        }
                    }
                }
            }
            .chartYScale(domain: 40...200)  // Example range for heart rate values
            .frame(height: 200)
            .padding()
        }
    }
}
