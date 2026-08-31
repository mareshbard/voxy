import Foundation
import AVFoundation
import Combine
import Speech

class InterviewSessionViewModel: NSObject, ObservableObject {
    
    let synthesizer = AVSpeechSynthesizer()
    @Published var isTranscribing = false
    @Published var isSpeaking = false
    @Published var error: Error?
    @Published var transcript: String = ""
    var locale: Locale = .current
    private var resultsTask: Task<Void, Never>?
    private var audioTask: Task<Void, Never>?
    private var audioCapturer: AudioCapturer?
    private var transcriber: Transcriber?
    
    func resetTranscript() {
        transcript = ""
        error = nil
    }
    
    func updateTranscript(with text: String, isFinal: Bool) {
        transcript = text
    }
    
    func speakQuestion() async {
        synthesizer.stopSpeaking(at: .immediate)
        if isTranscribing  {
            await stopTranscription()
        }
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Erro: \(error)")
            }
            let utterance = AVSpeechUtterance(string: "Me conta sobre um projeto de design que você desenvolveu do zero. Como foi o seu processo?")
            utterance.voice = AVSpeechSynthesisVoice(language: "pt-br")
            utterance.rate = 0.53
            synthesizer.speak(utterance)
        
    }
    func startTranscription() async {
        synthesizer.stopSpeaking(at: .immediate)
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
                } catch {
                    await MainActor.run {
                        self?.error = error
                        self?.isTranscribing = false
                        print(error)
                    }
                }
            }

            audioTask = Task {
                for await buffer in audioCapturer.audioStream {
                    transcriber.streamAudio(buffer)
                }
            }
            try await audioCapturer.start()
            await MainActor.run { self.isTranscribing = true }
        } catch {
            await MainActor.run {
                self.error = error
                self.isTranscribing = false
            }
            await stopTranscription()
        }
    }
    
    func stopTranscription() async {
        resultsTask?.cancel()
        audioTask?.cancel()
        await transcriber?.stop()
        await MainActor.run {
            isTranscribing = false
            audioCapturer = nil
        }
    }
    
}
