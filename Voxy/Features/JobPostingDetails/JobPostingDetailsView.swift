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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        
        ZStack(alignment: .top) {
            Color(.systemBackground)
                                .ignoresSafeArea()
            Color("PrimaryBlue")
                .frame(height: 500)
                .ignoresSafeArea(edges: .top)
                ScrollView {
                    VStack(spacing: 0) {
                        header
                           
                        VStack(spacing: 24) {
                            CounterCard(job: jobPosting)
                            descriptionSection
                        }
                        .padding(.horizontal, 26)
                        .padding(.top, 26)
                        .padding(.bottom, 400)
                    }
                    .background(Color(.systemBackground))

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
