//
//  ReminderTests.swift
//  Next-fire-date logic + review-due copy for the daily reminder.
//

import XCTest

final class ReminderTests: XCTestCase {
    private let cal = Calendar.current

    private func at(_ hour: Int, _ minute: Int = 0, day: Int = 15) -> Date {
        cal.date(from: DateComponents(year: 2026, month: 6, day: day, hour: hour, minute: minute))!
    }

    func testSchedulesTodayWhenTimeAheadAndNotPracticed() {
        let now = at(10)   // 10:00, reminder at 19:00
        let fire = ReminderScheduler.nextFireDate(now: now, hour: 19, minute: 0,
                                                  practicedToday: false, calendar: cal)
        XCTAssertEqual(cal.component(.day, from: fire), 15)
        XCTAssertEqual(cal.component(.hour, from: fire), 19)
    }

    func testSchedulesTomorrowWhenAlreadyPracticed() {
        let now = at(10)
        let fire = ReminderScheduler.nextFireDate(now: now, hour: 19, minute: 0,
                                                  practicedToday: true, calendar: cal)
        XCTAssertEqual(cal.component(.day, from: fire), 16)
        XCTAssertEqual(cal.component(.hour, from: fire), 19)
    }

    func testSchedulesTomorrowWhenTimeHasPassed() {
        let now = at(20)   // 20:00, already past the 19:00 reminder
        let fire = ReminderScheduler.nextFireDate(now: now, hour: 19, minute: 0,
                                                  practicedToday: false, calendar: cal)
        XCTAssertEqual(cal.component(.day, from: fire), 16)
    }

    // MARK: - Message tiers (review-due framing)

    func testReviewDueIsThePrimaryNudge() {
        let m = ReminderScheduler.message(due: 3, skillsLearned: 9, daysAway: 0)
        XCTAssertEqual(m.title, "Time for a quick review")
        XCTAssertTrue(m.body.contains("3 skills are due"))
        XCTAssertFalse(m.body.lowercased().contains("streak"))   // no streak framing
    }

    func testReviewDueSingularGrammar() {
        let m = ReminderScheduler.message(due: 1, skillsLearned: 5, daysAway: 1)
        XCTAssertTrue(m.body.contains("1 skill is due"))
    }

    func testStartMessageWhenNothingLearned() {
        let m = ReminderScheduler.message(due: 0, skillsLearned: 0, daysAway: nil)
        XCTAssertEqual(m.title, "Pick up the guitar")
    }

    func testNothingDueButLearnedInvitesNewSkill() {
        let m = ReminderScheduler.message(due: 0, skillsLearned: 6, daysAway: 1)
        XCTAssertEqual(m.title, "Ready for more?")
    }

    func testLapsedWithDueEscalatesToOverdue() {
        let m = ReminderScheduler.message(due: 4, skillsLearned: 9, daysAway: 10)
        XCTAssertEqual(m.title, "Your skills are slipping")
        XCTAssertTrue(m.body.contains("overdue"))
    }

    func testLapsedWithNothingDueKeepsSkillsSharp() {
        let m = ReminderScheduler.message(due: 0, skillsLearned: 6, daysAway: 10)
        XCTAssertEqual(m.title, "Keep your skills sharp")
    }
}
