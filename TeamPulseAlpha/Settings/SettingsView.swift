//
//  SettingsView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

/// The `SettingsView` displays settings options for the user, including the ability to sign out.
struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager // Access the authentication manager to manage the sign-out process

    var body: some View {
        VStack {
            // Title of the settings screen
            Text("Settings")
                .font(.largeTitle) // Set the font size to large for the title
                .padding() // Add padding around the title for spacing
            
            // Button to sign out the user from their account
            Button(action: handleSignOut) {
                Text("Sign Out")
                    .foregroundColor(.white) // Set text color to white
                    .padding() // Add padding inside the button for a larger tappable area
                    .background(Color.red) // Set background color of the button to red
                    .cornerRadius(10) // Make the button corners rounded with a radius of 10
            }
            .padding() // Add padding around the button for better spacing within the VStack
        }
        .navigationBarTitle("Settings", displayMode: .inline) // Set the navigation bar title and inline display mode
    }
    
    /// Handles the sign-out process by removing stored credentials and updating the authentication state.
    private func handleSignOut() {
        // Remove the stored Apple user ID from UserDefaults, effectively signing out the user
        UserDefaults.standard.removeObject(forKey: "appleUserID")
        
        // Update the authentication state to reflect that the user is no longer authenticated
        authManager.isAuthenticated = false
        
        // Provide haptic feedback to enhance the user experience during sign-out
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

/// SwiftUI Preview provider for the `SettingsView`.
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a mock AuthenticationManager for the preview
        SettingsView()
            .environmentObject(AuthenticationManager())
    }
}
