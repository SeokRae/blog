---
슬러그: jev-system-one-intro
주제: Jev 입문. 처음 접하는 개발자가 "Jev가 무엇이고, 어떻게 동작하고, 어디에 쓰는지"를 설계 의도 중심으로 이해하게 하는 글 (심화편 `jev-system-one-model`의 앞편)
작성일: 2026-09-29
조회일: 새 외부 자료는 전부 2026-09-29 조회. 기존 노트(`_drafts/jev-system-one-model.research.md`)에서 옮긴 항목은 원래 조회일(2026-09-28)과 번호(E-x, V-x)를 함께 적음
상태: 조회 완료 (2026-09-29). 중간에 네트워크 오류로 한 번 중단됐고, 재개 후 확보분부터 먼저 저장한 뒤 나머지를 채움. 사실 검증 완료 (2026-09-29, `## 검증 기록`, 주장 재검토 필요 1건 VR-37). 응집 점검과 윤문 완료 (2026-09-29, 맨 끝 `## 응집 점검 기록`, 편집자 노트 1건)
---

# 리서치: Jev 입문, 문장 대신 판단을 돌려받는 모델

## 맨 먼저: 이 노트의 성격과 한계

⚠️ **내부 1차 근거가 없습니다.** 작성자는 Jev를 직접 호출해 보지 않았습니다(얼리 액세스). 기존 노트의 판단(`jev-system-one-model.research.md` 26행)이 그대로 유효합니다. 이 글도 "공개 자료 읽기"이고, 사용 경험처럼 쓰면 근거를 넘습니다.

⚠️ **입문편이라 근거의 무게중심이 다릅니다.** 심화편은 벤더 문서의 한계와 제3자 반론이 주 재료였습니다. 입문편은 벤더 문서가 **설계 의도를 스스로 설명하는 문장**이 주 재료입니다. 그래서 이 노트는 "벤더가 이렇게 설계했고 이렇게 쓰라고 한다"를 원문으로 모으고, 그중 수치나 우월성 주장은 따로 "벤더 주장" 표시를 붙입니다.

조회 방법(재현용): 벤더 문서는 `curl https://docs.typesafe.ai/{경로}.md`로 .md 원문을 받았습니다. 줄번호는 이 원문 기준이며, 맨 앞에 "Documentation Index" 안내 3줄이 붙은 상태입니다(기존 노트 V절과 같은 줄번호 체계). 문서 목록은 `https://docs.typesafe.ai/llms.txt`(2026-09-29, 16,019바이트)로 확인했습니다.

---

## 근거 R: 기존 노트에서 옮긴 것 (재조회하지 않음, 원번호 유지)

입문편에 쓸 수 있는 항목만 옮겼습니다. 출처 URL과 원래 번호를 함께 적습니다. 원문은 기존 노트의 해당 번호에 있습니다.

- **R-1 (← E-1, V-1)** 발표일 2026-09-15. 회사 블로그 "Introducing System One Models & Jev", 서명 "Diogo Almeida, founder, TypeSafe". https://typesafe.ai/blog/introducing-system-one-models-and-jev . HTML 주석의 "Published Sep 27, 2026"은 Framer 배포 시각이라 게시일이 아닙니다.
- **R-2 (← E-4, V-2)** 블로그 한 줄 소개 원문: "Think of Jev as a frontier-intelligence function call: unstructured state in, typed probabilistic decisions out." (축자 확인 V-2)
- **R-3 (← E-2, V-43, V-54)** 이름의 유래.
  - System One: 블로그 FAQ 원문 "We were inspired by Daniel Kahneman, Thinking, Fast and Slow. The model class name draws on the distinction between fast, intuitive System 1 thinking and slow, deliberate System 2 reasoning."
  - 같은 FAQ의 단서: "“System 1 thinking” has also implied error-prone. For reasons we will get into in the future, we believe System One Models can be made more reliable than its alternatives." (2026-09-28 기준 근거 미공개, V-54)
  - Jev: 블로그 FAQ 원문 "We named Jev after William Stanley Jevons. We expect machine intelligence to follow a similar path to coal, after steam-engine efficiency led to an increase in demand." 보도자료는 "Jev, a nod to Jevons Paradox".
- **R-4 (← E-3, V-6, V-7, V-8)** 요청 필드 `state`, `model`, `questions`와 질문 유형 표(Choice 최대 255개, Score 2~10단계, Noul은 `confidence` 없음). 아래 N-3에서 2026-09-29 원문으로 다시 확인했습니다.
- **R-5 (← E-3, V-9)** `confidence` 정의 원문: "`confidence` is a statistic computed from the probability distribution the answer already gives you." (https://docs.typesafe.ai/confidence .md 149행)
- **R-6 (← E-3)** 병렬, 독립 평가: "Every *question* is evaluated in parallel and in isolation against the same *state* in one go." (introduction .md 37행). 아래 N-1에서 2026-09-29 원문으로 재확인.
- **R-7 (← E-3, V-33)** gut-check determination (introduction .md 41행), 분해 권고(43행). N-1에서 재확인.
- **R-8 (← E-4, V-14, V-15)** 같은 인터페이스를 LLM으로 구현한 벤더 공식 어댑터 `typesafe-ai/system-one-adapter-python`(MIT, 2026-08-08 생성). README 원문 "A drop-in replacement for `typesafe_sdk`'s `system_one` evaluation API, backed by LLM APIs instead of TypeSafe." 입문편에서는 "계약(질문 유형 + 확률 분포)이 모델과 분리된다"는 설계 사실로만 쓸 수 있습니다. 비용 논의(재시도 카운터)는 심화편 몫입니다.
- **R-9 (← E-4)** 코딩 에이전트용이 아니라는 문장. 아래 N-2에서 2026-09-29 원문으로 재확인.
- **R-10 (← E-6, V-49, V-50)** "It does not generate code or choose its own next action." / "Keep control flow, deterministic rules, and side effects in code." (how-to-build .md 238, 243행) / "System One is TypeSafe's model for building AI-powered software, not agents." (238행, 첫 문장)
- **R-11 (← E-6, V-40)** 판단과 계산의 경계: "Extraction is a judgment, so give it to the model. Arithmetic is not, so keep it in code." (jaggedness .md 82행) / "Before asking a counting question, ask why the count needs a model at all. If the unit is something a regular expression or a parser can find, the count belongs in code and the model has nothing to add." (43행). https://docs.typesafe.ai/model-jaggedness/jev-1.13 , "Last reviewed 2026-09-17"
- **R-12 (← E-6, V-35)** 언어: "English is the primary training language and where accuracy is currently best. Other languages, including CJK scripts, are handled but not equally well" (https://docs.typesafe.ai/models .md 52행)
- **R-13 (← E-6)** 적대적 입력: "State is data, and `jev-1.13` does not treat it as hostile by default." (jaggedness .md 106행)
- **R-14 (← E-8, V-3, V-37)** 공개 범위(2026-09-28 기준): API 전용, 얼리 액세스(대기자 명단). 블로그 "Today, we are opening early access and bringing developers off the waitlist as quickly as we can." 오픈 가중치 없음, 논문 없음. 현재 모델 `jev-1.13.0`, 별칭 `jev-latest`와 `jev-preview`가 모두 이 버전. SDK 기본값은 `jev-latest`. 제3자 경로로 OpenRouter(`typesafe/jev-1.13`), Vercel AI Gateway가 있음(V-3).
- **R-15 (← E-8)** 컨텍스트: "64k tokens per request; 32k tokens for `state` plus the longest question" (models .md 15행). 오류 코드 429와 529 구분, SDK 자동 재시도(api .md 333~338행).
- **R-16 (← E-5)** 비교표 중 Outputs, Sampling, Confidence, Optimized with 네 행 원문은 기존 노트 E-4 표에 있습니다. 비교표 전체 9행은 아래 N-5에서 2026-09-29 원문으로 새로 옮깁니다.
- **R-17 (← E-6)** 사람이나 추론 모델로 넘김: "Answers from System One models also include confidence, so you can decide when to act and when to escalate to a person or a reasoning model." (concepts/system-one .md 49행, V-43). N-1에서 재확인.

입문편에서 **옮기지 않은 것**(심화편 논지라 되풀이 금지): 환각 0% 주장의 근거 분석(E-5), 보정은 집단의 성질이라는 논증(E-6), 두 송금 예제의 불일치(E-6, V-47), priorbench와 주사위 실험(E-7), HN 반론(E-7), 임계값의 버전 유효기간(E-6 models 40행). 아래 "기존 발행본과의 경계" 참조.

---

## 근거 N: 새로 확인한 것 (2026-09-29 조회)

### N-1. 무엇인가: System One과 Jev의 관계

출처: https://docs.typesafe.ai/concepts/system-one (.md), https://docs.typesafe.ai/introduction (.md)

- (외부) **System One은 모델 부류, Jev는 그 첫 모델.** 원문: "System One models are a class of AI models built to make fast, structured decisions that software can use directly. A System One model evaluates a [state](/concepts/state) and returns typed answers and probabilities." (system-one .md 9행) / "Jev is TypeSafe's flagship model and the first System One model." (11행, introduction .md 7행과 11행에도 같은 문장)
- (외부) **LLM과 같은 점과 다른 점.** "Like an LLM, a System One model understands natural-language input. It returns typed decisions and probabilities rather than generated text." (system-one .md 13행)
- (외부) **하지 않는 일.** "System One models do not write replies, produce code, or generate explanations of their reasoning. You define the possible answers through [primitives](/primitives):" (system-one .md 23행)
  - 이어지는 예시 표(25~29행): Choice "Which team should handle this ticket?" → 답의 공간 `billing`, `technical`, or `account` → `choice: "billing"` / Score "How frustrated is this customer?" → 0 = calm, 1 = frustrated, 2 = very frustrated → `score: 1.4` / Noul "Does this message request a refund?" → True or false → `noul: 0.95`. 31행 "These are illustrative configurations and values."
- (외부) **왜 문장이 아니라 판단인가(설계 의도).** introduction .md 9행 원문: "Large language models (LLMs) are designed to produce text for humans to read. When you need a model to make a judgment that your code will consume, that creates a mismatch: you are coercing a text-generation system into outputting structured decisions, then parsing the results back into something your code can depend on."
  - 11행: "Jev evaluates typed *questions* against a *state* and returns structured results directly. No text generation, no parsing. You get typed values and probability distributions that your code can branch on, sort by, and route with. Choice and Score also return [confidence](/confidence), which your code can use to decide whether and how to act on an answer."
- (외부) **introduction의 구조 도식(mermaid, 13~25행).** `state + questions` → "one request" → [TypeSafe AI model: "evaluate each question against the state in parallel"] → "one response" → "typed answers + probabilities + confidence (Choice and Score)" → "**your code** branch, sort, and route". 입문편 도입 그림의 뼈대로 쓸 수 있습니다(심화편 도입 그림과 겹치지 않게 주의, 경계 절 참조).
- (외부) **primitive라는 이름의 뜻.** introduction .md 29행: "TypeSafe exposes three *AI primitives*. Similar to software primitives, our AI primitives are modular, composable, structured, reliable, and fast. Each asks a different type of *question* and returns a different type of answer." primitives .md 238행: "TypeSafe's primitives are the small, typed building blocks you compose in code. They come in pairs: a question defines one judgment for a [System One model](/concepts/system-one) to make about a [state](/concepts/state), and its answer is the typed value that comes back. You compose the answers in your code to make decisions."
  - "reliable, and fast"는 벤더 주장입니다.
- (외부) **시스템 안에서의 자리(환불 예시).** system-one .md 41~45행: "For a refund request, your application can: 1. Build a state containing the customer's message, the relevant transactions, and the refund policy. 2. Ask independent questions together: whether a refund was requested, whether the evidence indicates a duplicate charge, and whether the policy supports a refund. 3. Combine the answers with deterministic checks in code, then route the case for action or review." 47행: "Because System One models return typed, constrained outputs rather than free-form text, your code can inspect and combine its answers into predictable workflows."
- (외부) Kahneman 노트 원문(system-one .md 36행): "The System One name comes from the concept Daniel Kahneman popularized in his book *Thinking, Fast and Slow*. System 1 thinking is fast and intuitive. System 2 is slower and more deliberate. Here, the emphasis is on fast, focused judgments."

### N-2. 무엇이 아닌가 (coding-agents 문서)

출처: https://docs.typesafe.ai/introduction/coding-agents (.md)

- (외부) 9행: "Jev is **not** a drop-in replacement for the LLM behind Claude Code, Cursor, opencode, Copilot, Muse Spark, Grok Bot, or similar tools. Instead, you can use your coding agent as usual to write code that uses Jev to make decisions."
- (외부) 13행: "It does not generate text, write code, or hold a conversation."
- (외부) 19행: "There is no `model: "jev-latest"` setting that turns your coding agent into a Jev-powered agent, because the two systems solve different problems."
- (외부) "When Jev is worth reaching for" 34~39행 원문: "Reach for Jev when your code needs to:" 네 항목
  - "Route a request to one of a fixed set of destinations, and know how confident that routing is."
  - "Score something on a rubric (urgency, quality, risk) and branch on the number."
  - "Check whether a statement is true of a document, message, or record before taking an action."
  - "Replace a fragile prompt that asks an LLM to "return JSON" with a call that returns typed values by construction."
- (외부) 표 28행은 용도를 "for routing, classification, scoring, guardrails, or any structured decision"으로 적습니다. ⚠️ 이 행 원문에는 em dash가 있어("you're building — for routing") 인용할 때 em dash 뒤 구절만 떼어 써야 합니다.
- (외부) 29행: "Jev isn't the tool for this. Keep using an LLM-based coding agent, and use Jev separately wherever your product needs a fast, calibrated, structured decision." ("fast, calibrated"는 벤더 주장)

### N-3. 어떻게 동작하나: 요청과 응답 (API 문서, quickstart)

출처: https://docs.typesafe.ai/api (.md), https://docs.typesafe.ai/introduction/quickstart (.md)

- (외부) 요약 문장(api .md 9행): "Evaluate a `state` against a map of typed `questions` and get back structured `answers`, one per question."
- (외부) 엔드포인트(14~16행): `POST https://api.typesafe.ai/v1/systemone`, `Authorization: Bearer <API_KEY>`.
- (외부) 요청 필드(23~39행):
  - `state` "string | object | array", 필수. "The content to evaluate. A plain string for text, or structured data (object/array) for things like chat logs, records, or the current state of your application."
  - `model` 필수. "Use `"jev-latest"`, TypeSafe's flagship model."
  - `questions` "map<string, Question>", 필수. "A map of typed [Question](#question-types) objects. You choose each key; answers come back under the same keys."
  - ★ 36행: 질문 키는 "A key you choose. The matching [Answer](#answer-types) is returned under this same id. **The key is not sent to the underlying model and is not used in inference.**" primitives .md 276행 Tip도 같은 말: "Question IDs are for your code. They are not sent to the model. Write the complete question in `instructions`, even when the ID seems self-explanatory."
- (외부) 질문 공통 구조(api .md 56행): "A `Question` is one of three types, set by its `type` field. All three share `type` and `instructions`; each adds its own `criteria`." `instructions`도 문자열, 객체, 배열이 가능(58~69행, `potential_duplicate` 예시).
- (외부) 유형별 한 줄(api):
  - Noul(75행) "A yes/no question. Returns the probability the answer is yes." `criteria.true`/`false`는 선택(83~95행).
  - Choice(116행) "Picks one option from a set you define. Returns the chosen option and the full probability distribution." 최대 255개(125행). 선택지 설명은 `null` 가능("use null when an option needs no extra detail").
  - Score(154행) "Rates the state along a rubric you define. Returns a probability-weighted value across your levels." 2~10단계(163행).
- (외부) 응답 필드(api .md 180~206행): `model`("The model that performed the evaluation."), `answers`("One [Answer](#answer-types) per question, keyed by the same ids you used in questions."), `usage`(`input_tokens`, `output_tokens`). 182행 "One answer per question, returned under the same ids you provided."
- (외부) 답 필드(api .md): Choice `choice` "The highest-probability option."(251행), `probabilities` "floats that sum to 1"(255행), `confidence` "How certain the model is, derived from probabilities."(265행). Score `score` "The probability-weighted answer across the levels; can land between levels."(288행), `legend`(292행), `probabilities`, `confidence`. Noul `noul` "The yes/no answer on a scale from 0 (no) to 1 (yes)."(230행). 223행 "Choice and Score answers also carry a `confidence` between 0 to 1, derived from the answer's probability distribution."
- (외부) API 문서의 Score 응답 예시(309~323행): `"score": 1.05`, `"legend": { "0": "Calm", "1": "Frustrated", "2": "Very angry" }`, `"probabilities": { "0": 0.0, "1": 0.95, "2": 0.05 }`, `"confidence": 0.92`. 0×0.0 + 1×0.95 + 2×0.05 = 1.05로 "probability-weighted"가 산술로 맞습니다(필자 계산).
- (외부) API 문서의 Choice 응답 예시(268~281행)는 심화편 도입 그림이 이미 썼습니다(V-57). 입문편은 quickstart 예시를 쓰는 편이 겹치지 않습니다.
- (외부) **quickstart의 세 유형 동시 요청과 응답 원문**(quickstart .md 65~136행). state: "Hi, I've been trying to connect my Stripe account for 3 days and the integration keeps failing. I'm losing sales. Please help ASAP."
  - 요청 질문: `department`(choice, instructions "Which team should handle this", criteria `billing` "Payment or subscription issues", `technical` "Bugs or integration problems", `sales` "Pricing or account questions") / `frustration`(score, instructions "How frustrated the customer appears", criteria ["Calm, just stating facts", "Frustrated but civil", "Very angry, strong language"]) / `is_urgent`(noul, instructions "The message conveys urgency or time-sensitivity")
  - 응답: `"model": "jev-1.13.0"`. `department`: `"choice": "technical"`, `"confidence": 0.78`, `"probabilities": { "technical": 0.85, "sales": 0.0, "billing": 0.15 }`. `frustration`: `"score": 1.0`, `"confidence": 1.0`, legend 0~2, `"probabilities": { "0": 0.0, "1": 1.0, "2": 0.0 }`. `is_urgent`: `"noul": 1.0`. `"usage": { "input_tokens": 392, "output_tokens": 65 }`.
  - ⚠️ 이 값들은 문서의 예시 응답입니다. 실제 호출 결과가 아닙니다(작성자 미호출). 글에서 "문서 예시"라고 밝혀야 합니다.
  - ⚠️ quickstart의 instructions "Which team should handle this"에는 물음표가 없습니다(원문 그대로). API 문서 예시는 "Which team should handle this?"로 물음표가 있습니다. 인용 시 어느 문서인지에 맞춰야 합니다.
- (외부) **SDK 호출 원문**(quickstart .md 153~190행). 153행 "The client reads `TYPESAFE_API_KEY` from the environment and calls `jev-latest` by default." 설치 `pip install typesafe-sdk`(146행, Python >= 3.10, 143행).

```python
from typesafe_sdk import Choice, Noul, Score, TypeSafeClient

client = TypeSafeClient()

ticket = "Hi, I've been trying to connect my Stripe account for 3 days and the integration keeps failing. I'm losing sales. Please help ASAP."

response = client.system_one(
    state=ticket,
    questions={
        "department": Choice(
            instructions="Which team should handle this",
            criteria={
                "billing": "Payment or subscription issues",
                "technical": "Bugs or integration problems",
                "sales": "Pricing or account questions",
            },
        ),
        "frustration": Score(
            instructions="How frustrated the customer appears",
            criteria=[
                "Calm, just stating facts",
                "Frustrated but civil",
                "Very angry, strong language",
            ],
        ),
        "is_urgent": Noul(
            instructions="The message conveys urgency or time-sensitivity",
        ),
    },
)

print(response.answers["department"].choice)  # "technical"
print(response.answers["frustration"].score)  # 1.0
print(response.answers["is_urgent"].noul)     # 1.0
```

  - 또 하나의 SDK 원문(primitives .md 399~436행)은 `with TypeSafeClient() as client:` 형태이고, state가 객체(`ticket_message`, `refund_policy`)이며 instructions가 백틱으로 state 키를 가리킵니다("Does `ticket_message` request a refund?"). 구조화된 state 예시가 필요하면 이쪽을 씁니다.
- (외부) **state와 질문의 역할 분리**(https://docs.typesafe.ai/concepts/state .md). 21행 "Think of state as the material you would present to a panel of experts before asking them to make a judgment." 59행 "The state contains the content and supporting facts. [Questions](/primitives) define the judgments the model should make about that material." 입문편에서 state를 처음 설명할 때 쓸 수 있는 벤더 비유입니다(비유는 처음 보는 개념에만 짧게).
- (외부) 오류(api .md 329~334행): 401, 422("The request body failed validation"), 429, 529.
- (외부) Playground: quickstart .md 11행 "Open the [Playground](https://console.typesafe.ai/playground) and log in." 로그인이 필요합니다. 계정 발급이 얼리 액세스 대기자 명단에 묶여 있는지는 미확인(미해결 질문).

### N-4. 질문 유형: 언제 무엇을 쓰나 (primitives 개요)

출처: https://docs.typesafe.ai/primitives (.md)

- (외부) 표(240~244행): Choice "Which of these options?" / Score "Which level?" / Noul "Is this true?"
- (외부) 246행: "You can ask one question or send several together. Every question in a request sees the same state, is evaluated independently, and returns a typed answer under the ID you chose."
- (외부) ★ **선택 기준 원문(283~287행).**
  - "**Choice** fits when the answer is one of a known set of options with no order between them: routing a ticket to a department, classifying a document type, detecting a programming language. Give the full list of options, and add an `other` or `none of the above` option when the list might not cover every input."
  - "**Score** fits when the answer falls on a spectrum and you can describe what each point on that spectrum means: bug severity, customer frustration, skill level. The levels are yours to define, and the model returns a position along them."
  - "**Noul** fits a clean yes/no question where the probability itself is the useful signal: does this message contain personally identifiable information, is the customer requesting a refund, does the resume mention distributed systems."
- (외부) Noul과 Score의 구분(290~292행 Note): "A Noul value of 0.5 means the model gives yes and no equal probability. It does not mean the candidate has a medium skill level. An unclear definition makes that probability hard to interpret." / "If you want to measure skill level, use a Score with defined levels, such as no experience, some familiarity, daily use, and deep expertise."
- (외부) ★ **코드로 바로 이어지는 쪽을 고르라(295행).** "If two types both seem to fit, prefer the one whose answer your code can act on directly. A Choice between `refund`, `rebook`, and `information` maps straight onto three code paths. A Score of customer frustration maps onto a threshold. A Noul maps onto an `if`."
- (외부) 답 읽는 법(303~305행): Choice "`confidence` summarizes how peaked that distribution is." / Score "`score` is a position along your levels, and can fall between two of them." / Noul "Near 1 is a strong yes, near 0 a strong no, near 0.5 uncertain. Noul has no separate `confidence`."
- (외부) ★ **답이 조합 가능한 두 성질(309~310행).**
  - "**Every answer is constrained to the options you supplied.** The model returns a probability distribution over your options or levels, never a value outside them. Your code never has to recover a value from generated prose."
  - "**Every answer is independent.** One question's answer is not hidden context for another. You can add or remove questions without changing the others' results."
- (외부) 질문 크기(250행): "Ask for a judgment a knowledgeable person makes in a second given the right context. "Does this message convey urgency?" is a good question. "Analyze this message and determine the best course of action" is not. That needs slow reasoning, and it is a signal to break the task into small questions and compose the answers in code."
- (외부) 분해와 가중치(252행): "Instead of "rate this startup pitch", ask about market size, technical feasibility, and differentiation, then weight them in code based on their relative importance. When priorities shift, change the value of weights rather than rewriting a prompt."
- (외부) state의 특정 부분 가리키기(316행): "name it in the `instructions` with a dot-and-index path to its key, including the backticks." 예: "Does `ticket.messages[0].text` request a refund?"(346행)
- (외부) 여러 질문 한 번에(362행): "System One models evaluate every question in a request in parallel. Adding questions barely changes the response time and costs only the tokens for the extra questions, which are cheap. Asking a question you might not need is close to free." ("barely changes", "close to free"는 벤더 주장)
- (외부) 질문 간 의존(456행): "Questions in the same request are independent: one answer does not become context for another question. If a later judgment depends on an earlier answer, make a second request in code." / 458행 "Two requests are the exception, not the rule."
- (외부) ⚠️ **같은 cookbook 수치가 문서마다 다릅니다.** primitives .md 442행은 Parallel questions cookbook을 "11.5x cheaper and 9.6x faster than 13 separate calls"로, `llms.txt`의 같은 cookbook 설명은 "12.2x cheaper and 10.0x faster"로 적습니다. 둘 다 벤더 주장이고, 쓴다면 출처를 붙이고 불일치를 밝혀야 합니다(입문편 본문에는 쓰지 않는 편을 권함).

### N-5. 벤더 블로그 비교표 "Frontiers, Old and New" 전체 9행

출처: https://typesafe.ai/blog/introducing-system-one-models-and-jev (2026-09-29 `curl`로 HTML을 받아 태그를 벗긴 본문 기준. 표 제목 "Frontiers, Old and New", 열 머리 "Existing LLMs" | "System One + Jev")

표시 규칙: **[설계]** = 인터페이스와 동작 방식에 관한 서술로, 문서(N-1~N-4)가 같은 내용을 설계 사실로 뒷받침함. **[주장]** = 수치, 우열, 보장에 관한 벤더 주장으로 이번 조회에서 독립 확인하지 않음. **[혼합]** = 한 셀에 둘이 섞임(어느 구절이 주장인지 옆에 적음).

| 행 | Existing LLMs (원문) | System One + Jev (원문) | 표시 |
|---|---|---|---|
| Optimized with | "Reinforcement Learning with Human Feedback (RLHF) / Reinforcement Learning with Verifiable Rewards (RLVR)" | "Reinforcement Learning for Calibrated Decisions (RLCD)" | [주장] RLCD는 비공개 방법(기존 노트 E-5, 미해결 질문) |
| Optimizes for | "Human preference: writeups and chat responses that human raters prefer." / "Verifiable rewards: outputs that can be programmatically verified." | "Calibrated decisions: answers with epistemically honest probabilities on System One tasks." | [주장] "epistemically honest"는 보정 주장 |
| Inputs | "Unstructured data (e.g. text) with an emphasis on sequential messages." | "Unstructured data (e.g. text) with an emphasis on structured program state." | [설계] `state`가 문자열, 객체, 배열(api .md 23행) |
| Outputs | "Strings / generated text. Strings are flexible and can be anything: chat responses, code, hallucinations, refusals, or even type-safe structured values. To be used by software, responses need to be parsed + validated. There is also always some risk that the AI goes off the rails." | "Type-safe structured values. Possible outputs and structure are defined in advance. The model never makes type errors. All answers are accompanied with calibrated probabilities and confidence scores." | [혼합] "Possible outputs and structure are defined in advance."는 [설계](primitives .md 309행). "The model never makes type errors."와 "calibrated"는 [주장]. 또 "All answers are accompanied with ... confidence scores"는 문서와 어긋남: Noul에는 `confidence`가 없음(api .md 223행, primitives .md 305행) |
| Sampling | "Sequential. Generates one token at a time, each conditioned on the last." | "Parallel. Generates all outputs in a single query. Incredibly efficient and hardware-aware." | [혼합] 질문들이 한 요청 안에서 병렬로 평가된다는 것은 [설계](introduction .md 37행). "Incredibly efficient and hardware-aware"는 [주장]. 샘플러 내부 구조는 비공개 |
| Cost | "Input tokens: from $0.20 to $10 / MTok." / "Output tokens: ~5x more expensive than input tokens." | "Input tokens: $0.042 / MTok ($42 per billion tokens)." / "Output tokens: FREE (too cheap to meter)." | [주장] 가격표(models .md 13, 18행과 같음, R-15). 지속 가능성은 벤더 스스로 "We can’t prove it isn’t subsidized" |
| Speed | "End-to-end response time is 3 to 329 seconds for frontier models.  Fast enough for interfacing with humans, but a big bottleneck when integrated in code." (원문 "models." 뒤 공백 두 칸) | "End-to-end response time is 70ms-500ms for TypeSafe. This can range from 40x-200x faster for the same levels of frontier intelligence for System One shaped queries." | [주장] 출처마다 속도 수치가 다름(기존 노트 E-5 표). 벤더 측정은 "generally run from our laptops on the West Coast" |
| Confidence | "Even if prompted for a confidence estimate, models tend to be overconfident and inconsistent. If a model can do a task 95% of the time but doesn’t say when it’s in the 5%, it can’t automate that task." | "Always communicates confidence and uncertainty with every output. Calibrated: higher confidence means higher accuracy. More consistent: returns similar answers for similar inputs." | [혼합] 확률을 항상 돌려준다는 것은 [설계](Noul은 값 자체가 확률). "Calibrated", "More consistent"는 [주장]. 벤더 공식 보정 지표 미공개(V-27) |
| Use cases | "Human-in-the-loop tasks (chatbots, copilots, coding agents). General and powerful, but requires human oversight because their freedom also means they might go off the rails." / "Verifiable problems (math proofs, kernel optimization). When correctness can be checked cheaply and automatically, LLMs can generate, test, and iterate until they find something that works." / "Demos. The flexibility of strings allows it to be incredible for quickly making prototypes that only work sometimes." | "AI-Powered Workflows / smart if-statements. Structured outputs slot into ordinary software as fuzzy decision rules: classify, route, score, extract, or branch where hand-written logic is too brittle. The surrounding code constrains their freedom, making them easier to compose into reliable systems." / "Map-reducing over big data. Turn petabytes of data into features and insights." / "Real-time applications. 100ms speeds means you can use AI in your applications where UX is critical." / "Verify everything. Score, judge, verify, guardrail, and detect jailbreaks of LLM prompts, reasoning traces, and/or outputs." | [혼합] 첫 항목("smart if-statements ... The surrounding code constrains their freedom")은 [설계] 서술로 how-to-build .md 286행 "Outputs are sortable and can drive smart `if` statements, thresholds, and comparisons."와 맞음. "100ms speeds", "petabytes"는 [주장] |

- (외부) ⚠️ 비교표 셀 원문의 경계: 태그를 벗긴 텍스트에서 Jev 쪽 Use cases의 마지막 세 항목이 한 줄로 붙어 나옵니다("...features and insights.Real-time applications. ..."). 표시 순서와 문장은 위와 같지만, 항목 사이 구분은 HTML 구조로 판단한 것입니다. 인용할 때는 항목 하나씩 끊어 쓰세요.
- (외부) 표 바로 위 문단(블로그): "Our first public model is Jev, available today in early access. Jev achieves similar levels of intelligence on System One tasks compared to existing LLMs, while being two orders of magnitude faster and more efficient. While Jev gives up string generation, it’s optimized for structured outputs and *can’t* hallucinate." 앞 두 문장의 비교("similar levels of intelligence", "two orders of magnitude")와 "can’t hallucinate"는 [주장]. 심화편이 이미 다뤘으니 입문편은 "string generation을 포기했다"는 설계 사실만 쓰는 편이 경계에 맞습니다.
- (외부) 블로그 서두의 문제의식 원문: "Models have been superhuman at chat for years, so where is all the automation?" 그리고 결말부 "We started TypeSafe because we believe that AI needs an interface software could depend on." 입문편의 "왜 문장이 아니라 판단인가"에 벤더 동기로 인용할 수 있습니다(동기 서술이라 주장 판정 대상 아님).

### N-6. 어떻게 설계하나: how-to-build 원칙과 패턴

출처: https://docs.typesafe.ai/concepts/how-to-build-with-system-one (.md, 문서 제목 "How to build with TypeSafe"), https://docs.typesafe.ai/patterns (.md)

- (외부) **Summary 상자 원문**(how-to-build .md 240~248행): "**Summary:** build a normal software workflow and insert System One only where AI is needed."
  - "Keep control flow, deterministic rules, and side effects in code."
  - "Break broad judgments into narrow, typed questions with explicit instructions and criteria."
  - "Give each question only the context it needs."
  - "Use probabilities and confidence to act, ask for review, or escalate."
  - "Ask independent questions together, then compose their answers in code."
- (외부) **세 아키텍처 비교**(250~266행). 252행 "TypeSafe is designed for building **AI-powered software**, where code owns the workflow and AI handles narrow, structured decisions."
  - Traditional software: "Traditional code is a complex decision tree made from simple software primitives. Because each primitive is reliable, developers can compose them into higher-level abstractions."
  - LLM agents: "An agent processes instructions and chooses its next step. This works well when a person is monitoring the process, but every loop introduces another opportunity to go off the rails."
  - AI-powered software: "Code handles deterministic work and owns the control flow. The model appears only where the system needs programmable common sense or needs to interpret unstructured data. Each AI task is kept atomic and constrained."
  - 입문편에서 "Jev가 시스템의 어디에 들어가는가"를 설명하는 가장 짧은 틀입니다. 세 구조를 그린 벤더 이미지(`software-architectures-light.webp`)가 있지만 싣지 않고 다시 그릴 경우 위 세 문장이 근거입니다.
- (외부) **"What makes System One composable" 카드 여섯 개**(274~300행). Structured "System One is type-safe by construction. ... so it never has to recover a value from generated prose." / Parallel "Questions are evaluated independently and in parallel. One primitive's result does not become hidden context that changes another primitive's result." / Comparable "Outputs are sortable and can drive smart `if` statements, thresholds, and comparisons." / Fast "Most queries complete in about 100 ms." / Calibrated confidence / Self-consistent.
  - [설계]는 Structured, Parallel, Comparable 세 장. Fast, Calibrated confidence, Self-consistent는 [주장]입니다. "smart `if` statements"는 블로그 비교표 Use cases 행의 "smart if-statements"와 같은 말이라 벤더 스스로 쓰는 요약어로 인용할 수 있습니다.
- (외부) **설계 여덟 단계**(304~802행, `<Step>` 제목 원문과 요지)
  1. "Use code when you can"(307행): "Keep deterministic work in code. It is reliable and cheap. Avoid agent `while` loops when a software workflow can express the same behavior." 예시는 `days_overdue > 30`이면 `route_to_collections`(모델 호출 없음).
  2. "Decompose the input state"(322행): "Include only the context relevant to the current questions. This helps the model avoid distractions and context rot. Do not rely on knowledge stored in model weights when current information can come from your own knowledge base."
  3. "Use structure in the input state"(347행): 중첩 JSON과 백틱 경로(`support.tickets[0].message`).
  4. "Decompose the questions"(400행): "Ask the most explicit, narrow, specific, atomic questions you can." 404행 Info 원문 "This is probably the most important concept in this guide. Broad questions hide several judgments behind one answer. Atomic questions expose those judgments so you can inspect, tune, and combine them in code."
     - ★ 스팸 판정 분해 예시(407~495행): 나쁜 예 "One broad question (bad)" = Noul 하나 `is_spam` "Is `message` spam?" / 좋은 예 "Decomposed questions (good)" = Noul 여섯 개 `requests_credentials`, `offers_unexpected_reward`, `creates_time_pressure`, `sender_identity_mismatch`, `link_domain_mismatch`, `disguises_link_destination`. state는 발신자 "Acme Payroll" `rewards@claim-bonus.example`, 제목 "Urgent: claim your employee bonus", 링크 `http://claim-bonus.example/acme`. 입문편 "질문을 설계하는 건 호출하는 쪽"의 가장 짧은 전후 비교 재료입니다.
  5. "Use structure in the questions"(666행): "Keep questions short." 구조가 도움 되는 세 경우(671~673행): 맥락이나 예시가 필요할 때, 질문 일부가 코드에서 올 때("put it in its own field instead of splicing it into a string template"), 비슷한 질문이 여럿일 때. Choice 선택지 설명을 `what` | `not_for` | `examples` 객체로 쓰는 대조 예시(711~748행).
  6. "Ask a lot of questions"(761행): "Ask many narrow, independent questions about the same state in one request."
  7. "Combine question outputs in code (or feed into a classical ML model)"(767행): 가중합 예시 `0.4 * answers["answers_request"].noul + 0.4 * answers["citations_are_supported"].noul + 0.2 * (1 - answers["contradicts_context"].noul)`(775~779행).
  8. "Route on uncertainty"(786행): "Escalate uncertain cases to a person or a more expensive reasoning model. Test thresholds by plotting confidence against accuracy on your data." 예시 `if answer.confidence < 0.8: route_to_human_review(ticket)`(793~794행). ⚠️ 확신도 라우팅의 깊은 논의는 심화편 몫입니다(경계 절).
  - 804~806행 Tip: "Decomposition does not require more round trips. Questions over the same state run in parallel."
- (외부) **종합 예제 `triage_ticket.py`**(808~1030행). 810행 "This support-ticket workflow keeps deterministic work in code, sends only relevant structured context, evaluates many atomic questions in one request, and composes the answers with explicit confidence gates." 흐름: 닫힌 티켓은 모델 없이 `"no_action"`(818~819행) → 필요한 필드만 state로(826~839행) → 질문 7개 한 요청(Choice `topic`, Noul `requests_credentials`, `sender_identity_mismatch`, `unexpected_reward`, `refund_requested`, `mentions_open_order`, Score `frustration`) → 스팸 위험 가중합 `0.45`, `0.30`, `0.25`(998~1002행) → `0.4 < spam_risk < 0.6`이거나 `topic` 확신도 < 0.75면 사람 검토(1005~1007행) → 주제별 라우팅에서 "Let code decide which speculative answers matter on this path."(1011행). 코드 인용이 필요하면 원문 그대로 옮기세요(블로그 포스트 규칙).
- (외부) **패턴 네 개**(https://docs.typesafe.ai/patterns .md 15~20행 표 원문, "What it does" | "Benefits")
  - Speculative Fan-Out: "Send many questions in a single call, including speculative ones, and let your code decide what's relevant" | Cost, Speed. 예제는 지원 티켓 분류(질문 5개 한 번에, bug_report가 아니면 severity 답을 무시). 푸는 문제: 첫 답을 보고 두 번째 호출을 하는 직렬 왕복(fan-out .md 244행 "Instead of asking for the category first and then the severity in a follow-up call, you can ask for both at the same time.").
  - Confidence-Gated Routing: "Utilize confidence as a second decision axis to build safer systems" | Reliability, Safety. 페이지 요약 원문(7행) "Use confidence as a second axis. The answer tells you what; confidence tells you whether to act." 예제는 음성 뱅킹. ⚠️ 이 패턴의 송금 예제는 심화편의 핵심 소재라 입문편은 한 줄 소개에서 멈춥니다.
  - Composite Scoring: "Combine several dimensions of analysis into a single score" | Cost, Reliability, Speed. 예제는 이력서 선별(Score 넷, 역할별 가중치를 코드에서 다르게: senior IC "40% Python + 10% leadership 40% design + 10% generalist", engineering manager "15% Python + 40% leadership 20% design + 25% generalist"). 푸는 문제: 한 질문에 여러 차원을 섞으면 가중치를 조정할 수 없음.
  - Intent Routing: "Classify a user's intent and route to the appropriate handler" | Cost, Speed. 페이지 요약 원문(7행) "Classify incoming requests and route each to the optimal handler: deterministic logic, a specialist LLM, or a human." 238행 "TypeSafe can sit in front of all of these as a fast, cheap classifier that determines which handler to invoke." 예제 흐름도에서 `order_status`는 결정적 코드, `product_question`과 `return_exchange`는 전문 LLM, 확신도 0.5 미만은 사람. 푸는 문제: 모든 메시지를 비싼 LLM에 먼저 태우는 것(242행 "Rather than sending every message through an expensive LLM to figure out what kind of request it is, you classify first and route accordingly.").
  - patterns .md 9행: "Learning to think in terms of discrete, atomic decisions that compose into complex system behavior is a key skill for getting the most out of TypeSafe."
  - ⚠️ "Benefits" 열(Cost, Speed, Reliability, Safety)은 벤더 분류라 [주장]입니다.

### N-7. 예제 하나를 끝까지: 보안 알림 처리 워크플로 (벤더 블로그 이미지)

**출처와 위치.** 블로그 "Workflow evals" 절의 문장 "Note that the calls here are significantly more complex than the side-by-side demonstration above. That’s because they’re more representative of the types of production workloads needed for true business automation. Below is the simplest of the 4 workflows we’re publishing:" 바로 뒤에 붙은 이미지입니다. 이미지 URL https://framerusercontent.com/images/ih1bFwZGYJxlnijbTuXx3f9NeM.png (HTML `<img alt ...>`, alt 텍스트 없음, 원본 2048×704). `?width=2048&height=704`로 받아 구간별로 잘라 확대해 읽었습니다(2026-09-29).

⚠️ **아래 문구는 전부 이미지에서 읽은 것입니다.** 이미지에는 alt 텍스트가 없어 문자 단위 대조 원본이 없습니다. 작은 글자를 확대해 읽었으므로 철자 하나 단위의 오독 가능성이 남습니다. 글에서 원문을 인용할 때는 "벤더 블로그 이미지에서 옮김"을 밝혀야 합니다. 1차 근거(코드나 질문 정의)는 N-7 끝의 조회 결과 참조.

이미지 바로 아래 문단(블로그 본문, HTML 텍스트라 축자 확인 가능):
> "The most reliable real-world workflows tend to have many independent, decomposed questions, with fine-grained behavior that’s dependent on probabilities instead of discrete decisions. The end result is discrete branching, but how we get to a final answer involves a lot of domain-specific engineering that needs to be done highly consistently."
> "See our workflow evals site for all the details: examples, disagreements, full queries, and each workflow." ("our workflow evals site"는 링크)

**이미지 범례(맨 아래 줄).**
- ACTION(동작 등급, 색): `Close`(초록) | `Queue`(파랑) | `Page`(회색/흰색) | `Light containment`(주황) | `Heavy containment`(빨강)
- QUESTIONS(질문 유형 아이콘): `Bool`(반쯤 채운 원) | `Score`(막대 그래프) | `Choice`(네 칸 격자)
- ⚠️ 이미지 범례는 참/거짓 질문을 문서 용어 "Noul"이 아니라 **"Bool"**로 적습니다. 다시 그릴 때 우리 그림은 문서 용어(Noul)로 통일하고, 이미지 표기가 Bool이라는 점은 각주 정도로 남기는 편이 혼동이 적습니다.

**단계 머리글 네 개(이미지 상단, 원문).**
1. **Triage**: "Three readings of the alert and its joined records: is this unauthorized, does a record explain it, and how strong is the evidence?"
2. **Disposition**: "Code turns the readings into close, queue or act, with the asset's environment and tier in the balance. Grey-zone identity alerts notify the user."
3. **Containment**: "An act runs eleven readings on the state of the incident: credentials, sessions, mail, persistence, processes, traffic, spread."
4. **Playbook**: "The first group that applies is taken, and within it the strongest action whose conditions hold. When no group applies, escalate urgently."

**흐름도 본체(왼쪽에서 오른쪽).**

① TRIAGE
- 입력 노드(둥근 상자) **"One alert"**: "the alert · the asset it fired on · the tickets, registrations, schedules and authorizations joined to it" (가운뎃점은 이미지 원문 표기)
- 질문 상자 제목 **"Is this unauthorized activity?"**, 상자 머리 "Three readings of the alert:", 부제 "reads the alert and the records the pipeline joined to it"
  - [Bool] "someone was doing something they were not authorized to do"
  - [Bool] "a specific record accounts for this activity, in advance"
  - [Score] "how strong the evidence is, from speculative to confirmed"
- 상자 아래 주석: "code reads the asset's environment and tier, and the detector's domain" (모델 질문이 아니라 **코드가 읽는 값**이라는 표시)

② DISPOSITION (분기 마름모 "Close, queue, or act?")
- 위쪽 가지 `close`: 조건 "probably authorized, a record explains it, and not a domain controller" → 동작 **`AUTO CLOSE`** (초록 = Close)
- 가운데 가지 `act`: 조건 "act: probably unauthorized (P > 0.75)" → ③ Containment로 이어짐
- 아래쪽 가지 `queue`: 조건 "everything in between" → 두 번째 마름모 "An identity alert in the grey zone (0.15–0.60)?"
  - `yes` → **`NOTIFY USER`** (파랑 = Queue)
  - `no` → **`ESCALATE TIER2`** (파랑 = Queue)
- ⚠️ 분기 조건 중 숫자는 둘뿐입니다: `P > 0.75`(act), 회색 지대 `0.15–0.60`(identity alert). close 가지의 "probably authorized"에는 숫자가 없습니다. P가 어느 질문의 값인지(첫 Bool인지, 세 값을 합친 것인지)는 이미지에 없습니다. 회색 지대의 0.15~0.60도 어느 값의 구간인지 이미지에 없습니다. 다시 그릴 때 **숫자를 특정 질문에 붙이지 마세요**(확인 불가, 미해결 질문).
- "domain controller", "identity alert"는 코드가 읽는 자산 정보와 탐지기 도메인(① 주석)에 해당하는 것으로 보입니다. 이 대응은 필자 추정입니다.

③ CONTAINMENT (act 가지만 도달)
- 질문 상자 제목 **"What state is the incident in?"**, 상자 머리 "Eleven readings of the incident:", 부제 "reads the same alert and records, now describing the state of the incident"
  - [Bool] "credentials have reached someone unauthorized"
  - [Bool] "a live session or token is being used by an attacker now"
  - [Bool] "malicious mail is sitting in inboxes"
  - [Bool] "something would bring the activity back after a reboot"
  - [Bool] "a malicious process or task is running right now"
  - [Bool] "data or command traffic is leaving to an attacker destination"
  - [Bool] "the attacker changed configuration that persists on its own"
  - [Bool] "it is happening now, or about to, rather than finished"
  - [Bool] "it has reached beyond the entity that was flagged"
  - [Choice] "how far it reaches: one entity, a workgroup, or the whole organization"
  - [Choice] "what kind of attack: host compromise, account takeover, mail campaign, or exfiltration"
- 합계: Bool 9개, Choice 2개 = 11개. 머리글의 "eleven readings"와 맞습니다(필자 집계).

④ PLAYBOOK
- 상자 머리: "Take the first group that applies, then its strongest action whose conditions hold:"
  1. "1 · data is leaving now: the whole organization's reach blocks the destination; otherwise this asset's egress" → `BLOCK DESTINATION`(빨강) | `BLOCK EGRESS ASSET`(주황)
  2. "2 · the attacker has access: a spreading live session locks the account; leaked cloud credentials are revoked; else sessions; else re-authentication" → `DISABLE ACCOUNT`(빨강) | `REVOKE ACCESS KEY`(빨강) | `REVOKE SESSIONS`(빨강) | `REQUIRE REAUTH`(주황)
  3. "3 · malicious mail is delivered: a campaign in several mailboxes blocks the sender; clearly malicious mail is purged; else quarantined" → `BLOCK SENDER`(빨강) | `PURGE MAILBOXES`(빨강) | `QUARANTINE MESSAGE`(주황)
  4. "4 · the host is compromised: live persistence isolates the host, never a lone production system; else kill the process; else quarantine the file" → `ISOLATE HOST`(빨강) | `KILL PROCESS`(주황) | `QUARANTINE FILE`(주황)
  5. "5 · configuration was changed: forwarding rules, delegations or consents are removed" → `REMOVE FORWARDING RULES`(주황)
- 상자 밖 오른쪽: "no group applies" → **`ESCALATE URGENT`** (회색/흰색 = Page)
- 색 대응(필자 판독): 빨강 = Heavy containment, 주황 = Light containment. 각 그룹 안에서 동작이 **강한 것부터 약한 것 순서**로 놓였고("strongest action whose conditions hold"), 그룹 4의 "never a lone production system"은 가장 강한 동작(ISOLATE HOST)에 코드가 거는 예외 조건입니다.

**다시 그리는 데 필요한 구조 요약(필자 정리, 이미지에 없는 해석 없음).**
- 모델 호출은 두 번 나옵니다: ① Triage의 질문 3개, ③ Containment의 질문 11개. ②와 ④는 모델 호출이 없는 **코드 단계**입니다(② 머리글 "Code turns the readings into close, queue or act", ④ 머리글이 규칙 서술).
- ③은 ②에서 act로 간 경우에만 실행됩니다. 즉 두 번째 요청은 첫 번째 답을 본 뒤에야 보낼지 결정되는 **진짜 의존**입니다. 이는 primitives .md 456행의 "The dependency is real only when your code cannot build the second request until it has the first answer"와 같은 모양으로 읽을 수 있습니다(이 대응은 필자 해석, 블로그는 이 문장을 연결하지 않음).
- 동작 종류: Close 1(AUTO CLOSE), Queue 2(NOTIFY USER, ESCALATE TIER2), Page 1(ESCALATE URGENT), Light containment 6, Heavy containment 7. 합 17개(필자 집계).
- 모델은 어떤 동작 이름도 돌려주지 않습니다. 질문 14개(Bool 11, Score 1, Choice 2)는 전부 **상태에 대한 판정**이고, 동작은 코드의 규칙이 고릅니다. 입문편 소주제 "질문을 설계하는 건 호출하는 쪽"과 "문장 대신 판단을 돌려받는 모델"을 한 그림으로 보여 줄 수 있는 지점입니다.

**1차 근거 조회 결과: 벤더 evals 사이트에 같은 워크플로의 텍스트와 질문 정의가 공개돼 있습니다.** 이미지보다 이쪽이 1차 근거입니다.

- **워크플로 페이지** https://evals.typesafe.ai/security_incidents.html (2026-09-29 조회). 블로그의 "our workflow evals site" 링크 대상 https://evals.typesafe.ai/ 의 "Example workflows" 네 개 중 첫째. 흐름도가 **SVG 텍스트**로 들어 있어 문자 단위로 읽을 수 있고, 위 이미지 판독 문구 전부가 이 SVG 텍스트와 일치합니다(단계 머리, 질문 문구, 분기 조건 `act: probably unauthorized (P > 0.75)`와 `the grey zone (0.15–0.60)?`, 플레이북 다섯 그룹, 동작 이름 17개). 이미지 판독 오독은 없었습니다.
  - 동작 등급은 HTML 클래스로 확정: `fc-chip close` AUTO CLOSE / `fc-chip queue` NOTIFY USER, ESCALATE TIER2 / `fc-chip page` ESCALATE URGENT / `fc-chip heavy` BLOCK DESTINATION, DISABLE ACCOUNT, REVOKE ACCESS KEY, REVOKE SESSIONS, BLOCK SENDER, PURGE MAILBOXES, ISOLATE HOST / `fc-chip light` BLOCK EGRESS ASSET, REQUIRE REAUTH, QUARANTINE MESSAGE, KILL PROCESS, QUARANTINE FILE, REMOVE FORWARDING RULES. 필자의 색 판독(빨강 = Heavy, 주황 = Light)과 같습니다.
  - 질문 유형은 SVG 아이콘으로 확정: 반원 아이콘 = Noul, 막대 네 개 = Score, 격자(한 칸 채움) = Choice. **evals 페이지 범례는 "Noul Score Choice"로 적습니다.** 블로그 이미지의 "Bool"은 이미지 판의 표기입니다. 다시 그릴 때 Noul로 쓰면 1차 근거와 맞습니다.
  - 페이지의 단계 이름(이미지와 다른 문구): "1 Read the alert", "2 Close, queue, or act", "3 The state of the incident", "4 Choose the response". 단계 설명 원문:
    - "Three questions about the alert and the records joined to it: was the activity unauthorized, does a record explain it, and how strong is the evidence?"
    - "The code combines the three answers with how important the machine is and where it runs. Borderline identity alerts also notify the user."
    - "Acting opens eleven more questions: credentials, live sessions, mail, anything left behind to run later, processes, network traffic, and how far the activity spread."
    - "The playbook takes the first group whose conditions are met, then the strongest step in it that still applies. When no group applies, the alert is escalated."
  - 페이지 머리: "Handling a security incident: close it, queue it, or contain it." / "An alert has fired. What should be done?"
  - **입력(Input) 여섯 가지** 원문: "The alert" what fired, on which asset, and when / "The asset" its environment, tier and owner / "Open tickets" change requests and incidents already in flight / "Registered devices" the hardware this person is known to use / "Scheduled maintenance" work someone booked in advance / "Standing authorizations" who may do what, and until when.
  - evals 홈의 워크플로 한 줄 소개: "A security alert fires on a laptop or a server. Given the alert and everything on file about that machine, we decide whether to close it, pass it to an analyst, or contain it now."
- **질문 정의 원문(벤더 데이터)**: 같은 페이지가 "View examples"를 누르면 불러오는 https://evals.typesafe.ai/security_incidents-cases.js?v=6c96b19f (89,160바이트, `__VIEWER_DATA__({...})` JSON) 안의 `eval.questions` 14개. 질문 ID는 SVG의 `data-q` 속성과 같습니다. `eval.n_cases` = 240(워크플로 전체 케이스 수), 공개된 케이스 데이터는 `examples` 5건뿐.

| # | 단계 | ID (`data-q`) | 유형 | instructions (원문) | criteria (원문) |
|---|---|---|---|---|---|
| 0 | Triage | `is_true_positive` | Noul | "Given the alert and its context records, does this describe unauthorized activity, as opposed to authorized activity that a detector flagged?" | true "Someone is doing something they were not authorized to do" / false "The activity was authorized, expected, or did not happen -- administrative work, a sanctioned tool, a test, or a detector firing on nothing" |
| 1 | Triage | `context_explains_activity` | Noul | "Do the context records -- tickets, registrations, schedules, authorization excerpts -- account for the flagged activity?" | true "A specific record covers this specific activity: the same actor, asset, or window, authorized in advance" / false "No record covers it, or the records that exist are about something adjacent. Silence is not an explanation" |
| 2 | Triage | `evidence_strength` | Score | "How strong is the evidence that the activity is unauthorized?" | ["Speculative: hedged language, or a single weak indicator", "Suggestive: one concrete indicator, uncorroborated", "Corroborated: independent indicators agree", "Confirmed: direct proof of unauthorized activity"] |
| 3 | Containment | `credentials_exposed` | Noul | "Have credentials been disclosed to, or captured by, someone unauthorized?" | true "A password, key or token has been submitted to an attacker-controlled destination, or is otherwise in hands it should not be in" / false "No credential has left the control of its owner" |
| 4 | Containment | `session_in_attacker_hands` | Noul | "Is a live session or token being used by someone unauthorized right now?" | true "An authenticated session or token is in active use by someone other than the owner" / false "Every active session belongs to the person it was issued to, or none are active" |
| 5 | Containment | `malicious_content_in_mailboxes` | Noul | "Is malicious mail sitting in user inboxes at this moment?" | true "A malicious message is still delivered and reachable in one or more mailboxes" / false "Nothing malicious is in any mailbox, or the incident is not about mail" |
| 6 | Containment | `attacker_persistence_present` | Noul | "Is there a mechanism that would survive a reboot and bring the activity back?" | true "A scheduled task, service, startup entry, key or implant placed by the attacker is still in place" / false "Nothing would restart the activity once it stopped" |
| 7 | Containment | `malicious_process_running` | Noul | "Is a specific malicious process or task executing right now?" | true "A named process, script or scheduled task is running and doing the harm described" / false "Nothing is executing; the evidence is of something that already ran or never ran" |
| 8 | Containment | `outbound_channel_active` | Noul | "Is data or command traffic leaving to a destination under attacker control?" | true "An outbound channel to an attacker destination is carrying traffic now" / false "No outbound channel is open, or the destination is legitimate" |
| 9 | Containment | `attacker_modified_configuration` | Noul | "Did the attacker create or change a configuration that persists on its own?" | true "Mailbox forwarding rules, delegations, OAuth consents, keys or policy entries were created or altered during the incident" / false "No configuration was changed, or the changes were made by their legitimate owner" |
| 10 | Containment | `activity_ongoing` | Noul | "Is the activity live or imminent, rather than finished?" | true "It is happening now, or the evidence points at an imminent next step" / false "It is finished, already remediated, or a historical record of something stopped" |
| 11 | Containment | `spread_beyond_initial_entity` | Noul | "Has this reached beyond the entity that was originally flagged?" | true "A second host, account or mailbox is implicated, or lateral movement is underway" / false "Everything in evidence is confined to the entity that was flagged" |
| 12 | Containment | `affected_scope` | Choice | "How far does this reach?" | `single_entity` "One host, account or mailbox" / `workgroup` "A team, a distribution list, or a handful of related assets" / `organization_wide` "Everyone, or an asset the whole organization depends on" |
| 13 | Containment | `attack_type` | Choice | "What kind of attack does the evidence describe?" | `host_compromise` "Malware, ransomware, or persistence on a host" / `account_takeover` "Stolen or abused credentials or sessions" / `mail_campaign` "Phishing or malicious mail sitting in user inboxes" / `exfiltration` "Data staging or outbound theft in progress" |

  - 원문의 `--`는 하이픈 두 개입니다(em dash 아님). 인용할 때 그대로 두면 됩니다.
  - 흐름도의 짧은 문구("someone was doing something they were not authorized to do" 등)는 대부분 **criteria.true 설명을 소문자로 옮긴 요약**이고, 모델에게 보내는 질문 원문은 위 instructions입니다. 글에서 "질문 원문"이라고 쓸 때는 이 표의 instructions를 써야 합니다.
  - Choice 두 개에는 "해당 없음" 선택지가 없습니다. 입문편이 primitives .md 283행의 권고("add an `other` or `none of the above` option when the list might not cover every input")를 소개한다면, 이 예제의 `attack_type`은 선택지 넷이 전부 공격 유형이라는 사실만 적고 평가는 하지 마세요(Containment는 act로 판정된 경우에만 실행되므로 설계상 이유가 있을 수 있음. 판단은 근거 밖).

- **코드 규칙 원문(벤더 데이터, 케이스별 판정 기록 `decisions.playbook.tests`).** 예시 5건에서 실제로 평가된 규칙만 기록돼 있습니다. `rule` | `qid` | `test` 원문:
  - Disposition(② 코드 단계)
    - `disposition` | `is_true_positive` | "P < 0.15, with a record that explains it: close" (자산이 도메인 컨트롤러 `DC-NW-01`인 케이스에서만 "P < 0.15, with a record that explains it (never on a domain controller): close"로 나옴. 예시 5건 대조)
    - `disposition` | `context_explains_activity` | "P > 0.50: a record explains the activity"
    - `disposition` | `is_true_positive` | "P > 0.75: act now"
    - `queue` | `is_true_positive` | "0.15 < P ≤ 0.60 on an identity alert: notify the user"
  - Playbook 그룹 진입(④ 코드 단계)
    - `data is leaving now` | `outbound_channel_active` | "P > 0.45: enters group 1"
    - `the attacker has access` | `session_in_attacker_hands` | "P > 0.50: enters group 2"
    - `the attacker has access` | `credentials_exposed` | "P > 0.40: enters group 2"
    - `malicious mail is delivered` | `malicious_content_in_mailboxes` | "P > 0.50: enters group 3"
    - `the host is compromised` | `attacker_persistence_present` | "P > 0.60: enters group 4"
    - `the host is compromised` | `malicious_process_running` | "P > 0.60: enters group 4"
  - Playbook 그룹 안 동작 조건
    - 그룹 2: `disable account` ← `session_in_attacker_hands` "P > 0.65" 와 `spread_beyond_initial_entity` "P > 0.50" / `revoke access key` ← `credentials_exposed` "P > 0.60" / `revoke sessions` ← `session_in_attacker_hands` "P > 0.50" 와 `credentials_exposed` "P > 0.60" / `require reauth` ← `credentials_exposed` "P > 0.40"
    - 그룹 4: `isolate host` ← `attacker_persistence_present` "P > 0.60" 와 `activity_ongoing` "P > 0.50" / `kill process` ← `malicious_process_running` "P > 0.60" / `quarantine file` ← `attacker_persistence_present` "P > 0.60"
  - ★ **이미지에서 확인 불가였던 두 숫자가 여기서 풀립니다.** `P > 0.75`의 P는 `is_true_positive`(Noul)의 값이고, 회색 지대 `0.15–0.60`도 `is_true_positive`의 값에 대한 구간이며 identity 알림에만 적용됩니다. close 가지는 `is_true_positive` < 0.15 이면서 `context_explains_activity` > 0.50인 경우입니다(두 테스트의 조합은 필자 해석. 원문 "with a record that explains it"과 바로 다음 테스트가 그렇게 읽힘).
  - 코드가 읽는 값(`decisions.playbook.outputs.state`): `environment`(prod | dev), `tier`(0 | 1 | 2), `domain`(identity | endpoint). 문서 입력의 `context.asset`(`environment`, `tier`, `type`)에서 옵니다. 판정 띠 `band`는 `act` | `middle`이 관찰됨. 경로 키(`keys`) 예: `trunk` → `gate1.act` → `containment` → `gate2` → `G4` → `G4.quarantine_file`, 또는 `trunk` → `gate1.queue` → `gate1.notify`.
  - Containment 노드의 건너뜀 사유 원문: "the disposition was middle: only an act reaches containment". ③이 ②의 act에만 실행된다는 것이 데이터로 확인됩니다.
  - ⚠️ **공개 데이터로 확인되지 않은 규칙**: 그룹 1 안의 동작 조건(BLOCK DESTINATION과 BLOCK EGRESS ASSET을 가르는 "the whole organization's reach"), 그룹 3 안의 동작 조건, 그룹 5 진입 조건, `evidence_strength`와 `affected_scope`, `attack_type`, `environment`, `tier`가 규칙에 어떻게 쓰이는지. 예시 5건의 판정 기록에 나오지 않습니다. 흐름도 문구("a campaign in several mailboxes", "the whole organization's reach", "never a lone production system")가 이 값들을 쓰는 것으로 보이지만 **추정**입니다. 다시 그릴 때 이 부분에 숫자나 질문 ID를 붙이지 마세요.
  - 벤더 코드 파일 자체(파이썬 등)는 찾지 못했습니다. GitHub `typesafe-ai` 조직 저장소 10개(2026-09-29 `gh api orgs/typesafe-ai/repos`: typesafe-ai.github.io, vllm, LLaDA, daggerverse, pulumi-clickhouse, system-one-adapter-python, skills, typesafe-sdk-python, typesafe-sdk-js, n8n-nodes-typesafe-ai)에 evals 저장소가 없습니다. 규칙은 위 판정 기록의 문자열이 공개된 전부입니다.
  - 참고(제3자, 입문편 본문에는 쓰지 않음): GitHub 코드 검색에서 `rorshopping/jev-on-a-laptop`, `TheoLeeCJ/SemIf-OpenJev`가 이 viewer 데이터를 추출해 자체 평가에 썼습니다. 벤더 1차 자료를 이미 확보했으므로 근거로 삼지 않습니다.

- **예시 케이스 하나의 끝까지 경로(벤더 데이터, Jev 답).** 케이스 `art_T1574.001-2__peer_contained__t0`, 이름 "Amsi.dll renamed as WinAppXRT", 라벨 "All three miss the reference". 자산 `DC-NW-01`(도메인 컨트롤러), `context.asset` = environment prod, tier 0, type Server. 모델 표기 `typesafe:v13_snowy_elephant`, 기록된 비용 $0.000244, 0.338초(벤더 측정, [주장]).
  - ① Triage 답: `is_true_positive` 0.82, `context_explains_activity` 0.06, `evidence_strength` score 2.25(confidence 0.54, probabilities 0: 0.01, 1: 0.08, 2: 0.55, 3: 0.36)
  - ② Disposition: "P > 0.75: act now"가 0.82로 성립 → act. (close 조건 불성립: 0.82는 0.15 미만이 아니고 기록 설명 0.06)
  - ③ Containment 답: `credentials_exposed` 0.3, `session_in_attacker_hands` 0.24, `malicious_content_in_mailboxes` 0.09, `attacker_persistence_present` 0.68, `malicious_process_running` 0.18, `outbound_channel_active` 0.16, `attacker_modified_configuration` 0.66, `activity_ongoing` 0.36, `spread_beyond_initial_entity` 0.45, `affected_scope` organization_wide(confidence 0.94), `attack_type` host_compromise(confidence 1.0)
  - ④ Playbook: 그룹 1(0.16 ≤ 0.45) 불성립, 그룹 2(0.24 ≤ 0.50, 0.3 ≤ 0.40) 불성립, 그룹 3(0.09 ≤ 0.50) 불성립, 그룹 4(`attacker_persistence_present` 0.68 > 0.60) 진입. 그룹 4 안에서 `isolate host`는 `activity_ongoing` 0.36 ≤ 0.50이라 불성립, `kill process`는 0.18 ≤ 0.60이라 불성립, `quarantine file`이 성립 → **QUARANTINE FILE**(light).
  - 기준 답(두 대형 모델 평균 합의)은 **ISOLATE HOST**(heavy)였고, Jev, Opus, Sol 셋 다 QUARANTINE FILE로 기준과 달랐습니다(라벨 "All three miss the reference").
  - 입문편에서 이 경로의 가치: 질문 11개 중 동작을 실제로 가른 것은 `activity_ongoing` 하나의 0.36이었다는 점이 **숫자 하나가 코드 분기를 타는 모양**을 보여 줍니다. 다만 이 케이스는 기준 답과 어긋난 사례라, 쓸 경우 "기준과 달랐다"를 반드시 함께 적어야 합니다(심화편 소재로 번지지 않게 한 문장으로).
    - ⚠️ **[verifier 교정, 2026-09-29] "`activity_ongoing` 하나가 갈랐다"는 공개 기록보다 강합니다.** 같은 케이스의 Opus는 `isolate host`의 기록된 조건 두 개를 모두 넘고도(0.72 > 0.60, 0.6 > 0.50, `group_holds: true`) `QUARANTINE FILE`로 끝났습니다. 공개 판정 기록에 없는 조건이 ISOLATE HOST를 한 번 더 거릅니다. Jev의 기록에서 ISOLATE HOST를 떨어뜨린 것은 `activity_ongoing`이 맞지만, 그 값이 0.50을 넘었어도 ISOLATE HOST가 나왔을지는 알 수 없습니다. 아래 `## 검증 기록` VR-37 참조.
  - 기준 답의 출처(데이터 `references` 원문): "GPT-6 Astra, high thinking, one question per request" / "Claude Fable 5.1 high, one question per request; Claude Opus 5 high on the 88 documents Fable refused or failed" / "Consensus: mean of Astra and Fable probabilities for every question". 정답이 아니라 모델 합의라는 점은 심화편 V-29와 같습니다.

- **evals 홈의 장난감 예제 "Expense claims"(입문편 도입용 후보).** https://evals.typesafe.ai/ "Decompose the work, build a harness" 절. 원문 설명: "A toy example. The policy on the left is the kind of paragraph a team writes down; the chart on the right is the same policy as a workflow. Each sentence became either a question for the model, with a type, or a rule for the code."
  - 정책 문장 네 개(원문): "1 Every claim comes with a receipt. If the receipt cannot be read, ask the employee for a new one." / "2 Work out what kind of expense it is: a meal, travel, or equipment." / "3 A meal over $75 needs a manager's sign-off when the description on the claim does not clearly match the receipt." / "4 Everything else is approved."
  - 워크플로(SVG 텍스트): 입력 "One expense claim" (the receipt · the claim form) → "1 THE MODEL ANSWERS": "the receipt can be read"(Noul), "what kind of expense: a meal, travel, or equipment"(Choice), "how clearly the claim's description matches the receipt, on four levels"(Score) → "2 THE CODE DECIDES": readable? no → `NEW RECEIPT` / "a meal over $75 whose description does not clearly match" → `MANAGER REVIEW` / "anything else" → `APPROVE`
  - 유형 대응은 SVG의 `data-q`와 아이콘 마크업으로 확정했습니다: `readable` = Noul(반원), `kind` = Choice(격자), `match` = Score(막대 넷). SVG `aria-label` 원문 "A toy expense workflow: one judgment with three questions, one decision, one rule list". 동작 칩 클래스는 `fc-chip back`(NEW RECEIPT), `fc-chip review`(MANAGER REVIEW). $75 비교가 모델 질문이 아니라 코드 규칙 쪽에 있다는 점은 R-11("Arithmetic is not, so keep it in code")과 같은 방향입니다.
  - 같은 절 원문: "To automate a task, we decompose the decisions into programmatic rules and intelligent judgments. Rather than ask a model to solve the entire problem in one shot (like the prompt examples in the plot), we ask independent narrow questions and defer to code where possible." 그리고 "Averaged across the four example tasks, every model is more accurate, cheaper and faster in the workflow than it is with the same policy as a prompt."(마지막 문장은 [주장]. 참고로 Security Incidents 개별 결과에는 DS v4 flash가 prompt 44.6%, workflow 37.9%로 반대인 점이 있어 "평균" 조건이 중요합니다.)

### N-8. 맞는 자리와 맞지 않는 자리

**맞는 자리 (벤더가 든 용도)**

- (외부) 블로그 비교표 Use cases 행(N-5): "AI-Powered Workflows / smart if-statements", "Map-reducing over big data", "Real-time applications", "Verify everything". 첫 항목의 설명 "Structured outputs slot into ordinary software as fuzzy decision rules: classify, route, score, extract, or branch where hand-written logic is too brittle."이 입문편의 한 줄 정의로 가장 쓸모 있습니다.
- (외부) 블로그 FAQ "What use cases is Jev good for?"의 답(접힌 영역, 하이드레이션 JSON에서 확인): "We’ve found diverse use cases for Jev across industries. We outline some in our docs, and are excited to see what else developers build." ("in our docs"가 use-case-map 링크)
- (외부) coding-agents "Reach for Jev when your code needs to:" 네 항목(N-2).
- (외부) **결정 모양 표**(https://docs.typesafe.ai/concepts/use-case-map .md 180~191행, "Decision shape" | "Reach for it when" | "Examples" 원문)
  - Classification | "One known category should win" | Intent, topic, department, risk type, entity type
  - Detection | "You need a probability that one property is present" | Spam, fraud, urgency, jailbreaks, sensitive data
  - Scoring | "The answer belongs on an ordered rubric" | Severity, relevance, quality, frustration, suitability
  - Routing | "A category selects the next code path" | Tool use, escalation, model routing, support queues
  - Search | "You need to find items that match a natural-language query" | Semantic search, document discovery, candidate generation
  - Retrieval | "A workflow needs the most relevant context or records" | RAG context, evidence retrieval, knowledge lookup
  - Ranking | "Items need to be ordered by semantic relevance or quality" | Search results, recommendations, candidate prioritization
  - Verification | "An artifact must be checked for specific failure modes" | Citation support, policy violations, tool-call errors, response quality
  - ML Feature Extraction | "A downstream classical ML model needs semantic signals" | Purchase intent, product interest, competitive pressure, churn signals
  - Structured Data Extraction | "Known fields must be recovered from unstructured input" | Candidate attributes, order fields, document labels
- (외부) use-case-map 카테고리 카드 다섯 개(14~31행): "AI Automation Software", "Real-time applications", "AI Map Reduce over Big Data", "Universal Verification", "Harness Engineering". 첫 카드 원문 "Interleave AI with reliable software in a way where you can run it a million times in the background without a human co-pilot. Code owns control flow (not markdown files) while TypeSafe handles the semantic decisions and language understanding." / 다섯째 카드 원문 "Use Jev queries to make your harness smarter - model routing, semantic context retrieval, LLM error detection and guardrails, reasoning trace classification at lightspeed and a fraction of the cost."
  - ⚠️ 카드 문구의 수치("150ms", "100x cheaper")와 "at lightspeed"는 [주장]. use-case-map의 "(150ms)"는 블로그 "70ms-500ms", 문서 "about 100 ms"와 또 다른 값입니다(기존 노트 E-5의 속도 불일치 표에 한 줄 더해짐).
  - "Harness Engineering" 카드는 이 블로그의 하네스 글들과 맞닿지만, 입문편에서 연결을 늘리면 심화편과 겹칩니다. 쓴다면 한 문장까지.
- (외부) "Example automation use cases" 아코디언 19개(38~175행, `grep -c '<Accordion title='` = 19): Search and retrieval, Scientific discovery, Model routing, LLM guardrails, Semantic code linting, Feature extraction for predictive modeling, Recruiting, Lead generation, Customer support, Insurance claims, Financial crime, Legal and compliance, E-commerce marketplaces, Moderation and trust and safety, Advertising, Gaming, Risk assessment, Demand forecasting, Graphs and knowledge graphs. 보안(사이버보안) 항목은 따로 없습니다. 보안 알림 예제는 문서가 아니라 블로그와 evals 사이트에서 옵니다. 목록 나열은 사용법 나열로 흐르기 쉬우니 본문에는 결정 모양 표 쪽을 쓰는 편이 낫습니다.
- (외부) **LLM을 대체하지 않고 LLM 앞이나 옆에 놓인다.** intent routing 패턴(N-6)이 Jev를 전문 LLM들 앞의 분류기로 두고, use-case-map "Model routing"(54~59행) "Use Jev to build a custom router that chooses which LLM receives each prompt." / "LLM guardrails"(62~67행) "Place semantic checks on every LLM input, output, and tool call at a fraction of the cost of the LLM call." 그리고 coding-agents 29행 "Keep using an LLM-based coding agent, and use Jev separately wherever your product needs a fast, calibrated, structured decision."

**맞지 않는 자리 (벤더가 스스로 적은 것)**

- (외부) **텍스트 생성, 대화, 코드 작성.** coding-agents 9, 13, 19행(N-2). jaggedness 실패 모드 9 "Generation" 원문(141행): "`jev-1.13` is not trained to generate text. While you can force it to by chaining choices, this will not work well and will be very slow." 권고(143행): "when the answer space is bounded, turn extraction into a [Choice](/primitives/choice) over the options rather than asking for the value itself. If you really need to generate text... there are other models for that."
  - ★ 그래서 블로그 Use cases의 "extract"는 **후보를 코드나 다른 모델이 뽑고 Jev가 고르는 추출**로 읽어야 합니다. 141행 "For data extraction, it is better to extract possible options using regex or a generative model and let `jev-1.13` pick the correct extraction." 문서 목록의 "Pre-parsed value extraction" 쿡북 설명(llms.txt)도 "Uses regexes to find candidate emails, phone numbers, and amounts, then has TypeSafe select the requested span so code can normalize a verbatim value." 입문 독자가 "추출"을 생성형 추출로 오해하기 쉬운 지점입니다.
- (외부) **jaggedness 실패 모드 표 9행**(https://docs.typesafe.ai/model-jaggedness/jev-1.13 .md 17~27행, "Failure mode" | "Do this instead" 원문, "Last reviewed 2026-09-17")
  1. Literal reading | "Write the exact condition, criteria for each available options"
  2. Math and Numbers | "Keep the arithmetic in code"
  3. Date and time comparison | "Extract components; compare in code"
  4. Indirection | "Reduce hops; point to the relevant state"
  5. Large state full of irrelevant detail | "Filter first; send only what the question needs"
  6. Adversarial content | "Write precise prompts, and test edge cases before deploying"
  7. Contradictory instructions and criteria | "Align the criteria and instruction"
  8. Common-sense structural invariants | "Ask each decision one way; enforce identities in code"
  9. Generation | "Use a generative model"
  - 문서 서두(13행): "`jev-1.13` is fast, calibrated, and good at common-sense judgment but it is not perfect. `jev-1.13` does the best on [System One](/concepts/system-one) tasks. It may struggle with tasks that require additional levels of indirection. It can be quite literal in its understanding. It struggles with tasks that require numeric precision." ("fast, calibrated"는 [주장])
  - 끝의 Info 상자(145~151행) "As a reminder, avoid the following:" 네 항목: "Asking the model something code can compute exactly." / "Hiding several judgments inside one question." / "System Two tasks: more layers of indirections" / "Giving it more context in `state` than the question needs. Jev suffers from context rot, so unrelated material in the `state` costs you accuracy."
  - ★ "context rot"의 두 문장을 구분해야 합니다. introduction 37행 "adding more questions does not create context-rot"은 **질문 수**에 대한 말이고, jaggedness 151행 "Jev suffers from context rot"은 **state 크기**에 대한 말입니다. 모순이 아니라 대상이 다릅니다(필자 대조).
  - ⚠️ 실패 모드 2, 3에 대해 priorbench가 "문서가 모델을 과소평가한다"고 반박한 기록이 있습니다(기존 노트 E-7, V-41). 입문편은 벤더 권고로만 소개하고 반박 논쟁은 심화편 몫으로 둡니다.
- (외부) **Literal reading의 원문**(jaggedness 31행): "`jev-1.13` answers the question you wrote, not the one you meant. Scoping words, negations, and implied conditions are read at face value." 33행 "When you look at a wrong answer and find yourself explaining what you really meant, that explanation is the missing half of the instruction." 소주제 2("질문을 설계하는 건 호출하는 쪽")와 소주제 3을 잇는 문장입니다.
- (외부) **입력 형태**: 텍스트만(concepts/system-one .md 16행, models .md 16, 21행 "Pre-process non-text inputs (images, audio, video, binaries) into text or structured fields before sending them as `state`."). state .md 32행 Note에는 em dash가 있어 인용 범위를 조정해야 합니다.
- (외부) **언어**: R-12(models .md 52행). "pay close attention to [Confidence](/confidence) when routing"까지가 같은 문장입니다.
- (외부) **도메인 맞춤은 요청으로만**: models .md 44행 "Jev is not fine-tuned or LoRA-adapted with customer data. ... the same weights serve every account. You shape its answers to your domain through the request rather than through per-account weights:" 이어지는 세 방법(46~48행): state에 자기 자료 넣기, instructions와 criteria에 도메인 규칙과 경계 사례 적기, 넓은 판단을 원자 질문으로 쪼개 코드로 합치기. 입문편에서 "질문 설계가 곧 도메인 적응 수단"이라는 이해를 뒷받침합니다(소주제 2와 3에 걸침).
- (외부) **적대적 입력**: R-13. 권고(jaggedness 108행) "be explicit in the criteria. Test your integration thoroughly before deploying it to many users."
- (외부) **공개 범위(발행 시점 기록)**: R-14와 R-15. 2026-09-29 재확인 결과:
  - 모델은 여전히 `jev-1.13.0` 하나, `jev-latest`와 `jev-preview`가 모두 이 버전(models .md 11, 33~37행). 가격, rate limit, 컨텍스트 값도 2026-09-28과 같음(models .md 13~15행). rate limit 경고(24행)도 그대로.
  - `GET /v1/models`(models .md 60행): "It currently lists the aliases."
  - Playground는 로그인 필요(quickstart .md 11행). API 키는 대시보드에서 발급(33행).
  - ⚠️ **현재도 대기자 명단인지 확인하지 못했습니다.** 블로그의 "opening early access and bringing developers off the waitlist"는 2026-09-15 발표 시점 문구입니다. 2026-09-29 홈페이지 HTML의 "Join Waitlist"는 Framer 레이어 이름일 뿐 보이는 글자는 "Open roles"(채용 링크)였고, 가입 정책을 적은 문구는 찾지 못했습니다. 글에는 "발표 시점 기준 얼리 액세스"로만 쓰세요(미해결 질문).
  - SDK: Python `typesafe-sdk`(pip, Python >= 3.10), JavaScript `@typesafe-ai/sdk`. 에이전트 스킬 `typesafe-ai/skills`(Claude Code 플러그인으로 설치, quickstart .md 196~205행). GitHub 조직에 n8n 노드 저장소 `n8n-nodes-typesafe-ai`(2026-09-23 생성)도 있습니다(`gh api`, 2026-09-29).

---

## 인사이트 후보

입문 독자가 이 글을 읽고 얻을 **이해 포인트**입니다. 작성자의 사용 경험이 없으므로 전부 "벤더 문서와 공개 데이터를 읽어 얻은 이해"이고, 판단이 섞인 곳은 ⚠️로 표시했습니다. 괄호 안은 근거 번호입니다.

1. **Jev는 답을 쓰는 모델이 아니라, 호출하는 쪽이 정한 칸을 채우는 모델이다.** 벤더가 출발점으로 삼은 문제는 "LLM의 성능"이 아니라 인터페이스의 불일치입니다. 코드가 소비할 판단을 사람이 읽을 텍스트로 받고 다시 파싱하는 구조(introduction 9행)를 버리고, 답의 후보를 먼저 정해 보내면 그 안에서 확률을 매겨 돌려받습니다(system-one 23행, primitives 309행). 벤더 블로그의 "where is all the automation?"과 AI primer의 "the machine interface matters more than the chat interface"가 같은 동기를 말합니다. (N-1, N-5 Outputs 행의 [설계] 부분, R-2)
2. **답의 모양이 곧 코드의 모양이다.** Choice는 코드 경로 N개로, Score는 문턱 하나로, Noul은 `if` 하나로 이어집니다(primitives 295행). 벤더가 스스로 고른 요약어가 "smart if-statements"(블로그 Use cases 행, how-to-build 286행)입니다. 입문 독자에게는 "모델 호출 결과를 조건식에 바로 넣을 수 있다"가 가장 손에 잡히는 첫 이해입니다. ⚠️ 그 조건식의 문턱을 어떻게 정하고 무엇을 맡기느냐는 심화편의 주제라 여기서는 "연결된다"까지만. (N-4, N-5, N-6)
3. **한 번의 호출은 하나의 state와 서로 모르는 여러 질문이다.** 질문들은 같은 state를 병렬로, 서로 독립적으로 봅니다. 한 질문의 답이 다른 질문의 맥락이 되지 않으니(primitives 310행), 질문을 더하거나 빼도 다른 답이 바뀌지 않습니다. 그래서 질문 사이에 진짜 의존이 있을 때만 두 번째 요청을 보냅니다(primitives 456행). 보안 워크플로에서 Containment 질문 11개가 act 판정 뒤에만 나가는 것이 그 모양입니다("the disposition was middle: only an act reaches containment"). 속도와 비용 수치는 [주장]이지만 "한 요청 안의 병렬 독립 평가"는 API 구조로 확인되는 설계입니다. (R-6, N-3, N-4, N-7)
4. **모델은 적힌 글자만 읽는다. 그래서 질문 설계가 곧 도메인 맞춤이다.** 질문 ID는 모델에 전달되지 않고(api 36행, primitives 276행, choice 284행), Score의 레벨 번호와 이웃 레벨도 보이지 않습니다(score 744행, 원문은 검증 기록 VR-15). 숫자만 적은 레벨로 물으면 벤더 예시에서 score 0.55, confidence 0.33으로 흩어지고 상황을 적은 레벨로 물으면 0.0, 1.0입니다(score 749~752행, 벤더 기록 예시). jaggedness는 이를 "answers the question you wrote, not the one you meant"로 요약합니다(31행). 파인튜닝이 없어서 도메인에 맞추는 수단은 요청뿐입니다(models 44~48행). (N-3, N-4, N-8)
5. **벤더가 "가장 중요한 개념"이라고 부른 것은 분해다.** 넓은 질문 하나를 좁은 질문 여럿으로 쪼개고 코드로 합칩니다(how-to-build 400~404행). 스팸 판정 전후 예시(Noul 하나 → 여섯)가 가장 짧은 설명이고, evals의 장난감 예제는 같은 원리를 "정책 문장 하나가 질문(유형 포함) 하나 또는 코드 규칙 하나가 된다"로 보여 줍니다. 보안 워크플로는 이 원리를 끝까지 밀어붙인 예입니다. 모델은 질문 14개에 답할 뿐이고 동작 17개 중 어느 것도 고르지 않으며, 분기는 전부 `is_true_positive`의 값이 0.75를 넘는가 같은 코드 규칙입니다. (N-6, N-7)
6. **코드가 쥐는 것은 제어 흐름, 결정 규칙, 부작용, 계산이다.** 벤더는 전통 소프트웨어, LLM 에이전트, AI-powered software를 나란히 놓고 세 번째를 "Code handles deterministic work and owns the control flow. The model appears only where the system needs programmable common sense or needs to interpret unstructured data."로 정의합니다(how-to-build 264행). 계산은 판단이 아니라서 코드에 둡니다(jaggedness 82, 148행). evals 장난감 예제에서 "$75 초과" 비교가 모델 질문이 아니라 코드 규칙 쪽에 놓인 것이 작은 예입니다. (R-10, R-11, N-6, N-7)
7. **맞는 자리와 맞지 않는 자리는 앞의 두 성질에서 따라 나온다.** ⚠️ 필자 정리입니다. 답의 공간이 닫혀 있고(성질 1) 한 질문이 몇 초짜리 판단일 때(성질 5) 맞습니다. 결정 모양 표의 열 가지(분류, 탐지, 점수, 라우팅, 검색, 검색 맥락, 순위, 검증, 특성 추출, 구조화 추출)가 전부 이 조건 안에 있습니다. 맞지 않는 자리도 같은 조건의 뒷면입니다. 생성(답의 공간이 열려 있음), 계산과 날짜 비교(판단이 아님), 간접과 긴 추론("System Two tasks"), 관련 없는 내용이 가득한 큰 state(몇 초짜리 판단의 맥락을 넘음). 여기에 입력 형식(텍스트만), 언어(영어 외 정확도 낮음), 공개 범위(API 전용)가 제품 조건으로 붙습니다. 벤더 문서의 권고가 이 정리와 같은 방향이라는 것은 근거로 확인되지만, "두 성질에서 따라 나온다"는 연결은 필자 해석입니다. (N-8)
8. **"추출"은 생성이 아니라 고르기로 바꾼 추출이다.** 벤더 블로그가 용도로 든 "extract"는 후보를 정규식이나 생성형 모델로 먼저 뽑고 Jev가 그중 하나를 고르는 방식입니다(jaggedness 141~143행, Pre-parsed value extraction 쿡북 설명). 입문 독자가 오해하기 쉬운 지점이라 소주제 3에서 짚을 만합니다. (N-8)
9. **Jev는 LLM을 대체하지 않고, LLM 앞이나 옆에 놓인다.** 코딩 에이전트 교체용이 아니라고 벤더가 못 박았고(coding-agents 9행), 의도 라우팅 패턴은 Jev를 전문 LLM들 앞의 분류기로 둡니다(intent-routing 238, 242행). 모델 라우팅과 LLM 가드레일도 같은 자리입니다. (N-2, N-6, N-8)

작은 이해 포인트(본문 곳곳에 한 문장씩 쓸 수 있는 것):
- Score의 `score`는 레벨 번호의 확률 가중 평균이라, 1.0이 "전부 레벨 1"일 수도 "레벨 0과 2가 반반"일 수도 있습니다(score 734행). API 예시 1.05 = 0×0.0 + 1×0.95 + 2×0.05로 산술이 맞습니다(N-3).
- Noul 0.5는 "중간 정도"가 아니라 "예와 아니오가 반반"입니다(primitives 290행, noul 369~378행의 Python 실력 표).
- `confidence`는 Choice와 Score에만 있고, "분포가 얼마나 뾰족한가"의 요약입니다(primitives 303행, choice 347행). Noul은 값 자체가 확률이라 따로 없습니다(noul 354행). 벤더 블로그 비교표의 "All answers are accompanied with ... confidence scores"는 이 문서 사실과 어긋나니 글은 문서를 따르세요.
- "context rot" 두 문장의 대상 구분(질문 수 대 state 크기, N-8).

묶이지 않는 후보 (소주제에 넣지 않음):
- 이름의 유래(R-3)는 소주제 1의 도입 한두 문장 재료이지 독립 인사이트가 아닙니다.
- 벤더 공식 LLM 어댑터(R-8)는 "계약이 모델과 분리된다"는 좋은 설계 사실이지만, 심화편이 같은 저장소로 실패 모양 논증을 했습니다. 입문편에서 쓰면 한 문장까지.
- evals 사이트의 모델별 정확도, 비용, 시간 수치(Jev 61.7%, $0.0001, 0.3 s 등)는 전부 벤더 측정이고 기준 답이 모델 합의라 입문편 인사이트가 아닙니다. 쓰지 않는 편을 권합니다.
- 데모(Doom, Wikiracing)는 흥미롭지만 "실시간" 주장의 재료라 입문편 논지와 결이 다릅니다.

---

## 소주제 이름 후보

사용자가 확정한 표기입니다. 도입부 예고와 소제목이 이 표기를 그대로 씁니다. 세 이름 모두 주제라 한국어이고, 고유명사(Jev, TypeSafe AI, System One, Choice, Score, Noul)는 원 표기를 유지합니다.

- **문장 대신 판단을 돌려받는 모델** : 인사이트 1, 2, 3 (+ 이름의 유래 R-3, 한 줄 소개 R-2, 호출 한 번의 형식 N-3, 작은 이해 포인트의 score, Noul 0.5, confidence 정의)
- **질문을 설계하는 건 호출하는 쪽** : 인사이트 4, 5, 6 (+ 보안 알림 워크플로를 끝까지 따라가는 예제 N-7, evals 장난감 예제)
- **맞는 자리와 맞지 않는 자리** : 인사이트 7, 8, 9 (+ 공개 범위 R-14, 언어 R-12, 입력 형식)

**뼈대에 대한 보고(바꾸지 않음):**
- 근거가 세 이름을 모두 받쳐 줍니다. 가장 두꺼운 것은 두 번째입니다(how-to-build 여덟 단계, primitives 유형 선택, jaggedness literal reading, 벤더 공개 워크플로 데이터).
- 보안 워크플로 예제는 두 번째 소주제의 끝에 두는 것이 자연스럽습니다. 첫 번째 소주제(판단만 돌려받음)와 두 번째(질문과 규칙을 호출하는 쪽이 설계)를 한 그림에서 동시에 보여 주기 때문입니다. 독립 절로 떼면 소제목이 이름 셋 밖으로 하나 늘어납니다.
- 세 번째 소주제는 목록 나열(사용 사례 19개, 결정 모양 10개, 실패 모드 9개)로 흐를 위험이 가장 큽니다. 인사이트 7의 "앞의 두 성질에서 따라 나온다"를 우산 문장으로 쓰면 목록이 판단 기준 하나로 묶입니다(단, 필자 해석 표시 필요).
- 태그 후보: `AI`, `Jev` (기존 태그와 같은 표기). 심화편 태그 `[AI, Jev, 검증, 아키텍처]` 중 `검증`은 이 글의 주제가 아니고, `아키텍처`는 소주제 2와 맞습니다. 최종 결정은 writer와 사용자 몫.

---

## 기존 발행본과의 경계

심화편: `_posts/2026-09-29-jev-system-one-model.md` 「확률을 돌려받는 순간, 틀렸다는 걸 알아낼 책임도 넘어왔다」, 링크 경로 `/blog/2026/09/29/jev-system-one-model.html`(AGI 편 링크 형식 `/blog/2026/09/08/agi-word-to-gate.html`과 같은 규칙).

**입문편이 하지 않을 것(심화편 논지 되풀이 금지)**
- "환각이 없다" 주장의 근거 분석, 시끄러운 실패와 조용한 실패(심화편 "틀려도 타입은 맞는 답" 절).
- priorbench(케이크 레시피 0.94, 0/30, 0.99 문턱), 주사위 실험(82.9%), HN 반론. 입문편에는 제3자 측정을 싣지 않는 것을 기본으로 합니다.
- 보정은 집단의 성질이라는 논증, 라벨 데이터로 문턱을 재야 한다는 논증, 질문 사이 확률이 공통 화폐가 아니라는 1.19 예(심화편 "호출하는 쪽으로 넘어온 확률" 절).
- 문턱값의 유효기간이 버전 ID로 적힌다는 논증(별칭 이동과 버전 고정).
- 두 송금 예제(`confidence` 문서와 `patterns/confidence-routing`)의 불일치, 확신도와 되돌릴 수 있음이 다른 축이라는 해석, 권한 회수(심화편 "확신도와 되돌릴 수 있음" 절).
- 심화편의 결론 문장("사람에게 넘기는 빈도는 숫자에 맡기고, 사람이 있는지는 숫자에 맡기지 않습니다").

**입문편이 해도 되는 것(겹치지만 입문에 필요한 사실)**
- 요청과 응답 형식, 질문 유형 표. 심화편도 같은 표를 실었지만 입문편은 "언제 무엇을 쓰나"(primitives 283~295행)라는 다른 각도로 씁니다.
- `confidence`의 **정의**(분포가 얼마나 뾰족한가)와 "사람이나 추론 모델에게 넘길 수 있다"는 **존재 사실**까지. 어디에 문턱을 두느냐는 심화편 링크로 넘깁니다.
- 맺음에서 심화편으로 넘기는 문장. 예: 돌려받은 확률을 조건식에 넣는 순간 생기는 질문(그 숫자가 틀렸다는 걸 무엇이 알려주는가, 그 숫자에 무엇을 맡기는가)은 심화편에서. 심화편의 결론을 요약해 미리 말하지는 않습니다.

**그림 경계**
- 심화편 도입 그림은 API 문서 Choice 예시("Help! My payouts have been failing for 3 days.", billing 0.88)를 썼고, 계약 테스트(`test/site_output_test.rb:106~126`)가 심화편 파일의 `jev-embed` 그림 세 장을 잠급니다. 입문편은 quickstart의 세 유형 동시 예시(Stripe 티켓) 또는 보안 워크플로를 쓰면 겹치지 않습니다.
- 계약 테스트는 `2026/09/29/jev-system-one-model.html` 파일만 읽으므로 입문편 그림이 심화편 테스트를 깨지는 않습니다. 다만 입문편이 `.jev-embed` 클래스를 재사용하면 스타일 충돌은 없어도 두 글의 그림 규칙이 한 이름을 공유하게 됩니다. 새 클래스를 쓸지는 writer 판단입니다. 외부 요청 0 계약(인라인 SVG 또는 HTML과 CSS, 다크 모드 대응)은 입문편 그림에도 똑같이 적용됩니다.
- 벤더 이미지는 싣지 않고 다시 그립니다(사용자 지시). 다시 그릴 재료는 N-7에 빠짐없이 있습니다.

**다른 발행본**
- AGI 편, 하네스 책 편, 레이트리미터 편과의 연결은 심화편이 이미 했습니다. 입문편은 이 연결을 되풀이하지 않습니다. 굳이 잇는다면 how-to-build의 세 아키텍처 비교("every loop introduces another opportunity to go off the rails")가 하네스 편의 "안쪽은 확률론, 가장자리는 결정론"(`_posts/2026-07-29-harness-engineering-book-overview.md:232`)과 같은 모양이라는 한 문장 정도입니다.

---

## 미해결 질문

- **[유지] 작성자의 직접 사용 경험이 없습니다.** 입문편도 "공개 자료 읽기"임을 밝혀야 합니다. quickstart 응답 값, Noul 표(noul 341행 "recorded `jev-1.13.0` answers"), Score 표와 숫자 레벨 예시는 전부 **벤더가 기록한 예시**이고 이번에 재현하지 않았습니다.
  - **[미해소, 유지]** 검증 단계에서도 호출하지 않았습니다. 본문 15행과 90행이 "공개 자료 읽기", "문서의 예시"를 밝히고 있어 서술 범위는 맞습니다(VR-4, VR-11).
- **현재 공개 상태**: 2026-09-29 기준 대기자 명단이 유지되는지, Playground 로그인 계정이 얼리 액세스와 묶여 있는지 확인하지 못했습니다(quickstart .md 11행은 "log in"만 적음. 홈페이지에서 가입 정책 문구를 찾지 못함). 글에는 "발표 시점(2026-09-15) 기준 얼리 액세스"와 "OpenRouter, Vercel AI Gateway 같은 제3자 경로도 있다(V-3)"까지만 쓰세요.
  - **[미해소, 유지]** 대기자 명단 유지 여부는 2026-09-29 검증에서도 확인하지 못했습니다. 제3자 경로 두 개는 같은 날 살아 있음을 다시 확인했습니다(VR-43). 본문 281행이 "지금도 대기자 명단을 거쳐야 하는지는 확인하지 못했습니다"로 밝히고 있습니다.
- **보안 워크플로의 미공개 규칙**: 그룹 1, 3 안의 동작 조건, 그룹 5 진입 조건, `evidence_strength`, `affected_scope`, `attack_type`, 자산의 `environment`와 `tier`가 규칙에 쓰이는 방식은 공개된 예시 5건의 판정 기록에 없습니다. "domain controller" 예외는 자산이 도메인 컨트롤러인 케이스(`DC-NW-01`)에서만 close 규칙 문자열이 "(never on a domain controller)" 변형으로 나와 존재가 확인되지만, 그 밖의 자산 조건은 확인 불가. 다시 그릴 때 이 부분에 숫자나 질문 ID를 붙이지 마세요.
  - **[미해소, 유지]** 2026-09-29에 예시 5건의 판정 기록 전체에서 규칙 문자열 21개를 모아 이 목록과 대조했습니다(VR-26, VR-29, F-4). 목록 밖으로 기록된 규칙은 그룹 2와 그룹 4 안의 동작 조건뿐이고, 여기 적힌 항목은 전부 기록에 없습니다. 추가로 ISOLATE HOST에는 기록된 두 조건 말고 기록되지 않은 조건이 하나 더 있습니다(아래 항목, VR-37).
- **"never a lone production system"**(그룹 4 ISOLATE HOST 예외)의 실제 판정 방식: 예시 케이스(`DC-NW-01`, prod, tier 0)에서 ISOLATE HOST는 `activity_ongoing` 0.36으로 이미 불성립이라, 이 예외가 따로 평가됐는지 기록에서 알 수 없습니다.
  - **[부분 해소, 2026-09-29 verifier]** 같은 케이스의 **Opus 기록**이 답을 절반 줍니다. Opus는 기록된 ISOLATE HOST 조건 두 개를 모두 넘었는데(`attacker_persistence_present` 0.72, `activity_ongoing` 0.6, `group_holds: true`) 최종 동작이 `QUARANTINE FILE`입니다. 그러니 기록되지 않은 추가 조건이 **존재하고 실제로 적용된다**는 것은 확인됩니다. 그 조건이 무엇인지(흐름도 문구로 보아 "lone production system" 판정, `spread_beyond_initial_entity`를 쓰는지 여부)는 여전히 미확인입니다. Opus와 Jev의 `spread_beyond_initial_entity`는 둘 다 0.45, 기준 답의 평균은 0.76이었습니다(추정의 재료일 뿐 근거 아님). 검증 기록 VR-37.
- **벤더 수치 전부**([주장]): 속도(블로그 70ms-500ms, 문서 about 100 ms, use-case-map 150ms, 기존 노트의 다른 값들), 비용 배수, evals 정확도, primitives와 llms.txt의 Parallel questions 쿡북 배수 불일치(11.5x, 9.6x 대 12.2x, 10.0x). 독립 확인하지 않았습니다. 입문편에서 쓰지 않는 것을 권합니다.
  - **[미해소, 본문 미사용]** 본문 43행이 비용, 속도, 확신도 행을 "벤더의 주장이고 이번에 확인하지 않았으므로 옮기지 않습니다"라고 밝히고 수치를 싣지 않았습니다(VR-8). 그래서 대조하지 않았습니다.
- Kahneman 원서의 System 1, System 2 서술은 기존 노트와 마찬가지로 원서 대조를 하지 않았습니다. 벤더 문장("fast and intuitive", "slower and more deliberate")을 옮기는 수준에서 멈추세요.
  - **[미해소, 유지]** 원서 대조는 하지 않았습니다. 본문 27행은 system-one .md 36행의 벤더 서술을 옮기는 범위에 머뭅니다(VR-6).
- RLCD 방법, 아키텍처, 모델 크기는 비공개(기존 노트 미해결 질문과 같음). evals 데이터의 모델 표기 `typesafe:v13_snowy_elephant`가 공개 버전 `jev-1.13.0`과 같은 것인지는 확인 불가입니다(이름의 `v13`이 1.13과 대응하는 것으로 보이지만 추정).
  - **[미해소, 유지]** 대응은 여전히 확인 불가입니다. 다만 본문 214행의 "Jev의 답"이라는 표현은 evals 페이지 차트가 TypeSafe 모델의 workflow 항목(정확도 61.7%)에 "Jev"라는 라벨을 붙이는 데 근거합니다. 본문은 이 답을 `jev-1.13.0`의 답이라고 적지 않았습니다(VR-32).

---

## 작성 시 지켜야 할 것 (writer에게)

- **입문 글이지만 사용법 나열 금지.** 각 절이 "이걸 읽으면 무엇을 이해하게 되나"에 답해야 합니다. 설치 명령, SDK 옵션, 오류 코드 표는 본문 재료가 아닙니다. SDK 예시는 **호출 한 번의 모양을 보여 주는 용도로 한 번만** 싣고, 원문 그대로 옮깁니다(블로그 포스트 규칙: 코드 인용은 축약, 괄호 생략 금지). 부분만 싣는다면 부분임이 드러나게.
- **"써 봤다"류 서술 금지.** 도입에서 공개 자료 읽기임을 밝히세요. 예시 응답 값은 "문서의 예시 응답"이라고 적습니다.
- **벤더 주장과 설계 사실을 구분합니다.** N-5 표의 [설계], [주장], [혼합] 표시를 따르세요. 특히 "never makes type errors", "calibrated", "100x", 속도 수치는 주장입니다. 설계 사실만 쓰는 편이 입문편과 경계 양쪽에 맞습니다.
- **질문 유형 용어는 문서 표기(Choice, Score, Noul)로 통일.** 벤더 블로그 이미지의 "Bool"은 쓰지 않습니다. evals 페이지 범례도 Noul입니다.
- **보안 워크플로를 다시 그릴 때**: 단계 넷(Triage, Disposition, Containment, Playbook, 또는 evals 페이지 표기 Read the alert, Close queue or act, The state of the incident, Choose the response 중 하나로 통일), 모델 단계(①, ③)와 코드 단계(②, ④)를 시각적으로 구분, 질문 유형 아이콘 셋, 동작 등급 다섯(Close, Queue, Page, Light containment, Heavy containment). 숫자는 공개 데이터에 있는 것만 싣고(`is_true_positive` 0.75, 0.15, 0.60, 그룹 진입 문턱들), 규칙이 공개되지 않은 부분에는 숫자를 붙이지 마세요. 출처는 "TypeSafe 블로그와 evals 사이트의 Security Incidents 워크플로를 다시 그림"으로 밝힙니다.
- **예시 케이스 경로(Amsi.dll)를 쓸 경우** 기준 답과 달랐다는 사실("All three miss the reference", 기준 ISOLATE HOST)을 함께 적고, 기준 답이 두 대형 모델의 합의라는 점까지만 짧게. 평가의 타당성 논의로 번지면 심화편과 겹칩니다.
- **맞지 않는 자리는 벤더가 스스로 적은 것 위주로.** jaggedness 실패 모드 표와 coding-agents 문서가 1차 근거입니다. 제3자 반론(priorbench의 99.6% 등)은 싣지 않습니다.
- **개수와 번호 라벨 금지**(하네스 문단 응집 계약): "세 가지를 다룹니다", "첫째/둘째" 쓰지 않기. 예고는 소주제 이름으로.
- **em dash가 든 원문**: coding-agents 28행("you're building — for routing"), state .md 32행, AI primer 91행, how-to-build의 일부는 em dash를 포함합니다. 인용 범위를 em dash 앞이나 뒤로 조정하세요. 벤더 질문 정의의 `--`(하이픈 둘)는 em dash가 아니므로 원문 그대로 둡니다.
- **가운뎃점이 든 원문**: 보안 워크플로 입력 노드 "the alert · the asset it fired on · ...", 플레이북 그룹 번호 "1 · data is leaving now" 등, evals 장난감 예제 "the receipt · the claim form"은 원문 표기가 가운뎃점입니다. 영문 원문 인용이면 그대로 두되, 한국어로 옮겨 그릴 때는 쉼표로 바꾸세요(전역 문체 규칙).
- **외부 인용은 이 노트에 있는 것만**(#16 계약). 새 인용이 필요하면 verifier 단계에서 노트에 먼저 추가합니다.
- **발행 시점 기록**: 모델 버전, 별칭, 공개 상태 문장에는 조회일(2026-09-29)을 붙입니다.
- **문체**: 습니다체 기본, 해요체는 리듬 변주로 최소(CLAUDE.md 포스트 규칙). frontmatter 순서 `layout → date → title → subtitle → tags`.
- **맺음**: 심화편 링크로 넘깁니다. 심화편의 결론을 미리 요약하지 말고, 입문편이 남긴 질문(돌려받은 숫자를 어디에 쓰는가)을 넘기는 형태로.

---

## 검증 기록

검증일 2026-09-29, blog-verifier. 대상 초안 `_drafts/jev-system-one-intro.md`. 아래 "본문 N행"은 검증 후 초안 기준입니다. 본문 줄번호는 검증 전과 같고, 각주 `[^score]` 한 줄을 더해 그 아래 각주 정의만 한 줄씩 밀렸습니다.

### 요약

- 확정 40건, 교정 4건(VR-5, VR-16, VR-37, VR-39), 확인 불가 0건. 교정 중 VR-37은 **주장 재검토 필요**(사용자 판단)를 겸합니다.
- writer 플래그 2건: 1번(Score 레벨 번호)은 확정하고 플래그를 지운 뒤 각주 `[^score]`를 더했습니다(VR-15). 2번(Intent Routing 주소)은 주소를 확정하고 각주를 고쳤습니다(VR-39).
- 그림 주석 4개: 데이터 오류 없음, 주석은 고치지 않았습니다(F-1~F-4). F-1과 F-4에 그릴 때의 주의를 적었습니다.
- 심화편 주제(보정 논증, 송금 예제, 독립 측정) 유입 없음(VR-45).
- 근거 사슬 게이트: 본문의 외부 인용, 수치, 버전이 전부 아래 항목에 있습니다(끝의 "완료 조건 점검").

### 조회 방법 (재현용)

- **방법 D (벤더 문서).** `curl -sS -L https://docs.typesafe.ai/{경로}.md`로 받은 원문. 줄번호는 맨 앞 "Documentation Index" 안내 3줄을 포함한 원문 기준입니다(N절과 같은 체계). 2026-09-29에 받은 파일과 크기: `concepts/system-one` 3,790B, `introduction` 4,114B, `introduction/quickstart` 7,053B, `api` 11,231B, `primitives` 24,072B, `primitives/score` 43,657B, `confidence` 11,396B, `model-jaggedness/jev-1.13` 10,736B, `models` 6,577B, `concepts/how-to-build-with-system-one` 40,921B, `concepts/use-case-map` 11,042B, `patterns` 1,477B, `patterns/intent-routing` 13,444B, `introduction/coding-agents` 3,821B, `llms.txt` 16,019B(N절 기록과 같은 크기).
- **방법 B (벤더 블로그).** `curl -sS -L https://typesafe.ai/blog/introducing-system-one-models-and-jev`(257,471B). `<script>`와 `<style>`을 지우고 태그를 벗긴 텍스트로 대조했습니다. 블로그 이미지 `https://framerusercontent.com/images/ih1bFwZGYJxlnijbTuXx3f9NeM.png?width=2048&height=704`는 직접 받아 열람했고, HTML 안의 문자 위치로 앞뒤 문단을 확인했습니다.
- **방법 E (evals 사이트).** `https://evals.typesafe.ai/`(65,946B), `https://evals.typesafe.ai/security_incidents.html`(47,625B), `https://evals.typesafe.ai/security_incidents-cases.js?v=6c96b19f`(89,160B, N절과 같은 크기). cases.js는 `__VIEWER_DATA__(`와 마지막 `)` 사이를 JSON으로 파싱했습니다. 질문 ID는 SVG의 `data-q`, 질문 유형은 SVG 아이콘 마크업을 데이터의 `icons` 필드(noul 반원, score 막대, choice 격자)와 대조, 동작 등급은 `class="fc-chip {등급}"`으로 셌습니다.
- **방법 R (렌더).** `bundle exec jekyll build --drafts -d {스크래치}`로 빌드해 `2026/09/29/jev-system-one-intro.html`을 확인했습니다(Ruby 3.4, 저장소 Gemfile). 표 한 개는 kramdown GFM 입력으로 따로 렌더해 한 번 더 봤습니다.

### 플래그

**VR-15. [플래그 1] Score의 레벨 번호가 모델에 보이지 않는다: 확정, 각주 추가**
- 대상: 본문 128행 "Score의 레벨 번호도 모델에게 보이지 않는다고 Score 문서가 적습니다."
- 서지: TypeSafe 문서 "Score"(.md 5행 제목 "# Score"), https://docs.typesafe.ai/primitives/score , 2026-09-29 조회.
- 원문(.md 744행): "Every level is evaluated separately. The model doesn't see a level's number or its neighbours, so "worse than the previous level" means nothing to it, and numbers in the descriptions or the instructions don't help. Here is what happens when the levels are only numbers, on the misaligned-button report from the table above:"
- 이어지는 예시(747~749행, 752행): `instructions: "Rate severity from 0 to 2, where 2 is worst"`, `criteria: ["0", "1", "2"]`, "→ score 0.55, confidence 0.33, probabilities 0: 0.45, 1: 0.55, 2: 0.0" / "The same report with the three descriptive levels scores 0.0 at confidence 1.0." 노트 인사이트 4의 숫자와 같습니다(본문은 이 숫자를 쓰지 않음).
- 확인 방법: 방법 D.
- 정합성: 본문은 "레벨 번호도 보이지 않는다"만 적어 원문(번호와 이웃 레벨 둘 다 보이지 않음)보다 약하고 정확합니다. 플래그를 지웠습니다. Score 문서가 본문에 처음 나오는 자리인데 각주가 없어 `[^score]`를 더했습니다(문장 표현은 그대로).

**VR-39. [플래그 2] Intent Routing 개별 페이지 주소: 확정, 각주 교정**
- 대상: 본문 250행 인용, 252행 예제 서술, 각주 `[^patterns]`.
- 서지: TypeSafe 문서 "Intent routing"(.md 5행 제목 "# Intent routing"), https://docs.typesafe.ai/patterns/intent-routing , 2026-09-29 조회. 주소 출처는 `llms.txt` 23행 "[Intent routing](https://docs.typesafe.ai/patterns/intent-routing.md)"과 patterns .md 20행 표 링크 `/patterns/intent-routing`.
- 확인 방법: 방법 D. `.md`(13,444B)와 HTML 경로(HTTP 200) 둘 다 받았습니다.
- 원문(.md 242행): "Let's imagine you are building a customer service system. Messages come in and need to be routed to the right handler. Rather than sending every message through an expensive LLM to figure out what kind of request it is, you classify first and route accordingly." 본문 인용 부분 축자 일치.
- 예제(244~267행 mermaid, 302~326행 `route_ticket`): intent confidence < 0.5면 "human agent" / `order_status`는 "order lookup deterministic code" / `product_question`은 "product specialist LLM" / `return_exchange`는 "returns specialist LLM" / `complaint`는 complexity > 1이거나 그 confidence < 0.5면 사람, 아니면 "complaint resolution LLM".
- 정합성: 본문 252행 서술은 원문과 맞습니다(complaint 가지는 생략했을 뿐 틀린 진술 없음).
  - 전: `[^patterns]: TypeSafe 문서, "Patterns"와 그 아래 Intent Routing 패턴 페이지. [docs.typesafe.ai](https://docs.typesafe.ai/patterns). 2026-09-29 조회. 인용 문장은 Intent Routing 페이지 .md 판 242행(개별 페이지 주소 확인 필요).`
  - 후: `[^patterns]: TypeSafe 문서, "Intent routing". [docs.typesafe.ai](https://docs.typesafe.ai/patterns/intent-routing). 2026-09-29 조회. "Patterns" 문서(https://docs.typesafe.ai/patterns)의 패턴 네 개 중 하나다. 인용 문장은 .md 판 242행, 예제의 처리기 배정은 244~267행 흐름도.`

### 교정

**VR-5. 소개 문서의 설계 동기 두 문단: 인용 확정, 위치 서술 교정**
- 대상: 본문 33행 인용, 35행.
- 서지: TypeSafe 문서 "Introduction", https://docs.typesafe.ai/introduction , 2026-09-29 조회.
- 원문: 9행은 본문 33행 인용과 축자 일치. 11행 전문 "Jev is TypeSafe's flagship model and the first [System One model](/concepts/system-one). System One models are built to make fast, structured decisions that software can use directly. Jev evaluates typed *questions* against a *state* and returns structured results directly. No text generation, no parsing. You get typed values and probability distributions that your code can branch on, sort by, and route with. Choice and Score also return [confidence](/confidence), which your code can use to decide whether and how to act on an answer."
- 확인 방법: 방법 D.
- 정합성: 인용은 축자 일치하지만 11행 문단의 첫 문장이 아니라 넷째와 다섯째 문장입니다. "로 시작합니다"가 틀려 고쳤습니다.
  - 전: 소개 문서의 다음 문단은 "No text generation, no parsing. You get typed values and probability distributions that your code can branch on, sort by, and route with."로 시작합니다.
  - 후: 소개 문서는 다음 문단에서 "No text generation, no parsing. You get typed values and probability distributions that your code can branch on, sort by, and route with."라고 적습니다.

**VR-16. 요청을 나누는 조건과 "Two requests are the exception": 인용 확정, 인접성 서술 교정**
- 대상: 본문 110행.
- 서지: TypeSafe 문서 "Primitives", https://docs.typesafe.ai/primitives , 2026-09-29 조회.
- 원문: 456행 "Questions in the same request are independent: one answer does not become context for another question. If a later judgment depends on an earlier answer, make a second request in code. The dependency is real only when your code cannot build the second request until it has the first answer: it needs the answer to fetch more data for the state, to decide what the state is made of, or to pick the next question's options. Otherwise, ask the questions together and combine their answers in code." / 458행 "Two requests are the exception, not the rule. If the second request's questions could have been asked against the original state, ask them in the first request and let the code ignore the ones it doesn't need. ..."
- 확인 방법: 방법 D.
- 정합성: 두 인용 모두 축자 일치하고 각주 줄번호(456~458행)도 맞습니다. 다만 두 인용 사이에 456행의 두 문장이 있고, 둘째 인용은 458행 문단의 첫 문장입니다. "바로 덧붙입니다"가 인접성을 잘못 말해 고쳤습니다.
  - 전: 문서는 후자를 "If a later judgment depends on an earlier answer, make a second request in code."라고 적고 바로 "Two requests are the exception, not the rule."을 덧붙입니다.
  - 후: 문서는 후자를 "If a later judgment depends on an earlier answer, make a second request in code."라고 적고, 다음 문단 첫머리에 "Two requests are the exception, not the rule."을 덧붙입니다.

**VR-37. Amsi.dll 케이스에서 "어긋남이 어디서 났는지": 교정, 주장 재검토 필요**
- 대상: 본문 222행.
- 서지: TypeSafe, Security Incidents 워크플로 데이터 https://evals.typesafe.ai/security_incidents-cases.js?v=6c96b19f , `eval.cases["art_T1574.001-2__peer_contained__t0"]`, 2026-09-29 조회.
- 확인 방법: 방법 E. 세 모델(`opus` = `anthropic:claude-opus-5`, `sol` = `openai:gpt-5.6-sol`, `typesafe` = `typesafe:v13_snowy_elephant`)의 `decisions.playbook.tests`, `actions`, `keys`와 `reference_answers`를 모두 대조했습니다.
- 사실:
  - Jev(`typesafe`): `isolate host` 테스트 `attacker_persistence_present` "P > 0.60" value 0.68 holds true, `activity_ongoing` "P > 0.50" value 0.36 holds false, `group_holds` false. 경로 끝 `G4.quarantine_file`, 동작 `QUARANTINE FILE`.
  - Opus: 같은 두 테스트가 value 0.72와 0.6으로 **둘 다 holds true, `group_holds` true**인데 `actions`는 `QUARANTINE FILE`, 경로 끝은 `G4.quarantine_file`입니다. 기록된 조건을 다 넘고도 ISOLATE HOST가 나오지 않았습니다.
  - Sol: `activity_ongoing` 0.24로 불성립, `QUARANTINE FILE`.
  - 기준 답(Astra와 Fable 평균): `activity_ongoing` (0.6 + 0.55) / 2 = 0.575, `attacker_persistence_present` 0.75, `spread_beyond_initial_entity` (0.9 + 0.62) / 2 = 0.76, 동작 `ISOLATE HOST`. Jev와 Opus의 `spread_beyond_initial_entity`는 둘 다 0.45입니다.
  - 흐름도 그룹 4 문구 "live persistence isolates the host, never a lone production system"(security_incidents.html SVG 텍스트). 이 예외는 예시 5건, 세 모델의 판정 기록 어디에도 규칙 문자열로 나오지 않습니다(규칙 문자열 21종 대조, F-4).
- 정합성: 원래 문장은 이 두 숫자만으로 ISOLATE HOST와 그 아래가 갈렸다고 읽힙니다. Opus 기록은 공개되지 않은 조건이 ISOLATE HOST를 한 번 더 거른다는 것을 보여 주므로, 이 읽힘은 공개 기록보다 강합니다. Jev의 기록에서 ISOLATE HOST를 떨어뜨린 것이 `activity_ongoing`이라는 사실만 남기도록 좁혔습니다.
  - 전: 질문 11개 중 가장 강한 조치와 그다음을 가른 것은 `activity_ongoing`의 0.36과 규칙에 적힌 0.50, 이 두 숫자입니다.
  - 후: Jev의 판정 기록에서 질문 11개 중 가장 강한 조치를 떨어뜨린 것은 `activity_ongoing`의 0.36과 규칙에 적힌 0.50, 이 두 숫자입니다.
- **→ 해소(2026-09-29, 사용자 결정 "단서 문장 더하기"):** 좁힌 문장 뒤에 세 문장을 더했습니다. "다만 이 숫자만 바뀌었다면 호스트 격리가 나왔을지는 공개 기록으로 알 수 없습니다. 같은 케이스에서 Opus는 호스트 격리에 기록된 조건 두 개를 모두 넘었는데도(0.72와 0.6) 최종 동작이 파일 격리였습니다. 흐름도의 "never a lone production system"처럼, 공개된 판정 기록에 없는 조건이 한 번 더 거르는 것으로 보입니다." 수치와 문구의 근거는 위 사실 항목(Opus 테스트 값, 흐름도 SVG 텍스트) 그대로이고, 숨은 조건이 그 문구라는 것은 "보입니다"로 추정임을 밝혔습니다.
- **주장 재검토 필요(사용자 판단).** 바로 앞 문장 "어긋남이 어디서 났는지를 짚을 수 있다는 점입니다"는 `activity_ongoing` 한 지점(Jev 0.36, 기준 평균 0.575)까지만 성립합니다. `activity_ongoing`이 0.50을 넘었더라도 Jev가 ISOLATE HOST를 골랐을지는 공개 기록으로 알 수 없습니다. 단서를 더할지는 이 문단의 논지(분해하면 들여다볼 곳이 생긴다)에 걸리므로 verifier가 쓰지 않고 초안에 `<!-- 검증: 주장 재검토 필요 -->` 주석으로 남겼습니다. 참고로 이 사실은 논지를 오히려 받칠 수도 있습니다. 세 모델의 판정 기록을 나란히 놓으면 공개 규칙에 없는 조건이 있다는 것까지 드러나기 때문입니다. 쓴다면 후보 문장: "다만 같은 케이스에서 Opus는 `activity_ongoing` 0.6으로 이 조건을 넘고도 `QUARANTINE FILE`에 멈췄습니다. 공개 기록에 없는 규칙이 한 겹 더 있다는 뜻이라, 기록으로 짚을 수 있는 것도 거기까지입니다."

### 확정: 벤더 블로그

**VR-1. 발표일, 회사명, 서명: 확정 (R-1, V-1과 일치)**
- 대상: 본문 9행 "TypeSafe AI가 2026-09-15에 Jev를 발표", 각주 `[^blog]`.
- 서지: Diogo Almeida(서명 "Diogo Almeida, founder, TypeSafe"), "Introducing System One Models & Jev", TypeSafe AI Blog, Company News, 2026-09-15. https://typesafe.ai/blog/introducing-system-one-models-and-jev
- 확인 방법: 방법 B. 보이는 본문의 게시일 "Sep 15, 2026", 본문 "today, TypeSafe AI is releasing our first System One Model", 푸터 "TypeSafe AI © 2026".
- 정합성: 정확.

**VR-2. 서두의 질문: 확정**
- 대상: 본문 9행 "회사 블로그 첫머리", 11행 인용.
- 원문: 서명 바로 다음 첫 문장 "Models have been superhuman at chat for years, so where is all the automation?" 축자 일치.
- 확인 방법: 방법 B. 정합성: "첫머리" 정확.

**VR-3. 결말부의 설립 이유: 확정**
- 대상: 본문 13행.
- 원문: "What's next" 절 마지막 문단(FAQ 바로 앞) "We started TypeSafe because we believe that AI needs an interface software could depend on. We can't wait to see new use cases continuously diffuse through the community and economy." 인용 문장 축자 일치.
- 확인 방법: 방법 B. 정합성: 뒤에는 FAQ만 남아 "결말부" 정확.

**VR-4. 발표 시점의 얼리 액세스: 확정 (R-14, V-3과 일치)**
- 대상: 본문 15행, 281행 인용.
- 원문: "What's next" 절 "Today, we are opening early access and bringing developers off the waitlist as quickly as we can." 첫머리 문단 "Our first public model is Jev, available today in early access."
- 확인 방법: 방법 B.
- 정합성: 본문이 "발표 시점 기준"과 "지금도 대기자 명단을 거쳐야 하는지는 확인하지 못했습니다"로 범위를 좁혀 정확합니다. 현재 상태는 미해결 질문에 미해소로 남겼습니다.

**VR-7. Jev 이름의 유래: 확정 (R-3, V-43과 일치)**
- 대상: 본문 27행 끝 문장.
- 원문: FAQ "Where do the names “System One Models” and “Jev” come from?"의 답 "We named Jev after William Stanley Jevons. We expect machine intelligence to follow a similar path to coal, ..."
- 확인 방법: 방법 B. 정합성: 정확.

**VR-8. 비교표 "Frontiers, Old and New"의 인용 셀: 확정 (R-16, N-5와 일치)**
- 대상: 본문 39행("sequential messages", "structured program state"), 40행(LLM 문자열), 41행(LLM의 순차 생성), 43행(비용, 속도, 확신도 행의 존재와 "The model never makes type errors."), 100행("모든 답에 확신도가 붙는다고 적었지만").
- 원문(열 머리 "Existing LLMs" | "System One + Jev"): Inputs "Unstructured data (e.g. text) with an emphasis on sequential messages." | "Unstructured data (e.g. text) with an emphasis on structured program state." / Outputs(LLM) "Strings / generated text. Strings are flexible and can be anything: ..." / Outputs(Jev) "Type-safe structured values. Possible outputs and structure are defined in advance. The model never makes type errors. All answers are accompanied with calibrated probabilities and confidence scores." / Sampling(LLM) "Sequential. Generates one token at a time, each conditioned on the last." / Cost, Speed, Confidence 행 존재.
- 확인 방법: 방법 B.
- 정합성: 본문은 [주장] 셀을 주장으로 밝히고 수치를 옮기지 않았습니다. "모든 답에 확신도"가 API 문서와 어긋난다는 서술은 api .md 223행과 primitives .md 305행 "Noul has no separate `confidence`."로 맞습니다.

**VR-17. "smart if-statements"와 첫 용도 설명: 확정**
- 대상: 본문 112행, 232~234행.
- 원문: 비교표 Use cases(Jev) 첫 항목 "AI-Powered Workflows / smart if-statements. Structured outputs slot into ordinary software as fuzzy decision rules: classify, route, score, extract, or branch where hand-written logic is too brittle. The surrounding code constrains their freedom, making them easier to compose into reliable systems."
- 확인 방법: 방법 B. 정합성: 234행 인용 축자 일치.

**VR-22. 보안 알림 워크플로의 소개 위치와 문제 설정: 확정**
- 대상: 본문 178행.
- 원문과 위치: 블로그 "Workflow evals" 절 "Below is the simplest of the 4 workflows we’re publishing:"(아포스트로피 U+2019, 본문도 같은 문자) 바로 뒤에 이미지 `ih1bFwZGYJxlnijbTuXx3f9NeM.png`가 옵니다(HTML 문자 위치: 문장 170604, 이미지 170834, 다음 문단 171489). 이미지는 단계 머리 Triage, Disposition, Containment, Playbook과 동작 칩 17개가 있는 Security Incidents 흐름도입니다(직접 열람). evals 페이지 머리 "An alert has fired. What should be done?", 입력 "Open tickets", "Registered devices", "Scheduled maintenance", "Standing authorizations", evals 홈 소개 "we decide whether to close it, pass it to an analyst, or contain it now."
- 확인 방법: 방법 B, 방법 E.
- 정합성: 정확. "the simplest of the 4 workflows we’re publishing" 축자 일치.

**VR-31. 이미지 아래 문단 인용: 확정**
- 대상: 본문 206~208행 "발표 글은 이 워크플로 그림 아래에 이렇게 적었습니다."
- 원문: 이미지 바로 다음 문단 "The most reliable real-world workflows tend to have many independent, decomposed questions, with fine-grained behavior that’s dependent on probabilities instead of discrete decisions. The end result is discrete branching, but how we get to a final answer involves a lot of domain-specific engineering that needs to be done highly consistently."
- 확인 방법: 방법 B. 정합성: 인용 문장 축자 일치, 위치 정확.

**VR-40. "Verify everything": 확정**
- 대상: 본문 252행 끝 두 문장.
- 원문: 비교표 Use cases(Jev) "Verify everything. Score, judge, verify, guardrail, and detect jailbreaks of LLM prompts, reasoning traces, and/or outputs." 본문의 "LLM의 입력, 출력, 도구 호출을 검사하는 가드레일"은 use-case-map .md 63행 "Place semantic checks on every LLM input, output, and tool call at a fraction of the cost of the LLM call."과 맞습니다.
- 확인 방법: 방법 B, 방법 D.
- 정합성: 비교표 항목에 "guardrail"이 있어 "같은 자리"라는 연결은 맞습니다. 도구 호출은 블로그가 아니라 use-case-map의 표현이지만 본문이 이를 블로그 문구로 인용하지는 않았습니다.

### 확정: 벤더 문서

**VR-6. System One 개념 문서: 확정 (R-17, V-43과 일치)**
- 대상: 본문 25행 인용, 27행(state를 받아 타입이 정해진 답과 확률, Kahneman, "Here, the emphasis is on fast, focused judgments."), 39행("Like an LLM, ..."), 40행("System One models do not write replies, ..."), 102행. 각주 `[^system-one]`.
- 서지: TypeSafe 문서 "System One", https://docs.typesafe.ai/concepts/system-one , 2026-09-29 조회.
- 원문: 9행 "System One models are a class of AI models built to make fast, structured decisions that software can use directly. A System One model evaluates a [state](/concepts/state) and returns typed answers and probabilities." / 13행 "Like an LLM, a System One model understands natural-language input. It returns typed decisions and probabilities rather than generated text." / 23행 "System One models do not write replies, produce code, or generate explanations of their reasoning. ..." / 36행 "The System One name comes from the concept Daniel Kahneman popularized in his book *Thinking, Fast and Slow*. System 1 thinking is fast and intuitive. System 2 is slower and more deliberate. Here, the emphasis is on fast, focused judgments." / 49행 "Answers from System One models also include [confidence](/confidence), so you can decide when to act and when to escalate to a person or a reasoning model."
- 확인 방법: 방법 D.
- 정합성: 인용 전부 축자 일치(49행은 링크 마크업만 평문으로), 각주 줄번호 9, 13, 23, 36, 49 모두 맞습니다. Kahneman 서술은 벤더 문장을 옮긴 범위이고 원서 대조는 하지 않았습니다.

**VR-9. 소개 문서의 병렬 평가, gut-check, context rot: 확정 (R-6, R-7과 일치)**
- 대상: 본문 41행, 160행, 274행. 각주 `[^intro]`.
- 원문: introduction .md 37행 "All three *question* types can be mixed in a single API call. Every *question* is evaluated in parallel and in isolation against the same *state* in one go. Adding questions barely changes the response time. Each question is evaluated independently, so adding more questions does not create context-rot." / 41행 "System One models work best when each question asks one specific, well-scoped thing. Think of each question as a gut-check determination: the kind of judgment a highly knowledgeable person could make in a few seconds given the right context."
- 확인 방법: 방법 D.
- 정합성: 인용 축자 일치. 41행은 "a few seconds"이고 본문 160행의 "1초"는 primitives .md 250행 "in a second"에서 옵니다. 본문은 41행에서 "gut-check determination"이라는 표현만 가져와 둘을 섞지 않았습니다. 각주 줄번호 9, 11, 37, 41 맞음.

**VR-10. quickstart SDK 코드: 확정**
- 대상: 본문 51~86행 코드 블록.
- 서지: TypeSafe 문서 "Quickstart", https://docs.typesafe.ai/introduction/quickstart , 2026-09-29 조회.
- 확인 방법: 방법 D. .md 156~189행(코드 펜스 안)과 초안 52~85행을 `diff`로 비교, 차이 없음.
- 정합성: 원문 그대로(포스트 규칙 충족). 각주 "153~190행"은 153행 안내 문장부터 190행 펜스 끝까지로 맞습니다.

**VR-11. quickstart 예시 요청과 응답 값: 확정**
- 대상: 본문 88행, 90행.
- 원문(.md 65~136행): 요청 `"model": "jev-latest"`, 질문 `department`(choice, "Which team should handle this", 물음표 없음), `frustration`(score), `is_urgent`(noul, "The message conveys urgency or time-sensitivity"), 질문 셋 중 `is_urgent`만 `criteria`가 없음. 응답 `"model": "jev-1.13.0"`, `department` `"choice": "technical"`, `"confidence": 0.78`, probabilities technical 0.85, sales 0.0, billing 0.15 / `frustration` `"score": 1.0`, `"confidence": 1.0`, probabilities 0: 0.0, 1: 1.0, 2: 0.0 / `is_urgent` `"noul": 1.0` / usage 392, 65.
- 확인 방법: 방법 D.
- 정합성: 본문 값 전부 일치. "응답의 `model` 필드에는 실제로 답한 버전"은 models .md 40행 "The response's `model` field reports the versioned ID that answered"로 맞습니다. 본문이 "문서의 예시"임을 밝혔습니다.

**VR-12. API 문서: 확정 (R-4와 일치)**
- 대상: 본문 39행(`state` 타입), 96~98행, 100행, 122행. 각주 `[^api]`.
- 서지: TypeSafe 문서 "API reference", https://docs.typesafe.ai/api , 2026-09-29 조회.
- 원문: 23행 `state` "string | object | array" / 36행 "A key you choose. The matching [Answer](#answer-types) is returned under this same id. The key is not sent to the underlying model and is not used in inference." / 223행 "Every answer carries a `type` matching its question. Choice and Score answers also carry a `confidence` between 0 to 1, derived from the answer's probability distribution." / 230행 "The yes/no answer on a scale from 0 (no) to 1 (yes)." / 251행 "The highest-probability option." / 255행 "Every option mapped to its probability (floats that sum to 1)." / 288행 "The probability-weighted answer across the levels; can land between levels." / 309~323행 Score 예시 `"score": 1.05`, probabilities 0: 0.0, 1: 0.95, 2: 0.05, confidence 0.92.
- 확인 방법: 방법 D.
- 정합성: 인용 축자 일치, 각주 줄번호 36, 223, 288, 309~323 맞음. 0×0.0 + 1×0.95 + 2×0.05 = 1.05 산술 맞음.

**VR-13. primitives 문서: 확정**
- 대상: 본문 98행, 100행, 108행, 126행, 142~144행, 148행, 158행, 166행. 각주 `[^primitives]`.
- 서지: TypeSafe 문서 "Primitives", https://docs.typesafe.ai/primitives , 2026-09-29 조회.
- 원문: 250행(본문 158행 인용은 둘째 문장부터 끝까지 축자) / 252행 "When priorities shift, change the value of weights rather than rewriting a prompt." / 276행 Tip(본문 126행 축자) / 283~287행 선택 기준(본문 142행 인용 "add an `other` or `none of the above` option when the list might not cover every input" 축자, 예시 요약 일치) / 290행 "A Noul value of 0.5 means the model gives yes and no equal probability. It does not mean the candidate has a medium skill level." / 292행 Score 권고 / 295행(본문 148행 축자) / 303행 "`confidence` summarizes how peaked that distribution is." / 310행(본문 108행 축자).
- 확인 방법: 방법 D.
- 정합성: 전부 일치, 각주 줄번호 전부 맞음.

**VR-14. 확신도 정의: 확정 (R-5, V-9와 일치)**
- 대상: 본문 100행 인용. 각주 `[^confidence]`.
- 서지: TypeSafe 문서 "Confidence", https://docs.typesafe.ai/confidence .
- 원문(.md 149행): "`confidence` is a statistic computed from the probability distribution the answer already gives you. TypeSafe computes it for you and returns it on every Choice and Score answer, so the common case needs no extra work on your side."
- 확인 방법: 방법 D로 2026-09-29에 다시 받았고, 줄번호와 문장이 2026-09-28 기록과 같습니다.
- 정합성: 축자 일치. 각주의 "2026-09-28 조회(심화편 노트에서 옮김)"는 사실대로라 고치지 않았습니다.

**VR-18. jaggedness 문서: 확정 (R-11, R-13과 일치)**
- 대상: 본문 130~134행, 258행, 266행, 270행, 272행, 280행, 289행. 각주 `[^jagged]`.
- 서지: TypeSafe 문서 "Jev 1.13 jaggedness", https://docs.typesafe.ai/model-jaggedness/jev-1.13 , 10행 "**Applies to `jev-1.13`.** Last reviewed 2026-09-17.", 2026-09-29 조회.
- 원문: 13행 "It may struggle with tasks that require additional levels of indirection." / 20행 "Keep the arithmetic in code" / 21행 "Extract components; compare in code" / 31행 "`jev-1.13` answers the question you wrote, not the one you meant. Scoping words, negations, and implied conditions are read at face value." / 33행 "When you look at a wrong answer and find yourself explaining what you really meant, that explanation is the missing half of the instruction." / 43행 "If the unit is something a regular expression or a parser can find, the count belongs in code and the model has nothing to add." / 106행 "State is data, and `jev-1.13` does not treat it as hostile by default." / 108행 "be explicit in the criteria. Test your integration thoroughly before deploying it to many users." / 141행 "`jev-1.13` is not trained to generate text. ... For data extraction, it is better to extract possible options using regex or a generative model and let `jev-1.13` pick the correct extraction." / 150행 "System Two tasks: more layers of indirections" / 151행 "Jev suffers from context rot, so unrelated material in the `state` costs you accuracy."
- 확인 방법: 방법 D.
- 정합성: 인용 전부 축자 일치, 리뷰일 일치, 각주 줄번호 전부 맞음. 272행의 "한 단계 건너 추론해야 하는 질문에서 모델이 고전할 수 있다"는 13행의 강도("may struggle")와 같습니다.

**VR-19. models 문서: 확정 (R-12, R-14와 일치)**
- 대상: 본문 136행, 278행, 279행, 281행, 289행. 각주 `[^models]`.
- 서지: TypeSafe 문서 "Models", https://docs.typesafe.ai/models , 2026-09-29 조회.
- 원문: 11행 "| Jev 1.13 | `jev-1.13.0` |"(Current models 표의 유일한 모델) / 33~34행 `jev-latest`와 `jev-preview` 모두 Points to `jev-1.13.0` / 37행 "`jev-preview` currently points to the same model as `jev-latest`. There is no preview build available right now." / 21행 "Pre-process non-text inputs (images, audio, video, binaries) into text or structured fields before sending them as `state`." / 44행 "Jev is not fine-tuned or LoRA-adapted with customer data. It is trained with [RLCD](...) to return calibrated decisions, and the same weights serve every account. You shape its answers to your domain through the request rather than through per-account weights:" / 46~48행 세 방법(state에 자료, instructions와 criteria에 규칙과 경계 사례, 원자 질문으로 쪼개 코드로 합치기) / 52행 "English is the primary training language and where accuracy is currently best. Other languages, including CJK scripts, are handled but not equally well; ..."
- 확인 방법: 방법 D.
- 정합성: 2026-09-29 기준 `jev-1.13.0` 하나와 별칭 둘이 모두 이 버전임을 확정. 136행의 세 방법과 "모든 계정이 같은 가중치" 일치. 279행 인용은 세미콜론 앞에서 끊었지만 뜻이 바뀌지 않습니다.

**VR-20. how-to-build 문서: 확정 (R-10과 일치)**
- 대상: 본문 162행, 164행, 166행, 170~172행. 각주 `[^howto]`.
- 서지: TypeSafe 문서 "How to build with TypeSafe", https://docs.typesafe.ai/concepts/how-to-build-with-system-one , 2026-09-29 조회.
- 원문: 241행 "**Summary:** build a normal software workflow and insert System One only where AI is needed." / 243행(바로 아래 첫 항목) "Keep control flow, deterministic rules, and side effects in code." / 252행 "**AI-powered software**" / 264행(본문 172행 축자) / 404행(본문 162행 축자) / 407~495행 스팸 예시: 409행 "One broad question (bad)"의 `is_spam` noul "Is `message` spam?", 440행 "Decomposed questions (good)"의 noul 여섯 개 `requests_credentials`, `offers_unexpected_reward`, `creates_time_pressure`, `sender_identity_mismatch`, `link_domain_mismatch`, `disguises_link_destination`, state 발신자 "Acme Payroll" `rewards@claim-bonus.example`, 제목 "Urgent: claim your employee bonus" / 805행 "Decomposition does not require more round trips. Questions over the same state run in parallel."
- 확인 방법: 방법 D.
- 정합성: 전부 일치. 164행의 우리말 풀이는 각 질문 instructions(465~490행)의 요약으로 뜻이 맞습니다(작성자 노트대로 번역 인용이 아님). 각주 줄번호 전부 맞음.

**VR-38. use-case-map 결정 모양 표와 모델 라우팅: 확정**
- 대상: 본문 236~244행, 248행. 각주 `[^usecase]`.
- 서지: TypeSafe 문서 "Use case map", https://docs.typesafe.ai/concepts/use-case-map , 2026-09-29 조회.
- 원문: 180~191행 표 열 행(Classification, Detection, Scoring, Routing, Search, Retrieval, Ranking, Verification, ML Feature Extraction, Structured Data Extraction). 본문 표의 다섯 행은 182, 183, 184, 185, 189행이고 "Reach for it when"과 "Examples" 열이 축자 일치. 55행 "Use Jev to build a custom router that chooses which LLM receives each prompt."
- 확인 방법: 방법 D.
- 정합성: "열 가지 모양" 정확, 표 셀 축자 일치, 각주 줄번호 맞음.

**VR-41. coding-agents 문서: 확정 (R-9와 일치)**
- 대상: 본문 258~262행. 각주 `[^coding-agents]`.
- 서지: TypeSafe 문서 "Coding agents", https://docs.typesafe.ai/introduction/coding-agents , 2026-09-29 조회.
- 원문: 9행 "If you found TypeSafe while looking for a model to plug into your coding agent, start here. Jev is **not** a drop-in replacement for the LLM behind Claude Code, Cursor, opencode, Copilot, Muse Spark, Grok Bot, or similar tools. Instead, you can use your coding agent as usual to write code that uses Jev to make decisions." / 19행 "... There is no `model: "jev-latest"` setting that turns your coding agent into a Jev-powered agent, because the two systems solve different problems."
- 확인 방법: 방법 D. 정합성: 인용 축자 일치(9행 첫 문장은 인용하지 않음), 줄번호 맞음.

**VR-42. llms.txt의 "Pre-parsed value extraction": 확정**
- 대상: 본문 268행. 각주 `[^llms]`.
- 원문(llms.txt 39행): "Uses regexes to find candidate emails, phone numbers, and amounts, then has TypeSafe select the requested span so code can normalize a verbatim value."
- 확인 방법: 방법 D. 정합성: 본문 요약과 일치.

**VR-43. 공개 범위(API 전용, 공개 가중치 없음, 제3자 경로): 확정, 부재 확인은 조회 범위를 밝힘**
- 대상: 본문 281행 "API로만 쓸 수 있고 공개 가중치는 없습니다", "OpenRouter와 Vercel AI Gateway 같은 제3자 경로도 있습니다."
- 확인 방법과 결과(2026-09-29):
  - OpenRouter `GET https://openrouter.ai/api/v1/models/typesafe/jev-1.13/endpoints`: `typesafe/jev-1.13` "TypeSafe: Jev 1.13", modality "text->decisions", 엔드포인트 `typesafe/jev-1.13-20260917`(provider TypeSafe). 전체 목록 `GET /api/v1/models`에는 이 모델이 없고 `typesafe/jev-router`만 나오지만 개별 조회는 살아 있습니다(목록이 텍스트 출력 모델만 싣는 것으로 보임, 추정).
  - Vercel AI Gateway `GET https://ai-gateway.vercel.sh/v1/models`: `typesafe-ai/jev`("Jev", owned_by typesafe-ai).
  - 가중치: Hugging Face `api/models?author=typesafe-ai`와 `author=typesafe`는 빈 목록. `author=TypeSafeAI`에는 `Step-5-Preview-BF16`, `Step-5-Preview-GGUF`(태그 stepfun, step-5)만 있고 Jev와 무관합니다(이 계정이 TypeSafe AI의 공식 계정인지는 확인하지 않음). GitHub `typesafe-ai` 조직 저장소 10개(`gh api orgs/typesafe-ai/repos`)에 가중치 저장소가 없습니다. 기존 노트 `jev-system-one-model.research.md` 180행(E-8)과 같은 결론입니다.
- 정합성: 본문 진술은 조회 범위 안에서 맞습니다. "공개 가중치는 없다"는 부재 확인이라 반증 하나로 뒤집힐 수 있는 진술임을 기록해 둡니다.

**VR-44. 각주 서지와 줄번호 전체: 확정**
- `[^system-one]`, `[^intro]`, `[^quickstart]`, `[^api]`, `[^primitives]`, `[^jagged]`, `[^models]`, `[^howto]`, `[^usecase]`, `[^coding-agents]`, `[^llms]`의 URL과 줄번호를 위 항목에서 하나씩 대조했고 전부 맞습니다. `[^patterns]`는 VR-39에서 고쳤고 `[^score]`는 VR-15에서 더했습니다. 방법 R 렌더에서 각주 17개가 모두 참조와 짝을 이룹니다.

### 확정: evals 사이트

**VR-21. 경비 정산 장난감 예제: 확정**
- 대상: 본문 174행, 270행. 각주 `[^evals]`.
- 서지: TypeSafe, workflow evals 사이트 홈, https://evals.typesafe.ai/ , "Decompose the work, build a harness" 절, 2026-09-29 조회.
- 원문: "A toy example. The policy on the left is the kind of paragraph a team writes down; the chart on the right is the same policy as a workflow. Each sentence became either a question for the model, with a type, or a rule for the code." / 정책 3 "A meal over $75 needs a manager's sign-off when the description on the claim does not clearly match the receipt." / SVG "THE MODEL ANSWERS" 아래 "the receipt can be read"(`data-q="readable"`, noul 반원 아이콘), "what kind of expense: a meal, travel, or equipment"(`kind`, choice 격자), "how clearly the claim's description matches the receipt, on four levels"(`match`, score 막대) / "THE CODE DECIDES" 아래 "a meal over $75 whose description does not clearly match" → `MANAGER REVIEW`.
- 확인 방법: 방법 E. 유형은 `<g class="fc-ic">` 안 마크업을 데이터 `icons`와 대조했습니다.
- 정합성: 유형 셋, 네 단계, $75가 코드 쪽이라는 서술 모두 일치. 174행 "금액 비교는 판단이 아니라 계산이기 때문입니다"와 270행 "이유가 이것입니다"는 evals 사이트가 적은 이유가 아니라 jaggedness 문서(20행, 82행 "Arithmetic is not, so keep it in code")에 기댄 필자 연결입니다. 벤더 원칙과 같은 방향이라 고치지 않았습니다.

**VR-23. 워크플로 단계 이름: 확정**
- 대상: 본문 180행.
- 원문(security_incidents.html): "1 Read the alert", "2 Close, queue, or act", "3 The state of the incident", "4 Choose the response". 단계 설명 넷도 N-7 기록과 같습니다.
- 확인 방법: 방법 E. 정합성: 일치.

**VR-24. 알림 읽기 질문 표와 `\-\-` 렌더: 확정**
- 대상: 본문 184~188행.
- 원문(cases.js `eval.questions[0]`~`[2]`, ID는 SVG `data-q`): `is_true_positive` noul "Given the alert and its context records, does this describe unauthorized activity, as opposed to authorized activity that a detector flagged?" / `context_explains_activity` noul "Do the context records -- tickets, registrations, schedules, authorization excerpts -- account for the flagged activity?" / `evidence_strength` score "How strong is the evidence that the activity is unauthorized?"
- 확인 방법: 방법 E, 방법 R.
- 정합성: 문자 단위 일치. 렌더 결과는 "Do the context records -- tickets, registrations, schedules, authorization excerpts -- account for the flagged activity?"로 하이픈 둘이 그대로 나오고 en dash(U+2013)와 em dash(U+2014)는 생기지 않습니다. 이스케이프는 원문과 같은 결과를 냅니다. 바깥 곧은 따옴표만 kramdown이 둥근 따옴표로 바꾸는데, 본문의 다른 인용과 같은 처리입니다.

**VR-25. `evidence_strength`의 네 단계: 확정**
- 대상: 본문 190행.
- 원문 criteria: "Speculative: hedged language, or a single weak indicator", "Suggestive: one concrete indicator, uncorroborated", "Corroborated: independent indicators agree", "Confirmed: direct proof of unauthorized activity".
- 확인 방법: 방법 E. 정합성: 일치.

**VR-26. 처리 방향 정하기(코드) 규칙: 확정**
- 대상: 본문 192~196행.
- 원문: evals 단계 설명 "The code combines the three answers with how important the machine is and where it runs. Borderline identity alerts also notify the user." / 흐름도 주석 "code reads the asset's environment and tier, and the detector's domain" / 판정 기록 `outputs.state`의 `environment`, `tier`, `domain`.
- 규칙 문자열(`rule` | `qid` | `test`): `disposition` | `is_true_positive` | "P < 0.15, with a record that explains it: close" / 같은 규칙의 변형 "P < 0.15, with a record that explains it (never on a domain controller): close"는 예시 5건 중 `art_T1574.001-2__peer_contained__t0`(자산 `DC-NW-01`)에서만 나옴 / `disposition` | `context_explains_activity` | "P > 0.50: a record explains the activity" / `disposition` | `is_true_positive` | "P > 0.75: act now" / `queue` | `is_true_positive` | "0.15 < P ≤ 0.60 on an identity alert: notify the user".
- 대기열 분기 대조(예시 5건의 middle 판정 10개): identity 알림이면서 P가 0.34, 0.4, 0.17, 0.2, 0.56이면 `NOTIFY USER`, identity 알림이라도 P가 0.72나 0.12면 `ESCALATE TIER2`, endpoint 알림은 전부 `ESCALATE TIER2`.
- 확인 방법: 방법 E.
- 정합성: 인용 축자 일치. "여기서 P는 `is_true_positive`의 값"은 `qid`로 확정. 196행 "신원 관련 알림이면 [구간을 담은 규칙 문자열], 아니면 ESCALATE TIER2"는 규칙 문자열에 구간이 들어 있어 정확합니다.

**VR-27. 사고 상태 읽기는 조치 판정에서만 나간다: 확정**
- 대상: 본문 198행.
- 원문: middle 판정 케이스의 `containment` 노드 `ran: false`, `reason` "the disposition was middle: only an act reaches containment"(예시 세 건의 세 모델과 LSASS 케이스의 TypeSafe에서 같음).
- 확인 방법: 방법 E. 정합성: 인용 축자 일치.

**VR-28. 두 번째 요청의 질문 11개: 확정**
- 대상: 본문 200행.
- 원문: `containment` 노드의 `questions` 11개(`eval.questions[3]`~`[13]`), noul 9개와 choice 2개(`affected_scope`, `attack_type`).
- 확인 방법: 방법 E.
- 정합성: 개수 일치. 우리말 풀이 아홉 개가 각 noul의 instructions와 순서대로 대응합니다(작성자 노트대로 요약).

**VR-29. 대응 고르기(코드)와 플레이북 그룹: 확정**
- 대상: 본문 202행.
- 원문: evals 단계 설명 "The playbook takes the first group whose conditions are met, then the strongest step in it that still applies. When no group applies, the alert is escalated."(축자 일치) / 흐름도 그룹 1 "data is leaving now", 2 "the attacker has access", 3 "malicious mail is delivered", 4 "the host is compromised", 5 "configuration was changed" / 그룹 4 칩 순서 ISOLATE HOST, KILL PROCESS, QUARANTINE FILE / 규칙 `the host is compromised` | `attacker_persistence_present` | "P > 0.60: enters group 4"(같은 그룹 진입 규칙으로 `malicious_process_running` "P > 0.60: enters group 4"도 있음).
- 확인 방법: 방법 E.
- 정합성: 일치. "강한 것부터 약한 것 순서"는 "the strongest step in it that still applies"와 칩 순서에 근거합니다.

**VR-30. 질문 14개와 동작 17개: 확정**
- 대상: 본문 206행.
- 원문: `eval.questions` 14개(noul 11, score 1, choice 2) / `class="fc-chip ..."` 17개(close 1 AUTO CLOSE, queue 2 NOTIFY USER와 ESCALATE TIER2, page 1 ESCALATE URGENT, light 6, heavy 7).
- 확인 방법: 방법 E.
- 정합성: 일치. "두 번의 요청에서 질문 14개"는 조치 판정 경로 기준입니다(닫기와 대기열 경로는 3개).

**VR-32. Amsi.dll 케이스의 신원: 확정**
- 대상: 본문 214행.
- 원문: `examples[3]` `case_id` "art_T1574.001-2__peer_contained__t0", `name` "Amsi.dll renamed as WinAppXRT", `label` "All three miss the reference" / `documents[3]` 알림 "EDR-5935 | DLL", asset `DC-NW-01`, `context.asset` environment "prod", tier 0, type "Server", 기록 `activedirectory.computer` "CN=DC-NW-01,OU=Domain Controllers,DC=northwind,DC=example", `crowdstrike.host` product_type_desc "Domain Controller", `servicenow.cmdb_ci` "Active Directory domain controller - authentication and Group Policy for all sites".
- 모델 표기: 데이터의 `typesafe` 항목은 `typesafe:v13_snowy_elephant`, 예시 목록 라벨은 "TypeSafe", 같은 페이지 차트의 해당 workflow 항목 라벨은 "Jev". 본문의 "Jev의 답"은 이 라벨에 근거하고, `jev-1.13.0`과의 대응은 주장하지 않습니다.
- 확인 방법: 방법 E. 정합성: "운영 환경의 도메인 컨트롤러(`DC-NW-01`, tier 0)" 정확.

**VR-33. 알림 읽기 값과 처리 방향: 확정**
- 대상: 본문 216행 앞부분.
- 원문(`typesafe` triage 노드): `is_true_positive` 0.82, `context_explains_activity` 0.06 / 테스트 "P > 0.75: act now" value 0.82 holds true, 닫기 테스트 holds false.
- 확인 방법: 방법 E. 정합성: 일치.

**VR-34. 사고 상태 읽기 값: 확정**
- 대상: 본문 216행 뒷부분.
- 원문(`typesafe` containment 노드): `outbound_channel_active` 0.16, `session_in_attacker_hands` 0.24, `credentials_exposed` 0.3, `malicious_content_in_mailboxes` 0.09, `attacker_persistence_present` 0.68, `malicious_process_running` 0.18, `activity_ongoing` 0.36.
- 확인 방법: 방법 E.
- 정합성: 본문 일곱 값 전부 일치. 본문이 뺀 넷(`attacker_modified_configuration` 0.66, `spread_beyond_initial_entity` 0.45, `affected_scope` organization_wide, `attack_type` host_compromise)은 이 케이스의 판정 기록에 테스트가 없어 "대응 고르기에서 쓰인 값만"이라는 본문 기준에 맞습니다.

**VR-35. 대응 고르기 경로와 최종 동작: 확정**
- 대상: 본문 218행.
- 원문(`typesafe` `decisions.playbook`): 그룹 1 0.16 vs "P > 0.45" false / 그룹 2 0.24 vs "P > 0.50" false, 0.3 vs "P > 0.40" false / 그룹 3 0.09 vs "P > 0.50" false / 그룹 4 0.68 vs "P > 0.60" true(진입) / isolate host 0.68 "P > 0.60" true, 0.36 "P > 0.50" false / kill process 0.18 "P > 0.60" false / quarantine file 0.68 "P > 0.60" true / `actions` [["QUARANTINE FILE", "light"]], `keys` trunk, gate1.act, containment, gate2, G4, G4.quarantine_file.
- 확인 방법: 방법 E.
- 정합성: 전부 일치. "호스트 격리는 `activity_ongoing`이 0.50을 넘어야 하는데"는 필요조건으로 정확합니다(충분조건이 아니라는 점은 VR-37).

**VR-36. 기준 답과 세 모델의 동작: 확정**
- 대상: 본문 220행.
- 원문: `references` "GPT-6 Astra, high thinking, one question per request"는 ISOLATE HOST / "Claude Fable 5.1 high, one question per request; Claude Opus 5 high on the 88 documents Fable refused or failed"는 REVOKE SESSIONS / "Consensus: mean of Astra and Fable probabilities for every question"는 ISOLATE HOST(heavy). 세 모델 `actions` 모두 QUARANTINE FILE(light), 라벨 "All three miss the reference". 블로그 "We use the average of GPT-6 Astra and Fable 5.1 as the reference answer".
- 확인 방법: 방법 E, 방법 B.
- 정합성: "두 대형 모델의 확률 평균으로 만든 합의", `ISOLATE HOST`, "세 모델이 모두 `QUARANTINE FILE`" 정확. Fable이 거부하거나 실패한 88개 문서를 Opus 5로 대신했다는 단서는 본문에 없지만 "두 대형 모델"이 틀린 진술은 아닙니다.

### R절 대조 (기존 노트에서 옮긴 항목이 이 글의 문장과 맞는가)

| R | 원번호 | 이 글에서 쓰인 곳 | 이번 대조 |
|---|---|---|---|
| R-1 | E-1, V-1 | 9행, `[^blog]` | VR-1, 일치 |
| R-2 | E-4, V-2 | 본문 미사용 | 대조 불필요 |
| R-3 | E-2, V-43, V-54 | 27행(Kahneman은 system-one 문서, Jevons는 블로그 FAQ) | VR-6, VR-7, 일치. V-54의 "error-prone" 단서는 본문 미사용 |
| R-4 | E-3, V-6~V-8 | 88행, 96~100행 | VR-11, VR-12, VR-13, 2026-09-29 원문과 일치 |
| R-5 | E-3, V-9 | 100행 | VR-14, 일치 |
| R-6 | E-3 | 41행 | VR-9, 일치 |
| R-7 | E-3, V-33 | 160행 | VR-9, 일치 |
| R-8 | E-4, V-14, V-15 | 본문 미사용 | 대조 불필요 |
| R-9 | E-4 | 258~262행 | VR-41, 일치 |
| R-10 | E-6, V-49, V-50 | 170행 | VR-20, 일치 |
| R-11 | E-6, V-40 | 270행 | VR-18, 43행 일치(82행은 본문 직접 인용 없음) |
| R-12 | E-6, V-35 | 279행 | VR-19, 일치 |
| R-13 | E-6 | 280행 | VR-18, 일치 |
| R-14 | E-8, V-3, V-37 | 15행, 281행, 289행 | VR-4, VR-19, VR-43, 2026-09-29 재조회로 일치 |
| R-15 | E-8 | 본문 미사용 | 대조 불필요 |
| R-16 | E-5 | 39~43행 | VR-8, 2026-09-29 원문과 일치 |
| R-17 | E-6, V-43 | 102행 | VR-6, 일치 |

### 그림 주석 데이터 (주석은 고치지 않음)

**F-1. 「같은 판단, 두 인터페이스」(본문 45행): 데이터 오류 없음, 주의 하나**
- introduction .md 9행과 11행(VR-5), mermaid 13~25행 문구: 16행 "state + questions", 22행 "one request", 19행 "evaluate each question<br/>against the state<br/>in parallel", 23행 "one response"와 "typed answers<br/>+ probabilities<br/>+ confidence<br/>(Choice and Score)", 24행 "<b>your code</b><br/>branch, sort, and route". 주석 문구는 `<br/>`를 공백으로 편 것이라 같습니다.
- 비교표 [설계] 행: Inputs 두 셀, Outputs(Jev) "Possible outputs and structure are defined in advance.", Sampling의 병렬 평가(설계 근거는 introduction .md 37행). VR-8과 일치.
- 주의: LLM 경로의 "파싱과 검증"은 비교표 Outputs(LLM) "To be used by software, responses need to be parsed + validated."와 introduction .md 9행에 근거가 있습니다. 그러나 "(실패하면 재호출)"은 벤더 문장이 아니라 본문 35행의 필자 서술입니다. 그림이나 캡션에서 벤더 출처로 표시하지 마세요.

**F-2. 「한 요청, 세 질문, 세 답」(본문 92행): 데이터 오류 없음**
- 주석의 state, 질문 셋(department instructions 물음표 없음), 응답 값 전부(model `jev-1.13.0`, choice technical, confidence 0.78, probabilities technical 0.85, sales 0.0, billing 0.15, score 1.0, confidence 1.0, probabilities 0: 0.0, 1: 1.0, 2: 0.0, noul 1.0, usage 392와 65)가 quickstart .md 65~136행과 문자 단위로 일치합니다(VR-11).
- 심화편 도입 그림이 API 문서 payouts 예시(Choice 하나)라는 주석 서술은 `_posts/2026-09-29-jev-system-one-model.md`의 첫 `<figure class="jev-embed">`(59행 부근 "payouts have been failing for 3 days.")와 기존 노트 V-57로 확인했습니다. 심화편에는 quickstart나 Stripe 예시가 없어 겹치지 않습니다.

**F-3. 「답의 모양에서 코드의 모양으로」(본문 152행): 데이터 오류 없음**
- primitives .md 표 242~244행(주석의 "240~244행"은 머리행 포함 범위): Choice "Which of these options?", Score "Which level?", Noul "Is this true?" 일치 / 283~287행 선택 기준, 295행 인용, 303~305행 답 읽는 법 일치 / api .md 223행 일치(VR-12, VR-13).
- 참고: Score의 반환값은 원문상 `score`, `legend`, `probabilities`, `confidence`입니다(243행). 주석은 가운데 칸에 "score와 legend"만 적었는데, 틀린 것이 아니라 일부를 고른 것입니다. `probabilities`를 빼면 Choice 칸과 모양이 달라지니 그릴 때 판단하세요.

**F-4. 「보안 알림 처리 워크플로」(본문 204행): 데이터 오류 없음, 주의 하나**
- 단계 이름 넷(VR-23), 질문 유형별 개수 Noul 11, Score 1, Choice 2(VR-30), 동작 17개와 등급 Close 1, Queue 2, Page 1, Light 6, Heavy 7(VR-30), evals 범례 "Noul Score Choice"(블로그 이미지만 "Bool"), 사고 상태 읽기로는 조치 가지에서만 간다(VR-27) 모두 일치.
- 숫자와 대상 질문: `P > 0.75`와 `P < 0.15`는 `is_true_positive`의 값에 대한 조건입니다. 회색 지대 0.15~0.60도 `is_true_positive`의 값에 대한 구간이며 identity 알림에만 적용됩니다(`qid`와 테스트 문자열 "0.15 < P ≤ 0.60 on an identity alert"). 0.50은 `context_explains_activity`에 대한 조건입니다. 그룹 진입 문턱은 그룹 1 `outbound_channel_active` 0.45, 그룹 2 `session_in_attacker_hands` 0.50과 `credentials_exposed` 0.40, 그룹 3 `malicious_content_in_mailboxes` 0.50, 그룹 4 `attacker_persistence_present` 0.60과 `malicious_process_running` 0.60입니다. 주석 값 전부 일치(VR-26, VR-29).
- 기록에 없는 규칙: 예시 5건, 세 모델의 판정 기록 전체에서 규칙 문자열은 21종입니다(처리 방향 5, 그룹 진입 6, 그룹 2 안 6, 그룹 4 안 4). 주석이 "숫자나 질문 ID를 붙이지 않는다"고 한 항목(그룹 1과 3 안의 동작 조건, 그룹 5 진입 조건, `evidence_strength`, `affected_scope`, `attack_type`, 자산 `environment`와 `tier`의 쓰임)은 21종 어디에도 없습니다. 주석이 허용한 숫자에 기록에 없는 값은 섞이지 않았습니다.
- 주의(주석에서 빠진 것, 주석은 고치지 않음): 그룹 4의 ISOLATE HOST에는 기록된 두 조건(`attacker_persistence_present` > 0.60, `activity_ongoing` > 0.50) 말고 기록되지 않은 조건이 더 있습니다(VR-37, Opus 기록). 주석은 그룹 안 동작 조건을 그리라고 하지 않으므로 지금은 문제가 없습니다. 다만 그룹 2나 4의 안쪽 조건을 그림에 넣게 되면 ISOLATE HOST의 두 조건을 전체 조건처럼 그리지 말고, "never a lone production system"에도 숫자나 질문 ID를 붙이지 마세요.

### 심화편 경계

**VR-45. 심화편 주제 유입 여부: 없음**
- 확인 방법: 초안 전문에서 "보정", "calibrat", "송금", "transfer", "priorbench", "주사위", "HN", "환각", "hallucinat", "0.99", "82.9"를 검색했고 해당하는 본문 문장이 없습니다. "문턱"은 102행, 150행, 287행에 나오지만 문턱을 정하는 방법은 다루지 않고 심화편으로 넘깁니다.
- 기준 답이 모델 합의라는 사실은 220행 한 문장으로만 나옵니다(노트 "작성 시 지켜야 할 것"의 권고 범위, 평가의 타당성 논의 없음). 심화편 발행본에는 evals 사이트, Security Incidents, quickstart가 나오지 않아 예제도 겹치지 않습니다.

### 완료 조건 점검

- 본문의 외부 인용과 수치를 줄 단위로 훑어 모두 위 항목에 대응시켰습니다. 벤더 블로그는 VR-1~4, 7, 8, 17, 22, 31, 36, 40. 벤더 문서는 VR-5, 6, 9~16, 18~20, 38, 39, 41, 42, 44. evals 데이터는 VR-21, 23~30, 32~37. 버전과 공개 범위는 VR-4, 19, 43. 검증 기록에 없는 외부 인용은 없습니다.
- 초안에 남긴 `<!-- 검증: -->` 주석 세 개는 VR-5, VR-16, VR-37로 이어지며, 발행 시 제거되므로 근거 사슬로 치지 않습니다.

---

## 응집 점검 기록

점검일 2026-09-29, blog-editor. 대상 `_drafts/jev-system-one-intro.md`. 아래 "L" 줄번호는 윤문 후 초안 기준입니다(317행, 편집자 노트 1줄 포함). L222 문단을 둘로 나눠 그 아래 줄번호는 윤문 전보다 2씩 밀렸습니다.

### 스크립트 출력 (`scripts/cohesion_check.py`)

- 예고 사슬: 작성자 노트 이름 셋이 모두 `##` 소제목에 있음. "이름에 없는 소제목" 12개는 `###` 하위 절과 맺음 절 "정리하며"라 작성자 노트가 밝힌 의도와 같음.
- 세 항목 이상 나열 5곳: L39, L96, L142, L194, L280. 모두 "직전에 문단 있음".
- 긴 문단 플래그 8개(윤문 전): L15, L35, L166, L202, L218, L222, L228(현 L230), L285(현 L287).
- 개수와 번호 라벨: L35 1건. 본문이 아니라 `<!-- 검증: -->` 주석 안의 "넷째, 다섯째"에 걸린 것.
- 윤문 후 재실행: 예고 사슬 동일, 플래그 8개. L222는 실제 문장 5개에 검증 주석이 두 문장으로 세어진 것이고, 나머지는 아래 "손대지 않기로 한 곳"의 판단대로.

### 예고 사슬

- 이름 {문장 대신 판단을 돌려받는 모델 | 질문을 설계하는 건 호출하는 쪽 | 맞는 자리와 맞지 않는 자리} → 도입부 L17(굵게, 같은 순서), `##` 소제목 셋, 본문 되부르기(L112, L228), 맺음 L287까지 전부 일치. 표기는 바꾸지 않았습니다.
- 이름 사이를 잇는 말 "두 성질"(도입 L17, 맺음 L287)이 셋째 절 우산(L230)에서 설명 없이 "두 조건"으로 바뀌어 있었습니다. 셋째 절 나머지는 "조건"으로 일관하므로, 우산 문장을 "이 두 성질을 조건으로 놓고 보면"으로 고쳐 전환을 드러냈습니다. 두 단어 모두 그대로 둡니다.

### 손본 곳

배열:
- L222 Amsi.dll 문단(윤문 전 8문장 플래그, 실제 7문장): 사용자 결정 단서 세 문장이 논지와 교훈 사이에 끼어 문단이 방향을 두 번 틀었습니다. 단서까지(5문장, 검증 주석 포함)와 교훈 두 문장(L224)을 두 문단으로 나눴습니다. 단서 문장은 뜻을 그대로 두고 지시어만 분명히 했습니다. "이 숫자만" → "이 0.36만"(직전 문장의 "이 두 숫자"와 겹침), "Opus는" → "함께 비교된 Opus는"(L220 "비교된 세 모델"과 연결, 본문에 Opus가 처음 나오는 자리), "흐름도의" → "평가 사이트 흐름도의"(본문에 흐름도가 처음 나오고, 삽입될 그림과 헷갈릴 수 있음), "한 번 더 거르는" → "호스트 격리를 한 번 더 거르는"(목적어 보충, VR-37의 원 표현과 같음).
- L164 스팸 예시: 입력 메시지 설명이 여섯 질문 뒤에 매달려 있었습니다. 메시지를 앞으로 옮겨 메시지 → 나쁜 예 → 좋은 예 → 여섯 질문 → (L166) "쪼개고 나면"으로 연쇄를 이었습니다. 여섯 질문 문장은 명사 나열로 끝나던 것에 서술어를 붙였습니다.
- L230 셋째 절 우산: 위 예고 사슬 항목의 성질 → 조건 전환.
- L258 맞지 않는 자리 우산: "앞의 두 조건을 뒤집어 보면 대부분 설명됩니다"를 뒤따르는 굵은 머리 문단 세 개의 이름(답의 공간이 열린 일, 판단이 아닌 일, 1초를 넘는 판단)으로 펼쳤습니다. 세 이름은 모두 절 안에 이미 있는 말이라 새 사실이 없습니다.

번호 라벨을 이름으로:
- L270 "첫 번째 조건 안으로" → "닫힌 답의 공간 안으로".
- L192 "두 번째 단계에는" → "이 단계에는"(굵은 머리가 이미 단계 이름을 부름). "두 번째 요청"은 실제 API 요청 순서라 라벨이 아니므로 둠.

같은 대상, 다른 이름(키워드 고정):
- 벤더 블로그 비교표: "벤더 비교표"(L39, L43), "벤더 블로그의 비교표"(L100), "발표 글 비교표"(L254) → 본문 다수 표기인 "발표 글의 비교표"로 통일. 블로그 글 자체는 L27부터 "발표 글"로 불립니다.
- use case map 문서: "개발 문서의 결정 모양 표"(L238)와 "사용 사례 문서"(L250)가 같은 문서 → 각주 `[^usecase]`가 걸린 첫 등장도 "사용 사례 문서"로.
- "gut-check determination" 출처: "벤더 문서의 다른 표현" → "소개 문서의 표현"(각주 `[^intro]` 41행과 같은 문서, 본문의 소개 문서 명칭과 통일).
- 자기 인용 두 곳: L198 `"두 요청은 예외"의 예외`, L210 `"질문 쓰기가 곧 도메인 맞춤"` → L110, L136의 표현을 따옴표 없이 되불렀습니다. 앞 문장에 없는 문구를 따옴표로 묶어 원문 인용처럼 보이던 것을 없앤 것입니다.

문장 표현(내용 불변):
- L23 "Jev를 부르는 이름은 둘" → "Jev를 소개하는 자료에는 이름이 둘 나옵니다"(System One은 Jev의 이름이 아니라 부류 이름).
- L130 "모델이 고르지 못한 지점" → "모델의 들쭉날쭉한 지점"(Choice의 "고르다"와 겹쳐 '선택하지 못한'으로 읽힘).
- L100, L170: 영어 인용 두 개가 한 문장에 몰린 곳을 두 문장으로 나눔. L170 "바로 아래에" → "바로 아래 첫 항목은"(이 노트 검증 기록의 "243행(바로 아래 첫 항목)").
- L112 "~는 것, 그것이" 번역투 정리. L128 "뿐이고 ... 뿐입니다" 반복을 두 문장으로 나눔. L276 "여기서 헷갈리기 쉬운 점이 하나 있습니다"는 L266 "여기서 입문자가 오해하기 쉬운 단어가 하나 있습니다"와 같은 틀이 두 문단 간격으로 반복돼 걷어내고 본론으로 시작.
- L206 "이 워크플로 그림 아래에" → "이 워크플로를 그림으로 소개한 뒤"(바로 위에 들어갈 본문 그림을 가리키는 것으로 읽힐 수 있음).
- L174 `"$75를 넘는 식비"`의 따옴표 제거. 초안 작성자 노트("원문 인용으로 읽히지 않도록 따옴표를 붙이지 않았다")의 의도와 맞춘 것.
- L110 "예제가 이 예외가" 주격 겹침 정리. L289 "알려주는지", "이어 받습니다" 띄어쓰기.
- 해요체: 기존 3문장(L100, L166, L248)에 3문장을 더했습니다(L128, L198, L264). 해요체가 한 문장도 없던 구간(둘째 절 앞부분, 보안 예제, 맞지 않는 자리)에 하나씩입니다. 정의와 결론 문장, 사용자 결정 단서 문단은 습니다체를 유지했습니다.

### 손대지 않기로 한 곳

- L15 도입 성격 밝히기(6문장): 호출하지 않음 → 이유(얼리 액세스) → 읽은 기록 → 예시 값 → 벤더 수치의 연쇄입니다. 고지 문단이라 나누면 고지가 흩어집니다.
- L35 설계 동기(플래그 7문장, 실제 5문장): 영어 인용 한 문장과 검증 주석이 문장 수를 부풀렸습니다. 라벨 플래그도 검증 주석 안이라 본문과 무관합니다(발행 시 주석 제거).
- L166 분해의 이점(7문장): "쪼개고 나면"에서 출발해 "쪼갠다고 호출이 늘지도 않습니다"로 같은 대상에 정박한 채 닫힙니다. 마지막 괄호 인용은 앞 문장의 근거입니다.
- L202 대응 고르기(6문장): 영어 인용 한 문장이 둘로 세어졌습니다. 그룹 순서 → 그룹 안 순서 → 예의 연쇄입니다.
- L218 케이스 경로(6문장): 그룹을 앞에서부터 확인하는 과정 자체가 연쇄라 나누면 경로가 끊깁니다.
- L287 맺음 첫 문단(6문장): 세 이름을 도입부 순서대로 되부르는 문단이라 나누면 예고 사슬의 닫힘이 흩어집니다.
- 나열 5곳(L39, L96, L142, L194, L280): 우산이 모두 직전 문단에 있습니다. L37 입력, 출력, 평가 방식 / L94 유형마다 읽는 법 / L140 답의 모양에 따른 기준 / L192 규칙 문자열 / L278 두 조건과 무관한 제품 조건.
- L142 Choice 항목의 한국어 풀이와 영어 인용이 겹치는 부분("후보 목록이 모든 입력을 덮지 못할 수 있으면"과 "when the list might not cover every input"): 입문 독자에게 인용의 뜻을 먼저 주는 역할이라 둡니다.
- L200 질문 11개 나열 한 문장: 첫 문장 "질문 11개가 들어갑니다"가 우산이라 둡니다.
- 그림 주석 네 곳의 앞뒤: 앞 문단이 그림 내용을 글로 먼저 전하고(L43 설계 사실, L90 예시 응답 값, L150 유형에서 코드 모양으로, L202 대응 고르기), 뒤 문단이 그림에 기대지 않습니다. L206의 "그림" 표현만 위처럼 고쳤습니다.
- 비평조 유입: L43 "역시 주장입니다", L100 "이 글은 문서를 따릅니다", L220 "함께 적어야 공정합니다"는 주장 표기와 출처 선택을 밝히는 문장이라 둡니다. 논쟁조 문장은 없습니다.
- 문장 앞자리에 새 정보가 먼저 나오는 곳: 걸리는 곳이 없었습니다.

### 사람 결정 대기

- 편집자 노트 1건(초안 맨 끝): L198 "두 번째 요청에 무엇을 담을지가 첫 답에 달려 있으니". 원문 기록("only an act reaches containment")으로 보면 담을 내용보다 보낼지 말지가 첫 답에 달린 것에 가깝습니다. 사실 판단이 걸린 표현이라 editor가 고치지 않았습니다.
- 우산 문장 필요: 없음. 예고 이름 불일치: 없음.

- **사람 결정 대기 해소(2026-09-29, 오케스트레이터):** 198행 "두 번째 요청에 무엇을 담을지가 첫 답에 달려 있으니, 코드가 첫 답을 본 뒤에야 보낼 수 있어요." → "두 번째 요청을 보낼지 말지가 첫 답에 달려 있으니, 코드가 첫 답을 본 뒤에야 정할 수 있어요." 근거: 판정 기록의 건너뜀 사유 "the disposition was middle: only an act reaches containment"(N-7), 두 번째 요청의 질문은 케이스와 무관하게 같은 11개(N-7 질문 표). 담을 내용이 아니라 보낼지 여부가 첫 답에 달렸다.

## 그림 구현 대조 (2026-09-29, 오케스트레이터)

그림 자리 주석 네 개(F-1~F-4, 검증 결과 오류 없음)를 인라인 HTML과 CSS 그림으로 바꿨습니다. 그림에 들어간 값과 문구를 검증 기록과 다시 대조했습니다.
- **F-1 두 인터페이스:** LLM 경로의 "파싱과 검증" 칸은 비교표 Outputs 셀의 "To be used by software, responses need to be parsed + validated."를 풀어 쓴 것이고, "실패하면 재호출"은 넣지 않았습니다(F-1 주의사항). 입력(sequential messages 대 structured program state)과 샘플링(토큰을 하나씩 대 요청 하나 안에서 병렬 평가)은 비교표 [설계] 셀과 introduction 도식에서 옮겼습니다. 속도, 비용 수치는 없습니다.
- **F-2 한 요청, 세 질문, 세 답:** state, instructions(물음표 없는 원문), criteria, 응답 값(`jev-1.13.0`, technical 0.85, billing 0.15, sales 0.0, confidence 0.78, score 1.0, probabilities 0: 0.0, 1: 1.0, 2: 0.0, confidence 1.0, noul 1.0)을 원문 그대로 옮겼습니다. usage는 싣지 않았습니다. 캡션에 "quickstart 문서의 예시, 필자 호출 결과 아님"과 "질문 키는 모델에 전달되지 않음"(api .md 36행)을 밝혔습니다.
- **F-3 유형 선택:** 칸마다 primitives 240~244행의 질문 형태, 283~287행의 "이럴 때"(요약), 돌려받는 값, 295행의 코드 모양(코드 경로 셋, 문턱 하나, if 하나)을 옮겼습니다. Score 칸에는 `probabilities`도 넣었습니다(F-3 참고사항). 문턱 값은 싣지 않았습니다.
- **F-4 보안 워크플로:** 단계 이름은 본문 표기(알림 읽기, 처리 방향 정하기, 사고 상태 읽기, 대응 고르기)에 맞췄습니다. 입력 여섯 가지는 evals 페이지 Input 절에서 옮겼습니다. 처리 방향의 문턱(0.15, 0.75, 0.15~0.60, 0.50)과 그룹 진입 문턱(0.45, 0.50과 0.40, 0.50, 0.60과 0.60)은 판정 기록 규칙 문자열과 같습니다. 그룹 안쪽 동작 조건은 그리지 않았습니다(VR-37 주의사항: ISOLATE HOST의 기록된 두 조건을 전체 조건처럼 그리지 않음). 그룹 5 진입 조건, 그룹 1과 3 안의 동작 선택, 자산 등급의 쓰임은 비워 두고 캡션에 밝혔습니다.
  - 그룹 진입 조건 두 개를 "또는"으로 그렸습니다. 그룹 4는 Amsi.dll 케이스에서 `attacker_persistence_present` 0.68만 넘고 `malicious_process_running` 0.18은 못 넘었는데도 진입했으므로(VR-37 사실 항목) 판정 기록으로 확인됩니다. 그룹 2는 같은 규칙 형식("P > …: enters group 2" 두 줄)이라 같은 뜻으로 읽었습니다. 공개 예시에서 그룹 2가 한쪽만 넘은 경우는 확인하지 않았습니다.
  - 닫기 조건은 규칙 문자열 두 줄("P < 0.15, with a record that explains it (never on a domain controller): close", "P > 0.50: a record explains the activity")을 한 칸에 합쳐 그렸습니다. 두 테스트의 조합은 N-7이 적은 대로 원문 문구에 기댄 읽기입니다.
  - 질문 문구는 필자가 한국어로 줄인 것이고 캡션에 밝혔습니다. 동작 17개의 등급 색은 evals 페이지의 `fc-chip` 클래스와 같습니다.
- 대비: 라이트와 다크의 모든 텍스트 조합이 WCAG AA(최저 4.61:1)입니다. 1280px와 390px에서 가로 넘침이 없습니다(headless Chrome 캡처로 확인).
