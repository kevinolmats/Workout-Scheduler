//
//  Schedule.swift
//  Workout Scheduler
//
//  Created by Kevin Olmats on 2021-07-07.
//

import Foundation
import MapKit

final class Schedule: Codable, RawRepresentable, Identifiable, Equatable, ObservableObject {
    init(id: UUID = UUID(), startDate: Date = Date.now, sessions: [Session] = []) {
        self.id = id
        self.startDate = startDate
        self.sessions = sessions
    }
    
    let id: UUID
    var startDate: Date
    @Published var sessions: [Session] = []
    
    var allBlocks: [Block] {
        return sessions.flatMap(\.blocks)
    }
    
    func populateSessions(previousSchedule: Schedule? = nil) {
        var priorityTypes = SessionType.allCases.filter { !(previousSchedule?.sessions.map(\.type) ?? []).contains($0) }.shuffled()
        let lastSession = previousSchedule?.sessions.last
        
        for (i, session) in sessions.enumerated() {
            if let type = priorityTypes.popLast() {
                session.type = type
            } else if let type = SessionType.allCases.filter({
                switch i {
                case 0:
                    guard let lastSession = lastSession else { fallthrough }
                    return $0 != lastSession.type
                default:
                    return sessions.indices.contains(i - 1) ?
                    $0 != sessions[i - 1].type : true
                }
            }).randomElement() {
                session.type = type
            }
            
            switch i {
            case 0:
                guard let lastSession = lastSession else { fallthrough }
                session.populateBlocks(strength: session.type.block, ignoring: session.type == .cardio ? [] : lastSession.blocks)
            default:
                session.populateBlocks(strength: session.type.block, ignoring: session.type == .cardio ? [] : allBlocks)
            }
        }
    }
    
    func scheduleEvents(with mapItem: MKMapItem? = nil) {
        for session in sessions {
            session.scheduleEvent(with: mapItem)
        }
    }
    
    private enum CodingKeys: String, CodingKey { case id, startDate, sessions }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(sessions, forKey: .sessions)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        startDate = try values.decode(Date.self, forKey: .startDate)
        sessions = try values.decode([Session].self, forKey: .sessions)
    }
    
    public var rawValue: String {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("Error encoding: \(error)")
            return ""
        }
    }
    
    public convenience init?(rawValue: String) {
        let decoder = JSONDecoder()
        do {
            let data = rawValue.data(using: .utf8)
            guard let data = data else { return nil }
            let schedule = try decoder.decode(Schedule.self, from: data)
            self.init(id: schedule.id, startDate: schedule.startDate, sessions: schedule.sessions)
        } catch {
            print("Error decoding: \(error)")
            return nil
        }
    }
}
