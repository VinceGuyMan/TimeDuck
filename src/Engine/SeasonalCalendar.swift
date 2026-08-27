// MARK: - TimeDuck · SeasonalCalendar.swift
// Lightweight, offline, deterministic date-aware seasonal companion reactions.
// Never deletes or locks user costumes — provides seasonal quips and automatic celebration hooks.

import Foundation

enum SeasonalEvent: String, Equatable {
    case none
    case spookySeason   // Late October: Halloween / Pumpkin season
    case holidaySeason  // Late December: Winter Holidays / Festive season
}

enum SeasonalCalendar {
    /// Determines the active seasonal event for a given calendar date (defaults to now).
    static func currentEvent(at date: Date = Date(), calendar: Calendar = Calendar.current) -> SeasonalEvent {
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        // Spooky Season: October 24 through November 1
        if (month == 10 && day >= 24) || (month == 11 && day == 1) {
            return .spookySeason
        }

        // Holiday Season: December 15 through January 2
        if (month == 12 && day >= 15) || (month == 1 && day <= 2) {
            return .holidaySeason
        }

        return .none
    }

    static func isSpooky(at date: Date = Date(), calendar: Calendar = Calendar.current) -> Bool {
        currentEvent(at: date, calendar: calendar) == .spookySeason
    }

    static func isHoliday(at date: Date = Date(), calendar: Calendar = Calendar.current) -> Bool {
        currentEvent(at: date, calendar: calendar) == .holidaySeason
    }

    /// Returns a seasonal greeting or quip if a holiday window is active.
    static func seasonalGreeting(at date: Date = Date(), calendar: Calendar = Calendar.current) -> String? {
        switch currentEvent(at: date, calendar: calendar) {
        case .spookySeason:
            let spookyLines = [
                "HAPPY HALLOWEEN!",
                "SPOOKY POND OPS.",
                "PUMPKIN DUCK ACTIVE.",
                "BEWARE OF BREAD GHOSTS."
            ]
            return spookyLines.randomElement()
        case .holidaySeason:
            let holidayLines = [
                "HAPPY HOLIDAYS!",
                "FESTIVE POND GREETINGS.",
                "WINTER WADDLE ACTIVE.",
                "STAY COZY, HUMAN."
            ]
            return holidayLines.randomElement()
        case .none:
            return nil
        }
    }
}
