//
//  JobPostingFormView.swift
//  Voxy
//
//  Created by Voxy Team on 31/08/26.
//

import SwiftUI
import SwiftData

struct JobPostingFormView: View {
    @Bindable var viewModel: JobPostingFormViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    miaSection

                    jobTitleSection

                    jobImageSection

                    jobDescriptionSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }

            trainButton
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
        }
        .background(Color.white)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }


    private var headerSection: some View {
        HStack {
            Button("Cancelar") {
                dismiss()
            }
            .font(Font.custom("SF Pro", size: 15))
            .foregroundColor(Color(red: 1, green: 0.22, blue: 0.24))

            Spacer()

            Text("Nova vaga")
                .font(
                    Font.custom("Nunito", size: 17)
                        .weight(.semibold)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(
                    Color(red: 0.1, green: 0.1, blue: 0.1)
                )

            Spacer()

            Button("Salvar") {
                do {
                    try viewModel.save()
                    dismiss()
                } catch {
                    print("Erro ao salvar vaga: \(error)")
                }
            }
            .font(Font.custom("SF Pro", size: 15))
            .foregroundColor(Color(red: 0, green: 0.53, blue: 1))
        }
        .padding(.horizontal, 24)
        .padding(.top, 30)
        .padding(.bottom, 12)
    }


    private var miaSection: some View {
        HStack(spacing: 16) {
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: 90, height: 90)
              .background(Color(red: 0.85, green: 0.85, blue: 0.85))

            VStack(alignment: .leading, spacing: 6) {
                Text("Mia diz:")
                  .font(
                    Font.custom("Nunito", size: 11)
                      .weight(.bold)
                  )
                  .kerning(1.1)
                  .foregroundColor(Color(red: 0.33, green: 0.33, blue: 0.33))

                Text("Vamos treinar!")
                  .font(
                    Font.custom("Nunito", size: 19)
                      .weight(.black)
                  )
                  .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))

                Text(
                    "Insira a descrição da vaga em texto ou adicionar um print se preferir!"
                )
                .font(
                    Font.custom("Nunito", size: 13)
                        .weight(.semibold)
                )
                .foregroundColor(
                    Color(red: 0.77, green: 0.77, blue: 0.77)
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .topLeading
                )
            }
            .padding(20)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(.white)
            .clipShape(
                RoundedRectangle(cornerRadius: 24)
            )
        }
    }


    private var jobTitleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOME DA VAGA*")
                .font(
                    Font.custom("Nunito", size: 12)
                        .weight(.bold)
                )
                .kerning(0.72)
                .foregroundColor(
                    Color(
                        red: 0.79,
                        green: 0.79,
                        blue: 0.79
                    )
                )

            TextField(
                "",
                text: $viewModel.title,
                prompt: Text(
                    "Ex: UX Designer Jr., Front-end Dev..."
                )
                .font(
                    Font.custom("Nunito", size: 15)
                        .weight(.bold)
                )
                .foregroundColor(
                    Color(
                        red: 0.51,
                        green: 0.51,
                        blue: 0.51
                    )
                )
            )
            .font(
                Font.custom("Nunito", size: 15)
                    .weight(.bold)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(
                maxWidth: .infinity,
                minHeight: 54
            )
            .background(
                Color(
                    red: 0.96,
                    green: 0.96,
                    blue: 0.96
                )
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 24)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        Color(
                            red: 0.91,
                            green: 0.91,
                            blue: 0.91
                        ),
                        lineWidth: 1.97
                    )
            )
        }
    }


    private var jobImageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PRINT DA VAGA")
                .font(
                    Font.custom("Nunito", size: 12)
                        .weight(.bold)
                )
                .kerning(0.72)
                .foregroundColor(
                    Color(
                        red: 0.79,
                        green: 0.79,
                        blue: 0.79
                    )
                )

            VStack(alignment: .center, spacing: 8) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 27))
                    .foregroundStyle(.black)

                Text("Adicionar imagem")
                    .font(
                        Font.custom("Nunito", size: 14)
                            .weight(.bold)
                    )
                    .multilineTextAlignment(.center)
                    .foregroundColor(
                        Color(
                            red: 0.27,
                            green: 0.27,
                            blue: 0.27
                        )
                    )

                Text("Máx.: 50 MB")
                    .font(
                        Font.custom("Nunito", size: 12)
                            .weight(.semibold)
                    )
                    .multilineTextAlignment(.center)
                    .foregroundColor(
                        Color(
                            red: 0.33,
                            green: 0.33,
                            blue: 0.33
                        )
                    )
            }
            .padding(0)
            .frame(
                maxWidth: .infinity,
                minHeight: 111.99213,
                maxHeight: 111.99213,
                alignment: .center
            )
            .background(
                Color(red: 0.97, green: 0.97, blue: 0.97)
            )
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .inset(by: 0.99)
                    .stroke(
                        Color(red: 0.8, green: 0.8, blue: 0.8),
                        style: StrokeStyle(
                            lineWidth: 1.97234,
                            dash: [3.94468, 1.97234]
                        )
                    )
            )
        }
    }


    private var jobDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DESCRIÇÃO EM TEXTO")
                .font(
                    Font.custom("Nunito", size: 12)
                        .weight(.bold)
                )
                .kerning(0.72)
                .foregroundColor(
                    Color(
                        red: 0.79,
                        green: 0.79,
                        blue: 0.79
                    )
                )

            ZStack(alignment: .topLeading) {
                TextEditor(
                    text: $viewModel.descriptionText
                )
                .font(
                    Font.custom("Nunito", size: 14)
                        .weight(.semibold)
                )
                .scrollContentBackground(.hidden)
                .padding(12)

                if viewModel.descriptionText.isEmpty {
                    Text(
                        "Ou cole aqui o texto da vaga..."
                    )
                    .font(
                        Font.custom("Nunito", size: 14)
                            .weight(.semibold)
                    )
                    .foregroundColor(
                        Color(
                            red: 0.51,
                            green: 0.51,
                            blue: 0.51
                        )
                    )
                    .padding(16)
                    .allowsHitTesting(false)
                }
            }
            .padding(16)
            .frame(
                maxWidth: .infinity,
                minHeight: 100,
                maxHeight: 100,
                alignment: .topLeading
            )
            .background(
                Color(red: 0.96, green: 0.96, blue: 0.96)
            )
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .inset(by: 0.99)
                    .stroke(
                        Color(red: 0.91, green: 0.91, blue: 0.91),
                        lineWidth: 1.97234
                    )
            )
        }
    }


    private var trainButton: some View {
        Button {
            // Treinar agora
        } label: {
            Text("Treinar agora!")
                .font(
                Font.custom("Nunito", size: 17)
                    .weight(.bold)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Color(
                        red: 0.0,
                        green: 0.58,
                        blue: 0.96
                    )
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 28)
                )
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: JobPosting.self,
        configurations: ModelConfiguration(
            isStoredInMemoryOnly: true
        )
    )

    let store = JobPostingStore(
        modelContext: container.mainContext
    )

    let viewModel = JobPostingFormViewModel(
        store: store
    )

    return JobPostingFormPreview(
        viewModel: viewModel
    )
}

private struct JobPostingFormPreview: View {
    let viewModel: JobPostingFormViewModel

    @State private var isPresented = true

    var body: some View {
        Color.gray.opacity(0.15)
            .ignoresSafeArea()
            .sheet(isPresented: $isPresented) {
                JobPostingFormView(
                    viewModel: viewModel
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
    }
}
