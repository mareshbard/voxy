//
//  OnBoardingModelView.swift
//  Voxy
//
//  Created by Voxy Team on 08/09/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class OnBoardingViewModel {

    enum Keys {
        static let username = "username"
    }

    enum Step {
        case splash
        case onboarding
        case home
    }

    private let defaults: UserDefaults

    var nameInput: String

    private(set) var username: String

    private(set) var isShowingSplash = true

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let stored = defaults.string(forKey: Keys.username) ?? ""
        self.username = stored
        self.nameInput = stored
    }

    var hasRegisteredName: Bool {
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var step: Step {
        if hasRegisteredName {
            return .home
        }
        return isShowingSplash ? .splash : .onboarding
    }

    func splashDidFinish() {
        isShowingSplash = false
    }

    var canRegister: Bool {
        !nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func register() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        username = trimmed
        defaults.set(trimmed, forKey: Keys.username)
    }
}
