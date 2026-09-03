//
//  JobPostingDetailsView.swift
//  Voxy
//
//  Created by Voxy Team on 03/09/26.
//

import SwiftUI
import SwiftData

struct JobPostingDetailsView: View {
    let jobPosting: JobPosting

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(jobPosting.title)
                        .font(.custom("Satoshi-Black", size: 24).weight(.black))
                        .foregroundStyle(Color("PrimaryFontColor"))

                    Text(jobPosting.companyName)
                        .font(.custom("Nunito", size: 16).weight(.bold))
                        .foregroundStyle(Color("SecondaryFontColor"))
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("DESCRIÇÃO DA VAGA")
                        .font(.custom("Satoshi-Bold", size: 12))
                        .tracking(1.1)
                        .foregroundStyle(Color("SecondaryFontColor"))

                    Text(jobPosting.jobDescription)
                        .font(.custom("Nunito", size: 15))
                        .foregroundStyle(Color("PrimaryFontColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("TREINOS REALIZADOS")
                        .font(.custom("Satoshi-Bold", size: 12))
                        .tracking(1.1)
                        .foregroundStyle(Color("SecondaryFontColor"))

                    Text("\(jobPosting.countInterview)")
                        .font(.custom("Nunito", size: 22).weight(.bold))
                        .foregroundStyle(Color("PrimaryBlue"))
                }
            }
            .padding(24)
        }
        .navigationTitle(jobPosting.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JobPosting.self, configurations: configuration)

    let jobPosting = JobPosting(
        title: "UX Designer Jr.",
        companyName: "iFood",
        jobDescription: "Vaga para UX Designer com foco em produtos digitais e pesquisa com usuários.",
        countInterview: 3
    )
    container.mainContext.insert(jobPosting)

    return NavigationStack {
        JobPostingDetailsView(jobPosting: jobPosting)
    }
    .modelContainer(container)
}
