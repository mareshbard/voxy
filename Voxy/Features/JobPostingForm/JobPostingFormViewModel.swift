//
//  JobPostingFormViewModel.swift
//  Voxy
//
//  Created by Voxy Team on 31/08/26.
//

import Foundation
import Observation
import PhotosUI
import _PhotosUI_SwiftUI

@MainActor
@Observable
final class JobPostingFormViewModel {
    var title = ""
    var descriptionText = ""

    var selectedPhoto: PhotosPickerItem?
    var imageData: Data?

    private let store: JobPostingStore

    init(store: JobPostingStore) {
        self.store = store
    }

    func loadSelectedPhoto() async {
        guard let selectedPhoto else {
            return
        }

        do {
            imageData = try await selectedPhoto.loadTransferable(
                type: Data.self
            )
        } catch {
            print("Erro ao carregar imagem: \(error)")
        }
    }

    func save() throws {
        let trimmedDescription = descriptionText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let description: String? =
            trimmedDescription.isEmpty ? nil : trimmedDescription

        let jobPosting = JobPosting(
            title: title,
            descriptionText: description
        )

        try store.save(jobPosting)
    }
}
