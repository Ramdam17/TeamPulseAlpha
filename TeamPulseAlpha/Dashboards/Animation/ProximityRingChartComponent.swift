//
//  ProximityRingChartComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/20/24.
//

import SwiftUI

/// A SwiftUI view that displays a proximity score in the form of a ring chart.
struct ProximityRingChartComponent: View {

    var data: Double  // The proximity score to display, ranging from 0.0 to 1.0.
    var color: Color  // The color of the ring chart.

    var body: some View {
        VStack {
            // Custom ring view displaying the proximity score
            ProximityRingView(score: data, color: color)
        }
        .padding()
    }
}

/// A custom view that displays a ring chart for the given proximity score.
struct ProximityRingView: View {
    var score: Double  // The score to be represented in the ring, from 0.0 to 1.0.
    var color: Color  // The color of the ring.

    var body: some View {
        ZStack {
            // Background circle to represent the inactive portion of the ring
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)  // Set opacity to make it look inactive
                .foregroundColor(color)

            // Foreground circle representing the active portion based on the score
            Circle()
                .trim(from: 0.0, to: CGFloat(score))  // Trim the circle based on the score
                .stroke(
                    style: StrokeStyle(
                        lineWidth: 2, lineCap: .round, lineJoin: .round
                    )
                )
                .foregroundColor(color)  // Set the color of the active portion
                .rotationEffect(Angle(degrees: 270.0))  // Rotate to start from the top
                .animation(.easeOut, value: score)  // Smooth animation when the score changes

            // Display the score as a percentage in the center of the ring
            Text(String(format: "%.0f%%", score * 100))
                .font(.headline)
                .foregroundColor(color)
        }
        .animation(.easeInOut(duration: 1.0), value: score)  // Smooth transition for the ring
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // Set the size of the ring view
    }
}

/// Preview provider for the `ProximityRingChartComponent`, showcasing different score values.
struct ProximityRingChartComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            // iPhone 15 Pro Preview
            ProximityRingChartComponent(
                data: 0.5,
                color: Color(red: 1.0, green: 0.84, blue: 0.0)  // Yellow color
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
            .previewDisplayName("iPhone 15 Pro")

            // iPad Pro 11-inch Preview
            ProximityRingChartComponent(
                data: 0.5,
                color: Color(red: 1.0, green: 0.84, blue: 0.0)  // Yellow color
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDevice(
                PreviewDevice(
                    rawValue: "iPad Pro (11-inch) (6th generation)")
            )
            .previewDisplayName("iPad Pro 11-inch")

            // iPad Pro 13-inch Preview
            ProximityRingChartComponent(
                data: 0.5,
                color: Color(red: 1.0, green: 0.84, blue: 0.0)  // Yellow color
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDevice(
                PreviewDevice(
                    rawValue: "iPad Pro (12.9-inch) (6th generation)")
            )
            .previewDisplayName("iPad Pro 13-inch")
        }
    }
}
