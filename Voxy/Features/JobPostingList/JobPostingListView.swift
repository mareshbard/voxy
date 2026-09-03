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
    @Query(sort: \JobPosting.title) private var jobPostings: [JobPosting]
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                VStack(spacing: 0) {
                    
                    HeaderSection()
                    
                    StreakSection()
                        .padding(20)
                    
                    Text("VAGAS CADASTRADAS")
                        .font(.custom("Satoshi-Bold", size: 12))
                        .tracking(1.1)
                        .foregroundStyle(Color("PrimaryFontColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 10) {
                        if jobPostings.isEmpty {
                            ContentUnavailableView(
                                "Nenhuma vaga cadastrada",
                                systemImage: "briefcase",
                                description: Text("Toque em + para adicionar sua primeira vaga.")
                                    .font(Font.custom("Satoshi-Bold", size: 18))
                            )
                        } else {
                            
                                ForEach(viewModel.jobPostings, id: \.persistentModelID) { jobPosting in
                                    NavigationLink(value: jobPosting) {
                                        JobPostingCard(
                                            title: jobPosting.title,
                                            companyName: jobPosting.companyName,
                                            lastSimulating: "Ontem, 10h45",
                                            count: "\(jobPosting.countInterview)",
                                            unit: "treinos"
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            viewModel.delete(jobPosting)
                                        } label: {
                                            Label("Excluir", systemImage: "trash")
                                        }
                                    }
                                }
                            
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.horizontal, 24)
                }
            }
            .navigationDestination(for: JobPosting.self) { jobPosting in
                JobPostingDetailsView(jobPosting: jobPosting)
            }
            .ignoresSafeArea()
            .scrollEdgeEffectHidden(true, for: .top)
            .task {
                viewModel.loadJobPostings()
            }
            .toolbar {
                
                ToolbarItem(placement: .primaryAction) {
                    
                    Button("Nova vaga", systemImage: "plus") {
                        
                        isShowingJobPostingForm = true
                        
                    }
                    .tint(Color.primary)
                    
                }
            }
            .sheet(isPresented: $isShowingJobPostingForm) {
                JobPostingFormView(
                    viewModel: JobPostingFormViewModel(
                        store: JobPostingStore(
                            modelContext: modelContext
                        )
                    )
                )
            }
            
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
