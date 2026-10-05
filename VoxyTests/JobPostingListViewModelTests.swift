import Testing
import Foundation
import SwiftData
@testable import Voxy

@MainActor
struct JobPostingListViewModelTests {

    @Test // CT-27
    func showsNotTrainedWhenThereAreNoInterviews() throws {
        let (_, store) = try makeStore()

        let job = JobPosting(
            title: "iOS Developer",
            companyName: "Empresa",
            jobDescription: "Desenvolvimento de aplicações iOS.",
            countInterview: 0
        )

        let viewModel = JobPostingListViewModel(store: store)

        #expect(viewModel.lastSimulatedText(for: job) == "Ainda não treinou")
    }

    @Test // ct-28
    func showsTodayWhenLastTrainingWasToday() throws {
        let (_, store) = try makeStore()

        let job = JobPosting(
            title: "iOS Developer",
            companyName: "Empresa",
            jobDescription: "Desenvolvimento de aplicações iOS.",
            countInterview: 1,
            lastSimulated: .now
        )

        let viewModel = JobPostingListViewModel(store: store)

        let result = viewModel.lastSimulatedText(for: job)

        #expect(result.hasPrefix("Hoje, "))
    }

    @Test // CT-29
    func showsYesterdayWhenLastTrainingWasYesterday() throws {
        let (_, store) = try makeStore()

        let yesterday = Calendar.current.date(
            byAdding: .day,
            value: -1,
            to: .now
        )!

        let job = JobPosting(
            title: "iOS Developer",
            companyName: "Empresa",
            jobDescription: "Desenvolvimento de aplicações iOS.",
            countInterview: 1,
            lastSimulated: yesterday
        )

        let viewModel = JobPostingListViewModel(store: store)

        let result = viewModel.lastSimulatedText(for: job)

        #expect(result.hasPrefix("Ontem, "))
    }

    @Test // CT-30
    func showsFormattedDateWhenLastTrainingWasBeforeYesterday() throws {
        let (_, store) = try makeStore()

        let date = Calendar.current.date(
            byAdding: .day,
            value: -2,
            to: .now
        )!

        let job = JobPosting(
            title: "iOS Developer",
            companyName: "Empresa",
            jobDescription: "Desenvolvimento de aplicações iOS.",
            countInterview: 1,
            lastSimulated: date
        )

        let viewModel = JobPostingListViewModel(store: store)

        let result = viewModel.lastSimulatedText(for: job)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd/MM/yyyy, HH'h'mm"

        #expect(result == formatter.string(from: date))
    }

    private func makeStore() throws -> (ModelContainer, JobPostingStore) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(
            for: JobPosting.self,
            configurations: configuration
        )

        let store = JobPostingStore(modelContext: container.mainContext)

        return (container, store)
    }
}
