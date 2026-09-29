---
layout: post
date: 2026-09-29 12:00:00 +0900
title: "답의 모양이 곧 코드의 모양이 되는 모델, Jev"
subtitle: "처음 보는 개발자를 위한 입문: 무엇이고, 어떻게 동작하고, 어디에 맞는가"
tags: [AI, Jev, 아키텍처]
---

TypeSafe AI가 2026-09-15에 Jev를 발표하면서 회사 블로그 첫머리에 던진 질문은 모델 성능에 관한 것이 아니었습니다.

> "Models have been superhuman at chat for years, so where is all the automation?"[^blog]

대화는 오래전부터 잘하는데 자동화는 왜 그만큼 따라오지 않았느냐는 물음입니다. 벤더가 내놓은 답은 더 똑똑한 대화 모델이 아니라 다른 인터페이스였습니다. 같은 글의 결말부는 회사를 세운 이유를 "We started TypeSafe because we believe that AI needs an interface software could depend on."이라고 적습니다. Jev는 그 인터페이스를 위해 만든 첫 모델입니다. 문장을 만들지 않고, 호출하는 쪽 코드가 미리 정해 보낸 칸에 판단과 확률을 채워 돌려줍니다.

이 글은 Jev를 처음 접하는 개발자를 위한 입문편입니다. 먼저 이 글의 성격을 밝혀 둡니다. **저는 Jev를 직접 호출해 보지 않았습니다.** 발표 시점 기준으로 공식 경로는 대기자 명단을 거치는 얼리 액세스였고, 이 글은 2026-09-29에 벤더의 블로그와 개발 문서, 공개 평가 사이트를 읽은 기록입니다. 본문에 나오는 응답 값은 전부 문서에 실린 예시입니다. 속도나 가격처럼 벤더가 수치로 내세운 것은 벤더의 주장으로만 다루고, 대부분은 싣지 않았습니다.

Jev를 이해하는 길은 기능 목록보다 설계 의도를 따라가는 편이 짧다고 봅니다. 출발점은 Jev가 **문장 대신 판단을 돌려받는 모델**이라는 점입니다. 판단을 돌려받으려면 무엇을 물을지, 답이 될 수 있는 후보가 무엇인지를 누군가 먼저 정해야 하는데, 그 일을 하는 것은 모델이 아닙니다. **질문을 설계하는 건 호출하는 쪽**입니다. 이 두 성질을 겹쳐 놓으면 Jev의 **맞는 자리와 맞지 않는 자리**도 사용 사례 목록 없이 갈립니다.

같은 날 발행한 [「확률을 돌려받는 순간, 틀렸다는 걸 알아낼 책임도 넘어왔다」](/blog/2026/09/29/jev-system-one-model.html)는 이 글 뒤에 읽을 심화편입니다. 그 글이 전제로 깔고 지나간 기본기를 여기서 먼저 다룹니다.

## 문장 대신 판단을 돌려받는 모델

Jev를 소개하는 자료에는 이름이 둘 나옵니다. System One은 모델의 부류 이름이고, Jev는 그 부류의 첫 모델입니다. 개념 문서는 부류를 이렇게 정의합니다.[^system-one]

> "System One models are a class of AI models built to make fast, structured decisions that software can use directly."

이 부류의 모델은 `state`(평가할 내용)를 받아 타입이 정해진 답과 확률을 돌려준다고 같은 문서가 이어서 적습니다. 부류 이름은 Daniel Kahneman이 대중화한 System 1(빠르고 직관적인 사고)과 System 2(느리고 신중한 사고)의 구분에서 왔고, 문서는 강조점을 "Here, the emphasis is on fast, focused judgments."라고 밝힙니다. Jev라는 이름은 William Stanley Jevons에게서 따왔다고 발표 글의 FAQ가 적습니다.

### 왜 문장이 아니라 판단인가

이 모델이 왜 문장을 버렸는지는 소개 문서가 한 문단으로 설명합니다.[^intro]

> "Large language models (LLMs) are designed to produce text for humans to read. When you need a model to make a judgment that your code will consume, that creates a mismatch: you are coercing a text-generation system into outputting structured decisions, then parsing the results back into something your code can depend on."

여기서 문제로 지목된 것은 LLM의 능력이 아니라 모양의 불일치입니다. 코드가 소비할 판단을 사람이 읽을 텍스트로 받으면, 그 텍스트를 코드가 기댈 수 있는 값으로 되돌리는 파싱과 검증이 매번 따라붙습니다. 프롬프트에 "JSON으로만 답하라"고 적고, 돌아온 문자열을 파싱하고, 형식이 깨지면 다시 부르는 코드가 그 흔적입니다. Jev는 그 왕복을 인터페이스에서 없애는 쪽을 택했습니다. 소개 문서는 다음 문단에서 "No text generation, no parsing. You get typed values and probability distributions that your code can branch on, sort by, and route with."라고 적습니다.

이 선택의 무게는 같은 판단을 LLM에게 물을 때와 Jev에게 물을 때를 나란히 놓으면 드러납니다. 인터페이스 수준에서 둘은 입력, 출력, 평가 방식에서 갈립니다.

- **입력.** 둘 다 자연어를 이해합니다. 개념 문서도 "Like an LLM, a System One model understands natural-language input."이라고 적습니다. 다만 Jev의 `state`는 문자열뿐 아니라 객체나 배열도 받습니다. 발표 글의 비교표 표현으로는 LLM이 "sequential messages"에, Jev는 "structured program state"에 무게를 둡니다.
- **출력.** LLM은 무엇이든 될 수 있는 문자열을 돌려줍니다. Jev는 호출하는 쪽이 미리 적어 보낸 후보 위의 값과 확률만 돌려줍니다. 개념 문서는 하지 않는 일을 분명히 적습니다. "System One models do not write replies, produce code, or generate explanations of their reasoning."
- **평가 방식.** LLM은 토큰을 하나씩 이어 붙여 답을 만듭니다. Jev는 한 요청에 담긴 질문들을 같은 `state`에 대해 한꺼번에, 서로 격리해 평가합니다. 소개 문서의 원문은 "Every *question* is evaluated in parallel and in isolation against the same *state* in one go."입니다.

발표 글의 비교표에는 비용, 속도, 확신도의 우열을 적은 행도 있습니다. 그 행들은 전부 벤더의 주장이고 이번에 확인하지 않았으므로 옮기지 않습니다. 출력 칸에 적힌 "The model never makes type errors." 역시 주장입니다. 이 글이 기대는 것은 "후보를 미리 정하고 그 안에서 답한다"는 설계 사실뿐입니다.

<figure class="jvi-embed jvi-compare">
<style>
/* Jev 입문편 그림 공통 규칙. 팔레트, 상자, 캡션은 이 블록이 정의하고 뒤의 그림들이 함께 쓴다 */
.jvi-embed{
  margin:2em 0;padding:1.25em;border:1px solid var(--bd);border-radius:10px;background:var(--bg);color:var(--text);
  font-family:-apple-system,"Apple SD Gothic Neo","Noto Sans KR","Segoe UI",sans-serif;font-size:0.9em;line-height:1.55;
  --bg:#f7faf9;--bd:rgba(17,121,100,0.26);--box:#ffffff;--text:#1f2a37;--muted:#56657a;--accent:#117964;
  --soft:#e6f1ee;--track:rgba(17,121,100,0.14);--warn:#b3402a;--warn-bg:#fcebe7;
  --close:#1d6b3a;--close-bg:#e6f4ea;--queue:#1f5fbf;--queue-bg:#e8f0fc;--page:#4f5d73;--page-bg:#eef1f5;
  --light:#8a5a00;--light-bg:#fdf4e3;--heavy:#b3402a;--heavy-bg:#fcebe7;
  --mono:ui-monospace,"JetBrains Mono",Menlo,monospace;
}
[data-theme="dark"] .jvi-embed{
  --bg:#131a28;--bd:rgba(77,182,160,0.30);--box:#1b2130;--text:#c9d3e0;--muted:#8b98a9;--accent:#4db6a0;
  --soft:#183331;--track:rgba(77,182,160,0.20);--warn:#ff8a70;--warn-bg:#3a2320;
  --close:#6fd39a;--close-bg:#17301f;--queue:#8ab8ff;--queue-bg:#172640;--page:#a3b0c2;--page-bg:#222a38;
  --light:#e3ad52;--light-bg:#312817;--heavy:#ff8a70;--heavy-bg:#3a2320;
}
.jvi-embed p{margin:0 0 0.35em;}
.jvi-embed ul{margin:0;padding:0;list-style:none;}
.jvi-embed li{margin:0;}
.jvi-embed code{font-family:var(--mono);font-size:0.9em;background:none;padding:0;margin:0;color:inherit;}
.jvi-embed .jvi-lead{margin:0 0 0.9em;text-align:center;font-weight:700;}
.jvi-embed .jvi-label{margin:0 0 0.5em;font-size:0.82em;font-weight:700;color:var(--accent);}
.jvi-embed .jvi-note{color:var(--muted);font-size:0.86em;}
.jvi-embed .jvi-box{background:var(--box);border:1px solid var(--bd);border-radius:8px;padding:0.6em 0.8em;min-width:0;}
.jvi-embed .jvi-arrow{display:flex;align-items:center;justify-content:center;color:var(--accent);font-size:1.2em;font-weight:700;}
.jvi-embed .jvi-down{text-align:center;color:var(--accent);font-size:1.2em;font-weight:700;line-height:1;margin:0.35em 0;}
.jvi-embed .jvi-type{display:inline-block;margin-right:0.35em;padding:0 0.45em;border:1px solid var(--bd);border-radius:4px;font-size:0.76em;font-weight:700;color:var(--accent);vertical-align:0.08em;}
.jvi-embed figcaption{margin-top:0.9em;color:var(--muted);font-size:0.9em;text-align:center;}
/* 같은 판단, 두 인터페이스 */
.jvi-embed .jvi-lane{display:grid;grid-template-columns:3.6em 1fr 1.2em 1fr 1.2em 1fr 1.2em 1fr;gap:0.35em;align-items:stretch;margin:0.5em 0;}
.jvi-embed .jvi-who{display:flex;align-items:center;font-weight:800;color:var(--accent);}
.jvi-embed .jvi-step b{display:block;margin-bottom:0.15em;}
.jvi-embed .jvi-step.is-cost{border-color:var(--warn);background:var(--warn-bg);}
.jvi-embed .jvi-step.is-cost b{color:var(--warn);}
.jvi-embed .jvi-step.is-none{border-style:dashed;background:transparent;text-align:center;}
.jvi-embed .jvi-step.is-none b{color:var(--muted);}
@media (max-width:640px){
  .jvi-embed .jvi-lane{grid-template-columns:1fr;gap:0.25em;margin:0.9em 0;}
  .jvi-embed .jvi-lane .jvi-arrow{transform:rotate(90deg);height:1.2em;}
}
</style>
<p class="jvi-lead">코드가 쓸 판단 하나를 받는 두 가지 길</p>
<div class="jvi-lane">
  <span class="jvi-who">LLM</span>
  <div class="jvi-box jvi-step"><b>프롬프트</b><span class="jvi-note">지시와 입력을 글로 보낸다. 대화 메시지 중심 입력</span></div>
  <span class="jvi-arrow" aria-hidden="true">→</span>
  <div class="jvi-box jvi-step"><b>생성된 문자열</b><span class="jvi-note">토큰을 하나씩, 앞의 토큰에 이어 생성한다</span></div>
  <span class="jvi-arrow" aria-hidden="true">→</span>
  <div class="jvi-box jvi-step is-cost"><b>파싱과 검증</b><span class="jvi-note">코드가 쓰려면 문자열을 다시 값으로 되돌려야 한다</span></div>
  <span class="jvi-arrow" aria-hidden="true">→</span>
  <div class="jvi-box jvi-step"><b>코드</b><span class="jvi-note">꺼낸 값을 쓴다</span></div>
</div>
<div class="jvi-lane">
  <span class="jvi-who">Jev</span>
  <div class="jvi-box jvi-step"><b><code>state</code>와 질문들</b><span class="jvi-note">프로그램 상태, 그리고 답의 후보를 미리 정한 질문</span></div>
  <span class="jvi-arrow" aria-hidden="true">→</span>
  <div class="jvi-box jvi-step"><b>질문마다 판단</b><span class="jvi-note">요청 하나 안에서 같은 <code>state</code>를 두고 병렬로 평가한다</span></div>
  <span class="jvi-arrow" aria-hidden="true">→</span>
  <div class="jvi-box jvi-step is-none"><b>파싱 단계 없음</b><span class="jvi-note">가능한 답과 구조가 미리 정해져 있다</span></div>
  <span class="jvi-arrow" aria-hidden="true">→</span>
  <div class="jvi-box jvi-step"><b>코드</b><span class="jvi-note">타입이 정해진 답과 확률로 분기, 정렬, 라우팅</span></div>
</div>
<figcaption>TypeSafe 문서의 구조 도식과 블로그 비교표 가운데 설계에 관한 항목(입력, 출력, 샘플링)을 바탕으로 다시 그렸습니다. 비교표의 속도와 비용 수치는 싣지 않았습니다.</figcaption>
</figure>

### 호출 한 번의 모양

호출 한 번의 모양은 quickstart 문서의 예시가 가장 잘 보여 줍니다.[^quickstart] 고객 지원 티켓 하나를 `state`로 넣고, 세 유형의 질문을 한 요청에 담아 묻는 예입니다. 코드는 문서 원문 그대로 옮겼습니다.

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

이 코드에서 볼 것은 SDK 사용법이 아니라 요청의 구조입니다. `questions`는 맵이고, 키(`department`, `frustration`, `is_urgent`)는 호출하는 쪽이 지은 이름입니다. 답은 같은 키 아래로 돌아옵니다. 질문마다 `instructions`에 무엇을 물을지 적고, Choice는 선택지 맵을, Score는 순서 있는 단계 설명 목록을 `criteria`로 함께 보냅니다. Noul은 예 아니면 아니오라서 `instructions`만으로도 됩니다.

문서에 실린 예시 응답은 이렇습니다. `department`는 `"choice": "technical"`이고 분포는 `technical` 0.85, `billing` 0.15, `sales` 0.0, 확신도는 0.78입니다. `frustration`은 `"score": 1.0`에 확신도 1.0, `is_urgent`는 `"noul": 1.0`입니다. 응답의 `model` 필드에는 실제로 답한 버전 `"jev-1.13.0"`이 찍힙니다. 다시 말하지만 이 값들은 문서의 예시이고, 제가 호출해서 얻은 값이 아닙니다.

<figure class="jvi-embed jvi-call">
<style>
/* 한 요청, 세 질문, 세 답. 공통 팔레트와 상자는 첫 그림의 .jvi-embed 규칙을 함께 쓴다 */
.jvi-embed .jvi-state{margin:0 0 0.7em;}
.jvi-embed .jvi-quote{display:block;margin:0.2em 0 0;padding:0.35em 0.6em;border-left:3px solid var(--bd);font-family:var(--mono);font-size:0.84em;overflow-wrap:anywhere;}
.jvi-embed .jvi-pairs{display:grid;grid-template-columns:1fr 1.4em 1fr;gap:0.55em 0.35em;align-items:stretch;}
.jvi-embed .jvi-head{margin:0;font-size:0.82em;font-weight:700;color:var(--accent);}
.jvi-embed .jvi-key{display:block;margin-bottom:0.2em;font-family:var(--mono);font-weight:700;color:var(--accent);}
.jvi-embed .jvi-instr{display:block;font-family:var(--mono);font-size:0.84em;overflow-wrap:anywhere;}
.jvi-embed .jvi-chips{display:flex;flex-wrap:wrap;gap:0.3em;margin-top:0.35em;}
.jvi-embed .jvi-chips li{border:1px solid var(--bd);border-radius:999px;padding:0 0.55em;font-family:var(--mono);font-size:0.8em;}
.jvi-embed .jvi-levels{margin-top:0.35em;font-size:0.82em;}
.jvi-embed .jvi-levels li{display:grid;grid-template-columns:1.2em 1fr;gap:0.3em;}
.jvi-embed .jvi-levels code{color:var(--muted);}
.jvi-embed .jvi-val{display:block;margin-bottom:0.3em;font-family:var(--mono);font-size:0.86em;}
.jvi-embed .jvi-val b{color:var(--accent);}
.jvi-embed .jvi-bars li{display:grid;grid-template-columns:6.4em 1fr 2.6em;gap:0.4em;align-items:center;margin:0.18em 0;font-family:var(--mono);font-size:0.8em;}
.jvi-embed .jvi-track{position:relative;display:block;height:0.6em;border-radius:3px;background:var(--track);}
.jvi-embed .jvi-fill{display:block;height:100%;border-radius:3px;background:var(--accent);}
.jvi-embed .jvi-num{text-align:right;white-space:nowrap;}
.jvi-embed .jvi-bars li > span:first-child{white-space:nowrap;}
.jvi-embed .jvi-scale{margin:0.5em 0.4em 0.2em;}
.jvi-embed .jvi-scale .jvi-track{height:0.5em;}
.jvi-embed .jvi-pin{position:absolute;top:50%;width:0.9em;height:0.9em;margin:-0.45em 0 0 -0.45em;border-radius:50%;background:var(--accent);border:2px solid var(--box);}
.jvi-embed .jvi-ticks{display:flex;justify-content:space-between;margin-top:0.2em;font-family:var(--mono);font-size:0.76em;color:var(--muted);}
@media (max-width:640px){
  .jvi-embed .jvi-pairs{grid-template-columns:1fr;gap:0.3em;}
  .jvi-embed .jvi-pairs .jvi-arrow{transform:rotate(90deg);height:1.2em;}
  .jvi-embed .jvi-pairs > span:empty{display:none;}
}
</style>
<div class="jvi-box jvi-state">
  <p class="jvi-label"><code>state</code>: 고객 티켓 원문</p>
  <span class="jvi-quote">"Hi, I've been trying to connect my Stripe account for 3 days and the integration keeps failing. I'm losing sales. Please help ASAP."</span>
</div>
<div class="jvi-pairs">
  <p class="jvi-head">질문: 호출하는 쪽이 키, 유형, 답의 후보를 정한다</p>
  <span></span>
  <p class="jvi-head">답: 같은 키 아래로 돌아온다 (<code>"model": "jev-1.13.0"</code>)</p>
  <div class="jvi-box">
    <span class="jvi-key">department</span>
    <span class="jvi-type">Choice</span><span class="jvi-instr">"Which team should handle this"</span>
    <ul class="jvi-chips"><li>billing</li><li>technical</li><li>sales</li></ul>
  </div>
  <span class="jvi-arrow" aria-hidden="true">→</span>
  <div class="jvi-box">
    <span class="jvi-val"><b>choice</b> "technical"</span>
    <ul class="jvi-bars">
      <li><span>technical</span><span class="jvi-track"><span class="jvi-fill" style="width:85%"></span></span><span class="jvi-num">0.85</span></li>
      <li><span>billing</span><span class="jvi-track"><span class="jvi-fill" style="width:15%"></span></span><span class="jvi-num">0.15</span></li>
      <li><span>sales</span><span class="jvi-track"><span class="jvi-fill" style="width:0%"></span></span><span class="jvi-num">0.0</span></li>
    </ul>
    <span class="jvi-val"><b>confidence</b> 0.78</span>
  </div>
  <div class="jvi-box">
    <span class="jvi-key">frustration</span>
    <span class="jvi-type">Score</span><span class="jvi-instr">"How frustrated the customer appears"</span>
    <ul class="jvi-levels">
      <li><code>0</code><span>Calm, just stating facts</span></li>
      <li><code>1</code><span>Frustrated but civil</span></li>
      <li><code>2</code><span>Very angry, strong language</span></li>
    </ul>
  </div>
  <span class="jvi-arrow" aria-hidden="true">→</span>
  <div class="jvi-box">
    <span class="jvi-val"><b>score</b> 1.0</span>
    <div class="jvi-scale" aria-hidden="true">
      <span class="jvi-track"><span class="jvi-pin" style="left:50%"></span></span>
      <div class="jvi-ticks"><span>0</span><span>1</span><span>2</span></div>
    </div>
    <span class="jvi-val"><b>probabilities</b> 0: 0.0, 1: 1.0, 2: 0.0</span>
    <span class="jvi-val"><b>confidence</b> 1.0</span>
  </div>
  <div class="jvi-box">
    <span class="jvi-key">is_urgent</span>
    <span class="jvi-type">Noul</span><span class="jvi-instr">"The message conveys urgency or time-sensitivity"</span>
  </div>
  <span class="jvi-arrow" aria-hidden="true">→</span>
  <div class="jvi-box">
    <span class="jvi-val"><b>noul</b> 1.0</span>
    <div class="jvi-scale" aria-hidden="true">
      <span class="jvi-track"><span class="jvi-pin" style="left:100%"></span></span>
      <div class="jvi-ticks"><span>0 아니오</span><span>1 예</span></div>
    </div>
    <span class="jvi-note">값 자체가 확률이라 <code>confidence</code>가 따로 없다</span>
  </div>
</div>
<figcaption>TypeSafe quickstart 문서의 예시 요청과 응답입니다. 필자가 호출한 결과가 아닙니다. 질문 키(<code>department</code> 같은 이름)는 모델에 전달되지 않고, 답을 같은 키 아래로 돌려받는 데만 쓰입니다.</figcaption>
</figure>

돌려받는 값은 유형마다 읽는 법이 다릅니다. 셋 모두 호출하는 쪽이 적은 후보 위의 확률에서 나온 값이라는 점은 같습니다.[^api]

- **Choice**의 `choice`는 확률이 가장 높은 선택지이고, `probabilities`는 합이 1인 선택지별 분포입니다.
- **Score**의 `score`는 API 문서 표현으로 "The probability-weighted answer across the levels; can land between levels."입니다. API 문서의 다른 예시에서 레벨 0, 1, 2의 확률이 0.0, 0.95, 0.05일 때 `score`가 1.05인데, 0×0.0 + 1×0.95 + 2×0.05를 계산하면 정확히 그 값이 나옵니다. 그러니 1.05는 "1.05라는 레벨"이 아니라 레벨 1 쪽에 거의 몰린 분포를 한 숫자로 요약한 값입니다.
- **Noul**의 `noul`은 0(아니오)에서 1(예) 사이의 참일 확률입니다. 질문 유형 문서는 0.5를 두고 "A Noul value of 0.5 means the model gives yes and no equal probability. It does not mean the candidate has a medium skill level."이라고 못 박습니다.[^primitives] 0.5는 "중간 정도"가 아니라 "반반"입니다.

확신도(`confidence`)는 Choice와 Score에만 붙습니다. 확신도 문서의 정의는 "`confidence` is a statistic computed from the probability distribution the answer already gives you."입니다.[^confidence] 질문 유형 문서는 Choice의 확신도를 "`confidence` summarizes how peaked that distribution is."라고 풀어 씁니다. 분포가 한 선택지에 뾰족하게 몰릴수록 높아지는 요약값입니다. Noul은 값 자체가 확률이라 따로 확신도가 없어요. 발표 글의 비교표는 모든 답에 확신도가 붙는다고 적었지만 API 문서와 어긋나므로, 이 글은 문서를 따릅니다.

확신도가 있는 이유를 개념 문서는 이렇게 적습니다. "Answers from System One models also include confidence, so you can decide when to act and when to escalate to a person or a reasoning model." 확신도가 낮은 답을 사람이나 더 비싼 추론 모델에게 넘길 수 있다는 뜻입니다. 그 문턱을 어디에 둘지는 입문 범위를 넘는 문제라 이 글 끝에서 심화편으로 넘깁니다.

### 서로 모르는 질문들

한 요청에 담긴 질문들은 서로의 답을 보지 못합니다. 질문 유형 문서는 이것을 답이 조합 가능한 이유로 듭니다.

> "**Every answer is independent.** One question's answer is not hidden context for another. You can add or remove questions without changing the others' results."

독립성에서는 호출하는 쪽이 얻는 것과 떠안는 것이 함께 나옵니다. 질문을 더하거나 빼도 나머지 답이 흔들리지 않는다는 것이 얻는 쪽이고, 앞 질문의 답을 보고 다음 질문을 정해야 할 때는 요청을 나눠야 한다는 것이 떠안는 쪽입니다. 문서는 후자를 "If a later judgment depends on an earlier answer, make a second request in code."라고 적고, 다음 문단 첫머리에 "Two requests are the exception, not the rule."을 덧붙입니다. 뒤에서 볼 보안 알림 예제에 이 예외가 실제로 필요한 모양이 나옵니다.

이렇게 돌아온 값은 코드가 곧바로 분기, 정렬, 라우팅에 쓸 수 있습니다. 벤더가 이 쓰임을 부르는 요약어는 "smart if-statements"입니다. 모델의 답이 파싱 없이 조건식 안으로 들어간다는 것이 **문장 대신 판단을 돌려받는 모델**이라는 말의 인터페이스 수준 뜻입니다. 그런데 조건식에 들어갈 답의 모양, 곧 무엇을 묻고 어떤 후보 중에서 고르게 할지는 아직 아무도 정하지 않았습니다.

## 질문을 설계하는 건 호출하는 쪽

앞 절의 예시에서 모델이 고를 수 있는 세계는 `billing`, `technical`, `sales` 세 선택지였습니다. 그 선택지를 정한 것은 모델이 아니라 요청을 쓴 코드입니다. 질문 문장도, Score의 단계 설명도 마찬가지입니다. Jev에서 모델이 맡는 일은 설계된 질문에 답하는 것까지이고, 질문 자체는 호출하는 쪽의 설계물입니다.

### 모델은 적힌 글자만 읽는다

입문자가 의외로 여길 만한 사실 하나가 이 분업을 선명하게 보여 줍니다. 질문에 붙인 키는 모델에게 전달되지 않습니다. API 문서는 질문 키를 설명하며 이렇게 적습니다.

> "The key is not sent to the underlying model and is not used in inference."

질문 유형 문서의 팁은 한 걸음 더 나아갑니다.

> "Question IDs are for your code. They are not sent to the model. Write the complete question in `instructions`, even when the ID seems self-explanatory."

quickstart 예시의 `is_urgent`라는 키는 사람이 보기에는 질문 전체를 말해 주는 것 같습니다. 하지만 모델이 받는 것은 "The message conveys urgency or time-sensitivity"라는 `instructions` 문장뿐입니다. 키는 코드가 응답에서 답을 꺼낼 때만 쓰는 이름이에요. Score의 레벨 번호도 모델에게 보이지 않는다고 Score 문서가 적습니다.[^score] 모델이 판단의 재료로 쓰는 것은 호출하는 쪽이 문장으로 적어 보낸 것이 전부입니다.

jaggedness 문서, 곧 버전별로 모델의 들쭉날쭉한 지점을 정리한 문서는 같은 성질을 모델 쪽에서 설명합니다.[^jagged]

> "`jev-1.13` answers the question you wrote, not the one you meant. Scoping words, negations, and implied conditions are read at face value."

바로 다음 문장이 질문을 쓰는 사람에게 주는 처방입니다. "When you look at a wrong answer and find yourself explaining what you really meant, that explanation is the missing half of the instruction." 틀린 답을 보고 "그 뜻이 아니었는데"라고 설명하고 싶어진다면, 그 설명이 질문에서 빠져 있던 절반이라는 뜻입니다.

이 성질은 도메인에 맞추는 방법까지 정합니다. 모델 문서는 "Jev is not fine-tuned or LoRA-adapted with customer data."라고 적고, 도메인 맞춤의 길을 "You shape its answers to your domain through the request rather than through per-account weights"라고 안내합니다.[^models] 이어지는 방법은 `state`에 자기 자료를 넣는 것, `instructions`와 `criteria`에 도메인 규칙과 경계 사례를 적는 것, 넓은 판단을 작은 질문으로 쪼개 코드로 합치는 것입니다. 모든 계정이 같은 가중치를 쓰니, Jev에서 질문을 쓰는 일이 곧 도메인에 맞추는 일입니다.

### 유형은 답을 받을 코드에서 고른다

질문 유형을 고르는 기준도 호출하는 쪽 코드에서 나옵니다. 질문 유형 문서가 드는 기준은 답의 모양에 따라 갈립니다.

- **Choice**는 답이 순서 없는 알려진 후보 중 하나일 때 맞습니다. 티켓을 부서로 보내기, 문서 종류 분류하기 같은 경우입니다. 문서는 후보 목록이 모든 입력을 덮지 못할 수 있으면 "add an `other` or `none of the above` option when the list might not cover every input"이라고 권합니다. 답은 언제나 적어 보낸 후보 안에서만 나오기 때문입니다.
- **Score**는 답이 스펙트럼 위에 있고, 그 스펙트럼의 각 지점이 무엇을 뜻하는지 설명할 수 있을 때 맞습니다. 버그 심각도, 고객의 불만 정도, 숙련도가 문서의 예입니다.
- **Noul**은 깔끔한 예, 아니오 질문이면서 확률 자체가 쓸모 있는 신호일 때 맞습니다. 메시지에 개인정보가 있는가, 고객이 환불을 요청하는가 같은 질문입니다. 숙련도처럼 정도를 묻고 싶다면 Noul이 아니라 단계를 정의한 Score를 쓰라고 문서는 따로 적습니다. 앞에서 본 것처럼 Noul 0.5는 "중간"이 아니라 "반반"이기 때문입니다.

두 유형이 다 맞아 보일 때의 기준이 입문자에게는 가장 실용적이라고 봅니다.

> "If two types both seem to fit, prefer the one whose answer your code can act on directly. A Choice between `refund`, `rebook`, and `information` maps straight onto three code paths. A Score of customer frustration maps onto a threshold. A Noul maps onto an `if`."

유형을 고를 때 먼저 볼 것은 입력이 아니라 답을 받을 코드라는 뜻입니다. 코드가 N갈래로 갈라지면 Choice, 문턱 하나로 자르면 Score, `if` 하나로 끝나면 Noul입니다. 이 글의 제목을 여기서 가져왔습니다. **답의 모양이 곧 코드의 모양**이고, 그 모양을 정하는 것은 호출하는 쪽입니다.

<figure class="jvi-embed jvi-types">
<style>
/* 답의 모양에서 코드의 모양으로. 공통 팔레트와 상자는 첫 그림의 .jvi-embed 규칙을 함께 쓴다 */
.jvi-embed .jvi-cols{display:grid;grid-template-columns:repeat(3,1fr);gap:0.7em;}
.jvi-embed .jvi-col{display:flex;flex-direction:column;gap:0.45em;min-width:0;}
.jvi-embed .jvi-col-title{margin:0;text-align:center;font-size:1.15em;font-weight:800;color:var(--accent);}
.jvi-embed .jvi-col-q{margin:0 0 0.2em;text-align:center;font-family:var(--mono);font-size:0.82em;color:var(--muted);}
.jvi-embed .jvi-row-label{display:block;margin-bottom:0.2em;font-size:0.76em;font-weight:700;color:var(--muted);}
.jvi-embed .jvi-code{background:var(--soft);border-color:var(--accent);}
.jvi-embed .jvi-code .jvi-shape{display:block;margin-bottom:0.3em;font-weight:800;color:var(--accent);}
.jvi-embed .jvi-paths li{display:grid;grid-template-columns:auto 1fr;gap:0.4em;font-family:var(--mono);font-size:0.84em;}
.jvi-embed .jvi-paths li::before{content:"→";color:var(--accent);}
.jvi-embed .jvi-mono{display:block;font-family:var(--mono);font-size:0.84em;}
@media (max-width:640px){
  .jvi-embed .jvi-cols{grid-template-columns:1fr;gap:1.1em;}
}
</style>
<div class="jvi-cols">
  <div class="jvi-col">
    <p class="jvi-col-title">Choice</p>
    <p class="jvi-col-q">"Which of these options?"</p>
    <div class="jvi-box"><span class="jvi-row-label">이럴 때</span>순서 없는, 알려진 후보 가운데 하나. 부서로 티켓 보내기, 문서 종류 분류</div>
    <div class="jvi-box"><span class="jvi-row-label">돌려받는 값</span><code>choice</code>, 후보별 <code>probabilities</code>, <code>confidence</code></div>
    <div class="jvi-box jvi-code"><span class="jvi-shape">코드 경로 셋</span>
      <ul class="jvi-paths"><li>refund</li><li>rebook</li><li>information</li></ul>
    </div>
  </div>
  <div class="jvi-col">
    <p class="jvi-col-title">Score</p>
    <p class="jvi-col-q">"Which level?"</p>
    <div class="jvi-box"><span class="jvi-row-label">이럴 때</span>각 단계의 뜻을 설명할 수 있는 스펙트럼 위의 위치. 버그 심각도, 고객 불만 정도</div>
    <div class="jvi-box"><span class="jvi-row-label">돌려받는 값</span><code>score</code>(단계 사이 값도 가능), <code>legend</code>, <code>probabilities</code>, <code>confidence</code></div>
    <div class="jvi-box jvi-code"><span class="jvi-shape">문턱 하나</span>
      <span class="jvi-mono">if score &gt;= 문턱: …</span>
    </div>
  </div>
  <div class="jvi-col">
    <p class="jvi-col-title">Noul</p>
    <p class="jvi-col-q">"Is this true?"</p>
    <div class="jvi-box"><span class="jvi-row-label">이럴 때</span>확률 자체가 쓸모 있는 예, 아니오. 개인정보가 들어 있는가, 환불을 요청하는가</div>
    <div class="jvi-box"><span class="jvi-row-label">돌려받는 값</span><code>noul</code>(0에서 1, 참일 확률). 값 자체가 확률이라 <code>confidence</code>가 따로 없다</div>
    <div class="jvi-box jvi-code"><span class="jvi-shape">if 하나</span>
      <span class="jvi-mono">if noul &gt; 문턱: …</span>
    </div>
  </div>
</div>
<figcaption>TypeSafe primitives 문서의 유형 선택 기준을 옮겼습니다. 두 유형이 모두 맞아 보이면, 답을 코드가 바로 쓸 수 있는 쪽을 고르라고 권합니다. 문턱을 얼마로 둘지는 이 그림에서 다루지 않습니다.</figcaption>
</figure>

### 한 질문은 1초짜리 판단으로

질문의 크기에도 기준이 있습니다. 질문 유형 문서의 문장입니다.

> "Ask for a judgment a knowledgeable person makes in a second given the right context. "Does this message convey urgency?" is a good question. "Analyze this message and determine the best course of action" is not. That needs slow reasoning, and it is a signal to break the task into small questions and compose the answers in code."

아는 사람이 맥락을 받으면 1초 안에 내릴 수 있는 판단, 소개 문서의 표현으로는 "gut-check determination"이 한 질문의 크기입니다. 그보다 큰 판단은 쪼갭니다. 개발 가이드는 이 분해를 두고 이렇게 적습니다.[^howto]

> "This is probably the most important concept in this guide. Broad questions hide several judgments behind one answer. Atomic questions expose those judgments so you can inspect, tune, and combine them in code."

가이드의 스팸 판정 예시가 가장 짧은 전후 비교입니다. 예시의 메시지는 발신자 이름이 "Acme Payroll"인데 주소는 `rewards@claim-bonus.example`이고, 제목은 "Urgent: claim your employee bonus"입니다. 나쁜 예는 이 메시지에 Noul 하나, `is_spam`에 "Is `message` spam?"을 묻습니다. 좋은 예는 같은 메시지에 Noul 여섯 개를 묻습니다. 질문 ID만 우리말로 풀어 보면 자격 증명을 요구하는가(`requests_credentials`), 뜻밖의 보상을 내거는가(`offers_unexpected_reward`), 시간 압박을 거는가(`creates_time_pressure`), 발신자 이름과 주소가 어긋나는가(`sender_identity_mismatch`), 링크 도메인이 어긋나는가(`link_domain_mismatch`), 링크의 실제 목적지를 숨기는가(`disguises_link_destination`)입니다.

쪼개고 나면 "스팸인가"는 모델의 답이 아니라 코드가 여섯 신호를 합친 결과가 됩니다. 어느 신호가 결론을 끌었는지가 보이고, 신호마다 무게를 달리 줄 수 있습니다. 질문 유형 문서는 그 이점을 "When priorities shift, change the value of weights rather than rewriting a prompt."라고 적습니다. 우선순위가 바뀌면 프롬프트를 고쳐 쓰는 대신 코드의 가중치 숫자를 바꾸면 됩니다. 쪼갠다고 호출이 늘지도 않습니다. 같은 `state`에 대한 질문은 한 요청 안에서 함께 평가되니까요("Decomposition does not require more round trips. Questions over the same state run in parallel.").

### 코드가 쥐는 것

쪼갠 질문의 답을 합치는 곳이 코드라면, 코드가 쥐는 몫은 합치기보다 넓습니다. 개발 가이드의 요약 상자는 "build a normal software workflow and insert System One only where AI is needed."로 시작합니다. 바로 아래 첫 항목은 "Keep control flow, deterministic rules, and side effects in code."입니다. 제어 흐름, 결정적 규칙, 부작용은 코드에 두고, 모델은 코드로 표현하기 어려운 판단이 필요한 자리에만 끼워 넣으라는 것입니다. 가이드는 이런 구조를 "AI-powered software"라고 부르며 이렇게 정의합니다.

> "Code handles deterministic work and owns the control flow. The model appears only where the system needs programmable common sense or needs to interpret unstructured data. Each AI task is kept atomic and constrained."

벤더의 평가 사이트는 이 분업을 장난감 예제 하나로 보여 줍니다.[^evals] 팀이 흔히 적어 두는 경비 정산 정책 문단을 워크플로로 옮긴 예인데, 설명 문장이 핵심을 요약합니다. "Each sentence became either a question for the model, with a type, or a rule for the code." 정책 문장마다 모델에게 줄 질문(유형 포함)이 되거나 코드의 규칙이 된다는 뜻입니다. 영수증을 읽을 수 있는가는 Noul, 경비 종류(식비, 교통비, 장비)는 Choice, 청구서 설명이 영수증과 얼마나 맞는가는 네 단계 Score가 됩니다. 반면 $75를 넘는 식비라는 조건은 모델의 질문이 아니라 코드의 규칙 쪽에 놓입니다. 금액 비교는 판단이 아니라 계산이기 때문입니다.

### 예제 하나를 끝까지: 보안 알림 처리

분업이 실제 규모에서 어떤 모양이 되는지는 벤더가 공개한 보안 알림 처리 워크플로가 보여 줍니다. 발표 글이 "the simplest of the 4 workflows we’re publishing"이라며 소개하고, 평가 사이트가 질문 정의와 판정 기록까지 공개한 예제입니다.[^security] 워크플로가 푸는 문제는 "An alert has fired. What should be done?"입니다. 알림 하나가 울리면, 그 알림과 알림이 울린 자산, 그리고 거기에 붙은 기록들(진행 중인 티켓, 등록된 장비, 예정된 점검 작업, 사전 권한)을 보고 닫을지, 분석가에게 넘길지, 지금 막을지를 정합니다.

흐름은 모델 단계와 코드 단계가 번갈아 나오는 네 단계입니다. 평가 사이트의 단계 이름은 "Read the alert", "Close, queue, or act", "The state of the incident", "Choose the response"이고, 이 글에서는 알림 읽기, 처리 방향 정하기, 사고 상태 읽기, 대응 고르기로 옮깁니다.

**알림 읽기(모델).** 첫 요청은 질문 세 개를 담습니다. 모델에게 가는 질문 원문은 이렇습니다.

| 질문 ID | 유형 | `instructions` 원문 |
|---|---|---|
| `is_true_positive` | Noul | "Given the alert and its context records, does this describe unauthorized activity, as opposed to authorized activity that a detector flagged?" |
| `context_explains_activity` | Noul | "Do the context records \-\- tickets, registrations, schedules, authorization excerpts \-\- account for the flagged activity?" |
| `evidence_strength` | Score | "How strong is the evidence that the activity is unauthorized?" |

세 질문 모두 "무엇을 할까"가 아니라 "지금 어떤 상태인가"를 묻습니다. 권한 없는 활동인가, 그걸 설명하는 기록이 있는가, 증거가 얼마나 강한가. `evidence_strength`의 네 단계도 "Speculative"에서 "Confirmed"까지 증거의 상태를 적은 설명입니다.

**처리 방향 정하기(코드).** 이 단계에는 모델 호출이 없습니다. 코드가 세 답을 자산의 환경, 중요도 등급, 탐지기의 영역과 함께 읽어 닫기, 대기열, 조치 중 하나로 보냅니다. 공개된 판정 기록에 남은 규칙 문자열은 이렇습니다. 여기서 P는 `is_true_positive`의 값입니다.

- 닫기: "P < 0.15, with a record that explains it: close". 기록이 설명한다는 조건은 `context_explains_activity`에 대한 "P > 0.50: a record explains the activity"로 따로 기록돼 있고, 자산이 도메인 컨트롤러인 경우에는 같은 규칙이 "(never on a domain controller)"라는 예외를 달고 나옵니다.
- 조치: "P > 0.75: act now"
- 그 사이: 신원 관련 알림이면 "0.15 < P ≤ 0.60 on an identity alert: notify the user", 아니면 분석가에게 넘깁니다(`ESCALATE TIER2`).

**사고 상태 읽기(모델).** 조치로 판정된 경우에만 두 번째 요청이 나갑니다. 평가 사이트의 판정 기록에는 조치가 아니었던 케이스에서 이 단계를 건너뛴 사유가 "the disposition was middle: only an act reaches containment"로 남아 있습니다. 앞에서 요청을 나누는 것은 예외라고 했는데, 그 예외가 바로 이 자리입니다. 두 번째 요청을 보낼지 말지가 첫 답에 달려 있으니, 코드가 첫 답을 본 뒤에야 정할 수 있어요.

두 번째 요청에는 질문 11개가 들어갑니다. 자격 증명이 새어 나갔는가, 공격자가 지금 세션을 쓰고 있는가, 악성 메일이 받은편지함에 남아 있는가, 재부팅 뒤에도 살아나는 장치가 있는가, 악성 프로세스가 돌고 있는가, 공격자 쪽으로 트래픽이 나가고 있는가, 설정이 바뀌었는가, 지금 진행 중인가, 처음 탐지된 대상 밖으로 번졌는가를 묻는 Noul 아홉 개와, 영향 범위와 공격 종류를 고르는 Choice 두 개입니다.

**대응 고르기(코드).** 마지막 단계도 코드입니다. 평가 사이트의 설명은 "The playbook takes the first group whose conditions are met, then the strongest step in it that still applies. When no group applies, the alert is escalated."입니다. 그룹은 데이터가 지금 나가고 있다, 공격자가 접근 권한을 쥐었다, 악성 메일이 배달됐다, 호스트가 장악됐다, 설정이 바뀌었다의 순서로 놓이고, 각 그룹 안의 조치는 강한 것부터 약한 것 순서입니다. 예를 들어 호스트 그룹에는 `attacker_persistence_present`에 대한 "P > 0.60: enters group 4"라는 진입 규칙이 기록돼 있고, 그 안에서 호스트 격리(`ISOLATE HOST`), 프로세스 종료(`KILL PROCESS`), 파일 격리(`QUARANTINE FILE`) 순서로 조건을 확인합니다.

<figure class="jvi-embed jvi-flow">
<style>
/* 보안 알림 처리 워크플로. 공통 팔레트와 상자는 첫 그림의 .jvi-embed 규칙을 함께 쓴다 */
.jvi-embed .jvi-stage{display:grid;grid-template-columns:7.6em 1fr;gap:0.7em;align-items:start;padding:0.75em 0.85em;border-radius:8px;}
.jvi-embed .jvi-stage.is-model{background:var(--soft);border:1px solid var(--accent);}
.jvi-embed .jvi-stage.is-code{background:var(--box);border:1px dashed var(--bd);}
.jvi-embed .jvi-stage.is-input{background:var(--box);border:1px solid var(--bd);}
.jvi-embed .jvi-stage-name{margin:0;font-weight:800;line-height:1.35;}
.jvi-embed .jvi-stage-name small{display:block;font-size:0.78em;font-weight:700;color:var(--muted);}
.jvi-embed .is-model .jvi-stage-name{color:var(--accent);}
.jvi-embed .jvi-qs li{display:grid;grid-template-columns:3.4em 1fr;gap:0.4em;align-items:baseline;margin:0.18em 0;}
.jvi-embed .jvi-qs .jvi-type{margin:0;text-align:center;}
.jvi-embed .jvi-qid{display:block;font-family:var(--mono);font-size:0.78em;color:var(--muted);overflow-wrap:break-word;}
/* 좁은 화면에서 질문 ID가 글자 중간이 아니라 밑줄 뒤에서만 줄바꿈되도록 <wbr>을 넣었다 */
.jvi-embed .jvi-qs.is-two{display:grid;grid-template-columns:1fr 1fr;gap:0 1em;}
.jvi-embed .jvi-rules > li{display:grid;grid-template-columns:minmax(0,1.25fr) minmax(0,1fr);gap:0.3em 0.8em;align-items:center;padding:0.4em 0;border-top:1px dashed var(--bd);}
.jvi-embed .jvi-rules > li:first-child{border-top:0;padding-top:0;}
.jvi-embed .jvi-cond{font-size:0.9em;}
.jvi-embed .jvi-cond b{display:block;}
.jvi-embed .jvi-cond code{font-size:0.84em;color:var(--muted);}
.jvi-embed .jvi-acts{display:flex;flex-wrap:wrap;gap:0.3em;}
.jvi-embed .jvi-act{display:inline-block;padding:0.05em 0.55em;border:1px solid currentColor;border-radius:4px;font-family:var(--mono);font-size:0.74em;font-weight:700;white-space:nowrap;}
.jvi-embed .jvi-act.is-close{color:var(--close);background:var(--close-bg);}
.jvi-embed .jvi-act.is-queue{color:var(--queue);background:var(--queue-bg);}
.jvi-embed .jvi-act.is-page{color:var(--page);background:var(--page-bg);}
.jvi-embed .jvi-act.is-light{color:var(--light);background:var(--light-bg);}
.jvi-embed .jvi-act.is-heavy{color:var(--heavy);background:var(--heavy-bg);}
.jvi-embed .jvi-act.is-next{color:var(--accent);background:var(--soft);}
.jvi-embed .jvi-inputs{display:flex;flex-wrap:wrap;gap:0.3em;}
.jvi-embed .jvi-inputs li{border:1px solid var(--bd);border-radius:999px;padding:0 0.6em;font-size:0.84em;}
.jvi-embed .jvi-down small{font-size:0.62em;font-weight:700;vertical-align:0.2em;}
.jvi-embed .jvi-legend{display:flex;flex-wrap:wrap;justify-content:center;gap:0.4em 0.9em;margin-top:0.9em;font-size:0.84em;color:var(--muted);}
.jvi-embed .jvi-legend .jvi-act{margin-right:0.2em;}
@media (max-width:640px){
  .jvi-embed .jvi-stage{grid-template-columns:1fr;gap:0.4em;}
  .jvi-embed .jvi-qs.is-two{grid-template-columns:1fr;}
  .jvi-embed .jvi-rules > li{grid-template-columns:1fr;}
}
</style>
<p class="jvi-lead">모델은 질문에 답하고, 동작은 코드의 규칙이 고른다</p>
<div class="jvi-stage is-input">
  <p class="jvi-stage-name">입력<small>알림 하나</small></p>
  <ul class="jvi-inputs"><li>알림</li><li>자산(환경, 등급, 담당자)</li><li>진행 중인 티켓</li><li>등록된 기기</li><li>예정된 점검</li><li>상시 허가</li></ul>
</div>
<div class="jvi-down" aria-hidden="true">↓</div>
<div class="jvi-stage is-model">
  <p class="jvi-stage-name">알림 읽기<small>모델이 답한다</small></p>
  <ul class="jvi-qs">
    <li><span class="jvi-type">Noul</span><span>허가받지 않은 활동인가<span class="jvi-qid">is_<wbr>true_<wbr>positive</span></span></li>
    <li><span class="jvi-type">Noul</span><span>미리 등록된 기록이 이 활동을 설명하는가<span class="jvi-qid">context_<wbr>explains_<wbr>activity</span></span></li>
    <li><span class="jvi-type">Score</span><span>증거가 얼마나 강한가 (추정에서 확정까지 네 단계)<span class="jvi-qid">evidence_<wbr>strength</span></span></li>
  </ul>
</div>
<div class="jvi-down" aria-hidden="true">↓</div>
<div class="jvi-stage is-code">
  <p class="jvi-stage-name">처리 방향 정하기<small>코드가 정한다</small></p>
  <ul class="jvi-rules">
    <li><span class="jvi-cond"><b>닫기</b>허가 없음 확률 <code>&lt; 0.15</code>, 기록이 설명함 <code>&gt; 0.50</code>, 도메인 컨트롤러가 아님</span><span class="jvi-acts"><span class="jvi-act is-close">AUTO CLOSE</span></span></li>
    <li><span class="jvi-cond"><b>조치</b>허가 없음 확률 <code>&gt; 0.75</code></span><span class="jvi-acts"><span class="jvi-act is-next">사고 상태 읽기로 ↓</span></span></li>
    <li><span class="jvi-cond"><b>그 사이</b>신원(identity) 알림이고 허가 없음 확률이 <code>0.15</code> 초과 <code>0.60</code> 이하이면 사용자에게 알림, 아니면 2차 분석가에게</span><span class="jvi-acts"><span class="jvi-act is-queue">NOTIFY USER</span><span class="jvi-act is-queue">ESCALATE TIER2</span></span></li>
  </ul>
</div>
<div class="jvi-down"><span aria-hidden="true">↓</span> <small>조치로 판정된 알림만</small></div>
<div class="jvi-stage is-model">
  <p class="jvi-stage-name">사고 상태 읽기<small>모델이 답한다</small></p>
  <ul class="jvi-qs is-two">
    <li><span class="jvi-type">Noul</span><span>자격 증명이 외부로 넘어갔는가<span class="jvi-qid">credentials_<wbr>exposed</span></span></li>
    <li><span class="jvi-type">Noul</span><span>공격자가 지금 세션이나 토큰을 쓰는가<span class="jvi-qid">session_<wbr>in_<wbr>attacker_<wbr>hands</span></span></li>
    <li><span class="jvi-type">Noul</span><span>악성 메일이 받은편지함에 있는가<span class="jvi-qid">malicious_<wbr>content_<wbr>in_<wbr>mailboxes</span></span></li>
    <li><span class="jvi-type">Noul</span><span>재부팅 뒤 되살아날 장치가 있는가<span class="jvi-qid">attacker_<wbr>persistence_<wbr>present</span></span></li>
    <li><span class="jvi-type">Noul</span><span>악성 프로세스가 지금 실행 중인가<span class="jvi-qid">malicious_<wbr>process_<wbr>running</span></span></li>
    <li><span class="jvi-type">Noul</span><span>공격자 쪽으로 트래픽이 나가는가<span class="jvi-qid">outbound_<wbr>channel_<wbr>active</span></span></li>
    <li><span class="jvi-type">Noul</span><span>공격자가 스스로 유지되는 설정을 바꿨는가<span class="jvi-qid">attacker_<wbr>modified_<wbr>configuration</span></span></li>
    <li><span class="jvi-type">Noul</span><span>끝난 일이 아니라 지금 진행 중인가<span class="jvi-qid">activity_<wbr>ongoing</span></span></li>
    <li><span class="jvi-type">Noul</span><span>처음 탐지된 대상 밖으로 퍼졌는가<span class="jvi-qid">spread_<wbr>beyond_<wbr>initial_<wbr>entity</span></span></li>
    <li><span class="jvi-type">Choice</span><span>어디까지 닿았나: 대상 하나, 작업 그룹, 조직 전체<span class="jvi-qid">affected_<wbr>scope</span></span></li>
    <li><span class="jvi-type">Choice</span><span>공격 종류: 호스트 장악, 계정 탈취, 메일 캠페인, 유출<span class="jvi-qid">attack_<wbr>type</span></span></li>
  </ul>
</div>
<div class="jvi-down" aria-hidden="true">↓</div>
<div class="jvi-stage is-code">
  <p class="jvi-stage-name">대응 고르기<small>코드가 정한다</small></p>
  <div>
    <p class="jvi-note">조건이 맞는 첫 그룹을 고르고, 그 안에서 조건이 맞는 가장 강한 동작을 고른다</p>
    <ul class="jvi-rules">
      <li><span class="jvi-cond"><b>1. 데이터가 나가는 중</b><code>outbound_<wbr>channel_<wbr>active &gt; 0.45</code></span><span class="jvi-acts"><span class="jvi-act is-heavy">BLOCK DESTINATION</span><span class="jvi-act is-light">BLOCK EGRESS ASSET</span></span></li>
      <li><span class="jvi-cond"><b>2. 공격자가 접근 권한을 가짐</b><code>session_<wbr>in_<wbr>attacker_<wbr>hands &gt; 0.50</code> 또는 <code>credentials_<wbr>exposed &gt; 0.40</code></span><span class="jvi-acts"><span class="jvi-act is-heavy">DISABLE ACCOUNT</span><span class="jvi-act is-heavy">REVOKE ACCESS KEY</span><span class="jvi-act is-heavy">REVOKE SESSIONS</span><span class="jvi-act is-light">REQUIRE REAUTH</span></span></li>
      <li><span class="jvi-cond"><b>3. 악성 메일이 배달됨</b><code>malicious_<wbr>content_<wbr>in_<wbr>mailboxes &gt; 0.50</code></span><span class="jvi-acts"><span class="jvi-act is-heavy">BLOCK SENDER</span><span class="jvi-act is-heavy">PURGE MAILBOXES</span><span class="jvi-act is-light">QUARANTINE MESSAGE</span></span></li>
      <li><span class="jvi-cond"><b>4. 호스트가 장악됨</b><code>attacker_<wbr>persistence_<wbr>present &gt; 0.60</code> 또는 <code>malicious_<wbr>process_<wbr>running &gt; 0.60</code></span><span class="jvi-acts"><span class="jvi-act is-heavy">ISOLATE HOST</span><span class="jvi-act is-light">KILL PROCESS</span><span class="jvi-act is-light">QUARANTINE FILE</span></span></li>
      <li><span class="jvi-cond"><b>5. 설정이 바뀜</b>전달 규칙, 위임, 동의를 제거</span><span class="jvi-acts"><span class="jvi-act is-light">REMOVE FORWARDING RULES</span></span></li>
      <li><span class="jvi-cond"><b>해당하는 그룹이 없음</b></span><span class="jvi-acts"><span class="jvi-act is-page">ESCALATE URGENT</span></span></li>
    </ul>
  </div>
</div>
<div class="jvi-legend">
  <span><span class="jvi-act is-close">Close</span>닫기</span>
  <span><span class="jvi-act is-queue">Queue</span>대기열</span>
  <span><span class="jvi-act is-page">Page</span>긴급 호출</span>
  <span><span class="jvi-act is-light">Light</span>가벼운 격리</span>
  <span><span class="jvi-act is-heavy">Heavy</span>강한 격리</span>
</div>
<figcaption>TypeSafe 블로그와 evals 사이트의 Security Incidents 워크플로를 다시 그렸습니다. 질문 문구는 필자가 한국어로 줄였고, 문턱값은 벤더가 공개한 예시 판정 기록에 나온 것만 적었습니다. 기록에 없는 조건(그룹 1과 3 안의 동작 선택, 그룹 5 진입 조건, 자산 등급의 쓰임)은 비워 두었습니다. 모델이 돌려주는 값 가운데 동작 이름은 하나도 없습니다.</figcaption>
</figure>

이 워크플로에서 눈여겨볼 것은 분업의 선이 어디에 그어졌는가입니다. 모델은 두 번의 요청에서 질문 14개에 답합니다. 그 답은 전부 알림과 사고의 **상태**에 대한 판정이고, 동작의 이름은 하나도 없습니다. 자동 종료(`AUTO CLOSE`)부터 긴급 에스컬레이션(`ESCALATE URGENT`)까지 17개의 동작은 전부 코드의 규칙이 고릅니다. 발표 글은 이 워크플로를 그림으로 소개한 뒤 이렇게 적었습니다.

> "The end result is discrete branching, but how we get to a final answer involves a lot of domain-specific engineering that needs to be done highly consistently."

도메인 지식이 들어간 자리는 모델 가중치가 아니라 질문 14개의 문장과 규칙 문자열들입니다. 앞에서 질문을 쓰는 일이 곧 도메인에 맞추는 일이라고 했는데, 실제 규모에서는 이런 모양이 됩니다.

### 한 케이스의 경로

공개된 예시 케이스 하나를 끝까지 따라가 보면 숫자 하나가 코드 분기를 타는 모양이 보입니다. 케이스 이름은 "Amsi.dll renamed as WinAppXRT"이고, 알림이 울린 자산은 운영 환경의 도메인 컨트롤러(`DC-NW-01`, tier 0)입니다. 아래 값은 평가 사이트에 기록된 Jev의 답입니다.

알림 읽기에서 `is_true_positive`는 0.82, `context_explains_activity`는 0.06이었습니다. 0.82가 0.75를 넘으니 처리 방향은 조치이고, 두 번째 요청이 나갑니다. 사고 상태 읽기의 답 중 대응 고르기에서 쓰인 값만 추리면 공격자 쪽 트래픽(`outbound_channel_active`) 0.16, 공격자의 세션 사용(`session_in_attacker_hands`) 0.24, 자격 증명 노출(`credentials_exposed`) 0.3, 악성 메일(`malicious_content_in_mailboxes`) 0.09, 재부팅 뒤에도 살아나는 장치(`attacker_persistence_present`) 0.68, 진행 중인 악성 프로세스(`malicious_process_running`) 0.18, 활동이 진행 중인가(`activity_ongoing`) 0.36입니다.

대응 고르기는 그룹을 앞에서부터 확인합니다. 데이터 유출 그룹은 0.16이 문턱 0.45에 못 미쳐 들어가지 않습니다. 접근 권한 그룹은 0.24와 0.3이 각각 문턱 0.50과 0.40에 못 미치고, 메일 그룹은 0.09가 0.50에 못 미칩니다. 호스트 그룹에서 0.68이 문턱 0.60을 넘어 처음으로 진입합니다. 그룹 안에서 가장 강한 호스트 격리는 `activity_ongoing`이 0.50을 넘어야 하는데 0.36이라 성립하지 않고, 프로세스 종료는 0.18이 0.60에 못 미쳐 성립하지 않습니다. 남은 파일 격리가 성립해서, 최종 동작은 `QUARANTINE FILE`입니다.

이 케이스는 벤더 평가에서 기준 답과 어긋난 사례라는 점도 함께 적어야 공정합니다. 기준 답은 두 대형 모델의 확률 평균으로 만든 합의였고, 그 답은 `ISOLATE HOST`였습니다. Jev를 포함해 비교된 세 모델이 모두 `QUARANTINE FILE`을 골랐습니다(평가 사이트 표기 "All three miss the reference").

그런데 입문자의 눈으로 이 케이스에서 볼 것은 맞고 틀림보다 어긋남이 어디서 났는지를 짚을 수 있다는 점입니다. Jev의 판정 기록에서 질문 11개 중 가장 강한 조치를 떨어뜨린 것은 `activity_ongoing`의 0.36과 규칙에 적힌 0.50, 이 두 숫자입니다. 다만 이 0.36만 0.50을 넘었다면 호스트 격리가 나왔을지는 공개 기록으로 알 수 없습니다. 같은 케이스에서 함께 비교된 Opus는 호스트 격리에 기록된 조건 두 개를 모두 넘었는데도(0.72와 0.6) 최종 동작이 파일 격리였습니다. 평가 사이트 흐름도의 "never a lone production system"처럼, 공개된 판정 기록에 없는 조건이 호스트 격리를 한 번 더 거르는 것으로 보입니다.

"이 알림에 어떻게 대응할까"를 한 질문으로 물었다면 돌아오는 것은 동작 이름 하나였을 것이고, 어긋났을 때 들여다볼 곳이 없었을 겁니다. 개발 가이드가 분해의 이점으로 든 "inspect, tune, and combine"이 이런 뜻이라고 저는 읽습니다.

결국 **질문을 설계하는 건 호출하는 쪽**이라는 말은 질문 문장만 가리키지 않습니다. 무엇을 물을지, 답의 후보를 무엇으로 둘지, 답을 어떤 규칙으로 합쳐 어느 동작으로 보낼지까지가 전부 호출하는 쪽의 설계입니다. 모델은 그 설계 안에서 상태를 판정할 뿐입니다.

## 맞는 자리와 맞지 않는 자리

벤더 문서에는 사용 사례 목록과 결정 모양 표, 실패 모드 표가 따로 있습니다. 그대로 옮기면 목록만 길어지는데, 제가 읽은 범위에서는 이 목록들이 앞의 두 절에서 본 성질로 정리됩니다. 답의 공간이 호출하는 쪽이 적은 후보로 닫혀 있다는 것, 그리고 한 질문이 아는 사람의 1초짜리 판단이라는 것입니다. 이 두 성질을 조건으로 놓고 보면, 조건 안에 드는 일에는 맞고 벗어나는 일에는 맞지 않습니다. **벤더가 이렇게 묶어 설명한 것은 아닙니다.** 벤더 문서의 권고들이 이 정리와 같은 방향을 가리킨다는 데서 끌어낸 제 해석입니다.

### 맞는 자리

맞는 자리를 한 줄로 요약한 문장은 발표 글의 비교표에 있습니다. Jev의 첫 용도로 든 "AI-Powered Workflows / smart if-statements" 항목의 설명입니다.

> "Structured outputs slot into ordinary software as fuzzy decision rules: classify, route, score, extract, or branch where hand-written logic is too brittle."

손으로 쓴 규칙으로는 너무 깨지기 쉬운 자리에 들어가는 흐릿한 결정 규칙이라는 뜻입니다. 사용 사례 문서의 결정 모양 표는 이 자리를 열 가지 모양으로 나눕니다.[^usecase] 대표적인 행만 원문 그대로 옮기면 이렇습니다.

| 결정 모양 | 이럴 때 (원문) | 예 (원문) |
|---|---|---|
| Classification | "One known category should win" | Intent, topic, department, risk type, entity type |
| Detection | "You need a probability that one property is present" | Spam, fraud, urgency, jailbreaks, sensitive data |
| Scoring | "The answer belongs on an ordered rubric" | Severity, relevance, quality, frustration, suitability |
| Routing | "A category selects the next code path" | Tool use, escalation, model routing, support queues |
| Verification | "An artifact must be checked for specific failure modes" | Citation support, policy violations, tool-call errors, response quality |

어느 행이든 답의 후보를 미리 적을 수 있고, 한 번의 판단이 짧습니다. 앞의 두 조건이 그대로 들어 있어요.

맞는 자리 중 입문자가 놓치기 쉬운 것은 LLM과의 관계입니다. Jev는 LLM을 밀어내는 자리보다 LLM의 앞이나 옆에 놓이는 자리가 많습니다. 결정 모양 표의 Routing 예에 "model routing"이 있고, 사용 사례 문서는 이를 "Use Jev to build a custom router that chooses which LLM receives each prompt."라고 설명합니다. 의도 라우팅 패턴은 같은 발상을 이렇게 적습니다.[^patterns]

> "Rather than sending every message through an expensive LLM to figure out what kind of request it is, you classify first and route accordingly."

패턴의 예제에서 주문 상태 문의는 결정적 코드로, 상품 질문과 반품 교환 문의는 전문 LLM으로, 확신도가 낮은 메시지는 사람에게 갑니다. Jev가 맡는 것은 어느 처리기로 보낼지라는 판단 하나이고, 답을 쓰는 일은 여전히 LLM의 몫입니다. LLM의 입력, 출력, 도구 호출을 검사하는 가드레일도 같은 자리입니다. 발표 글의 비교표가 "Verify everything"이라는 이름으로 든 용도입니다.

### 맞지 않는 자리

맞지 않는 자리는 벤더가 스스로 적은 것이 1차 근거입니다. 앞의 두 조건을 뒤집으면 답의 공간이 열린 일, 판단이 아닌 일, 1초를 넘는 판단이 나오고, 맞지 않는 자리는 대부분 이 안에서 설명됩니다.

**답의 공간이 열린 일**에는 맞지 않습니다. 가장 분명한 것이 문장 생성입니다. jaggedness 문서는 "`jev-1.13` is not trained to generate text."라고 적고, 코딩 에이전트에 관한 문서는 오해를 먼저 막습니다.[^coding-agents]

> "Jev is **not** a drop-in replacement for the LLM behind Claude Code, Cursor, opencode, Copilot, Muse Spark, Grok Bot, or similar tools. Instead, you can use your coding agent as usual to write code that uses Jev to make decisions."

같은 문서는 "There is no `model: "jev-latest"` setting that turns your coding agent into a Jev-powered agent, because the two systems solve different problems."라고 덧붙입니다. 코딩 에이전트의 모델 설정을 바꿔 끼우는 용도가 아니라, 코딩 에이전트로 Jev를 호출하는 코드를 짜는 관계라는 뜻이에요.

여기서 입문자가 오해하기 쉬운 단어가 하나 있습니다. 앞의 한 줄 요약에 나온 "extract"입니다. 생성형 모델이 문서에서 값을 뽑아 적어 주는 추출을 떠올리기 쉽지만, Jev의 추출은 다릅니다. jaggedness 문서의 권고입니다.

> "For data extraction, it is better to extract possible options using regex or a generative model and let `jev-1.13` pick the correct extraction."

후보는 정규식이나 생성형 모델이 먼저 뽑고, Jev는 그중 하나를 고릅니다. 문서 목록에 실린 "Pre-parsed value extraction" 예제의 설명도 정규식으로 이메일, 전화번호, 금액 후보를 찾은 뒤 요청한 구간을 TypeSafe가 고르게 한다고 적습니다.[^llms] 열린 추출을 닫힌 고르기로 바꾼 것이니, 추출조차 닫힌 답의 공간 안으로 들여온 셈입니다.

**판단이 아닌 일**에도 맞지 않습니다. jaggedness 문서의 실패 모드 표는 수와 숫자 계산에 "Keep the arithmetic in code", 날짜와 시간 비교에 "Extract components; compare in code"를 처방합니다. 세는 질문에 대한 문장이 이 경계를 가장 잘 보여 줍니다. "If the unit is something a regular expression or a parser can find, the count belongs in code and the model has nothing to add." 경비 정산 예제에서 $75 비교가 코드 쪽에 놓인 이유가 이것입니다.

**1초를 넘는 판단**도 맞지 않습니다. 같은 문서는 피할 것으로 "System Two tasks: more layers of indirections"를 들고, 한 단계 건너 추론해야 하는 질문에서 모델이 고전할 수 있다고 적습니다. 큰 `state`도 같은 계열입니다. 문서는 "Jev suffers from context rot, so unrelated material in the `state` costs you accuracy."라고 경고합니다.

소개 문서는 반대로 "adding more questions does not create context-rot"이라고 적어서 헷갈릴 수 있습니다. 두 문장은 모순이 아니라 대상이 다릅니다. 질문은 늘려도 되지만 `state`는 질문에 필요한 만큼으로 줄여야 합니다.

두 조건과 무관하게 붙는 제품 조건도 있습니다. 한국어로 서비스를 만드는 개발자라면 특히 언어 항목을 먼저 봐야 합니다.

- **입력은 텍스트뿐입니다.** 모델 문서는 "Pre-process non-text inputs (images, audio, video, binaries) into text or structured fields before sending them as `state`."라고 적습니다.
- **영어가 가장 정확합니다.** 원문은 "English is the primary training language and where accuracy is currently best. Other languages, including CJK scripts, are handled but not equally well"입니다. CJK에는 한국어가 들어가니, 한국어 입력의 정확도는 영어보다 낮을 수 있다고 벤더가 스스로 밝힌 셈입니다.
- **입력을 적대적으로 보지 않습니다.** jaggedness 문서는 "State is data, and `jev-1.13` does not treat it as hostile by default."라고 적고, 기준을 명시적으로 쓰고 배포 전에 충분히 시험하라고 권합니다.
- **공개 범위가 좁습니다.** 발표 글의 문구는 "Today, we are opening early access and bringing developers off the waitlist as quickly as we can."였습니다. API로만 쓸 수 있고 공개 가중치는 없습니다. 2026-09-29 조회 기준으로 공개된 모델은 `jev-1.13.0` 하나이고, 별칭 `jev-latest`와 `jev-preview`가 모두 이 버전을 가리킵니다. OpenRouter와 Vercel AI Gateway 같은 제3자 경로도 있습니다. 지금도 대기자 명단을 거쳐야 하는지는 확인하지 못했습니다.

## 정리하며

Jev는 **문장 대신 판단을 돌려받는 모델**입니다. 답을 쓰지 않고, 호출하는 쪽이 적어 보낸 후보 위에 확률을 매겨 돌려주며, 그 답은 파싱 없이 조건식으로 들어갑니다. 그 후보와 질문 문장, 답을 합치는 규칙, 규칙이 고르는 동작은 전부 코드에 있습니다. **질문을 설계하는 건 호출하는 쪽**이고, 보안 알림 예제에서 본 것처럼 도메인 지식이 놓이는 곳도 모델 가중치가 아니라 그 설계입니다. 두 성질을 겹치면 **맞는 자리와 맞지 않는 자리**가 갈립니다. 답의 공간을 닫을 수 있고 1초짜리 판단으로 쪼갤 수 있는 일에는 맞고, 생성과 계산, 긴 추론에는 맞지 않습니다.

입문의 끝에서 남는 질문은 돌려받은 숫자를 어디에 쓰느냐입니다. 보안 알림 예제의 0.75와 0.50은 누군가 정한 문턱이고, 확신도를 받으면 그다음 줄에는 `if confidence > x` 모양의 조건식이 생깁니다. 그 문턱을 무엇으로 재야 하는지, 그 숫자가 틀렸다는 걸 무엇이 알려 주는지, 확신도가 높으면 사람 확인 없이 실행해도 되는지는 이 글이 다루지 않았습니다. 그 질문들은 심화편 [「확률을 돌려받는 순간, 틀렸다는 걸 알아낼 책임도 넘어왔다」](/blog/2026/09/29/jev-system-one-model.html)가 이어받습니다.

이 글이 서 있는 시점도 적어 둡니다. 2026-09-29에 조회한 자료의 기록이고, 그때 공개된 모델은 `jev-1.13.0` 하나였습니다. 이 글이 인용한 jaggedness 문서도 "Last reviewed 2026-09-17" 판입니다. 모델 버전이 바뀌면 맞지 않는 자리의 목록은 달라질 수 있지만, 판단을 돌려받고 질문은 호출하는 쪽이 설계한다는 구조는 이 모델 부류의 정의에 속한다고 봅니다.

[^blog]: TypeSafe, "Introducing System One Models & Jev", 2026-09-15. [typesafe.ai](https://typesafe.ai/blog/introducing-system-one-models-and-jev). 2026-09-29 조회. 서두의 질문, 비교표("Frontiers, Old and New"), FAQ의 이름 유래, 얼리 액세스 문구, 보안 알림 워크플로 소개와 그 아래 문단은 모두 이 글에서 왔다.
[^system-one]: TypeSafe 문서, "System One". [docs.typesafe.ai](https://docs.typesafe.ai/concepts/system-one). 2026-09-29 조회. 정의는 .md 판 9행, LLM과의 공통점과 차이는 13행, 하지 않는 일은 23행, 이름의 유래는 36행, 사람이나 추론 모델로 넘기라는 문장은 49행.
[^intro]: TypeSafe 문서, "Introduction". [docs.typesafe.ai](https://docs.typesafe.ai/introduction). 2026-09-29 조회. 설계 동기는 .md 판 9행과 11행, 병렬 독립 평가와 질문 수에 관한 문장은 37행, "gut-check determination"은 41행.
[^quickstart]: TypeSafe 문서, "Quickstart". [docs.typesafe.ai](https://docs.typesafe.ai/introduction/quickstart). 2026-09-29 조회. SDK 코드는 .md 판 153~190행, 예시 요청과 응답은 65~136행.
[^api]: TypeSafe 문서, "API reference". [docs.typesafe.ai](https://docs.typesafe.ai/api). 2026-09-29 조회. 질문 키가 모델에 가지 않는다는 문장은 .md 판 36행, 확신도가 Choice와 Score에만 붙는다는 문장은 223행, Score 값 설명은 288행, Score 응답 예시는 309~323행.
[^primitives]: TypeSafe 문서, "Primitives". [docs.typesafe.ai](https://docs.typesafe.ai/primitives). 2026-09-29 조회. 질문 크기는 .md 판 250행, 가중치는 252행, 질문 ID 팁은 276행, 유형 선택 기준은 283~287행, Noul 0.5는 290행, 유형 고르기는 295행, 확신도 읽기는 303행, 독립성은 310행, 요청 나누기는 456~458행.
[^score]: TypeSafe 문서, "Score". [docs.typesafe.ai](https://docs.typesafe.ai/primitives/score). 2026-09-29 조회. 레벨 번호와 이웃 레벨이 모델에 보이지 않는다는 문장은 .md 판 744행.
[^confidence]: TypeSafe 문서, "Confidence". [docs.typesafe.ai](https://docs.typesafe.ai/confidence). 확신도 정의는 .md 판 149행. 2026-09-28 조회(심화편 노트에서 옮김).
[^jagged]: TypeSafe 문서, "Jev 1.13 jaggedness". [docs.typesafe.ai](https://docs.typesafe.ai/model-jaggedness/jev-1.13). 문서 표기 "Last reviewed 2026-09-17", 2026-09-29 조회. 실패 모드 표는 .md 판 17~27행, literal reading은 31행과 33행, 세는 질문은 43행, 적대적 입력은 106행과 108행, 생성과 추출은 141~143행, 피할 것 목록과 context rot는 145~151행.
[^models]: TypeSafe 문서, "Models". [docs.typesafe.ai](https://docs.typesafe.ai/models). 2026-09-29 조회. 버전과 별칭은 .md 판 11행과 33~37행, 텍스트 입력은 21행, 도메인 맞춤은 44~48행, 언어별 정확도는 52행.
[^howto]: TypeSafe 문서, "How to build with TypeSafe". [docs.typesafe.ai](https://docs.typesafe.ai/concepts/how-to-build-with-system-one). 2026-09-29 조회. 요약 상자는 .md 판 240~248행, AI-powered software 정의는 264행, 분해가 가장 중요하다는 문장은 404행, 스팸 판정 예시는 407~495행, 왕복이 늘지 않는다는 팁은 804~806행.
[^evals]: TypeSafe, workflow evals 사이트. [evals.typesafe.ai](https://evals.typesafe.ai/). 2026-09-29 조회. 경비 정산 장난감 예제는 "Decompose the work, build a harness" 절.
[^security]: TypeSafe, "Security Incidents" 워크플로. [evals.typesafe.ai](https://evals.typesafe.ai/security_incidents.html). 2026-09-29 조회. 질문 정의(`eval.questions`)와 규칙 문자열(`decisions.playbook.tests`), 예시 케이스의 답은 이 페이지가 불러오는 데이터 파일 `security_incidents-cases.js`에서 읽었다. 공개된 케이스 데이터는 예시 5건이고, 그 판정 기록에 나오지 않는 규칙(일부 그룹 안의 동작 조건 등)은 이 글에 숫자를 적지 않았다. 기준 답의 정의도 같은 데이터의 `references` 항목에 있다.
[^usecase]: TypeSafe 문서, "Use case map". [docs.typesafe.ai](https://docs.typesafe.ai/concepts/use-case-map). 2026-09-29 조회. 결정 모양 표는 .md 판 180~191행, 모델 라우팅 설명은 54~59행.
[^patterns]: TypeSafe 문서, "Intent routing". [docs.typesafe.ai](https://docs.typesafe.ai/patterns/intent-routing). 2026-09-29 조회. "Patterns" 문서(https://docs.typesafe.ai/patterns)의 패턴 네 개 중 하나다. 인용 문장은 .md 판 242행, 예제의 처리기 배정은 244~267행 흐름도.
[^coding-agents]: TypeSafe 문서, "Coding agents". [docs.typesafe.ai](https://docs.typesafe.ai/introduction/coding-agents). 2026-09-29 조회. 인용 문장은 .md 판 9행과 19행.
[^llms]: TypeSafe 문서 목록. [docs.typesafe.ai/llms.txt](https://docs.typesafe.ai/llms.txt). 2026-09-29 조회. "Pre-parsed value extraction" 쿡북 설명.
