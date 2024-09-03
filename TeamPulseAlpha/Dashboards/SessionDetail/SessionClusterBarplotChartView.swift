//
//  SessionClusterBarplotChartView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/27/24.
//

import Charts
import SwiftUI

// Enum representing different bar colors
enum BarColor: String, CaseIterable {
    case blue = "Blue"
    case green = "Green"
    case red = "Red"
    case orange = "Orange"
    case yellow = "Yellow"

    // Color mapping for each case
    var color: Color {
        switch self {
        case .blue:
            return .blue
        case .green:
            return .green
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return Color("CustomYellow")  // Custom color defined in asset catalog
        }
    }

    // Description for each color
    var description: String {
        switch self {
        case .blue:
            return "With Blue"
        case .green:
            return "With Green"
        case .red:
            return "With Red"
        case .orange:
            return "In Soft"
        case .yellow:
            return "In Hard"
        }
    }
}

// Struct representing a single bar in the chart
struct ClusterBar: Identifiable {
    let id = UUID()  // Automatically generates a unique ID for each bar
    let category: String  // Main category (e.g., "Blue", "Green", "Red")
    let value: Double  // Value of the bar
    let subCategory: BarColor  // Subcategory color for the bar
}

struct SessionClusterBarplotChartView: View {
    let data: [Double]  // Array of data values for the bars
    let title: String  // Title to display above the chart
    let barValues: [String] = ["Blue Sensor", "Green Sensor", "Red Sensor"]  // Array of values for each bar to display

    var body: some View {
        VStack {
            Text(title)  // Chart title
                .font(.headline)
                .padding(.top, 5)

            // Creating an array of ClusterBar objects based on the provided data
            let clusterBar: [ClusterBar] = [
                ClusterBar(
                    category: "Blue", value: data[0], subCategory: .green),
                ClusterBar(category: "Blue", value: data[1], subCategory: .red),
                ClusterBar(
                    category: "Blue", value: data[3], subCategory: .orange),
                ClusterBar(
                    category: "Blue", value: data[4], subCategory: .yellow),

                ClusterBar(
                    category: "Green", value: data[0], subCategory: .blue),
                ClusterBar(
                    category: "Green", value: data[2], subCategory: .red),
                ClusterBar(
                    category: "Green", value: data[3], subCategory: .orange),
                ClusterBar(
                    category: "Green", value: data[4], subCategory: .yellow),

                ClusterBar(category: "Red", value: data[1], subCategory: .blue),
                ClusterBar(
                    category: "Red", value: data[2], subCategory: .green),
                ClusterBar(
                    category: "Red", value: data[3], subCategory: .orange),
                ClusterBar(
                    category: "Red", value: data[4], subCategory: .yellow),
            ]

            // Creating the bar chart
            Chart(clusterBar) { bar in
                BarMark(
                    x: .value("Cluster", bar.category),  // X-axis is the category
                    y: .value("Value", bar.value),  // Y-axis is the value
                    stacking: .standard  // Stack bars of the same category
                )
                .foregroundStyle(bar.subCategory.color)  // Color each bar according to its subcategory
                .annotation(position: .top) {
                    Text("\(bar.category) sensor")  // Display the value on top of the bar
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }
            .frame(height: 200)  // Set the height of the chart
            .chartYScale(domain: 0...1)

            // Legend explaining the colors
            HStack {
                ForEach(BarColor.allCases, id: \.self) { barColor in
                    if UIDevice.current.orientation.isLandscape {
                        HStack {
                            Rectangle()
                                .fill(barColor.color)
                                .frame(width: 20, height: 20)
                            Text(barColor.description)
                                .font(.footnote)
                        }
                        .padding(.horizontal, 5)
                    } else {
                        VStack {
                            Rectangle()
                                .fill(barColor.color)
                                .frame(width: 20, height: 20)
                            Text(barColor.description)
                                .font(.footnote)
                        }
                        .padding(.horizontal, 5)
                    }

                }
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct SessionClusterBarplotChartView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with sample data and values
        SessionClusterBarplotChartView(
            data: [0.05, 0.13, 0.08, 0.42, 0.31],
            title: "Cluster State Barplot"
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
