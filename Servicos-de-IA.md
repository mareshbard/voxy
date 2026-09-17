# Voxy — Os Serviços de Inteligência Artificial

> Guia narrativo dos serviços de IA do Voxy. Serve tanto para estudo quanto como roteiro de pitch. Tudo aqui d  escreve **o que realmente está implementado** no app.

---

## Visão geral: uma entrevista inteira, 100% no dispositivo

O Voxy é um simulador de entrevistas técnicas. A grande tese do produto é que **toda a inteligência acontece dentro do iPhone** — nenhuma resposta, áudio ou vaga do usuário sai do aparelho para um servidor. Isso é possível porque o app é construído sobre três frameworks de IA da Apple que rodam localmente:

- **Foundation Models** (Apple Intelligence) — o modelo de linguagem on-device que gera perguntas e avalia respostas.
- **Speech** (SpeechAnalyzer / SpeechTranscriber) — transcrição de fala ao vivo, em português.
- **Vision** — leitura de texto (OCR) a partir de uma foto da vaga.

Esses serviços se encadeiam num fluxo único. Vale a pena guardar esta sequência para o pitch, porque ela conta a história do produto de ponta a ponta:

```
Foto da vaga  ──►  OCR (Vision)  ──►  Descrição em texto
                                          │
                                          ▼
                            Geração de perguntas (Foundation Models)
                                          │
                                          ▼
        Usuário responde falando  ──►  Captura de áudio (AVAudioEngine)
                                          │
                                          ▼
                    Transcrição ao vivo (Speech / SpeechAnalyzer)
                                          │
                                          ▼
               Avaliação e feedback final (Foundation Models)
```

Cada etapa é um serviço isolado, testável e independente. A seguir, a história de cada um.

---

## 1. Vision — Lendo a vaga a partir de uma foto

**Arquivo:** `Services/OCR/JobPostingTextExtractor.swift` · **Framework:** Vision

A jornada começa quando o usuário fotografa (ou seleciona) o anúncio de uma vaga. Em vez de obrigá-lo a digitar tudo, o Voxy usa **OCR (reconhecimento óptico de caracteres)** para transformar a imagem em texto.

O serviço `VisionTextRecognitionService` recebe os dados brutos da imagem, cria uma `RecognizeTextRequest` configurada para **português do Brasil** (`pt-BR`) e a executa através de um `ImageRequestHandler`. O resultado é uma lista de observações; para cada uma, o serviço pega o candidato de maior confiança (`topCandidates(1)`) e junta tudo em um único texto, linha a linha.

O ponto interessante para o pitch: essa é a API de Vision mais recente, baseada em `async/await` — a chamada `handler.perform(request)` é assíncrona e não trava a interface. E, como tudo em Vision, roda **offline, no dispositivo**.

> **Fala de pitch:** "O usuário não digita a vaga — ele tira uma foto. Em segundos, a Vision extrai o texto e alimenta o resto do sistema."

---

## 2. Foundation Models — Gerando as perguntas da entrevista

**Arquivo:** `Services/QuestionGeneration/QuestionGenerationService.swift` · **Framework:** Foundation Models (Apple Intelligence)

Com a descrição da vaga em mãos, entra o coração do produto: a geração de perguntas por um **modelo de linguagem que roda no próprio iPhone** (`SystemLanguageModel.default`).

### Geração estruturada (o diferencial técnico)

Em vez de pedir texto livre e depois "quebrar" a resposta, o Voxy usa **geração estruturada** do Foundation Models. Definimos um tipo Swift anotado com `@Generable`, e o modelo é obrigado a preencher exatamente aquela estrutura:

```swift
@Generable
struct GeneratedInterview {
    @Guide(description: "3 perguntas técnicas ancoradas na vaga...", .count(3))
    let technicalQuestions: [String]

    @Guide(description: "3 perguntas sobre decisões de projeto/experiência...", .count(3))
    let projectDecisionQuestions: [String]
}
```

Cada campo carrega um `@Guide` — uma instrução em linguagem natural + regras rígidas como `.count(3)` (exatamente 3 itens). Isso garante que **sempre** venham 6 perguntas: 3 técnicas conceituais/práticas e 3 sobre experiências reais ("me conte sobre uma decisão que você tomou...").

### Inteligência de contexto

As instruções do modelo são cuidadosamente desenhadas para que ele **identifique a área da vaga** (design, dados, produto, engenharia, marketing…) e permaneça nela. Uma vaga de design nunca gera pergunta sobre código; uma vaga de back-end não gera pergunta genérica. As perguntas se ancoram **exclusivamente no que a descrição menciona**. O nome da empresa é omitido de propósito.

### Detalhes de engenharia que valem citar

| Recurso | O que faz | Por que importa |
|---|---|---|
| `temperature: 0.9` + `sampling: .random(0.95)` | Alta criatividade na geração | Perguntas variadas, nunca repetitivas |
| Deduplicação por chave normalizada | Remove perguntas repetidas (ignorando acentos/maiúsculas) | Nunca cai a mesma pergunta duas vezes, nem entre treinos diferentes |
| Histórico de "perguntas a evitar" | Reenvia ao modelo o que já foi perguntado | Cada treino é inédito, mesmo em sessões novas |
| `prewarm()` | Pré-carrega o modelo | Reduz a latência da primeira geração |
| Controle de janela de contexto | Reinicia a sessão se estourar os tokens e tenta de novo | Robustez: nunca falha por "contexto cheio" |
| Estimativa de uso de tokens | Mostra quanto da janela de contexto (~4096) já foi usada | Transparência e controle de sessão |

> **Fala de pitch:** "Não pedimos texto solto para a IA. Usamos geração estruturada: o modelo é forçado a entregar exatamente 6 perguntas, no formato certo, ancoradas na vaga — e nunca repetidas."

---

## 3. Captura de áudio — Ouvindo o candidato

**Arquivo:** `Services/AudioRecorder/AudioRecorder.swift` · **Framework:** AVFAudio

Quando o usuário responde falando, o `AudioCapturer` entra em cena. Ele usa o `AVAudioEngine` para se conectar ao microfone e instala um "tap" que captura o áudio em pedaços pequenos (buffers de 1024 quadros). Cada pedaço é entregue continuamente através de um `AsyncStream`, pronto para ser transcrito em tempo real.

Ele também cuida de toda a etiqueta do sistema: pede permissão de microfone, trata os casos de permissão negada e, ao terminar, desliga o microfone e libera a sessão de áudio para outros apps. É um serviço de infraestrutura — não é "IA" em si, mas é o que alimenta a transcrição.

---

## 4. Speech — Transcrição de fala ao vivo

**Arquivos:** `Services/SpeechTranscription/SpeechTranscriptionService.swift` e `Services/SpeechAnalyzer/SpeechAnalyzerService.swift` · **Framework:** Speech

Aqui está a parte mais nova tecnicamente. O Voxy usa o **SpeechAnalyzer / SpeechTranscriber** — a API de transcrição mais recente da Apple, que roda **no dispositivo** e é feita para **fala contínua e ao vivo**.

### `Transcriber` — o motor

A classe `Transcriber` monta um `SpeechAnalyzer` com um único módulo: o `SpeechTranscriber`, configurado em português e no preset `.timeIndexedProgressiveTranscription` (transcrição progressiva com marcação de tempo). Dois detalhes elegantes:

- **Download automático de idioma:** se o aparelho ainda não tem os recursos de fala em pt-BR, o serviço baixa e instala sob demanda via `AssetInventory`.
- **Conversão de formato de áudio:** o microfone pode entregar o áudio num formato diferente do que o transcritor espera. O `Transcriber` detecta isso e converte cada buffer na hora, com um `AVAudioConverter`.

Os buffers vindos do microfone são transmitidos ao analisador; os resultados voltam como um fluxo assíncrono de texto.

### `SpeechAnalyzeManager` — o maestro

Esta classe (`@Observable`, integrada direto à SwiftUI) orquestra tudo: liga o microfone e o transcritor, escuta os resultados e atualiza a transcrição na tela em tempo real. Ela distingue dois tipos de texto:

- **Volátil:** a hipótese provisória, que muda enquanto a pessoa fala.
- **Finalizado:** o trecho já consolidado, que não muda mais.

A transcrição exibida é a junção dos dois, o que dá aquela sensação fluida de "legenda ao vivo". Ela também gerencia permissões, erros e o encerramento ordenado (espera processar o último pedaço de áudio antes de parar).

> **Fala de pitch:** "Enquanto o candidato fala, a transcrição aparece ao vivo na tela — tudo processado localmente, em português, sem enviar áudio para lugar nenhum."

---

## 5. Foundation Models — O feedback (o momento "aha")

**Arquivo:** `Services/FeedbackEngine/FeedbackEngine.swift` · **Framework:** Foundation Models (Apple Intelligence)

Transcrita a resposta, o mesmo modelo on-device volta — agora no papel de **avaliador rigoroso**. O `FoundationFeedbackEngine` faz duas coisas:

### a) Feedback por resposta (`AnswerFeedback`)

Para cada pergunta respondida, o modelo gera uma estrutura com:

- **Nota de articulação** (1 a 5) para clareza;
- **Análise da articulação** em 2–3 frases;
- **Vícios de linguagem** ("tipo", "né", repetições…);
- **Pontos técnicos fortes** realmente demonstrados;
- **Lacunas técnicas**, enquadradas como sugestões de estudo;
- **Resumo acionável** em uma frase.

### b) Feedback final consolidado (`FinalFeedback`)

Ao fim da entrevista, o modelo junta todos os feedbacks num relatório: o que **melhorar**, os **melhores momentos**, a **clareza**, os **vícios** e a **profundidade** técnica.

### O grande diferencial: honestidade forçada

O que torna esse serviço especial é a **engenharia de prompt anti-elogio-falso**. As instruções e os `@Guide` são desenhados para o modelo ser realista e nunca "inventar" elogios:

- Regra do **"não sei"**: se a pessoa respondeu de forma vazia ou evasiva, as listas de pontos fortes, melhores momentos, clareza e profundidade voltam **obrigatoriamente vazias**.
- **`temperature: 0.1`** (bem baixa): força o modelo a respeitar rigidamente as regras e a formatação, sem "viajar".
- **Deduplicação entre seções:** a mesma frase nunca aparece em duas partes do relatório.

> **Fala de pitch:** "O feedback é brutalmente honesto por design. Se você não soube responder, a IA não te elogia — ela transforma a lacuna em um plano de estudo. E ainda por cima gera tudo em formato estruturado, pronto para a interface."

---

## Temas transversais (os pilares do pitch)

Estes são os argumentos que amarram todos os serviços — vale destacá-los:

| Pilar | Como o Voxy entrega |
|---|---|
| **Privacidade total** | Foto da vaga, áudio e respostas nunca saem do aparelho. Não há servidor de IA. |
| **Offline-first** | Foundation Models, Speech e Vision rodam localmente. Funciona sem internet. |
| **Custo zero de inferência** | Sem chamadas a APIs pagas de LLM — a inferência é do próprio dispositivo. |
| **Tecnologia de ponta** | Usa as APIs mais recentes da Apple: Apple Intelligence, SpeechAnalyzer e a nova Vision assíncrona. |
| **Saída estruturada e confiável** | `@Generable` / `@Guide` garantem respostas no formato certo — nada de "parsear" texto solto. |
| **Degradação elegante** | Se o Apple Intelligence não estiver disponível, o app explica exatamente o porquê (não compatível, precisa ativar, modelo carregando…). |

### Sobre disponibilidade do modelo

Tanto a geração de perguntas quanto o feedback checam `model.availability` e devolvem mensagens claras ao usuário: ativar o Apple Intelligence nos Ajustes, dispositivo incompatível, modelo ainda carregando, etc. Isso mostra maturidade de produto — o app nunca "quebra em silêncio".

---

## Resumo em uma tabela (cola rápida)

| Serviço | Arquivo | Framework | Papel no fluxo |
|---|---|---|---|
| OCR da vaga | `OCR/JobPostingTextExtractor.swift` | Vision | Foto → texto da vaga |
| Geração de perguntas | `QuestionGeneration/QuestionGenerationService.swift` | Foundation Models | Vaga → 6 perguntas |
| Captura de áudio | `AudioRecorder/AudioRecorder.swift` | AVFAudio | Microfone → buffers |
| Transcrição | `SpeechTranscription/…` + `SpeechAnalyzer/…` | Speech | Fala → texto ao vivo |
| Feedback | `FeedbackEngine/FeedbackEngine.swift` | Foundation Models | Respostas → avaliação honesta |

---

## Roteiro sugerido de pitch (60 segundos)

1. **Problema:** treinar entrevista é caro e constrangedor. Ninguém tem um entrevistador à disposição.
2. **Solução:** o Voxy é seu entrevistador de bolso — tire uma foto da vaga e comece.
3. **Mágica 1:** a IA lê a vaga (Vision) e cria perguntas sob medida para *aquele* cargo (Foundation Models).
4. **Mágica 2:** você responde falando; o app transcreve ao vivo (Speech).
5. **Mágica 3:** recebe um feedback honesto e acionável, com nota, vícios de fala e plano de estudo (Foundation Models).
6. **Fechamento:** e o melhor — **tudo roda dentro do iPhone**. Privado, offline e sem custo de servidor.
