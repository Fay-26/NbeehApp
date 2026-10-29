//
//  UserProgress.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//

import SwiftUI
import Combine

enum DailyMission: String, Codable {
    case selectiveAttention
    case sustainedAttention

    var title: String {
        switch self {
        case .selectiveAttention:
            return "تحدي الانتباه السمعي"
        case .sustainedAttention:
            return "تحدي الانتباه المستمر"
        }
    }

    var description: String {
        switch self {
        case .selectiveAttention:
            return "انتبه لصوت العصفور واضغط عندما تسمعه."
        case .sustainedAttention:
            return "استمع إلى قصة سارة وأكمل هدف خطواتك."
        }
    }
}

@MainActor
final class UserProgress: ObservableObject {

    static let shared = UserProgress()

    @Published var currentLevel: Int {
        didSet {
            let level = max(1, currentLevel)

            if currentLevel != level {
                currentLevel = level
                return
            }

            UserDefaults.standard.set(level, forKey: "userLevel")
            updateStepGoalForLevel()
        }
    }

    @Published var totalPoints: Int {
        didSet {
            let points = max(0, totalPoints)

            if totalPoints != points {
                totalPoints = points
                return
            }

            UserDefaults.standard.set(points, forKey: "userPoints")
        }
    }

    @Published var currentStreak: Int {
        didSet {
            let streak = max(0, currentStreak)

            if currentStreak != streak {
                currentStreak = streak
                return
            }

            UserDefaults.standard.set(streak, forKey: "userStreak")
        }
    }

    @Published private(set) var dailyStepGoal: Int = 1000

    @Published private(set) var dailyMission: DailyMission =
        .selectiveAttention

    private let defaults = UserDefaults.standard

    private let missionDateKey = "nbeehDailyMissionDate"
    private let missionKey = "nbeehDailyMission"

    private let lastCompletionDateKey = "nbeehLastCompletionDate"
    private let rewardedDatesKey = "nbeehRewardedDates"

    private init() {
        let savedLevel = defaults.integer(forKey: "userLevel")
        let savedPoints = defaults.integer(forKey: "userPoints")
        let savedStreak = defaults.integer(forKey: "userStreak")

        currentLevel = max(1, savedLevel == 0 ? 1 : savedLevel)
        totalPoints = max(0, savedPoints)
        currentStreak = max(0, savedStreak)

        dailyStepGoal =
            1000 + (max(1, savedLevel == 0 ? 1 : savedLevel) - 1) * 100

        refreshDailyMission()
    }

    // MARK: - Daily Mission

    func refreshDailyMission() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let savedDate = defaults.object(
            forKey: missionDateKey
        ) as? Date,
           calendar.isDate(savedDate, inSameDayAs: today),
           let savedName = defaults.string(forKey: missionKey),
           let savedMission = DailyMission(rawValue: savedName) {

            dailyMission = savedMission
            return
        }

        let newMission: DailyMission =
            Bool.random()
            ? .selectiveAttention
            : .sustainedAttention

        dailyMission = newMission

        defaults.set(newMission.rawValue, forKey: missionKey)
        defaults.set(today, forKey: missionDateKey)
    }

    // MARK: - Step Goal

    private func updateStepGoalForLevel() {
        dailyStepGoal = 1000 + (max(1, currentLevel) - 1) * 100
    }

    func refreshDailyStepGoal() {
        updateStepGoalForLevel()
    }

    // MARK: - Points and Level

    func updateLevel(_ level: Int) {
        currentLevel = max(1, level)
    }

    func updateStreak(_ streak: Int) {
        currentStreak = max(0, streak)
    }

    func addPoints(_ points: Int) {
        guard points > 0 else { return }
        totalPoints += points
    }

    // MARK: - Daily Completion

    /// Awards the daily reward once per local calendar day.
    /// Returns false if today's reward has already been claimed.
    @discardableResult
    func completeDailyMission(
        points: Int = 10,
        on date: Date = Date()
    ) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)

        var rewardedDates = defaults.stringArray(
            forKey: rewardedDatesKey
        ) ?? []

        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = calendar.timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let todayKey = dateFormatter.string(from: today)

        guard !rewardedDates.contains(todayKey) else {
            return false
        }

        let previousDate = defaults.object(
            forKey: lastCompletionDateKey
        ) as? Date

        if let previousDate {
            let previousDay = calendar.startOfDay(for: previousDate)

            if calendar.isDate(
                previousDay,
                inSameDayAs: calendar.date(
                    byAdding: .day,
                    value: -1,
                    to: today
                ) ?? today
            ) {
                currentStreak += 1
            } else if !calendar.isDate(
                previousDay,
                inSameDayAs: today
            ) {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        totalPoints += max(0, points)

        // Level 1 begins at 0 points; each 100 lifetime points adds a level.
        currentLevel = max(1, (totalPoints / 100) + 1)

        rewardedDates.append(todayKey)
        defaults.set(rewardedDates, forKey: rewardedDatesKey)
        defaults.set(today, forKey: lastCompletionDateKey)

        return true
    }
}
