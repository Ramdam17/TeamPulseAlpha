//
//  AnimationComponent.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import SwiftUI

/// A view that represents the animation component, including a placeholder for future animation work.
/// This component could be used to visualize data or display dynamic content within the app.
struct AnimationComponent: View {

    var body: some View {
        VStack {
            // Background Circle
            Circle()
                .stroke(lineWidth: 4)
                .frame(width: 200, height: 200)
                .foregroundColor(.blue)
                .opacity(0.5)  // Reduce opacity for a subtle background circle effect
        }
        .frame(height: 300)
    }
}

// Preview provider for SwiftUI previews, allowing for real-time design feedback.
struct AnimationComponent_Previews: PreviewProvider {
    static var previews: some View {
        AnimationComponent()
            .padding()
    }
}
