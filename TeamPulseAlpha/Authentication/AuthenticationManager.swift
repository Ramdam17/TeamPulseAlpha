//
//  AuthenticationManager.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 24/07/2024.
//

import SwiftUI
import AuthenticationServices

/// Manages the authentication process using Sign in with Apple.
class AuthenticationManager: NSObject, ObservableObject {
    /// Published property that indicates whether the user is authenticated.
    @Published var isAuthenticated = false

    /// Published property that stores any error messages during the authentication process.
    @Published var errorMessage: String?

    /// Initializes the authentication manager and checks the current credential state.
    override init() {
        super.init()
        checkCredentialState()
    }

    /// Initiates the Sign in with Apple process.
    func signInWithApple() {
        // Create a request for Apple ID authentication.
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email] // Request access to the user's full name and email.

        // Create an authorization controller with the request.
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self // Set the delegate to handle the response.
        authorizationController.presentationContextProvider = self // Provide the presentation context.
        authorizationController.performRequests() // Start the authentication process.
    }

    /// Checks the credential state to see if the user is already authenticated.
    private func checkCredentialState() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()

        // Retrieve the stored user ID from user defaults.
        if let userID = UserDefaults.standard.string(forKey: "appleUserID") {
            // Check the credential state for the stored user ID.
            appleIDProvider.getCredentialState(forUserID: userID) { (credentialState, error) in
                // Ensure UI updates occur on the main thread.
                DispatchQueue.main.async {
                    switch credentialState {
                    case .authorized:
                        // The user is still authorized, update the state accordingly.
                        self.isAuthenticated = true
                    case .revoked, .notFound:
                        // The credential is no longer valid, remove the stored user ID and update the state.
                        UserDefaults.standard.removeObject(forKey: "appleUserID")
                        self.isAuthenticated = false
                    default:
                        break
                    }
                }
            }
        } else {
            // No user ID stored, mark as not authenticated.
            self.isAuthenticated = false
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthenticationManager: ASAuthorizationControllerDelegate {
    /// Handles the successful completion of the authorization process.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // The authentication was successful, update the state and store the user ID.
            DispatchQueue.main.async {
                self.isAuthenticated = true
                let userID = appleIDCredential.user
                UserDefaults.standard.set(userID, forKey: "appleUserID")
            }
        }
    }

    /// Handles errors during the authorization process.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Update the error message if authentication fails.
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthenticationManager: ASAuthorizationControllerPresentationContextProviding {
    /// Provides the presentation context for the authorization controller.
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Find the key window in the current window scene.
        guard let windowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first,
            let keyWindow = windowScene.windows.filter({ $0.isKeyWindow }).first else {
                // Fallback to a default UIWindow if the key window cannot be found.
                return UIWindow()
        }
        return keyWindow
    }
}

