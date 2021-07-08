//
//  SessionScheduler.swift
//  Workout Scheduler
//
//  Created by Kevin Olmats on 2021-07-07.
//

import SwiftUI

struct SessionScheduler: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var schedule: Schedule
    @AppStorage("defaultTime") var defaultTime: Date = Date.now
    @AppStorage("schedules") var schedules: [Schedule] = []
    @State var nextSheet = false
    
    var body: some View {
        NavigationView {
            Form {
                ForEach($schedule.sessions) { $session in
                    DatePicker("\((schedule.sessions.firstIndex(of: session) ?? 0) + 1)", selection: $session.startDate)
                }
                .onDelete(perform: delete)
                
                Section {
                    Button {
                        let session = Session(type: .cardio)
                        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: defaultTime)
                        let startDate = Calendar.current.date(bySettingHour: components.hour ?? 5, minute: components.minute ?? 0, second: components.second ?? 0, of: Date.now)
                        session.startDate = startDate ?? Date.now
                        schedule.sessions.append(session)
                    } label: {
                        Label("New Session", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }

                }
            }
            .animation(.default, value: schedule.sessions)
            .navigationTitle("New Schedule")
            .navigationBarItems(leading: cancelButton, trailing: nextButton)
        }
    }
    
    var cancelButton: some View {
        Button("Cancel", role: .cancel) { dismiss() }
    }
    
    var nextButton: some View {
        Button {
            schedule.populateSessions(previousSchedule: schedules.last)
            nextSheet = true
        } label: {
            ZStack {
                Text("Next")
                    .font(.headline)
                NavigationLink("", destination: SessionList(schedule: schedule, dismiss: dismiss), isActive: $nextSheet)
                    .hidden()
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        schedule.sessions.remove(atOffsets: offsets)
    }
}

//struct SessionScheduler_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionScheduler()
//    }
//}
