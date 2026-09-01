import AVFAudio

// nonisolated: não precisa usar o await pois não é algo ligado a um state mutável
nonisolated final class AudioCapturer {
    enum AudioCapturerError: Error {
        case permissionDenied
        case unknownPermission
        case inputUnavailable
    }
    
    let audioStream: AsyncStream<AVAudioPCMBuffer>
    
    private let audioEngine = AVAudioEngine()
    private let continuation: AsyncStream<AVAudioPCMBuffer>.Continuation
    private let bufferSize: AVAudioFrameCount = 1024
    
    init() {
        (audioStream, continuation) = AsyncStream.makeStream(of: AVAudioPCMBuffer.self)
    }
    
    func start() async throws {
        // PEDINDO PERMISSAO PARA GRAVAR AUDIO
        try await requestPermission()
        // CONECTANDO COM O HARDWARE DO MICROFONE
        let inputNode = audioEngine.inputNode
        // VERIFICANDO FORMATO DO ÁUDIO
        let format = inputNode.outputFormat(forBus: 0)
        //RECEBENDO RESULTADO E CHECANDO
        guard format.sampleRate > 0, format.channelCount > 0 else {
            throw AudioCapturerError.inputUnavailable
        }
        // REMOVE TAP ANTERIOR, EVITANDO DUPLICAÇÕES
        inputNode.removeTap(onBus: 0)
        // CHAMADO SEMPRE QUE O MICROFONE CAPTURA UM NOVO PEDAÇO DE AUDIO
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: format) { [continuation] buffer, _ in
            continuation.yield(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    private func requestPermission() async throws {
        switch AVAudioApplication.shared.recordPermission {
        case .undetermined:
            guard await AVAudioApplication.requestRecordPermission() else {
                throw AudioCapturerError.permissionDenied
            }
        case .denied:
            
            throw AudioCapturerError.permissionDenied
        case .granted:
            return
        @unknown default:
            throw AudioCapturerError.unknownPermission
        }
    }
}
