//
//  Schedule.swift
//  Workout Scheduler
//
//  Created by Kevin Olmats on 2021-07-07.
//

import Foundation

class Schedule {
    init(startDate: Date = Date.now, sessions: [Session] = []) {
        self.startDate = startDate
        self.sessions = sessions
    }
    
    let startDate: Date
    var sessions: [Session] = []
    
    var allBlocks: [Block] {
        return sessions.flatMap(\.blocks)
    }
    
    func populateSessions(previousSchedule: Schedule?) {
        var priorityTypes = SessionType.allCases.filter { (previousSchedule?.sessions.map(\.type) ?? []).contains($0) }.shuffled()
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
}
