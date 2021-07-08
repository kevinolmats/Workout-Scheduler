//
//  ContentView.swift
//  Workout Scheduler
//
//  Created by Kevin Olmats on 2021-07-07.
//

import SwiftUI
import EventKit

struct ContentView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("schedules") var schedules: [Schedule] = []
    @State var newSchedule: Schedule? = nil
    @State var showSettingsView = false
    
    let session = "session"
    
    var body: some View {
        NavigationView {
            Group {
                if schedules.isEmpty {
                    Text("No Schedules")
                        .font(.title)
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(schedules) { schedule in
                            NavigationLink(destination: SessionList(schedule: schedule, dismiss: dismiss)) {
                                VStack {
                                    Text("\(schedule.startDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.headline)
                                    Text("^[\(schedule.sessions.count) \(session)](inflect: true)")
                                }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    .animation(.default, value: schedules)
                }
            }
            .navigationBarItems(leading: settingsButton, trailing: addButton)
            .navigationTitle("Schedules")
            .sheet(item: $newSchedule) { schedule in SessionScheduler(schedule: schedule) }
            .sheet(isPresented: $showSettingsView) { SettingsView() }
            .onAppear {
                EKEventStore().requestAccess(to: .event) { granted, error in
                    // Handle the response to the request.
                }
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        schedules.remove(atOffsets: offsets)
    }
    
    var addButton: some View {
        Button {
            newSchedule = Schedule()
        } label: {
            Label("Add", systemImage: "plus")
        }
    }
    
    var settingsButton: some View {
        Button {
            showSettingsView = true
        } label: {
            Label("Settings", systemImage: "gearshape.fill")
                .labelStyle(.iconOnly)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
