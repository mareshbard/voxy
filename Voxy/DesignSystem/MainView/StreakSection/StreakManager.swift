//
//  StreakManager.swift
//  Voxy
//
//  Created by Voxy Team on 04/09/26.
//

import Foundation

enum StreakManager {

    // MARK: - Keys (precisam bater com as usadas no @AppStorage da view)

    enum Keys {
        static let currentStreak = "currentStreak"
        static let maxStreak = "maxStreak"
        static let totalSessions = "totalSessions"
        static let lastSessionDate = "lastSessionDate"
    }

    // MARK: - Registrar uma sessão de entrevista concluída

    @discardableResult
    static func recordSession(defaults: UserDefaults = .standard, now: Date = Date()) -> (streak: Int, record: Int, total: Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        let lastDateInterval = defaults.double(forKey: Keys.lastSessionDate)
        let hasLastDate = lastDateInterval > 0
        let lastDate = hasLastDate ? Date(timeIntervalSince1970: lastDateInterval) : nil
        let lastDayStart = lastDate.map { calendar.startOfDay(for: $0) }

        var currentStreak = defaults.integer(forKey: Keys.currentStreak)
        var maxStreak = defaults.integer(forKey: Keys.maxStreak)
        var totalSessions = defaults.integer(forKey: Keys.totalSessions)

        if let lastDayStart {
            let daysBetween = calendar.dateComponents([.day], from: lastDayStart, to: today).day ?? Int.max

            if daysBetween == 0 {
                // Já treinou hoje: não mexe na streak, só conta a sessão.
            } else if daysBetween == 1 {
                // Treinou ontem: streak continua.
                currentStreak += 1
            } else {
                // Pulou um ou mais dias: streak reinicia.
                currentStreak = 1
            }
        } else {
            // Primeira sessão registrada.
            currentStreak = 1
        }

        maxStreak = max(maxStreak, currentStreak)
        totalSessions += 1

        defaults.set(currentStreak, forKey: Keys.currentStreak)
        defaults.set(maxStreak, forKey: Keys.maxStreak)
        defaults.set(totalSessions, forKey: Keys.totalSessions)
        defaults.set(today.timeIntervalSince1970, forKey: Keys.lastSessionDate)

        return (currentStreak, maxStreak, totalSessions)
    }

    // MARK: - Verificar se a streak "quebrou" (opcional, pra chamar ao abrir o app)

    static func refreshIfStreakBroken(defaults: UserDefaults = .standard, now: Date = Date()) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        let lastDateInterval = defaults.double(forKey: Keys.lastSessionDate)
        guard lastDateInterval > 0 else { return }

        let lastDayStart = calendar.startOfDay(for: Date(timeIntervalSince1970: lastDateInterval))
        let daysBetween = calendar.dateComponents([.day], from: lastDayStart, to: today).day ?? 0

        if daysBetween > 1 {
            defaults.set(0, forKey: Keys.currentStreak)
        }
    }
}
