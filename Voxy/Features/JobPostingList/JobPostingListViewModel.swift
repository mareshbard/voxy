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
