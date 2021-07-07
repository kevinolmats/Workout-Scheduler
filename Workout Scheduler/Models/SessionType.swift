//
//  SessionType.swift
//  Workout Scheduler
//
//  Created by Kevin Olmats on 2021-07-07.
//

import Foundation

enum SessionType: String, CaseIterable {
    case push, pull, legs, cardio
    
    var blocks: [BlockType] {
        switch self {
        case .push, .pull, .legs: return [.cardio, .strength, .core]
        case .cardio: return [.cardio, .cardio, .cardio, .core]
        }
    }
    
    var block: Block? {
        switch self {
        case .push: return Block(title: "Push", type: .strength)
        case .pull: return Block(title: "Pull", type: .strength)
        case .legs: return Block(title: "Legs", type: .strength)
        case .cardio: return nil
        }
    }
}
