---
슬러그: jev-system-one-model
주제: Jev (TypeSafe AI의 System One 모델). 생성 대신 판단과 확률을 반환한다는 선택이 호출하는 쪽 코드에 무엇을 요구하는가
작성일: 2026-09-28
조회일: 외부 자료는 전부 2026-09-28에 조회 (발표 13일 뒤)
---

# 리서치: Jev, 문장 대신 판단과 확률을 돌려주는 모델

## 맨 먼저: 실재 확인 결과와 이 노트의 한계

**실재합니다.** 회사명 TypeSafe AI, 모델명 Jev 모두 전해 들은 표기 그대로이고, 2026-09-15에 공식 발표됐습니다. 공식 출처는 회사 블로그, 문서 사이트(docs.typesafe.ai), Business Wire 보도자료, GitHub 조직(typesafe-ai)입니다.

전해 들은 설명과 공식 자료를 대조하면 이렇습니다.

| 전해 들은 설명 | 공식 자료 | 판정 |
|---|---|---|
| TypeSafe AI의 모델 | 회사 표기 "TypeSafe AI", 블로그 서명은 "TypeSafe" | 맞음 |
| 자연어 텍스트를 생성하지 않음 | "While Jev gives up string generation" (블로그) | 맞음 |
| 프로그램의 상태와 질문을 받음 | 요청 필드가 `state`와 `questions` (API 문서) | 맞음. 단 상태는 텍스트만 받습니다(문자열, JSON 객체, 텍스트 배열) |
| 구조화된 판단과 확률을 반환 | Choice, Score는 `probabilities`와 `confidence`, Noul은 0~1 값 하나 | 맞음. Noul에는 `confidence`가 없습니다 |
| '시스템 1(System One)' 모델 | "System One"은 모델 **부류** 이름이고 Jev는 그 첫 모델 | 대체로 맞음. 표기는 숫자 1이 아니라 "One" |

전해 들은 설명에서 빠진 것이 두 가지 있습니다. **답의 후보(선택지, 척도 단계)를 호출하는 쪽이 미리 정의해야 한다**는 것, 그리고 **제어 흐름과 부작용은 코드가 쥐고 모델은 판단만 돌려준다**는 것. 인사이트 후보는 대부분 이 빠진 두 가지에서 나옵니다.

⚠️ **내부 1차 근거가 없습니다.** 오케스트레이터가 `~/IdeaProjects` 전체를 확인했고, 이 저장소의 `_posts`, `_drafts`에도 Jev, TypeSafe, System One 언급이 0건입니다(2026-09-28 grep). 작성자가 Jev를 직접 호출해 본 기록이 없다는 뜻이에요. 그래서 이 노트의 "근거 I"는 작업물이 아니라 **기존 발행본 세 편과의 연결 지점**뿐이고, 인사이트 후보는 전부 "공개 문서와 독립 측정을 이 블로그의 기존 관점으로 읽은 것"입니다. 사용 경험처럼 쓰면 근거를 넘습니다(아래 "작성 시 지켜야 할 것" 참조).

⚠️ **시점이 매우 이릅니다.** 발표 13일 뒤의 기록입니다. 문서 자체가 rate limit이 "can change without notice"라고 적어 두었고, 모델 별칭도 옮겨 갈 수 있습니다. 수치와 조건은 전부 조회일 기준으로 적어야 합니다.

---

## 근거 E: 외부

### E-1. 회사와 발표 (1차 출처 확인)

- (외부) 발표일 2026-09-15. 회사 블로그 글 "Introducing System One Models & Jev"의 게시일 표기가 `Sep 15, 2026`, 서명은 `Diogo Almeida, founder, TypeSafe`. 출처: https://typesafe.ai/blog/introducing-system-one-models-and-jev
  - ⚠️ 같은 페이지 HTML 주석의 `Published Sep 27, 2026`은 Framer 사이트 배포 시각이고 글 게시일이 아닙니다(홈과 매니페스토 페이지에도 같은 값이 찍혀 있음). WebFetch 요약이 이 값을 게시일로 잘못 읽었으니 인용하지 마세요.
- (외부) Business Wire 보도자료, 데이트라인 `SAN FRANCISCO, September 15, 2026--(BUSINESS WIRE)`. 원문: "TypeSafe AI, a frontier AI lab building machine-native, composable AI, today emerged from stealth with $40 million in seed funding led by DCVC." 창업자는 "Diogo Almeida, with Erik Gafni and Sasha Sheng". 회사 소개 문단: "Founded in 2024 and headquartered in San Francisco". 출처: Yahoo Finance 게재본 https://finance.yahoo.com/technology/ai/articles/typesafe-ai-emerges-stealth-40m-190000776.html (원본 링크 https://www.businesswire.com/news/home/20260915525333/en/). Yahoo 페이지에 "This is a paid press release"라고 표시돼 있어 **회사 발표문**으로 취급해야 합니다.
- (외부) Diogo Almeida 이력에 대한 회사 측 표현: 보도자료 "former OpenAI researcher and co-inventor of RLHF/ChatGPT", 블로그 "At OpenAI, I helped build the methods that made language models useful at following instructions and talking with people." 문서의 AI primer는 "co-invented by Diogo Almeida"라며 Google Scholar 링크를 겁니다. 이건 **회사 측 주장**이고 이번 리서치에서 독립 확인하지 않았습니다.
- (외부) 블로그 원문: "After two years in stealth, countless technical challenges, and research breakthroughs…" (스텔스 2년은 회사 주장).
- (외부) Hacker News 발표 스레드: "Introducing System One Models and Jev", 2026-09-15T19:25Z, 1984점, 댓글 518개(Algolia API 조회). https://news.ycombinator.com/item?id=49717558
- 이름 혼동 주의: 2011년 Scala와 Akka 쪽 회사 Typesafe는 2016-02에 Lightbend로 이름을 바꿨습니다(https://en.wikipedia.org/wiki/Lightbend). TypeSafe AI와 무관합니다. GitHub의 `nshkrdotcom/typesafe_sdk`(Elixir용 AI SDK 포트)도 이름만 같고 무관합니다.

### E-2. 이름의 출처: System One과 Jev

- (외부) 블로그 FAQ 원문: "We were inspired by Daniel Kahneman, Thinking, Fast and Slow. The model class name draws on the distinction between fast, intuitive System 1 thinking and slow, deliberate System 2 reasoning."
- (외부) 같은 FAQ가 스스로 약점을 짚습니다: "“System 1 thinking” has also implied error-prone. For reasons we will get into in the future, we believe System One Models can be made more reliable than its alternatives." **"더 신뢰할 수 있다"의 근거는 "나중에 설명하겠다"로 미뤄져 있습니다.**
- (외부) 문서의 설명: "System 1 thinking is fast and intuitive. System 2 is slower and more deliberate. Here, the emphasis is on fast, focused judgments." 출처: https://docs.typesafe.ai/concepts/system-one (.md 36행)
- (외부) 문서는 System 2 쪽을 별도 모델로 두지 않습니다. 불확실한 판단을 "a person or a reasoning model"로 넘기라고 할 뿐이고(`concepts/system-one` .md 49행), 그 넘김을 결정하는 건 코드입니다(E-6 참조). 즉 **System 1과 System 2 사이의 전환 스위치를 모델이 아니라 호출하는 코드가 쥡니다.**
- (외부) Jev 이름: 블로그 FAQ 원문 "We named Jev after William Stanley Jevons. We expect machine intelligence to follow a similar path to coal, after steam-engine efficiency led to an increase in demand." 보도자료는 "Jev, a nod to Jevons Paradox"라고 적습니다.

### E-3. 입력과 출력의 실제 형식 (API 문서, 1차)

- 엔드포인트: `POST https://api.typesafe.ai/v1/systemone`. 요청 본문은 `state`, `model`, `questions` 세 필드. 출처: https://docs.typesafe.ai/api
- `state`: "string | object | array". 문서 원문 "Jev currently accepts text input only. It evaluates strings, JSON objects, and arrays of text. Images, audio, and video are not supported (yet)." (`concepts/system-one` .md 16행)
- `questions`: 호출자가 이름을 붙인 맵. 질문 유형은 셋입니다.

| 유형 | 묻는 것 | 호출자가 미리 정하는 것 | 돌려받는 것 |
|---|---|---|---|
| Choice | 목록에서 하나 고르기 | `criteria`: 선택지 맵, 최대 255개 | `choice`, `probabilities`(합 1), `confidence` |
| Score | 순서 있는 척도로 평가 | `criteria`: 단계 설명 배열, 2~10개 | `score`(단계 사이 값 가능), `legend`, `probabilities`, `confidence` |
| Noul | 참/거짓 판정 | `instructions`, 선택적 `criteria.true/false` | `noul`(0~1, 참일 확률). `confidence` 없음 |

- 응답 예시(API 문서 원문 그대로): `"probabilities": { "billing": 0.88, "technical": 0.12, "sales": 0.0 }`, `"confidence": 0.81`. 응답의 `model` 필드는 `jev-1.13.0`처럼 **실제로 답한 버전 ID**를 돌려줍니다.
- `confidence`는 확률 분포에서 **파생된 통계량**입니다. 원문: "`confidence` is a statistic computed from the probability distribution the answer already gives you." / "(Noul answers don't carry one.)" 출처: https://docs.typesafe.ai/confidence (.md 145, 149행). 문서 데모는 선택지 3개일 때 `(3 × largest probability − 1) / 2`로 "approximate"한다고만 적어서, 정확한 공식은 공개되지 않았습니다.
- 질문들은 같은 상태에 대해 병렬로, 서로 독립적으로 평가됩니다. 원문: "Every *question* is evaluated in parallel and in isolation against the same *state* in one go." (https://docs.typesafe.ai/introduction .md 37행)
- 질문 설계 원칙 원문: "Think of each question as a gut-check determination: the kind of judgment a highly knowledgeable person could make in a few seconds given the right context." (introduction .md 41행) 복잡한 판단은 쪼개서 코드로 합치라고 합니다.

### E-4. LLM과 무엇이 다르다고 주장하는가

블로그의 비교표(원문 그대로, 필요한 행만):

| 항목 | Existing LLMs | System One + Jev |
|---|---|---|
| Optimized with | "Reinforcement Learning with Human Feedback (RLHF) / Reinforcement Learning with Verifiable Rewards (RLVR)" | "Reinforcement Learning for Calibrated Decisions (RLCD)" |
| Outputs | "Strings / generated text. ... To be used by software, responses need to be parsed + validated." | "Type-safe structured values. Possible outputs and structure are defined in advance. The model never makes type errors." |
| Sampling | "Sequential. Generates one token at a time, each conditioned on the last." | "Parallel. Generates all outputs in a single query." |
| Confidence | "Even if prompted for a confidence estimate, models tend to be overconfident and inconsistent. If a model can do a task 95% of the time but doesn’t say when it’s in the 5%, it can’t automate that task." | "Always communicates confidence and uncertainty with every output. Calibrated: higher confidence means higher accuracy." |

- (외부) 블로그 한 줄 요약 원문: "Think of Jev as a frontier-intelligence function call: unstructured state in, typed probabilistic decisions out."
- (외부) structured output, function calling과의 차이에 대해 문서가 직접 드는 사례: "Replace a fragile prompt that asks an LLM to "return JSON" with a call that returns typed values by construction." (https://docs.typesafe.ai/introduction/coding-agents .md 39행)
- (외부) **그런데 같은 인터페이스를 LLM으로도 구현할 수 있다는 걸 TypeSafe가 직접 보여 줍니다.** 공식 조직의 `system-one-adapter-python`(MIT, 2026-08-08 생성) README 원문: "A drop-in replacement for `typesafe_sdk`'s `system_one` evaluation API, backed by LLM APIs instead of TypeSafe." 이 어댑터는 `n_retries_malformed_structure` 카운터와 `normalize_probabilities`("Rescale invalid LLM probability distributions to sum to 1") 옵션을 갖고 있습니다. 출처: https://github.com/typesafe-ai/system-one-adapter-python
  - 이게 중요한 이유: 블로그의 비교 평가에서 LLM들도 이 래퍼를 썼습니다. 원문: "The LLMs use our System One LLM wrapper, which constrains LLMs to output structured decisions compatible with our API." 즉 **"질문 유형 + 확률 분포"라는 계약은 모델과 분리 가능**하고, LLM 쪽 경로에서 사라지는 비용(형식 오류 재시도, 확률 정규화)이 어댑터 옵션으로 그대로 드러나 있습니다.
- (외부) 코딩 에이전트용 모델이 아니라고 문서가 못 박습니다: "Jev is **not** a drop-in replacement for the LLM behind Claude Code, Cursor, opencode, Copilot, Muse Spark, Grok Bot, or similar tools." (coding-agents .md 9행)

### E-5. 공식 주장 목록 (전부 "주장"으로 표시할 것)

**속도와 배수는 출처마다 다릅니다.** 이 불일치 자체가 기록할 만합니다.

| 출처 | 속도 | 배수 |
|---|---|---|
| 블로그 비교표 | "End-to-end response time is 70ms-500ms for TypeSafe" | "40x-200x faster" |
| 보도자료 | "less than 100 milliseconds of latency" | "up to 100 times faster and less expensive" |
| 문서(how-to-build) | "Most queries complete in about 100 ms." | "greater than 100× intelligence-to-speed-and-cost ratio"(목표로 표현) |
| 홈페이지 | 데모 "Completed in 0.114s" vs LLM "8.566s" | "193.6x Faster,444.6x Cheaper." (원문 쉼표 뒤 공백 없음) |
| The Register(2026-09-23) | "as little as 150 ms" | 없음 |
| 독립 측정 priorbench(OpenRouter 경유, 서유럽) | "~430 ms floor", 800개 판단 한 번 호출에 985 ms | 해당 없음 |

- (외부) 블로그가 홈페이지 배수의 출처와 한계를 스스로 적었습니다. 원문: "This is where the claims of 193.6x faster, 444.6x cheaper on our home page comes from, and we expect that these are on the higher end of real world gains."
- (외부) 속도 측정 조건 원문: "our published evals are generally run from our laptops on the West Coast (this is where our service is currently based)."
- (외부) 가격 원문: "Input tokens: $0.042 / MTok ($42 per billion tokens)." / "Output tokens: FREE (too cheap to meter)." 지속 가능성에 대한 단서 원문: "We can’t prove it isn’t subsidized". 홈페이지는 "238x Lower input price than Claude Fable 5.1"이라고 적습니다.
- (외부) **"환각이 없다"는 주장의 실제 근거는 스키마 일치입니다.** 블로그 원문: "Jev ... can’t hallucinate." / "No type errors: This would be an easy thing to falsify with just a single counter-example, but it is mathematically impossible." / 환각 비교 차트 설명 "Our number is not empirical. Schema matching is guaranteed, thus we can confidently add 0% into the plots." 그리고 "Hallucination and type-safety are intrinsically related, and we think the latter is table stakes for automation."
- (외부) **비교 평가의 정답은 실제 정답이 아니라 다른 모델들의 평균입니다.** 블로그 원문: "Instead, we assume there is a correct compute graph (a “workflow” represented in code) and use the predictions of the largest, smartest, and most expensive external models as reference probabilities." / "We use the average of GPT-6 Astra and Fable 5.1 as the reference answer, which biases answers towards OpenAI and Anthropic’s models." / 워크플로 작성자에 대해 "they were made by individuals on our model capabilities team, so some bias could exist."
- (외부) 공개 벤치마크는 일부러 싣지 않았습니다. FAQ 원문: "We deliberately chose not to publish performance against public benchmarks." / 권고 "Put no weight on public benchmarks." / "Encourage users to create their own evals for their use cases (System One tasks are much easier to evaluate)."
- (외부) "Jev는 LLM인가"에 대한 공식 답변 원문: "Jev is neither small nor an LLM, hence being off the intelligence Pareto curve." (FAQ) 아키텍처 설명은 "a new model architecture, parallel sampler for maximum efficiency" 이상 공개되지 않았습니다.
- (외부) 학습 데이터 FAQ 원문: "We make all the data ourselves. We wouldn’t train on your data even if you asked us to (no offense)."

### E-6. 벤더가 스스로 적은 한계와 "코드가 쥐는 것"

이 절이 인사이트의 주 재료입니다. 벤더 문서가 마케팅 문구보다 훨씬 신중합니다.

- (외부) **보정은 집단의 성질이지 개별 답의 보증이 아닙니다.** 원문: "Calibration is measured across groups of predictions; it does not guarantee that an individual answer is correct." (`concepts/system-one` .md 21행) / "These rates describe groups of predictions, not a guarantee about any single answer." (https://docs.typesafe.ai/introduction/machine-learning-primer .md 63행)
- (외부) **임계값은 호출자의 데이터로 정하라고 합니다.** 원문: "Test thresholds by plotting confidence against accuracy on your data." (https://docs.typesafe.ai/concepts/how-to-build-with-system-one .md 787행) / "The correct threshold values depend on your domain and the performance of the model for your use case. Start with conservative thresholds, test with your own data, and adjust as you observe results." (confidence .md 219행)
- (외부) **제어 흐름과 부작용은 코드 몫이라고 명시합니다.** 원문: "It does not generate code or choose its own next action." (how-to-build .md 238행) / "Keep control flow, deterministic rules, and side effects in code." (같은 문서 243행) / "Code handles deterministic work and owns the control flow. The model appears only where the system needs programmable common sense or needs to interpret unstructured data." (264행)
- (외부) **임계값을 결과의 크기로 나눕니다.** 원문:
  - "Where to set the threshold depends on the cost of being wrong. ... Raise it when acting on a false yes is expensive, such as paging someone or issuing a refund. Lower it when missing a true yes is expensive, such as failing to flag a safety issue." (https://docs.typesafe.ai/primitives/noul .md 367행)
  - confidence 문서 코드 주석: `# Low stakes. Showing the wrong screen is recoverable.` 그리고 본문 "the threshold for acting without confirmation is higher for a destructive operation than for a read-only one. Your code encodes the risk tolerance." (confidence .md 204, 216행)
- (외부) ★ **벤더의 두 문서가 같은 예제(송금 승인)에서 다른 결론을 냅니다.** 둘 다 원문 그대로 옮겨야 합니다.
  - `confidence` 문서(.md 199~213행): 0.5 미만이면 사람에게, `approve_transfer`는 `if confidence > 0.9:` 일 때도 `confirm_then_execute(account_id)` (주석 `# High stakes, high confidence. Proceed with confirmation.`). **높은 확신도에서도 확인 절차를 남깁니다.**
  - `patterns/confidence-routing` 문서(.md 286~304행): 0.6 미만이면 사람에게, `if action.confidence > 0.85:` 일 때 `approve_transfer(account_id)` (주석 `# High stakes, but high confidence. Safe to act automatically.`). **확신도가 높으면 확인 없이 자동 실행합니다.** 출처: https://docs.typesafe.ai/patterns/confidence-routing
  - 같은 회사의 같은 시점 문서에서, 되돌리기 어려운 동작(송금 승인)에 사람 확인을 남길지가 확신도 임계값에 따라 갈립니다. 한쪽은 "확신도와 무관하게 확인", 다른 쪽은 "확신도가 충분하면 자동".
- (외부) **판단과 계산의 경계를 벤더가 먼저 긋습니다.** `jev-1.13` jaggedness 문서(https://docs.typesafe.ai/model-jaggedness/jev-1.13, "Last reviewed 2026-09-17") 원문:
  - "Before asking a counting question, ask why the count needs a model at all. If the unit is something a regular expression or a parser can find, the count belongs in code and the model has nothing to add." (.md 43행)
  - "Extraction is a judgment, so give it to the model. Arithmetic is not, so keep it in code." (.md 82행)
- (외부) **"모르겠다"를 담을 자리는 답의 공간에 호출자가 만들어야 합니다.** 날짜 추출 예시 원문: "it gives you somewhere to put an explicit "not stated" option so a missing part is reported rather than guessed." (jaggedness .md 84행)
- (외부) **확률은 질문 유형 사이에서 공통 화폐가 아닙니다.** 같은 티켓에 "환불 요청인가"와 그 부정을 각각 Noul로 물었더니 0.72와 0.47, 합 1.19. 원문 권고: "Don't carry a threshold tuned on a Noul over to a Choice, and don't hold the model to arithmetic identities between separate questions." 그리고 "the Choice is relative, settling *which* option, while each Noul is absolute and can be low for all of them." (jaggedness .md 133, 137행)
- (외부) **입력은 데이터이지만 적대적 입력에 기본 방어가 없습니다.** 원문: "State is data, and `jev-1.13` does not treat it as hostile by default." (jaggedness .md 106행)
- (외부) **모델 별칭은 옮겨 가고, 임계값은 버전에 묶입니다.** 원문: "An alias moves when a new release ships, so the answers behind it can change without a change on your side." / "If you have tuned confidence thresholds against a specific version, pin that version's ID instead of the alias and move to the new one on your own schedule." (https://docs.typesafe.ai/models .md 40행) SDK 기본값은 별칭 `jev-latest`입니다(같은 문서 33행, `concepts/system-one` .md 53행).
- (외부) **한국어는 정확도가 낮다고 적혀 있습니다.** 원문: "English is the primary training language and where accuracy is currently best. Other languages, including CJK scripts, are handled but not equally well" (models .md 52행)
- (외부) 벤더 문서의 설계 요약(원문): "System One is TypeSafe's model for building AI-powered software, not agents." (how-to-build .md 238행)

### E-7. 독립 검증과 반론

**등급을 나눠 적습니다.** 원문을 직접 확인한 것과 요약을 거친 것을 구분했습니다.

원문 직접 확인:

- (외부) ★ **HN 스레드의 핵심 반론과 회사 측 응답.** 출처: https://news.ycombinator.com/item?id=49717558 (Algolia API로 댓글 원문 조회)
  - jacobgold: "Sure, it can't emit an invalid type, but it can still emit a completely wrong valid value."
  - WhitneyLand: "Type safety is not factual correctness." → CompleteSkeptic 응답: "I very much agree with this and want to hone in on where do actually disagree. Would you say a linear classifier hallucinates?"
  - CompleteSkeptic의 다른 댓글: "that's right, but because these models are probabilistic, it's also possible to be confidently wrong (and all future models will be smarter still and still have that possibility)" / 아키텍처 질문에 "architecture is close to the chest for now, but we have talked about writing a paper"
  - thduabmd: "Even granting that each answer is calibrated individually, that doesn't establish calibration of the decision that combines them." / "I still have to define the constraints and test which wrong actions get through the complete workflow on my own data. That's a substantial part of the work being pushed back onto the developer."
  - bigglebear: "because the model is forced to answer in a boolean (if in boolean mode), if the user input is outside of the range of a boolean, it's forced to hallucinate. It can't abstain."
  - WhitneyLand에 따르면 스레드 원제목은 "Jev: New frontier model 40-400x cheaper and 20-200x faster"였고 한 시간 안에 바뀌었습니다(댓글 한 건의 진술, 미확인).
  - ⚠️ CompleteSkeptic이 누구인지: HN 프로필에 소개가 없습니다. 본인이 "I'm biased", "we describe that in the blog post"라고 쓰고 "my blog"로 링크한 completeskeptic.com 글의 author 메타가 "Diogo"입니다. **TypeSafe 창업자 Diogo Almeida일 가능성이 높지만 추정입니다.** 글에서는 "회사 측으로 보이는 계정"까지만 쓰세요.
- (외부) ★ **공정한 주사위 실험.** 출처: https://github.com/KantaHayashiAI/jev-does-not-play-dice (2026-09-18 생성, README 원문 확인, 저장소에 원 응답과 분석 스크립트 포함) **→ 검증 V-22에서 정정: 저장소의 `data/recorded/`는 작성자 스스로 "recorded experiment outputs, not complete raw HTTP responses"라고 적은 기록된 출력입니다. 원 HTTP 응답이 아닙니다.**

| 실험 | 기대 확률 | 보고된 평균 확률 | 관측 정확도 |
|---|---:|---:|---:|
| 공정한 6면 주사위 (Choice) | 16.7% | 82.9% | 19.0% (76/400) |
| 공정한 동전 (Choice) | 50.0% | 92.0% | 52.0% |
| 공정한 6면 주사위 (Noul) | 16.7% | 19.2% | 해당 없음 |
| 20개 동일 확률 선택지 (Noul) | 5.0% | 15.0% | 해당 없음 |
| 예측 문서, 명시 확률 45% (Choice) | 45.0% | 6.6% | 해당 없음 |
| 예측 문서, 명시 확률 55% (Choice) | 55.0% | 95.9% | 해당 없음 |

  - 저자 스스로의 해석 원문: "The issue is not that Jev failed to predict a random event; the observed accuracy stayed close to chance, as expected. The notable result is that the reported probabilities did not reflect that known uncertainty."
  - 저자 스스로의 한계 원문: "These results are specific to the prompts and conditions in this repository. They do not establish that Jev probabilities are generally unusable."
  - 호출 경로는 Vercel AI Gateway, 모델 리비전은 응답에 기록되지 않았고 "the experiments were run during the launch window when jev-1.13.0 was the only publicly available Jev version."
  - ⚠️ 2차 보도(Substack "The Dark Side of Jev")는 82.9%를 "confidence"라고 불렀지만 README는 "Mean reported probability"입니다. 선택된 선택지에 부여된 확률이지 `confidence` 필드가 아닙니다. 글에서 섞지 마세요.
- (외부) ★ **사전 등록 독립 평가 priorbench.** 출처: https://github.com/priorbench/jev (2026-09-20 생성, README 원문 확인, 원 응답 JSONL 포함). 모델 `typesafe/jev-1.13-20260917`, OpenRouter 경유, 2026-09-20 서유럽에서 측정, 5,721회 호출.
  - "It always answers." 원문: "A cake recipe is classified as a technical issue at **0.94 confidence**; random letters at **0.97**." 그리고 "Without an explicit "none of these" option, **0 of 30** out-of-scope messages were flagged" (원문은 이어서 그것이 0.99 confidence였다고 적음)
  - 임계값 원문: "**Gate at 0.99 or not at all.** Accuracy above threshold is flat from 0.50 to 0.95, then jumps to **100 % at 0.99, covering 60.2 % of traffic**."
  - 벤더 문서와 반대되는 발견 원문: "**TypeSafe's own documentation understates the model.** Its "jaggedness" page says Jev cannot compare numbers and that date ordering is unreliable. We measure **99.6 % across 13 designs**."
  - 권고 중: "Always offer an explicit "none of these" option." 그리고 문서의 경고를 직접 재현해 보라는 권고(원문에 em dash가 있어 인용 대신 요지만 적음)
  - 향후 계획 중 버전 관련 구절: "a silent model update shows up as a diff, not as a surprise" (문장 일부)
  - 한계 원문: "Everything here was produced in a single evening. It is a **wide, shallow pass**" / "**One location, one day, one model version.**" / "**Our benchmarks are ours**". 작성자는 익명(`1j6c`)입니다. **단일 출처, 얕은 1차 측정**으로만 쓰세요.
- (외부) The Register, Joab Jackson, 2026-09-23, "Shut up and calculate: Jev's new AI primitives for coders". 기자가 직접 테스트하지 않았습니다. 원문 중: "Basically, Jev is a classifier with brains." / "So using Jev requires some old-school manual configuration ahead of time, compared to the free-wheeling prompting required to generate LLM responses." / Mo Bitar 인용 "I know it’s fast. I know it’s cheap, but is it good?" / 기사 스스로 "Jev is an LLM, but thus far, we have limited insight (or benchmarks) into Jev’s intelligence." 출처: https://www.theregister.com/devops/2026/09/23/shut-up-and-calculate-jevs-new-ai-primitives-for-coders/5298431
  - ⚠️ 이 기사는 Jev를 "an LLM"이라고 쓰는데 회사 FAQ는 "neither small nor an LLM"입니다. 확정 불가(미해결 질문).

요약을 거친 것 (원문 대조 필요):

- (외부) Archer Hume, "Jev’s Architecture Unmasked", 2026-09-17. 약 10,000회 호출로 지연시간 패턴 등을 역공학. WebFetch 요약에 따르면 단일 forward pass와 선택지 위 softmax 판독은 "High" 신뢰, sparse MoE는 "least certain", 1,200개 MMLU 문항 ECE 0.0313, 작성자 스스로 "This is clearly all quite speculative."라고 적음. 출처: https://archerhume.com/posts/jevs-architecture-unmasked/
- (외부) dev.to 집계 "Jev After Eight Days of Independent Tests" (xbill, 2026-09-24). 여러 제3자 연구를 모은 2차 집계입니다. 요약에 따르면 "Fit a temperature on 50 to a few hundred of your own labels"를 권하고, 보정 오차의 방향이 도메인마다 바뀐다고 함. 원 연구 미확인. 출처: https://dev.to/gde/jev-after-eight-days-of-independent-tests-level-with-mid-price-llms-behind-the-frontier-1kln
- (외부) Vercel 설명 페이지(https://vercel.com/i/what-is-jev): WebFetch 요약에 "An answer can fit the allowed values and still misinterpret the evidence"라는 문장이 있다고 나옴. 원문 대조 전에는 인용 금지.

### E-8. 공개 범위, 가격, 사용 조건 (발행 시점 기록용, 2026-09-28 기준)

- 공개 형태: **API 전용, 얼리 액세스(대기자 명단).** 블로그 "Today, we are opening early access and bringing developers off the waitlist as quickly as we can." 보도자료 "Early access to its first frontier model, Jev, is waitlisted at typesafe.ai."
- 오픈 가중치: 없음. 공개 자료 어디에도 가중치 공개 언급이 없고, 문서 원문 "the same weights serve every account"(models .md 44행)는 API 단일 서빙을 가리킵니다.
- 논문: 없음. RLCD 방법도 비공개(HN의 회사 측으로 보이는 계정 "we have talked about writing a paper").
- 현재 모델: `jev-1.13.0`, 별칭 `jev-latest`와 `jev-preview`가 모두 이 버전을 가리킴("There is no preview build available right now.").
- 가격: 입력 $0.042 / 100만 토큰, 출력 무료. (models .md 13, 18행)
- Rate limit: "250,000 tokens per second / 1,200 requests per minute". 그런데 바로 아래 경고 원문 "the limits above can change without notice while we do, as upcoming large GPU deals land and we let in more users." (models .md 14, 24행)
- 컨텍스트: "64k tokens per request; 32k tokens for `state` plus the longest question" (models .md 15행)
- 오류 코드: `429 Too Many Requests`(호출자 한도 초과)와 `529 Overloaded`(TypeSafe 측 과부하)를 구분합니다. SDK는 둘 다 지수 백오프로 자동 재시도합니다. (api .md 333~338행)
- SDK: Python(`typesafe_sdk`), JavaScript(`@typesafe-ai/sdk`). GitHub `typesafe-ai/typesafe-sdk-python`, `typesafe-sdk-js` 모두 2026-09-04 생성.
- 제3자 경로: priorbench는 OpenRouter(`typesafe/jev-1.13-20260917`), 주사위 실험은 Vercel AI Gateway로 호출. OpenRouter 모델 API에는 `typesafe/jev-router`("Jev Router picks the best model and reasoning effort for each request")가 2026-09-25 생성으로 등재돼 있습니다(설명 뒷부분은 잘려 있어 미확인).
- 데이터: "Jev is not trained on customer requests or responses." (models .md 56행)

### E-9. 매니페스토의 AGI 언급 (AGI 편과 만나는 외부 근거)

- (외부) 원문: "We’re not racing towards the ever-moving goalposts of “AGI,” because today’s models have long since crossed the threshold of intelligence needed for creating massive economic value." / "That should tell us something: the bottleneck isn’t raw intelligence. It’s that today’s intelligence is hard to build on." / 마지막 문장 "We're building prod, not God." 출처: https://typesafe.ai/manifesto
- (외부) 매니페스토가 스스로 세운 목표의 정의(부록 원문): "There are many definitions of this, but our favorite is global TFP growth reaching 3% within five years and holding at that level for ten". AGI라는 판정 불가능한 목표를 버리고 **측정 가능한 수치 목표**로 바꿔 적은 형태입니다.
- (외부) 신뢰 조건 원문: "It takes trust to bury a dependency five layers deep in a system. People will only do so if they can inspect it, test it, and constrain it piece by piece, the way we’ve always engineered dependable software."
- (외부) "Software has never worked that way. Even the most complex software is built out of simple logic and layered abstractions, with every branch auditable."
- HN에서도 이 언급을 문제 삼는 댓글이 있습니다(kypro): "why are they bringing up AGI given there approach is so restrictive that what they're building literally cannot have the creativity required for AGI?"

---

## 근거 I: 내부 (기존 발행본과의 연결 지점)

작업물 근거가 없으므로 연결 지점만 정리합니다. 전부 발행본 원문과 줄번호를 확인했습니다.

### I-1. AGI 편 (`_posts/2026-09-08-agi-word-to-gate.md`)

- (내부) 이 글이 남긴 질문 세 개: "**이 산출물이 틀렸다는 걸 무엇이 알려주는가. 그 답은 조회인가 판단인가. 그리고 그게 틀렸을 때 되돌리는 데 무엇이 필요한가.**" 출처: `_posts/2026-09-08-agi-word-to-gate.md:401`
- (내부) 틀린 모양에 대한 관찰: "검토는 모호하게 틀리지 않았습니다. **구체적인 수치를 달고 틀렸습니다.**" 출처 `:113` / "**전부 읽어서는 걸리지 않는 형태로 틀렸습니다.**" 출처 `:244`
  - 연결: priorbench의 "케이크 레시피를 technical issue로, 0.94 confidence"와 주사위 82.9%는 정확히 "수치를 달고 틀린" 모양입니다. 타입이 맞는 오답은 읽어서는 걸리지 않습니다.
- (내부) "넷 다 판단이 아니라 조회입니다. **그리고 조회는 모델 성능과 무관하게 같은 답을 냅니다.**" 출처 `:248`
  - 연결: jaggedness 문서의 "count belongs in code". priorbench가 "문서가 모델을 과소평가한다(수 비교 99.6%)"고 반박했지만, AGI 편의 논리로 보면 계산을 코드에 두는 이유는 모델이 못 해서가 아니라 **코드의 답이 모델 버전과 무관하기 때문**이라 권고는 그대로 섭니다.
- (내부) "확률적인 판단을 exit 코드 하나로 귀결시킨 것입니다." 출처 `:282` (flowcast의 `scan-sensitive.sh`에 대한 서술)
  - 연결: Jev의 설계는 모델 출력 자체를 "임계값 한 줄로 분기할 수 있는 숫자"로 만든 것입니다. 이 블로그가 스크립트로 해 온 일을 모델 인터페이스가 떠맡은 모양입니다.
- (내부) "여기서 눈여겨볼 것은 목록이 아니라 **네 기준에 없는 것**입니다. "모델이 이건 잘 못한다"가 하나도 없습니다. 네 기준은 전부 결과의 성질을 말합니다." 출처 `:310` / "**이 선은 애초에 모델 성능 축 위에 놓여 있지 않아서, 그 축이 움직여도 따라 움직이지 않습니다.**" 출처 `:312`
  - 연결: Jev 문서의 임계값도 결과의 성질("recoverable", "destructive", "cost of being wrong")로 나누지만, 그 선을 **확신도 값**으로 표현합니다. 확신도는 모델 성능 축 위에 있고 버전이 바뀌면 다시 재야 합니다(E-6 models .md 40행). 같은 기준을 서로 다른 축에 그린 셈입니다.
- (내부) "**분할의 기준은 능력이 아니라 권한이고, 권한을 나누는 이유는 한 판단이 다른 판단을 조용히 덮어쓰는 것을 막기 위해서입니다.**" 출처 `:374`
  - 연결: Jev는 "choose its own next action"을 하지 않습니다. 모델의 출력 타입이 행동을 표현할 수 없게 설계돼 있어서, 권한 회수가 모델 설계 수준에서 이뤄져 있습니다.
- (내부) "조회는 모델이 좋아져도 같은 답을 내고, 되돌리기 어려움은 모델이 좋아져도 그대로 어렵습니다." 출처 `:397`

### I-2. 하네스 책 편 (`_posts/2026-07-29-harness-engineering-book-overview.md`)

- (내부) 채드 파울러 인용 명제: "패턴은 이렇습니다. 안쪽은 확률론, 가장자리는 결정론." 출처 `:232`
  - 연결: Jev 문서의 "Keep control flow, deterministic rules, and side effects in code."는 이 명제를 제품 인터페이스로 굳힌 형태입니다. 다만 경계가 **코드 안의 `if confidence > x`** 로 들어오면서, 결정론 쪽 가장자리에 확률값이 조건식으로 박힙니다.
- (내부) "이 버그들 중 어느 하나도 TypeScript 컴파일러가 잡지 못했습니다." 출처 `:172` / "타입 시스템은 모듈 안쪽의 정합성은 보장해도 모듈 **사이의 약속**은 보장하지 못한다." 출처 `:174`
  - 연결: HN의 "Type safety is not factual correctness."와 같은 구조입니다. 타입 보장은 형식의 보장이고, 이 블로그는 이미 한 번 그 차이를 기록했습니다.
- (내부) "**자기 검토를 막는 방법은 설득이 아니라 권한 회수다.**" 출처 `:162`
- (내부) 유효기간: "각 구성요소가 **모델의 어떤 능력이 부족하기 때문에 존재하는지**를 적어 두라고 한다." 출처 `:275` / "**모델이 강해질수록 하네스의 한계 효용은 줄어든다.**" 출처 `:281` / Build to Delete가 "그때가 언제이고 무엇이 남는지에 대한 답은 아니다." 출처 `:283`
  - 연결: 확신도 임계값은 유효기간이 **모델 버전 ID로 명시된** 하네스 구성요소입니다. 벤더 문서가 "pin that version's ID"를 권하는 순간, "그때가 언제인가"에 대한 답 하나(다음 버전이 나올 때)가 생깁니다. AGI 편 `:395`가 이어받은 이 열린 질문의 한 조각을 채울 수 있습니다.

### I-3. 레이트리미터 편 (`_posts/2026-08-09-rate-limiter-payment-platform.md`)

- (내부) "그러니까 트레이드오프를 고르는 것보다 먼저 해야 할 일은, **지금 무엇이 나 대신 골라져 있는지 확인하는 것**입니다. 라이브러리 기본값이 곧 정책이니까요." 출처 `:631`
  - 연결 두 가지. (1) SDK 기본값이 별칭 `jev-latest`라서, 별칭이 옮겨 가면 고정해 둔 임계값 뒤의 모델이 조용히 바뀝니다. (2) Choice의 선택지 목록에 "해당 없음"이 없으면 모델은 반드시 하나를 고릅니다(priorbench 0/30). **선택지 목록이 곧 정책**입니다.
- (내부) "**런타임 버전이 라이브러리를 고르고, 라이브러리가 알고리즘을 고르고, 알고리즘이 정책을 고쳤습니다.**" 출처 `:629`
- (내부) "**버스트 허용치를 설정으로 노출하고 테스트로 잠근다.**" 출처 `:613`
  - 연결: priorbench의 "a silent model update shows up as a diff, not as a surprise"와 같은 처방입니다. 임계값과 모델 버전을 설정으로 드러내고 자기 데이터로 된 회귀 세트로 잠그는 것.
- (내부) "서비스는 "동작하는가"로 완성되지만, 안전은 "지금 무엇을 통제하고 있는지 설명할 수 있는가"로 완성됩니다." 출처 `:633`
- (내부, 약한 연결) 429와 503의 구분(`:31-34`). Jev API도 429(호출자 한도)와 529(벤더 과부하)를 나눕니다. 다만 이건 인사이트라기보다 사실 대응이라 본문 재료로는 약합니다.

---

## 인사이트 후보

근거가 받쳐 주는 것만 올렸습니다. 괄호 안은 근거 번호입니다.

1. **"환각이 없다"는 실패를 없앤 게 아니라 실패의 모양을 바꾼 것이다.** 문자열 출력의 실패는 파싱 에러로 시끄럽게 드러나지만(어댑터의 `n_retries_malformed_structure`가 그 비용의 흔적), 타입 보장 출력의 실패는 **선택지 안의 그럴듯한 오답**으로 조용히 분기를 탑니다. 벤더 스스로 0%의 근거가 "Schema matching is guaranteed"라고 밝혔고, 회사 측으로 보이는 계정도 "Type safety is not factual correctness."에 동의했습니다. 케이크 레시피가 0.94로 기술 문의가 되는 모양은 AGI 편의 "구체적인 수치를 달고 틀린" 사례와 같은 형태입니다. 근거: E-5, E-7(HN, priorbench), E-4(어댑터), I-1 `:113`, `:244`, I-2 `:172-174`

2. **"모르겠다"는 확신도가 아니라 답의 공간에 들어 있어야 한다.** Choice는 상대적 판단이라 범위 밖 입력에도 반드시 하나를 고르고, 확신도는 고른 선택지들 사이의 퍼짐일 뿐 "애초에 이 질문이 맞는가"를 말하지 않습니다. 벤더 문서(날짜 추출의 "not stated" 선택지, Noul은 절대 판단이라 전부 낮을 수 있다는 설명)와 독립 측정(0/30, 주사위 Choice 82.9% 대 Noul 19.2%), HN의 "It can't abstain."이 같은 지점을 가리킵니다. 레이트리미터 편의 "기본값이 곧 정책"을 옮기면 **선택지 목록이 곧 정책**입니다. 근거: E-6(jaggedness 84, 137행), E-7(dice, priorbench, HN bigglebear), I-3 `:631`

3. **확률을 돌려받는 순간 "이게 틀렸다는 걸 무엇이 알려주는가"의 답이 호출하는 쪽으로 넘어온다.** 보정은 집단의 성질이라 개별 답을 보증하지 않고, 벤더는 공개 벤치마크를 싣지 않는 대신 "your data"로 임계값을 재라고 합니다. 벤더의 비교 평가도 정답이 아니라 다른 모델 평균과의 일치를 쟀습니다. 질문 유형끼리 확률을 섞으면 1.19 같은 값이 나오고, 여러 답을 가중합한 점수는 따로 보정되지 않습니다(HN thduabmd). 그러니 **틀림을 알려주는 것은 확률값이 아니라 호출자가 가진 라벨 데이터**이고, 그 데이터를 만드는 일이 도입 비용의 본체입니다. 근거: E-5(평가 방식, FAQ), E-6(보정 문장, 787행, 1.19), E-7(HN thduabmd, dev.to 집계), I-1 `:401`

4. **확신도 임계값은 유효기간이 모델 버전으로 적힌 하네스 구성요소다.** 벤더 문서가 임계값을 튜닝했다면 버전 ID를 고정하라고 권합니다. 하네스 책 편이 "그때가 언제인가"를 열어 두었는데, 이 구성요소에 한해서는 답이 명시돼 있습니다. 다음 버전이 나오는 때입니다. 레이트리미터 편에서 라이브러리 교체가 버스트 정책을 조용히 바꾼 것처럼, 별칭 교체는 임계값의 의미를 조용히 바꿉니다. 처방도 같습니다. 설정으로 드러내고, 자기 데이터 회귀 세트로 잠급니다. 근거: E-6(models 40행), E-7(priorbench 계획 구절), I-2 `:275-283`, I-3 `:613`, `:629-631`

5. **확신도와 되돌릴 수 있음은 다른 축이다.** 벤더 문서도 임계값을 결과의 성질("recoverable", "destructive", "cost of being wrong")로 나눕니다. 그런데 그 선을 확신도 값으로 그리면 두 군데가 흔들립니다. 하나는 버전이 바뀌면 다시 재야 한다는 점이고(후보 4), 다른 하나는 같은 회사의 두 문서가 송금 승인에 대해 "0.9를 넘어도 확인"과 "0.85를 넘으면 자동"으로 갈린다는 점입니다. AGI 편이 관찰한 선(되돌리기 어려운 동작 앞의 사람 승인)은 모델 성능 축 밖에 있어서 움직이지 않습니다. 확신도는 되돌릴 수 있는 동작 안에서 **얼마나 자주 사람에게 넘길지**를 정하는 데 쓰고, 사람 확인이 **존재하는지**는 되돌릴 수 있는가가 정한다는 구분이 두 문서의 불일치를 설명합니다. 근거: E-6(두 문서 원문, noul 367행, confidence 204, 216행), E-7(priorbench "flat from 0.50 to 0.95", 단일 출처), I-1 `:310-312`, `:397`
   - ⚠️ 이 후보의 마지막 문장(구분 규칙)은 근거를 종합한 **해석**입니다. 벤더가 그렇게 말한 적은 없습니다. 글에서는 "이렇게 읽으면 불일치가 설명된다" 수준으로 쓰세요.

6. **생성 대신 판단을 반환한다는 선택은 모델에서 행동 권한을 구조적으로 뺀 것이다.** 모델은 다음 행동을 고르지 않고, 제어 흐름과 부작용은 코드에 남습니다. 하네스 책 편의 "권한 회수"와 AGI 편의 "분할의 기준은 능력이 아니라 권한"이 모델 인터페이스 수준에서 이뤄진 사례입니다. 판단과 계산의 경계도 벤더가 먼저 긋습니다("Arithmetic is not, so keep it in code"). priorbench가 모델이 수 비교를 해낸다고 반박했지만, 계산을 코드에 두는 이유가 능력이 아니라 모델 버전과의 무관함이라면 그 반박은 권고를 무너뜨리지 않습니다. 근거: E-6(238, 243, 264행, jaggedness 43, 82행), E-7(priorbench 99.6%), I-1 `:248`, `:374`, I-2 `:162`, `:232`

묶이지 않는 후보 (소주제에 넣지 않음):

- 매니페스토가 AGI를 버리고 TFP 3%라는 측정 가능한 목표를 적은 것(E-9)은 AGI 편 `:77`의 "판정할 수 없는 조건을 문서에서 빼고" 관찰과 맞닿지만, 이 글의 줄기(호출하는 쪽 코드)와는 결이 다릅니다. 쓴다면 도입이나 맺음의 한두 문장이 한계입니다.
- 속도와 비용 배수(E-5)는 전부 주장이고 출처마다 다릅니다. 인사이트가 아니라 "주장 표기 연습"의 재료입니다.
- 아키텍처 추정(E-7 Hume, TypeSafe 조직의 LLaDA 포크)은 확인 불가라 후보에서 뺐습니다.
- 429와 529의 구분(E-8, I-3)은 사실 대응이라 약합니다.

---

## 소주제 이름 후보

- **틀려도 타입은 맞는 답** : 인사이트 후보 1, 2 (환각 주장의 실제 범위, 조용한 오답, "모르겠다"를 담을 선택지)
- **호출하는 쪽으로 넘어온 확률** : 인사이트 후보 3, 4 (보정은 집단의 성질, 틀림을 알려주는 건 내 라벨 데이터, 버전에 묶인 임계값)
- **확신도와 되돌릴 수 있음** : 인사이트 후보 5, 6 (벤더 두 문서의 송금 승인 불일치, 성능 축 위의 선과 밖의 선, 행동 권한을 뺀 설계)

세 이름 모두 주제라 한국어로 적었습니다. 고유명사(Jev, TypeSafe AI, System One)는 원 표기를 유지합니다. 태그 후보: `AI`, `Jev`, `검증`, `아키텍처` (기존 태그 `AI`, `검증`과 맞춤. 최종 결정은 writer와 사용자 몫).

---

## 이미 발행된 것과의 경계 (중복 회피)

- **AGI 편의 결론을 다시 증명하지 마세요.** "게이트는 조회 또는 되돌리기 어려움에 놓인다"는 이미 내부 근거로 논증됐습니다. 이 글이 보탤 수 있는 건 그 결론을 **확률값이 분기 조건에 직접 들어오는 제품**에 대 보았을 때 생기는 새 문제입니다. 타입이 맞는 오답의 모양(소주제 1), 틀림의 판정 책임 이전(소주제 2), 성능 축 위에 그려진 임계값(소주제 3).
- **하네스 책 편의 "안쪽은 확률론, 가장자리는 결정론"을 설명하지 마세요.** 인용 한 줄로 충분하고, 이 글은 그 경계에 확률값이 조건식으로 박힐 때 무엇이 필요해지는지를 봐야 합니다.
- **레이트리미터 편의 버스트 사고를 다시 서술하지 마세요.** "기본값이 곧 정책" 한 문장과 링크만으로 연결됩니다.
- **테스트 기준 3편**(`_posts/2026-08-11-test-standards-3-delegating-standards.md`)이 검사기 세 개가 같은 것을 세고 다른 답을 낸 기록을 다뤘습니다. 이 글에서 독립 측정끼리 결론이 엇갈리는 부분(priorbench "문서가 과소평가" 대 벤더 jaggedness)은 그 편을 되풀이하지 말고 사실로만 짚으세요.

---

## 미해결 질문

- **[미해소, 유지]** **작성자의 직접 사용 경험이 없습니다.** 가장 좋은 내부 근거는 작은 실험 한 번입니다. 예: (1) Choice에 "해당 없음"을 넣고 뺐을 때 범위 밖 입력의 결과, (2) 한국어 state에서의 `confidence` 분포(문서가 CJK 정확도가 낮다고 적음), (3) `jev-latest`와 `jev-1.13.0` 응답의 `model` 필드 확인. 얼리 액세스나 OpenRouter, Vercel AI Gateway 경로가 필요합니다. **실험 여부는 사용자가 정할 일이고, 하지 않는다면 글은 "공개 자료 읽기"임을 밝혀야 합니다.**
- RLCD의 학습 방법, 아키텍처, 모델 크기, 학습 데이터는 비공개입니다. 논문 없음.
- "Jev는 LLM인가": 회사 FAQ "neither small nor an LLM", The Register "Jev is an LLM", Hume 추정(사전학습 LLM 기반 재목적화, 요약 경유). 확정 불가.
- TypeSafe GitHub 조직에 `vllm`, `LLaDA`(Large Language Diffusion Models) 포크가 있습니다(2025-05, 2025-07 생성). 아키텍처와의 관계는 확인 불가. 글에 쓰지 마세요.
- 공식 보정 지표(신뢰도 곡선, ECE, Brier)는 공개되지 않았습니다. Hume의 ECE 0.0313, dev.to 집계의 중앙값 ECE 0.071은 요약 경유라 원문 대조가 필요합니다. **→ 벤더 공식 지표 부분은 해소: 2026-09-28 재조회에서도 미공개(검증 V-27). Hume, dev.to 수치는 본문에 쓰이지 않아 대조하지 않았고 미해소로 남깁니다.**
- HN 계정 CompleteSkeptic이 Diogo Almeida인지: 정황 추정뿐입니다. **[미해소, 유지] 본문은 "회사 측으로 보이는 계정"까지만 씁니다(검증 V-12).**
- HN 원제목("40-400x cheaper and 20-200x faster")은 댓글 한 건의 진술입니다.
- 투자 규모: 보도자료는 $40M, Dealroom 기사는 제목 $40M에 본문 "US$25.9M seed round"로 자기모순. 보도자료 기준 $40M로 쓰되, 이건 회사 발표입니다.
- 직원 수 25명(검색 결과 요약, Tracxn와 LinkedIn 경유)은 미확인. 쓰지 마세요.
- Kahneman 원서에서 System 1과 System 2의 관계(예: System 2가 System 1을 감시한다는 서술)는 이번에 원문 확인하지 않았습니다. 비유를 넓히려면 `(확인 필요)`로 두고 verifier에게 넘기세요.
- 벤더가 "System One Models can be made more reliable than its alternatives"의 근거를 "in the future"로 미뤘습니다. 이후 공개됐는지 발행 전에 재확인 필요. **→ 해소: 2026-09-28 기준 미공개 확인(검증 V-54).**
- Vercel 페이지 인용문, Hume 글, dev.to 집계, Substack 글은 WebFetch 요약 경유입니다. 원문 인용 전 대조 필요. **[미해소, 본문 미사용] 초안 본문에 이 네 출처의 인용과 수치가 없어 대조하지 않았습니다(검증 V-56). 본문의 "Vercel AI Gateway"는 Vercel 페이지가 아니라 주사위 실험 작성자의 글에서 왔습니다(검증 V-22).**
- `confidence` 계산식: 문서 데모는 선택지 3개에 대한 근사식만 보여 줍니다. 정확한 정의는 미공개.
- The Register가 Andrej Karpathy를 "Anthropic researcher"로 소개했는데 이번 리서치에서 확인하지 않았습니다. 글에 필요 없으니 쓰지 마세요.
- 발행이 늦어지면 다음 항목을 다시 조회해야 합니다: 모델 버전과 별칭, 가격, rate limit, 얼리 액세스 여부, jaggedness 문서(리뷰일 2026-09-17), 두 임계값 예제 문서. **→ 2026-09-28 재조회로 해소: 별칭과 버전(V-37), jaggedness 리뷰일(V-53), 두 예제 문서(V-47) 모두 노트와 같습니다. 가격과 rate limit도 models .md 13, 14행이 노트와 같지만 본문은 쓰지 않습니다.**

---

## 작성 시 지켜야 할 것 (writer에게)

- **"써 봤다"류 서술 금지.** 내부 근거가 없습니다. 도입에서 이 글이 공개 문서와 독립 측정을 읽은 기록임을 밝히세요.
- **수치는 전부 "주장"으로 표기합니다.** 특히 속도, 비용 배수, "환각 0%". 속도는 출처마다 다르다는 사실까지 적는 게 정직합니다(E-5 표).
- **"Jev는 환각하지 않는다"를 사실 문장으로 쓰지 마세요.** 사실로 쓸 수 있는 건 "벤더가 스키마 일치를 근거로 환각 0%라고 주장한다"까지입니다. 스키마 일치 자체도 벤더 주장이며, 이번에 본 자료에서 반례가 보고되지는 않았습니다.
- **벤더의 두 임계값 예제를 인용할 때는 두 문서 모두 코드 원문 그대로** 옮기세요(E-6). 숫자만 뽑아 비교하면 "confirm_then_execute"와 "approve_transfer"의 차이가 사라집니다. 이 차이가 요점입니다.
- **독립 측정은 조건을 붙여 씁니다.** 주사위 실험 저자와 priorbench 저자가 스스로 일반화를 막았습니다(E-7 원문). 82.9%는 "confidence"가 아니라 "선택된 선택지에 보고된 평균 확률"입니다.
- 모델 이름 GPT-6 Astra, Fable 5.1, GPT-5.6 Terra는 TypeSafe 블로그 표기 그대로 씁니다.
- em dash가 든 원문(priorbench 권고문 일부, 문서 AI primer의 마지막 문장 등)은 인용 범위를 조정하세요. 부분 인용은 부분임이 드러나게.
- 외부 인용은 이 노트에 있는 것만 씁니다(#16 계약). 새 인용이 필요하면 verifier 단계에서 노트에 먼저 추가합니다.
- 발행 시점 기록 문장에는 조회일(2026-09-28)을 붙입니다.

---

## 검증 기록

verifier가 2026-09-28에 초안 `_drafts/jev-system-one-model.md`를 전수 검증한 기록입니다. **본문의 외부 인용과 수치, 서지, 내부 인용을 원문에서 직접 조회해 대조했고, 이 노트의 E절과 writer의 서술은 근거로 삼지 않았습니다.** 확정한 항목도 전부 남깁니다(`CLAUDE.md` #16). 초안의 `<!-- 검증: -->` 주석은 발행 때 지워지므로, 근거 사슬은 이 절입니다.

조회 방법(재현용):
- 벤더 문서: `curl https://docs.typesafe.ai/{경로}.md`로 .md 원문을 받았습니다. 줄번호는 이 원문 기준이고, 맨 앞에 "Documentation Index" 안내 3줄이 붙은 상태입니다(노트 E절과 초안 각주가 쓴 줄번호 체계와 같음을 199~213행 등으로 교차 확인). 문서 제목은 각 페이지 HTML의 `<title>`과 .md의 H1로 확인했습니다. 벤더 문서 전체 검색은 `https://docs.typesafe.ai/llms-full.txt`(918,065바이트)로 했습니다.
- 회사 블로그: `curl`로 HTML을 받아 보이는 본문과 Framer 하이드레이션 JSON(접힌 FAQ 답변이 여기 있음)을 함께 읽었습니다. 글 목록은 `https://typesafe.ai/sitemap.xml`로 전수 확인했습니다.
- GitHub 저장소: README 원문은 `raw.githubusercontent.com`, 생성일과 라이선스는 `gh api repos/{owner}/{repo}`, 파일 존재는 `gh api repos/{owner}/{repo}/git/trees/HEAD?recursive=1`.
- HN: `https://hn.algolia.com/api/v1/items/49717558` (댓글 518개, 원시 HTML 텍스트로 문자 대조).
- 보도자료: Yahoo Finance 게재본 HTML. Business Wire 원본 URL은 이번에 `curl` 접속이 HTTP/2 오류와 시간 초과로 실패했습니다. 초안 각주가 이미 "Yahoo Finance 게재본으로 조회"라고 밝히고 있어 본문 진술에는 영향이 없습니다.
- 영문 인용문 전체는 스크립트로 원문 코퍼스(위 자료 전부)와 문자 단위로 대조했습니다(마크다운 굵게, 기울임, 백틱과 공백 차이만 무시). 곡선 아포스트로피가 어긋난 2건 외에는 모두 축자 일치했습니다.

결과 요약: **검증 항목 56건(V-1~V-56) / 확정 48건 / 초안 교정 7건(수정 지점 11곳) / 확인 불가 0건 / 본문 미사용이라 검증 대상 아님 1건(V-56) / 주장 재검토 필요 1건(V-47, 확정 항목 안의 해석 문장)**
- writer 플래그 5건: 1번 V-8, 2번 V-27, 3번 V-37, 4번 V-47, 5번 V-54. 다섯 건 모두 원문으로 확정했고 플래그를 지웠습니다. 4번은 발췌와 하한값은 확정이지만, 관련 해석 문장 하나에 사용자 판단을 요청했습니다.
- 초안을 고친 것: V-9(각주 줄번호), V-16(어댑터 "옵션 이름"), V-22(각주 "원 응답"), V-32(HN 인용 아포스트로피), V-41(priorbench 99.6%의 범위), V-50("요약"을 "첫 문장"으로), V-55(각주 문서 제목 4건).
- 노트를 고친 것: E-7 주사위 실험 항목의 "원 응답"에 정정 표시(V-22). 미해결 질문 6개 항목에 해소 여부를 표시했습니다.

### A. 발표와 회사 자료

**V-1. 발표일과 회사 블로그 서지: 확정**
- 대상: 본문 `:9`, `:13`("발표 13일 뒤인 2026-09-28"), 각주 `[^blog]`.
- 서지: TypeSafe, "Introducing System One Models & Jev", 회사 블로그, https://typesafe.ai/blog/introducing-system-one-models-and-jev . 서명 "Diogo Almeida, founder, TypeSafe", 분류 "Company News".
- 확인 방법: 페이지 HTML의 보이는 본문에서 게시일 표기 `Sep 15, 2026`을 확인했습니다. HTML 3행의 주석 `<!-- Published Sep 27, 2026, 10:27 PM UTC -->`는 Framer 배포 시각이라 게시일로 쓰지 않았습니다(같은 사이트 홈에도 "Sep 27, 2026 22:27:29"가 찍혀 있음). HN 스레드 생성 시각 2026-09-15T19:25Z도 발표일과 맞습니다.
- 정합성: 본문의 2026-09-15와 제목이 원문과 정확히 일치합니다. 15일에서 13일 뒤는 28일로 맞습니다.

**V-2. 블로그 한 줄 소개 인용: 확정**
- 대상: 본문 `:11`.
- 결과: "Think of Jev as a frontier-intelligence function call: unstructured state in, typed probabilistic decisions out." 축자 일치(원문은 문장 뒤에 공백 하나가 더 있음).

**V-3. 얼리 액세스와 대기자 명단: 확정**
- 대상: 본문 `:13` "발표문 기준으로 공식 경로는 대기자 명단을 거치는 얼리 액세스".
- 근거: 블로그 "Today, we are opening early access and bringing developers off the waitlist as quickly as we can." / 보도자료 "Early access to its first frontier model, Jev, is waitlisted at typesafe.ai."
- 정합성: 본문이 "발표문 기준"으로 범위를 좁혀 두어 정확합니다. 참고로 2026-09-28 기준 OpenRouter(`typesafe/jev-1.13`)와 Vercel AI Gateway로도 호출할 수 있고, 제3자 측정 두 건이 그 경로를 썼습니다.

**V-4. 속도 수치 네 개와 측정 조건: 확정**
- 대상: 본문 `:15`.
- 결과(출처별 원문):
  - 블로그 비교표 Speed 행: "End-to-end response time is 70ms-500ms for TypeSafe. This can range from 40x-200x faster ..." 본문 인용 부분 축자 일치.
  - 보도자료(Yahoo 게재본): "The model delivers frontier-level intelligence at less than 100 milliseconds of latency and is up to 100 times faster ..." 본문 인용 부분 축자 일치.
  - how-to-build .md 290행: "Most queries complete in about 100 ms." 축자 일치.
  - priorbench README 20행: "**Latency is a fixed cost, not a workload cost.** ~430 ms floor." 측정 조건은 README 8~9행 "accessed through OpenRouter, measured from Western Europe on 20 September 2026". README 131~132행은 "The ~430 ms fixed cost is measured; its cause is hypothesis."라며 게이트웨이 지연과 분리하지 못했다고 적습니다.
  - 블로그 "our published evals are generally run from our laptops on the West Coast (this is where our service is currently based)." 본문 인용 부분 축자 일치.
- 정합성: 본문은 네 수치를 각 출처에 붙여 나란히 적고 "한 줄에 세울 수는 없으니"로 비교를 피합니다. 근거와 같은 강도입니다. The Register의 "as little as 150 ms"는 본문에 없습니다(V-56).

**V-5. 보도자료 서지: 확정**
- 대상: 각주 `[^pr]`.
- 서지: Business Wire, "TypeSafe AI Emerges From Stealth With $40M in Funding With New Model for Composable AI", 데이트라인 "SAN FRANCISCO, September 15, 2026--(BUSINESS WIRE)--". 원본 https://www.businesswire.com/news/home/20260915525333/en/ . 조회본: Yahoo Finance 게재본 https://finance.yahoo.com/technology/ai/articles/typesafe-ai-emerges-stealth-40m-190000776.html (게재 표기 "Business Wire September 16, 2026").
- 확인 방법: Yahoo 게재본 HTML에서 "This is a paid press release. Contact the press release distributor directly with any inquiries."와 "View source version on businesswire.com: https://www.businesswire.com/news/home/20260915525333/en/"를 확인했습니다. Business Wire 원본 직접 접속은 실패했습니다(조회 방법 참조).
- 정합성: 각주의 날짜(2026-09-15, 데이트라인 기준), URL, 유료 게재 표시, "회사 발표문으로 다뤘다"가 모두 근거와 맞습니다.

### B. 틀려도 타입은 맞는 답

**V-6. 요청 필드와 질문 키: 확정**
- 대상: 본문 `:9` "프로그램의 상태(`state`)와 호출하는 쪽이 이름을 붙인 질문들(`questions`)".
- 근거: api .md 23행 `state`("string | object | array"), 31~36행 `questions`("A map of typed Question objects. You choose each key; answers come back under the same keys.").

**V-7. 질문 유형 표: 확정**
- 대상: 본문 `:23`~`:29`, 각주 `[^api]`.
- 근거(api .md): Choice `criteria` 최대 255개 125행("You can have a maximum of 255 options per Choice."), 응답 `choice`, `probabilities`("floats that sum to 1"), `confidence` 250~266행. Score `criteria` 162~163행("A Score should have at least two levels; the API accepts up to 10."), 응답 `score`, `legend`, `probabilities`, `confidence` 287~307행. Noul `instructions`, 선택적 `criteria.true/false` 79~95행, 응답 `noul` 0~1 229~231행, "Returns the probability the answer is yes." 75행. 확신도는 223행 "Choice and Score answers also carry a `confidence`"와 confidence .md 145행 "(Noul answers don't carry one.)".
- 정합성: 표의 모든 칸이 근거와 같습니다.

**V-8. [플래그 1] 응답 예시의 `billing`, `technical`, `sales`가 요청 `criteria`의 키인지: 확정**
- 대상: 본문 `:31`.
- 근거: api .md 134~150행 Choice 요청 예시가 `"criteria": { "billing": "Payments, invoicing, refunds", "technical": "Bugs, outages, integrations", "sales": "Pricing, upgrades, new accounts" }`이고, 268~281행 응답 예시가 같은 질문 키 `department` 아래 `"probabilities": { "billing": 0.88, "technical": 0.12, "sales": 0.0 }`, `"confidence": 0.81`입니다. 선택지 키에 대해 128~129행은 "A key you choose. A description of this option."이라고 적습니다.
- 처리: 플래그를 지우고 문장을 그대로 확정했습니다. 본문의 응답 예시 인용도 축자 일치합니다.

**V-9. 확신도 정의 인용: 확정, 각주 교정**
- 대상: 본문 `:33`, 각주 `[^confidence]`.
- 근거: "`confidence` is a statistic computed from the probability distribution the answer already gives you."는 confidence .md **149행**입니다. 145행은 "The answer's `confidence` property collapses that shape into a single number from 0 to 1, ... (Noul answers don't carry one.)" 문단입니다.
- 처리: 각주의 "확신도 정의는 .md 판 145행"을 "149행"으로 교정했습니다. 같은 각주의 송금 예제 199~213행과 216행은 맞습니다.

**V-10. 블로그의 환각 주장 세 건: 확정**
- 대상: 본문 `:39`, `:41`, `:43`.
- 결과: "While Jev gives up string generation, it’s optimized for structured outputs and *can’t* hallucinate."(원문은 can’t에 기울임, 곡선 아포스트로피) / 환각 절 Nuance "Our number is not empirical. Schema matching is guaranteed, thus we can confidently add 0% into the plots." / "Hallucination and type-safety are intrinsically related, and we think the latter is table stakes for automation." 세 인용 모두 축자 일치.
- 정합성: "스키마 일치 자체도 벤더의 주장이지만, 이번에 읽은 자료 안에서 반례가 보고된 것은 없었습니다"는 이번 조회 범위(블로그, 문서 전체본, priorbench README와 REPORT, 주사위 실험 README와 문서, HN 댓글)에서도 반례가 없어 유지됩니다.

**V-11. HN 스레드 서지와 핵심 반론 인용: 확정**
- 대상: 본문 `:45`, `:47`, 각주 `[^hn]`.
- 서지: Hacker News item 49717558, 제목 "Introducing System One Models and Jev", 생성 2026-09-15T19:25:03Z, 1984점, 댓글 518개. 링크 대상은 회사 블로그 글.
- 결과: jacobgold 댓글(id 49718492, 2026-09-15T20:31Z) 원문 "Sure, it can't emit an invalid type, but it can still emit a completely wrong valid value." 원시 텍스트의 아포스트로피가 HTML 엔티티 `&#x27;`(곧은 따옴표)라 본문 표기와 축자 일치합니다. 발표 당일 댓글이 맞습니다.

**V-12. WhitneyLand과 회사 측으로 보이는 계정의 응답: 확정(신원은 미확인 유지)**
- 대상: 본문 `:49`, `:51`.
- 결과: WhitneyLand(id 49719001)의 마지막 문장 "Type safety is not factual correctness." 축자 일치. 그 댓글에 대한 직접 답글이 CompleteSkeptic(id 49719080, parent 49719001)의 "I very much agree with this and want to hone in on where do actually disagree. Would you say a linear classifier hallucinates?"로 축자 일치(원문의 "where do actually"는 원문 그대로의 비문).
- 정합성: 본문은 "회사 측으로 보이는 계정"까지만 쓰고 신원을 단정하지 않습니다. 노트의 미해결 질문과 같은 강도라 유지했습니다.

**V-13. 내부 인용: 하네스 책 리뷰: 확정**
- 대상: 본문 `:53`.
- 근거: `_posts/2026-07-29-harness-engineering-book-overview.md:172` "이 버그들 중 어느 하나도 TypeScript 컴파일러가 잡지 못했습니다." 축자 일치. `:170`에 "런타임 버그 일곱 종을 싣는다"가 있어 "일곱 종"도 맞습니다.

**V-14. 어댑터 README 인용과 서지: 확정**
- 대상: 본문 `:57`, `:59`, 각주 `[^adapter]`.
- 서지: typesafe-ai/system-one-adapter-python, GitHub, 생성 2026-08-08T22:59:50Z, 라이선스 MIT(`gh api`).
- 결과: README 3~4행 "A drop-in replacement for `typesafe_sdk`'s `system_one` evaluation API, backed by LLM APIs instead of TypeSafe." 줄바꿈만 다르고 축자 일치.
- "TypeSafe 공식 조직": 회사 블로그의 "System One LLM" 링크가 이 저장소(github.com/typesafe-ai/system-one-adapter-python)를 가리켜 벤더가 직접 연결한 저장소임을 확인했습니다.

**V-15. 블로그의 LLM 래퍼 문장: 확정**
- 대상: 본문 `:61` 괄호 속 인용.
- 결과: "The LLMs use our System One LLM wrapper, which constrains LLMs to output structured decisions compatible with our API." 축자 일치. 위 V-14대로 이 래퍼가 어댑터 저장소라는 연결("이 래퍼에 태웠다")도 블로그 링크로 뒷받침됩니다.

**V-16. 어댑터가 드러내는 비용: 카운터와 옵션: 교정**
- 대상: 본문 `:61`.
- 근거: README "Response" 절 90~91행 "`response.usage` adds ... `n_retries`, `n_retries_malformed_structure`, and `latency`." 즉 `n_retries_malformed_structure`는 **응답 필드(카운터)**입니다. 재시도 횟수를 정하는 **옵션**은 "Options" 표 139행의 `n_retry_malformed_structure`("Corrective retries when the model's output fails schema validation."). `normalize_probabilities`는 옵션이 맞고 설명 "Rescale invalid LLM probability distributions to sum to 1."이 축자 일치합니다(138행).
- 처리: 본문의 "재시도 카운터"라는 표현은 정확했지만, 둘을 묶은 "어댑터의 옵션 이름으로 드러납니다"가 카운터를 옵션으로 읽히게 해서 "어댑터의 응답 필드와 옵션 이름으로 드러납니다"로 교정했습니다.
- 교정 전: "LLM 쪽 경로에서 그 계약을 지키는 비용이 어댑터의 옵션 이름으로 드러납니다."
- 교정 후: "LLM 쪽 경로에서 그 계약을 지키는 비용이 어댑터의 응답 필드와 옵션 이름으로 드러납니다."

**V-17. priorbench 서지와 측정 조건: 확정**
- 대상: 본문 `:15`, `:65`, 각주 `[^priorbench]`.
- 서지: priorbench/jev, GitHub, 생성 2026-09-20T20:06:58Z, MIT. README 인용 표기 "1j6c (2026). ... an independent, pre-registered evaluation of TypeSafe AI's System One model. https://github.com/priorbench/jev".
- 결과: README 5~9행 "5,721 calls, 21 experiments, $0.176", "Model `typesafe/jev-1.13-20260917`, accessed through OpenRouter, measured from Western Europe on 20 September 2026." / 135행 "**One location, one day, one model version.**" 축자 일치 / 113행 "Every raw response is in `*/raw/*.jsonl`." 실제로 저장소 트리에 `*/raw/*.jsonl` 14개가 있습니다 / 45~46행 "It is a **wide, shallow pass**"(본문 `:184` "저자 스스로 얕다고 한 측정"의 근거).
- 정합성: "익명 저자"는 실명 없이 핸들 `1j6c`와 이메일만 있다는 뜻으로 맞습니다. OpenRouter 모델 API에서 `typesafe/jev-1.13`의 엔드포인트 이름이 `typesafe/jev-1.13-20260917`임도 확인했습니다.

**V-18. priorbench 케이크 레시피 인용: 확정**
- 대상: 본문 `:67`.
- 결과: README 30~31행 "A cake recipe is classified as a technical issue at **0.94 confidence**; random letters at **0.97**." 굵게 표시까지 축자 일치.

**V-19. 내부 인용: AGI 편 "구체적인 수치를 달고 틀렸습니다": 확정**
- 대상: 본문 `:69`, 그리고 `:17`, `:113`의 AGI 편 질문.
- 근거: `_posts/2026-09-08-agi-word-to-gate.md:113` "**구체적인 수치를 달고 틀렸습니다.**", `:79`와 `:401`의 "이 산출물이 틀렸다는 걸 무엇이 알려주는가". 축자 일치.

**V-20. jaggedness의 Choice와 Noul 대비 인용: 확정**
- 대상: 본문 `:73`, `:75`, 각주 `[^jagged]`.
- 결과: jaggedness .md 137행 "the Choice is relative, settling *which* option, while each Noul is absolute and can be low for all of them." 기울임까지 축자 일치.

**V-21. priorbench 0 of 30과 HN "It can't abstain.": 확정**
- 대상: 본문 `:77`.
- 결과: README 31~33행 "Without an explicit "none of these" option, **0 of 30** out-of-scope messages were flagged" 축자 일치(원문은 뒤에 em dash와 "at 0.99 confidence."가 이어져 인용 범위를 거기서 끊은 것이 맞음). HN bigglebear(id 49720872) "because the model is forced to answer in a boolean (if in boolean mode), ... It can&#x27;t abstain." 곧은 아포스트로피로 축자 일치, "참/거짓 모드를 두고"도 원문의 "boolean mode"와 맞습니다.

**V-22. 주사위 실험: 수치, 인용, 조건: 확정, 각주 교정**
- 대상: 본문 `:79`, `:81`, `:83`, 각주 `[^dice]`.
- 서지: KantaHayashiAI/jev-does-not-play-dice, GitHub, 생성 2026-09-18T11:21:53Z, MIT, 마지막 푸시 2026-09-25. 작성자 글: "Jev Does Not Play Dice: 83% probability, 19% accuracy on a hidden fair die roll", https://kantahayashiai.github.io/posts/jev-does-not-play-dice/ .
- 결과:
  - README 결과 표 17행 "Fair six-sided die (Choice) | 16.7% | **82.9%** | 19.0% (76/400)", 19행 "Fair six-sided die (Noul) | 16.7% | **19.2%**". 본문 수치 전부 일치.
  - docs/methods.md "The evaluated probability is `probabilities[choice]`, not `confidence`." 와 "mean reported probability is 0.828550". 본문의 "82.9%는 확신도 필드가 아니라 선택된 선택지에 보고된 확률의 평균"과 정확히 같습니다.
  - README 11행 "The issue is not that Jev failed to predict a random event; the observed accuracy stayed close to chance, as expected. The notable result is that the reported probabilities did not reflect that known uncertainty." 와 24행 "These results are specific to the prompts and conditions in this repository." 축자 일치.
  - 호출 경로: 작성자 글 "I called Jev through the Vercel AI Gateway (typesafe-ai/jev) in the week of its launch." README 30행도 API 실행에 "A Vercel AI Gateway key"가 필요하다고 적습니다. 이 진술은 README 본문이 아니라 README가 링크한 작성자 글에 있습니다.
  - README 95행 "The historical responses do not themselves record an exact model revision. However, the experiments were run during the launch window when jev-1.13.0 was the only publicly available Jev version." 본문 서술과 일치.
- 교정: 각주의 "원 응답과 분석 스크립트가 저장소에 포함돼 있다"를 "기록된 출력과 분석 스크립트가 저장소에 포함돼 있다"로 교정했습니다. docs/data.md가 "These files are recorded experiment outputs, not complete raw HTTP responses."라고 적고, 저장소 트리에는 `data/recorded/*.json`과 `scripts/analyze.py`가 있습니다. 노트 E-7의 같은 표현에도 정정 표시를 달았습니다.

**V-23. jaggedness의 "not stated" 선택지 인용: 확정**
- 대상: 본문 `:85`, `:87`.
- 결과: jaggedness .md 84행(Date and time comparison 절, 날짜 추출 설명) "it gives you somewhere to put an explicit "not stated" option so a missing part is reported rather than guessed." 축자 일치. "날짜 추출 예시에서"도 맞습니다.

**V-24. 내부 인용: 레이트리미터 편 "라이브러리 기본값이 곧 정책": 확정**
- 대상: 본문 `:89`.
- 근거: `_posts/2026-08-09-rate-limiter-payment-platform.md:631` "라이브러리 기본값이 곧 정책이니까요." 본문은 따옴표 안을 명사구로 끊어 인용했고 의미가 같습니다.

### C. 호출하는 쪽으로 넘어온 확률

**V-25. 블로그 비교표의 Confidence 행: 확정**
- 대상: 본문 `:93`.
- 결과: "Always communicates confidence and uncertainty with every output. Calibrated: higher confidence means higher accuracy." 축자 일치(원문은 "More consistent: returns similar answers for similar inputs."가 이어짐. 앞부분만 인용).

**V-26. 보정은 집단의 성질이라는 문장: 확정**
- 대상: 본문 `:95`, 각주 `[^system-one]`.
- 결과: concepts/system-one .md 21행 "Calibration is measured across groups of predictions; it does not guarantee that an individual answer is correct." 축자 일치.

**V-27. [플래그 2] 벤더가 보정 지표를 공개하지 않았다는 서술: 확정**
- 대상: 본문 `:101`.
- 확인 방법(2026-09-28):
  - 벤더 문서 전체본 `llms-full.txt`에서 "expected calibration error", "ECE", "reliability diagram|curve|plot", "calibration curve|plot|chart|error|diagram", "Brier"가 모두 0건입니다. "calibrat" 26건은 전부 개념 설명이나 쿡북의 "not a calibrated guarantee" 같은 문구이고 측정값이 아닙니다. machine-learning-primer의 "well-calibrated model" 설명도 정의 예시(0.2면 20%)일 뿐 Jev의 측정치가 아닙니다.
  - 회사 블로그 글 전수(sitemap.xml 기준 5편: 2026-03-31 "Diogo Almeida - Founders You Should Know", 2026-06-19 "AI: too good to be true, too bad to be useful", 2026-09-10 "The Bitterest Lesson", 2026-09-11 "Lies, Damned Lies, and Benchmarks", 2026-09-15 Jev 발표 글)에 보정 지표가 없습니다. Jev 발표 글 HTML에는 "calibration", "ECE", "Brier"가 0건입니다.
  - 벤더 평가 사이트 https://evals.typesafe.ai/ 는 정확도, 비용, 시간만 싣고 보정 지표는 없습니다.
  - 웹 검색에서도 벤더 발표는 찾지 못했고, 제3자 글들이 "TypeSafe has published no calibration metric of its own"이라고 적는 것만 확인했습니다(2차 자료라 근거로 쓰지 않음).
- 참고: 제3자 측정은 있습니다. priorbench REPORT 4절이 "ECE 0.051, Brier 0.038", AUROC 0.837을 보고합니다. 본문 문장은 "벤더가 공개한"으로 범위를 좁혀 있어 이것과 모순되지 않습니다.
- 처리: 플래그를 지우고 문장을 그대로 확정했습니다.

**V-28. FAQ의 공개 벤치마크 문장: 확정**
- 대상: 본문 `:101`~`:103`.
- 결과: FAQ "How does Jev perform against public benchmarks?"의 답 첫 문장 "We deliberately chose *not* to publish performance against *public* benchmarks." 글자는 축자 일치하고, 원문의 not과 public 기울임이 본문 인용에서 빠졌습니다. 의미는 바뀌지 않습니다.

**V-29. 비교 평가의 기준 답: 확정**
- 대상: 본문 `:105`, `:107`.
- 결과: Workflow evals Nuance "We use the average of GPT-6 Astra and Fable 5.1 as the reference answer, which biases answers towards OpenAI and Anthropic’s models." 곡선 아포스트로피까지 축자 일치. 같은 절 "use the predictions of the largest, smartest, and most expensive external models as reference probabilities"가 "실제 정답이 아니라 다른 모델들의 평균"을 뒷받침합니다.

**V-30. 임계값을 자기 데이터로 재라는 권고: 확정**
- 대상: 본문 `:109`, `:111`, 각주 `[^howto]`.
- 결과: how-to-build .md 787행 "... Test thresholds by plotting confidence against accuracy on your data." 축자 일치.

**V-31. FAQ의 자체 평가 권고: 확정**
- 대상: 본문 `:113`.
- 결과: 같은 FAQ 답의 목록 항목 "Encourage users to create their own evals for their use cases (System One tasks are much easier to evaluate)." 축자 일치.

**V-32. HN thduabmd 두 인용: 확정, 문자 교정**
- 대상: 본문 `:117`, `:119`.
- 결과: 댓글 id 49720703(thduabmd, 2026-09-16T00:34Z, CompleteSkeptic 댓글 49719080에 대한 답글) 원문 두 문장은 "I still have to define the constraints and test which wrong actions get through the complete workflow on my own data. That’s a substantial part of the work being pushed back onto the developer."와 "Even granting that each answer is calibrated individually, that doesn’t establish calibration of the decision that combines them."입니다. 원문은 "That’s a substantial part ..."와 "that doesn’t establish calibration ..."에 곡선 아포스트로피(U+2019)를 씁니다. 초안은 곧은 따옴표였습니다.
- 처리: 두 곳을 원문 문자로 교정했습니다. 나머지 글자는 축자 일치하고, 두 문장이 같은 작성자의 같은 댓글이라는 본문 서술도 맞습니다.
- 교정 전: "That's a substantial part of the work being pushed back onto the developer." / "that doesn't establish calibration of the decision that combines them."
- 교정 후: "That’s a substantial part of the work being pushed back onto the developer." / "that doesn’t establish calibration of the decision that combines them."

**V-33. gut-check determination과 분해 권고: 확정**
- 대상: 본문 `:119`, 각주 `[^intro]`.
- 결과: introduction .md 41행 "Think of each question as a gut-check determination: the kind of judgment a highly knowledgeable person could make in a few seconds given the right context." 43행 "decompose it. Ask each factor as a separate question, then combine the results with logic in your code." 본문 요약과 일치합니다.

**V-34. jaggedness의 0.72, 0.47, 합 1.19 예와 권고: 확정(정합성 메모 있음)**
- 대상: 본문 `:123`, `:125`, `:127`.
- 결과: jaggedness .md 129~133행. 질문은 "Is the customer asking for a refund?"와 그 부정 "Is the customer asking for something other than a refund?", 두 Noul, 티켓 "I was charged twice for the same order. Can someone look into this?", 값 0.72, 0.47, 합 1.19. 137행 "Don't carry a threshold tuned on a Noul over to a Choice, and don't hold the model to arithmetic identities between separate questions." 축자 일치.
- 정합성 메모: `:127`의 "한 질문에서 맞춘 임계값을 다른 질문에 가져다 쓸 수 없으니"는 근거보다 한 걸음 일반화한 필자 추론입니다. 문서가 직접 금지한 것은 Noul에서 Choice로의 임계값 이전과 질문 사이의 산술 항등식 기대입니다. 1.19 예가 서로 다른 질문의 확률이 맞물리지 않음을 보여 주므로 추론 자체는 근거 위에 있다고 보고 문장은 고치지 않았습니다. 강도 조정은 editor와 사용자 판단입니다.
- **→ 해소(2026-09-29, 사용자 결정 "근거 범위로 좁히기"):** `:127` "한 질문에서 맞춘 임계값을 다른 질문에 가져다 쓸 수 없으니, 임계값을 정하는 라벨 데이터도 질문 단위로 쌓여야 합니다." → "문서는 질문 유형 사이에서도 임계값을 옮기지 말라고 합니다. 그렇다면 임계값을 정하는 라벨 데이터도 질문 단위로 쌓는 편이 안전하다고 봅니다." 같은 이유로 `:123` "라벨 데이터가 질문마다 따로 필요한 이유도 문서에 있습니다." → "임계값을 질문 사이에 옮기기 어렵다는 점도 문서에 나옵니다." 문서가 직접 말한 범위와 필자 판단의 경계를 맞췄습니다.

**V-35. 언어별 정확도: 확정**
- 대상: 본문 `:129`, 각주 `[^models]`.
- 결과: models .md 52행 "English is the primary training language and where accuracy is currently best. Other languages, including CJK scripts, are handled but not equally well; test on your own content ..." 본문은 세미콜론 앞까지 인용했고 축자 일치합니다.

**V-36. 별칭 이동과 버전 고정 권고: 확정**
- 대상: 본문 `:137`, `:139`.
- 결과: models .md 40행의 첫 문장 "An alias moves when a new release ships, so the answers behind it can change without a change on your side."와 셋째 문장 "If you have tuned confidence thresholds against a specific version, pin that version's ID instead of the alias and move to the new one on your own schedule." 둘 다 축자 일치.

**V-37. [플래그 3] 별칭이 가리키는 버전, SDK 기본값, 응답 `model` 필드: 확정**
- 대상: 본문 `:141`, `:218`, `:220`.
- 결과(2026-09-28 조회): models .md 31~34행 표에서 `jev-latest`와 `jev-preview` 모두 "Points to `jev-1.13.0`". 37행 "`jev-preview` currently points to the same model as `jev-latest`. There is no preview build available right now." SDK 기본값은 33행 "The default in our client SDKs"와 concepts/system-one .md 53행 "`jev-latest`, which is also the SDK default". 응답 `model` 필드는 models .md 40행 "The response's `model` field reports the versioned ID that answered"와 api .md 184~186행, 응답 예시 `"model": "jev-1.13.0"`(요청은 `"jev-latest"`).
- 처리: 플래그를 지우고 문장을 그대로 확정했습니다.

**V-38. 내부 인용: 하네스 책 리뷰의 "언제"와 AGI 편의 "무엇이 남는가": 확정**
- 대상: 본문 `:143`.
- 근거: `_posts/2026-07-29-harness-engineering-book-overview.md:275` "각 구성요소가 **모델의 어떤 능력이 부족하기 때문에 존재하는지**를 적어 두라고 한다", `:283` "그때가 언제이고 무엇이 남는지에 대한 답은 아니다"(본문 인용 부분). `_posts/2026-09-08-agi-word-to-gate.md:395` "이 글은 그중 앞쪽에는 여전히 답하지 못합니다. **다만 뒤쪽, 무엇이 남는가에 대해서는 관찰 하나를 보탤 수 있습니다.**" 본문 서술과 일치합니다.

**V-39. 레이트리미터 처방과 priorbench 향후 계획 구절: 확정**
- 대상: 본문 `:145`.
- 근거: `_posts/2026-08-09-rate-limiter-payment-platform.md:613` "**버스트 허용치를 설정으로 노출하고 테스트로 잠근다.**" 축자 일치. priorbench README "The plan, in order:" 목록의 "Automate the whole suite." 항목 58~59행 "so a silent model update shows up as a diff, not as a surprise." 본문은 문장 일부로 인용했고 축자 일치합니다.

**V-40. 판단과 계산의 경계: 확정**
- 대상: 본문 `:147`, `:149`.
- 결과: jaggedness .md 82행 "**Instead:** split the work. Extraction is a judgment, so give it to the model. Arithmetic is not, so keep it in code." 인용 부분 축자 일치. 이 문장은 "Date and time comparison" 절에 있습니다.

**V-41. priorbench 99.6%의 범위: 교정**
- 대상: 본문 `:151`.
- 근거: README 26~28행 "Its "jaggedness" page says Jev cannot compare numbers and that date ordering is unreliable. We measure **99.6 % across 13 designs**." REPORT 3번 발견 "We measure **99.6 % across 13 distinct designs** (520 calls)", 설계 목록에 정수, 천 단위 구분자, 소수, 음수, 10¹⁴ 크기, 세 항 비교, **다섯 가지 날짜 형식**이 들어 있고, 문서 주장 대조표는 "99.6 % on numbers and dates across 13 designs | 520".
- 처리: 99.6%는 수 비교만의 값이 아니라 수와 날짜를 합친 값이라 "수 비교에서"를 "수와 날짜 비교에서"로 교정했습니다. 앞 문장이 인용한 jaggedness 권고가 날짜 절 문장이라, 교정 후 대응도 더 정확해집니다.
- 교정 전: "priorbench는 이 문서가 모델을 과소평가한다고 반박했습니다. 수 비교에서 "We measure **99.6 % across 13 designs**."라는 측정입니다."
- 교정 후: "priorbench는 이 문서가 모델을 과소평가한다고 반박했습니다. 수와 날짜 비교에서 "We measure **99.6 % across 13 designs**."라는 측정입니다."

**V-42. 내부 인용: AGI 편 "조회는 모델 성능과 무관하게 같은 답을 냅니다": 확정**
- 대상: 본문 `:151`.
- 근거: `_posts/2026-09-08-agi-word-to-gate.md:248`에 "그리고 조회는 모델 성능과 무관하게 같은 답을 냅니다."가 있습니다(노트 I-1과 같음).

### D. 확신도와 되돌릴 수 있음

**V-43. 사람이나 추론 모델로 넘기라는 문장과 이름의 출처: 확정**
- 대상: 본문 `:155`.
- 근거: concepts/system-one .md 49행 "Answers from System One models also include confidence, so you can decide when to act and when to escalate to a person or a reasoning model." 블로그 FAQ "We were inspired by Daniel Kahneman, Thinking, Fast and Slow. The model class name draws on the distinction between fast, intuitive System 1 thinking and slow, deliberate System 2 reasoning."
- 정합성: 문서 원문은 "넘길 때를 정할 수 있다"이고 본문은 "넘기라고 하는데"라 약간 강하지만, 이어지는 문장이 "그 넘김을 결정하는 것은 ... 호출하는 쪽 코드"라고 적어 원문의 "you can decide"와 같은 결론에 닿습니다. 고치지 않았습니다.

**V-44. Noul 임계값과 오류 비용: 확정**
- 대상: 본문 `:157`, `:159`, 각주 `[^noul]`.
- 결과: primitives/noul .md 367행 "Where to set the threshold depends on the cost of being wrong. Use 0.5 when yes and no are equally easy to act on. Raise it when acting on a false yes is expensive, such as paging someone or issuing a refund. Lower it when missing a true yes is expensive, such as failing to flag a safety issue." 본문 `:165`의 "cost of being wrong"도 이 문장입니다. 본문의 "..."는 "Use 0.5 when yes and no are equally easy to act on."을 생략한 자리이고, 앞뒤 문장은 축자 일치합니다.

**V-45. 확신도 문서의 주석과 216행: 확정**
- 대상: 본문 `:161`, `:163`, `:210`.
- 결과: confidence .md 204행 `# Low stakes. Showing the wrong screen is recoverable.` 축자 일치. 216행 "The 0.5 confidence floor catches anything the model reports as genuinely uncertain. Above that, the threshold for acting without confirmation is higher for a destructive operation than for a read-only one. Your code encodes the risk tolerance." 본문 인용은 "Above that,"까지를 "..."로 생략했고 나머지는 축자 일치합니다. `:210`의 "Your code encodes the risk tolerance."도 같은 행입니다.

**V-46. 내부 인용: AGI 편의 결과 성질 기준과 머지: 확정**
- 대상: 본문 `:165`, `:190`.
- 근거: `_posts/2026-09-08-agi-word-to-gate.md:310` "네 기준은 전부 결과의 성질을 말합니다." 축자 일치. `:290`이 `sr-harness` 플러그인 `CLAUDE.md`의 기준을 인용하고 `:302`가 "되돌리는 데 별도 작업이 필요하다 | `finish` (머지, 브랜치 삭제)"라 "모델 자동 호출 차단 기준"이라는 본문 설명과 맞습니다. `:312` "머지는 모델이 아무리 좋아져도 여전히 되돌리는 데 별도 작업이 필요합니다."가 `:190`의 근거입니다.

**V-47. [플래그 4] 두 송금 예제의 발췌와 하한값: 확정, 관련 해석 1문장은 주장 재검토 필요**
- 대상: 본문 `:169`~`:178`(표와 하한값), `:192`(해석), 각주 `[^confidence]`, `[^routing]`.
- 서지: TypeSafe 문서 "Confidence", https://docs.typesafe.ai/confidence , .md 181~214행 코드 블록. TypeSafe 문서 "Confidence-gated routing", https://docs.typesafe.ai/patterns/confidence-routing , .md 283~304행 코드 블록. 둘 다 2026-09-28 조회.
- 발췌 대조(문자 단위, 들여쓰기만 제외):
  - confidence .md 208행 `if confidence > 0.9:`, 209행 `# High stakes, high confidence. Proceed with confirmation.`, 210행 `confirm_then_execute(account_id)`. 표 1행과 일치.
  - confidence-routing .md 295행 `if action.confidence > 0.85:`, 296행 `# High stakes, but high confidence. Safe to act automatically.`, 297행 `approve_transfer(account_id)`. 표 2행과 일치.
- 하한값 대조: confidence .md 199~201행 `if confidence < 0.5:` / `# Model is genuinely unsure. Don't guess.` / `route_to_human(user_message)`. confidence-routing .md 286~288행 `# Below 0.6 confidence on any action, route to a human` / `if action.confidence < 0.6:` / `route_to_support_agent(account_id)`. 본문의 "0.5 미만", "0.6 미만", "사람에게 넘깁니다"가 원문과 맞습니다. 이 값들은 노트에만 있던 것이 아니라 원문에 있음을 확인했습니다.
- 발췌 때문에 의미가 바뀌는가: 바뀌지 않는다고 판단했습니다. 두 문서 모두 중간 확신도 분기(else)가 `ask_user_to_confirm(...)`이라(confidence .md 211~213행, confidence-routing .md 298~300행) 두 코드의 차이는 높은 확신도 분기에만 있습니다. 블록 전체를 싣지 않아도 "갈리는 건 확신도가 높은 쪽"은 성립합니다. 블록 전체를 실으면 else 분기가 둘 다 확인이라는 점이 눈에 보여 더 설득력이 생기겠지만, 필수는 아니라고 봅니다. 본문 구조는 바꾸지 않았습니다.
- 정합성 메모 1(표현 강도): 본문 `:19`, `:169`의 "같은 송금 예제", "같은 예제"는 느슨한 표현입니다. 두 예제는 한 예제의 복제가 아니라 `check_balance`, `approve_transfer` 분기를 공유하는 서로 다른 예제입니다. 확신도 문서는 선택지가 `check_balance`, `approve_transfer`, `support`이고 `approve_transfer` 설명이 "Approve the pending withdrawal request"입니다. 라우팅 문서는 "voice banking commands" 예제로 선택지가 `check_balance`, `approve_transfer`, `other`이고 설명이 "Approve the pending transfer request"입니다. 같은 동작(`approve_transfer`)을 두고 결론이 갈린다는 요지는 유지되므로 고치지 않았습니다.
- **→ 메모 1 해소(2026-09-29, 사용자 결정 "같은 동작으로 고치기"):** `:19` "같은 송금 예제에서" → "같은 송금 동작을 두고", `:169` "같은 예제, 송금 승인을 다룹니다" → "서로 다른 예제에서 같은 송금 승인 동작, `approve_transfer`를 다룹니다". `:167` 소제목 "같은 송금, 다른 결론"은 동작을 가리키는 말로 읽혀 두었습니다.
- 정합성 메모 2(주장 재검토 필요, `:192`): "확신도 문서는 결과의 성질을 **사람 확인이 있는가**로 표현했습니다. 그래서 확신도가 아무리 높아도 확인 단계는 남습니다."는 확신도 문서의 **코드 예제**에는 맞습니다. 그런데 같은 문서의 **산문**은 반대 틀로 적혀 있습니다. 216행 "Above that, the threshold for acting without confirmation is higher for a destructive operation than for a read-only one."은 파괴적 동작에도 확인 없이 실행하는 문턱이 있고 높이만 다르다는 서술입니다(본문 `:163` 인용문이 바로 이 문장). 169행 "**High confidence:** Act automatically. The model has a clear read and you can proceed without human involvement."도 같은 방향입니다. 확신도 문서는 코드로는 "확인이 있는가", 산문으로는 "임계값의 높이"를 말해 문서 안에서 어긋나고, 산문의 틀은 `:192`가 라우팅 문서에만 돌린 방식과 같습니다. 필자 해석 구간이라 문장을 고치지 않고 초안에 `<!-- 검증: 주장 재검토 필요 -->`를 남겼습니다. 선택지는 "확신도 문서의 코드 예제는"처럼 범위를 좁히는 것, 또는 확신도 문서 자체가 코드와 산문에서 어긋난다는 점을 드러내는 것입니다. 사용자 판단이 필요합니다.
- **→ 메모 2 해소(2026-09-29, 사용자 결정 "어긋남을 드러내기"):** `:192`를 "확신도 문서의 코드 예제는 ... 0.9를 넘어도 확인 단계가 남습니다. 그런데 같은 문서의 산문은 앞에서 인용했듯 파괴적 동작에도 확인 없이 실행하는 문턱이 있고 그 높이만 다르다고 적습니다. 한 문서 안에서도 두 방식이 섞여 있는 셈입니다. 라우팅 문서는 산문 쪽 방식, 곧 **임계값의 높이**를 코드로 옮겼고, ..."로 고쳤습니다. 근거는 위 메모 2의 confidence .md 207~213행, 216행, 169행 그대로입니다.
- 처리: 플래그 단락(`:176`)을 지우고 그 자리에 대조 결과를 담은 검증 주석을 남겼습니다.

**V-48. priorbench 임계값 측정과 0.85, 0.9 해석: 확정**
- 대상: 본문 `:180`, `:182`, `:184`.
- 결과: README 36~37행 "**Gate at 0.99 or not at all.** Accuracy above threshold is flat from 0.50 to 0.95, then jumps to **100 % at 0.99, covering 60.2 % of traffic**." 축자 일치. REPORT 4절 표: 임계값 0.80에서 임계값 위 정확도 97.75%, 0.90에서 97.55%, 0.95에서 97.26%, 0.99에서 100.00%(적용 범위 60.2%).
- 정합성: 0.85는 직접 측정되지 않았지만 0.80과 0.90 사이가 97.75%와 97.55%로 거의 같아 "0.85와 0.9 사이가 임계값 위 정확도를 거의 가르지 않았습니다"는 근거와 맞습니다. 본문이 "일반화할 수는 없습니다"로 단서를 달아 강도도 적절합니다. "벤더 쪽 자료에서 찾지 못했습니다"는 V-27의 조회 범위와 같습니다.

**V-49. 모델이 하지 않는 일과 코드가 쥐는 것: 확정**
- 대상: 본문 `:200`, `:202`.
- 결과: how-to-build .md 238행 "It does not generate code or choose its own next action." 축자 일치. 243행 "Keep control flow, deterministic rules, and side effects in code." 축자 일치(240~248행 "Summary:" 상자의 첫 항목).

**V-50. "같은 문서의 요약도": 교정**
- 대상: 본문 `:204`.
- 근거: "System One is TypeSafe's model for building AI-powered software, not agents."는 how-to-build .md 238행, 본문 첫 문단의 첫 문장입니다. 같은 문서에는 "**Summary:**"라는 이름표가 붙은 상자(240~248행)가 따로 있고 이 문장은 거기에 없습니다.
- 처리: "요약"이 독자를 Summary 상자로 이끌어 "첫 문장"으로 교정했습니다. 인용문 자체는 축자 일치합니다.
- 교정 전: "같은 문서의 요약도 "System One is TypeSafe's model for building AI-powered software, not agents."입니다."
- 교정 후: "같은 문서의 첫 문장도 "System One is TypeSafe's model for building AI-powered software, not agents."입니다."

**V-51. 내부 인용: 권한 회수와 분할의 기준: 확정**
- 대상: 본문 `:204`.
- 근거: `_posts/2026-07-29-harness-engineering-book-overview.md:162` "**자기 검토를 막는 방법은 설득이 아니라 권한 회수다.**" `_posts/2026-09-08-agi-word-to-gate.md:374` "**분할의 기준은 능력이 아니라 권한이고, ...**" 본문은 앞부분을 인용했고 축자 일치합니다.

**V-52. 결론의 "Your code encodes the risk tolerance.": 확정**
- 대상: 본문 `:210`. 근거는 V-45와 같습니다(confidence .md 216행).

### E. 시점 기록과 각주

**V-53. jaggedness 리뷰일과 "공개된 모델은 jev-1.13.0 하나": 확정**
- 대상: 본문 `:220`, 각주 `[^jagged]`.
- 결과: jaggedness .md 10행 "**Applies to `jev-1.13`.** Last reviewed 2026-09-17." 2026-09-28에도 같은 값입니다. models .md "Current models" 표는 `jev-1.13.0` 하나만 싣습니다.
- 참고: OpenRouter 모델 API에 `typesafe/jev-router`("TypeSafe: Jev Router", 2026-09-25 등재)가 있습니다. 설명은 "Jev Router picks the best model and reasoning effort for each request ... It runs on Jev"로, 요청마다 다른 모델을 고르는 라우터이지 Jev의 새 버전이 아닙니다. 본문 진술은 Jev 버전 기준이라 그대로 맞습니다.

**V-54. [플래그 5] 신뢰성 근거를 "in the future"로 미룬 뒤 공개됐는가: 확정(2026-09-28 기준 미공개)**
- 대상: 본문 `:220`.
- 근거: Jev 발표 글 FAQ "Where do the names “System One Models” and “Jev” come from?"의 답 "“System 1 thinking” has also implied error-prone. For reasons we will get into in the future, we believe System One Models can be made more reliable than its alternatives." 2026-09-28에도 이 문장이 그대로입니다.
- 확인 방법: sitemap.xml 기준 회사 블로그 글 5편 중 발표 글 이후 게시물이 없습니다(최신이 2026-09-15). 발표 글의 다른 FAQ 답("Why was a new training algorithm needed?", "These results are kinda crazy - how is it possible?")은 "the bitterest lesson" 글로 안내할 뿐 신뢰성 근거를 제시하지 않습니다. 벤더 문서 전체본에도 해당 설명이 없습니다. 웹 검색("TypeSafe AI Jev RLCD paper calibration" 등)에서 벤더 논문이나 후속 글은 찾지 못했고, 제3자 글이 "TypeSafe has not published a paper describing the loss function ..."이라고 적는 것만 확인했습니다.
- 정합성: 본문의 "대안보다 더 신뢰할 수 있게 만들어질 수 있다고 하면서"는 원문 "can be made more reliable than its alternatives"와 같은 강도입니다. 플래그를 지우고 확정했습니다.

**V-55. 각주 문서 제목 4건: 교정**
- 대상: 각주 `[^howto]`, `[^api]`, `[^jagged]`, `[^routing]`.
- 확인 방법: 각 페이지 HTML `<title>`(형식 "{제목} - TypeSafe AI")과 .md H1, `llms.txt` 목록 이름을 대조했습니다.
- 교정 전 → 교정 후: "How to build with System One" → "How to build with TypeSafe" / "API" → "API reference" / "Model jaggedness: jev-1.13" → "Jev 1.13 jaggedness" / "Confidence routing" → "Confidence-gated routing". URL은 네 건 모두 맞아 두었습니다. 본문 `:169`의 "확신도 라우팅 패턴 문서"는 한국어 풀이라 두었습니다.
- 나머지 각주 제목("Confidence", "System One", "Introduction", "Models", "Noul")과 줄번호(howto 787, 238, 243 / confidence 199~213, 216 / system-one 21, 49 / intro 41 / models 40, 52 / noul 367 / routing 286~304)는 원문과 일치합니다. routing 286~304는 분기 부분(주석 줄부터 닫는 코드 펜스까지)을 가리키고, confidence 199~213도 같은 방식이라 일관됩니다.

**V-56. 본문에 쓰이지 않은 출처: 검증 대상 아님**
- The Register(2026-09-23) 인용과 "as little as 150 ms", Archer Hume 글, dev.to 집계, Vercel 설명 페이지(https://vercel.com/i/what-is-jev), Substack 글, 가격($0.042/MTok, 출력 무료), rate limit, 투자 규모는 초안 본문과 각주에 한 건도 없습니다(초안 전문 검색). 본문 `:15`가 "이 글은 속도와 가격을 다루지 않습니다"라고 밝혀 두었습니다. 그래서 원문 대조를 하지 않았고, 노트의 해당 미해결 질문은 미해소로 남깁니다. 발행 전에 이 출처가 본문에 들어오면 새로 검증해야 합니다.


**V-57. 발행 후 추가한 개요 그림의 요청과 응답 값: 확정 (#111)**
- 대상: 발행본 도입부의 `<figure class="jev-embed">`. 본문 문장은 바꾸지 않고 그림만 덧붙였습니다.
- 대조: 2026-09-29에 https://docs.typesafe.ai/api.md 를 다시 받아 문자 단위로 대조했습니다.
  - Example request(.md 134~150행 부근): `"state": "Help! My payouts have been failing for 3 days."`, `"model": "jev-latest"`, 질문 이름 `department`, `"type": "choice"`, `"instructions": "Which team should handle this?"`, `criteria` 키 `billing`, `technical`, `sales`. 그림에는 state, 질문 이름, instructions, criteria 키를 옮겼습니다.
  - Example response(.md 268~281행 부근): `"model": "jev-1.13.0"`, `"choice": "billing"`, `"probabilities": { "billing": 0.88, "technical": 0.12, "sales": 0.0 }`, `"confidence": 0.81`. 그림의 값과 일치합니다. V-8에서 확정한 키와 확률값도 2026-09-28 조회와 같습니다.
- 그림의 한국어 설명은 이미 검증된 항목에서만 가져왔습니다: 텍스트 입력만 받는다(E-3, `concepts/system-one` .md 16행), 확신도는 분포에서 계산한 값(V-9, `confidence` .md 149행), 응답의 `model`은 실제로 답한 버전(E-3, V-37), 다음 행동을 고르지 않는다(`how-to-build-with-system-one` .md 238행 "It does not generate code or choose its own next action."), 불확실하면 사람이나 추론 모델에게 넘긴다(`concepts/system-one` .md 49행 "a person or a reasoning model").
- 그림의 `if confidence > x:` / `else:` 분기는 벤더 코드 인용이 아니라 본문 도입부의 "`if confidence > x` 모양의 줄"을 도식으로 옮긴 것입니다. 그래서 원문 인용 표시를 하지 않았습니다.
---

## 응집 점검 기록

blog-editor가 2026-09-29에 윤문하며 남긴 기록입니다. 줄번호는 "윤문 전 → 윤문 후" 순서로 적습니다. 문단을 나누면서 윤문 후 줄번호가 최대 12줄 밀렸습니다. 위 `## 검증 기록`의 본문 줄번호(`:192` 등)는 윤문 전 기준입니다.

### 점검 재료 (`cohesion_check.py`)
- 윤문 전: 예고 사슬 불일치 0건 / 플래그 8개 문단(L61, L63, L143, L151, L178, L192, L210, L220, 전부 [긴 문단]) / 세 항목 이상 나열 1곳(L216, 직전에 문단 있음) / 개수와 번호 라벨 0건
- 윤문 후: 예고 사슬 불일치 0건 / 플래그 5개 문단(L61, L157, L186, L200, L220) / 나열 1곳(L226, 직전에 문단 있음) / 개수와 번호 라벨 0건
- 스크립트는 `<!-- 검증: -->` 주석 안의 마침표도 문장으로 셉니다. 그래서 L61, L151(→L157), L192(→L200)의 문장 수가 실제보다 1~2개 많게 나옵니다.
- 윤문 전 L220(시점 기록 문단)과 윤문 후 L220(결론 첫 문단)은 서로 다른 문단입니다. 윤문 전 L210이 윤문 후 L220입니다.

### 예고 사슬
- 이름 {틀려도 타입은 맞는 답 | 호출하는 쪽으로 넘어온 확률 | 확신도와 되돌릴 수 있음} → 도입부 L19의 예고(굵게, 이 순서), `##` 소제목 L21, L93, L161, 결론 L220의 되짚기(굵게, 같은 순서)까지 전부 일치.
- 절을 닫는 문장도 이름을 그대로 받습니다. L91 "틀려도 타입은 맞는 답은", L159 "호출하는 쪽으로 넘어온 확률은", L216과 L232 "확신도와 되돌릴 수 있음을". 동의어로 바뀐 곳이 없습니다.
- 이름에 없는 소제목 10개(`###` 9개와 결론 절 "읽고 나서 남은 것")는 작성자 노트대로 의도된 것입니다. 예고 대상은 `##` 세 절뿐입니다.

### 손본 곳: 배열 (8개 문단)
- L31: "그리고 `confidence`(이하 확신도)는 그 목록 위의 분포에서 계산한 값입니다" → "그 목록 위의 분포에서 계산한 값이 `confidence`(이하 확신도)입니다". 앞 문장 끝의 "선택지 목록"을 앞자리로 받고, 새 용어를 뒷자리로 보냈습니다(연쇄).
- L63 (7문장) → L63, L65: "사라지는 실패"와 "남는 실패"가 갈리는 지점에서 나눴습니다. 긴 문장 "오답인데, 이건 ..."도 둘로 나누고 "이건"을 "이 오답은"으로 받아 지시 대상을 고정했습니다.
- L127 → L129, L131: 사용자가 확정한 두 문장(질문 단위 라벨 데이터)과 한국어 조건을 다른 문단으로 나눴습니다. 확정 문장의 문구는 그대로입니다.
- L141 → L145: 마지막 문장 "`model` 필드가 ... 돌려준다는 점이 그나마 흔적을 남길 자리입니다"(주어와 서술어가 어긋남) → "그나마 흔적이 남는 자리는 응답의 `model` 필드로, 실제로 답한 버전 ID를 돌려줍니다". 앞 문장의 "조용히 바꿉니다"를 "흔적"으로 앞자리에 받고 `model` 필드를 뒤로 보냈습니다.
- L143 (7문장) → L147, L149: 질문의 배경(하네스 책 리뷰, AGI 편)과 답(확신도 임계값)으로 나눴습니다. 첫 문단 끝의 "언제"를 둘째 문단 첫 문장의 "그 '언제'"가 받아 연쇄가 이어집니다. "~적힌다는 것, 이게 ~입니다" 구문은 두 문장으로 풀었습니다.
- L151 → L157, L159: 마지막 문장 "호출하는 쪽으로 넘어온 확률은 ..."은 99.6% 논의가 아니라 `##` 절 전체를 닫는 문장이라 한 문장짜리 문단으로 뗐습니다.
- L192 (8문장) → L200, L202: 두 문서의 표현 방식(L200)과 버전이 바뀔 때의 결과(L202)로 나눴습니다. "앞의 방식이라면 / 뒤의 방식이라면"은 "사람 확인이 있는가로 표현하는 방식이라면 / 임계값의 높이로 표현하는 방식이라면"으로 바꿨습니다. 사용자 결정으로 "한 문서 안에서도 두 방식이 섞여 있는 셈입니다"가 들어가면서, 먼저 나온 문서인 확신도 문서가 두 방식을 모두 품게 됐습니다. 그래서 "앞"이 확신도 문서로 읽힐 여지가 생겼습니다. 바로 다음 문단(L204)의 "앞의 것 / 뒤의 것"은 반대 순서로 대응해서(앞 = 확신도로 정하는 빈도, 뒤 = 사람 확인 유무) 두 쌍이 연달아 엇갈리기도 했습니다. L200이 굵게 세운 두 이름을 그대로 반복해 풀었습니다. 검증 주석의 위치(L200 끝)와 사용자가 확정한 문장은 그대로입니다.
- L220 (6문장) → L230, L232: 시점 기록과, 벤더가 미룬 근거 및 이 글의 해석을 나눴습니다. "송금은 여전히 되돌리기 어렵기 때문입니다"가 둘째 문단의 끝, 곧 글의 마지막 문장으로 남습니다.

### 손본 곳: 문장 표현만
- L13 긴 문장 분리. L15 "이 글의 관심은 ~에 둡니다"(주술 불일치) → 두 문장. L19 문두 "그리고" 삭제(사용자 확정 문구 "같은 송금 동작을 두고"는 그대로).
- L53 "책이 실은 런타임 버그" → "책에 실린 런타임 버그". "실은"이 '사실은'으로 읽힙니다. L105 → L107 "벤더가 실은 비교 평가의 정답도"도 같은 중의성이라 "벤더 블로그의 비교 평가도 ~ 평균을 정답으로 삼습니다"로 바꿨습니다(비교 평가가 블로그에 있다는 것은 L61과 `[^blog]`에 이미 있음).
- L65 → L67 긴 문장 분리. L69 → L71 "이 저장소의 틀린 기록들" → "이 블로그 저장소의 틀린 기록들". 직전 문단이 priorbench 저장소라 지시 대상이 흔들렸습니다. AGI 편 `:113`이 말하는 대상은 이 블로그 저장소입니다(V-19).
- L73 → L75 "모델이 고르지 못한 지점" → "모델의 능력이 고르지 않은 지점". Choice(고르기)를 다루는 문맥이라 '선택하지 못한'으로 읽혔습니다. jaggedness(능력이 들쭉날쭉함)의 뜻으로 고정했습니다.
- L85 → L87 "확신도의 낮음으로" → "낮은 확신도로". L123 → L125 둘째 문장 분리(첫 문장은 사용자 확정 문구 그대로). L155 → L163 "넘기라고 하는데," 분리(V-43의 강도 판단은 그대로).
- L184 → L192 "앞에서 적은 조건(하루, 한 위치, 한 버전, 저자 스스로 얕다고 한 측정)" → "앞에서 적은 조건(하루, 한 위치, 한 버전)을 그대로 두면, 저자 스스로 얕다고 한 그 측정 안에서는". "얕다"는 앞에서 적은 적이 없어서(L67은 "One location, one day, one model version."만 인용) 괄호 밖으로 뺐습니다. 사실 근거는 V-17(README "wide, shallow pass")입니다.
- L190 → L198 "앞 절에서 본 것처럼" → "앞에서 본 것처럼". 버전과 언어 이야기는 직전 `###`가 아니라 앞 `##` 절에 있습니다.
- L204 → L214 "선택지와 척도와 참일 확률" → 쉼표 나열. L206 → L216 긴 마지막 문장 분리. L210 → L220 "따라 읽고 나면 ... 읽힙니다"(읽 중복) → "따라가 보면". L212 → L222 "고르는 일이라고"(일 반복) → "고르는 것이라고".

### 손대지 않기로 한 곳
- L61 (플래그 6문장): 실제로는 5문장이고 검증 주석이 섞여 하나 더 셌습니다. 래퍼 → 계약 분리 → 비용 → 카운터와 옵션 → 뜻풀이로 연쇄가 닫혀 있어 유지했습니다. 첫 문장의 "이 래퍼"도 유지했습니다. L57의 "어댑터"와 같은 대상이지만, 괄호 속 벤더 원문 "System One LLM wrapper"를 옮긴 간접 인용이라 "어댑터"로 바꾸면 벤더가 쓰지 않은 말을 벤더가 적은 것처럼 됩니다. 두 이름이 같은 대상이라는 것은 V-14, V-15가 확인했습니다.
- L157 (플래그 6문장, 윤문 전 L151): 마무리 문장을 뗀 뒤 실제 5문장과 주석입니다. 반박 → 제 판단 → 이유 → AGI 편 연결로 이어지는 연쇄라 유지했습니다.
- L186 (6문장, 윤문 전 L178): "두 문서 모두 낮은 쪽"과 "갈리는 높은 쪽"으로 짝을 맞춘 비교 문단입니다. 확신도 문서와 라우팅 문서가 번갈아 앞자리에 오는 대응이 바로 위 표와 짝을 이루고, 나누면 그 대응이 끊겨 유지했습니다.
- L200 (플래그 7문장): 실제 6문장과 주석입니다. 코드 예제 → 산문 → 섞임 → 라우팅 문서가 산문 쪽을 코드로 옮김, 이렇게 한 줄로 이어진 연쇄라 L202를 뗀 것 말고는 더 나누지 않았습니다.
- L204 "앞의 것 / 뒤의 것": 지시 대상이 바로 앞 문장 안에 굵게 있습니다. L202에서 앞/뒤 표현을 없애 엇갈림도 사라져 유지했습니다.
- L220 (6문장, 결론 첫 문단): 우산 문장("불확실성의 소유권을 호출하는 쪽으로 옮기는 설계") 뒤에 예고 이름 셋을 같은 순서로 되짚고, 마지막 문장이 "책임이 놓인 위치"로 고리를 닫습니다. 세 항목의 "~넘어왔습니다" 반복은 병렬 구조라 유지했습니다.
- L226~228 나열 3항목: 직전 문장 "먼저 확인하고 싶은 것들은 전부 이 글의 해석이 틀릴 수 있는 지점입니다"가 우산이라 유지했습니다.
- L115 "이 세 문장을 이어 놓으면": 글 구조에 붙인 개수 라벨이 아니라 바로 앞 세 인용(FAQ, 비교 평가 기준, 개발 문서)을 가리키는 지시어라 유지했습니다.
- 문체: 해요체 어미 9개로 윤문 전과 같습니다. 새로 쓰거나 나눈 문장은 전부 습니다체로 맞춰 해요체 비율을 늘리지 않았습니다. em dash, 중간점 0건. 인용문, 코드, `<!-- 검증: -->` 주석 7개, `<!-- 작성자 노트 -->` 4개는 손대지 않았습니다.

### 사람 결정 대기
- 없음. 우산 문장이 필요한 곳 0건, 예고 이름 불일치 0건, 편집자 노트 0건.
