//
//  VoxyTests.swift
//  VoxyTests
//
//  Created by Voxy Team on 18/09/26.
//

// vou usar Swift Testing
import Testing
import Foundation

// importa o meu target do projeto pra ser testado
@testable import Voxy



struct StreakManagerTests {
    
    // CT-01 — Primeiro treino
    @Test
    func firstTrainingSession() {
        let suiteName = "StreakManagerTests.CT01"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let result = StreakManager.recordSession(defaults: defaults)

        #expect(result.streak == 1)
    }
    // CT-02
    @Test
    func secondTrainingSessionOnSameDay() {
        let suiteName = "StreakManagerTests.CT02"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let now = Date()

        let firstResult = StreakManager.recordSession(
            defaults: defaults,
            now: now
        )

        let secondResult = StreakManager.recordSession(
            defaults: defaults,
            now: now
        )

        #expect(firstResult.streak == 1)
        #expect(secondResult.streak == 1)
        #expect(secondResult.total == firstResult.total + 1)
    }
    
    // CT-03
    @Test
    func trainingSessionOnConsecutiveDay() {
        let suiteName = "StreakManagerTests.CT03"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let firstResult = StreakManager.recordSession(
            defaults: defaults,
            now: yesterday
        )

        let secondResult = StreakManager.recordSession(
            defaults: defaults,
            now: today
        )

        #expect(firstResult.streak == 1)
        #expect(secondResult.streak == firstResult.streak + 1)
    }
    
    // CT-04
    @Test
    func trainingSessionAfterStreakBreak() {
        let suiteName = "StreakManagerTests.CT04"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let calendar = Calendar.current
        let today = Date()
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        StreakManager.recordSession(
            defaults: defaults,
            now: twoDaysAgo
        )

        let result = StreakManager.recordSession(
            defaults: defaults,
            now: today
        )

        #expect(result.streak == 1)
    }
    
    // CT-05
    @Test
    func refreshAfterStreakBreak() {
        let suiteName = "StreakManagerTests.CT05"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let calendar = Calendar.current
        let today = Date()
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        StreakManager.recordSession(
            defaults: defaults,
            now: twoDaysAgo
        )

        StreakManager.refreshIfStreakBroken(
            defaults: defaults,
            now: today
        )

        let currentStreak = defaults.integer(
            forKey: StreakManager.Keys.currentStreak
        )

        #expect(currentStreak == 0)
    }
    
    // CT-06
    @Test
    func maintainsMaxStreakWhenCurrentStreakIsLower() {
        let suiteName = "StreakManagerTests.CT06"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        defaults.set(5, forKey: StreakManager.Keys.maxStreak)

        let result = StreakManager.recordSession(
            defaults: defaults,
            now: Date()
        )

        #expect(result.streak == 1)
        #expect(result.record == 5)
    }
}
