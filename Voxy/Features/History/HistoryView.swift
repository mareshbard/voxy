import SwiftUI
import SwiftData

struct HistoryView: View {
    
    @Bindable var viewModel: JobPostingListViewModel
    @State private var isShowingJobPostingForm: Bool = false
    @State private var path = NavigationPath()
    // Altura real do header, usada para dimensionar a faixa azul do topo.
    @State private var headerHeight: CGFloat = 300

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .top) {
                // Fundo base da tela.
                Color("VoxyBackground")
                    .ignoresSafeArea()

                // Faixa azul no topo, para cobrir o overscroll. A altura acompanha
                // dinamicamente a altura real do header (medida via GeometryReader),
                // ficando sempre coberta por ele no estado normal.
                Color("PrimaryBlue")
                    .frame(height: headerHeight)
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(edges: .top)


                List {
                    // Seções do topo inseridas como itens da List
                    Group {
                        HeaderSectionHistory()
                            .padding(.bottom, 10)
                            .background(
                                // Mede a altura real do header para dimensionar a
                                // faixa azul do topo dinamicamente.
                                GeometryReader { proxy in
                                    Color.clear.preference(
                                        key: HeaderHeightPreferenceKey.self,
                                        value: proxy.size.height
                                    )
                                }
                            )

                        Text("VAGAS")
                            .font(.custom("Satoshi-Bold", size: 12))
                            .tracking(1.1)
                            .foregroundStyle(Color("PrimaryFontColor"))
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                    .listRowBackground(Color("VoxyBackground"))
                    
                    // Lista de Vagas
                    if viewModel.jobPostings.isEmpty {
                        EmptyJobPostingsHistoryCard()
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 20, leading: 24, bottom: 5, trailing: 24))
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
                        }
                        
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color("VoxyBackground"))
                        .listRowInsets(EdgeInsets(top: 5, leading: 24, bottom: 5, trailing: 24))
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .onPreferenceChange(HeaderHeightPreferenceKey.self) { newHeight in
                    headerHeight = newHeight
                }
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
