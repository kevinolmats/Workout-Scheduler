//
//  BlockType.swift
//  Workout Scheduler
//
//  Created by Kevin Olmats on 2021-07-07.
//

import Foundation

enum BlockType: String {
    case strength, cardio, core
    
    var blocks: [Block] {
        switch self {
        case .strength:
            return [
                Block(title: "Push", type: .strength),
                Block(title: "Pull", type: .strength),
                Block(title: "Legs", type: .strength)
            ]
        case .cardio:
            return [
                Block(title: "Treadmill", type: .cardio, possibleDurations: [.ten, .twenty, .thirty, .fourtyFive]),
                Block(title: "Cycling", type: .cardio, possibleDurations: [.ten, .twenty, .thirty, .fourtyFive]),
                Block(title: "Rowing", type: .cardio, possibleDurations: [.ten, .twenty, .thirty])
            ]
        case .core:
            return [
                Block(title: "Core", type: .core, possibleDurations: [.five, .ten]),
            ]
        }
    }
}

