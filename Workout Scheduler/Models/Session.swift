//
//  Session.swift
//  Workout Scheduler
//
//  Created by Kevin Olmats on 2021-07-07.
//

import Foundation

class Session: CustomDebugStringConvertible {
    init(startDate: Date = Date.now, duration: TimeInterval = 3000, type: SessionType, blocks: [Block] = []) {
        self.startDate = startDate
        self.duration = duration
        self.type = type
        self.blocks = blocks
    }
    
    var startDate: Date = Date.now
    var duration: TimeInterval = 3000
    var type: SessionType
    var blocks: [Block] = []
    
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
}
