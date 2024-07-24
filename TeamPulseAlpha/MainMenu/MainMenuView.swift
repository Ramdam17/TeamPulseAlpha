//
//  MainMenuView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("Main Menu")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.black)
                .padding(.bottom, 50)
            
            NavigationLink(destination: DeviceConnectionView()) {
                Text("Start New Session")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal)
            
            NavigationLink(destination: SessionListView()) {
                Text("View Recorded Sessions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal)
            
            NavigationLink(destination: SettingsView()) {
                Text("Settings")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}
