//
//  JobPostingListView.swift
//  Voxy
//
//  Created by Voxy Team on 31/08/26.
//

import SwiftUI
import SwiftData

struct JobPostingListView: View {
    @Bindable var viewModel: JobPostingListViewModel

    var body: some View {
        ZStack {
            Color(
                red: 241 / 255,
                green: 241 / 255,
                blue: 241 / 255
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection

                ScrollView {
                    VStack(spacing: 24) {
                        miaSection

                        statsSection

                        jobsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }
                
                tabBar
                    .padding(.bottom, 12)
            }
        }
        .task {
            viewModel.loadJobPostings()
        }
    }


    private var headerSection: some View {
        ZStack {
            Text("Histórico de vagas")
                .font(
                    Font.custom("Nunito", size: 16)
                        .weight(.bold)
                )
                .foregroundStyle(
                    Color(
                        red: 0.38,
                        green: 0.38,
                        blue: 0.38
                    )
                )

            HStack {
                backButton

                Spacer()

                addButton
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .padding(.top, 10)
    }

    private var backButton: some View {
        Button {
            print("voltar")
        } label: {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.65))

                Circle()
                    .fill(
                        Color(
                            red: 0.87,
                            green: 0.87,
                            blue: 0.87
                        )
                    )
                    .blendMode(.colorBurn)

                Circle()
                    .fill(
                        Color(
                            red: 0.97,
                            green: 0.97,
                            blue: 0.97
                        )
                    )
                    .blendMode(.darken)

                Circle()
                    .fill(.black.opacity(0.01))

                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(
                        Color(
                            red: 0.1,
                            green: 0.1,
                            blue: 0.1
                        )
                    )
                    .blendMode(.plusDarker)
            }
            .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }

    private var addButton: some View {
        Button {
            print("adicionar")
        } label: {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.65))

                Circle()
                    .fill(
                        Color(
                            red: 0.87,
                            green: 0.87,
                            blue: 0.87
                        )
                    )
                    .blendMode(.colorBurn)

                Circle()
                    .fill(
                        Color(
                            red: 0.97,
                            green: 0.97,
                            blue: 0.97
                        )
                    )
                    .blendMode(.darken)

                Circle()
                    .fill(.black.opacity(0.01))

                Image(systemName: "plus")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(
                        Color(
                            red: 0.1,
                            green: 0.1,
                            blue: 0.1
                        )
                    )
                    .blendMode(.plusDarker)
            }
            .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
    }


    private var miaSection: some View {
        HStack(alignment: .top, spacing: 16) {
            Rectangle()
            
                .fill(
                    Color(
                        red: 0.85,
                        green: 0.85,
                        blue: 0.85
                    )
                )
                .frame(width: 90, height: 90)
            

            VStack(alignment: .leading, spacing: 8) {
                Text("MIA DIZ:")
                    .font(
                        Font.custom("Nunito", size: 11)
                            .weight(.bold)
                            
                    )
                    .kerning(1.1)
                    .foregroundStyle(
                        Color(
                            red: 0.33,
                            green: 0.33,
                            blue: 0.33
                        )
                    )

                Text("Esse é seu histórico de vagas. Escolha uma e tente novamente!")
                    .font(
                    Font.custom("Nunito", size: 13)
                    .weight(.semibold)
                    )
                    .foregroundColor(Color(red: 0.77, green: 0.77, blue: 0.77))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.white)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 24
                )
            )
        }
    }


    private var statsSection: some View {
        HStack(spacing: 12) {
            statCard(
                title: "OFENSIVA",
                value: "3",
                subtitle: "dias"
            )

            statCard(
                title: "RECORDE",
                value: "15",
                subtitle: "dias"
            )

            statCard(
                title: "TOTAL",
                value: "15",
                subtitle: "sessões"
            )
        }
    }

    private func statCard(
        title: String,
        value: String,
        subtitle: String
    ) -> some View {
        VStack(spacing: 4) {
            Text(title)
              .font(
                Font.custom("Nunito", size: 11)
                  .weight(.bold)
              )
              .kerning(1.1)
              .foregroundColor(Color(red: 0.33, green: 0.33, blue: 0.33))

            Text(value)
              .font(
                Font.custom("Nunito", size: 19)
                  .weight(.black)
              )
              .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))

            Text(subtitle)
              .font(
                Font.custom("Nunito", size: 13)
                  .weight(.semibold)
              )
              .multilineTextAlignment(.center)
              .foregroundColor(Color(red: 0.77, green: 0.77, blue: 0.77))
              .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )
    }


    private var jobsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("VAGAS")
              .font(
                Font.custom("Nunito", size: 12)
                  .weight(.bold)
              )
              .kerning(0.72)
              .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.45))

            VStack(spacing: 0) {
                if viewModel.jobPostings.isEmpty {
                    emptyState
                } else {
                    ForEach(
                        viewModel.jobPostings,
                        id: \.persistentModelID
                    ) { jobPosting in
                        jobRow(jobPosting)

                        if jobPosting.persistentModelID !=
                            viewModel.jobPostings.last?.persistentModelID {
                            Divider()
                                .padding(.leading, 74)
                        }
                    }
                }
            }
            .background(.white)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 24
                )
            )
        }
    }

    private func jobRow(
        _ jobPosting: JobPosting
    ) -> some View {
        Button {
            print("card")
        } label: {
            HStack(spacing: 12) {
                RoundedRectangle(
                    cornerRadius: 14
                )
                .fill(
                    Color(
                        red: 0.9,
                        green: 0.9,
                        blue: 0.9
                    )
                )
                .frame(width: 50, height: 50)

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text(jobPosting.title)
                        .font(Font.custom("SF Pro Display", size: 17))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.12))

                    HStack(spacing: 6) {
                        Text(jobPosting.companyName)
                            .font(Font.custom("SF Pro Display", size: 17))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.12))


                        Text("Ontem, 10h15")
                            .font(
                                Font.custom("SF Pro Display", size: 15)
                            )
                            .foregroundColor(
                                Color(
                                    red: 0.43,
                                    green: 0.43,
                                    blue: 0.45
                                )
                            )
                    }
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("\(jobPosting.countInterview)")
                        .font(
                        Font.custom("Nunito", size: 24)
                        .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.45))

                    Text("treinos")
                        .font(Font.custom("Nunito", size: 14))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.45))

                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        Text("Nenhuma vaga cadastrada.")
            .font(
                Font.custom("Nunito", size: 14)
                    .weight(.semibold)
            )
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
    }
    
    private var tabBar: some View {
        HStack(spacing: 0) {

            Button {
                print("Início")
            } label: {
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                        .frame(width: 28, height: 28)
                        .rotationEffect(.degrees(45))

                    Text("Início")
                        .font(
                            Font.custom("SF Pro Display", size: 12)
                                .weight(.semibold)
                        )
                        .foregroundStyle(
                            Color(red: 0.1, green: 0.1, blue: 0.1)
                        )
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)

            Button {
                print("Histórico")
            } label: {
                VStack(spacing: 6) {
                    Circle()
                        .fill(
                            Color(
                                red: 217 / 255,
                                green: 76 / 255,
                                blue: 99 / 255
                            )
                        )
                        .frame(width: 24, height: 24)

                    Text("Histórico")
                        .font(
                            Font.custom("SF Pro Display", size: 12)
                                .weight(.semibold)
                        )
                        .foregroundStyle(
                            Color(
                                red: 217 / 255,
                                green: 76 / 255,
                                blue: 99 / 255
                            )
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(
                            Color(
                                red: 237 / 255,
                                green: 237 / 255,
                                blue: 237 / 255
                            )
                        )
                )
            }
            .buttonStyle(.plain)

            Button {
                print("Conquistas")
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            Color(red: 0.1, green: 0.1, blue: 0.1)
                        )

                    Text("Conquistas")
                        .font(
                            Font.custom("SF Pro Display", size: 12)
                                .weight(.semibold)
                        )
                        .foregroundStyle(
                            Color(red: 0.1, green: 0.1, blue: 0.1)
                        )
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .frame(width: 302, height: 62)
        .background(
            Capsule()
                .fill(.white.opacity(0.65))
        )
        .shadow(
            color: .black.opacity(0.12),
            radius: 20,
            x: 0,
            y: 8
        )
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
                companyName: "Nubank",
                descriptionText: "Vaga para UX Designer",
                countInterview: 8
            )
        )

        context.insert(
            JobPosting(
                title: "iOS Developer Jr.",
                companyName: "Apple",
                descriptionText: "Vaga para desenvolvimento iOS",
                countInterview: 3
            )
        )

        context.insert(
            JobPosting(
                title: "Product Designer",
                companyName: "Uber",
                descriptionText: "Vaga para Product Designer",
                countInterview: 6
            )
        )
    }()

    let store = JobPostingStore(
        modelContext: context
    )

    let viewModel = JobPostingListViewModel(
        store: store
    )

    return JobPostingListView(
        viewModel: viewModel
    )
    .modelContainer(container)
}
