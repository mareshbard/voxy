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
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingJobPostingForm: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                // Seções do topo inseridas como itens da List
                Group {
                    HeaderSection()
                    
                    StreakSection()
                        .padding(.vertical, 10)
                    
                    Text("VAGAS")
                        .font(.custom("Satoshi-Bold", size: 12))
                        .tracking(1.1)
                        .foregroundStyle(Color("PrimaryFontColor"))
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                .listRowBackground(Color.clear)
                
                // Lista de Vagas
                if viewModel.jobPostings.isEmpty {
                    ContentUnavailableView(
                        "Nenhuma vaga cadastrada",
                        systemImage: "briefcase",
                        description: Text("Toque em + para adicionar sua primeira vaga.")
                            .font(Font.custom("Satoshi-Bold", size: 18))
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.jobPostings, id: \.persistentModelID) { jobPosting in
                        JobPostingCard(
                            title: jobPosting.title,
                            companyName: jobPosting.companyName,
                            lastSimulating: "Ontem, 10h45",
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
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 5, leading: 24, bottom: 5, trailing: 24))
                }
            }
            .listStyle(.plain)
            .navigationDestination(for: JobPosting.self) { jobPosting in
                JobPostingDetailsView(jobPosting: jobPosting)
            }
            .ignoresSafeArea(edges: .top)
            .task {
                viewModel.loadJobPostings()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Nova vaga", systemImage: "plus") {
                        isShowingJobPostingForm = true
                    }
                    .buttonStyle(GlassProminentButtonStyle())
                    .tint(Color("BackgroundJobCardColor"))
                }
            }
            
            .sheet(isPresented: $isShowingJobPostingForm, onDismiss: {
                viewModel.loadJobPostings()
            }) {
                JobPostingFormView(
                    viewModel: JobPostingFormViewModel(
                        store: JobPostingStore(
                            modelContext: modelContext
                        )
                    )
                )
            }
            .scrollEdgeEffectHidden(true, for: .top)
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
    
    JobPostingListView(
        viewModel: viewModel
    )
    .modelContainer(container)
}
