//
//  AuthenticationManager.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI
import AuthenticationServices

class AuthenticationManager: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?

    override init() {
        super.init()
        checkCredentialState()
    }

    func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func checkCredentialState() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        if let userID = UserDefaults.standard.string(forKey: "appleUserID") {
            appleIDProvider.getCredentialState(forUserID: userID) { (credentialState, error) in
                DispatchQueue.main.async {
                    switch credentialState {
                    case .authorized:
                        self.isAuthenticated = true
                    case .revoked, .notFound:
                        UserDefaults.standard.removeObject(forKey: "appleUserID")
                        self.isAuthenticated = false
                    default:
                        break
                    }
                }
            }
        } else {
            self.isAuthenticated = false
        }
    }
}

extension AuthenticationManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Authentication successful
            DispatchQueue.main.async {
                self.isAuthenticated = true
                let userID = appleIDCredential.user
                UserDefaults.standard.set(userID, forKey: "appleUserID")
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
        }
    }
}

extension AuthenticationManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first,
            let keyWindow = windowScene.windows.filter({ $0.isKeyWindow }).first else {
                return UIWindow()
        }
        return keyWindow
    }
}
