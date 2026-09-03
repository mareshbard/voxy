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

    init(
        title: String,
        companyName: String,
        jobDescription: String,
        status: PostingStatus = .saved,
        countInterview: Int = 0
    ) {
        self.title = title
        self.companyName = companyName
        self.jobDescription = jobDescription
        self.status = status
        self.countInterview = countInterview
    }
}

enum PostingStatus: String, Codable {
    case saved, simulated
}
