//
//  AnswerQuality.swift
//  Voxy
//

import Foundation

nonisolated enum AnswerQuality {

    private static let lowEffortPhrases: Set<String> = [
        "nao sei", "nao sei responder", "nao sei dizer", "nao faco ideia",
        "sei la", "nao lembro", "nao me lembro", "passo", "sem resposta",
        "nao entendi", "nao conheco", "nao"
    ]

    static func isSubstantive(_ answer: String) -> Bool {
        let normalized = answer
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalized.isEmpty else { return false }
        if lowEffortPhrases.contains(normalized) { return false }

        let wordCount = normalized.split { $0 == " " || $0 == "\n" }.count
        return wordCount >= 4
    }

    static func hasSubstantiveAnswer(in answers: [String]) -> Bool {
        answers.contains(where: isSubstantive)
    }
}
