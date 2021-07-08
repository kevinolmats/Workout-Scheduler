//
//  Date+RawRepresentable.swift
//  Workout Scheduler
//
//  Created by Kevin Olmats on 2021-07-07.
//

import Foundation

extension Date: RawRepresentable {
    public var rawValue: String {
        self.formatted(.iso8601.dateSeparator(.dash).timeSeparator(.colon))
    }
    
    public init?(rawValue: String) {
        guard let date = try? Date(rawValue, strategy: .iso8601.dateSeparator(.dash).timeSeparator(.colon)) else {
            return nil
        }
        
        self = date
    }
}
