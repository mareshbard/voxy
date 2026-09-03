import SwiftUI
import SwiftData

@main
struct VoxyApp: App {

    init() {
        FontRegistration.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            InterviewSessionView()
        }
        .modelContainer(for: JobPosting.self)
    }
}
