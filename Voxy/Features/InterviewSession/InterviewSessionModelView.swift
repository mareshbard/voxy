import Foundation
import AVFoundation

// marcado para
@MainActor
@Observable
class InterviewSessionViewModel: NSObject, AVSpeechSynthesizerDelegate {
    
    let synthesizer = AVSpeechSynthesizer()
    var speechAnalyzerManager = SpeechAnalyzeManager()
    var isSpeaking = false
    var elapsedSeconds: Int = 0
    private var timerTask: Task<Void, Never>?
    
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
    
    var formattedTime: String {
        String(format: "%02d:%02d", elapsedSeconds / 60, elapsedSeconds % 60)
    }
    
    func startTimer() {
        // cancela timer antigo
        timerTask?.cancel()
        // zerando contador
        elapsedSeconds = 0
        // tarefa assíncrona que roda em paralelo (referencia guardada em timerTask p/ poder cancelar depois)
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { break }
                self?.elapsedSeconds += 1
            }
        }
    }
    
    func stopTimer(){
        timerTask?.cancel()
        timerTask = nil
    }
}
