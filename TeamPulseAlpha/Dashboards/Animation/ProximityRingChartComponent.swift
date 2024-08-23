//
//  ProximityRingChartComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/20/24.
//

import SwiftUI

struct ProximityRingChartComponent: View {

    var data: Double
    var color: Color

    var body: some View {
        VStack {
            Text("Proximity Score")
                .font(.headline)
                .padding()

            ProximityRingView(score: data, color: color)
        }
        .padding()
    }
}

struct ProximityRingView: View {
    var score: Double
    var color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(color)

            Circle()
                .trim(from: 0.0, to: CGFloat(score))
                .stroke(
                    style: StrokeStyle(
                        lineWidth: 20, lineCap: .round, lineJoin: .round)
                )
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeOut, value: score)

            Text(String(format: "%.0f%%", score * 100))
                .font(.headline)
                .foregroundColor(color)
        }
        .animation(.easeInOut(duration: 1.0), value: score)
        .frame(width: 150, height: 150)
    }
}

struct ProximityRingChartComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            // Preview with a 50% score
            ProximityRingChartComponent(
                data: 0.5,
                color:
                    Color(red: 1.0, green: 0.84, blue: 0.0)
            )
            .previewLayout(.sizeThatFits)
            .padding()

        }
    }
}
