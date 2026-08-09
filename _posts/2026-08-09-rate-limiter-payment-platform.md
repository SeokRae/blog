---
layout: post
date: 2026-08-09
title: "같은 30 TPS인데, 버스트는 30배가 됐다"
subtitle: "결제 플랫폼에 레이트리미터를 넣으며 배운 것"
tags: [레이트리미팅, 결제, 아키텍처, Java]
---

커밋 제목은 이랬다. "bucket4j(Java 11 바이트코드) → Guava RateLimiter(Java 8 호환) 교체."

읽으면 호환성 이슈로 보인다. 실제로 그게 맞다. 그런데 이 한 줄이 바꾼 건 라이브러리만이 아니었어요. 2주 전에 "버스트를 원천 차단한다"고 못 박아 뒀던 정책이, 이 커밋과 함께 "최대 1초치 버스트 허용"으로 뒤집혔습니다. 커밋 본문은 비어 있었습니다. 의도를 적어 둔 javadoc은 diff에서 통째로 사라졌고, 대체 설명도 붙지 않았어요.

레이트리미터를 알고리즘 비교표로 배웠다면 절대 못 봤을 사고입니다. 표에는 "Token Bucket: 버스트 허용"이라고만 적혀 있으니까요. 얼마나 허용하는지는 어디에도 없습니다.

그런데 이 사고의 진짜 문제는 버스트를 막느냐 허용하느냐가 아니었습니다. 그 값이 1이든 30이든, 누군가는 그 숫자를 의식적으로 쥐고 있어야 했어요. 문제는 그 통제권이 어느 순간 조용히 아무에게도 없는 상태가 됐다는 겁니다.

이 글은 결제 플랫폼을 만들면서 레이트리미터라는 개념이 어떻게 도착했고, 구현 과정에서 제가 뭘 잘못 알고 있었는지를 남기는 기록입니다.

## 개념은 필요해서가 아니라, 답할 수 없어서 도착했다

레이트리미터를 성능 문제로 발견한 게 아닙니다. 해외 결제 파트너가 보낸 기술 질의서 10문항을 받고 나서 발견했어요.

질문은 이런 것들이었습니다. 카테고리별 한도는 얼마인가. 한도는 무슨 단위로 적용되는가(API 키인가, 계정인가, IP인가). 라이브와 테스트 모드는 다른가. 초과하면 어떤 상태 코드로 응답하고 `Retry-After`를 주는가. 결제 라이프사이클 단계별로 처리량이 다른가. 부하 테스트를 해도 되는가. 한도를 공개하는가. 임시 증량이 가능한가, 리드타임은 얼마인가.

전부 대답할 수 있어야 하는 질문인데, 대답할 수 없었습니다.

가장 뼈아픈 건 "초과 시 동작" 항목이었어요. 답변서에 적힌 문장은 "현재 미구현"으로 시작합니다. 별도 처리가 없고 서버 부하가 넘치면 `503 Service Unavailable`로 응답한다고 썼습니다. 429 응답 샘플은 "향후 적용 예정"이라는 꼬리표를 달고 들어갔고요.

여기서 처음으로 429와 503의 차이를 진지하게 생각했습니다. 둘 다 "지금은 안 된다"인데 의미가 정반대입니다.

- **429**는 "당신이 너무 많이 보냈다"입니다. 호출자 책임이고, 백오프 후 재시도가 합리적입니다.[^rfc6585]
- **503**은 "우리가 지금 못 받는다"입니다. 서버 상태의 문제고, 호출자가 아무리 줄여도 안 될 수 있습니다.

호출자가 그다음에 뭘 해야 하는지가 완전히 달라지는데, 우리는 둘 다 503으로 응답하고 있었어요. 한도라는 개념이 없으니 "당신 몫을 다 썼다"는 말을 할 방법 자체가 없었던 겁니다.

일이 벌어진 순서를 확인하다가 조금 웃펐습니다. 사내 레이트 리밋 정책 문서의 작성일과, 파트너 질의서 답변의 기준일이 **같은 날**이었어요. 정책이 있어서 답변한 게 아니라, 답변하려고 정책을 만든 겁니다.

교훈은 이겁니다. **레이트 리미팅은 성능 문제로 발견되지 않습니다.** 파트너나 감사나 계약이 "숫자를 말해 보라"고 할 때 발견돼요. 대답할 수 있는지가 곧 설계가 있는지고요.

## 그런데 왜 하필 결제인가

"트래픽 많은 서비스면 다 필요한 것 아닌가"라고 생각했는데, 파고들수록 결제에는 이유가 세 개 더 있었습니다.

**1. 우리 한도의 상한은 우리 성능이 아니라 남의 한도다.**

정책 문서가 세운 공식은 단순합니다. `전체 처리량 = MIN(WEB 한계, WAS 한계, DB 한계, 외부 파트너 한계)`. 여기에 "외부 파트너 한계의 70%를 우리 내부 상한으로 설정"한다는 규정이 붙었습니다. 파트너의 429를 맞기 전에 우리가 먼저 막겠다는 버퍼예요.

문제는 그 공식에 넣을 입력값을 몰랐다는 겁니다. 파트너 유형별 표의 "예상 Rate Limit" 열이 세 행 모두 "파트너별 계약 확인 필요"로 비어 있었어요. 공식은 세웠는데 변수가 빈칸입니다.

**레이트 리밋 숫자의 1차 출처는 벤치마크가 아니라 계약서였습니다.** 우리 서버를 아무리 튜닝해도, 상대가 초당 몇 건까지 받아 주는지가 상한을 정합니다. 그 값은 코드가 아니라 협상 테이블에 있고요.

실제로 우리가 파트너 한도를 알아낸 경로도 문서가 아니었습니다. 429를 맞아 보고 알았어요. 답변서에 적힌 근거는 "초과 요청 시 429 응답 확인"이었고, 상태는 "협의 중"이었습니다.

**2. 인프라 탄력성이 낮으면 레이트리미터가 유일한 손잡이다.**

정책 문서에 스케일링 소요 시간 표가 있습니다.

| 방식 | 소요 시간 |
|---|---|
| Rate Limit 설정 변경 | 즉시(분 단위) |
| JVM 힙/스레드 풀 조정 + 재시작 | 5~15분 |
| 서버 VM 스케일업 | 1~2 영업일 |
| 신규 VM 추가(스케일아웃) | 3~5 영업일 |

온프레미스(IDC) 환경에서 신규 서버 추가는 ITSM 다단계 프로세스를 타야 합니다. 클라우드였으면 오토스케일이 소리 없이 흡수했을 스파이크를, 여기서는 레이트리미터가 받아내야 해요. **인프라 탄력성이 낮을수록 레이트리미터의 정책적 중요도가 올라갑니다.** 결제 시스템이 유독 온프레미스가 많다는 점과 정확히 겹치는 지점이었어요.

**3. 재시도 증폭이 결제에서 특히 비싸다.**

이전 글에서 커넥션 풀 고갈과 재시도 폭풍을 다룬 적이 있는데,[^prev-post] AWS Builders' Library가 그 메커니즘을 정확히 서술합니다. 클라이언트가 재시도하면 시스템에 걸리는 부하가 배수로 늡니다. 호출 그래프가 깊고 각 계층이 재시도를 하면 최하위 계층의 과부하는 지수적으로 증폭되고요. 그래서 "과부하가 스스로 피드백 루프를 만들어 정상 상태가 된다"고 씁니다.[^aws-shedding]

레이트 리미팅은 그 장애의 **앞단**입니다. 재시도 폭풍이 터진 뒤에 서킷 브레이커로 끊는 게 아니라, 애초에 폭풍이 생길 유량을 만들지 않는 쪽이에요.

### 규제 때문은 아니었다

결제 글에서 흔히 보는 서사가 있습니다. "규제 때문에 트래픽 제어가 필요하다"는 거요. 저도 처음엔 그렇게 짐작했는데, 확인해 보니 근거가 없었습니다.

전자금융감독규정(제2025-4호) 전문을 내려받아 전수 검색했습니다. `이상금융거래`, `이상거래`, `FDS`, `트래픽`, `DDoS`, `처리건수`, `가용성` 전부 **0회**입니다.[^efd] 성능 관련 조문은 제25조(정보처리시스템의 성능관리) 하나인데, 요구하는 건 "사용 현황 및 추이 분석 등을 정기적으로 실시"하는 것뿐이에요. 한도값도, 유량 제어 의무도 없습니다.

FDS의 실제 근거도 법령이 아니라 2023년 금융감독원과 금융보안원이 발표한 가이드라인이고, 내용은 부정 거래 탐지 룰셋입니다. 특금법의 CTR/STR은 금액 기준의 사후 보고 의무고요.

정리하면 이렇습니다. **FDS는 "누가 무슨 거래를 하는가"를 판단하는 도메인 통제고, 레이트 리미팅은 "시스템이 초당 몇 건을 감당하는가"를 지키는 엔지니어링 통제입니다.** 규제는 전자를 요구하고(그것도 상당 부분 자율 가이드라인 형태로), 후자는 규제가 아니라 위의 세 가지 이유에서 나옵니다. 둘을 규제 링크로 묶으면 사실과 달라져요.

감독규정만 봐서는 부족하니 상위 법률도 같은 방식으로 확인했습니다. 전자금융거래법 조문 전문(63개 조문)을 내려받아 전수 검색한 결과도 같아요. `이상금융거래`, `이상거래`, `FDS`, `트래픽`, `DDoS`, `처리건수`, `가용성`, `성능` 전부 **0회**입니다. `한도`는 10회 나오는데 전부 제23조(전자지급수단 등의 발행과 이용한도) 계열이고, 전자화폐 발행권면 최고한도나 전자자금이체 이용한도처럼 **금액** 한도입니다. 요청 빈도와는 무관해요. 안전성 확보 의무를 정한 제21조도 선량한 관리자의 주의와 금융위원회가 정하는 기준 준수를 요구할 뿐, 탐지나 유량 제어를 명시하지 않습니다.[^efa]

## 방향이 바뀌면 전략이 정반대가 된다

정책을 짜면서 가장 늦게 이해한 게 이겁니다. 같은 "rate limiting"인데 방향에 따라 정답이 반대예요.

정책 문서가 상황별 처리를 이렇게 갈랐습니다.

| 상황 | 처리 | 이유 |
|---|---|---|
| 인바운드 API 요청 한도 초과 | 즉시 429 반환 | 결제는 즉시성이 중요, 큐 대기 시 UX 저하 |
| 외부 파트너 일시 한도 초과 | 단기 큐잉(5초 미만) | 일시적 버스트 흡수 가능 |
| 외부 파트너 지속 장애 | 즉시 Circuit Open | 누적 큐가 시스템 과부하 유발 |

**인바운드는 거절하고, 아웃바운드는 대기합니다.**

이유를 알고 나면 당연합니다. 인바운드 리미터는 **나를 보호**해요. 남의 요청을 거절하면 내 자원이 지켜지니까 거절이 정답입니다. 아웃바운드 리미터는 **상대를 보호**합니다. 내가 보낼 요청을 내가 거절해 봐야 내 일이 안 끝나요. 그래서 기다리는 게 정답이 됩니다.

알고리즘 표를 외우기 전에 방향부터 정해야 했습니다. 이 글의 사고는 아웃바운드 쪽에서 났고요.

## 버스트를 0으로 만들려던 첫 구현

아웃바운드 레이트리미터의 최초 구현은 bucket4j였습니다. 설정은 이랬어요. 시크릿 키별로 독립 버킷을 두고, **버킷 용량 1**에 33밀리초마다 토큰 1개를 충전. 초당 30건이 됩니다.

여기서 Token Bucket을 최소한만 짚고 갑시다. 이 알고리즘의 스펙은 숫자 하나가 아니라 **두 개**입니다.

- **충전 속도(rate)**: 초당 몇 개의 토큰을 넣는가. 장기 평균 처리량을 결정합니다.
- **버킷 용량(capacity)**: 토큰을 최대 몇 개까지 쌓아 둘 수 있는가. **순간 버스트 허용치**를 결정합니다.

AWS API Gateway 문서가 이 둘을 각각 rate와 burst로 부르면서 "burst limit은 API Gateway가 429를 반환하기 전에 처리할 동시 요청 제출의 목표 최대치"라고 정의합니다.[^aws-apigw] 이름이 다를 뿐 같은 두 축이에요.

용량을 1로 잡은 건 의도적이었습니다. 당시 코드의 javadoc이 이유를 못 박아 뒀어요. 용량이 1이므로 토큰 누적 자체가 불가능하고, 따라서 버스트 없이 물리적으로 TPS 상한을 보장한다는 취지였습니다. 파트너 한도를 절대 넘지 않겠다는 목적에는 이게 맞습니다. 30건을 몰아서 보내면 그 순간 파트너 쪽에서는 초당 30건을 초과한 것으로 보일 수 있으니까요.

인터셉터도 함께 신경 썼습니다. 블로킹 대기 중 인터럽트가 오면 `Thread.currentThread().interrupt()`로 플래그를 복원하고 `IOException`으로 전환해 올렸어요. 대기 중인 스레드를 종료 시점에 회수할 수 있게요.

## 라이브러리를 바꾸자 정책이 바뀌었다

2주 뒤, 문제가 생겼습니다. 이 프로젝트는 `sourceCompatibility = '1.8'`, `targetCompatibility = '1.8'`이었는데 bucket4j가 Java 11 바이트코드로 빌드돼 있었어요. 런타임에서 안 돕니다.

대안을 찾아봤지만 다 막혔습니다. resilience4j는 2.0부터 Java 17을 요구하고, Java 8을 지원하는 마지막 버전은 2021년 6월 이후 릴리스가 끊겨 있었어요. 결국 이미 클래스패스에 있던 Guava의 `RateLimiter`로 갔습니다.

교체 후 코드는 한 줄로 줄었습니다.

```java
rateLimiters.computeIfAbsent(key, k -> RateLimiter.create(permitsPerSecond)).acquire()
```

깔끔해 보이죠. 그런데 `RateLimiter.create(double)`이 실제로 뭘 만드는지 Guava 31.1-jre 소스에서 확인하면 이렇습니다.

```java
RateLimiter rateLimiter = new SmoothBursty(stopwatch, 1.0 /* maxBurstSeconds */);
```

`SmoothBursty`. 이름에 버스트가 들어 있습니다. 이 클래스가 버스트 저장량을 계산하는 식은 `SmoothRateLimiter.java`에 있어요.

```java
maxPermits = maxBurstSeconds * permitsPerSecond;
```

같은 파일의 필드 주석이 이 값의 의미를 한 문장으로 설명합니다. "The work (permits) of how many seconds can be saved up if this RateLimiter is unused?"

즉 **몇 초치 작업을 쌓아 둘 수 있는가**입니다. 기본값 `maxBurstSeconds = 1.0`이므로, 초당 30건 설정에서 `maxPermits = 1.0 × 30 = 30`이 됩니다.

`create(double)`의 javadoc도 이걸 명시적으로 광고하고 있었어요.

> When the rate limiter is unused, bursts of up to `permitsPerSecond` permits will be allowed, with subsequent requests being smoothly limited at the stable rate of `permitsPerSecond`.

버스트 허용치가 **1에서 30으로, 30배 늘어난 겁니다.** 리미터가 잠시 유휴 상태였다면 30건이 한꺼번에 나갑니다. 평균 초당 30건이라는 설정값은 그대로인데요.

"버스트를 원천 차단한다"는 원래 설계는 **커밋 제목 어디에도 없이** 사라졌습니다. 본문은 비어 있고, 그 의도를 적어 둔 javadoc 단락은 diff에서 삭제됐으며, 새로 쓰인 javadoc은 버스트를 한 마디도 언급하지 않아요.

### 이건 Guava의 잘못이 아니다

여기서 중요한 지점이 있어요. Guava의 버스트 허용은 버그가 아니라 **의도된 기능**입니다. 소스 안에 그 설계 의도가 주석으로 남아 있습니다.

> The default RateLimiter configuration can save the unused permits of up to one second. This is to avoid unnecessary stalls in situations like this: A RateLimiter of 1qps, and 4 threads, all calling acquire() at these moments: T0 at 0 seconds, T1 at 1.05 seconds, T2 at 2 seconds, T3 at 3 seconds. Due to the slight delay of T1, T2 would have to sleep till 2.05 seconds, and T3 would also have to sleep till 3.05 seconds.

지터 때문에 요청이 0.05초 늦게 도착했을 뿐인데 그 이후의 모든 요청이 연쇄적으로 밀리는 걸 막으려는 설계입니다. 합리적이에요. 대부분의 용도에서는 이게 더 나은 동작입니다.

문제는 우리 목적이 "평균 처리량을 부드럽게 유지"가 아니라 **"파트너가 정한 한도를 어떤 순간에도 넘지 않는다"**였다는 겁니다. 이 목적에는 Guava의 기본값이 정면으로 반해요.

**두 라이브러리가 모두 "rate limiter"이고 모두 "초당 30건"을 설정할 수 있는데, 버스트 허용치는 30배 달랐습니다.** 그 차이는 어느 쪽 문서에도 "주의"라고 적혀 있지 않아요. 각자의 문서에는 각자의 정상 동작으로 적혀 있을 뿐입니다.

### 인터럽트도 조용히 사라졌다

교체 diff는 인터셉터의 try/catch도 함께 지웠습니다. Guava의 `acquire()`가 검사 예외를 던지지 않으니 컴파일 에러를 없애려면 지우는 게 맞아요. 그런데 그 이유가 컴파일 때문이라는 게 함정입니다.

Guava의 `acquire(int)`는 대기 시간을 계산한 뒤 이렇게 잡니다.

```java
stopwatch.sleepMicrosUninterruptibly(microsToWait);
```

`Uninterruptibly`. 인터럽트를 받지 않고 잡니다. 실제 구현은 `Uninterruptibles.sleepUninterruptibly(micros, MICROSECONDS)`예요.

그러니까 컴파일 에러가 사라진 이유는 "예외가 안 나서"가 아니라 **"인터럽트를 받는 기능 자체가 없어서"**입니다. 대기 중인 스레드를 더 이상 깨울 수 없어요. 애플리케이션 종료나 요청 취소 시점에 회수가 안 됩니다.

같은 코드베이스가 HTTP 커넥션 풀에는 "풀 고갈 시 무한 대기 대신 빠른 실패"를 적용해 놨는데(커넥션 요청 타임아웃 5초), 레이트리미터에는 상한 없는 블로킹이 남았습니다. 방어의 일관성이 깨진 지점이에요.

덧붙이면 Guava의 `RateLimiter`에는 `@Beta` 애노테이션이 붙어 있습니다. Guava에서 `@Beta`는 API 호환성을 보장하지 않는다는 표시예요. 프로덕션 결제 경로의 유량 제어를 `@Beta` 클래스에 맡기고 있다는 사실도 그때는 몰랐습니다.

## 알고리즘 표를 외웠어도 이 사고는 못 막았다

사고를 겪고 나서 알고리즘 문헌을 다시 봤습니다. 결론부터 말하면, 표에서 봐야 할 건 알고리즘 이름이 아니라 **열 이름**이었어요.

| 알고리즘 | 키당 상태 | 메모리 | 정확도 | 버스트 |
|---|---|---|---|---|
| Token Bucket | 토큰 수 + 최종 갱신 시각 | O(1) | 정확 | 허용(용량만큼) |
| Leaky Bucket (meter형) | TAT 또는 (X, LCT) | O(1) | 정확 | 설정에 따름 |
| Leaky Bucket (queue형) | 큐 | O(큐 길이) | 정확 | 흡수 후 평활화 |
| Fixed Window Counter | 정수 1개 + TTL | O(1) | 경계에서 최대 2배 통과 | 경계에서 스파이크 |
| Sliding Window Log | 요청마다 타임스탬프 | O(n) | 정확 | 정확히 차단 |
| Sliding Window Counter | 카운터 2개 또는 60개 | O(1) | 근사 | 평활화 |

이 표에서 실무적으로 판단이 갈리는 지점만 짚습니다.

**고정 윈도우의 경계 문제는 구체적입니다.** Figma가 계산까지 붙은 예를 남겼어요. 분당 5건 한도에서 "사용자가 11:00:59에 5건을 보냈다면, 매 분 시작마다 새 카운터가 시작되므로 11:01:00에 5건을 더 보낼 수 있다"고요. 그래서 "때때로 허용 건수의 두 배를 통과시킬 수 있다"고 씁니다.[^figma] 다만 Cloudflare는 같은 문제를 인정하면서도 "순진한 고정 윈도우 알고리즘도 사실 그렇게 나쁘지 않다"고 쓰기도 했어요.[^cloudflare] 나쁜 알고리즘이라기보다, **경계 스파이크를 감당할 수 있는 자리인지**가 판단 기준입니다.

**슬라이딩 윈도우 로그는 정확한데 비쌉니다.** Figma의 계산: 사용자 1만 명이 각각 500건을 보내면 타임스탬프당 4바이트만 잡아도 약 20MB입니다. 요청마다 값을 저장하니까요.

**슬라이딩 윈도우 카운터는 근사인데, 그 오차가 실측돼 있습니다.** Cloudflare가 27만 개 출처에서 온 4억 요청을 분석해서 "0.003%의 요청이 잘못 허용되거나 잘못 제한됐다"고 발표했어요. 상태량은 "카운터당 숫자 두 개"뿐입니다.[^cloudflare]

그런데 여기서 이름의 함정이 또 나옵니다. **같은 "슬라이딩 윈도우 카운터"인데 Figma의 구현은 다릅니다.** Figma는 카운터 2개가 아니라 윈도우를 60등분한 서브윈도우 60개를 Redis 해시에 담아요. 메모리는 약 2.4MB로 로그 방식의 1/8 수준이고요. 오차는 의도적으로 **한쪽 방향으로 몰았습니다.** "약간 관대한 대신 조금 더 엄격한 쪽"을 택했다고 씁니다.[^figma] Cloudflare의 오차는 양방향인데 Figma의 오차는 한 방향이에요. 같은 이름, 다른 계약입니다.

**그리고 Leaky Bucket은 아예 두 개입니다.** 위키백과가 이 혼동을 직접 서술해요. 문헌에 이 비유를 적용하는 서로 다른 두 방법이 있고, 둘 다 leaky bucket 알고리즘이라 불리며, 대개 서로를 언급하지 않은 채로 쓰인다고. 그래서 "leaky bucket 알고리즘이 무엇이고 어떤 속성을 갖는지에 대한 혼동을 낳았다"고 적혀 있습니다. 게다가 계량기(meter)형 leaky bucket은 **Token Bucket의 거울상으로 정확히 등가**라고 명시합니다.[^leaky]

그러니까 흔히 보는 "Token Bucket vs Leaky Bucket" 비교 자체가 부정확할 수 있어요. meter형이면 둘은 같은 것이고, 실제 대비는 queue형(대기시켜 평활화)과의 대비입니다.

실물에서도 이름과 동작이 어긋납니다. Shopify는 자기 방식을 "leaky bucket"이라 부르지만 초과분을 큐에 넣지 않고 429로 거절해요.[^shopify] 동작만 보면 meter형입니다.

정리하면, 제가 겪은 사고와 이 문헌들이 말하는 문제가 같습니다. **레이트 리미팅은 용어가 유독 헐겁습니다.** 이름을 믿지 말고 세 가지를 확인해야 해요.

1. **버스트를 얼마나 허용하는가** (용량, `maxBurstSeconds` 같은 기본값 포함)
2. **초과하면 거절하는가 대기하는가**
3. **키당 상태를 얼마나 들고 있는가**

두 라이브러리 모두 "rate limiter"였고, 제가 확인하지 않은 건 1번이었습니다.

### 하나 고르는 게 아니라 위치별로 다르게

또 하나 늦게 이해한 건, 알고리즘 하나를 골라 전사에 적용하는 게 아니라는 점입니다. 정책 문서는 위치별로 다르게 배치했어요.

| 알고리즘 | 특성 | 적용 위치 |
|---|---|---|
| Token Bucket | 버스트 허용, 평균 속도 제한 | API Gateway (기본) |
| Sliding Window | 정밀한 윈도우 제어 | 결제 생성 엔드포인트 |
| Fixed Window | 단순, 오버헤드 낮음 | 모니터링/관리 API |

기본을 Token Bucket으로 둔 근거는 이거였습니다. 결제 트래픽에는 자연스러운 버스트가 발생하므로 순간 초과는 허용하되 평균 속도를 제한하는 방식이 적합하다고요.

그런데 이 근거를 다시 읽으면 위의 사고와 정확히 겹칩니다. **인바운드에서는 버스트 허용이 장점이고, 아웃바운드에서는 그게 그대로 리스크입니다.** 방향이 반대니까요. 같은 알고리즘, 같은 성질, 정반대 평가. 한 문서 안에서 이걸 구분해 적어 두지 않으면 다음 사람이 헷갈립니다. 제가 헷갈렸어요.

## 알고리즘보다 먼저 정해야 하는 것 두 가지

사고 이후로 우선순위가 바뀌었습니다. 알고리즘은 셋째였어요.

### 1. 어디에 거는가

아웃바운드 인터셉터의 적용 조건은 딱 한 줄이었습니다. 요청 URL의 호스트가 특정 파트너 도메인으로 끝나는지 확인하고, 맞으면 리미터를 통과시키는 식이에요.

문제는 **같은 `RestTemplate`을 다른 파트너 호출도 공유**한다는 겁니다. 인터셉터 체인은 로깅, 서킷 브레이커, 레이트리미터 순인데, 호스트 조건이 걸린 건 레이트리미터뿐이에요. 그래서 다른 파트너로 나가는 호출은 이 보호를 전혀 받지 않습니다.

사내 위험 카탈로그 문서는 이 한계를 스스로 적어 뒀습니다. 현재 상태 스냅샷 표에도 대량 export 기능의 "호출 간 페이싱" 칸이 "없음"이었고요. 정작 한 번에 수십 건을 순차 발사하는 경로에는 리미터가 안 걸려 있었던 거예요.

**완벽한 알고리즘도 안 걸린 경로는 못 막습니다.** Token Bucket이냐 Sliding Window냐를 고민하기 전에, 적용 범위부터 그렸어야 했습니다.

### 2. 키를 무엇으로 하는가

교과서는 "키별로 카운터를 유지한다"까지만 말합니다. 그 키가 뭔지는 각자 정하라고 하고요.

우리 아웃바운드 리미터는 API 시크릿 키를 키로 썼습니다. `ConcurrentHashMap`에 시크릿 키를 그대로 담고 있었어요. 두 가지 문제가 동시에 생깁니다.

- **보안**: 시크릿이 평문으로 힙에 남습니다. 힙 덤프를 뜨면 그대로 보여요.
- **용량**: 맵이 무한히 자랍니다. 만료가 없으니 한 번 본 키는 영원히 남습니다.

세 번째 커밋이 이걸 고쳤습니다. 키를 SHA-256으로 해싱하고, `ConcurrentHashMap` 대신 Caffeine 캐시에 상한과 만료를 걸었어요. 최대 1000개, 마지막 접근 후 1시간 만료.

이 계약은 테스트로 잠갔습니다. 리플렉션으로 캐시 키를 꺼내 64자리 16진수 패턴에 맞는지, 원래 시크릿 문자열과 다른지를 검증해요. 이건 잘한 판단이었다고 생각합니다. 나중에 누군가 성능을 이유로 해싱을 걷어내면 테스트가 먼저 깨집니다.

**키 카디널리티(무한 증가하면 TTL과 상한이 필요하다)와 키 민감도(시크릿이면 해싱이 필요하다)는 알고리즘 선택과 완전히 독립적인 설계 축이었습니다.** 어떤 알고리즘 비교표에도 이 열은 없어요.

## 레이트리미터가 하지 않는 일

리서치하면서 제가 갖고 있던 오해 하나가 깨졌습니다.

### 중복 결제를 막지 않는다

"레이트리미터를 걸면 더블클릭 중복 결제도 막히는 것 아닌가"라고 생각했는데, 아닙니다. **레이트리미터는 멱등성 계층보다 앞에서 돌아갑니다.**

Stripe의 저수준 에러 문서에 이 순서가 명시돼 있어요. 429로 제한된 요청은 같은 멱등키를 써도 다른 결과를 낼 수 있는데, 레이트리미터가 API의 멱등성 계층보다 먼저 실행되기 때문이라고요. 4xx 에러에 대해서는 **같은 키 재사용이 아니라 새 멱등키 생성**을 가장 안전한 전략으로 권합니다.[^stripe-lowlevel]

이게 왜 중요하냐면, 429로 잘린 요청은 애초에 서버 로직에 도달하지 않았다는 뜻입니다. 중복 여부를 판단할 정보 자체가 리미터에는 없어요. 요청을 **보기 전에** 자르니까요.

관찰 사실 하나를 덧붙이면, Stripe의 레이트 리밋 문서는 중복 방지를 **한 번도 언급하지 않습니다.** 명시된 목적은 API 안정성 극대화와 남용 방지예요. 중복 방지는 멱등성 문서에만 등장하고, 거기서는 "연결 오류가 발생했을 때 두 번째 객체를 만들 위험 없이 안전하게 재요청하기 위한 것"이라고 정의합니다.[^stripe-idempotent] 더블클릭 방어의 정석으로 제시하는 것도 레이트 리밋이 아니라 **장바구니 ID 같은 사용자 귀속 객체에서 키를 파생하는 것**이고요.

이 지점에서 우리 시스템의 구멍이 보였습니다. 우리는 멱등키가 없어서 **비멱등 POST를 아예 재시도하지 않습니다.** 재시도 정책이 멱등성으로 갈려 있어요. 조회(GET)는 최대 3회 재시도하지만, 통보나 보상 같은 POST는 재시도 없이 즉시 예외로 올립니다.

그러니까 429를 받아도 재시도할 선택지가 없어요. **레이트 리미팅을 제대로 하려면 멱등성이 먼저 필요했습니다.** 순서를 거꾸로 밟은 셈입니다.

### 429와 503은 다른 도구다

AWS Builders' Library가 이 구분을 가장 선명하게 씁니다. Amazon에서는 서비스가 가용 영역 장애를 흡수할 만큼 여유 용량을 유지하고, **스로틀링은 클라이언트 간 공정성을 보장하기 위해** 쓴다고요. 반면 로드 셰딩은 서버가 과부하에 다가갈 때 초과 요청을 거절해 **받아들이기로 한 요청의 지연을 낮게 유지**하는 자기 보호입니다.[^aws-shedding]

Stripe도 같은 구분을 두고 리미터를 4종 운영한다고 공개했어요. 요청 속도 리미터, 동시 요청 리미터, 로드 셰더 두 종입니다. 그중 **로드 셰딩에는 503을 반환**한다고 명시해요. 예약 비율이 20%면 80% 할당을 넘어선 비핵심 요청은 503으로 거절된다고요.[^stripe-limiters]

여기서 앞의 이야기로 돌아옵니다. 우리는 429가 미구현이라 둘 다 503이었어요. **같은 503인데 의미가 정반대입니다.** Stripe의 503은 "우선순위가 낮은 요청을 의도적으로 버렸다"는 판단이고, 우리의 503은 "한도라는 개념이 없어서 그냥 부하가 넘쳤다"는 상태였습니다.

같은 문서에서 결제에 그대로 옮길 수 있는 대목도 발견했습니다. 우선순위를 API 의미론 기준으로 매기라는 조언인데, 예시가 `start()`와 `end()`입니다. 이 경우 `end()`를 `start()`보다 우선해야 한다고요. `start()`를 우선하면 클라이언트가 시작한 작업을 끝낼 수 없어서 브라운아웃이 난다는 이유입니다.[^aws-shedding]

결제로 옮기면 **과부하 시 승인보다 취소와 확정을 우선해야 합니다.** 승인만 받아 주고 취소를 막으면 미결 거래가 쌓여요. 우리 정책은 "결제 조회는 결제 생성의 3배 허용"까지는 갔지만, 취소와 환불의 우선순위는 없었습니다.

### 속도 제한은 네 개 방어 중 하나다

사내 위험 카탈로그가 위험 유형과 대응을 이렇게 짝지어 뒀습니다.

| 위험 | 정의 | 대응 |
|---|---|---|
| Burst | 한 액션이 N회 호출을 지연 없이 순차 실행 | 아웃바운드 TPS 레이트리미터 |
| Concurrency Multiplication | 같은 burst가 여러 탭, 세션, 사용자로 겹침 | 동시성 세마포어, 클라이언트 single-flight |
| Retry Storm | 실패를 백오프 없이 즉시 무한 재시도 | 백오프 재시도 정책 |
| 무기억 재트리거 | 직전 실패를 다음 실행이 모름 | 서킷 브레이커 |

특히 좋았던 구분이 마지막 항목입니다. 재시도 폭풍과 달리, 이건 **하나의 함수 호출 안에서의 자동 재시도가 아니라 사용자가 매번 새로 트리거하는 별도의 실행**이 문제라고 정의해요. 직전 실행이 파트너 장애로 실패했다는 사실을 다음 실행이 전혀 모르면, 파트너가 아직 복구되지 않았는데도 매번 처음부터 다시 burst를 보냅니다.

그리고 하나 더. **"초당 몇 건"(속도)과 "동시에 몇 개"(동시성)는 다른 축입니다.** 초당 30건을 정확히 지켜도 각 요청이 3초 걸리면 동시에 90개가 떠 있어요. 레이트리미터 하나로 다 막으려 하면 나머지 셋을 놓칩니다.

## 순서가 곧 의미다

작은 발견인데 인상적이었던 게 하나 있습니다. 인터셉터 체인에서 **서킷 브레이커가 레이트리미터보다 앞**에 있어요. 코드 주석이 이유를 적어 뒀습니다. 서킷이 열려 있으면 레이트리미터의 permit을 소비하지 않고 즉시 차단하려고요.

순서를 뒤집으면 이미 죽은 파트너를 향해 permit을 태우면서 대기하게 됩니다. 두 장치는 같은 체인에 있고, **배치 순서 자체가 semantics**였어요.

다만 여기서 다시 걸리는 게 있습니다. 이 서킷 브레이커는 5xx 응답과 IOException만 실패로 집계하고, 4xx는 파트너가 응답한 것으로 간주해 실패로 세지 않습니다. 그런데 **429는 4xx예요.** 레이트리미터가 못 막은 초과분이 429로 돌아와도 서킷은 열리지 않는 구간이 생깁니다.

구현을 열어 보니 실제로는 한 걸음 더 갑니다. 인터셉터의 분기가 "상태 코드가 500 이상이면 실패 기록, 아니면 성공 기록"이라는 이분법이라서, 429는 실패로 안 세는 정도가 아니라 **성공으로 기록됩니다.** 성공 기록은 연속 실패 카운터를 0으로 되돌리고요. 파트너가 5xx를 간헐적으로 던지는 와중에 429가 하나 섞이면, 그때까지 쌓인 실패 카운트가 초기화됩니다. 서킷이 안 열리는 게 아니라, 열릴 뻔한 것도 되돌리는 셈이에요.

## 다시 한다면

- **버스트 허용치를 설정으로 노출하고 테스트로 잠근다.** 이 사고의 원인은 버스트가 라이브러리 기본값에 숨어 있었다는 겁니다. 값이 코드에 명시돼 있었다면 교체 diff에서 보였을 거예요. 시크릿 키 해싱을 테스트로 잠근 것처럼, 버스트 허용치도 잠갔어야 했습니다.
- **커밋 제목이 "교체"면 본문에 "무엇이 달라지는가"를 쓴다.** 교체 커밋의 본문이 비어 있었던 게 결정적이었어요. 의도를 적어 둔 javadoc을 지웠으면 그 자리에 새 의도를 적어야 했고요. 이 블로그에서 반복해 온 결론이 "'왜'를 기록하라"인데, 이번엔 **적혀 있던 '왜'를 지운 것**이 사고였습니다.
- **아웃바운드 대기에 상한과 취소 경로를 남긴다.** 커넥션 풀에는 빠른 실패를 걸어 놓고 레이트리미터에는 무제한 블로킹을 남긴 건 일관성이 아니에요. Guava에 `tryAcquire(timeout, unit)`이 있으니 최소한 상한은 걸 수 있습니다.
- **429를 에러율과 분리해 계측한다.** 부하 테스트 계획서를 보면 Spike Test의 **통과 기준**이 "429 정상 반환, 복구 시간 30초 미만"입니다. 거절이 정상 동작이에요. 그런데 거절을 에러율에 넣고 보면 레이트리미터를 켤수록 지표가 나빠집니다. 위의 서킷 브레이커가 4xx를 실패로 안 세는 것과 같은 발상인데, 대시보드에는 그 구분이 없었습니다.
- **실측으로 알아낸 한도에는 출처와 측정 시점을 함께 적는다.** 코드 javadoc과 대외 답변서에 적힌 파트너 한도 숫자가 서로 달랐습니다. 한쪽은 단정형이고 한쪽은 실측 후 협의 중이었어요. 설정값을 그보다 보수적으로 잡은 것 같은데, 왜 그 값인지에 대한 기록이 없습니다. 지금은 아무도 어느 쪽이 맞는지 모릅니다.
- **분산 환경에서 실효 한도를 다시 계산한다.** 정책 문서는 Redis를 상태 저장소로 쓰는 분산 카운터를 키 설계와 TTL까지 그려 뒀는데, 구현은 전부 단일 JVM 로컬 리미터(Guava + Caffeine)였습니다. 저장소 전체를 뒤져 보니 Redis 클라이언트 의존성 자체가 없어요. 분산 설계는 문서에만 있고 코드에는 도착하지 않은 겁니다. 인스턴스가 N대면 실효 한도도 N배가 됩니다. 파트너 한도의 70%를 지키겠다고 세운 버퍼가, 인스턴스를 늘리는 순간 소리 없이 사라져요.
- **재시도 백오프에 지터를 넣는다.** 우리 재시도 정책은 1초, 2초, 4초 고정입니다. AWS가 정리한 Full Jitter는 `sleep = random_between(0, min(cap, base * 2 ** attempt))`인데,[^backoff] 고정 백오프는 실패한 클라이언트들을 같은 시점에 다시 모아서 두 번째 파도를 만들어요.

## 무엇을 배웠는가

이 사고를 겪기 전까지 저에게 레이트 리미팅은 "초당 몇 건"이라는 숫자 하나였습니다. 알고리즘 비교표도 그렇게 읽었어요. Token Bucket은 버스트 허용, Fixed Window는 경계 문제, 이런 식으로요.

지금은 이렇게 정리합니다.

**"몇 TPS인가"는 스펙의 절반입니다. 나머지 절반은 "버스트를 얼마나 허용하는가"입니다.** 두 라이브러리가 똑같이 30 TPS를 광고해도 버스트 허용치는 30배 다를 수 있고, 그 차이는 어느 쪽 문서에도 경고로 적혀 있지 않습니다. 각자에게는 정상 동작이니까요.

그리고 알고리즘 선택이 트레이드오프라는 말의 진짜 의미도 다르게 다가옵니다. 표를 보고 신중히 고르는 상황을 상상했는데, 실제로는 **런타임 버전이 라이브러리를 고르고, 라이브러리가 알고리즘을 고르고, 알고리즘이 정책을 고쳤습니다.** 순서가 반대였어요. Java 8 제약 때문에 bucket4j가 탈락하고, resilience4j가 탈락하고, 남은 Guava가 버스트 정책을 대신 정해 줬습니다. 세 번 연속으로 알고리즘 문헌이 아니라 바이트코드 버전이 결정권을 쥐고 있었습니다.

그러니까 트레이드오프를 고르는 것보다 먼저 해야 할 일은, **지금 무엇이 나 대신 골라져 있는지 확인하는 것**입니다. 라이브러리 기본값이 곧 정책이니까요.

마지막으로 하나. 이 글의 사고는 코드 리뷰에서 잡히지 않았습니다. diff만 보면 라이브러리 임포트가 바뀌고, 한 줄이 짧아지고, try/catch가 사라진 게 전부예요. 하나같이 "정리된 것처럼" 보입니다. **삭제된 javadoc 세 줄만 읽었다면 잡혔을 겁니다.** 리뷰에서 추가된 코드는 다들 열심히 보는데, 삭제된 주석은 잘 안 봐요. 이번에 거기에 정책이 들어 있었습니다.

[^rfc6585]: 429 Too Many Requests의 정본은 RFC 6585 §4다. "The 429 status code indicates that the user has sent too many requests in a given amount of time ('rate limiting')." 참고로 `Retry-After`는 **MAY**이지 필수가 아니다("MAY include a Retry-After header"). `Retry-After` 자체의 정의는 RFC 9110 §10.2.3에 있다. 다만 그 절이 예로 드는 건 503과 3xx뿐이고, RFC 9110 전문에는 `429`라는 문자열이 한 번도 등장하지 않는다(429는 RFC 6585 소관이다). 원문: "Servers send the "Retry-After" header field to indicate how long the user agent ought to wait before making a follow-up request." 출처: [RFC 6585](https://www.rfc-editor.org/rfc/rfc6585), [RFC 9110 §10.2.3](https://www.rfc-editor.org/rfc/rfc9110.html#name-retry-after)
[^prev-post]: [장애의 원인은 다양해도, 대응이 늦어지는 이유는 하나다]({{ site.baseurl }}/2026/07/24/incident-response-pipeline.html)
[^aws-shedding]: David Yanacek, "Using load shedding to avoid overload", Amazon Builders' Library. 인용문 원문: "At Amazon, services maintain enough excess capacity to handle Availability Zone failures without having to add more capacity. They use throttling to ensure fairness among clients." / "an overload in the bottom layer causes cascading retries that amplify the offered load exponentially" 출처: [PDF](https://d1.awsstatic.com/builderslibrary/pdfs/using-load-shedding-to-avoid-overload.pdf)
[^efd]: 전자금융감독규정(제2025-4호) 전문(약 116KB)을 내려받아 전수 검색한 결과다. 제25조 원문: "금융회사 또는 전자금융업자는 정보처리시스템의 장애예방 및 성능의 최적화를 위하여 정보처리시스템의 사용 현황 및 추이 분석 등을 정기적으로 실시하여야 한다." 출처: [전자금융감독규정 (제2025-4호)](https://ko.wikisource.org/wiki/전자금융감독규정_(제2025-4호))
[^efa]: 전자금융거래법(법률 제21205호, 2025년 12월 16일 공포) 전문을 국가법령정보센터 오픈 API로 내려받아 전수 검색한 결과다. 조문 63개, 추출 텍스트 약 136KB. 제21조(안전성의 확보의무) 제1항 원문: "금융회사등은 전자금융거래가 안전하게 처리될 수 있도록 선량한 관리자로서의 주의를 다하여야 한다." 제2항은 "금융위원회가 정하는 기준을 준수하여야 한다"로 이어지며, 그 기준이 곧 위의 전자금융감독규정이다. 출처: [전자금융거래법 (국가법령정보센터)](https://www.law.go.kr/법령/전자금융거래법)
[^aws-apigw]: "API Gateway throttles requests to your API using the token bucket algorithm, where a token counts for a request." / "the burst limit represents the target maximum number of concurrent request submissions that API Gateway will fulfill before returning 429 Too Many Requests error responses." 문서는 스로틀과 쿼터 모두 "best-effort basis"이며 "targets rather than guaranteed request ceilings"라고 덧붙인다. 출처: [AWS API Gateway: Throttle API requests](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-request-throttling.html)
[^figma]: "An alternative approach to rate limiting", Figma. 고정 윈도우 원문: "can sometimes let through twice the number of allowed requests per minute." 슬라이딩 윈도우 로그 원문: "leaves a considerably large memory footprint because it stores a value for every request." Figma의 구현: "count requests from each sender using multiple fixed time windows 1/60th the size of our rate limit's time window", 오차 방향은 "a tad harsher instead of slightly lenient". 출처: [Figma Blog](https://www.figma.com/blog/an-alternative-approach-to-rate-limiting/)
[^cloudflare]: "How we built rate limiting capable of scaling to millions of domains", Cloudflare, 2017-06-07. 오차 실측: "an analysis on 400 million requests from 270,000 distinct sources shown" / "0.003% of requests have been wrongly allowed or rate limited". 고정 윈도우 평가: "The naive fixed window algorithm is actually not that bad". 2017년 시점의 서술이며, 현행 Cloudflare 문서는 알고리즘명을 밝히지 않는다. 출처: [Cloudflare Blog](https://blog.cloudflare.com/counting-things-a-lot-of-different-things/)
[^leaky]: "Two different methods of applying this leaky bucket analogy are described in the literature. (…) This has resulted in confusion about what the leaky bucket algorithm is and what its properties are." / "The leaky bucket as a meter is exactly equivalent to (a mirror image of) the token bucket algorithm". 최초 출처는 J. Turner, "New directions in communications (or which way to the information age?)", *IEEE Communications Magazine* 24(10), 1986, pp. 8–15, ISSN 0163-6804, [doi:10.1109/MCOM.1986.1092946](https://doi.org/10.1109/MCOM.1986.1092946). 출처: [Wikipedia: Leaky bucket](https://en.wikipedia.org/wiki/Leaky_bucket)
[^shopify]: "Each app has access to a bucket. It can hold, say, 60 'marbles'. (…) Each second, a marble is removed from the bucket (if there are any)." 그리고 "All requests that are made after rate limits have been exceeded are throttled and an HTTP 429 Too Many Requests error is returned." 출처: [Shopify API rate limits](https://shopify.dev/docs/api/usage/limits)
[^stripe-lowlevel]: "a request that's rate limited with a 429 can produce a different result with the same idempotency key because rate limiters run before the API's idempotency layer. (…) Even so, the safest strategy where 4xx errors are concerned is to always generate a new idempotency key." 출처: [Stripe: Low-level error handling](https://docs.stripe.com/error-low-level)
[^stripe-idempotent]: "The API supports idempotency for safely retrying requests without accidentally performing the same operation twice. (…) if a connection error occurs, you can safely repeat the request without risk of creating a second object or performing the update twice." 더블클릭 방어에 관한 문장은 같은 문서가 아니라 저수준 에러 문서에 있다: "Derive the key from a user-attached object, like the ID of a shopping cart. This provides a relatively straightforward way to protect against double submissions." 출처: [Stripe: Idempotent requests](https://docs.stripe.com/api/idempotent_requests), 더블클릭 방어 인용은 [Stripe: Low-level error handling](https://docs.stripe.com/error-low-level)
[^stripe-limiters]: "Scaling your API with rate limiters", Stripe. "We use the token bucket algorithm to do rate limiting." 4종 구성과 로드 셰딩 응답 코드: "If our reservation number is 20%, then any non-critical request over their 80% allocation would be rejected with status code 503." 운영 조언도 참고할 만하다: "Dark launch each rate limiter to watch the traffic they would block" / "Make sure you have kill switches to disable the rate limiters should they kick in erroneously." 출처: [Stripe Blog](https://stripe.com/blog/rate-limiters)
[^backoff]: Marc Brooker, "Exponential Backoff And Jitter", AWS Architecture Blog, 2015-03-04. Full Jitter는 `sleep = random_between(0, min(cap, base * 2 ** attempt))`. 결론: "The 'Full Jitter' approach uses less work, but slightly more time. Both approaches, though, present a substantial decrease in client work and server load." 출처: [AWS Architecture Blog](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)
