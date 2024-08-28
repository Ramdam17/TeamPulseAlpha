//
//  SessionListView.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 23/07/2024.
//

import CoreData
import SwiftUI

extension Date {
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM yyyy 'at' HH'h'mm"
        formatter.locale = Locale(identifier: "en_US") // Set to your preferred locale
        return formatter.string(from: self)
    }
}

extension SessionEntity {
    /// Computes the duration of the session in minutes and seconds.
    func durationString() -> String {
        guard let startTime = startTime, let endTime = endTime else {
            return "Unknown"
        }

        let duration = endTime.timeIntervalSince(startTime)
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60

        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct SessionListView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(
        entity: SessionEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \SessionEntity.startTime, ascending: false)
        ]
    )
    var sessions: FetchedResults<SessionEntity>

    @State private var filter: FilterOption = .allTime

    enum FilterOption: String, CaseIterable {
        case today, thisWeek, thisMonth, thisYear, allTime

        var title: String {
            switch self {
            case .today: return "Today"
            case .thisWeek: return "This Week"
            case .thisMonth: return "This Month"
            case .thisYear: return "This Year"
            case .allTime: return "All Time"
            }
        }
    }

    init() {
        UIScrollView.appearance().backgroundColor = .clear
    }

    var body: some View {

        VStack {
            // Navigation icon on the top right

            HStack {

                Spacer()

                VStack {

                    // Filter options

                    HStack(alignment: .center) {

                        Spacer()

                        ForEach(FilterOption.allCases, id: \.self) { option in
                            Button(action: {
                                filter = option
                            }) {
                                Text(option.title)
                                    .font(.headline)
                                    .padding()
                                    .background(
                                        filter == option
                                            ? Color("CustomYellow")
                                            : Color.white
                                    )
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                                    .shadow(
                                        color: Color.black.opacity(0.2),
                                        radius: 5,
                                        x: 0, y: 3)
                            }
                            .padding(.horizontal, 4)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    .shadow(
                        color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)

                    // Session list

                    List {
                        ForEach(filteredSessions()) { session in
                            NavigationLink(
                                destination: SessionDetailView(sessionID: session)
                            ) {
                                Text("\(session.startTime?.formattedString() ?? "Date unknown") - Duration: \(session.durationString())")
                                    .padding()
                                    .background(Color("CustomGrey"))
                                    .cornerRadius(10)
                                    .shadow(
                                        color: Color.black.opacity(0.2),
                                        radius: 5,
                                        x: 0, y: 3)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    deleteSession(session)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(20)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .shadow(
                        color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3
                    )
                    .listStyle(PlainListStyle())

                    Spacer()
                }
                .frame(width: 800)

                Spacer()
            }
            .padding()
        }
        .background(Color("CustomYellow"))

    }

    // Filtering logic based on selected filter option
    private func filteredSessions() -> [SessionEntity] {
        let calendar = Calendar.current
        let now = Date()

        return sessions.filter { session in
            guard let startTime = session.startTime else { return false }

            switch filter {
            case .today:
                return calendar.isDateInToday(startTime)
            case .thisWeek:
                return calendar.isDate(
                    startTime, equalTo: now, toGranularity: .weekOfYear)
            case .thisMonth:
                return calendar.isDate(
                    startTime, equalTo: now, toGranularity: .month)
            case .thisYear:
                return calendar.isDate(
                    startTime, equalTo: now, toGranularity: .year)
            case .allTime:
                return true
            }
        }
    }

    // Deleting a session
    private func deleteSession(_ session: SessionEntity) {
        context.delete(session)
        do {
            try context.save()
        } catch {
            print("Failed to delete session: \(error)")
        }
    }
}

struct SessionListView_Previews: PreviewProvider {
    static var previews: some View {
        SessionListView()
            .environment(\.managedObjectContext, CoreDataStack.shared.context)
    }
}
