import Speech
import SwiftUI


@MainActor
@Observable
final class SpeechAnalyzeManager {
    
   private(set) var transcript = ""
    private(set) var isTranscribing: Bool = false
    var error: Error?
    
    private let locale = Locale(identifier: "pt-br")
    
    private var finalizedTranscript = ""
    private var volatileTranscript = ""
    private var transcriber: Transcriber?
    private var audioCapturer: AudioCapturer?
    private var audioTask: Task<Void, Never>?
    private var resultsTask: Task<Void, Never>?
    
    func startTranscription() async{
        guard !isTranscribing else { return }
        do {
            resetTranscript()
            let transcriber = try await Transcriber(locale: locale)
            let audioCapturer = AudioCapturer()
            
            self.transcriber = transcriber
            self.audioCapturer = audioCapturer
            
            resultsTask = Task { [weak self] in
                do {
                    for try await result in transcriber.results {
                        let text = String(result.text.characters)
                        
                        await MainActor.run {
                            self?.updateTranscript(with: text, isFinal: result.isFinal)
                        }
                    }
                }
                catch {
                    await MainActor.run {
                        self?.error = error
                        self?.isTranscribing = false
                    }
                }
            }
            
            audioTask = Task {
                for await buffer in audioCapturer.audioStream {
                    transcriber.streamAudio(buffer)
                }
            }
            try await audioCapturer.start()
            isTranscribing = true
        } catch {
            self.error = error
            await stopTranscription()
        }
    }
    func stopTranscription() async {
        audioCapturer?.stop()
        audioTask?.cancel()
        resultsTask?.cancel()
        
        await transcriber?.stop()
        
        audioCapturer = nil
        transcriber = nil
        audioTask = nil
        resultsTask = nil
        isTranscribing = false
        
    }
    
    private func resetTranscript() {
        finalizedTranscript = ""
        volatileTranscript = ""
        transcript = ""
    }
    
    private func updateTranscript(with text: String, isFinal: Bool) {
        if isFinal {
            appendFinalTranscript(text)
            volatileTranscript = ""
        } else {
            volatileTranscript = text
        }
        transcript = [finalizedTranscript, volatileTranscript]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    private func appendFinalTranscript(_ text: String) {
        guard !text.isEmpty else { return }
        if finalizedTranscript.isEmpty {
            finalizedTranscript = text
        } else {
            finalizedTranscript += " " + text
        }
    }
}
