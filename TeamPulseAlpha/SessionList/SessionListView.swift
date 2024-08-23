//
//  SessionListView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import SwiftUI
import CoreData

/// A view that displays a list of recorded sessions.
struct SessionListView: View {
    @FetchRequest(
        entity: SessionEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SessionEntity.timestamp, ascending: false)]
    ) var sessions: FetchedResults<SessionEntity>  // FetchRequest to retrieve recorded sessions from Core Data

    @Environment(\.managedObjectContext) private var viewContext  // Access the Core Data context from the environment

    var body: some View {
        VStack {
            // Title for the session list
            Text("Recorded Sessions")
                .font(.largeTitle)
                .padding()

            // List to display recorded sessions
            List {
                if sessions.isEmpty {
                    // Show a message if no sessions are available
                    Text("No recorded sessions available.")
                        .foregroundColor(.gray)
                } else {
                    // Iterate through fetched sessions and display each session
                    ForEach(sessions) { session in
                        NavigationLink(destination: SessionDetailView()) {
                            HStack {
                                Text(session.timestamp ?? Date(), formatter: dateFormatter)
                                    .font(.headline)  // Display the session's timestamp
                                
                            }
                        }
                    }
                    .onDelete(perform: deleteSessions)  // Enable swipe-to-delete functionality
                }
            }
        }
        .navigationBarTitle("Session List", displayMode: .inline)
        .navigationBarItems(trailing: EditButton())  // Add an edit button to enable deleting sessions
    }

    /// Deletes selected sessions from the Core Data store.
    /// - Parameter offsets: The indices of the sessions to delete.
    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            let sessionToDelete = sessions[index]
            viewContext.delete(sessionToDelete)  // Remove the session from Core Data
        }

        do {
            try viewContext.save()  // Save the changes to the context
        } catch {
            print("Failed to delete sessions: \(error.localizedDescription)")
        }
    }
}

/// DateFormatter to format the session timestamps.
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

// Preview provider for SwiftUI previews, allowing for real-time design feedback.
struct SessionListView_Previews: PreviewProvider {
    static var previews: some View {
        SessionListView()
            
    }
}
