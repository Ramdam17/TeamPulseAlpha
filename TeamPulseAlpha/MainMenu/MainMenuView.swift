//
//  MainMenuView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

// MainMenuView is the primary view for the app's main menu.
// It provides navigation to different sections of the app, such as starting a new session,
// viewing recorded sessions, and accessing settings.
struct MainMenuView: View {
    
    @Environment(SensorDataProcessor.self) var sensorDataProcessor // Access the SensorDataProcessor from the environment
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            HeaderView(title: "Main Menu")
            
            MenuButtonView(title: "Start New Session", destination: DeviceConnectionView(), backgroundColor: .blue)

            MenuButtonView(title: "View Recorded Sessions", destination: SessionListView(), backgroundColor: .green)
            
            MenuButtonView(title: "Settings", destination: SettingsView(), backgroundColor: .gray)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

// HeaderView is a reusable view for displaying headers in the app.
struct HeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Color.black)
            .padding(.bottom, 50)
    }
}

// MenuButtonView is a reusable view for creating navigation buttons in the main menu.
// It takes a title, a destination view, and a background color as parameters.
struct MenuButtonView<Destination: View>: View {
    let title: String
    let destination: Destination
    let backgroundColor: Color
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal)
    }
}
