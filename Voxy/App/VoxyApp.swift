import SwiftUI
import SwiftData

@main
struct VoxyApp: App {
    var body: some Scene {
        WindowGroup {
            OnBoardingView()
        }
        .modelContainer(for: JobPosting.self)
    }
}
