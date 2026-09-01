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
    var descriptionText: String
    var countInterview: Int

    init(
        title: String,
        companyName: String,
        descriptionText: String,
        countInterview: Int = 0
    ) {
        self.title = title
        self.companyName = companyName
        self.descriptionText = descriptionText
        self.countInterview = countInterview
    }
}

enum PostingStatus: String, Codable {
    case saved, simulated
}
