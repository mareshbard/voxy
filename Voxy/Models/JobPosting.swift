//
//  JobPosting.swift
//  Voxy
//
//  Created by Voxy Team on 28/08/26.
//
import Foundation
import SwiftData

@Model
final class JobPosting {
    var title: String
    var companyName: String
    var jobDescription: String
    var status: PostingStatus
    var countInterview: Int
    var lastSimulated: Date
    var feedback: InterviewFeedbackRecord?
    /// Perguntas já geradas para esta vaga em treinos anteriores. Uso interno
    /// (não exibido ao usuário): serve para evitar que uma mesma pergunta se
    /// repita entre sessões diferentes da mesma vaga.
    var askedQuestions: [String] = []
    init(
        title: String,
        companyName: String,
        jobDescription: String,
        status: PostingStatus = .saved,
        countInterview: Int = 0,
        lastSimulated: Date = .now,
        askedQuestions: [String] = []
    ) {
        self.title = title
        self.companyName = companyName
        self.jobDescription = jobDescription
        self.status = status
        self.countInterview = countInterview
        self.lastSimulated = lastSimulated
        self.askedQuestions = askedQuestions
    }
}

enum PostingStatus: String, Codable {
    case saved, simulated
}

@Model
final class InterviewFeedbackRecord {
    var improve: [String]
    var bestMoments: [String]
    var clarity: [String]
    var vicios: [String]
    var profundity: [String]

    init(improve: [String], bestMoments: [String], clarity: [String], vicios: [String], profundity: [String]) {
        self.improve = improve
        self.bestMoments = bestMoments
        self.clarity = clarity
        self.vicios = vicios
        self.profundity = profundity
    }
}
