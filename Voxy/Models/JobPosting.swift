//
//  JobPosting.swift
//  Voxy
//
//  Created by Voxy Team on 28/08/26.
//

import Foundation
import SwiftData

@Model
class JobPosting {
    
    var id: UUID
    var title: String
    var jobDescription: String
    var status: PostingStatus
    
    init (id: UUID, title: String, jobDescription: String, status: PostingStatus = .draft) {
        self.id = id
        self.title = title
        self.jobDescription = jobDescription
        self.status = status
    }
}

enum PostingStatus: String, Codable, CaseIterable {
    case draft, saved, simulated
}
