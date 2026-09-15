# Voxy — Vision (OCR) e FoundationModels

Guia de apresentação sobre as duas tecnologias de IA on-device que o Voxy usa:
**Vision** (para ler a vaga de uma imagem) e **FoundationModels** (para gerar
perguntas e avaliar as respostas). Tudo roda **no dispositivo**, sem servidor.

---

## Visão geral do fluxo (ponta a ponta)

```
┌─────────────┐   Vision (OCR)     ┌──────────────┐  FoundationModels   ┌──────────────┐
│  Foto da    │ ─────────────────► │  Descrição   │ ──────────────────► │  6 perguntas │
│  vaga (img) │  texto reconhecido │  da vaga     │  geração guiada     │  de entrevista│
└─────────────┘                    └──────────────┘                     └──────┬───────┘
                                                                               │
                                                                               ▼
┌──────────────┐   FoundationModels  ┌──────────────┐   Speech (voz→texto) ┌──────────────┐
│  Feedback    │ ◄────────────────── │  Respostas   │ ◄─────────────────── │  Entrevista  │
│  final       │  avaliação guiada   │  transcritas │   transcrição        │  (usuário fala)│
└──────────────┘                     └──────────────┘                      └──────────────┘
```

1. **Vision** transforma a imagem da vaga em texto (a descrição).
2. **FoundationModels** usa cargo + descrição para gerar **6 perguntas**.
3. O usuário responde falando; a fala vira texto (Speech).
4. **FoundationModels** avalia cada resposta e depois consolida um **feedback final**.

Os dois pilares desta apresentação são os passos **1** e **2/4**.

---

# Parte 1 — Vision (OCR)

## O que é
**Vision** é o framework de visão computacional da Apple. Entre outras coisas,
ele faz **OCR** (reconhecimento óptico de caracteres): dada uma imagem, devolve
o texto contido nela. No Voxy, isso permite o usuário **tirar uma foto / escolher
o print de uma vaga** e importar a descrição automaticamente, sem digitar.

> Importante: usamos a **API nova de Vision em Swift** (iOS 18+), baseada em
> `RecognizeTextRequest` e `ImageRequestHandler` com `async/await` — e **não** a
> API antiga (`VNRecognizeTextRequest` + `VNImageRequestHandler` com completion
> handlers). A API nova é mais enxuta, tipada e integrada ao Swift Concurrency.

## Onde fica no código
`Voxy/Services/OCR/JobPostingTextExtractor.swift`

```swift
import Vision

protocol TextRecognitionServiceProtocol {
    func recognizeText(from imageData: Data) async throws -> String
}

final class VisionTextRecognitionService: TextRecognitionServiceProtocol {
    enum OCRError: Error { case invalidData }

    func recognizeText(from imageData: Data) async throws -> String {
        // 1) Data -> UIImage -> CGImage (Vision trabalha com CGImage)
        guard let uiImage = UIImage(data: imageData),
              let cgImage = uiImage.cgImage else {
            throw OCRError.invalidData
        }

        // 2) Cria a requisição de OCR e define o idioma
        var request = RecognizeTextRequest()
        request.recognitionLanguages = [.init(identifier: "pt-BR")]

        // 3) Executa a requisição sobre a imagem (async)
        let handler = ImageRequestHandler(cgImage)
        let observations = try await handler.perform(request)

        // 4) Para cada trecho reconhecido, pega o melhor candidato e junta as linhas
        return observations
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n")
    }
}
```

## Explicando passo a passo (para a fala)
- **Protocolo `TextRecognitionServiceProtocol`**: abstrai o OCR. Isso permite
  injetar um mock nos testes/preview e trocar a implementação sem tocar na UI.
- **`Data → UIImage → CGImage`**: a imagem chega como `Data` (do photo picker);
  o Vision opera sobre `CGImage`, então convertemos.
- **`RecognizeTextRequest`**: a requisição de OCR da API nova.
- **`recognitionLanguages = ["pt-BR"]`**: dizemos que o texto é em português —
  melhora bastante a precisão de acentuação e vocabulário.
- **`ImageRequestHandler(cgImage).perform(request)`**: roda o reconhecimento.
  Retorna uma lista de **observações**, cada uma correspondendo a um trecho de
  texto detectado na imagem.
- **`topCandidates(1).first?.string`**: para cada observação, o Vision devolve
  vários "candidatos" ranqueados por confiança. Pegamos **o melhor (top 1)**.
- **`joined(separator: "\n")`**: juntamos os trechos em um único texto,
  preservando quebras de linha.

## Como isso chega na tela
`Voxy/Features/JobPostingForm/JobPostingFormViewModel.swift`

```swift
func importRequirements(from imageData: Data?) async {
    isRecognizing = true
    defer { isRecognizing = false }

    guard let imageData else {
        errorMessage = "Nao foi possivel carregar a imagem selecionada."
        return
    }
    do {
        let recognizedText = try await textRecognitionService.recognizeText(from: imageData)
        if recognizedText.isEmpty {
            errorMessage = "Nao foi possivel encontrar texto na imagem."
        } else {
            jobDescription = recognizedText   // preenche o campo de descrição
        }
    } catch {
        errorMessage = "Nao foi possivel ler a imagem."
    }
}
```

- O texto reconhecido preenche `jobDescription` — o mesmo campo que a pessoa
  editaria à mão. Ou seja, o OCR é um **atalho de digitação**.
- Estados de UI: `isRecognizing` (mostra loading) e `errorMessage` (imagem sem
  texto ou falha de leitura).

## Pontos fortes para destacar
- **On-device e privado**: a imagem da vaga nunca sai do aparelho.
- **Funciona offline**.
- **Zero custo** por uso (sem API paga).
- **Injeção de dependência** via protocolo → testável.

## Limitações honestas
- OCR depende da qualidade da foto (iluminação, foco, tipografia).
- Devolve texto "cru" (linha a linha) — não interpreta semântica; quem entende
  o conteúdo é a etapa seguinte (FoundationModels).

---

# Parte 2 — FoundationModels

## O que é
**FoundationModels** é o framework (iOS 18/26, Apple Intelligence) que dá acesso
ao **LLM on-device** da Apple (um modelo de linguagem que roda no próprio
aparelho). No Voxy ele faz duas coisas:

1. **Gerar as perguntas** da entrevista a partir da vaga.
2. **Avaliar as respostas** e produzir o feedback.

O grande diferencial da API é a **geração guiada/estruturada**: em vez de pedir
texto livre e depois tentar "parsear", declaramos um **tipo Swift** com
`@Generable` e o modelo devolve **exatamente aquela estrutura** preenchida.

## Conceitos-chave da API
- **`@Generable`**: macro em uma `struct` — diz que o modelo pode gerar uma
  instância desse tipo. A Apple converte o tipo em um schema (JSON) que
  restringe a saída do modelo.
- **`@Guide`**: descreve, em linguagem natural, o que cada campo deve conter, e
  permite **restrições programáticas** nos arrays:
  - `.count(3)` → exatamente 3 itens.
  - `.count(2...4)` → entre 2 e 4 itens.
  - `.maximumCount(3)` → no máximo 3 (pode ser **vazio**).
- **`LanguageModelSession`**: a sessão de conversa com o modelo. Recebe
  `instructions` (o "system prompt" — o papel/regra do modelo) e mantém contexto.
- **`session.respond(to:generating:options:)`**: envia um `prompt` e pede a saída
  no tipo `@Generable` indicado.
- **`GenerationOptions`**: controla `temperature` (criatividade) e `sampling`.
- **`SystemLanguageModel.default.availability`**: checa se o modelo está
  disponível (Apple Intelligence ligado, device compatível, modelo baixado).

---

## 2.1 — Geração de perguntas
`Voxy/Services/QuestionGeneration/QuestionGenerationService.swift`

### O schema guiado
```swift
@Generable
struct GeneratedInterview {
    @Guide(description: "Gere 3 perguntas técnicas ancoradas na descrição da vaga...", .count(3))
    let technicalQuestions: [String]

    @Guide(description: "Gere 3 perguntas sobre decisões/experiências reais...", .count(3))
    let projectDecisionQuestions: [String]
}
```
- `.count(3)` em cada campo → **3 + 3 = 6 perguntas por geração**, sempre.
- As descrições em `@Guide` orientam o **estilo** (técnica x comportamental,
  ancorada na vaga, sem sim/não, sem repetir).

### A sessão e as instruções
```swift
init() {
    instructions = """
    Você é um entrevistador experiente que adapta as perguntas à ÁREA da vaga...
    NÃO introduza temas de programação a menos que a descrição os mencione...
    """
    session = LanguageModelSession(instructions: instructions)
}

private let options = GenerationOptions(
    sampling: .random(probabilityThreshold: 0.95),
    temperature: 0.9   // alta → mais variedade nas perguntas
)
```
- **`instructions`**: define o "personagem" (entrevistador) e regras globais
  (permanecer na área da vaga).
- **`temperature: 0.9`**: queremos **variedade** — perguntas diferentes a cada
  treino. (No feedback usamos o oposto, ver adiante.)

### O prompt (contexto da vaga)
```swift
let jobBlock = """
Cargo: \(job.title)
Descrição da vaga:
\(job.description)
"""
```
- Só **cargo + descrição** ancoram as perguntas (o nome da empresa foi
  removido de propósito, para não gerar perguntas sobre a empresa).
- Em treinos seguintes, o prompt também lista as **perguntas anteriores a
  evitar**, porque uma sessão nova não lembra do passado.

### Garantias e robustez (pontos "de engenharia" para destacar)
- **Sempre 6 perguntas**: a deduplicação (mesma pergunta em treinos passados)
  pode encurtar um lote, então geramos em **rodadas** e classificamos:
  - `fresh` (inéditas) têm prioridade;
  - `fallback` (só repetem o histórico) completam se faltar — garantindo 6.
- **Deduplicação normalizada**: comparamos ignorando maiúsculas, acentos e
  pontuação (`normalizedKey`).
- **Resiliência à janela de contexto**: se os tokens estouram
  (`exceededContextWindowSize`), a sessão é reiniciada e tentamos de novo.
- **Estimativa de uso de tokens** (`tokenUsagePercent`) para monitorar o contexto.

---

## 2.2 — Feedback das respostas
`Voxy/Services/FeedbackEngine/FeedbackEngine.swift`

Aqui há **dois** tipos gerados: um por resposta e um consolidado.

### Feedback por resposta
```swift
@Generable
struct AnswerFeedback: Hashable {
    @Guide(description: "Nota de 1 a 5 para clareza/articulação.", .range(1...5))
    let articulationScore: Int

    @Guide(description: "Pontos técnicos REALMENTE demonstrados. Se não soube responder, retorne VAZIO.", .maximumCount(3))
    let technicalStrengths: [String]

    @Guide(description: "Lacunas técnicas enquadradas como sugestões de estudo.", .count(2...4))
    let technicalGaps: [String]
    // ...articulationNotes, languageVices, summary
}
```

### Feedback final (consolidado da entrevista)
```swift
@Generable
struct FinalFeedback {
    @Guide(description: "Sugestões acionáveis (verbo no início).", .count(2...4))
    let improve: [String]

    @Guide(description: "Elogios reais. Se não houve, retorne VAZIO.", .maximumCount(3))
    let bestMoments: [String]

    @Guide(description: "Clareza da fala (não conteúdo técnico).", .maximumCount(2))
    let clarity: [String]
    // ...vicios, profundity
}
```

### Diferenças-chave em relação à geração de perguntas
- **`temperature: 0.3`** (baixa) → feedback **estável e consistente**, não
  criativo. O oposto da geração de perguntas.
- **`.maximumCount` em vez de `.count`** nos campos "de elogio": permite listas
  **vazias**. Isso é essencial: se a pessoa respondeu "não sei" em tudo, o
  modelo **não é obrigado** a inventar pontos positivos.

### Guardas contra alucinação (ponto importante da apresentação)
O modelo às vezes "inventa" positividade. Combatemos isso em **duas camadas**:
1. **No prompt/schema**: instruções de honestidade + `.maximumCount` permitindo
   vazio.
2. **Determinístico, em código** (não confia no modelo): olhamos a **transcrição
   crua**. Se **nenhuma** resposta foi substantiva (vazia / "não sei" / curta
   demais), zeramos à força `bestMoments`, `clarity` e `profundity`:

```swift
private func sanitized(_ feedback: FinalFeedback) -> FinalFeedback {
    let noSubstance = !answers.isEmpty && !hasSubstantiveAnswer
    guard noSubstance else { return feedback }
    return FinalFeedback(improve: feedback.improve, bestMoments: [],
                         clarity: [], vicios: feedback.vicios, profundity: [])
}
```

> Moral: **schema + prompt** guiam o modelo, mas **regras determinísticas em
> Swift** garantem honestidade onde o modelo é pouco confiável.

---

## Disponibilidade (os dois serviços fazem isso)
```swift
var availabilityMessage: String? {
    switch model.availability {
    case .available: return nil
    case .unavailable(.appleIntelligenceNotEnabled):
        return "Ative o Apple Intelligence nos Ajustes..."
    case .unavailable(.deviceNotEligible):
        return "Este dispositivo não é compatível..."
    case .unavailable(.modelNotReady):
        return "O modelo ainda está sendo preparado..."
    case .unavailable:
        return "O modelo de IA não está disponível neste dispositivo."
    }
}
```
- Antes de usar, checamos se o modelo está pronto e mostramos uma mensagem clara
  quando não está (Apple Intelligence desligado, device incompatível, modelo
  ainda baixando).

---

## Por que on-device? (fechamento)
- **Privacidade**: imagem da vaga, respostas e feedback **não saem do aparelho**.
- **Offline**: funciona sem internet.
- **Custo zero por uso**: sem API paga por token.
- **Latência**: sem ida e volta de rede.

## Trade-offs honestos
- **Disponibilidade**: só em dispositivos com Apple Intelligence.
- **Capacidade**: modelo on-device é menor que os de nuvem → precisa de bons
  prompts, schema bem restrito e **guardas em código**.
- **Vision**: qualidade do OCR depende da foto.

---

## Resumo em uma frase
> **Vision** lê a vaga de uma imagem e vira texto; **FoundationModels** usa esse
> texto para gerar perguntas guiadas por schema (`@Generable`/`@Guide`) e depois
> avalia as respostas — tudo on-device, com regras determinísticas em Swift
> reforçando a confiabilidade do modelo.
