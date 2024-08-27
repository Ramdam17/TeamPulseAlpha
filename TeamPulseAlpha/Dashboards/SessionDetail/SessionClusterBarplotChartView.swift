//
//  SessionClusterBarplotChartView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/27/24.
//

import Charts
import SwiftUI

enum BarColor: String, CaseIterable {
    case blue = "Blue"
    case green = "Green"
    case red = "Red"
    case pink = "Pink"
    case yellow = "Yellow"

    var color: Color {
        switch self {
        case .blue:
            return .blue
        case .green:
            return .green
        case .red:
            return .red
        case .pink:
            return .pink
        case .yellow:
            return Color("CustomYellow")
        }
    }
}

struct ClusterBar: Identifiable {
    let id = UUID()  // Automatically generates a unique ID
    let category: String
    let value: Double
    let subCategory: BarColor
}

struct SessionClusterBarplotChartView: View {
    let data: [Double]
    @State var clusterBar: [ClusterBar] = []

    var body: some View {
        VStack {
            Text("Cluster State Barplot")
                .font(.headline)
                .padding(.top)

            Chart(clusterBar) { bar in
                BarMark(
                    x: .value("Cluster", bar.category),
                    y: .value("Value", bar.value),
                    stacking: .standard
                )
                .foregroundStyle(bar.subCategory.color)

            }
            .chartLegend(.hidden)
            .frame(height: 300)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .onAppear {
            clusterBar = [
                ClusterBar(category: "Blue", value: 0.0, subCategory: .blue),
                ClusterBar(
                    category: "Blue", value: data[0], subCategory: .green),
                ClusterBar(category: "Blue", value: data[1], subCategory: .red),
                ClusterBar(
                    category: "Blue", value: data[3], subCategory: .pink),
                ClusterBar(
                    category: "Blue", value: data[4], subCategory: .yellow),

                ClusterBar(
                    category: "Green", value: data[0], subCategory: .blue),
                ClusterBar(category: "Green", value: 0.0, subCategory: .green),
                ClusterBar(
                    category: "Green", value: data[2], subCategory: .red),
                ClusterBar(
                    category: "Green", value: data[3], subCategory: .pink),
                ClusterBar(
                    category: "Green", value: data[4], subCategory: .yellow),

                ClusterBar(category: "Red", value: data[1], subCategory: .blue),
                ClusterBar(
                    category: "Red", value: data[2], subCategory: .green),
                ClusterBar(category: "Red", value: 0.0, subCategory: .red),
                ClusterBar(category: "Red", value: data[3], subCategory: .pink),
                ClusterBar(
                    category: "Red", value: data[4], subCategory: .yellow),

            ]
        }
    }
}

struct SessionClusterBarplotChartView_Previews: PreviewProvider {
    static var previews: some View {
        SessionClusterBarplotChartView(data: [0.05, 0.13, 0.08, 0.42, 0.31])
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
