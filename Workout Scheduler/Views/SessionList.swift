//
//  SessionList.swift
//  Workout Scheduler
//
//  Created by Kevin Olmats on 2021-07-07.
//

import SwiftUI
import MapKit

class WrappedMapItem: ObservableObject {
    @Published var wrappedValue: MKMapItem? = nil
}

struct SessionList: View {
    @AppStorage("schedules") var schedules: [Schedule] = []
    @ObservedObject var schedule: Schedule
    let dismiss: DismissAction
    @State var editing = false
    @ObservedObject var mapItem: WrappedMapItem = WrappedMapItem()
    
    var body: some View {
        List {
            ForEach(schedule.sessions) { session in
                NavigationLink(destination: SessionDetail(session: session)) {
                    VStack(alignment: .leading) {
                        Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.title3)
                            .bold()
                            .foregroundColor(session.type.tint)
                        Text("\(session.type.rawValue.capitalized), \(Int(session.duration / 60)) min.")
                            .font(.subheadline)
                    }
                }
            }
            .onDelete(perform: delete)
        }
        .navigationBarItems(trailing: editing ? doneButton : nil)
    }
    
    var doneButton: some View {
        Button {
            schedules.append(schedule)
            schedule.scheduleEvents(with: mapItem.wrappedValue)
            dismiss()
        } label: {
            Text("Done")
                .font(.headline)
        }
    }
    
    func delete(at offsets: IndexSet) {
        schedule.sessions.remove(atOffsets: offsets)
        schedule.objectWillChange.send()
    }
}

//struct SessionList_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionList()
//    }
//}
