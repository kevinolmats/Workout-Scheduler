//
//  ContentView.swift
//  Workout Scheduler
//
//  Created by Kevin Olmats on 2021-07-07.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("schedules") var schedules: [Schedule] = []
    @State var newSchedule: Schedule? = nil

    let session = "session"
    
    var body: some View {
        NavigationView {
            List {
                ForEach(schedules) { schedule in
                    VStack {
                        Text("\(schedule.startDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.headline)
                        Text("^[\(schedule.sessions.count) \(session)](inflect: true)")
                    }
                }
                .onDelete(perform: delete)
            }
            .animation(.default, value: schedules)
            .navigationBarItems(trailing: addButton)
            .navigationTitle("Schedules")
            .sheet(item: $newSchedule) { schedule in SessionScheduler(schedule: schedule) }
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
