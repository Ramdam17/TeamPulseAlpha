//
//  SettingsView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        
        VStack {

            HStack { Spacer() }

            Spacer()
            SensorSettingsComponent()
                .frame(
                    width: UIDevice.current.orientation.isLandscape
                        ? UIScreen.main.bounds.width * 0.5
                        : UIScreen.main.bounds.width * 0.8,
                    height: UIDevice.current.orientation.isLandscape
                        ? UIScreen.main.bounds.height * 0.4
                        : UIScreen.main.bounds.height * 0.4)

            Spacer()
            DataAuthManagementComponent()
                .frame(
                    width: UIDevice.current.orientation.isLandscape
                        ? UIScreen.main.bounds.width * 0.5
                        : UIScreen.main.bounds.width * 0.8,
                    height: UIDevice.current.orientation.isLandscape
                        ? UIScreen.main.bounds.height * 0.3
                        : UIScreen.main.bounds.height * 0.3)

            Spacer()
        }
        .padding()
        .background(Color("CustomYellow"))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(SessionManager())
            .environment(AuthenticationManager())
    }
}
