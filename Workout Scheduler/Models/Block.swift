//
//  Block.swift
//  Workout Scheduler
//
//  Created by Kevin Olmats on 2021-07-07.
//

import Foundation

class Block: CustomDebugStringConvertible, Equatable, Codable {
    init(title: String, type: BlockType, duration: TimeInterval = 0, possibleDurations: [TimeInterval] = [], url: URL? = nil) {
        self.title = title
        self.type = type
        self.duration = duration
        self.possibleDurations = possibleDurations
        self.url = url
    }
    
    static func == (lhs: Block, rhs: Block) -> Bool {
        lhs.title == rhs.title
        && lhs.type == rhs.type
        && lhs.duration == rhs.duration
        && lhs.url == rhs.url
    }
    
    var title: String
    let type: BlockType
    
    var duration: TimeInterval
    var minutes: Double {
        return duration / 60
    }
    var possibleDurations: [TimeInterval]
    
    var url: URL? = nil
    var debugDescription: String {
        return "\(title) (\(minutes) min(s)) | \(type.rawValue) | \(url?.absoluteString ?? "No URL")"
    }
}
