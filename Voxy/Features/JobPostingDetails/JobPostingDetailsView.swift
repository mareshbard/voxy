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
    // Inicia o fluxo de entrevista pela pilha da lista (permite voltar à raiz).
    var onStartInterview: () -> Void = {}

    @State private var shouldEditJobPosting = false
    @State private var isFeedbackExpanded = true

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        
        ZStack(alignment: .top) {
            Color("VoxyBackground")
                .ignoresSafeArea()

            Color("PrimaryBlue")
                .frame(height: 300)
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(spacing: 0) {
                    header
                       
                    VStack(spacing: 24) {
                        CounterCard(job: jobPosting)
                        descriptionSection

                        if jobPosting.feedback != nil {
                            lastFeedbackHeader
                        }
                    }
                    .padding(.horizontal, 26)
                    .padding(.top, 26)
                    .padding(.bottom, jobPosting.feedback == nil ? 400 : 0)
                    .background(Color("VoxyBackground"))

                    if let feedback = jobPosting.feedback,
                       isFeedbackExpanded {
                        lastFeedbackSection(feedback)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .toolbar(.hidden, for: .tabBar)
            .ignoresSafeArea(edges: .top)
            .safeAreaInset(edge: .bottom) {
                trainButton
            }
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
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .accessibilityLabel(Text("Voltar"))
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Editar") {
                    shouldEditJobPosting = true
                }
            }
        }
        .tint(Color("IconPrimaryColor"))
    }


    private var header: some View {
        ZStack {
            Color("PrimaryBlue")

            VStack(spacing: 6) {
                Text(jobPosting.title)
                    .font(.custom("Satoshi-Black", size: 30))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .frame(width: 242, alignment: .top)

                Text(jobPosting.companyName)
                    .font(.custom("Nunito-Bold", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .top)
            }
            .padding(.top, 110)
            .padding(.bottom, 20)
        }
       // .frame(height: 234)
    }


    private var trainingCountCard: some View {
        CounterCard(job: jobPosting)

    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("DESCRIÇÃO DA VAGA")
                .font(.custom("Satoshi-Bold", size: 16))
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
                            .font(.custom("Nunito-Bold", size: 16))
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


    private var lastFeedbackHeader: some View {
        Button {
            withAnimation {
                isFeedbackExpanded.toggle()
            }
        } label: {
            HStack {
                Text("ÚLTIMO FEEDBACK")
                    .font(.custom("Satoshi-Bold", size: 16))
                    .kerning(0.72)
                    .foregroundStyle(Color("PrimaryFontColor"))

                Spacer()

                Image(systemName: "chevron.down")
                    .rotationEffect(
                        .degrees(isFeedbackExpanded ? 0 : -90)
                    )
                    .foregroundStyle(Color("PrimaryFontColor"))
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }


    private func lastFeedbackSection(
        _ feedback: InterviewFeedbackRecord
    ) -> some View {
        VStack(spacing: 26) {
            FeedbackSection(
                title: "CLAREZA",
                items: feedback.clarity,
                highlighted: true
            )

            FeedbackSection(
                title: "VÍCIOS",
                items: feedback.vicios,
                highlighted: true
            )

            FeedbackSection(
                title: "PROFUNDIDADE",
                items: feedback.profundity,
                highlighted: true
            )

            bestMomentsSection(feedback.bestMoments)

            improveSection(feedback.improve)
        }
        .padding(.horizontal, 26)
        .padding(.top, 16)
        .padding(.bottom, 140)
        .background(Color("VoxyBackground"))
    }
    
    @ViewBuilder
    private func bestMomentsSection(_ items: [String]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("MELHORES MOMENTOS")
                    .font(.custom("Nunito", size: 16))
                    .bold()
                    .foregroundStyle(Color("PrimaryFontColor"))

                feedbackItemsWithMascot(
                    items,
                    imageName: "MiaFeedbackLike",
                    imageOnLeadingSide: true
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func improveSection(_ items: [String]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("ONDE MELHORAR")
                    .font(.custom("Nunito", size: 16))
                    .bold()
                    .foregroundStyle(Color("PrimaryFontColor"))

                feedbackItemsWithMascot(
                    items,
                    imageName: "MiaFeedbackClipboard",
                    imageOnLeadingSide: false
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func feedbackItemsWithMascot(
        _ items: [String],
        imageName: String,
        imageOnLeadingSide: Bool
    ) -> some View {
        let mascotItems = Array(items.prefix(2))
        let remainingItems = Array(items.dropFirst(2))

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                if imageOnLeadingSide {
                    mascotImage(imageName)
                }

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(mascotItems.enumerated()), id: \.offset) { _, item in
                        feedbackItem(item)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if !imageOnLeadingSide {
                    mascotImage(imageName)
                }
            }

            ForEach(Array(remainingItems.enumerated()), id: \.offset) { _, item in
                feedbackItem(item)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func feedbackItem(_ item: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.bg)
                .frame(width: 10, height: 10)
                .padding(.top, 5)

            Text(item)
                .font(.custom("Nunito", size: 16))
                .bold()
                .foregroundStyle(Color("SecondaryFontColor"))
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func mascotImage(_ imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 150)
            .accessibilityHidden(true)
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
            onStartInterview()
        } label: {
            Text("Treinar")
                .frame(maxWidth: .infinity)
            
        }
        .frame(width: 336)
        .buttonStyle(BlueGameButton())
        .padding(.bottom, 8)
    }
}

#Preview {
    let jobPosting = JobPosting(
        title: "UX Designer PL",
        companyName: "iFood",
        jobDescription: """
        Ensino Superior completo ou cursando em Design, Design Digital, Sistemas de Informação, ou áreas relacionadas;
        Experiência com UX/UI e prototipação;
        Conhecimento em ferramentas de design.
        """,
        countInterview: 1
    )

    jobPosting.feedback = InterviewFeedbackRecord(
        improve: [
            "Apresentar exemplos mais específicos.",
            "Aprofundar as decisões tomadas nos projetos."
        ],
        bestMoments: [
            "Boa explicação sobre experiência com prototipagem.",
            "Boa relação entre experiência e requisitos da vaga."
        ],
        clarity: [
            "Respostas claras e bem estruturadas.",
            "Boa organização das ideias."
        ],
        vicios: [
            "Evitar repetição de algumas expressões.",
            "Reduzir o uso de vícios de linguagem."
        ],
        profundity: [
            "Boa relação entre experiência e requisitos da vaga.",
            "Aprofundar exemplos técnicos."
        ]
    )

    return NavigationStack {
        JobPostingDetailsView(
            jobPosting: jobPosting
        )
    }
}
