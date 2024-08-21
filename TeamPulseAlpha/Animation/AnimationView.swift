import SwiftUI

struct AnimationView: View {

    var body: some View {
        ScrollView {  // Wrap the entire content in a ScrollView
            VStack {
                // Animation Component placeholder (this will display the actual animation)
                AnimationComponent()
                    .frame(height: 300)
                
                // Bluetooth Connection Status Component
                BluetoothStatusComponent()
                    .padding()
                
                // Dashboard Component - showing charts and stats related to the sensor data
                DashboardComponent()
                    .padding()
                
                // Session Recording Management Component
                SessionRecordingComponent()
                    .padding(.top, 20)
            }
            .navigationBarTitle("Animation", displayMode: .inline)
        }
    }
}

// Sample usage of the AnimationView with actual UUIDs
struct AnimationView_Previews: PreviewProvider {
    static var previews: some View {
        // Example sensor UUIDs - replace with actual UUIDs from your app's data
        AnimationView()
    }
}
