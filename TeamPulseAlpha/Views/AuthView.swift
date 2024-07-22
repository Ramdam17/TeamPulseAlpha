//
//  AuthView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

struct AuthView: View {
    @Binding var isAuthenticated: Bool

    var body: some View {
        VStack {
            Text("Authentication")
                .font(.largeTitle)
                .padding()
            Button(action: {
                // Authentication logic here
                isAuthenticated = true
            }) {
                Text("Login with Apple ID")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
            }
        }
    }
}
