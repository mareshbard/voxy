import Foundation
import AVFoundation
import Combine

// marcado para
@MainActor
class InterviewSessionViewModel: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    
    let synthesizer = AVSpeechSynthesizer()
    var speechAnalyzerManager = SpeechAnalyzeManager()
    @Published var isSpeaking = false
    
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    func speakQuestion() async {
        synthesizer.stopSpeaking(at: .immediate)
        if speechAnalyzerManager.isTranscribing  {
            await speechAnalyzerManager.stopTranscription()
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
    
  nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in isSpeaking = true }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,  didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in isSpeaking = false }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in isSpeaking = false }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        Task { @MainActor in isSpeaking = false }
    }
}
