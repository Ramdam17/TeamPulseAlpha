//
//  MainMenuView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

/// MainMenuView is the primary view for the app's main menu.
/// It provides navigation to different sections of the app, such as starting a new session,
/// viewing recorded sessions, and accessing settings.
struct MainMenuView: View {
    
    @Environment(SensorDataProcessor.self) var sensorDataProcessor // Access the SensorDataProcessor from the environment
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Header for the main menu
            HeaderView(title: "Main Menu")
            
            // Navigation buttons for the main menu
            MenuButtonView(title: "Start New Session", destination: DeviceConnectionView(), backgroundColor: .blue)
            MenuButtonView(title: "View Recorded Sessions", destination: SessionListView(), backgroundColor: .green)
            MenuButtonView(title: "Settings", destination: SettingsView(), backgroundColor: .gray)
            
            Spacer()
        }
        .padding()
        .background(Color.white) // Set background color for the entire view
        .edgesIgnoringSafeArea(.all) // Extend the background to the edges of the screen
    }
}

/// HeaderView is a reusable view for displaying headers in the app.
struct HeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.largeTitle) // Large title font for the header
            .fontWeight(.bold) // Bold font weight
            .foregroundColor(Color.black) // Black color for the text
            .padding(.bottom, 50) // Space below the header text
    }
}

/// MenuButtonView is a reusable view for creating navigation buttons in the main menu.
/// It takes a title, a destination view, and a background color as parameters.
struct MenuButtonView<Destination: View>: View {
    let title: String
    let destination: Destination
    let backgroundColor: Color
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.title2) // Title font for the button
                .fontWeight(.bold) // Bold font weight
                .foregroundColor(.white) // White text color
                .padding() // Padding around the text
                .frame(maxWidth: .infinity) // Expand button to fill the available width
                .background(backgroundColor) // Background color for the button
                .cornerRadius(15) // Rounded corners for the button
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5) // Drop shadow for a 3D effect
        }
        .padding(.horizontal) // Horizontal padding around the button
    }
}

// Preview provider for MainMenuView
struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Embed in NavigationView for correct preview behavior
            MainMenuView()
                .environment(SensorDataProcessor()) // Inject a mock SensorDataProcessor for preview
        }
    }
}
