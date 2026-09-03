//
//  JobPostingStore.swift
//  Voxy
//
//  Created by Voxy Team on 30/08/26.
//
// armazena vagas - persistência de vaga
import SwiftData

@MainActor
final class JobPostingStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ jobPosting: JobPosting) throws {
        modelContext.insert(jobPosting)
        try modelContext.save()
    }

    func fetchAll() throws -> [JobPosting] {
        let descriptor = FetchDescriptor<JobPosting>()
        return try modelContext.fetch(descriptor)
    }
}
