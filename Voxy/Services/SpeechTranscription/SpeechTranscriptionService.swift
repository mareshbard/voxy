import AVFAudio
import Speech

final class Transcriber {
    enum TranscriberError: Error {
        case notAvailable
        case localeNotSupported
        case audioConverterCreationFailed
        case bufferConversionFailed(String?)
    }
    
    let results: SpeechTranscriber.Results
    
    private let analyzer: SpeechAnalyzer
    private let transcriber: SpeechTranscriber
    private let inputStream: AsyncStream<AnalyzerInput>
    private let inputContinuation: AsyncStream<AnalyzerInput>.Continuation
    
    // FORMATO USADO PELO TRANSCRIBER, SE FOR OUTRO O BUFFER SERÁ CONVERTIDO ANTES DE SER ENVIADO
    private let inputFormat: AVAudioFormat?
    private var audioConverter: AVAudioConverter?
    
    init(locale: Locale = Locale.current) async throws {
        
        guard SpeechTranscriber.isAvailable else {
            throw TranscriberError.notAvailable
        }
        
        // CHECA SE TÁ DISPONIVEL O IDIOMA PEDIDO
        guard let supportedLocale = await SpeechTranscriber.supportedLocale(equivalentTo: locale) else {
            throw TranscriberError.localeNotSupported
        }
        // TRANSCRICAO DE FALA AO VIVO
        transcriber = SpeechTranscriber(locale: supportedLocale, preset: .timeIndexedProgressiveTranscription)
        results = transcriber.results
       // print(results)
        // CRIANDO ANALISADOR APENAS COM O MÓDULO DE TRANSCRIÇÃO
        analyzer = SpeechAnalyzer(modules: [transcriber])
        
        // BAIXA RECURSOS DE FALA NECESSÁRIOS PARA O IDIOMA, CASO NÃO TENHA
        if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
            try await request.downloadAndInstall()
        }
        
        // ANALISA QUAL É O FORMATO DA ENTRADA
        inputFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber])
        
        (inputStream, inputContinuation) = AsyncStream.makeStream(of: AnalyzerInput.self)
        
        // COMEÇA A CONSUMIR A ENTRADA DO MICROFONE
        try await analyzer.prepareToAnalyze(in: inputFormat)
        try await analyzer.start(inputSequence: inputStream)
    }
    
    deinit {
        inputContinuation.finish()
    }
    func streamAudio(_ buffer: AVAudioPCMBuffer) {
        do {
            // TENTA CONVERTER P/ FORMATO NECESSÁRIO
            let convertedBuffer = try convert(buffer)
            inputContinuation.yield(AnalyzerInput(buffer: convertedBuffer))
        } catch {
            print("Conversão de áudio falhou \(error)")
        }
    }
     
    func stop() async {
        // fecha o canal de entrada e encerra sessão de análise
        inputContinuation.finish()
        await analyzer.cancelAndFinishNow()
    }
    
    private func convert(_ buffer: AVAudioPCMBuffer) throws -> AVAudioPCMBuffer {
        guard let inputFormat, buffer.format != inputFormat else {
            return buffer
        }
        
        if audioConverter == nil || audioConverter?.inputFormat != buffer.format || audioConverter?.outputFormat != inputFormat {
            audioConverter = AVAudioConverter(from: buffer.format, to: inputFormat)
            audioConverter?.primeMethod = .none
        }
        guard let audioConverter else {
            throw TranscriberError.audioConverterCreationFailed
        }
        
        let ratio = audioConverter.outputFormat.sampleRate / audioConverter.inputFormat.sampleRate
        let capacity = AVAudioFrameCount((Double(buffer.frameLength) * ratio).rounded(.up))
        
        guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: audioConverter.outputFormat, frameCapacity: capacity) else {
            throw TranscriberError.bufferConversionFailed("Não foi possível criar o buffer de saída")
        }
        
        var nsError: NSError?
        var didProvideInput = false
        
        let status = audioConverter.convert(to: convertedBuffer, error: &nsError) { _, status in
            if didProvideInput {
                status.pointee = .noDataNow
                return nil
            }
            
            didProvideInput = true
            status.pointee = .haveData
            return buffer
        }
        guard status != .error else {
            throw TranscriberError.bufferConversionFailed(nsError?.localizedDescription)
        }
        return convertedBuffer
    }
    
}
