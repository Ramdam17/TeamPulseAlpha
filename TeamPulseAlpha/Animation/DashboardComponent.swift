//
//  DashboardComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import SwiftUI

struct DashboardComponent: View {
    var body: some View {
        VStack {
            Text("Dashboard")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Heart Rate")
                    Text("IBI")
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("120 BPM") // Placeholder
                    Text("500 ms") // Placeholder
                }
            }
        }
    }
}
