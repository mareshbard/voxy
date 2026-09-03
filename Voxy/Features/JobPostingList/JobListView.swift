//
//  JobListView.swift
//  Voxy
//
//  Created by Voxy Team on 02/09/26.
//

import SwiftUI
import SwiftData

struct JobListView: View {

    @Bindable var viewModel: JobPostingListViewModel

    @State private var isShowingJobPostingForm: Bool = false

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 0) {

                    HeaderSection()
                        .frame(minHeight: 234)

                    StreakSection()
                        .padding(20)

                    Text("ÚLTIMOS TREINOS")
                        .font(.custom("Satoshi-Bold", size: 12))
                        .tracking(1.1)
                        .foregroundStyle(Color("PrimaryFontColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 10)

                    VStack(spacing: 10) {
                        ForEach(viewModel.jobPostings, id: \.persistentModelID) { jobPosting in
                            JobPostingCard(
                                title: jobPosting.title,
                                companyName: jobPosting.companyName,
                                lastSimulating: "Ontem, 10h45",
                                count: "\(jobPosting.countInterview)",
                                unit: "treinos"
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 200, alignment: .top)
                    .padding(.horizontal, 24)
                }
            }
            .ignoresSafeArea(edges: .top)
            .task {
                viewModel.loadJobPostings()
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {

                ToolbarItem(placement: .primaryAction) {

                    Button("Nova vaga", systemImage: "plus") {

                        isShowingJobPostingForm = true

                    }
                    .tint(Color.primary)

                }
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

    JobListView(
        viewModel: viewModel
    )
    .modelContainer(container)
}
