//
//  SessionScheduler.swift
//  Workout Scheduler
//
//  Created by Kevin Olmats on 2021-07-07.
//

import SwiftUI
import MapKit

struct SessionScheduler: View {
    enum LocationState {
        case none, fetching, fetched, error
    }
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var schedule: Schedule
    @AppStorage("defaultTime") var defaultTime: Date = Date.now
    @AppStorage("defaultDuration") var defaultDuration: TimeInterval = 3000
    @AppStorage("schedules") var schedules: [Schedule] = []
    @AppStorage("searchLocation") var searchLocation: String = "Shane Homes YMCA"
    @State var nextSheet = false
    @StateObject var mapItem: WrappedMapItem = WrappedMapItem()
    @State var locationState: LocationState = .none
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            view
            
            if locationState != .none {
                location
                    .zIndex(1)
            }

        }
        .animation(.default, value: locationState)
        .task(getMapItem)
    }
    
    var view: some View {
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
                        session.duration = defaultDuration
                        schedule.sessions.append(session)
                    } label: {
                        Label("New Session", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .imageScale(.large)
                    }

                }
            }
            .animation(.default, value: schedule.sessions)
            .navigationTitle("New Schedule")
            .navigationBarItems(leading: cancelButton, trailing: nextButton)
        }
    }
    
    var location: some View {
        HStack {
            switch locationState {
            case .none, .fetching:
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(.trailing, 2)
                Text("Fetching Location...")
            case .fetched:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Fetched \(mapItem.wrappedValue?.name ?? "")")
                    .lineLimit(1)
                    .truncationMode(.tail)
            case .error:
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                Text("No Location Found")
            }
        }
        .font(.headline)
        .padding()
        .background {
            Capsule()
                .foregroundStyle(.white)
        }
        .padding()
        .transition(.move(edge: .leading))
        .animation(.default, value: locationState)
        .onChange(of: locationState) { newValue in
            if newValue == .fetched {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.locationState = .none
                }
            }
        }
        .onTapGesture {
            guard locationState == .error else { return }
            locationState = .none
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
                NavigationLink("", destination: SessionList(schedule: schedule, dismiss: dismiss, editing: true, mapItem: mapItem), isActive: $nextSheet)
                    .hidden()
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        schedule.sessions.remove(atOffsets: offsets)
    }
    
    func getMapItem() async {
        self.locationState = .fetching
        let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(51.15686259), longitude: CLLocationDegrees(-114.23151813))
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchLocation
        request.region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 200000, longitudinalMeters: 200000)
        
        let search = MKLocalSearch(request: request)
        let response = try? await search.start()
        guard let location = response?.mapItems.first else {
            self.locationState = .error
            return
        }
        sleep(1)
        DispatchQueue.main.sync {
            self.mapItem.wrappedValue = location
            self.locationState = .fetched
        }
    }
}

struct SessionScheduler_Previews: PreviewProvider {
    static var previews: some View {
        let schedule = Schedule()

        return SessionScheduler(schedule: schedule, locationState: .fetched)
    }
}
