//
//  Untitled.swift
//  Voxy
//
//  Created by Voxy Team on 28/08/26.
//

import Foundation
import SwiftData

// assina com @Model - class que represeta o obejto "vaga" que será persistido
@Model
final class JobPosting {
    var title: String
    var descriptionText: String?
    var countInterview: Int

    init(
        title: String,
        descriptionText: String? = nil,
        countInterview: Int = 0
    ) {
        self.title = title
        self.descriptionText = descriptionText
        self.countInterview = countInterview
    }
}
