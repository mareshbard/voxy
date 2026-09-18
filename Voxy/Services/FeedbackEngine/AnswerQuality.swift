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

    /// Indica se um item de feedback é apenas um marcador de baixo esforço
    /// (ex.: "não sei"), que não deve aparecer em seções como Profundidade/Clareza.
    static func isLowEffortMarker(_ text: String) -> Bool {
        let normalized = text
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted.subtracting(.whitespaces))
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalized.isEmpty else { return true }
        if lowEffortPhrases.contains(normalized) { return true }
        // Frases curtas que são essencialmente "não sei".
        return normalized.hasPrefix("nao sei") && normalized.split(separator: " ").count <= 4
    }
}
