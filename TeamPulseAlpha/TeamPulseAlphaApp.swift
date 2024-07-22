//
//  TeamPulseAlphaApp.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

@main
struct TeamPulseAlphaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataStack.shared.context)
        }
    }
}

struct ContentView: View {
    @State private var isAuthenticated = false

    var body: some View {
        NavigationView {
            if isAuthenticated {
                MainMenuView()
            } else {
                AuthView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}
