import SwiftUI
import SwiftData

@main
struct VoxyApp: App {

    init() {
        FontRegistration.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            OnBoardingView(feedbackEngine: FoundationFeedbackEngine())
        }
        .modelContainer(for: JobPosting.self)
    }
}
