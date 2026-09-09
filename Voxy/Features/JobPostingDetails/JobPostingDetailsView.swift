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

    @State private var shouldStartInterview = false
    @State private var shouldEditJobPosting = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 24) {
                    trainingCountCard
                    descriptionSection
                }
                .padding(.horizontal, 26)
                .padding(.top, 26)
                .padding(.bottom, 120)
            }
        }
        .toolbar(.hidden, for: .tabBar)

        .background(Color.white)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom) {
            trainButton
        }
        .navigationDestination(
            isPresented: $shouldStartInterview
        ) {
            InterviewView(
                jobPosting: jobPosting,
                feedbackEngine: FoundationFeedbackEngine()
            )
        }
        
        .sheet(isPresented: $shouldEditJobPosting) {
            JobPostingFormView(
                viewModel: JobPostingFormViewModel(
                    store: JobPostingStore(
                        modelContext: modelContext
                    ),
                    editingJobPosting: jobPosting
                )
            )
        }
        .toolbar(.hidden, for: .navigationBar)
    }


    private var header: some View {
        ZStack {
            Color("PrimaryBlue")

            VStack(spacing: 6) {
                Text(jobPosting.title)
                    .font(.custom("Satoshi-Black", size: 32))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                //    .frame(width: 242, alignment: .top)

                Text(jobPosting.companyName)
                    .font(.custom("Nunito-Bold", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                //    .frame(maxWidth: .infinity, alignment: .top)
            }
            .padding(.top, 110)

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 19, weight: .medium))
                            .foregroundStyle(Color("IconPrimaryColor"))
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(.white.opacity(0.9))
                            )
                            .accessibilityLabel(Text("Voltar"))
                    }
                    

                    Spacer()

                    Button {
                        shouldEditJobPosting = true
                    } label: {
                        Text("Editar")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Color("IconPrimaryColor"))
                            .padding(.horizontal, 20)
                            .frame(height: 48)
                            .background(
                                Capsule()
                                    .fill(.white)
                            )
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 74)
        }
    //    .frame(height: 234)
    }


    private var trainingCountCard: some View {
        VStack(spacing: 4) {
            Text("\(jobPosting.countInterview)")
                .font(.custom("Nunito-Black", size: 24))
                .foregroundStyle(Color("DisabledFontColor"))

            Text(trainingMessage)
                .font(.custom("Nunito-Bold", size: 14))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("SecondaryFontColor"))
                .frame(maxWidth: .infinity, alignment: .top)
        }
        .accessibilityElement(children: .combine)
        .padding(16)
        .frame(width: 117, alignment: .center)
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color("PrimaryBlue"), lineWidth: 1)
        }
    }

    private var trainingMessage: String {
        switch jobPosting.countInterview {
        case 0:
            return "ainda não\ntreinou :("
        case 1:
            return "1 treino\nrealizado"
        default:
            return "treinos\nrealizados"
        }
    }


    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("DESCRIÇÃO DA VAGA")
                .font(.custom("Satoshi-Bold", size: 14))
                .kerning(0.72)
                .foregroundStyle(Color("PrimaryFontColor"))

            VStack(alignment: .leading, spacing: 24) {
                ForEach(Array(jobDescriptionItems.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .top, spacing: 16) {
                        Circle()
                            .fill(Color("PrimaryBlue"))
                            .frame(width: 10, height: 10)
                            .padding(.top, 4)

                        Text(item)
                            .font(.custom("Nunito-Bold", size: 14))
                            .foregroundStyle(Color("SecondaryFontColor"))
                            .frame(
                                maxWidth: .infinity,
                                alignment: .topLeading
                            )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var jobDescriptionItems: [String] {
        let lines = jobPosting.jobDescription
            .components(separatedBy: .newlines)
            .map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter {
                !$0.isEmpty
            }

        var items: [String] = []
        var currentItem = ""

        for line in lines {
            if currentItem.isEmpty {
                currentItem = line
            } else {
                currentItem += " " + line
            }

            if endsRequirement(line) {
                items.append(currentItem)
                currentItem = ""
            }
        }

        if !currentItem.isEmpty {
            items.append(currentItem)
        }

        return items
    }

    private func endsRequirement(_ text: String) -> Bool {
        guard let lastCharacter = text.last else {
            return false
        }

        return ".;!?".contains(lastCharacter)
    }


    private var trainButton: some View {
        Button {
            shouldStartInterview = true
        } label: {
            Text("Treinar")
                .frame(maxWidth: .infinity)
            
        }
        .frame(width: 336)
        .buttonStyle(GameButton(height: 50))
        .padding(.bottom, 8)
        .background(.white)
    }


    
}

#Preview {
    NavigationStack {
        JobPostingDetailsView(
            jobPosting: JobPosting(
                title: "UX Designer PL",
                companyName: "iFood",
                jobDescription: """
                Ensino Superior completo ou cursando em Design, Design Digital, Sistemas de Informação, ou áreas relacionadas;
                Experiência com UX/UI e prototipação;
                Conhecimento em ferramentas de design.
                """,
                countInterview: 1
            )
        )
    }
}
