//
//  SessionList.swift
//  Workout Scheduler
//
//  Created by Kevin Olmats on 2021-07-07.
//

import SwiftUI

struct SessionList: View {
    @AppStorage("schedules") var schedules: [Schedule] = []
    @ObservedObject var schedule: Schedule
    let dismiss: DismissAction
    
    var body: some View {
        List {
            ForEach(schedule.sessions) { session in
                NavigationLink(destination: EmptyView()) {
                    VStack(alignment: .leading) {
                        Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.title3)
                            .bold()
                            .foregroundColor(rowTint(for: session.type))
                        Text("\(session.type.rawValue.capitalized), \(Int(session.duration / 60)) min.")
                            .font(.subheadline)
                    }
                }
            }
            .onDelete(perform: delete)
        }
        .navigationBarItems(trailing: doneButton)
    }
    
    func rowTint(for type: SessionType) -> Color {
        switch type {
        case .push:
            return .mint
        case .pull:
            return .green
        case .legs:
            return .indigo
        case .cardio:
            return .orange
        }
    }
    
    var doneButton: some View {
        Button {
            schedules.append(schedule)
            dismiss()
        } label: {
            Text("Done")
                .font(.headline)
        }
    }
    
    func delete(at offsets: IndexSet) {
        schedule.sessions.remove(atOffsets: offsets)
    }
}

//struct SessionList_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionList()
//    }
//}
