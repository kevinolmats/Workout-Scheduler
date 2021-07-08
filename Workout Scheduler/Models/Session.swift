//
//  Session.swift
//  Workout Scheduler
//
//  Created by Kevin Olmats on 2021-07-07.
//

import Foundation
import EventKit
import MapKit
import SwiftUI

final class Session: CustomDebugStringConvertible, Codable, Equatable, ObservableObject, Identifiable {
    static func == (lhs: Session, rhs: Session) -> Bool {
        lhs.id == rhs.id
        && lhs.startDate == rhs.startDate
        && lhs.duration == rhs.duration
        && lhs.type == rhs.type
        && lhs.blocks == rhs.blocks
    }
    
    init(id: UUID = UUID(), startDate: Date = Date.now, duration: TimeInterval = 3000, type: SessionType, blocks: [Block] = []) {
        self.id = id
        self.startDate = startDate
        self.duration = duration
        self.type = type
        self.blocks = blocks
    }
    
    let id: UUID
    @Published var startDate: Date = Date.now
    @Published var duration: TimeInterval = 3000
    @Published var type: SessionType
    @Published var blocks: [Block] = []
    
    private enum CodingKeys: String, CodingKey { case id, startDate, duration, type, blocks }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(duration, forKey: .duration)
        try container.encode(type, forKey: .type)
        try container.encode(blocks, forKey: .blocks)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        startDate = try values.decode(Date.self, forKey: .startDate)
        duration = try values.decode(TimeInterval.self, forKey: .duration)
        type = try values.decode(SessionType.self, forKey: .type)
        blocks = try values.decode([Block].self, forKey: .blocks)
    }
    
    var debugDescription: String {
        var str = "Session: \(type), \(startDate), \(duration / 60) min(s), \(blocks.count) block(s)\n"
        for block in blocks {
            str.append("\(block.debugDescription)\n")
        }
        return str
    }
    
    func populateBlocks(strength: Block? = nil, ignoring ignoredBlocks: [Block] = []) {
        var timeRemaining = self.duration
        
        for type in type.blocks {
            if type == .strength, let block = strength {
                print("Append: \(block.title), \(block.minutes) min(s)")
                blocks.append(block)
            } else if let block = type.blocks.filter({
                !ignoredBlocks.map(\.title).contains($0.title)
                && !self.blocks.map(\.title).contains($0.title)
            }).randomElement(),
                      let duration = block.possibleDurations.filter({
                          $0 <= timeRemaining
                                && (self.type == .cardio ? true : $0 <= .twenty)
                                && !(ignoredBlocks
                                        .first(where: { $0.title == block.title })
                                        .map(\.possibleDurations)?.contains($0) ?? false)
                      }).randomElement() {
                block.duration = duration
                timeRemaining -= block.duration
                blocks.append(block)
                print("Append: \(block.title), \(block.minutes) min(s), Time Remaining: \(timeRemaining)")
            } else if self.type != .cardio, let block = type.blocks.filter({
                !self.blocks.map(\.title).contains($0.title)
            }).randomElement(),
                      let duration = block.possibleDurations.filter({
                          $0 <= timeRemaining
                                && (self.type == .cardio ? true : $0 <= .twenty)
                      }).randomElement() {
                block.duration = duration
                print("Repeat: \(block.title), \(block.minutes) min(s)")
                timeRemaining -= block.duration
                blocks.append(block)
            } else {
                print("Ignored: \(type)")
            }
        }
        
        if !blocks.filter({ $0.duration == 0 }).isEmpty && timeRemaining == 0 {
            print("No time remaining - removing unused blocks")
            blocks.removeAll(where: { $0.duration == 0 })
            return
        }
        
        for block in blocks where block.type == .strength {
            block.duration = timeRemaining / Double(blocks.filter { $0.type == .strength }.count)
        }
        
        for block in blocks where block.type == .strength {
            timeRemaining -= block.duration
        }
        
        self.duration = self.duration - timeRemaining
        
    }
    
    func scheduleEvent(with mapItem: MKMapItem? = nil)  {
        @AppStorage("minutesToArriveEarly") var arriveEarly: Int = 10
        @AppStorage("bookingLegnth") var bookingLegnth: Int = 60
        
        let store = EKEventStore()
        let event = EKEvent(eventStore: store)
        let startDate = Calendar.current.date(byAdding: .minute, value: -arriveEarly, to: self.startDate) ?? self.startDate
        event.startDate = startDate
        event.endDate = Calendar.current.date(byAdding: .minute, value: bookingLegnth, to: self.startDate)
        event.title = "Workout: \(type.rawValue.capitalized)"
        
        if let mapItem = mapItem {
            let location = EKStructuredLocation(mapItem: mapItem)
            event.structuredLocation = location
        }
        
        event.calendar = store.defaultCalendarForNewEvents
        try? store.save(event, span: EKSpan.thisEvent, commit: true)
    }
}
