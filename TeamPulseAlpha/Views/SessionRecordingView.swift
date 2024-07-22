//
//  SessionRecordingView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI

struct SessionRecordingView: View {
    var body: some View {
        VStack {
            Text("Recording Session...")
                .font(.largeTitle)
                .padding()
            // Add session recording logic and UI here
            Button(action: {
                // End recording logic here
            }) {
                Text("End Session")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .navigationBarTitle("Session Recording", displayMode: .inline)
    }
}
