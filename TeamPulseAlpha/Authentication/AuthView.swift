//
//  AuthView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 24/07/2024.
//

import AuthenticationServices
import SwiftUI

import AuthenticationServices
import SwiftUI

/// A view that handles the authentication process for TeamPulse using Apple Sign-In.
struct AuthView: View {
    /// The authentication manager responsible for handling sign-in and credential checks.
    @Environment(AuthenticationManager.self) var authManager

    /// Stores any error messages that occur during the authentication process.
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Spacer()  // Adds flexible space at the top to vertically center the content.

            // Displays a heart icon, representing the app's theme, centered on the screen.
            Image(systemName: "heart.circle")
                .resizable()  // Allows the image to be resized.
                .aspectRatio(contentMode: .fit)  // Maintains the aspect ratio within the frame.
                .frame(width: 100, height: 100)  // Adjusted size for a shorter logo.
                .foregroundColor(.white)  // Sets the heart icon color to white.
                .padding(.bottom, 80)  // Adds padding below the image.

            // Displays the title of the app in three lines.
            VStack(spacing: -5) {
                Text("Team Pulse Alpha")
            }
            .font(.custom("MarkerFelt-Wide", size: 72))  // Sets a dynamic handwritten font.
            .fontWeight(.bold)  // Makes the text bold.
            .foregroundColor(.white)  // Sets the text color to white.
            .multilineTextAlignment(.center)  // Aligns text to the center.
            .padding(.bottom, 100)  // Adds padding below the text.


            // Button that initiates the Sign in with Apple process.
            Button(action: {
                authManager.signInWithApple()  // Initiates the Apple Sign-In process.
            }) {
                // Layout and style of the Sign in with Apple button.
                HStack {
                    Image(systemName: "applelogo")  // Apple logo icon.
                        .font(.title)  // Sets the icon size to title.
                    Text("Sign in with Apple")  // Button label.
                        .fontWeight(.semibold)  // Makes the text semibold.
                        .font(.title2)  // Sets the text size to title2.
                }
                .frame(width: UIScreen.main.bounds.width / 4)  // Sets the button width to 1/4 of the screen width.
                .padding()  // Adds padding inside the button.
                .background(Color.black)  // Sets the button background color to black.
                .foregroundColor(.white)  // Sets the text and icon color to white.
                .cornerRadius(10)  // Rounds the button corners.
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)  // Adds a subtle shadow below the button.
            }
            
            Spacer()

            // If there's an error message, display it in red text below the button.
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)  // Sets the error message color to red.
                    .padding()  // Adds padding around the error message.
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // Ensures the VStack takes up the full screen
        .padding()  // Adds padding around the entire view.
        .background(Color("CustomYellow"))  // Sets the background color of the view to yellow.
        .ignoresSafeArea()  // Ensures the background color covers the entire screen.
        .onAppear {
            // Clears the error message if the user is already authenticated when the view appears.
            if authManager.isAuthenticated {
                errorMessage = nil
            }
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
            // Clears the error message if authentication succeeds.
            if isAuthenticated {
                errorMessage = nil
            }
        }
        .onChange(of: authManager.errorMessage) { _, errorMessage in
            // Updates the error message if authentication fails.
            self.errorMessage = errorMessage
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // iPhone 15 Pro Preview
            AuthView()
                .environment(AuthenticationManager())  // Provide a mock environment object for preview.
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
                .previewDisplayName("iPhone 15 Pro")

            // iPad Pro 11-inch Preview
            AuthView()
                .environment(AuthenticationManager())  // Provide a mock environment object for preview.
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (11-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 11-inch")

            // iPad Pro 13-inch Preview
            AuthView()
                .environment(AuthenticationManager())  // Provide a mock environment object for preview.
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (12.9-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 13-inch")
        }
    }
}
