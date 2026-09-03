//
//  JobPostingRowView.swift
//  Voxy
//
//  Created by Voxy Team on 31/08/26.
//

import SwiftUI

struct JobPostingRowView: View {
    let jobPosting: JobPosting

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(jobPosting.title)
                .font(Font.custom("Nunito", size: 17).weight(.bold))
                .foregroundStyle(.primary)

            if !jobPosting.jobDescription.isEmpty {
                Text(jobPosting.jobDescription)
                    .font(Font.custom("Nunito", size: 14).weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 8) {
                Text(statusLabel)
                    .font(Font.custom("Nunito", size: 12).weight(.bold))
                    .foregroundStyle(.secondary)

                if jobPosting.countInterview > 0 {
                    Text("· \(jobPosting.countInterview) entrevista(s)")
                        .font(Font.custom("Nunito", size: 12).weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var statusLabel: String {
        switch jobPosting.status {
        case .saved:
            return "Salva"
        case .simulated:
            return "Simulada"
        }
    }
}

#Preview {
    List {
        JobPostingRowView(
            jobPosting: JobPosting(
                title: "UX Designer Jr.",
                companyName: "Nubank",
                jobDescription: "Vaga para atuar com pesquisa e prototipação em produtos digitais.",
            )
        )
        JobPostingRowView(
            jobPosting: JobPosting(
                title: "Front-end Dev",
                companyName: "Nubank",
                jobDescription: "",
            )
        )
    }
}
