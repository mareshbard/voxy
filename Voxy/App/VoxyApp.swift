import SwiftUI
import SwiftData

@main
struct VoxyApp: App {

    private let modelContainer: ModelContainer
    private let jobPostingListViewModel: JobPostingListViewModel

    init() {
        FontRegistration.registerFonts()

        let container = try! ModelContainer(for: JobPosting.self)
        let store = JobPostingStore(modelContext: container.mainContext)

        self.modelContainer = container
        self.jobPostingListViewModel = JobPostingListViewModel(store: store)
    }

    var body: some Scene {
        WindowGroup {
            JobPostingListView(viewModel: jobPostingListViewModel)
        }
        .modelContainer(modelContainer)
    }
}
