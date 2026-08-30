import Foundation
import Observation

@MainActor
@Observable
final class JobPostingViewModel {
    var title = ""
    var jobDescription = ""
    var isRecognizing = false
    var errorMessage: String?

    private let textRecognitionService: TextRecognitionServiceProtocol

    init(textRecognitionService: TextRecognitionServiceProtocol? = nil) {
        self.textRecognitionService = textRecognitionService ?? VisionTextRecognitionService()
    }

    func importRequirements(from imageData: Data) async {
        isRecognizing = true
        errorMessage = nil
        defer { isRecognizing = false }

        do {
            let text = try await textRecognitionService.recognizeText(from: imageData)
            if text.isEmpty {
                errorMessage = "Nao foi possivel encontrar texto na imagem."
            } else {
                jobDescription = text
            }
        } catch {
            errorMessage = "Nao foi possivel ler a imagem."
        }
    }
}
