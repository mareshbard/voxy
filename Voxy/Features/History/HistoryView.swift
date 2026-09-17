import SwiftUI
import SwiftData

struct HistoryView: View {
    
    @Bindable var viewModel: JobPostingListViewModel
    @State private var isShowingJobPostingForm: Bool = false
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .top) {
                // Topo azul para acompanhar o header
                Color(.systemBackground)
                    .ignoresSafeArea()
                Color("PrimaryBlue")
                    .frame(height: 300)
                    .ignoresSafeArea(edges: .top)
                
                
                List {
                    // Seções do topo inseridas como itens da List
                    Group {
                        HeaderSectionHistory()
                            .padding(.bottom, 10)
  
                        Text("VAGAS")
                            .font(.custom("Satoshi-Bold", size: 12))
                            .tracking(1.1)
                            .foregroundStyle(Color("PrimaryFontColor"))
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                  //  .listRowBackground(Color.clear)
                    
                    // Lista de Vagas
                    if viewModel.jobPostings.isEmpty {
                        ContentUnavailableView(
                            "Nenhuma vaga cadastrada",
                            systemImage: "briefcase",
                            description: Text("Toque em + para adicionar sua primeira vaga.")
                                .font(Font.custom("Satoshi-Bold", size: 18))
                        )
                        .listRowSeparator(.hidden)
//                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(viewModel.jobPostings, id: \.persistentModelID) { jobPosting in
                            JobPostingCard(
                                title: jobPosting.title,
                                companyName: jobPosting.companyName,
                                lastSimulating: viewModel.lastSimulatedText(for: jobPosting),
                                count: "\(jobPosting.countInterview)",
                                unit: "treinos"
                            )
                            .background(
                                NavigationLink(value: jobPosting) {
                                    EmptyView()
                                }
                                .opacity(0)
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.delete(jobPosting)
                                } label: {
                                    Label("Excluir", systemImage: "trash")
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 24, bottom: 5, trailing: 24))
                            .background(Color(.systemBackground))
                        }
                        Section {
                            Color.clear
                                .frame(height: 200)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .navigationDestination(for: JobPosting.self) { jobPosting in
                    JobPostingDetailsView(
                        jobPosting: jobPosting,
                        onStartInterview: { path.append(InterviewRoute(job: jobPosting)) }
                    )
                }
                .navigationDestination(for: InterviewRoute.self) { route in
                    InterviewLoadingView(
                        jobPosting: route.job,
                        onFinish: { path.removeLast(path.count) }
                    )
                }

                .ignoresSafeArea(edges: .top)
                .task {
                    viewModel.loadJobPostings()
                }
                
                .sheet(isPresented: $isShowingJobPostingForm, onDismiss: {
                    viewModel.loadJobPostings()
                }) {
                    JobPostingFormView(
                        viewModel: viewModel.makeFormViewModel()
                    )
                }
                .scrollEdgeEffectHidden(true, for: .top)
                .alert(
                    "Erro",
                    isPresented: Binding(
                        get: { viewModel.errorMessage != nil },
                        set: { isPresented in
                            if !isPresented {
                                viewModel.errorMessage = nil
                            }
                        }
                    ),
                    presenting: viewModel.errorMessage
                ) { _ in
                    Button("OK", role: .cancel) {}
                } message: { message in
                    Text(message)
                }
            }
        }
        .onAppear {
            viewModel.loadJobPostings()
        }
    }
}

#Preview {
    let configuration = ModelConfiguration(
        isStoredInMemoryOnly: true
    )
    
    let container = try! ModelContainer(
        for: JobPosting.self,
        configurations: configuration
    )
    
    let context = container.mainContext
    
    let _ = {
        context.insert(
            JobPosting(
                title: "UX Designer Jr.",
                companyName: "iFood",
                jobDescription: "Vaga para UX Designer",
                countInterview: 1
            )
        )
        
        context.insert(
            JobPosting(
                title: "iOS Developer Jr.",
                companyName: "Apple",
                jobDescription: "Vaga para desenvolvimento iOS",
                countInterview: 3
            )
        )
        context.insert(
            JobPosting(
                title: "iOS Developer Jr.",
                companyName: "Apple",
                jobDescription: "Vaga para desenvolvimento iOS",
                countInterview: 3
            )
        )
        context.insert(
            JobPosting(
                title: "iOS Developer Jr.",
                companyName: "Apple",
                jobDescription: "Vaga para desenvolvimento iOS",
                countInterview: 3
            )
        )
        context.insert(
            JobPosting(
                title: "iOS Developer Jr.",
                companyName: "Apple",
                jobDescription: "Vaga para desenvolvimento iOS",
                countInterview: 3
            )
        )
    }()
    
    let store = JobPostingStore(
        modelContext: context
    )
    
    let viewModel = JobPostingListViewModel(
        store: store
    )
    
    HistoryView(
        viewModel: viewModel
    )
    .modelContainer(container)
}

