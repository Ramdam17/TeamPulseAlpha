//
//  DataAuthManagementComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/25/24.
//

import SwiftUI

/// A view component responsible for managing data and authentication settings.
struct DataAuthManagementComponent: View {
    @Environment(SessionManager.self) var sessionManager  // Accessing the session manager from the environment
    @Environment(AuthenticationManager.self) var authenticationManager  // Accessing the authentication manager from the environment
    
    @State private var showClearSessionsAlert = false  // State to show the confirmation alert for clearing sessions
    
    var body: some View {

        VStack(spacing: 20) {
            
            Text("Data & Authentication Management")
                .font(.title)
                .fontWeight(.bold)
                .fixedSize(horizontal: false, vertical: true)

                // Button to clear all sessions with confirmation
                Text("Clear All Sessions")
                    .padding()
                    .background(Color.white)
                    .foregroundColor(Color("CustomGrey"))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("CustomGrey"), lineWidth: 1)
                    )
                    .onTapGesture {
                        showClearSessionsAlert = true
                    }
                    .alert(isPresented: $showClearSessionsAlert) {
                        Alert(
                            title: Text("Clear All Sessions"),
                            message: Text("Are you sure you want to delete all recorded sessions? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                sessionManager.deleteAllSessions()
                            },
                            secondaryButton: .cancel()
                        )
                    }

                // Button to sign out
                Text("Sign Out")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .onTapGesture {
                        authenticationManager.signOut()
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding(.horizontal)

    }
}

struct DataAuthManagementComponent_Previews: PreviewProvider {
    static var previews: some View {
        DataAuthManagementComponent()
            .environment(AuthenticationManager())
            .environment(SessionManager())
    }
}
