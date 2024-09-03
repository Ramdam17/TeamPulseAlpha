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

    @Environment(SensorDataProcessor.self) var sensorDataProcessor  // Access the SensorDataProcessor from the environment

    var body: some View {
        VStack {
            HStack {
                Spacer()
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)  // Adjusted size for the gear icon
                        .foregroundColor(.black)
                        .padding(20)
                }
            }
            Spacer()

            // Navigation buttons for the main menu
            VStack(spacing: 80) {
                MenuButtonView(
                    title: "Start New Session",
                    destination: DeviceConnectionView(),
                    backgroundColor: .black)

                MenuButtonView(
                    title: "Review Sessions",
                    destination: SessionListView(),
                    backgroundColor: .gray)
            }
            .padding(.horizontal)

            Spacer()
        }
        .background(Color("CustomYellow"))  // Set background color for the entire view
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
                .font(UIDevice.current.orientation.isLandscape ? .largeTitle : .title)  // Title font for the button
                .fontWeight(.bold)  // Bold font weight
                .foregroundColor(.white)  // White text color
                .padding()  // Padding around the text
                .frame(maxWidth: .infinity, maxHeight: .infinity)  // Expand button to fill the available width
                .background(backgroundColor)  // Background color for the button
                .cornerRadius(15)  // Rounded corners for the button
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)  // Drop shadow for a 3D effect
        }
        .frame(
            width: UIDevice.current.orientation.isLandscape ? UIScreen.main.bounds.width * 0.3 : UIScreen.main.bounds.width * 0.8,  // Set the button width to 1/4 of the screen width
            height: 100  // Adjusted height for the button
        )
        .padding(.horizontal)  // Horizontal padding around the button
    }
}

// Preview provider for MainMenuView
struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // iPhone 15 Pro Preview
            MainMenuView()
                .environment(SensorDataProcessor())  // Inject a mock SensorDataProcessor for preview
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
                .previewDisplayName("iPhone 15 Pro")

            // iPad Pro 11-inch Preview
            MainMenuView()
                .environment(SensorDataProcessor())  // Inject a mock SensorDataProcessor for preview
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (11-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 11-inch")

            // iPad Pro 13-inch Preview
            MainMenuView()
                .environment(SensorDataProcessor())  // Inject a mock SensorDataProcessor for preview
                .previewDevice(
                    PreviewDevice(
                        rawValue: "iPad Pro (12.9-inch) (6th generation)")
                )
                .previewDisplayName("iPad Pro 13-inch")
        }
    }
}
