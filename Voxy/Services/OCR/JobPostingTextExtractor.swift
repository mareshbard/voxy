import Foundation
import UIKit
import Vision

protocol TextRecognitionServiceProtocol {
    func recognizeText(from imageData: Data) async throws -> String
}

final class VisionTextRecognitionService: TextRecognitionServiceProtocol {
    enum OCRError: Error {
        case invalidData
    }

    func recognizeText(from imageData: Data) async throws -> String {
        guard let uiImage = UIImage(data: imageData),
              let cgImage = uiImage.cgImage else {
            throw OCRError.invalidData
        }

        var request = RecognizeTextRequest()
        request.recognitionLanguages = [.init(identifier: "pt-BR")]

        let handler = ImageRequestHandler(cgImage)
        let observations = try await handler.perform(request)

        return observations
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n")
    }
}
