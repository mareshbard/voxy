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


// CT-01 — Primeiro treino
struct StreakManagerTests {

    @Test
    func firstTrainingSession() {
        let suiteName = "StreakManagerTests.CT01"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let result = StreakManager.recordSession(defaults: defaults)

        #expect(result.streak == 1)
    }
}
