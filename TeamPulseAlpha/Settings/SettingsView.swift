//
//  SettingsView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

// This view represents the settings screen of the TeamPulseAlpha app, where users can sign out of their account.
struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager // Accessing the authentication manager to handle sign out logic

    var body: some View {
        VStack {
            // Title of the settings screen
            Text("Settings")
                .font(.largeTitle)
                .padding()
            
            // Button to sign out the user
            Button(action: handleSignOut) {
                Text("Sign Out")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding() // Added padding around the button for better spacing
        }
        .navigationBarTitle("Settings", displayMode: .inline)
    }
    
    // Function that handles the sign out process
    private func handleSignOut() {
        // Remove the stored Apple user ID to effectively sign out
        UserDefaults.standard.removeObject(forKey: "appleUserID")
        
        // Update the authentication state in the AuthenticationManager
        authManager.isAuthenticated = false
        
        // Optional: Add haptic feedback for a better user experience
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// Preview provider for SwiftUI previews, allowing for real-time design feedback
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthenticationManager()) // Provide a mock environment object for preview
    }
}
