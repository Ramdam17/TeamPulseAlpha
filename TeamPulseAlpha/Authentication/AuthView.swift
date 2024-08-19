import SwiftUI
import AuthenticationServices

/// A view that handles the authentication process for TeamPulse using Apple Sign-In.
struct AuthView: View {
    /// The authentication manager responsible for handling sign-in and credential checks.
    @EnvironmentObject var authManager: AuthenticationManager

    /// Stores any error messages that occur during the authentication process.
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Spacer() // Adds space at the top to vertically center the content.

            // Displays the title of the app.
            Text("Welcome to TeamPulse")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.black)
                .padding(.bottom, 20)

            // Displays a heart icon to represent the theme of the app.
            Image(systemName: "heart.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .foregroundColor(Color.yellow)
                .shadow(radius: 10)
                .padding(.bottom, 50)

            // Button that initiates the Sign in with Apple process.
            Button(action: {
                // Call the function to start the Apple Sign-In process.
                authManager.signInWithApple()
            }) {
                HStack {
                    Image(systemName: "applelogo")
                        .font(.title)
                    Text("Sign in with Apple")
                        .fontWeight(.semibold)
                        .font(.title2)
                }
                .frame(maxWidth: .infinity) // Makes the button stretch across the screen.
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal)

            // If there's an error message, display it in red text.
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer() // Adds space at the bottom to vertically center the content.
        }
        .padding()
        .background(Color.white) // Sets the background color of the view.
        .edgesIgnoringSafeArea(.all) // Extends the view to the edges of the screen.
        .onAppear {
            // Clears the error message if the user is already authenticated when the view appears.
            if authManager.isAuthenticated {
                errorMessage = nil
            }
        }
        .onReceive(authManager.$isAuthenticated) { isAuthenticated in
            // Clears the error message if authentication succeeds.
            if isAuthenticated {
                errorMessage = nil
            }
        }
        .onReceive(authManager.$errorMessage) { errorMessage in
            // Updates the error message if authentication fails.
            self.errorMessage = errorMessage
        }
    }
}
