//
//  ScheduleTests.swift
//  Workout SchedulerTests
//
//  Created by Kevin Olmats on 2021-07-07.
//

import XCTest
@testable import Workout_Scheduler

class ScheduleTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPopulateSessions() {
        print("=== SESSION A ==========")
        let sessionA = Session(type: .push)
        sessionA.populateBlocks(strength: Block(title: "Push", type: .strength))
        print(sessionA)
        
        print("=== SESSION B ==========")
        let sessionB = Session(type: .pull)
        sessionB.populateBlocks(strength: Block(title: "Pull", type: .strength), ignoring: sessionA.blocks)
        print(sessionB)
        
        let previousSchedule = Schedule()
        previousSchedule.sessions = [sessionA, sessionB]
        
        print("=== SCHEDULE ==========")
        let sessionC = Session(type: .push)
        let sessionD = Session(type: .push)
        let sessionE = Session(type: .push)
        
        let schedule = Schedule()
        schedule.sessions = [sessionC, sessionD, sessionE]
        schedule.populateSessions(previousSchedule: previousSchedule)
        
        for session in schedule.sessions {
            print("===")
            print(session)
        }
        
        var expectedTypes = [SessionType.legs, SessionType.cardio]
        XCTAssertTrue(expectedTypes.contains(sessionC.type), "Session set to unexpected type: \(sessionC.type). Expected legs or cardio.")
        expectedTypes.removeAll(where: { $0 == sessionC.type })
        XCTAssertTrue(expectedTypes.contains(sessionD.type), "Session set to unexpected type: \(sessionD.type). Expected legs or cardio.")
        XCTAssertNotEqual(sessionC.type, sessionD.type, "Sessions did not have unique types")
        XCTAssertNotEqual(sessionD.type, sessionE.type, "Sessions did not have unique types")
        XCTAssertNotEqual(sessionC.type, sessionE.type, "Sessions did not have unique types")
    }
    
    func testCodable() {
        let schedule = Schedule()
        schedule.sessions = [Session(type: .push)]
        schedule.populateSessions()

        let encoded = schedule.rawValue
        print(encoded)
        let decoded = Schedule(rawValue: encoded)
        
        XCTAssertEqual(schedule.id, decoded?.id, "Unexpected decoded value: \(String(describing: decoded?.id))")
        XCTAssertEqual(schedule.startDate, decoded?.startDate, "Unexpected decoded value: \(String(describing: decoded?.startDate))")
        XCTAssertEqual(schedule.sessions, decoded?.sessions, "Unexpected decoded value: \(String(describing: decoded?.sessions))")
    }

}
