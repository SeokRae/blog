---
layout: post
date: 2026-08-11
title: "가장 비싼 테스트가 가장 적게 검증하고 있었다"
subtitle: "무엇이 바뀌면 이 테스트가 실패해야 하는가 (테스트 기준 1편)"
tags: [테스트, 코드품질, 아키텍처]
---

실제 Oracle에 접속하는 통합 테스트가 있습니다. 인메모리 DB로 대체하지 않고, `@AutoConfigureTestDatabase(replace = NONE)`을 달아 진짜 데이터베이스에 붙는 쪽입니다. 테스트 메서드는 11개고, 단언은 전부 같은 모양입니다.

그리고 그 단언은 실패할 수 없습니다.

> ⚠️ 아래 Java와 Groovy 예제는 **사내 저장소 코드의 구조만 남기고 재구성한 것**입니다. 클래스명과 도메인 이름은 중립적인 것으로 바꿨고, 파일 경로와 줄번호는 달지 않습니다. 반면 뒤에 나오는 Ruby와 JavaScript 예제는 **이 블로그 저장소의 원문 그대로**이며 파일과 줄번호를 밝힙니다. 두 종류를 섞어 읽지 않도록 각 코드 블록에 표시해 두었습니다.

```java
// [재구성]
@MybatisTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ActiveProfiles("oracle-it")
@Tag("oracle-integration")
class PaymentSummaryMapperOracleIT {

    @Autowired
    private PaymentSummaryMapper mapper;

    @Test
    void findAttemptsByDate_빈결과_반환() {
        PaymentCondition condition = PaymentCondition.builder()
                .reqDt("20260101")
                .build();
        assertThat(mapper.findAttemptsByDate(condition)).isNotNull();
    }

    // 같은 모양의 메서드가 10개 더 이어진다.
    // 이름만 바뀌고 본문 구조는 동일하다.
}
```

매퍼 인터페이스의 메서드 11개는 전부 `List<...>`를 반환합니다. 그리고 MyBatis는 결과가 없을 때 `null`이 아니라 **빈 리스트**를 돌려줍니다. `DefaultResultHandler`는 결과 리스트 필드를 생성자에서 `new ArrayList<>()`로 초기화하고 `getResultList()`가 그것을 그대로 반환하며, `DefaultResultSetHandler.handleResultSets`도 빈 `ArrayList`에서 시작합니다.[^mybatis]

그러니까 `isNotNull()`은 쿼리가 예외 없이 실행되기만 하면 무조건 통과하는 항진명제입니다. 데이터가 0건이든 100만 건이든, WHERE 절이 맞든 틀리든, 조인이 뒤집혀 있든 통과합니다.

## 그렇다고 가치가 0은 아닙니다

여기서 "통합 테스트는 낭비"로 넘어가면 진단을 틀립니다. 이 테스트도 검증하는 것이 있습니다. **예외 없이 실행됐다는 사실 자체**입니다. SQL 문법 오류, 존재하지 않는 컬럼명, Oracle 방언 문제는 이 테스트가 잡습니다. 실제 Oracle에 붙지 않으면 확인할 수 없는 것들이죠.

즉 **경계 선택은 옳았습니다.** 매퍼를 검증하려면 실제 DB가 필요하다는 판단 자체는 맞습니다. 틀린 건 그 비싼 자리에서 무엇을 단언했느냐입니다.

더 정확히 말하면, 문제는 **이름과 단언이 서로 다른 말을 한다**는 데 있습니다. 메서드 이름은 `빈결과_반환`이라고 약속합니다. 그런데 단언은 빈 결과인지 만 건인지 구분하지 못합니다. 이름이 단언보다 강한 명세입니다. 이름이 약속한 것을 실제로 검증하려면 `isEmpty()`여야 했습니다.

## 그래서 얼마나 있는지 세어 봤습니다

저장소 전체를 훑어봤습니다. 기준은 "단언이 하나라도 있는 `@Test` 메서드 중 `isNotNull`, `assertNotNull`, `isNotEmpty`, `assertDoesNotThrow` 말고는 아무 단언도 없는 메서드"입니다.[^measure]

이 기준으로 세면 단언이 있는 `@Test` 메서드 7,767개 중 264개, 그러니까 3.4%입니다. 정규식으로 센 값이라 절대 수치는 근사치로 읽어야 하고, 아래 비교도 그룹 간 비율 대비로 보는 편이 안전합니다.

**3.4%면 낮습니다.** "약한 단언이 만연하다"는 서술은 이 저장소에 대해 사실이 아닙니다. 흥미로운 건 총량이 아니라 분포였습니다.

| 파일명 접미사 | 약한 단언만 | 전체 | 비율 |
|---|---|---|---|
| `*MapperOracleIT` | 27 | 37 | **73.0%** |
| `*IntegrationTest` | 27 | 229 | 11.8% |
| `*Test` (일반) | 210 | 7,484 | **2.8%** |
| `*OracleIT` (매퍼 아님) | 0 | 17 | 0.0% |

실제 Oracle을 요구하는 매퍼 통합 테스트에서 약한 단언의 밀도가 일반 단위 테스트의 **20배를 넘습니다.** 가장 비싼 테스트가 가장 적게 검증하고 있었습니다.

이 수치는 파서를 달리해 두 번 셌습니다. 단언으로 인정하는 호출 목록을 넓히면 모수가 8,800여 개로 늘고 배수도 30배 가까이로 움직였습니다. **그런데 대조의 양 끝, 그러니까 매퍼 IT의 27/37과 매퍼가 아닌 `*OracleIT`의 0/17은 두 번 다 분자와 분모까지 같았습니다.** 흔들린 건 "일반 테스트"라는 뭉뚱그린 모수였고, 이 글이 기대는 대조는 흔들리지 않았습니다.[^measure]

그리고 마지막 줄이 진단을 좁혀 줍니다. 같은 Oracle 비용을 치르는 `*OracleIT` 중 매퍼가 아닌 것들은 **0%**입니다. 전부 구체적으로 단언합니다. 그러니 "통합 테스트라서 약하다"가 아니라 **"매퍼 테스트라서 약하다"**입니다.

원인은 단순합니다. 매퍼 테스트에 **픽스처가 없으면 단언할 값 자체가 없습니다.** 통제된 입력이 없으니 "실행됐다" 말고는 단언할 거리가 남지 않습니다. 그리고 픽스처를 만드는 건 품이 듭니다. 그래서 비싼 인프라를 띄워 놓고 값싼 단언을 답니다.

## 같은 비용, 다른 단언

같은 저장소, 같은 매퍼, 같은 애노테이션 네 개, 같은 실제 Oracle 접속. 그런데 정반대인 클래스가 하나 더 있었습니다.

```java
// [재구성]
/**
 * 집계 쿼리 동등성 검증용 characterization 시딩 IT.
 * 대표 데이터를 insert하고 손계산 기대값과 비교한다. 쿼리 재작성 전후로 동일하게 통과해야 한다
 * (재작성 전: 기대값=기존 동작 잠금, 재작성 후: new=old 동등성 증명).
 * @MybatisTest는 트랜잭션 롤백이므로 insert는 테스트 종료 시 자동 롤백된다.
 */
class PaymentSummarySeedingOracleIT {

    private static final String REQ_DT = "20991231";  // 실 데이터와 충돌 불가능한 미래 날짜

    @Test
    void findApprovals_시딩_동등성검증() {
        insertMerchantOption("TST_APV_1");

        insertAuthReq("APVQ1", "TST_APV_1", REQ_DT, "N", "N", null, "card");
        insertAuthReq("APVQ2", "TST_APV_1", REQ_DT, "Y", "N", "{...}", "wallet");
        insertAuthReq("APVQ3", "TST_APV_NO", REQ_DT, ...);   // 제외: 가맹점 미등록
        insertAuthReq("APVQ4", "TST_APV_1", "20990101", ...); // 제외: 날짜 불일치

        insertTrans("APT1", "APVQ1", "approved");
        insertTrans("APT2", "APVQ1", "refund");   // 합산 대상
        insertTrans("APT3", "APVQ1", "cancel");   // 제외 대상
        insertTrans("APT4", "APVQ2", "approved");

        List<PaymentApproveSummary> result = mapper.findApprovals(condition);

        // 손계산 기대값과 정확히 대조
        assertThat(actual)
                .containsEntry("ONE_TIME/card", 2L)
                .containsEntry("OFF_SESSION_RECURRING/wallet", 1L)
                .hasSize(2);
    }
}
```

두 클래스를 나란히 놓으면 이렇습니다.

| | (가) 빈결과 IT | (나) 시딩 IT |
|---|---|---|
| 컨텍스트 비용 | 실제 Oracle | 실제 Oracle (동일) |
| 입력 통제 | 없음 | 대표 데이터 직접 적재 |
| 제외 케이스 | 없음 | 미등록, 날짜 불일치, 취소 상태 3종을 일부러 심음 |
| 단언 | `isNotNull()` | 집계 결과를 손계산 기대값과 전수 대조 |
| 실패 가능성 | 쿼리 실행 실패 시에만 | WHERE 절, 조인, 집계 로직 중 하나만 틀려도 |

비용은 같습니다. 실패할 수 있는 범위만 다릅니다.

**여기서 가장 중요한 관찰**: (나)가 구체적인 이유는 작성자의 규율이 더 좋아서가 아닙니다. **답해야 할 질문이 생겼기 때문**입니다. 쿼리를 재작성해야 했고, 재작성 전후가 같음을 증명해야 했습니다. 그 목적이 단언을 구체적으로 만들었습니다.

(가)에는 그런 질문이 없었습니다. 그래서 단언이 자라지 않았어요.

"단언은 구체적으로 쓰자"는 훈계는 이미 코딩 원칙 문서에 있었고, `assertThat(result).isNotNull()`을 나쁜 예시로 콕 집어 적어 두기까지 했습니다.[^principles] 그런데 260곳 남짓에서 그대로 나타났습니다. **기준이 없어서 못 지킨 게 아닙니다.** 지켜지게 만든 건 훈계가 아니라 테스트가 답해야 할 질문이었습니다.

그래서 실무적으로 쓸 만한 방법은 이겁니다. 테스트를 쓰기 전에 **"이 테스트가 무슨 질문에 답하는가"를 한 줄로 먼저 적는 것.** 답할 질문이 안 떠오르면, 그 테스트는 아직 쓸 준비가 안 된 겁니다.

## 커버리지 숫자는 이 차이를 구분하지 못합니다

(가)와 (나)는 커버리지 리포트에서 똑같이 초록불입니다. 같은 매퍼 메서드, 같은 SQL을 실행했으니까요.

Google의 커버리지 가이드가 이것을 정확히 구분합니다. 프로덕션에 나쁜 코드가 나가는 경우는 두 가지인데, (a) 테스트가 특정 경로를 아예 안 지난 경우는 커버리지 분석으로 쉽게 찾을 수 있고, (b) 커버는 됐는데 그 안의 엣지 케이스를 검증하지 않은 경우는 커버리지로 잡기가 어렵거나 불가능하다는 겁니다.

> "Code coverage does not guarantee that the covered lines or branches have been tested correctly, it just guarantees that they have been executed by a test."[^google-coverage]

PIT 문서는 같은 지점을 더 짧게 짚습니다.

> "The most extreme examples of the problem are tests with no assertions."[^pit]

`isNotNull()`은 단언이 없는 테스트는 아닙니다. 하지만 실패할 수 없다는 점에서는 단언이 없는 것과 구별되지 않습니다. 뮤테이션 테스팅이 커버리지보다 강한 지표인 이유가 여기 있습니다. 코드에 인위적으로 결함을 심고 테스트가 그걸 잡아내는지 보니까요. 이 글은 도구 이야기가 아니니 개념만 짚고 넘어가겠습니다.

### 문서가 규정한 임계값을 따라가 봤습니다

사내 표준 문서는 인수 단계 통과 조건 다섯 개 중 하나로 "jacoco LINE 커버리지 60% 최소"를 규정합니다. 어떤 모듈의 설계 문서는 한술 더 떠서 도메인과 애플리케이션 패키지는 LINE 80% + BRANCH 70%로 상향하고, 이유까지 적어 뒀습니다. "파일럿이 후속 단계의 전례가 되므로 핵심 레이어는 상향."

그래서 빌드 파일을 열어 봤습니다. 재구축 트랙 네 개 모듈 전부요.

| 모듈 | jacoco 플러그인 | 임계값 검증 태스크 | `check`에 연결 |
|---|---|---|---|
| A | 있음 | 있음 (LINE 60%) | **없음** |
| B | 있음 | **없음** (리포트만) | 해당 없음 |
| C | 있음 | **없음** (리포트만) | 해당 없음 |
| D | 있음 | **없음** (리포트만) | 해당 없음 |

**문서가 "합격 조건"이라고 적은 60%를 실제로 강제하는 빌드는 하나도 없었습니다.** 모듈 A만 검증 태스크를 정의했는데, 그마저 `check`에 걸려 있지 않아서 누가 명시적으로 호출하지 않으면 돌지 않습니다. 문서가 레이어별 차등(80%/70%)을 규정한 모듈에는 검증 태스크조차 정의돼 있지 않았습니다.

여기서 "그러니 커버리지는 쓸모없다"로 가고 싶어집니다. 그런데 이 주제에 대해 가장 자주 인용되는 세 출처 중 어느 쪽도 그렇게 말하지 않습니다.

Brian Marick은 1997년에 이미 정확한 비유를 남겼습니다. 커버리지 도구는 명령을 내리지 않고 단서를 준다는 겁니다.

> "coverage tools don't give commands (“make that evaluate true”), they give clues (“you made some mistakes somewhere around there”)."[^marick]

그리고 같은 글에 게이트에 관한 실증 관찰이 있습니다. 85%를 출하 게이트로 쓰는 조직에 가서 물어보면, 90%를 넘긴 사람이 몇 있긴 하지만 나머지는 전부 85% 언저리에 몰려 있다는 겁니다. 그 사람들이 하필 85%를 찍고 더 쓸 만한 테스트를 못 찾은 걸까요, 아니면 일단 테스트를 쓰고 커버리지 결과를 본 다음 85%를 간신히 넘길 때까지 두들기고 안도의 한숨을 쉰 걸까요.

우리 조직에서 일어난 일은 같은 힘이 반대 방향으로 작용한 결과로 읽힙니다. 아무도 60%를 반대하지 않았고, 아무도 켜지도 않았습니다. 숫자가 판단을 대체하려고 할 때, 조직은 그 숫자를 조용히 배선하지 않는 쪽을 택했습니다.

Google 가이드도 목표치 자체에 같은 경고를 답니다.

> "Be mindful that engineers may start treating your target like a checkbox and avoid increasing coverage beyond the target, even if doing so would be prudent."[^google-coverage]

### 그런데 하나는 실제로 배선돼 있었습니다

커버리지 **제외 목록**입니다. 어떤 모듈은 순수 데이터 POJO, 커맨드와 결과 레코드, 열거형, 설정 클래스, 진입점을 커버리지 계산에서 뺍니다.

**"이건 테스트 대상이 아니다"라는 경계 판단이 빌드 파일에 실제로 적혀 있는 유일한 자리**였습니다. 강제되는 건 목표치가 아니라 제외 규칙이었습니다.

같은 성격의 장치가 문서에도 있습니다. 테스트 설계 문서에 「명문화된 설계 한계 (테스트 범위 제외)」 절이 있고, 구조만 옮기면 이런 항목들입니다.

| 한계 | 근거와 완화책 |
|---|---|
| 동시 이중 호출 시 중복 발송 가드 없음 | 레거시 동일(분산 락 없음). 수신 측 멱등 전제. 도입은 후속 단계에서 재론 |
| 비동기 수락 후 프로세스 다운 시 발송 유실 | 레거시 동일. 상태값이 유지되므로 외부 배치 재발송 경로가 회복 수단 |
| 특정 실패 경로의 계약 미정 | 구현 전 레거시 코드 대조로 확정 |

**커버리지 퍼센트가 답하지 못하는 것을 이 표가 답합니다.** "무엇이 안 덮였나"에 대해 커버리지 숫자가 알려 주는 건 덮이지 않은 줄의 목록까지입니다. 이 표는 무엇이 왜 빠졌고 대신 무엇이 그 위험을 받아 주는지를 말합니다. Google 가이드의 결론도 같습니다.

> "What's not covered is more meaningful than what is covered."[^google-coverage]

Martin Fowler는 숫자 대신 쓸 판정 기준을 아예 두 문장으로 제시합니다. 프로덕션으로 새어 나가는 버그가 드물고, 프로덕션 버그가 무서워서 코드 고치기를 주저하는 일이 드물다면 충분히 테스트하고 있다는 겁니다.[^fowler-coverage] 커버리지 도구의 용도는 그 판정을 대신하는 게 아니라, 안 덮인 부분을 보여 주고 "이게 안 덮인 게 걱정되는가?"를 묻게 하는 데 있습니다.

## 반대 방향으로도 똑같이 틀립니다

여기까지 읽으면 결론이 "단언을 더 구체적으로 쓰자"로 보입니다. 그래서 이번엔 제 코드를 열겠습니다.

이 블로그에는 `test/site_output_test.rb`라는 계약 테스트가 있습니다. Jekyll을 실제로 빌드한 다음 **생성된 HTML을 읽어서** 단언합니다. 구현이 아니라 산출물을 봅니다. 여기서부터는 이 저장소 원문 그대로입니다.

```ruby
# [원문] test/site_output_test.rb:37-38
assert_match(/<html[^>]+lang="ko"/, index)
assert_match(%r{<link rel="canonical" href="https://seokrae\.github\.io/blog/">}, index)
```

각 단언에 **깨졌을 때 무슨 일이 생기는지**가 주석으로 붙어 있는 게 특징입니다.

```ruby
# [원문] test/site_output_test.rb:45-46
# 제목의 &와 따옴표가 escape돼야 한다 — 안 그러면 속성이 깨져 미리보기가 잘린다
assert_includes post, %(<meta property="og:title" content="Tom &amp; Jerry &quot;quoted&quot;">)
```

부정 단언이 계약을 지키는 자리도 있습니다. "외부 요청 0"이라는 계약은 "없어야 한다"로만 표현되거든요.

```ruby
# [원문] test/site_output_test.rb:52-53, 58
refute_match(%r{<link[^>]*\shref="https?://[^"]*\.css}, index, "외부 스타일시트를 받으면 안 된다")
refute_includes index, "fontawesome"
refute_match(%r{<script[^>]*\ssrc="https?://}, search, "검색은 외부 스크립트 없이 동작해야 한다")
```

그리고 존재 이유가 자명하지 않은 계약에는 배경까지 적혀 있습니다.

```ruby
# [원문] test/site_output_test.rb:64-70
# Chirpy PWA가 /blog/sw.min.js에 심어둔 서비스 워커를 자폭시키는 tombstone. 이 경로가
# 비면 Chirpy 시절 방문자의 브라우저가 옛 캐시(포스트 없는 홈)에 영구히 갇힌다. (#34)
sw_path = File.join(destination, "sw.min.js")
assert File.exist?(sw_path), "tombstone 서비스 워커가 /blog/sw.min.js로 발행돼야 한다"
sw = File.read(sw_path)
assert_includes sw, "registration.unregister", "sw.min.js는 자기 등록을 해제해야 한다"
assert_includes sw, "caches.delete", "sw.min.js는 옛 캐시를 비워야 한다"
```

이 테스트가 잘 그어진 이유는 경계 선택에 있습니다. 테마가 remote theme라서 소스가 이 저장소에 없고, 구현을 테스트할 방법이 아예 없습니다. 그래서 **산출물에 경계를 그었고**, 덕분에 테마 커밋을 올려도 계약이 깨지면 즉시 드러납니다. 경계를 "내가 통제할 수 있는 것"이 아니라 **"사용자가 실제로 받는 것"**에 그은 사례입니다.

그런데 같은 파일에 이런 것들도 있습니다.

```ruby
# [원문] test/site_output_test.rb:108-109
assert_equal 30, rate_limiter_post.scan(/class="rl-mem-track"/).length,
  "패널 6개 × 눈금 5칸의 메모리 인디케이터가 있어야 한다"
```

```ruby
# [원문] test/site_output_test.rb:112-113
assert_match(/\.rl-algo-embed \.rl-grid\{\s*display:grid;grid-template-columns:repeat\(3,1fr\)/,
  rate_limiter_post, "알고리즘 패널이 3열 그리드여야 한다")
```

```ruby
# [원문] test/site_output_test.rb:117-120
assert_match(/th,td\{border:none;border-bottom:1px solid rgba\(0,0,0,0\.1\)/,
  css, "표 세로선이 없고 가로 구분선만 있어야 한다")
assert_match(/tbody tr:nth-child\(even\)\{background:rgba\(0,0,0,0\.025\)\}/,
  css, "지브라 스트라이프가 있어야 한다")
```

```ruby
# [원문] test/site_output_test.rb:121-122
assert_equal 4, rate_limiter_post.scan(/class="tbl-good"/).length,
  "O(1) 4곳에 상태색이 있어야 한다"
```

같은 파일, 같은 저자, 같은 스타일입니다. 그런데 **"이 단언은 무엇이 바뀌면 실패하는가"를 물으면 갈라집니다.**

| 단언 | 실패 조건 | 그게 진짜 고장인가 |
|---|---|---|
| `lang="ko"` 없음 | 언어 표기가 사라짐 | ✅ 접근성과 SEO가 실제로 깨진다 |
| 외부 스타일시트 등장 | 외부 요청 0 계약 위반 | ✅ 의도적으로 지킨 계약이 깨진다 |
| 그리드가 3열이 아님 | 디자인을 2열로 바꿈 | ❌ **고장이 아니라 결정이다** |
| 지브라 배경이 `0.025`가 아님 | 색을 미세 조정함 | ❌ 고장이 아니다 |
| `tbl-good`이 4개가 아님 | 표에 행을 추가함 | ❌ 고장이 아니다 |

아래 셋은 **change detector**입니다. Google Testing Blog의 정의가 정확히 이것을 가리킵니다. 대상 코드에 있는 정보를 형태만 바꿔 옮겨 적은 테스트라서, 프로덕션 코드를 바꾸면 무조건 깨지는데 바뀐 동작이 옳은지 그른지는 아무것도 말해 주지 않는다는 겁니다. 판정도 가혹합니다.

> "Change detectors provide negative value, since the tests do not catch any defects, and the added maintenance cost slows down development. These tests should be re-written or deleted."[^google-changedetector]

같은 글이 증상을 이렇게 서술합니다. 동작을 바꾸지 않고 리팩터링을 끝냈는데 커밋 전에 테스트를 돌리니 한 무더기가 깨져 있고, 그걸 고치면서 여러 테스트에 똑같은 변환을 기계적으로 적용하고 있다는 느낌이 든다면 그겁니다. 실제로 지브라 스트라이프의 알파값을 0.025에서 0.03으로 바꾸면 이 테스트가 빨간불이 됩니다. 아무것도 고장 나지 않았는데요.

### 두 실패는 정확히 대칭입니다

- `isNotNull()`: **고장 났는데도 통과합니다.** 너무 느슨해서.
- `assert_equal 30, ...scan(...)`: **고장 안 났는데도 실패합니다.** 너무 빡빡해서.

둘 다 "단언이 실제 계약을 추적하지 못한다"는 같은 병의 양쪽 끝입니다. **구체성은 단조 증가하는 미덕이 아닙니다.** 구체성을 계속 올리면 좋은 테스트가 되는 게 아니라, 어느 지점을 지나면서 검증이 복사로 변합니다.

그러니 올바른 질문은 "이 단언이 얼마나 구체적인가"가 아닙니다.

**"무엇이 바뀌면 이게 실패해야 하는가."**

이 질문에 한 문장으로 답할 수 있으면 단언의 강도는 거기서 자동으로 결정됩니다. 답이 "이 파일이 조금이라도 바뀌면"이라면 change detector고, 답이 "잘 모르겠는데 일단 실행은 되니까"라면 항진명제입니다.

Justin Searls의 문장이 이것을 한 줄로 요약합니다. Fowler가 자기 글에 인용해 둔 것인데, 테스트 종류별 비율을 논쟁하는 건 distraction이고, 명확한 경계를 세우고 빠르고 안정적으로 돌면서 **유용한 이유로만 실패하는** 표현력 있는 테스트를 쓰는 팀이 거의 없다는 겁니다.[^fowler-shapes]

"only fail for useful reasons"가 이 글의 주제문입니다.

## 이름이 곧 명세입니다

`빈결과_반환`이라는 이름은 단언보다 강한 명세였습니다. 그래서 이름이 거짓말을 했습니다. 그런데 이름이 명세를 제대로 지면, 명세가 틀렸을 때 그 사실이 이름에 드러납니다.

레거시 시스템을 새 구조로 재구축하면서 두 시스템의 동작 차이를 전수 대조한 문서가 있습니다. 거기서 나온 사례입니다. 외부 파트너에게 위임 정보 조회를 요청했는데 실패했을 때, 원장 테이블에 행을 적재하는가?

- 레거시의 실제 동작: **적재한다** (상태값 `ISSUED`)
- 새 구현의 동작: 적재하지 않는다
- 새 구현의 테스트: `verify(billHistoryRepository, never()).insert(any())`
- 새 구현의 주석: "(레거시 동일)"

**테스트도 주석도 틀렸습니다.** 테스트는 초록불이었고, 커버리지에도 잡혔고, 레거시와 다른 동작을 "레거시와 같다"고 잠그고 있었습니다.

교정은 이렇게 됐습니다.

```java
// [재구성]
// 교정 전
verify(billHistoryRepository, never()).insert(any());

// 교정 후
ArgumentCaptor<BillHistoryRecord> captor = ArgumentCaptor.forClass(BillHistoryRecord.class);
verify(billHistoryRepository).insert(captor.capture());
assertThat(captor.getValue().getStatus()).isEqualTo(BillHistoryStatus.ISSUED);
assertThat(captor.getValue().getBid()).isEqualTo(BID);
assertThat(captor.getValue().getBuyerId()).isEqualTo(BID);
```

**부정 단언은 긍정 단언보다 훨씬 쉽게, 틀린 이유로 통과합니다.** `never().insert()`는 아래 네 경우에 모두 통과합니다.

1. 코드가 정말로 insert하지 않을 때 (의도한 경우)
2. 코드가 그 분기에 **도달하지 못했을 때**
3. mock이 다른 객체에 물려 있을 때
4. 조건이 바뀌어 그 경로가 죽은 코드가 됐을 때

1번만 참인 검증이고 2번부터 4번은 거짓 통과입니다. 반면 `ArgumentCaptor` 버전은 **실제로 호출되어야만** 통과합니다. `never()`는 "무엇이 바뀌면 실패해야 하는가"에 답하기 가장 어려운 단언 형태입니다.

이 사례에서 `@DisplayName`도 함께 교정됐는데, 교정 후 이름은 이런 모양이었습니다. "Retrieve 비2xx: U513, NOTI void, 보상 없음 + 원장 INSERT(issued), 레거시 동일(Retrieve 실패에도 적재)". 길죠. 그런데 **이름이 명세를 통째로 지고 있습니다.** 그래서 명세가 틀렸을 때 이름과 단언이 함께 틀렸고, 함께 고쳐졌습니다.

Google이 정리한 규칙도 같은 자리를 짚습니다. 어떤 명명 패턴을 쓰든, **테스트 이름에 검증하는 시나리오와 기대 결과가 둘 다 들어가야 한다**는 겁니다.[^google-names] `빈결과_반환`에는 기대 결과만 있고 단언이 그것을 지키지 않았습니다. 이름이 명세를 지면 부수 효과가 따라옵니다. 클래스의 테스트 이름만 훑어도 그 클래스가 가진 동작을 알 수 있고, 찾는 동작의 이름이 없으면 그 테스트가 없다는 것을 바로 알 수 있어요.

## 형태를 고르는 문제가 아니었습니다

여기까지 오면 "그래서 어떤 레벨에서 무엇을 테스트하나"가 남습니다. 이 질문은 보통 피라미드냐 트로피냐 허니콤이냐 하는 형태 논쟁으로 흘러갑니다.

Fowler 본인이 2021년에 이 논쟁을 정리했는데, 결론이 시원합니다. 허니콤 지지자들이 비판하는 건 mock의 과용이고, 그렇다면 그들이 말하는 "단위 테스트"는 자기가 말하는 solitary unit test이며 그들의 "통합 테스트"는 자기가 말하는 sociable unit test로 들린다는 겁니다. 그리고 피라미드의 어떤 서술도 단위 테스트를 그 둘 중 하나로 못 박은 적이 없으니,

> "This makes the pyramid versus honeycomb discussion moot"[^fowler-shapes]

라는 판정이 나옵니다. 같은 글의 마무리도 실용적입니다. 누군가 테스트 분류를 이야기하기 시작하면 그 단어로 무엇을 뜻하는지 더 파고들라는 것. 지난번에 읽은 사람과 같은 뜻으로 쓰고 있지 않을 가능성이 크니까요.

실제로 각 형태의 제안자들이 맥락 한정을 스스로 밝힙니다. Kent C. Dodds는 트로피가 마이크로서비스나 백엔드 서비스에 적용되는지는 **애초에 고려한 적이 없다**고 못 박습니다. 자기 코드 소유 범위 안에서 쓸 수 있는 테스트 종류를 분류했을 뿐이라는 겁니다.[^dodds] Spotify는 더 직접적입니다. 마이크로서비스를 계약으로 테스트되는 격리된 컴포넌트로 다뤘고, 그런 의미에서 **마이크로서비스가 자기들의 새로운 "단위"가 됐다**고 적습니다. 그래서 "단위 테스트"라는 용어를 피하고 Implementation Detail Tests라고 불렀다고 합니다.[^spotify]

이름이 표준이 아니라는 건 우리 쪽에서도 확인됩니다. 사내 표준 문서는 테스트 레벨을 L1부터 L5까지 정의합니다. L1은 도메인 단위 테스트, L2는 애플리케이션과 포트(port mock), L3은 어댑터 통합 테스트(DB는 Testcontainers, 외부 HTTP는 WireMock), L4는 인바운드 어댑터 슬라이스 테스트, L5는 인수 시나리오 실행입니다.

깔끔하고 잘 작동합니다. 그런데 **이건 업계 표준이 아닙니다.** ISTQB CTFL 실러버스 v4.0.1 전문을 훑어보면 `L1`부터 `L5`까지의 표기는 한 번도 나오지 않습니다.[^istqb] 실러버스에 나오는 "Level 1/2/3"은 테스트 단계가 아니라 시험 문제의 인지 수준(K-Level)입니다. 그리고 흔히 말하는 "단위, 통합, 시스템, 인수 4단계"도 ISTQB 원문과 다릅니다. 원문은 다섯 개입니다. component / component integration / system / system integration / acceptance.

**표준 이름이 없어서 각자 만드는 겁니다.** 그리고 그것이 문제도 아닙니다. ISTQB 자신이 레벨을 가르는 건 이름이 아니라 속성이라고 적습니다. 테스트 대상, 테스트 목적, 테스트 기준, 결함과 실패의 종류, 접근 방식과 책임. 이름을 통일하는 게 목적이 아니라, **각 레벨이 무엇을 검증하고 무엇을 검증하지 않는지 합의하는 게 목적**입니다.

## 그래서 무엇을 적어야 하나: 빈칸이 있는 표

같은 조직이 그 합의를 표로 만들어 뒀습니다. 구조만 옮기면 이렇습니다.

| 불변식 | L1 (도메인) | L3 (어댑터) | L5 (인수) |
|---|---|---|---|
| 큐 조회 고정 조건 | — | mapper WHERE 검증 | AT-01-8 |
| 상태 전이 | 판정표 6행 전수 | updateResult | AT-01-1~7 |
| 응답값 정규화 판정 | 정규화 케이스 전수 | — | AT-01-2~4 |
| 특정 테이블 읽기 전용 | — | 쓰기 mapper 부재 확인 | 변경 0건 |
| 만료 멱등 | 판정 로직(L2) | UPDATE 0건/1건 | AT-09-1, 11, 14 |
| ID 매핑 | 5케이스 전수 | — | 적용 지점 전수 |

**이 표에서 가장 중요한 칸은 `—`입니다.** "이 레이어는 이 불변식에 대해 할 말이 없다"를 명시적으로 적어 둔 것입니다. "같은 로직을 여러 레벨에서 중복 검증하지 말 것"이라는 규칙은 어느 팀 코딩 원칙에나 있는데, 여기서는 훈계가 아니라 **표의 빈칸**으로 구현돼 있습니다.

그리고 채워진 칸들은 서로 다른 것을 봅니다. 같은 "만료 멱등" 불변식이 L2에서는 판정 로직, L3에서는 UPDATE 영향 행 수(0건이냐 1건이냐), L5에서는 시나리오 세 건으로 나뉩니다. **중복이 아니라 분해입니다.** 각 칸이 "무엇이 바뀌면 여기가 실패해야 하는가"에 서로 다른 답을 갖고 있으니까요.

같은 계열의 장치가 하나 더 있습니다. 인수 시나리오 39건 중 4건에 `(L1)` 태그가 붙어 있습니다. 결제수단 별칭 전수 변환, 레거시 코드값 보존, 서명 데이터 입력 순서와 hex 소문자, 검증 스펙 62종과 에러코드. 전부 **비즈니스가 요구하는 인수 기준이지만 I/O가 필요 없는** 순수 계산입니다. 그래서 "이건 L1에서 해결한다"고 태그로 못 박고, 인수 테스트에서 다시 돌리지 않겠다고 선언했습니다.

인수 기준이라고 해서 인수 레벨에서 검증해야 하는 건 아닙니다. 요구사항의 출처와 검증의 위치는 별개 축입니다.

## 경계는 게이트 설계이기도 합니다

경계는 "무엇을 어느 레벨에서 볼 것인가"만이 아닙니다. **"무엇을 게이트 안에 둘 것인가"**이기도 합니다. 그리고 후자를 잘못 그으면 게이트 자체가 무력화됩니다.

같은 저장소의 두 모듈이 같은 문제를 정반대로 처리했습니다.

```groovy
// [재구성] 모듈 X: 게이트를 끈다
test {
    useJUnitPlatform()
    // 원본 parity: 52/280건이 로컬 DB 스키마, pem 키 부재로 원본부터 실패 (이관 회귀 0건 검증 완료)
    // 테스트 그린화 후 제거 예정
    ignoreFailures = true
}
```

280건 중 52건이 환경 문제로 실패하는데, 빌드는 초록불로 나옵니다.

```groovy
// [재구성] 모듈 Y: 테스트를 가른다
// 회귀 게이트: 실 DB 없이 도는 단위 테스트만 돌리고, 하나라도 깨지면 빌드를 실패시킨다.
// ignoreFailures 를 두면 테스트가 red 여도 BUILD SUCCESSFUL 이 나와 "빌드 통과"가 근거로서 무의미해진다.
test {
    useJUnitPlatform { excludeTags 'integration' }
}

// 실 Oracle 접속이 필요한 통합 테스트(@Tag("integration")). 접속 주소는 TEST_DB_URL 로 오버라이드한다.
// check/build 에 의도적으로 걸지 않는다. DB 환경에 좌우되는 실패가 빌드를 red 로 만들면
// 게이트 자체를 다시 끄는 압력이 생긴다. 실행은 ./gradlew integrationTest 로 명시한다.
tasks.register('integrationTest', Test) { ... }
```

**같은 진단, 반대 처방입니다.** 둘 다 "환경에 좌우되는 테스트가 게이트 안에 있다"를 문제로 봤어요. X는 게이트의 민감도를 껐고, Y는 테스트를 게이트 밖으로 옮겼습니다.

Y의 주석이 X의 결과를 정확히 예측합니다. "빌드 통과"가 근거로서 무의미해진다는 것. 그리고 Y는 한 걸음 더 나갑니다. **환경 의존 테스트를 게이트에 두면 게이트를 다시 끄는 압력이 생긴다**는 관찰입니다. 이건 테스트 설계 문제가 아니라 인센티브 설계 문제입니다.

`ignoreFailures = true`도 결국 같은 질문에 대한 답입니다. "무엇이 바뀌면 이 빌드가 실패해야 하는가." X의 답은 "아무것도"가 됐습니다.

## 어떤 스위트도 전부를 덮지 않습니다

마지막으로 이 블로그의 사건 하나. `CLAUDE.md`에 이렇게 기록돼 있습니다.

> `assets/js/search.js`는 lunr을 쓰지 않는다 — lunr 파이프라인의 trimmer가 `\W`로 토큰을 잘라 **한글 토큰을 빈 문자열로 만들기 때문에** 한국어 질의가 전부 0건이 된다 (#12). 대신 substring 매칭을 쓰고, 이 동작은 `test/search_test.js`에 잠겨 있다. HTML 계약 테스트는 JS 동작을 검증하지 못하므로 검색 로직을 고치면 **두 테스트를 모두** 돌린다.
>
> (`CLAUDE.md:34`, 원문 그대로)

앞에서 칭찬한 그 계약 테스트가 전부 통과하는 동안, **라이브 사이트의 한국어 검색은 항상 0건이었습니다.** HTML을 읽는 테스트는 JS를 실행하지 않으니까요. `lang="ko"`도 맞고, 외부 요청도 0이고, `aria-label="검색"`도 붙어 있었습니다. 검색창은 완벽하게 렌더됐고 아무것도 찾지 못했습니다.

**테스트 스위트의 경계가 곧 그 스위트가 볼 수 없는 결함의 범위입니다.**

고친 방법도 경계 이야기입니다. lunr을 버리고 substring 매칭으로 바꾼 다음, **JS를 실제로 실행하는 별도 테스트**를 만들었습니다.

```javascript
// [원문] test/search_test.js:32-36
// 한국어 — 이 블로그의 주 언어. lunr trimmer 회귀 시 전부 0건이 된다.
assert.deepStrictEqual(refs("문서"), ["flowcast"], "제목의 한글이 검색돼야 한다");
assert.deepStrictEqual(refs("다이어그램"), ["flowcast"], "본문의 한글이 검색돼야 한다");
assert.deepStrictEqual(refs("블로그"), ["type-theme"], "태그의 한글이 검색돼야 한다");
assert.deepStrictEqual(refs("회고"), ["flowcast", "type-theme"], "여러 글의 공통 태그가 모두 걸려야 한다");
```

조용히 새는 경로도 함께 잠갔습니다.

```javascript
// [원문] test/search_test.js:51-54
// 빈 질의 — 전체 매칭으로 새지 않아야 한다
assert.deepStrictEqual(refs(""), [], "빈 질의는 0건");
assert.deepStrictEqual(refs("   "), [], "공백뿐인 질의는 0건");
assert.deepStrictEqual(refs(null), [], "null 질의는 0건");
```

이 단언들은 "무엇이 바뀌면 실패해야 하는가"에 한 문장으로 답합니다. **한국어 질의가 다시 0건이 되면.** 그래서 강도가 딱 그만큼입니다. 검색 결과의 정렬 알고리즘을 바꿔도, HTML 마크업을 바꿔도 깨지지 않습니다. 한국어가 안 걸리기 시작하면 깨집니다.

## 무엇을 배웠는가

**첫째, 실패할 수 없는 단언은 커버리지 리포트에서 다른 단언과 구별되지 않습니다.** 커버리지는 실행됐다는 것만 보장하니까요. 그리고 가장 비싼 테스트일수록 픽스처 비용 때문에 이 함정에 잘 빠집니다. 약한 단언의 밀도가 가장 높았던 자리가 하필 실제 Oracle을 띄우는 매퍼 통합 테스트였습니다.

**둘째, 단언을 구체적으로 만드는 건 규율이 아니라 질문입니다.** 코딩 원칙 문서에 `isNotNull()`을 나쁜 예시로 적어 뒀는데도 260곳 남짓에서 나왔습니다. 반면 "쿼리 재작성 전후가 같은가"라는 질문이 생기자, 아무도 시키지 않았는데 손계산 기대값까지 대조하는 테스트가 만들어졌습니다. 규율을 더 요구해서 얻은 결과가 아닙니다.

**셋째, 구체성은 단조 증가하는 미덕이 아닙니다.** `isNotNull()`은 고장 났는데 통과하고, `assert_equal 30, scan(...)`은 고장 안 났는데 실패합니다. 둘 다 단언이 실제 계약을 추적하지 못한다는 같은 병입니다. 제 저장소에도 둘 다 있었어요.

**넷째, 경계는 레벨 선택만이 아니라 게이트 설계입니다.** 환경에 좌우되는 테스트를 게이트 안에 두면 게이트를 끄는 압력이 생기고, 실제로 꺼집니다. 그러면 "빌드 통과"라는 근거가 통째로 무의미해집니다.

**다섯째, 무엇이 안 덮이는지 아는 것이 경계입니다.** 문서로 규정한 커버리지 60%는 어느 빌드에도 배선돼 있지 않았지만, "이건 테스트 대상이 아니다"라는 제외 목록은 실제로 배선돼 있었습니다. 목표치보다 제외 규칙이 더 많은 판단을 담고 있었습니다.

## 테스트를 쓰기 전에 물어볼 것

단언을 쓰기 전에 이 순서로 물어보면 됩니다.

- **이 테스트는 무슨 질문에 답하는가.** 한 줄로 안 나오면 아직 쓸 준비가 안 된 겁니다.
- **무엇이 바뀌면 이게 실패해야 하는가.** 답이 "이 파일이 조금이라도 바뀌면"이면 change detector고, "잘 모르겠지만 실행은 되니까"면 항진명제입니다.
- **무엇이 바뀌어도 이게 실패하면 안 되는가.** 리팩터링, 디자인 변경, 표에 행 추가. 이쪽이 비어 있으면 단언이 구현을 베끼고 있는 겁니다.
- **이름이 단언보다 강하지 않은가.** 이름에 시나리오와 기대 결과가 둘 다 있고, 단언이 그 기대 결과를 실제로 확인하는지 봅니다.
- **부정 단언이라면, 틀린 이유로 통과할 경로가 몇 개인가.** `never()`는 코드가 그 분기에 도달조차 못 했을 때도 통과합니다.
- **이 비용을 치른 이유를 단언이 쓰고 있는가.** 실제 DB를 띄웠으면 실제 DB만 답할 수 있는 것을, 실제 브라우저를 띄웠으면 브라우저만 답할 수 있는 것을 단언합니다.
- **이 스위트가 못 보는 건 무엇인가.** 그리고 그것이 안 덮인 채로 괜찮은지, 명시적으로 적어 두었는가.

이 글은 3부작의 1편입니다. 여기서는 "무엇을 테스트할 것인가", 그러니까 경계를 어디에 긋고 그 경계가 무엇을 못 보는지까지만 다뤘습니다.

[^mybatis]: 로컬 Gradle 캐시의 `mybatis-3.5.17-sources.jar`를 풀어 원본을 확인했다. `DefaultResultHandler`는 `private final List<Object> list;`를 인자 없는 생성자에서 `list = new ArrayList<>();`로 초기화하고 `getResultList()`가 그대로 반환한다(`ObjectFactory`를 받는 다른 생성자도 `list = objectFactory.create(List.class);`라 null이 되지 않는다). `DefaultResultSetHandler.handleResultSets`도 `final List<Object> multipleResults = new ArrayList<>();`로 시작한다. 빈 결과셋이면 빈 `ArrayList`가 반환되며 `null`이 될 수 없다. 다만 이 매퍼 통합 테스트를 실제로 실행해 본 것은 아니다(실제 Oracle 접속이 필요하다). 소스 확인으로 논리를 확정했을 뿐 실행 검증은 아니다.
[^principles]: 이 문서는 사내 문서가 아니라 필자가 GitHub 마켓플레이스로 배포하는 하네스 플러그인의 스킬 파일이라 원문을 그대로 옮긴다. `sr-harness` 0.23.0의 `skills/dev-coding-principles/SKILL.md` `## §3 Test` 절이다. `:40` "**목표**: 테스트는 코드의 동작 명세다 — 구현이 아닌 의도를 검증한다." `:54` "**통합 테스트 경계**: 외부 경계(Repository, HTTP Client)만 통합 테스트 — 비즈니스 로직 중복 검증 금지" `:55` "**픽스처 분리**: 테스트 데이터 생성은 `*Fixture` 클래스로 분리하여 재사용" `:56` "**단언은 구체적으로**: `assertThat(result).isNotNull()` ❌ → `assertThat(result.getStatus()).isEqualTo(COMPLETED)` ✅". 체크리스트의 `§3 Test` 블록(`:71-74`)은 머리말 한 줄과 항목 셋으로 돼 있고, 항목(`:72-74`)은 각각 "[ ] given-when-then 구조인가?", "[ ] 테스트 이름이 한국어로 의도를 표현하는가?", "[ ] 단위/통합 테스트 경계가 올바른가?"다. 출처: [SeokRae/sr-harness](https://github.com/SeokRae/sr-harness)
[^measure]: `@Test`, `@ParameterizedTest`, `@RepeatedTest` 메서드 본문에서 단언 호출을 추출한 뒤, `isNotNull` / `assertNotNull` / `isNotEmpty` / `assertDoesNotThrow`를 포함한 줄을 제외하면 단언이 하나도 남지 않는 메서드를 셌다. 정규식 기반이라 커스텀 단언 헬퍼는 놓친다. 그래서 절대 수치보다 접미사 그룹 간 비율 대비로 읽는 편이 안전하다. 실제로 단언 인정 목록에 BDDMockito `then()`과 `andExpect`를 넣어 다시 세니 모수가 7,767에서 8,841로 늘었고 전체 비율은 3.4%에서 3.0%로, 일반 테스트는 2.8%에서 2.4%로 움직였다. 매퍼 IT의 27/37과 매퍼 아닌 `*OracleIT`의 0/17은 두 번 다 같았다.
[^google-coverage]: Carlos Arguelles, Marko Ivanković, Adam Bender, "Code Coverage Best Practices", Google Testing Blog, 2020-08-07. 커버되지 않은 경로와 커버는 됐지만 검증되지 않은 엣지 케이스의 구분: "Bad code being pushed to production due to missing tests could happen either because (a) your tests did not cover a specific path of code, a test gap that is easy to identify with code coverage analysis, or (b) because your tests did not cover a specific edge case in an area that did have code coverage, which is difficult or impossible to catch with code coverage analysis." 목표치에 대한 입장: "There is no “ideal code coverage number” that universally applies to all products." 다만 참고 수치는 제시한다. "at Google we offer the general guidelines of 60% as “acceptable”, 75% as “commendable” and 90% as “exemplary.”" 출처: [Google Testing Blog](https://testing.googleblog.com/2020/08/code-coverage-best-practices.html)
[^pit]: PIT Mutation Testing 공식 문서, "What's wrong with line coverage?" 절. "Traditional test coverage (i.e line, statement, branch, etc.) measures only which code is executed by your tests. It does not check that your tests are actually able to detect faults in the executed code." 뮤테이션 테스팅의 원리: "Faults (or mutations) are automatically seeded into your code, then your tests are run. If your tests fail then the mutation is killed, if your tests pass then the mutation lived." 출처: [pitest.org](https://pitest.org/)
[^marick]: Brian Marick, "How to Misuse Code Coverage". 문서의 저작권 표기는 "Copyright 1997 Brian Marick, 1999 Reliable Software Technologies"다. 85% 게이트 관찰 원문: "when I talk about coverage to organizations that use 85%, say, as a shipping gate, I sometimes ask how many people have gotten substantially higher, perhaps 90%. There's usually a few who have, but everyone else is clustered right around 85%." 그리고 "Coverage numbers (like many numbers) are dangerous because they're objective but incomplete." 결론은 도구 무용론이 아니다. "I wouldn't have written four coverage tools if I didn't think they're helpful. But they're only helpful if they're used to enhance thought, not replace it." 1997년 문서이며 최신 연구가 아니다. 출처: [exampler.com PDF](http://www.exampler.com/testing-com/writings/coverage.pdf)
[^fowler-coverage]: Martin Fowler, "TestCoverage", 2012-04-17. "Test coverage is a useful tool for finding untested parts of a codebase. Test coverage is of little use as a numeric statement of how good your tests are." 목표치의 함정: "If you make a certain level of coverage a target, people will try to attain it. The trouble is that high coverage numbers are too easy to reach with low quality testing." 대안 판정 기준 원문: "You rarely get bugs that escape into production, and You are rarely hesitant to change some code for fear it will cause production bugs." 출처: [martinfowler.com](https://martinfowler.com/bliki/TestCoverage.html)
[^google-changedetector]: Alex Eagle, "Testing on the Toilet: Change-Detector Tests Considered Harmful", Google Testing Blog, 2015-01-27. 정의 원문: "This is a change-detector test—it is a transformation of the same information in the code under test—and it breaks in response to any change to the production code, without verifying correct behavior of either the original or modified production code." 체크섬 비유: "A correct or incorrect program is equally likely to pass a test that is a derivative of the code under test." 증상 서술: "You have just finished refactoring some code without modifying its behavior. Then you run the tests before committing and… a bunch of unit tests are failing." 출처: [Google Testing Blog](https://testing.googleblog.com/2015/01/testing-on-toilet-change-detector-tests.html)
[^fowler-shapes]: Martin Fowler, "On the Diverse And Fantastical Shapes of Testing", 2021-06-02(부제 "Pyramids, honeycombs, trophies, and the meaning of unit testing"). moot 판정 원문: "This makes the pyramid versus honeycomb discussion moot, since any descriptions I've heard of the test pyramid consider unit tests to be sociable and/or solitary." 그리고 "The take-away here is when anyone starts talking about various testing categories, dig deeper on what they mean by their words, as they probably don't use them the same way as the last person you read did." Searls 인용문은 **Fowler의 말이 아니라 Justin Searls의 말을 Fowler가 인용한 것**이다. 원문: "People love debating what percentage of which type of tests to write, but it's a distraction. Nearly zero teams write expressive tests that establish clear boundaries, run quickly & reliably, and only fail for useful reasons. Focus on that instead." 참고로 같은 저자의 [TestPyramid](https://martinfowler.com/bliki/TestPyramid.html)(2012-05-01)는 요점을 단수(`essential point`)로 적는다. "Its essential point is that you should have many more low-level UnitTests than high level BroadStackTests running through a GUI." 출처: [martinfowler.com](https://martinfowler.com/articles/2021-test-shapes.html)
[^dodds]: Kent C. Dodds, "The Testing Trophy and Testing Classifications". 맥락 한정 원문: "The reason I explain this background is to help you understand the way the Testing Trophy is intended to be interpreted. I never considered whether it applied to microservices or even backend services at all. I considered my codebase in isolation and attempted to categorize the types of tests I could write within the confines of my own code ownership." 참고로 "Write tests. Not too many. Mostly integration."의 원 출처는 Dodds가 아니라 Guillermo Rauch의 2016-12-10 트윗이며, Dodds가 직접 밝힌다. 커버리지 목표치 비판은 이 글이 아니라 같은 저자의 「Write tests. Not too many. Mostly integration.」에 있다. "I've heard managers and teams mandating 100% code coverage for applications. That's a really bad idea." 출처: [kentcdodds.com](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications), [Write tests. Not too many. Mostly integration.](https://kentcdodds.com/blog/write-tests)
[^spotify]: André Schaffer, Rickard Dybeck, "Testing of Microservices", Spotify Engineering, 2018-01-11. 단위의 재정의 원문: "By the way, you may have noticed that what we've been treating the Microservice as an isolated Component, tested through its contracts. In that sense the Microservice has become our new Unit, which is why we have avoided the use of the term Unit Tests for Microservices in favour of Implementation Detail Tests." 피라미드 비판: "In a Microservices world, this is no longer the case, and we would argue that it can be actively harmful." 트레이드오프도 명시한다. "The trade-off here is some loss of speed in test execution. The suite goes from milliseconds to a few seconds..." 출처: [Spotify Engineering](https://engineering.atspotify.com/2018/1/testing-of-microservices)
[^istqb]: ISTQB Certified Tester Foundation Level Syllabus v4.0.1(2024-09-15) §2.2.1. 전문 78페이지에서 정규식 `\bL[1-5]\b` 일치는 0건이다. 실러버스에 나오는 "Level 1/2/3"은 테스트 단계가 아니라 K-Level(인지 학습목표 수준)이며 원문은 "Level 1: Remember (K1)", "Level 2: Understand (K2)", "Level 3: Apply (K3)"이다. 테스트 레벨은 다섯 개다. 원문: "In this syllabus, the following five test levels are described" (component / component integration / system / system integration / acceptance). 레벨을 가르는 기준: "Test levels are distinguished by the following non-exhaustive list of attributes, to avoid overlapping of test activities:" 이어지는 항목은 불릿 다섯 개다. "Test object", "Test objectives", "Test basis", "Defects and failures", "Approach and responsibilities". 출처: [ISTQB CTFL Syllabus v4.0.1 (PDF)](https://istqb.org/wp-content/uploads/2024/11/ISTQB_CTFL_Syllabus_v4.0.1.pdf)
[^google-names]: Andrew Trenk, "Testing on the Toilet: Writing Descriptive Test Names", Google Testing Blog, 2014-10-16. 핵심 규칙 원문: "Whichever pattern you use, the same advice still applies: Make sure test names contain both the scenario being tested and the expected outcome." 이름이 명세 역할을 한다는 논지: "If you want to know all the possible behaviors a class has, all you need to do is read through the test names in its test class" / "You can easily tell if some functionality isn't being tested. If you don't see a test name that describes the behavior you're looking for, then you know the test doesn't exist." 구현이 아니라 동작을 테스트하라는 [같은 시리즈의 글](https://testing.googleblog.com/2013/08/testing-on-toilet-test-behavior-not.html)(Andrew Trenk, 2013-08-05)에는 유보 조항이 함께 있어 "구현 테스트 금지"로 읽으면 오독이다. "There are many cases where you do want to test implementation details (e.g. you want to ensure that your implementation reads from a cache instead of from a datastore), but this should be less common since in most cases your tests should be independent of your implementation." 출처: [Google Testing Blog](https://testing.googleblog.com/2014/10/testing-on-toilet-writing-descriptive.html)
