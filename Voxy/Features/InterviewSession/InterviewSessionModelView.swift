import Foundation
import SwiftUI
import AVFoundation

@MainActor
@Observable

class InterviewSessionViewModel: NSObject, AVSpeechSynthesizerDelegate {

    private var feedbackEngine: FeedbackEngineProtocol
    var feedbacks: [AnswerFeedback] = []
    var isGeneratingFeedback: Bool = false
    var finalFeedback: String = ""
    var responses: String = ""
    let synthesizer = AVSpeechSynthesizer()
    var speechAnalyzerManager = SpeechAnalyzeManager()
    var isSpeaking = false
    var elapsedSeconds: Int = 0
    private var timerTask: Task<Void, Never>?
    var goToFeedback: Bool = false
    var questions: [String]
    var currentIndex: Int = 0
    var currentQuestion: String {
        questions[currentIndex]
    }
    var isTranscribing: Bool {
        speechAnalyzerManager.isTranscribing
    }
    var showMicPermissionAlert: Bool {
        get { speechAnalyzerManager.showMicDeniedAlert }
        set { speechAnalyzerManager.showMicDeniedAlert = newValue}
    }
    var canGoToNextQuestion: Bool {
        elapsedSeconds < 10 || speechAnalyzerManager.isTranscribing
    }
    
    var restartConfirmation: Bool = false
    
    init(questions: [String], feedbackEngine: FeedbackEngineProtocol) {
        self.questions = questions
        self.feedbackEngine = feedbackEngine
        super.init()
        synthesizer.delegate = self
    }
    var lastQuestion: Bool {
        currentIndex == questions.count - 1
    }
    
    func resetTranscript() {
        speechAnalyzerManager.resetTranscript()
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
        let utterance = AVSpeechUtterance(string: currentQuestion)
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
    
    func record() async {
        if speechAnalyzerManager.isTranscribing {
            await speechAnalyzerManager.stopTranscription()
            stopTimer()
        } else {
            synthesizer.stopSpeaking(at: .immediate)
            await speechAnalyzerManager.startTranscription()
            startTimer()
        }
    }
    
    func restartTranscript() {
        resetTranscript()
        elapsedSeconds = 0
        stopTimer()
    }
    
    func advance () async {
        await finishCurrentQuestion()
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            elapsedSeconds = 0
            stopTimer()
            resetTranscript()
        } else {
            finalFeedback = buildFeedbackString()
            goToFeedback = true
            print(responses)
            
        }
        //        saveResponse(response: speechAnalyzerManager.transcript)
    }
    
    private func buildFeedbackString() -> String {
        feedbacks.enumerated().map { index, fb in
            """
            Pergunta \(index + 1)
            Nota de articulação: \(fb.articulationScore) / \(fb.articulationNotes)
                    Vícios de linguagem: \(fb.languageVices.joined(separator: ", "))
                    Pontos fortes: \(fb.technicalStrengths.joined(separator: ", "))
                    A melhorar: \(fb.technicalGaps.joined(separator: ", "))
                    Resumo: \(fb.summary)
            
            """
        }
        .joined(separator: "\n\n")
    }
    
    func checkingReset() async {
        if elapsedSeconds >= 10 && !speechAnalyzerManager.isTranscribing {
            restartConfirmation = true
        } else {
            await record()
        }
    }
    
    func saveResponse(response: String) {
        responses += response
    }
    
    func  finishCurrentQuestion() async {
        let question = currentQuestion
        let answer = speechAnalyzerManager.transcript
        
        guard !answer.isEmpty else { return }
        
        isGeneratingFeedback = true
        defer { isGeneratingFeedback = false }
        do {
            let feedback = try await feedbackEngine.evaluate(question: question, answer: answer)
            print(feedback)
        } catch {
            print("Erro ao gerar feedback")
        }
        
    }
}
