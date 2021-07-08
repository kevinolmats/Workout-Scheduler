//
//  SettingsView.swift
//  WorkoutScheduler
//
//  Created by Kevin Olmats on 2021-07-08.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("minutesToArriveEarly") var arriveEarly: Int = 10
    @AppStorage("searchLocation") var searchLocation: String = "Shane Homes YMCA"
    @AppStorage("defaultDuration") var defaultDuration: TimeInterval = 3000
    @AppStorage("bookingLegnth") var bookingLegnth: Int = 60

    var body: some View {
        NavigationView {
            Form {
                Stepper("Arrive \(arriveEarly) minutes early", value: $arriveEarly)
                Stepper("Workout Legnth: \(Int(defaultDuration / 60)) min.", value: $defaultDuration, in: 0...3600, step: 300)
                Stepper("Booking Legnth: \(bookingLegnth) min.", value: $bookingLegnth, in: 0...120, step: 5)

                Section {
                    TextField("Location", text: $searchLocation)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
