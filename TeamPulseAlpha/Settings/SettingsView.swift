//
//  SettingsView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        
        GeometryReader {
            metrics in
            
            VStack(alignment: .center, spacing: 20) {
                
                SensorSettingsComponent()
                    .frame(width: metrics.size.width * 0.6, height: metrics.size.height * 0.5)

                DataAuthManagementComponent()
                    .frame(width: metrics.size.width * 0.6, height: metrics.size.height * 0.3)

            }
            .padding()
            .edgesIgnoringSafeArea(.all)
            .frame(width: metrics.size.width, height: metrics.size.height)
            .background(Color("CustomYellow"))
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .previewDevice("iPad Pro (11-inch)")
    }
}
