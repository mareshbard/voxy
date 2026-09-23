//
//  JobPostingFormViewModelTests.swift
//  Voxy
//
//  Created by Voxy Team on 21/09/26.
//

import Testing
import SwiftData
@testable import Voxy

@MainActor
struct JobPostingFormViewModelTests {

    private func makeStore() throws -> (ModelContainer, JobPostingStore) {
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: JobPosting.self,
            configurations: configuration
        )

        let store = JobPostingStore(
            modelContext: container.mainContext
        )

        return (container, store)
    }

    // CT-10

    @Test
    func allRequiredFieldsFilledInIsValidForTraining() throws {
        let (container, store) = try makeStore()
        _ = container

        let viewModel = JobPostingFormViewModel(
            store: store
        )

        viewModel.title = "iOS Developer"
        viewModel.companyName = "Empresa"
        viewModel.jobDescription = "Desenvolvimento de aplicações iOS."

        #expect(viewModel.canTrain)
    }

    // CT-11

    @Test
    func emptyJobTitleIsInvalidForTraining() throws {
        let (container, store) = try makeStore()
        _ = container

        let viewModel = JobPostingFormViewModel(
            store: store
        )

        viewModel.title = ""
        viewModel.companyName = "Empresa"
        viewModel.jobDescription = "Desenvolvimento de aplicações iOS."

        #expect(viewModel.canTrain == false)
    }

    // CT-12

    @Test
    func emptyCompanyNameIsInvalidForTraining() throws {
        let (container, store) = try makeStore()
        _ = container

        let viewModel = JobPostingFormViewModel(
            store: store
        )

        viewModel.title = "iOS Developer"
        viewModel.companyName = ""
        viewModel.jobDescription = "Desenvolvimento de aplicações iOS."

        #expect(viewModel.canTrain == false)
    }

    // CT-13

    @Test
    func emptyJobDescriptionIsInvalidForTraining() throws {
        let (container, store) = try makeStore()
        _ = container

        let viewModel = JobPostingFormViewModel(
            store: store
        )

        viewModel.title = "iOS Developer"
        viewModel.companyName = "Empresa"
        viewModel.jobDescription = ""

        #expect(viewModel.canTrain == false)
    }

    // CT-14

    @Test
    func loadsExistingJobPostingForEditing() throws {
        let (container, store) = try makeStore()
        _ = container

        let jobPosting = JobPosting(
            title: "iOS Developer",
            companyName: "Empresa",
            jobDescription: "Desenvolvimento de aplicações iOS."
        )

        let viewModel = JobPostingFormViewModel(
            store: store,
            editingJobPosting: jobPosting
        )

        #expect(viewModel.isEditing)
        #expect(viewModel.title == "iOS Developer")
        #expect(viewModel.companyName == "Empresa")
        #expect(
            viewModel.jobDescription
                == "Desenvolvimento de aplicações iOS."
        )
    }
    
    // CT-15

    @Test
    func editsExistingJobPostingWithoutCreatingDuplicate() throws {
        let (container, store) = try makeStore()
        _ = container

        let jobPosting = JobPosting(
            title: "iOS Developer",
            companyName: "Empresa",
            jobDescription: "Descrição original"
        )

        try store.save(jobPosting)

        let viewModel = JobPostingFormViewModel(
            store: store,
            editingJobPosting: jobPosting
        )

        viewModel.title = "Senior iOS Developer"
        viewModel.companyName = "Nova Empresa"
        viewModel.jobDescription = "Nova descrição"

        let updatedJobPosting = viewModel.save()

        #expect(updatedJobPosting != nil)

        let jobPostings = try store.fetchAll()

        #expect(jobPostings.count == 1)
        #expect(jobPostings.first?.title == "Senior iOS Developer")
        #expect(jobPostings.first?.companyName == "Nova Empresa")
        #expect(jobPostings.first?.jobDescription == "Nova descrição")
    }
    
    // CT-16

    @Test
    func trimsWhitespaceOnSave() throws {
        let (container, store) = try makeStore()
        _ = container

        let viewModel = JobPostingFormViewModel(
            store: store
        )

        viewModel.title = "   iOS Developer   "
        viewModel.companyName = "   Empresa   "
        viewModel.jobDescription = "   Desenvolvimento de aplicações iOS.   "

        let savedJobPosting = viewModel.save()

        #expect(savedJobPosting?.title == "iOS Developer")
        #expect(savedJobPosting?.companyName == "Empresa")
        #expect(
            savedJobPosting?.jobDescription
                == "Desenvolvimento de aplicações iOS."
        )
    }
}
