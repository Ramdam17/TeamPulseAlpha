//
//  SettingsView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            Button(action: {
                // Sign out logic
                UserDefaults.standard.removeObject(forKey: "appleUserID")
                authManager.isAuthenticated = false
            }) {
                Text("Sign Out")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .navigationBarTitle("Settings", displayMode: .inline)
    }
}
