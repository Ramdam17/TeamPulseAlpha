//
//  AuthView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 24/07/2024.
//

import SwiftUI
import AuthenticationServices

/// A view that handles the authentication process for TeamPulse using Apple Sign-In.
struct AuthView: View {
    /// The authentication manager responsible for handling sign-in and credential checks.
    @Environment(AuthenticationManager.self) var authManager

    /// Stores any error messages that occur during the authentication process.
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Spacer() // Adds flexible space at the top to vertically center the content.

            // Displays the title of the app.
            Text("Welcome to TeamPulse")
                .font(.largeTitle) // Sets the font size to large title.
                .fontWeight(.bold) // Makes the text bold.
                .foregroundColor(Color.black) // Sets the text color to black.
                .padding(.bottom, 20) // Adds padding below the text.

            // Displays a heart icon, representing the app's theme, centered on the screen.
            Image(systemName: "heart.circle")
                .resizable() // Allows the image to be resized.
                .aspectRatio(contentMode: .fit) // Maintains the aspect ratio within the frame.
                .frame(width: 150, height: 150) // Sets the width and height of the image.
                .foregroundColor(Color.yellow) // Colors the image yellow.
                .shadow(radius: 10) // Adds a shadow to the image for a 3D effect.
                .padding(.bottom, 50) // Adds padding below the image.

            // Button that initiates the Sign in with Apple process.
            Button(action: {
                authManager.signInWithApple() // Initiates the Apple Sign-In process.
            }) {
                // Layout and style of the Sign in with Apple button.
                HStack {
                    Image(systemName: "applelogo") // Apple logo icon.
                        .font(.title) // Sets the icon size to title.
                    Text("Sign in with Apple") // Button label.
                        .fontWeight(.semibold) // Makes the text semibold.
                        .font(.title2) // Sets the text size to title2.
                }
                .frame(maxWidth: .infinity) // Expands the button to fill the available width.
                .padding() // Adds padding inside the button.
                .background(Color.black) // Sets the button background color to black.
                .foregroundColor(.white) // Sets the text and icon color to white.
                .cornerRadius(10) // Rounds the button corners.
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5) // Adds a subtle shadow below the button.
            }
            .padding(.horizontal) // Adds horizontal padding around the button.

            // If there's an error message, display it in red text below the button.
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red) // Sets the error message color to red.
                    .padding() // Adds padding around the error message.
            }

            Spacer() // Adds flexible space at the bottom to vertically center the content.
        }
        .padding() // Adds padding around the entire view.
        .background(Color.white) // Sets the background color of the view to white.
        .edgesIgnoringSafeArea(.all) // Extends the view to the edges of the screen.
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
        AuthView()
            .environment(AuthenticationManager()) // Provide a mock environment object for preview.
    }
}
