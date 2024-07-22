//
//  MainMenuView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
        VStack {
            NavigationLink(destination: DeviceConnectionView()) {
                Text("Start New Session")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
            }
            NavigationLink(destination: SessionListView()) {
                Text("View Recorded Sessions")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
            }
            NavigationLink(destination: SettingsView()) {
                Text("Settings")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(10)
            }
        }
        .navigationBarTitle("Main Menu", displayMode: .inline)
    }
}
