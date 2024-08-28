//
//  SettingsView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {

        VStack(spacing: 40) {

            SensorSettingsComponent()

            DataAuthManagementComponent()

        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("CustomYellow"))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .previewDevice("iPad Pro (11-inch)")
    }
}
