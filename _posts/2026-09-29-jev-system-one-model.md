---
layout: post
date: 2026-09-29
title: "확률을 돌려받는 순간, 틀렸다는 걸 알아낼 책임도 넘어왔다"
subtitle: "문장 대신 판단을 돌려주는 모델, Jev의 공개 자료 읽기"
tags: [AI, Jev, 검증, 아키텍처]
---

2026-09-15에 TypeSafe AI가 공개한 Jev는 문장을 만들지 않습니다. Jev는 프로그램의 상태(`state`)와 호출하는 쪽이 이름을 붙인 질문들(`questions`)을 받아, 질문마다 구조화된 판단 하나와 확률을 돌려줍니다. 벤더인 TypeSafe AI는 회사 블로그에서 이 모델을 한 줄로 이렇게 소개합니다.[^blog]

> "Think of Jev as a frontier-intelligence function call: unstructured state in, typed probabilistic decisions out."

먼저 이 글의 성격을 밝혀 둡니다. **저는 Jev를 직접 호출해 보지 않았습니다.** 발표문 기준으로 공식 경로는 대기자 명단을 거치는 얼리 액세스입니다. 이 글은 발표 13일 뒤인 2026-09-28에 회사 블로그와 API 문서, 그리고 제3자가 공개한 측정 저장소 몇 개를 읽은 기록입니다. 그래서 본문의 수치에는 누가, 어떤 조건에서 낸 주장이나 측정인지를 전부 붙여 둡니다.

> 이 글은 속도와 가격을 다루지 않습니다. 응답 속도 하나만 해도 출처마다 수치가 다릅니다. 회사 블로그의 비교표는 "End-to-end response time is 70ms-500ms for TypeSafe", 보도자료는 "less than 100 milliseconds of latency",[^pr] 개발 문서는 "Most queries complete in about 100 ms."라고 적었습니다.[^howto] 제3자 측정인 priorbench는 OpenRouter를 거쳐 서유럽에서 잰 값으로 "~430 ms floor"를 보고했습니다.[^priorbench] 벤더 스스로도 자기 측정이 "generally run from our laptops on the West Coast"라고 조건을 밝혀 두었어요. 호출 경로와 위치가 다른 수치는 한 줄에 세울 수 없습니다. 이 글이 보려는 것은 속도가 아니라, 돌려받은 값을 코드가 어떻게 다뤄야 하는가입니다.

문장 대신 판단과 확률을 돌려받는다는 건, 호출하는 쪽 코드에 `if confidence > x` 모양의 줄이 생긴다는 뜻입니다. 그 한 줄이 이 글의 관심사입니다. 지난 글 [「AGI가 아니라, 되돌릴 수 있는가로 선이 그어져 있었다」](/blog/2026/09/08/agi-word-to-gate.html)(이하 AGI 편)는 "이 산출물이 틀렸다는 걸 무엇이 알려주는가"라는 질문을 남겼습니다. Jev 같은 모델에서 그 질문은 추상적인 물음으로 머물지 않고 조건식의 형태로 코드 안에 들어옵니다. 확률값이 분기 조건에 직접 박히면, 그 조건식은 호출하는 쪽에 무엇을 요구할까요.

벤더가 "환각이 없다"고 말하는 근거를 따라가면 먼저 **틀려도 타입은 맞는 답**이 나옵니다. 그런 답이 틀렸는지를 무엇으로 알아내느냐고 물으면, 판정의 책임이 확률값과 함께 건너와 있다는 것, 곧 **호출하는 쪽으로 넘어온 확률**이 보입니다. 그 확률로 사람이 멈춰 설 자리를 정하려는 순간, 벤더의 문서 두 개가 같은 송금 동작을 두고 다른 결론을 냅니다. 그 불일치를 풀어 보면 **확신도와 되돌릴 수 있음**이 서로 다른 축에 있다는 것이 드러납니다.

## 틀려도 타입은 맞는 답

"타입이 맞는다"는 말의 뜻부터 보겠습니다. Jev의 질문 유형은 셋이고, 셋 모두 답이 될 수 있는 후보를 호출하는 쪽이 미리 정의한다는 점이 같습니다.[^api]

| 유형 | 묻는 것 | 호출하는 쪽이 미리 정하는 것 | 돌려받는 것 |
|---|---|---|---|
| Choice | 목록에서 하나 고르기 | 선택지 맵(`criteria`), 최대 255개 | `choice`, `probabilities`(합 1), `confidence` |
| Score | 순서 있는 척도로 평가 | 단계 설명 배열(`criteria`), 2~10개 | `score`, `legend`, `probabilities`, `confidence` |
| Noul | 참/거짓 판정 | `instructions`, 선택적으로 `criteria.true/false` | `noul`(0~1, 참일 확률). `confidence` 없음 |

API 문서의 응답 예시에는 `"probabilities": { "billing": 0.88, "technical": 0.12, "sales": 0.0 }`와 `"confidence": 0.81`이 나옵니다. `billing`, `technical`, `sales`라는 이름은 모델이 지은 것이 아니라 호출하는 쪽이 선택지로 적어 보낸 것입니다. 모델이 고를 수 있는 세계는 호출하는 쪽이 적어 보낸 선택지 목록의 크기만큼이에요. 그 목록 위의 분포에서 계산한 값이 `confidence`(이하 확신도)입니다. 문서 원문은 이렇습니다.[^confidence]

> "`confidence` is a statistic computed from the probability distribution the answer already gives you."

그러니 타입 보장이란 "답이 호출하는 쪽이 적은 목록 안에 있다"는 보장이고, 확신도도 그 목록 안에서만 계산됩니다. 이 절의 나머지는 전부 이 한 문장에서 나옵니다.

### 환각 0%가 가리키는 것

벤더가 "환각이 없다"고 말할 때의 근거가 바로 이 보장입니다. 회사 블로그는 Jev가 "can’t hallucinate"라고 적고, 환각 비교 차트에 찍은 0%를 이렇게 설명합니다.

> "Our number is not empirical. Schema matching is guaranteed, thus we can confidently add 0% into the plots."

0%는 측정값이 아니라 스키마 일치에서 연역한 값이라는 걸 벤더가 스스로 밝힌 셈입니다. 같은 글은 이어서 "Hallucination and type-safety are intrinsically related, and we think the latter is table stakes for automation."이라고 적습니다. 스키마 일치 자체도 벤더의 주장이지만, 이번에 읽은 자료 안에서 반례가 보고된 것은 없었습니다.

발표 당일 올라온 Hacker News 스레드의 핵심 반론도 이 지점을 겨눴습니다.[^hn]

> "Sure, it can't emit an invalid type, but it can still emit a completely wrong valid value."

다른 댓글이 "Type safety is not factual correctness."라고 적자, 회사 측으로 보이는 계정은 이렇게 답했습니다.

> "I very much agree with this and want to hone in on where do actually disagree. Would you say a linear classifier hallucinates?"

반론과 벤더가 사실에서는 갈리지 않는다는 점이 눈에 띕니다. 타입 안전이 사실의 정확성을 보장하지 않는다는 데에는 양쪽이 동의하고, 갈리는 것은 그걸 "환각"이라고 부를지 여부뿐입니다. 이 블로그도 [하네스 책 리뷰](/blog/2026/07/29/harness-engineering-book-overview.html)에서 같은 구분을 한 번 기록했습니다. 책에 실린 런타임 버그 일곱 종에 붙은 문장이 "이 버그들 중 어느 하나도 TypeScript 컴파일러가 잡지 못했습니다."였죠. 그렇다면 호출하는 쪽에 중요한 건 이름이 아니라, 틀린 답이 코드에 들어오는 모양입니다.

### 사라진 것은 시끄러운 실패였다

그 모양을 가장 잘 보여 주는 자료는 뜻밖에도 벤더 자신의 저장소에 있습니다. TypeSafe 공식 조직의 `system-one-adapter-python`은 Jev와 같은 인터페이스를 LLM API로 구현한 어댑터이고, README는 자기를 이렇게 소개합니다.[^adapter]

> "A drop-in replacement for `typesafe_sdk`'s `system_one` evaluation API, backed by LLM APIs instead of TypeSafe."

벤더는 블로그의 비교 평가에서도 LLM들을 이 래퍼에 태웠다고 적었습니다("The LLMs use our System One LLM wrapper, which constrains LLMs to output structured decisions compatible with our API."). 질문 유형과 확률 분포라는 계약이 모델과 분리된다는 뜻입니다. 분리해 놓고 보면, LLM 쪽 경로에서 그 계약을 지키는 비용이 어댑터의 응답 필드와 옵션 이름으로 드러납니다. `n_retries_malformed_structure`라는 재시도 카운터가 있고, `normalize_probabilities` 옵션의 설명은 "Rescale invalid LLM probability distributions to sum to 1"입니다. 형식을 어기면 다시 부르고, 확률 합이 1이 아니면 다시 맞춘다는 것이죠.

그런데 이 비용에는 다른 얼굴이 있습니다. 형식이 깨진 응답은 적어도 실패라는 것이 보입니다. 파싱이 실패하고, 재시도 카운터가 올라갑니다. Jev에서 사라지는 것이 바로 이 종류의 실패입니다.

남는 것은 형식은 맞고 내용이 틀린 답, 곧 선택지 목록 안의 그럴듯한 오답입니다. 이 오답은 LLM 경로에서도 원래 조용했던 실패입니다. **달라진 것은 조용한 실패만 남는다는 점입니다.** 시끄러운 실패가 빠진 자리에서, 오답은 예외를 던지지 않고 정상 분기를 탑니다.

제3자 평가 저장소 priorbench가 이 모양을 수치로 보여 줍니다. 조건부터 적으면, 익명 저자가 OpenRouter를 거쳐 모델 `typesafe/jev-1.13-20260917`을 2026-09-20에 서유럽에서 호출한 측정입니다. 저자 스스로 한계를 "**One location, one day, one model version.**"이라고 적어 둔 단일 출처이기도 합니다. 그 README의 한 줄입니다.

> "A cake recipe is classified as a technical issue at **0.94 confidence**; random letters at **0.97**."

케이크 레시피는 기술 문의가 아닙니다. 그런데 답은 선택지 목록 안에 있고, 확신도는 0.94입니다. 타입 검사로는 걸릴 곳이 없어요. 저는 이걸 AGI 편이 이 블로그 저장소의 틀린 기록들에서 본 모양, "구체적인 수치를 달고 틀렸습니다"와 같은 형태로 읽습니다. 읽어서는 걸리지 않는 오답이, 이번에는 확률까지 달고 옵니다.

### "모르겠다"를 담을 자리

케이크 레시피가 기술 문의가 되는 이유는 벤더 문서가 먼저 설명해 둡니다. 버전별로 모델의 능력이 고르지 않은 지점을 정리한 jaggedness 문서는 Choice와 Noul의 차이를 이렇게 적습니다.[^jagged]

> "the Choice is relative, settling *which* option, while each Noul is absolute and can be low for all of them."

Choice는 "이 중 무엇인가"를 정하는 상대 판단이라, 어떤 입력이 와도 목록 중 하나를 고릅니다. priorbench의 측정도 같은 방향입니다. 선택지에 "해당 없음"이 없을 때 범위 밖 메시지 30건 중 걸러진 것은 0건이었습니다("Without an explicit "none of these" option, **0 of 30** out-of-scope messages were flagged"). HN의 한 댓글은 참/거짓 모드를 두고 같은 지적을 한 문장으로 적었습니다. "It can't abstain."

기권할 자리가 없을 때 확률이 어떻게 보이는지는 또 다른 제3자 실험이 보여 줍니다.[^dice] 공정한 6면 주사위의 결과를 Choice로 묻자, 선택된 선택지에 보고된 확률의 평균이 82.9%였습니다. 기대 확률은 16.7%이고 실제 정답률은 19.0%(400회 중 76회)로 우연 수준이었어요. 같은 주사위를 Noul로 물었을 때 보고된 평균 확률은 19.2%였습니다. 저자의 해석은 이렇습니다.

> "The issue is not that Jev failed to predict a random event; the observed accuracy stayed close to chance, as expected. The notable result is that the reported probabilities did not reflect that known uncertainty."

조건도 함께 적어야 공정합니다. 저자는 "These results are specific to the prompts and conditions in this repository."라고 일반화를 스스로 막았습니다. 호출은 Vercel AI Gateway를 거쳤고, 모델 리비전은 응답에 기록되지 않았으며, 당시 공개된 버전은 `jev-1.13.0` 하나였다고 저자가 적었습니다. 그리고 82.9%는 확신도 필드가 아니라 **선택된 선택지에 보고된 확률의 평균**입니다. 둘을 섞으면 안 됩니다.

두 결과를 겹쳐 읽으면 제가 얻은 요지는 이렇습니다. 확신도는 호출하는 쪽이 적은 선택지들 사이의 분포에서 나오는 값이라, "이 질문이 애초에 이 입력에 맞는가"는 말하지 못합니다. "모르겠다"는 낮은 확신도로 오지 않고, 답의 공간에 그 자리가 있을 때만 옵니다. 벤더 문서도 날짜 추출 예시에서 같은 처방을 합니다.

> "it gives you somewhere to put an explicit "not stated" option so a missing part is reported rather than guessed."

[레이트리미터 글](/blog/2026/08/09/rate-limiter-payment-platform.html)에서 저는 "라이브러리 기본값이 곧 정책"이라고 적었습니다. 여기로 옮기면 **선택지 목록이 곧 정책**입니다. 목록에 "해당 없음"을 넣을지는 모델이 아니라 목록을 쓰는 사람이 정하고, 넣지 않으면 모델은 반드시 무언가를 고릅니다. 틀려도 타입은 맞는 답은 모델의 성질이기도 하지만, 목록을 쓴 사람의 결정이 만든 모양이기도 합니다.

## 호출하는 쪽으로 넘어온 확률

그렇다면 목록 안의 오답은 무엇으로 걸러야 할까요. 벤더의 답은 보정(calibration)입니다. 회사 블로그의 비교표는 Jev의 확신도를 "Always communicates confidence and uncertainty with every output. Calibrated: higher confidence means higher accuracy."라고 설명합니다. 그런데 개념 문서는 같은 단어에 범위를 긋습니다.[^system-one]

> "Calibration is measured across groups of predictions; it does not guarantee that an individual answer is correct."

보정은 집단의 성질입니다. 같은 확률로 보고된 답들을 많이 모았을 때 그 비율만큼 맞는가를 재는 것이지, 지금 받은 이 답이 맞는다는 보증이 아닙니다.

### 그 집단은 누가 재는가

집단의 성질이라면, 그 집단을 누가 재느냐가 다음 질문입니다. 이번에 읽은 자료 범위에서 벤더가 공개한 보정 지표(신뢰도 곡선, ECE 같은)는 찾지 못했습니다. 공개 벤치마크는 일부러 싣지 않았다고 FAQ가 밝힙니다.

> "We deliberately chose not to publish performance against public benchmarks."

벤더 블로그의 비교 평가도 실제 정답이 아니라 다른 모델들의 평균을 정답으로 삼습니다.

> "We use the average of GPT-6 Astra and Fable 5.1 as the reference answer, which biases answers towards OpenAI and Anthropic’s models."

대신 벤더가 권하는 것은 호출하는 쪽의 데이터입니다. 개발 문서의 문장입니다.

> "Test thresholds by plotting confidence against accuracy on your data."

이 세 문장을 이어 놓으면 AGI 편의 질문, "이 산출물이 틀렸다는 걸 무엇이 알려주는가"의 답이 어디 있는지가 분명해집니다. 확률값은 아닙니다. 확률값이 믿을 만한지를 알려주는 것은 호출하는 쪽이 가진, 정답이 달린 데이터(이하 라벨 데이터)이고, 그 라벨 데이터는 호출하는 쪽이 만들어야 합니다. FAQ도 "Encourage users to create their own evals for their use cases (System One tasks are much easier to evaluate)."라고 적어, 그 일이 사용자 몫이라는 걸 전제합니다. 괄호 안의 "much easier"는 벤더의 주장이고, 쉬워도 누군가는 해야 합니다.

HN의 한 댓글은 이 비용을 정확히 짚었습니다.

> "I still have to define the constraints and test which wrong actions get through the complete workflow on my own data. That’s a substantial part of the work being pushed back onto the developer."

같은 작성자는 개별 답의 보정이 그 답들을 합친 결정의 보정까지 보장하지 않는다는 점도 지적했습니다("Even granting that each answer is calibrated individually, that doesn’t establish calibration of the decision that combines them."). 벤더 문서가 권하는 설계는 복잡한 판단을 몇 초짜리 "gut-check determination"들로 쪼개고 코드로 합치는 것입니다.[^intro] 그렇게 하면 라벨 데이터로 재야 할 대상은 개별 질문이 아니라 코드가 합친 결정이 됩니다.

### 확률은 공통 화폐가 아니다

임계값을 질문 사이에 옮기기 어렵다는 점도 문서에 나옵니다. jaggedness 문서는 같은 티켓에 "환불 요청인가"와 그 부정을 각각 Noul로 물은 예를 싣습니다. 두 값은 0.72와 0.47로, 합이 1.19였습니다. 문서의 권고는 이렇습니다.

> "Don't carry a threshold tuned on a Noul over to a Choice, and don't hold the model to arithmetic identities between separate questions."

문서는 질문 유형 사이에서도 임계값을 옮기지 말라고 합니다. 그렇다면 임계값을 정하는 라벨 데이터도 질문 단위로 쌓는 편이 안전하다고 봅니다.

한국어 서비스라면 조건이 하나 더 붙어요. 모델 문서는 언어별 정확도를 이렇게 적습니다.[^models]

> "English is the primary training language and where accuracy is currently best. Other languages, including CJK scripts, are handled but not equally well"

영어 입력으로 잰 곡선을 한국어 입력에 그대로 옮길 근거가 없다는 뜻이라, 벤더가 말한 "your data"는 여기서 "한국어로 된 우리 데이터"가 됩니다.

### 임계값의 유효기간은 버전 ID로 적힌다

라벨 데이터로 임계값을 재고 나면 한 가지가 더 남습니다. 그 임계값은 언제까지 유효한가. 모델 문서가 이 질문에 직접 답합니다.

> "An alias moves when a new release ships, so the answers behind it can change without a change on your side."

> "If you have tuned confidence thresholds against a specific version, pin that version's ID instead of the alias and move to the new one on your own schedule."

그런데 SDK의 기본값은 별칭 `jev-latest`입니다. 2026-09-28 조회 기준으로 `jev-latest`와 `jev-preview`는 모두 `jev-1.13.0`을 가리킵니다. 기본값대로 쓰면 임계값은 코드에 고정돼 있는데, 그 뒤의 모델은 새 릴리스와 함께 조용히 바뀝니다. 레이트리미터 글의 사고가 라이브러리 교체로 버스트 정책이 조용히 바뀐 것이었다면, 여기서는 별칭 이동이 임계값의 의미를 조용히 바꿉니다. 그나마 흔적이 남는 자리는 응답의 `model` 필드로, 실제로 답한 버전 ID를 돌려줍니다.

이 대목에서 하네스 책 리뷰가 닫지 못한 질문 하나가 부분적으로 닫힙니다. 책은 하네스의 각 구성요소가 "모델의 어떤 능력이 부족하기 때문에 존재하는지"를 적어 두라고 했습니다. 저는 그 권고가 "그때가 언제이고 무엇이 남는지에 대한 답은 아니다"라고 적었습니다. AGI 편은 그중 "무엇이 남는가"에 관찰 하나를 보탰지만 "언제"에는 답하지 못했습니다.

**확신도 임계값은 그 "언제"가 명시된 드문 구성요소입니다.** 벤더의 권고를 따르면 임계값의 유효기간은 고정한 버전 ID이고, 다음 버전으로 옮기는 날이 곧 다시 재는 날입니다. 모든 하네스 구성요소에 대한 답은 아닙니다. 다만 확률이 조건식에 들어오는 자리에서는 유효기간이 설정 파일의 문자열 하나로 적힙니다. 이 글을 쓰며 새로 얻은 관점 중 하나입니다.

처방도 이미 이 블로그에 있습니다. 레이트리미터 글의 "버스트 허용치를 설정으로 노출하고 테스트로 잠근다."를 옮기면, 모델 버전 ID와 임계값을 설정으로 드러내고 자기 라벨 데이터로 만든 회귀 세트로 잠그는 것입니다. priorbench가 향후 계획에 적은 구절 "a silent model update shows up as a diff, not as a surprise"도 같은 방향을 가리킵니다.

버전과 함께 다시 재지 않아도 되는 부분도 있습니다. jaggedness 문서는 판단과 계산의 경계를 먼저 긋습니다.

> "Extraction is a judgment, so give it to the model. Arithmetic is not, so keep it in code."

priorbench는 이 문서가 모델을 과소평가한다고 반박했습니다. 수와 날짜 비교에서 "We measure **99.6 % across 13 designs**."라는 측정입니다. 이 측정이 맞다고 해도 권고가 무너지지는 않는다고 저는 봅니다. 계산을 코드에 두는 이유를 "모델이 못 해서"가 아니라 "코드의 답은 모델 버전과 무관해서"로 읽으면, 99.6%는 다음 버전에서 다시 재야 하는 수치이고 코드의 비교 연산은 다시 잴 필요가 없습니다. AGI 편이 "조회는 모델 성능과 무관하게 같은 답을 냅니다"라고 적은 것과 같은 이유예요.

호출하는 쪽으로 넘어온 확률은 숫자 하나가 아니라, 그 숫자를 해석할 라벨 데이터와 그 해석의 유효기간까지 함께 넘어온 것입니다.

## 확신도와 되돌릴 수 있음

라벨 데이터와 버전 고정으로 임계값을 믿을 수 있게 됐다고 가정해 보겠습니다. 남는 질문은 그 임계값으로 무엇을 정하느냐입니다. 개념 문서는 불확실한 판단을 "a person or a reasoning model"에게 넘기라고 합니다. 그 넘김을 결정하는 것은 모델이 아니라 호출하는 쪽 코드의 조건식입니다. System One이라는 부류 이름은 Kahneman의 System 1과 System 2 구분에서 왔다고 FAQ가 밝히지만, System 1에서 System 2로 넘어가는 스위치는 Jev 밖, 호출하는 쪽에 있습니다.

그 조건식의 높이를 정하는 기준으로 벤더 문서들은 한결같이 결과의 크기를 듭니다. Noul 문서는 이렇게 적습니다.[^noul]

> "Where to set the threshold depends on the cost of being wrong. ... Raise it when acting on a false yes is expensive, such as paging someone or issuing a refund. Lower it when missing a true yes is expensive, such as failing to flag a safety issue."

확신도 문서의 예제에는 `# Low stakes. Showing the wrong screen is recoverable.`라는 주석이 달려 있고, 본문은 이렇게 정리합니다.

> "... the threshold for acting without confirmation is higher for a destructive operation than for a read-only one. Your code encodes the risk tolerance."

"recoverable", "destructive", "cost of being wrong". 벤더가 고른 단어는 전부 결과의 성질입니다. AGI 편에서 제 하네스 플러그인의 모델 자동 호출 차단 기준을 두고 "네 기준은 전부 결과의 성질을 말합니다"라고 적었던 것과 같은 축이에요. 다른 점은 벤더가 그 선을 확신도 값으로 그린다는 것이고, 그 선택이 어디서 흔들리는지를 같은 벤더의 문서 두 개가 보여 줍니다.

### 같은 송금, 다른 결론

확신도 문서와 확신도 라우팅 패턴 문서(이하 라우팅 문서)는 서로 다른 예제에서 같은 송금 승인 동작, `approve_transfer`를 다룹니다.[^routing] 결론이 갈리는 줄만 원문 그대로 발췌하면 이렇습니다.

| 문서 | 높은 확신도 분기 | 그 분기의 주석 | 부르는 함수 |
|---|---|---|---|
| `confidence` | `if confidence > 0.9:` | `# High stakes, high confidence. Proceed with confirmation.` | `confirm_then_execute(account_id)` |
| `patterns/confidence-routing` | `if action.confidence > 0.85:` | `# High stakes, but high confidence. Safe to act automatically.` | `approve_transfer(account_id)` |

두 문서 모두 확신도가 낮은 쪽은 사람에게 넘깁니다. 확신도 문서는 0.5 미만, 라우팅 문서는 0.6 미만입니다. 갈리는 건 확신도가 높은 쪽입니다. 확신도 문서는 0.9를 넘어도 `confirm_then_execute`, 곧 확인을 거쳐 실행합니다. 라우팅 문서는 0.85를 넘으면 `approve_transfer`를 바로 부르고, 주석이 "Safe to act automatically."라고 적습니다. 2026-09-28에 함께 조회한 같은 회사의 두 문서에서, 되돌리기 어려운 동작 앞에 사람 확인이 남느냐가 문서마다 다릅니다.

0.85와 0.9의 차이가 실제로 무엇을 가르는지에 대한 측정은 벤더 쪽 자료에서 찾지 못했습니다. 참고할 수 있는 건 priorbench의 단일 측정 하나입니다.

> "**Gate at 0.99 or not at all.** Accuracy above threshold is flat from 0.50 to 0.95, then jumps to **100 % at 0.99, covering 60.2 % of traffic**."

앞에서 적은 조건(하루, 한 위치, 한 버전)을 그대로 두면, 저자 스스로 얕다고 한 그 측정 안에서는 0.85와 0.9 사이가 임계값 위 정확도를 거의 가르지 않았습니다. 이걸 일반화할 수는 없습니다. 다만 두 문서의 차이가 확신도 0.05의 차이가 아니라는 것은 분명해 보입니다. 차이는 분기 안에서 부르는 함수, 곧 사람 확인이 있느냐 없느냐에 있습니다.

### 성능 축 위의 선과 밖의 선

**여기서부터는 제 해석입니다. 벤더가 이렇게 설명한 적은 없습니다.**

확신도는 모델 성능 축 위의 값입니다. 앞에서 본 것처럼 버전이 바뀌면 다시 재야 하고, 입력 언어가 바뀌어도 다시 재야 합니다. 되돌릴 수 있는가는 그 축 밖에 있습니다. AGI 편에서 적었듯 머지는 모델이 아무리 좋아져도 되돌리는 데 별도 작업이 필요하고, 송금도 마찬가지입니다.

두 축을 나눠 놓고 보면 두 문서의 불일치가 설명됩니다. 확신도 문서의 코드 예제는 결과의 성질을 **사람 확인이 있는가**로 표현했습니다. 0.9를 넘어도 확인 단계가 남습니다. 그런데 같은 문서의 산문은 앞에서 인용했듯 파괴적 동작에도 확인 없이 실행하는 문턱이 있고 그 높이만 다르다고 적습니다. 한 문서 안에서도 두 방식이 섞여 있는 셈입니다. 라우팅 문서는 산문 쪽 방식, 곧 **임계값의 높이**를 코드로 옮겼고, 그래서 확신도가 충분하면 확인까지 사라집니다.

사람 확인이 있는가로 표현하는 방식이라면, 다음 버전에서 확신도 분포가 달라져도 송금 앞의 사람 확인은 그대로입니다. 임계값의 높이로 표현하는 방식이라면 0.85의 의미가 버전과 함께 움직이고, 그 줄이 사람 확인을 대신하고 있으니 사람 확인의 존재도 함께 움직입니다.

그래서 저라면 이렇게 나눠 쓰겠습니다. 확신도는 되돌릴 수 있는 동작 안에서 **얼마나 자주 사람에게 넘길지**를 정하는 데 쓰고, 사람 확인이 **있는지**는 되돌릴 수 있는가가 정합니다. 앞의 것은 모델이 바뀌면 다시 재는 값이고, 뒤의 것은 모델이 바뀌어도 그대로인 선입니다.

### 모델에게서 뺀 권한, 한 줄로 돌아오는 권한

이 해석을 이 글에서 가장 중요하게 보는 이유는 Jev의 설계 자체와 맞물리기 때문입니다. 개발 문서는 모델이 하지 않는 일을 분명히 적습니다.

> "It does not generate code or choose its own next action."

> "Keep control flow, deterministic rules, and side effects in code."

같은 문서의 첫 문장도 "System One is TypeSafe's model for building AI-powered software, not agents."입니다. 출력 타입이 선택지, 척도, 참일 확률뿐이니, 모델은 구조적으로 행동을 표현할 수 없습니다. 하네스 책 리뷰의 "자기 검토를 막는 방법은 설득이 아니라 권한 회수다"와 AGI 편의 "분할의 기준은 능력이 아니라 권한"이 모델 인터페이스 수준에서 이뤄진 모양입니다.

그런데 `if action.confidence > 0.85:` 아래의 `approve_transfer(account_id)`는 그렇게 모델에게서 뺀 권한을 호출하는 쪽 한 줄로 확률값에 다시 이어 붙입니다. 모델은 여전히 다음 행동을 고르지 않지만, 확률이 문턱을 넘는 순간 송금이 실행된다면 실질적으로 행동을 고른 것은 그 확률입니다. 권한 회수는 인터페이스가 해 줍니다. 회수한 권한을 다시 건네지 않는 일은 호출하는 쪽 코드의 몫으로 남습니다. 확신도와 되돌릴 수 있음을 같은 조건식에 섞지 않는 것이 그 몫의 구체적인 모양이라고 저는 읽습니다.

## 읽고 나서 남은 것

생성 대신 판단을 돌려주는 모델이라는 설명은 불확실성을 줄여 주는 설계처럼 들립니다. 공개 자료를 따라가 보면, 불확실성의 소유권을 호출하는 쪽으로 옮기는 설계로 읽힙니다. **틀려도 타입은 맞는 답**에서는 "모르겠다"를 담을 자리가 선택지 목록을 쓰는 사람에게 넘어왔습니다. **호출하는 쪽으로 넘어온 확률**에서는 그 답이 틀렸다는 걸 알아낼 라벨 데이터와, 그 판정의 유효기간이 함께 넘어왔습니다. **확신도와 되돌릴 수 있음**에서는 사람이 멈춰 설 자리를 어느 축으로 그을지가 넘어왔습니다. 벤더 문서의 "Your code encodes the risk tolerance."는 면책 문구처럼 읽히지만, 책임이 놓인 위치를 정확히 적은 문장입니다.

AGI 편은 게이트가 모델 성능 축 밖에 놓인다는 관찰로 끝났습니다. 이 글이 거기에 보태는 것은 반대편의 사례입니다. 성능 축 위의 숫자가 게이트 자리에 직접 들어오는 제품이 나왔고, 그 제품의 문서 안에 이미 게이트가 버전과 함께 움직일 수 있는 방식으로 그려진 예제가 있었습니다. 그래서 확률을 돌려주는 모델 앞에서 할 일은 그 숫자를 믿을지 말지를 정하는 게 아니라, 그 숫자가 들어갈 자리를 고르는 것이라고 정리합니다. 사람에게 넘기는 빈도는 숫자에 맡기고, 사람이 있는지는 숫자에 맡기지 않습니다.

이 글은 공개 자료 읽기라서, 위 해석을 제 데이터로 확인하지는 못했습니다. 얼리 액세스를 받는다면 먼저 확인하고 싶은 것들은 전부 이 글의 해석이 틀릴 수 있는 지점입니다.

- Choice에 "해당 없음"을 넣었을 때와 뺐을 때, 범위 밖 입력의 결과와 확신도가 어떻게 달라지는가
- 한국어 `state`에서 확신도 분포가 영어 입력과 어떻게 다른가
- `jev-latest`로 호출한 응답의 `model` 필드가 언제 바뀌는가, 그때 고정 버전과 비교해 임계값 위 정확도가 얼마나 달라지는가

마지막으로 이 글이 서 있는 시점을 적어 둡니다. 발표 13일 뒤인 2026-09-28의 기록입니다. 그때 공개된 모델은 `jev-1.13.0` 하나였고, 두 송금 예제 문서와 jaggedness 문서(리뷰일 2026-09-17)도 그 시점의 판입니다.

벤더는 System One 모델이 대안보다 더 신뢰할 수 있게 만들어질 수 있다고 하면서, 그 근거를 "For reasons we will get into in the future"로 미뤄 두었습니다. 그 근거가 나오면 이 글의 해석 중 일부는 다시 읽어야 할 수 있습니다. 다만 확신도와 되돌릴 수 있음을 나누는 선은 그 근거와 무관하게 그대로일 거라고 봅니다. 모델이 더 믿을 만해져도, 송금은 여전히 되돌리기 어렵기 때문입니다.

[^blog]: TypeSafe, "Introducing System One Models & Jev", 2026-09-15. [typesafe.ai](https://typesafe.ai/blog/introducing-system-one-models-and-jev). 2026-09-28 조회. 본문의 비교표, FAQ, 환각 0% 설명, 비교 평가 방식 인용은 모두 이 글에서 왔다.
[^pr]: Business Wire 보도자료, 2026-09-15. [businesswire.com](https://www.businesswire.com/news/home/20260915525333/en/). 2026-09-28에 Yahoo Finance 게재본으로 조회했고, 게재본에 "This is a paid press release"라고 표시돼 있어 회사 발표문으로 다뤘다.
[^howto]: TypeSafe 문서, "How to build with TypeSafe". [docs.typesafe.ai](https://docs.typesafe.ai/concepts/how-to-build-with-system-one). 2026-09-28 조회. 임계값 권고는 .md 판 787행, 제어 흐름과 부작용에 관한 문장은 238행과 243행.
[^priorbench]: priorbench, "jev". [github.com/priorbench/jev](https://github.com/priorbench/jev). 2026-09-20 생성, 2026-09-28 README 조회. 익명 저자(`1j6c`)의 사전 등록 평가로, 모델 `typesafe/jev-1.13-20260917`을 OpenRouter 경유로 2026-09-20 서유럽에서 5,721회 호출했다. 원 응답 JSONL이 저장소에 포함돼 있다.
[^api]: TypeSafe 문서, "API reference". [docs.typesafe.ai](https://docs.typesafe.ai/api). 2026-09-28 조회.
[^confidence]: TypeSafe 문서, "Confidence". [docs.typesafe.ai](https://docs.typesafe.ai/confidence). 2026-09-28 조회. 확신도 정의는 .md 판 149행, 송금 예제는 199~213행, 확인 없이 실행하는 임계값에 관한 문장은 216행.
[^hn]: Hacker News, "Introducing System One Models and Jev", 2026-09-15. [news.ycombinator.com](https://news.ycombinator.com/item?id=49717558). 댓글 원문은 2026-09-28에 Algolia API로 조회했다. 회사 측으로 보이는 계정의 신원은 확인하지 않았다.
[^adapter]: TypeSafe, "system-one-adapter-python". [github.com/typesafe-ai/system-one-adapter-python](https://github.com/typesafe-ai/system-one-adapter-python). MIT, 2026-08-08 생성, 2026-09-28 조회.
[^jagged]: TypeSafe 문서, "Jev 1.13 jaggedness". [docs.typesafe.ai](https://docs.typesafe.ai/model-jaggedness/jev-1.13). 문서 표기 "Last reviewed 2026-09-17", 2026-09-28 조회.
[^dice]: KantaHayashiAI, "jev-does-not-play-dice". [github.com](https://github.com/KantaHayashiAI/jev-does-not-play-dice). 2026-09-18 생성, 2026-09-28 README 조회. 기록된 출력과 분석 스크립트가 저장소에 포함돼 있다.
[^system-one]: TypeSafe 문서, "System One". [docs.typesafe.ai](https://docs.typesafe.ai/concepts/system-one). 2026-09-28 조회. 보정 문장은 .md 판 21행, 사람이나 추론 모델로 넘기라는 문장은 49행.
[^intro]: TypeSafe 문서, "Introduction". [docs.typesafe.ai](https://docs.typesafe.ai/introduction). 2026-09-28 조회. 질문 설계 원칙은 .md 판 41행.
[^models]: TypeSafe 문서, "Models". [docs.typesafe.ai](https://docs.typesafe.ai/models). 2026-09-28 조회. 별칭 이동과 버전 고정 권고는 .md 판 40행, 언어별 정확도는 52행.
[^noul]: TypeSafe 문서, "Noul". [docs.typesafe.ai](https://docs.typesafe.ai/primitives/noul). 2026-09-28 조회. 임계값과 오류 비용에 관한 문장은 .md 판 367행.
[^routing]: TypeSafe 문서, "Confidence-gated routing". [docs.typesafe.ai](https://docs.typesafe.ai/patterns/confidence-routing). 2026-09-28 조회. 송금 예제는 .md 판 286~304행. 확신도 문서 쪽 송금 예제의 위치는 확신도 문서 각주에 적었다.
