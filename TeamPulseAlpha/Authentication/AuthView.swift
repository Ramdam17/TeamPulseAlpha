//
//  AuthView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Spacer()
            
            Text("Welcome to TeamPulse")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.black)
                .padding(.bottom, 20)
            
            Image(systemName: "heart.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .foregroundColor(Color.yellow)
                .shadow(radius: 10)
                .padding(.bottom, 50)
            
            Button(action: {
                authManager.signInWithApple()
            }) {
                HStack {
                    Image(systemName: "applelogo")
                        .font(.title)
                    Text("Sign in with Apple")
                        .fontWeight(.semibold)
                        .font(.title2)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            if authManager.isAuthenticated {
                errorMessage = nil
            }
        }
        .onReceive(authManager.$isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                errorMessage = nil
            }
        }
        .onReceive(authManager.$errorMessage) { errorMessage in
            self.errorMessage = errorMessage
        }
    }
}
