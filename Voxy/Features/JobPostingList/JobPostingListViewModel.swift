//
//  JobPostingListViewModel.swift
//  Voxy
//
//  Created by Voxy Team on 31/08/26.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class JobPostingListViewModel {
    var jobPostings: [JobPosting] = []
    var errorMessage: String?

    private let store: JobPostingStore

    init(store: JobPostingStore) {
        self.store = store
    }

    func makeFormViewModel() -> JobPostingFormViewModel {
        JobPostingFormViewModel(store: store)
    }

    /// Formata a data do último treino: "Hoje" ou "Ontem" com o horário,
    /// e para datas mais antigas exibe a data completa.
    func lastSimulatedText(for jobPosting: JobPosting) -> String {
        let date = jobPosting.lastSimulated
        let calendar = Calendar.current
        let time = Self.timeFormatter.string(from: date)

        if calendar.isDateInToday(date) {
            return "Hoje, \(time)"
        } else if calendar.isDateInYesterday(date) {
            return "Ontem, \(time)"
        } else {
            return Self.dateFormatter.string(from: date)
        }
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "HH'h'mm"
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd/MM/yyyy, HH'h'mm"
        return formatter
    }()

    func loadJobPostings() {
        do {
            let fetchedJobPostings = try store.fetchAll()
            jobPostings = fetchedJobPostings
            errorMessage = nil
        } catch {
            jobPostings = []
            errorMessage = "Não foi possível carregar as vagas."
            print("Erro ao carregar vagas: \(error)")
        }
    }

    func delete(_ jobPosting: JobPosting) {
        do {
            try store.delete(jobPosting)
            jobPostings.removeAll { $0.persistentModelID == jobPosting.persistentModelID }
            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível excluir a vaga."
            print("Erro ao excluir vaga: \(error)")
        }
    }
}
