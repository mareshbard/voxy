import Foundation
import AVFoundation
import Combine

class InterviewSessionViewModel: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    
    func speakQuestion() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Erro: \(error)")
        }
        let utterance = AVSpeechUtterance(string: "Me conta sobre um projeto de design que você desenvolveu do zero. Como foi o seu processo?")
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-br")
        utterance.rate = 0.53
        synthesizer.speak(utterance)
    }
}

