import SwiftUI
import SwiftData

struct TabBar: View {
    
    @SceneStorage("selectedTab") private var selectedTabIndex: Int = 0
    let viewModel: JobPostingListViewModel

    var body: some View {
        TabView(selection: $selectedTabIndex) {
            Tab("Início", systemImage: "clipboard.fill", value: 0) {
                JobPostingListView(viewModel: viewModel)
            }
            Tab("Histórico", systemImage: "folder.fill", value: 1) {
                HistoryView(viewModel: viewModel)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .accentColor(Color(.bg))
    }
}

#Preview {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JobPosting.self, configurations: configuration)
    let store = JobPostingStore(modelContext: container.mainContext)

    TabBar(viewModel: JobPostingListViewModel(store: store))
}
