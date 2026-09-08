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
            RootView(listViewModel: jobPostingListViewModel)
        }
        .modelContainer(modelContainer)
    }
}

private struct RootView: View {
    let listViewModel: JobPostingListViewModel
    @State private var viewModel = OnBoardingViewModel()

    var body: some View {
        switch viewModel.step {
        case .splash:
            SplashView(onFinished: { viewModel.splashDidFinish() })
        case .onboarding:
            OnBoardingView(viewModel: viewModel)
        case .home:
            JobPostingListView(viewModel: listViewModel)
        }
    }
}
