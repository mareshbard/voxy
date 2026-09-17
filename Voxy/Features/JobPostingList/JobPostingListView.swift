//
//  JobListView.swift
//  Voxy
//
//  Created by Voxy Team on 02/09/26.
//

import SwiftUI
import SwiftData

struct JobPostingListView: View {
    
    @Bindable var viewModel: JobPostingListViewModel
    @State private var isShowingJobPostingForm: Bool = false
    @State private var jobPostingToTrain: JobPosting?
    // Pilha de navegação controlada: permite voltar direto à raiz (esvaziar).
    @State private var path = NavigationPath()
    // Altura real do header, usada para dimensionar a faixa azul do topo.
    @State private var headerHeight: CGFloat = 300

    var body: some View {
        NavigationStack(path: $path) {
        ZStack(alignment: .top) {
            // Fundo base da tela.
            Color("VoxyBackground")
                .ignoresSafeArea()

            // Faixa azul no topo, para cobrir o overscroll (quando o usuário
            // puxa a tela e o header desce, evitando que o fundo apareça atrás).
            // A altura acompanha dinamicamente a altura real do HeaderSection
            // (medida via GeometryReader): assim ela fica sempre coberta pelo
            // header no estado normal — sem sobrar uma faixa azul no meio — e
            // cresce junto com o header (ex.: tamanhos de acessibilidade).
            Color("PrimaryBlue")
                .frame(height: headerHeight)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)

                List {
                    // Seções do topo inseridas como itens da List
                    Group {
                        HeaderSection()
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

                        StreakSection()
                            .padding(.vertical, 10)

                        if !viewModel.jobPostings.isEmpty {
                            Text("VAGAS")
                                .font(.custom("Satoshi-Bold", size: 12))
                                .tracking(1.1)
                                .foregroundStyle(Color("PrimaryFontColor"))
                                .padding(.top, 10)
                                .padding(.bottom, 5)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                    .listRowBackground(Color("VoxyBackground"))
                    
                    // Lista de Vagas
                    if viewModel.jobPostings.isEmpty {
                        EmptyJobPostingsCard()
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 20, leading: 24, bottom: 5, trailing: 24))
                    } else {
                        ForEach(viewModel.jobPostings.prefix(5), id: \.persistentModelID) { jobPosting in
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
                .scrollIndicators(.hidden)
                .listStyle(.plain)
                .onPreferenceChange(HeaderHeightPreferenceKey.self) { newHeight in
                    headerHeight = newHeight
                }
                // .scrollContentBackground(.hidden)
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
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Nova vaga", systemImage: "plus") {
                            jobPostingToTrain = nil
                            isShowingJobPostingForm = true
                        }
                        .buttonStyle(GlassProminentButtonStyle())
                        .tint(Color("BackgroundJobCardColor"))
                    }
                }
                
                .sheet(isPresented: $isShowingJobPostingForm, onDismiss: {
                    viewModel.loadJobPostings()
                    
                    if let jobPostingToTrain {
                        path.append(InterviewRoute(job: jobPostingToTrain))
                    }
                }) {
                    JobPostingFormView(
                        viewModel: viewModel.makeFormViewModel(),
                        onStartTraining: { jobPosting in
                            jobPostingToTrain = jobPosting
                            isShowingJobPostingForm = false
                        }
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

struct InterviewRoute: Hashable {
    let job: JobPosting
}

struct EmptyJobPostingsCard: View {
    var title: String = "Você ainda não tem nenhuma vaga cadastrada!"
    var message: String = "Para começar a treinar, cadastre uma vaga clicando no canto superior direito da tela"

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.custom("Satoshi-Black", size: 24, relativeTo: .title3).weight(.black))
                .foregroundStyle(Color("PrimaryFontColor"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(message)
                .font(.custom("Nunito", size: 16, relativeTo: .subheadline).weight(.bold))
                .foregroundStyle(Color("SecondaryFontColor"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 40)
        .background(Color("BackgroundJobCardColor"))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

struct EmptyJobPostingsHistoryCard: View {
    var title: String = "Você ainda não tem nenhuma vaga cadastrada!"
    var message: String = "Para começar a treinar, cadastre uma vaga na aba inicial para começar"

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.custom("Satoshi-Black", size: 24, relativeTo: .title3).weight(.black))
                .foregroundStyle(Color("PrimaryFontColor"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(message)
                .font(.custom("Nunito", size: 16, relativeTo: .subheadline).weight(.bold))
                .foregroundStyle(Color("SecondaryFontColor"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 40)
        .background(Color("BackgroundJobCardColor"))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

struct HeaderHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 300
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
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
    
    JobPostingListView(
        viewModel: viewModel
    )
    .modelContainer(container)
}
