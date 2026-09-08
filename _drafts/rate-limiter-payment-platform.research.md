# 리서치: Rate Limiter — 결제 플랫폼에서 개념이 필요해진 순간

**slug**: `rate-limiter-payment-platform`
**수집일**: 2026-08-09
**발행본**: `_posts/2026-08-09-rate-limiter-payment-platform.md`

---

## 이 파일의 범위

이 노트는 발행본 각주 14개의 **근거 사슬**이다. 본문의 외부 인용을 누구나 되짚을 수 있게 하는 것이 목적이고, 그래서 `## 검증 기록`만 담는다 (#16).

내부 근거는 사내 결제 플랫폼 저장소에서 나왔고 여기에 옮기지 않았다. 회사와 PG사 실명, 도메인, 패키지와 클래스 실명, 사내 이슈 번호, 계약 수치가 그 대상이다. 원본은 같은 디렉터리의 `rate-limiter-payment-platform.sources-internal.md`에 있고, `.gitignore`의 `_drafts/*` 규칙에 걸려 추적되지 않는다. 사내 근거를 되짚어야 하면 그 파일을 본다.

**남긴 것과 지운 것의 기준**: 발행본에 이미 공개된 것은 남기고(30 TPS, Guava, bucket4j, 인용한 공개 문서), 발행본에 없는 사내 식별자는 지웠다. 경로와 클래스명이 있던 자리에는 역할 이름을 넣었다.

**각주 대응**: 발행본 각주 14개 중 13개가 아래 검증 기록에 대응한다. `[^rfc6585]`→V-9, `[^efa]`→V-1, `[^efd]`→V-20, `[^aws-shedding]`→V-10, `[^aws-apigw]`→V-11, `[^figma]`→V-13, `[^cloudflare]`→V-14, `[^leaky]`→V-7과 V-12, `[^shopify]`→V-15, `[^stripe-lowlevel]`→V-16, `[^stripe-idempotent]`→V-17과 V-6, `[^stripe-limiters]`→V-19, `[^backoff]`→V-5. 남은 `[^prev-post]`는 이 블로그의 선행 포스트를 가리키는 내부 링크라 외부 검증 대상이 아니다.

⚠️ 이 노트는 발행 후에 분리했다. 발행 시점(2026-08-09)에는 익명화 분리 규약이 아직 없었고, 규약은 2026-08-11에 확정돼 `test-standards` 편부터 적용됐다.

---

## 검증 기록

> 작성: blog-verifier, 2026-08-09. **확정 포함 전 항목**을 남긴다(#16 재발 방지 — 초안의 `<!-- 검증: -->` 주석은 publisher가 발행 시 제거하므로 근거 사슬은 여기에만 남는다).
> 결과 요약: **확정 13건 / 오류 교정 4건 / 확인 불가 0건.** writer의 `(확인 필요)` 3건은 모두 해소됐다.

### A. writer가 남긴 `(확인 필요)` 3건

#### V-1. 전자금융거래법 조문 전문에 트래픽 제어·FDS 의무가 있는가 → **확정 (부재)**

- **서지/출처**: 전자금융거래법, 법률 제21205호, 공포 2025-12-16, 소관 금융위원회. 국가법령정보센터(law.go.kr) 공식 오픈 API. 조회 URL 2건
  - 최신 공포본: `https://www.law.go.kr/DRF/lawService.do?OC=test&target=law&LM=전자금융거래법&type=XML` (시행일자 2026-12-17, XML 218,586 bytes)
  - 현행 시행본: 같은 엔드포인트에 `target=eflaw` (시행일자 2025-12-16, XML 207,632 bytes)
- **확인 방법**: 두 XML을 `xml.etree.ElementTree`로 파싱해 전 노드의 text/tail을 이어붙여 평문 추출(각각 135,772 / 125,601 bytes, 조문 63개). 추출 텍스트에 대해 키워드 전수 카운트. **두 버전 모두 동일 결과**다.
  - `이상금융거래` 0 / `이상거래` 0 / `FDS` 0 / `사기` 0 / `트래픽` 0 / `DDoS` 0 / `디도스` 0 / `분산서비스거부` 0 / `서비스거부` 0 / `처리건수` 0 / `처리량` 0 / `가용성` 0 / `초당` 0 / `유량` 0 / `접속량` 0 / `과부하` 0 / `성능` 0 / `속도` 0 / `탐지` 0 / `모니터링` 0 / `용량` 0 / `자금세탁` 0
  - `한도`만 10회. 문맥을 전부 열어 확인한 결과 **전부 금액 한도**다 — 제23조(전자지급수단 등의 발행과 이용한도)의 "전자화폐 및 선불전자지급수단의 발행권면 최고한도", "전자자금이체의 이용한도", "직불전자지급수단의 이용한도", "현금 출금 최고한도", 그리고 소액후불결제의 "이용한도, 총제공한도". 요청 빈도와 무관.
  - 제21조(안전성의 확보의무) 전문 확인. 제1항 원문: "금융회사등은 전자금융거래가 안전하게 처리될 수 있도록 선량한 관리자로서의 주의를 다하여야 한다." 제2항은 인력·시설·전자적 장치·소요경비 등에 관해 "금융위원회가 정하는 기준을 준수하여야 한다"로 위임. **FDS도 유량 제어도 명시하지 않는다.**
  - ⚠️ 첫 추출 시도는 정규식 `<[^>]+>`로 태그를 지우다가 `<![CDATA[ … ]]>` 블록을 통째로 삼켜(12KB만 남음) 전 키워드가 0으로 나왔다. 파서 기반으로 재추출해 136KB를 확보한 뒤 다시 세었다. **0회라는 결론은 재추출본 기준이다.**
- **본문 대비 정합성**: 초안의 원래 문장은 플래그(미검색 고지)였고, 이를 검증된 부재 서술로 대체했다. 본문은 "0회"와 "금액 한도"까지만 말하고 "그러므로 규제가 rate limiting을 금지/불요한다"로 넘어가지 않으므로 근거보다 강하지 않다. 새 각주 `[^efa]` 추가.

#### V-2. 서킷 브레이커가 4xx를 실패로 세지 않아 429 폭주 시 서킷이 안 열린다 → **확정, 그리고 근거가 본문보다 강함**

- **서지/출처**: 사내 저장소 실물 코드 2개 파일
  - `사내 저장소의 서킷 브레이커 인터셉터`
  - `사내 저장소의 서킷 브레이커 구현체`
- **확인 방법**: 사내 문서의 **서술**까지만 확인한 상태였다. 이번에 구현체를 직접 열어 상태 코드 분기를 읽었다. **사내 코드이므로 원문을 인용하지 않고 구조만 옮긴다.**
  - 인터셉터는 응답 상태 코드를 `>= 500` 하나로만 가른다. 5xx면 실패로 기록하고, **그 밖의 모든 코드(2xx와 4xx 전부)는 성공으로 기록**한다.
  - 성공 기록은 연속 실패 카운트와 OPEN 상태, half-open 시험 플래그를 전부 초기화한다.
  - javadoc이 그 의도를 명시한다. 4xx를 성공으로 세는 것은 "파트너가 응답했다"는 뜻이라는 서술이다.
  - 실패 임계치와 쿨다운도 함께 확인했다. 임계치 기본 5회, OPEN 지속 기본 30,000ms (서킷 브레이커 구현체).
- **본문 대비 정합성**: 초안의 원래 서술("4xx는 실패로 세지 않는다 → 서킷이 열리지 않는 구간이 생긴다")은 **맞지만 약했다.** 분기가 `>= 500`의 이분법이라 429는 미집계가 아니라 **성공으로 기록**되고, 성공 기록은 누적 연속 실패를 0으로 되돌린다. 즉 5xx가 섞여 쌓이던 카운트도 429 하나로 초기화된다. 본문에 이 사실을 추가하고 근거 주석을 달았다. 추가한 서술은 코드가 직접 뒷받침하는 범위를 넘지 않는다(운영에서 실제로 그렇게 리셋된 사건이 있었다는 주장은 하지 않음 — §4-4의 "사고 기록 없음" 제약 유지).

#### V-3. 정책 문서의 Redis 기반 분산 리미터가 실제로 구현됐는가 → **확정 (미구현)**

- **서지/출처**
  - 설계 측: 사내 레이트리밋 정책 문서 §1-3 "Redis 기반 분산 Rate Limiting". 원문에 "Redis를 Rate Limit 상태 저장소로 사용한다", 키 설계 `rate_limit:{api_key}:{window}` , TTL "윈도우 크기 × 2", "Redis 장애 시 로컬 카운터로 Fallback", WAS 1..N → Redis(Master-Replica) 다이어그램까지 포함.
  - 구현 측: 아웃바운드 레이트리미터 (Guava `RateLimiter` + Caffeine), 아웃바운드 레이트리미터 인터셉터
- **확인 방법**: "찾지 못했다"를 "없다"로 올리기 위해 3중으로 확인했다.
  1. 사내 저장소 전체 재귀 grep — `RedisTemplate|RedisRateLimit|StringRedisTemplate|data-redis|lettuce|jedis|RedisScript|redisson`, 대상 확장자 `*.java,*.gradle,*.yml,*.yaml,*.xml,*.properties`, 빌드산출물(`/build/`, `/bin/`)과 `.git` 제외 → **0건**
  2. 전 모듈 `build.gradle`의 의존성 선언에 redis 좌표 **0건**. 빌드 스크립트가 선언한 건 `com.github.ben-manes.caffeine:caffeine:2.9.3`와 `com.google.guava:guava:31.1-jre`뿐이고 주석까지 "(Java 8 호환)"이라 붙어 있다.
  3. 리미터 클래스 전수 확인 — `find -iname "*RateLimit*" -o -iname "*Throttl*"` 결과 소스 파일은 위 2개뿐. 미병합 브랜치 하나의 트리도 `git ls-tree -r`로 확인했으나 추가 리미터 파일 없음.
  - ⚠️ 오탐 1건 기록: 정적 리소스의 JS 파일 하나가 "redis"에 걸리는데 실제 문자열은 `allow-redisplay`다. Redis와 무관.
  - 다른 프로젝트의 설계 문서에는 Redis가 등장하지만 **이 결제 모듈과 무관**하며 역시 문서 레벨이다.
- **본문 대비 정합성**: "찾지 못했을 뿐 없다고 확정하지 못했다"를 "의존성 자체가 없다"로 승격했다. "인스턴스가 N대면 실효 한도가 N배"는 로컬 리미터의 정의상 성립하는 조건문이며, **실제로 N대로 운영 중이라는 주장은 하지 않았다**(멀티 인스턴스 배포 여부는 확인하지 않음 — 아래 미해소 항목 참조).

### B. 플래그 밖에서 발견해 교정한 사실 오류 4건

#### V-4. RFC 9110 §10.2.3이 "429와 503에 가장 유용하다"고 적혀 있다 → **오류. 교정함**

- **서지/출처**: RFC 9110, "HTTP Semantics", R. Fielding·M. Nottingham·J. Reschke 편, June 2022, STD 97. 전문 `https://www.rfc-editor.org/rfc/rfc9110.txt` (502,941 bytes).
- **확인 방법**: 전문을 내려받아 정규화 후 전수 검색. **`"429"` 0회, `"most useful"` 0회.** §10.2.3 실제 원문은 "Servers send the "Retry-After" header field to indicate how long the user agent ought to wait before making a follow-up request. When sent with a 503 (Service Unavailable) response, Retry-After indicates how long the service is expected to be unavailable to the client. When sent with any 3xx (Redirection) response, Retry-After indicates the minimum time that the user agent is asked to wait before issuing the redirected request." — 언급되는 상태 코드는 **503과 3xx뿐**이다. ABNF `Retry-After = HTTP-date / delay-seconds`도 확인.
- **본문 대비 정합성**: 노트 §2-8이 기록한 인용문("The "Retry-After" response header field indicates…" / "is most useful with 503 … and 429 … responses")은 **RFC 9110 원문이 아니다**(구 RFC 7231 계열 표현이나 2차 자료로 추정). 초안 각주 `[^rfc6585]`가 이를 그대로 옮겼기에, RFC 9110이 실제로 말하는 범위로 교정하고 "RFC 9110 본문에 429는 등장하지 않는다"는 사실을 덧붙였다. 429의 정본이 RFC 6585 §4라는 본문의 다른 주장은 아래 V-7에서 별도 확정.

#### V-5. AWS Full Jitter 공식 `sleep = random(0, …)` → **오류(함수명). 교정함**

- **서지/출처**: Marc Brooker, "Exponential Backoff And Jitter", AWS Architecture Blog, 2015-03-04.
- **확인 방법**: 페이지 HTML을 내려받아 확인하니 **의사코드가 텍스트로 존재하지 않는다**(`<pre>` 태그 0개, `random(` 0회, `sleep =` 0회). 코드가 이미지로 실려 있었다. "Adding jitter is a small change to the sleep function:" 바로 뒤의 코드 이미지 `exponential-backoff-and-jitter-blog-figure-6.png`(860×44)를 직접 내려받아 판독한 결과 원문은

  ```
  sleep = random_between(0, min(cap, base * 2 ** attempt))
  ```

  함수명이 `random`이 아니라 **`random_between`**이다. 산문 결론 "The "Full Jitter" approach uses less work, but slightly more time. Both approaches, though, present a substantial decrease in client work and server load."와 "Equal Jitter is the loser."는 텍스트로 확인됨.
- **본문 대비 정합성**: 본문과 각주 양쪽의 공식을 원문 표기로 교정했다. 의미는 동일하나 이 글 자체가 "인용을 다듬으면 그 자리에서 결론을 어긴다"(`CLAUDE.md` #30)를 주제로 삼고 있어 그대로 둘 수 없다.
- **파생 확인**: 노트 §2-14의 Decorrelated Jitter 표기(`sleep = min(cap, random(0, sleep * 3))`)도 같은 이유로 신뢰할 수 없다. **본문이 인용하지 않으므로 교정 대상은 아니나, 향후 인용 금지.**

#### V-6. Stripe 더블클릭 방어 인용의 출처 → **오류(출처 귀속). 교정함**

- **서지/출처**: 인용문 "Derive the key from a user-attached object, like the ID of a shopping cart. This provides a relatively straightforward way to protect against double submissions."
- **확인 방법**: 두 페이지를 각각 열어 대조했다. `https://docs.stripe.com/api/idempotent_requests`에는 이 문장이 **없고**, 키 생성 조언은 "How you create unique keys is up to you, but we suggest using V4 UUIDs, or another random string with enough entropy to avoid collisions."에서 끝난다. 문제의 문장은 `https://docs.stripe.com/error-low-level`의 "Sending idempotency keys" 절에 있다(같은 절의 "There are two common strategies for generating idempotency keys" 목록 두 번째 항목).
- **본문 대비 정합성**: 각주 `[^stripe-idempotent]`가 두 인용을 한 URL에 묶어 놨기에, 앞 인용(멱등성 정의)은 그대로 두고 더블클릭 문장만 출처를 분리 표기했다. 본문 서술("더블클릭 방어의 정석으로 제시하는 것도 레이트 리밋이 아니라 장바구니 ID 같은 사용자 귀속 객체에서 키를 파생하는 것")은 사실 그대로 유지.

#### V-7. Turner 1986 서지 축약 → **교정(보강)함**

- **서지/출처 (전체)**: J. Turner, "New directions in communications (or which way to the information age?)", *IEEE Communications Magazine*, vol. 24, no. 10, pp. 8–15, October 1986. Publisher: Institute of Electrical and Electronics Engineers (IEEE). ISSN 0163-6804. DOI **10.1109/MCOM.1986.1092946**.
- **확인 방법**: DOI content negotiation — `curl -H "Accept: application/vnd.citationstyles.csl+json" https://doi.org/10.1109/MCOM.1986.1092946`. Crossref가 반환한 CSL JSON에서 `author=[{given:"J.", family:"Turner"}]`, `container-title="IEEE Communications Magazine"`, `volume=24`, `issue=10`, `page="8-15"`, `published-print=1986-10`, `ISSN=["0163-6804"]`, `type="journal-article"`, `is-referenced-by-count=679` 확인. DOI는 `http://ieeexplore.ieee.org/document/1092946/`로 302 해석되어 실재도 확인됨.
- **본문 대비 정합성**: 초안 각주 `[^leaky]`가 제목의 부제를 잘라내고("New directions in communications") 페이지·DOI를 누락했기에 전체 서지로 보강했다. 이 문헌이 leaky bucket의 최초 출처라는 **귀속 자체는 위키백과의 서술을 옮긴 것**이며(아래 V-12), 논문 본문을 직접 열어 확인하지는 않았다. 본문도 "최초 출처는 …"이라는 위키백과발 서술 이상으로 나가지 않는다.

### C. 본문의 나머지 외부 인용 (근거 사슬 게이트 — 전수)

> 아래는 초안 본문·각주에 남은 외부 인용 전부다. 각 항목을 원문에 대해 **문자열 완전 일치**로 재대조했다(따옴표·대시·공백 정규화만 적용).

#### V-8. Guava `RateLimiter` / `SmoothRateLimiter` (이 글의 핵심 근거) → **확정**

- **서지/출처**: Google Guava 31.1-jre, `guava-31.1-jre-sources.jar` (로컬 Gradle 캐시 `~/.gradle/caches/modules-2/files-2.1/com.google.guava/guava/31.1-jre/c388a68bc2b17a314dfa7c769d858ada0fc32dcf/`). 추출본: 스크래치패드 `guava-src/com/google/common/util/concurrent/{RateLimiter,SmoothRateLimiter}.java` (파일 타임스탬프 2022-02-28 — 31.1 릴리스 시기와 일치).
- **확인 방법**: 소스 파일에서 줄 번호까지 직접 확인.
  - `RateLimiter.java:135` — `RateLimiter rateLimiter = new SmoothBursty(stopwatch, 1.0 /* maxBurstSeconds */);` ✅ (초안 코드블록과 일치)
  - `RateLimiter.java` `create(double)` javadoc — "When the rate limiter is unused, bursts of up to {@code permitsPerSecond} permits will be allowed, with subsequent requests being smoothly limited at the stable rate of {@code permitsPerSecond}." ✅ (초안은 `{@code X}`를 백틱으로 렌더 — javadoc 마크업의 정상 표기)
  - `RateLimiter.java:117-129` 설계 의도 주석 — "The default RateLimiter configuration can save the unused permits of up to one second. This is to avoid unnecessary stalls in situations like this: A RateLimiter of 1qps, and 4 threads, all calling acquire() at these moments: T0 at 0 seconds / T1 at 1.05 seconds / T2 at 2 seconds / T3 at 3 seconds. Due to the slight delay of T1, T2 would have to sleep till 2.05 seconds, and T3 would also have to sleep till 3.05 seconds." ✅ (원문은 T0~T3가 줄바꿈된 목록. 초안은 한 문단으로 이어 붙였으나 어절 누락·변형 없음)
  - `SmoothRateLimiter.java:278` 필드 주석 — "The work (permits) of how many seconds can be saved up if this RateLimiter is unused?" ✅
  - `SmoothRateLimiter.java:289` — `maxPermits = maxBurstSeconds * permitsPerSecond;` ✅
  - `RateLimiter.java:95, 98` — `@Beta` 애노테이션이 클래스 선언에 실재 ✅ (초안의 "@Beta가 붙어 있다" 확정)
  - `RateLimiter.java:305, 421` — `stopwatch.sleepMicrosUninterruptibly(microsToWait);`, `:486` — `Uninterruptibles.sleepUninterruptibly(micros, MICROSECONDS);` ✅
  - `RateLimiter.java:351` — `public boolean tryAcquire(long timeout, TimeUnit unit)` 실재 ✅ ("다시 한다면"의 `tryAcquire(timeout, unit)` 권고가 성립)
- **본문 대비 정합성**: 초안의 산술 "maxPermits = 1.0 × 30 = 30"은 위 두 사실(기본 `maxBurstSeconds=1.0`, `maxPermits = maxBurstSeconds * permitsPerSecond`)의 직접 대입이다. **30 TPS는 사내 설정 기본값**(사내 애플리케이션 설정)이지 파트너 계약 한도가 아니며 본문도 그렇게만 서술한다.

#### V-9. RFC 6585 §4 (429의 정본) → **확정**

- **서지/출처**: RFC 6585, "Additional HTTP Status Codes", M. Nottingham·R. Fielding, April 2012, Standards Track. 전문 `https://www.rfc-editor.org/rfc/rfc6585.txt`.
- **확인 방법**: 전문을 내려받아 §4 전체를 육안 확인 + 문자열 일치. "The 429 status code indicates that the user has sent too many requests in a given amount of time ("rate limiting")." ✅ / "The response representations SHOULD include details explaining the condition, and **MAY** include a Retry-After header indicating how long to wait before making a new request." ✅ — `Retry-After`가 MAY이지 필수가 아니라는 초안 서술과 일치.
- **본문 대비 정합성**: 일치. ⚠️ 사소한 표기 — 원문은 `("rate limiting")`로 큰따옴표인데 초안 각주는 한국어 문장의 큰따옴표와 겹치지 않게 `('rate limiting')`로 중첩 표기했다. 의미 변화 없음.

#### V-10. AWS Builders' Library, 로드 셰딩 → **확정**

- **서지/출처**: David Yanacek, "Using load shedding to avoid overload", Amazon Builders' Library. PDF `https://d1.awsstatic.com/builderslibrary/pdfs/using-load-shedding-to-avoid-overload.pdf` (379,754 bytes). PDF 표지에 저자명과 "Copyright © 2019 Amazon Web Services, Inc." 확인.
- **확인 방법**: `pdftotext`로 추출 후 문자열 일치.
  - "They use throttling to ensure fairness among clients" ✅
  - "an overload in the bottom layer causes cascading retries that amplify the offered load exponentially" ✅
  - "an overload creates its own feedback loop that results in overload as a steady state" ✅
  - "the service should prioritize end() requests over start() requests" ✅
- **본문 대비 정합성**: 네 인용 모두 본문 서술과 일치. 본문의 "결제로 옮기면 과부하 시 승인보다 취소와 확정을 우선해야 합니다"는 AWS의 `start()`/`end()` 조언을 **필자가 결제 도메인으로 옮긴 해석**이며, 본문도 "결제로 옮기면"이라고 명시해 원문 주장과 구분하고 있다. 노트 §2-13의 URL 주의(본문 HTML은 301+JS라 PDF를 쓸 것)는 이번에도 유효했다.

#### V-11. AWS API Gateway 스로틀링 → **확정**

- **서지/출처**: "Throttle API requests for better throughput", AWS API Gateway Developer Guide. `https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-request-throttling.html`
- **확인 방법**: 페이지 내려받아 문자열 일치. "token bucket algorithm, where a token counts for a request" ✅ / "the target maximum number of concurrent request submissions" ✅ / "targets rather than guaranteed request ceilings" ✅
- **본문 대비 정합성**: 본문은 rate와 burst가 Token Bucket의 두 축과 이름만 다를 뿐 같다는 근거로만 쓴다. 원문의 best-effort 단서도 각주에 함께 실려 있어 근거보다 강하지 않다.

#### V-12. Wikipedia "Leaky bucket" → **확정**

- **서지/출처**: `https://en.wikipedia.org/wiki/Leaky_bucket` (원문 위키텍스트를 `action=raw`로 취득, 39,211 bytes).
- **확인 방법**: 문자열 일치.
  - "This has resulted in confusion about what the leaky bucket algorithm is and what its properties are" ✅
  - "The leaky bucket as a meter is exactly equivalent to (a mirror image of) the token bucket algorithm" ✅ — ⚠️ 최초 대조에서 실패로 나왔는데, 원문이 `(a mirror image of) the [[token bucket]] algorithm`처럼 위키 링크 마크업을 품고 있었기 때문이다. 마크업 제거 후 완전 일치. 초안이 마크업 없이 인용한 것은 정상.
  - "Two different methods of applying this leaky bucket analogy are described in the literature" ✅
- **본문 대비 정합성**: 일치. 본문의 "흔히 보는 'Token Bucket vs Leaky Bucket' 비교 자체가 부정확할 수 있어요"는 meter형 등가 문장에서 나오는 직접 귀결이다. ⚠️ 출처가 위키백과(3차 자료)라는 점은 본문에 "위키백과가 이 혼동을 직접 서술해요"로 드러나 있어 독자가 오인할 여지는 없다.

#### V-13. Figma 블로그 → **확정**

- **서지/출처**: "An alternative approach to rate limiting", Figma Blog. `https://www.figma.com/blog/an-alternative-approach-to-rate-limiting/`
- **확인 방법**: 페이지 내려받아 문자열 일치 7건 전부 ✅
  - "twice the number of allowed requests" / "5 more requests at 11:01:00" / "it stores a value for every request" / "20 MB" / "1/60th the size of our rate limit's time window" / "2.4 MB" / "a tad harsher instead of slightly lenient"
- **본문 대비 정합성**: 일치. 본문이 Cloudflare(양방향 오차)와 Figma(한 방향 오차)를 "같은 이름, 다른 계약"으로 대비한 것은 두 원문 표현("wrongly allowed **or** rate limited" vs "a tad harsher")에서 직접 나온다.

#### V-14. Cloudflare 블로그 → **확정**

- **서지/출처**: "How we built rate limiting capable of scaling to millions of domains", Cloudflare Blog, 2017-06-07. `https://blog.cloudflare.com/counting-things-a-lot-of-different-things/`
- **확인 방법**: 문자열 일치 4건 전부 ✅ — "400 million requests from 270,000 distinct sources" / "0.003% of requests have been wrongly allowed or rate limited" / "The naive fixed window algorithm is actually not that bad" / "only two numbers per counter"
- **본문 대비 정합성**: 일치. 본문·각주 모두 "2017년 시점의 서술"이라고 시점을 밝히고 있어, 노트 §4-3의 미해소 항목(현행 Cloudflare 알고리즘 미공개)과 충돌하지 않는다.

#### V-15. Shopify API 한도 → **확정**

- **서지/출처**: "Shopify API rate limits", `https://shopify.dev/docs/api/usage/limits`
- **확인 방법**: 문자열 일치. "All Shopify APIs use a leaky bucket algorithm to manage requests" ✅ / "Each app has access to a bucket. It can hold, say, 60 "marbles"." ✅ / "Each second, a marble is removed from the bucket (if there are any)." ✅ / 429 반환 서술 ✅
- **본문 대비 정합성**: 일치 — Shopify가 자칭 leaky bucket이면서 초과분을 큐잉하지 않고 429로 거절한다는 본문 서술이 원문에서 그대로 확인된다. ⚠️ 사소한 표기: 원문은 `60 "marbles"`(큰따옴표), 초안 각주는 한국어 인용부호와 중첩을 피해 `60 'marbles'`로 표기. 의미 변화 없음.

#### V-16. Stripe: Low-level error handling → **확정**

- **서지/출처**: "Advanced error handling", `https://docs.stripe.com/error-low-level`
- **확인 방법**: 페이지 전문을 열어 확인. "a request that's rate limited with a `429` can produce a different result with the same idempotency key because rate limiters run before the API's idempotency layer. The same goes for a `401` that omitted an API key, or most `400`s that sent invalid parameters. Even so, the safest strategy where `4xx` errors are concerned is to always generate a new idempotency key." ✅ 완전 일치.
- **본문 대비 정합성**: 이 글에서 가장 무거운 외부 근거인데 원문과 정확히 일치한다. 본문의 "429로 잘린 요청은 애초에 서버 로직에 도달하지 않았다"는 원문의 계층 순서 + 같은 문서의 "We save results only after the execution of an endpoint begins"에서 나오는 귀결이다.

#### V-17. Stripe: Idempotent requests → **확정**(출처 귀속만 V-6에서 교정)

- **서지/출처**: `https://docs.stripe.com/api/idempotent_requests`
- **확인 방법**: 페이지 전문 확인. "The API supports idempotency for safely retrying requests without accidentally performing the same operation twice. When creating or updating an object, use an idempotency key. Then, if a connection error occurs, you can safely repeat the request without risk of creating a second object or performing the update twice." ✅ 완전 일치.
- **본문 대비 정합성**: 일치. 더블클릭 인용의 출처 오귀속은 V-6에서 교정 완료.

#### V-18. Stripe: Rate limits 문서의 "중복 방지 미언급" → **확정 (관찰된 부재)**

- **서지/출처**: `https://docs.stripe.com/rate-limits`
- **확인 방법**: 페이지 전문을 받아 목적 진술과 부재를 함께 확인. 목적 원문: "Stripe uses rate limiting to maximize API stability and prevent abuse, so treat limits as maximums and avoid unnecessary load." ✅ 그리고 페이지 전체에 **duplicate / duplicate charge / idempotency / idempotency key 언급이 전혀 없다**(멱등성 링크조차 없음). 백오프 권고도 확인: "Follow an exponential backoff schedule … and add randomness to the backoff schedule to avoid a thundering herd effect."
- **본문 대비 정합성**: 본문은 이를 "관찰 사실 하나를 덧붙이면"으로 시작해 **관찰**로만 제시하고, "rate limiting은 중복 결제를 막을 수 없다"고 벤더가 단언했다는 식으로 격상하지 않는다. 노트 §2-12의 UNVERIFIED 경고(그런 단언을 한 1차 문서는 없음)를 정확히 지킨 서술이다.

#### V-19. Stripe 블로그: 4종 리미터와 로드 셰딩 503 → **확정**

- **서지/출처**: Paul Tarjan, "Scaling your API with rate limiters", Stripe Blog. `https://stripe.com/blog/rate-limiters`
- **확인 방법**: 문자열 일치 4건 전부 ✅ — "We use the token bucket algorithm to do rate limiting" / "would be rejected with status code 503" / "If our reservation number is 20%" / "20 API requests in progress at the same time"
- **본문 대비 정합성**: 일치. ⚠️ 2017년 글이라는 점(노트 §4-3 미해소)은 본문이 "리미터를 4종 운영한다고 공개했어요"라는 과거 공개 사실 서술로 처리해 회피하고 있다.

#### V-20. 전자금융감독규정 (제2025-4호) → **확정 (부재 재확인)**

- **서지/출처**: 전자금융감독규정(금융위원회 고시 제2025-4호) 전문. 원문 보관본 `…/scratchpad/efd.txt` (116,658 bytes, 세션 스크래치패드에 잔존 확인). 출처 `https://ko.wikisource.org/wiki/전자금융감독규정_(제2025-4호)`
- **확인 방법**: 보관본에 대해 키워드 전수 재카운트 — `이상금융거래` 0 / `이상거래` 0 / `FDS` 0 / `사기` 0 / `트래픽` 0 / `DDoS` 0 / `분산서비스거부` 0 / `처리건수` 0 / `용량` 0 / `가용성` 0. 노트 §2-15의 수치와 완전 일치. 제25조 원문도 대조 확인: "금융회사 또는 전자금융업자는 정보처리시스템의 장애예방 및 성능의 최적화를 위하여 정보처리시스템의 사용 현황 및 추이 분석 등을 정기적으로 실시하여야 한다." ✅ 초안 각주 `[^efd]`와 글자 단위로 일치.
- **본문 대비 정합성**: 일치. V-1(법률)과 합쳐 "법과 하위 규정 양쪽에 없다"가 성립한다.

#### V-21. 라이브러리 버전 제약 (bucket4j / resilience4j) → **확정**

- **서지/출처 및 확인 방법**: 초안은 이 대목을 사내 문서 서술로만 갖고 있었기에 **바이트코드로 직접 검증**했다.
  - bucket4j: `com.bucket4j:bucket4j-core:7.6.1` (Gradle 캐시에 메타데이터 잔존). 클래스 파일 major version 전수 확인 → **208개 전부 major=55 = Java 11**. 사내 커밋 기록의 서술과 일치하며, Java 8(major 52) 런타임에서 로드 불가라는 초안 서술이 성립한다.
  - resilience4j: Maven Central에서 `resilience4j-ratelimiter` jar를 직접 받아 대조 → **2.0.0은 major=61 (Java 17)**, **1.7.1은 major=52 (Java 8)**. 릴리스 이력(Maven Central Solr API)에서 1.7.1이 **2021-06-25**로 1.x 마지막 릴리스이고 다음 릴리스가 2.0.0 (2022-11-21)임도 확인.
  - 프로젝트 측: 빌드 스크립트 — `sourceCompatibility = '1.8'`, `targetCompatibility = '1.8'` ✅ (초안 인용과 일치)
- **본문 대비 정합성**: 초안의 "resilience4j는 2.0부터 Java 17을 요구하고, Java 8을 지원하는 마지막 버전은 2021년 6월 이후 릴리스가 끊겨 있었어요"가 외부 1차 근거로 확정됐다. 초안은 "유지보수 중단"으로 단정하지 않고 "릴리스가 끊겨 있었어요"로만 써서 근거 범위를 넘지 않는다.

#### V-22. 인터셉터 체인 순서와 코드 주석 → **확정**

- **서지/출처**: 사내 저장소의 RestTemplate 설정
- **확인 방법**: 실물 확인. **사내 코드이므로 원문을 인용하지 않고 구조만 옮긴다.**
  - RestTemplate에 인터셉터가 로깅 → 서킷 브레이커 → 아웃바운드 레이트리미터 순으로 등록돼 있다 ✅
  - 코드 주석이 그 순서의 의도를 명시한다. 서킷이 OPEN이면 레이트리미터의 permit을 소비하지 않고 즉시 차단하려고 서킷 브레이커를 앞에 뒀다는 서술이다 ✅
  - 커넥션 풀 관련 초안 서술도 같은 파일에서 확인했다. 커넥션 요청 타임아웃 기본 5,000ms이고, 주석은 풀 고갈 시 무한 대기 대신 빠르게 실패시켜 요청 스레드 적체를 막는 것이 의도라고 적고 있다 ✅ (초안의 "커넥션 요청 타임아웃 5초"와 일치).
- **본문 대비 정합성**: 일치. "배치 순서 자체가 semantics"라는 본문 해석은 코드 주석이 명시한 의도 그대로다.

### D. 노트 §4의 미해결 질문 처리

**§4-3에서 해소된 항목**

- [x] 전자금융거래법 조문 전문 grep 미실시 → **해소. V-1 참조** (법 전문 전수 검색 완료, 관련 용어 전부 0회)

**§4-4에서 해소된 항목**

- [x] 서킷 브레이커 4xx 미집계로 429 폭주 시 서킷 미개방 (구현체 상태 코드 분기 미확인) → **해소. V-2 참조** (분기 확인 완료, 추론이 사실로 확정됐고 실제로는 더 강함)
- [x] Redis 기반 분산 레이트리미팅의 실제 구현 여부 → **해소. V-3 참조** (미구현 확정 — 의존성 자체가 없음)

**여전히 미해소 (본문에 반영되지 않았거나, 반영됐어도 근거 범위를 넘지 않게 서술됨)**

- [ ] §4-3의 나머지 UNVERIFIED 항목(Stripe `X-RateLimit-*`, PayPal 샌드박스 수치, Shopify 버킷 크기, `RateLimit-*` 폐기 시점, Cloudflare 현행 알고리즘, GitHub 알고리즘, 감독규정 별표 3 금액, FDS 가이드라인의 "자율" 성격 원문, Stripe 4종 구성의 현행 유효성) → **미해소 유지.** 다만 초안이 이들을 본문에 넣지 않았음을 확인했다(작성자 노트 5번 항목과 일치). 검증 불필요가 아니라 **인용하지 않아 위험이 없는 상태**다.
- [ ] 파트너 실제 한도가 문서마다 다르게 적힌 것, 임시 증량 리드타임도 마찬가지인 것 → **미해소 유지.** 본문은 이를 해소하려 하지 않고 오히려 "다시 한다면"에서 "지금은 아무도 어느 쪽이 맞는지 모릅니다"라고 불일치 자체를 소재로 삼는다. 정직한 처리.
- [ ] 사내 용량 산정 계수의 출처 → **미해소 유지.** 본문에 등장하지 않음.
- [ ] §4-4의 Guava 블로킹이 실제로 톰캣 워커 스레드를 고갈시킨 사건 → **미해소 유지.** 본문은 "회수가 안 됩니다", "방어의 일관성이 깨진 지점"처럼 **구조적 위험**으로만 서술하고 발생 사실로 쓰지 않았음을 확인했다.
- [ ] **(이번에 새로 생긴 항목)** 아웃바운드 리미터가 붙은 WAS가 실제로 다중 인스턴스로 운영 중인지 → **미확인.** V-3에서 "로컬 리미터라 인스턴스가 N대면 실효 한도가 N배"까지는 확정했으나, 현재 배포 인스턴스 수는 확인하지 않았다. 본문도 조건문("인스턴스가 N대면")으로만 서술하므로 현재 서술은 안전하다. **"실제로 한도가 N배로 새고 있다"는 단정으로 바꾸지 말 것.**
- [ ] **(이번에 새로 생긴 항목)** 노트 §2-8이 RFC 9110 인용으로 기록한 두 문장은 **원문이 아니다**(V-4). 어느 2차 자료에서 왔는지는 추적하지 못했다. **노트 §2-8의 해당 인용은 그대로 재사용하지 말 것.**
- [ ] **(이번에 새로 생긴 항목)** 노트 §2-14의 Decorrelated Jitter 공식 표기도 같은 경로로 부정확할 수 있다(V-5). 인용하려면 원문 코드 이미지를 다시 판독할 것.
