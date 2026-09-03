//
//  OnBoardingView.swift
//  Voxy
//
//  Created by Yohane Cavalcante on 28/08/26.
//

import SwiftUI
import SwiftData

struct OnBoardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JobPosting.title) private var jobPostings: [JobPosting]
    @State private var isShowingJobPostingForm = false

    var body: some View {
        NavigationStack {
            Group {
                if jobPostings.isEmpty {
                    ContentUnavailableView(
                        "Nenhuma vaga cadastrada",
                        systemImage: "briefcase",
                        description: Text("Toque em + para adicionar sua primeira vaga.")
                    )
                } else {
                    List {
                        ForEach(jobPostings) { jobPosting in
                            NavigationLink(value: jobPosting) {
                                JobPostingRowView(jobPosting: jobPosting)
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: JobPosting.self) { jobPosting in
                InterviewView(jobPosting: jobPosting)
            }
            .navigationTitle("Início")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Nova vaga", systemImage: "plus") {
                        isShowingJobPostingForm = true
                    }
                    .tint(Color.blue)
                }
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

#Preview {
    OnBoardingView()
        .modelContainer(for: JobPosting.self, inMemory: true)
}
