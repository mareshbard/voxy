import Speech
import SwiftUI


@MainActor
@Observable
final class SpeechAnalyzeManager {
    
    var transcript = ""
    private var transcriber: Transcriber?
    var showMicDeniedAlert = false
    private(set) var isTranscribing: Bool = false
    private(set) var speechPermissionDenied: Bool = false
    private(set) var microphonePermissionDenied: Bool = false
    var error: Error?
    
    private let locale = Locale(identifier: "pt-br")
    
    private var finalizedTranscript = ""
    private var volatileTranscript = ""
    private var audioCapturer: AudioCapturer?
    private var audioTask: Task<Void, Never>?
    private var resultsTask: Task<Void, Never>?
    
    func startTranscription() async {
        guard !isTranscribing else { return }

        speechPermissionDenied = false
        microphonePermissionDenied = false
        error = nil

        let speechStatus = await requestSpeechPermission()
        guard speechStatus == .authorized else {
            speechPermissionDenied = true
            return
        }
       // let microphoneStatus = await request()
        

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
                        //print(text)
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
        } catch AudioCapturer.AudioCapturerError.permissionDenied {
            microphonePermissionDenied = true
            showMicDeniedAlert = true
            await stopTranscription()
        } catch {
            self.error = error
            await stopTranscription()
        }
    }
    func stopTranscription() async {
        audioCapturer?.stop()
        await audioTask?.value // espera os buffers eram pra transcritor
        await transcriber?.stop() // finaliza processando oq sobrou
        await resultsTask?.value // espera o loop ler o resultado final
        
        audioCapturer = nil
        transcriber = nil
        audioTask = nil
        resultsTask = nil
        isTranscribing = false
        
        print(transcript)
        
    }
    
    func resetTranscript() {
        finalizedTranscript = ""
        volatileTranscript = ""
        transcript = ""
    }

    private func requestSpeechPermission() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
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
