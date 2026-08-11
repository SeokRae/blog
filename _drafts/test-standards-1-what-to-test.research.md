# 리서치: 무엇을 테스트할 것인가 (테스트의 경계)

**slug**: `test-standards-1-what-to-test`
**수집일**: 2026-08-11
**시리즈**: 3부작 1편. 2편은 Spring 컨텍스트 구성, 3편은 기준을 에이전트에게 위임하기.

---

## ⚠️ 0. writer가 먼저 읽어야 할 제약

### 0-1. 이 노트는 공개 저장소에 커밋된다 (이번에 새로 확인)

`.gitignore:17-18`이 `_drafts/*`를 무시하되 `!_drafts/*.research.md`로 리서치 노트만 되살린다. 그리고 `origin`은 `https://github.com/SeokRae/blog.git`, 즉 **공개 저장소**입니다. 실제로 선행 노트 3건이 이미 추적되고 있어요 (`git ls-files _drafts/`).

그래서 **이 노트 자체를 익명화된 상태로 작성했습니다.** 사내 패키지명, 클래스명, 파일 경로, 사내 이슈 번호는 이 노트에도 넣지 않았습니다. 아래 §1의 사내 근거는 전부 **구조만 남긴 재구성**입니다.

원본 추적이 필요하면 (verifier가 근거를 되짚을 때) 같은 디렉터리의 `test-standards-1-what-to-test.sources-internal.md`를 보세요. 그 파일은 `.gitignore`의 `_drafts/*` 규칙에 걸려 **커밋되지 않습니다** (`git check-ignore`로 확인함). 그 파일의 내용은 **본문에도 이 노트에도 옮기지 않습니다.**

### 0-2. 익명화 (필수, 예외 없음)

선행 노트 `_drafts/rate-limiter-payment-platform.research.md`의 `## 0. writer가 먼저 읽어야 할 제약` 표를 그대로 승계합니다. 요약하면 회사와 PG사 실명, 파트너사 실명, 도메인, 패키지와 클래스 실명, 사내 이슈 번호, 계약 및 협상 수치는 본문에 옮기지 않습니다.

### 0-3. ★ 이번 시리즈에만 추가되는 규칙: 인용 두 종류를 분리한다

`CLAUDE.md`의 포스트 규칙은 "저장소 코드를 인용할 때는 원문 그대로, 축약과 괄호 생략과 정규식 손질 금지"입니다. 그런데 익명화하면 원문이 아니게 되죠. 그래서 두 종류를 나눕니다.

| 종류 | 대상 | 본문에서 다루는 법 |
|---|---|---|
| **A. 원문 그대로 인용 가능** | 이 블로그 저장소(`test/*`), 공개 라이브러리 소스, 공개 문서, `sr-harness` 스킬 파일 | 파일과 줄번호를 밝히고 원문 그대로 |
| **B. 재구성 예제로만 가능** | 사내 저장소 코드 | 클래스명을 중립 도메인으로 치환, **파일 경로를 달지 않음**, 본문에 "구조만 남기고 재구성했다"고 명시 |

**B를 쓸 때는 반드시 본문에 재구성임을 밝힙니다.** 밝히지 않고 코드처럼 보이게 두면 "원문 그대로" 규칙을 어기는 것과 같은 효과가 납니다.

아래 §1에서 A는 `[원문]`, B는 `[재구성]`으로 표시했습니다.

### 0-4. 블로그 내 선행 글과의 관계

`_posts/`를 전수 확인한 결과 테스트를 주제로 다룬 발행 포스트는 **없습니다.** 처음 다루는 주제예요. 다만 인접한 글이 셋 있고, 각각 다른 방식으로 이어집니다.

| 선행 글 | 연결 지점 | 차별화 |
|---|---|---|
| `2026-07-13-chirpy-to-type-theme.md` | 계약 테스트가 처음 등장한 글. "검증 가능한 사실은 그 자리에서 검증하라"가 결론 | 그 글은 *테마 이전*의 기록. 1편은 그 계약 테스트가 **무엇을 잠그고 무엇을 못 잠그는가**로 들어간다 |
| `2026-07-24-incident-response-pipeline.md` | 커넥션 풀 고갈에서 재시도 폭풍으로 이어진 장애. 사후 대응 | 1편은 **사전**. "이 장애를 어떤 테스트가 잡을 수 있었나"로 연결 가능 |
| `2026-07-29-harness-engineering-book-overview.md` | 하네스와 자동화 원칙. 3편의 직접 선행 | 1편에서 에이전트 이야기를 선점하지 말 것 |
| `2026-08-09-rate-limiter-payment-platform.md` | 같은 사내 저장소가 근거. 익명화 표를 여기서 승계 | 주제가 다름. 다만 **§1-9의 "게이트를 끄는 두 방법"이 그 글의 "다시 한다면" 정서와 같은 결** |

⚠️ 선행 글은 **그 시점의 기록**입니다. 1편에서 인접 글을 언급할 때 그 글의 서술을 소급해 고치는 식으로 쓰지 마세요.

---

## 1. 근거: 내부 (1차)

### 1-1. 테스트 레벨 체계 L1~L5는 실재하고, 문서에 정의돼 있다 [재구성]

사내 재구축 표준 문서가 레이어별 테스트 레벨을 표로 정의합니다. 요지만 옮기면 이렇습니다.

**설계 단계 (top-down)**: 도메인 설계 → 계약 설계 → **테스트 설계**. 테스트 설계 단계의 산출물이 "인수 시나리오(Given/When/Then) 전수 목록 + 레이어별 테스트 전략"이고, 통과 기준은 "Use Case 대비 시나리오 커버리지 100%, **구현 전에 합격 기준 고정**"입니다.

**구현 단계 (bottom-up)**:

| 레벨 | 대상 | 검증 방식 |
|---|---|---|
| L1 | domain | 단위 테스트 (불변식과 상태 전이 전수) |
| L2 | application/port | 단위 테스트 (port mock) |
| L3 | adapter out | 통합 테스트. DB는 Testcontainers, 외부 HTTP는 WireMock |
| L4 | adapter in + config | 슬라이스 테스트 (`@WebMvcTest` 등) |

그리고 문서가 한 줄 못 박습니다: **"각 레이어는 머지 전 해당 레이어 테스트 통과가 조건. 레이어를 건너뛰어 구현하지 않는다."**

**검증 단계 (top-down)**: L5는 "테스트 설계에서 고정한 인수 시나리오 실행"이고, 통과 기준은 "GWT 시나리오 100% 통과 + 레거시 엔드포인트 커버리지표 100%".

**핵심 장치로 문서가 스스로 꼽는 것 두 가지**:
- "명세 추적표: 설계 누락을 구현 전에 잡는다."
- "테스트 설계 선행: 인수 기준을 구현 시작 전에 고정해, **구현이 설계를 끌고 가는 역전을 막는다.**"

그리고 마지막 줄이 커버리지 절의 복선입니다:
- **"커버리지 비교는 엔드포인트 단위: 클래스/파일 단위 비교는 신규 구조에서 무의미."**

> 💡 writer 메모: L1~L5는 **업계 표준이 아닙니다** (§2-7 검증 참조). 이 조직이 만든 사내 어휘예요. 본문에서 "표준 레벨 체계"로 소개하면 사실 오류입니다. 오히려 **"표준 이름이 없어서 각자 만든다"**는 점이 Fowler의 논지(§2-3)와 정확히 맞물리므로 그렇게 쓰는 편이 강합니다.

### 1-2. ★ 이 리서치의 핵심: 같은 비용, 다른 단언 [재구성]

같은 저장소, 같은 매퍼, 같은 애노테이션, 같은 실제 Oracle 접속. 테스트 두 벌이 있는데 **한쪽은 아무것도 검증하지 못하고 다른 한쪽은 쿼리 재작성의 동등성을 증명합니다.** 차이는 전부 "무엇을 통제하고 무엇을 단언하는가"에 있어요.

#### (가) 통제도 단언도 없는 쪽

```java
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

이 클래스는 테스트 메서드 11개가 전부 이 모양입니다. 그리고 매퍼 인터페이스의 메서드 11개는 **전부 `List<...>`를 반환**해요.

**결정적 사실: 이 단언은 실패할 수 없습니다.** MyBatis는 결과가 없을 때 `null`이 아니라 **빈 리스트**를 돌려줍니다. 1차 소스로 확인했습니다 (§3 V-1). 따라서 `isNotNull()`은 쿼리가 실행되기만 하면 무조건 통과하는 항진명제예요.

그렇다고 가치가 0이냐 하면 그건 아닙니다. **예외 없이 실행됐다는 것 자체는 검증합니다.** SQL 문법 오류, 없는 컬럼명, Oracle 방언 문제는 이 테스트가 잡아요. 실제 Oracle에 붙지 않으면 확인할 수 없는 것들이죠.

문제는 **이름과 단언이 서로 다른 말을 한다**는 데 있습니다. 이름은 `빈결과_반환`이라고 약속하는데, 단언은 빈 결과인지 만 건인지 구분하지 않아요. 이름이 단언보다 강한 명세입니다. 이름이 약속한 걸 검증하려면 `isEmpty()`여야 하죠.

> 💡 writer 메모: 여기서 "통합 테스트는 나쁘다"로 가면 안 됩니다. 경계 선택(실제 Oracle)은 **옳았어요.** 틀린 건 단언과 이름입니다. 정확한 결론은 "실제 DB 값을 치렀으면, 실제 DB만 답할 수 있는 것을 단언하라"입니다.

#### (나) 통제하고 단언하는 쪽

같은 매퍼를 대상으로, 같은 애노테이션 4개를 그대로 달고, 별도 클래스가 하나 더 있습니다.

```java
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

두 클래스의 차이를 정리하면 이렇습니다.

| | (가) 빈결과 IT | (나) 시딩 IT |
|---|---|---|
| 컨텍스트 비용 | 실제 Oracle | 실제 Oracle (동일) |
| 입력 통제 | 없음 | 대표 데이터 직접 적재 |
| 제외 케이스 | 없음 | 미등록, 날짜 불일치, 취소 상태 3종을 **일부러 심음** |
| 단언 | `isNotNull()` | 집계 결과를 손계산 기대값과 전수 대조 |
| 실패 가능성 | 쿼리 실행 실패 시에만 | WHERE 절, 조인, 집계 로직 중 하나만 틀려도 |
| 이름 | `빈결과_반환` | `시딩_동등성검증` |

**가장 중요한 관찰**: (나)가 구체적인 이유는 규율이 좋아서가 아닙니다. **답해야 할 질문이 생겼기 때문**이에요. 쿼리를 재작성해야 했고, 재작성 전후가 같음을 증명해야 했습니다. 그 목적이 단언을 구체적으로 만들었어요.

(가)에는 그런 질문이 없었습니다. 그래서 단언이 자라지 않았죠.

> 💡 writer 메모: **이게 1편의 결론 후보 1순위입니다.** "단언을 구체적으로 쓰자"는 훈계는 이미 체크리스트에 있고(§1-4), 지켜지지 않았습니다. 지켜지게 만든 건 훈계가 아니라 **테스트가 답해야 할 질문**이었어요. 경계를 정하는 실무적 방법은 "이 테스트가 무슨 질문에 답하는가"를 먼저 적는 것입니다.

또 하나 쓸 만한 디테일: 시딩 쪽은 `REQ_DT = "20991231"`이라는 **먼 미래 날짜를 센티널로** 씁니다. 공유 Oracle에 실 데이터와 섞여도 충돌하지 않게 하려는 장치예요. 그리고 `@MybatisTest`의 트랜잭션 롤백에 기대어 뒷정리를 생략합니다.

### 1-3. 약한 단언의 실제 분포: 총량은 적고, 비싼 곳에 몰린다

저장소 전체를 스크립트로 훑었습니다. 측정 기준은 "단언이 하나라도 있는 `@Test` 메서드 중, `isNotNull` / `assertNotNull` / `isNotEmpty` / `assertDoesNotThrow` **말고는 아무 단언도 없는** 메서드".

| 지표 | 값 |
|---|---|
| 테스트 파일 (`*Test*.java`) | 2,046개 |
| 단언이 있는 `@Test` 메서드 | 7,767개 |
| 그중 약한 단언만 있는 메서드 | **264개 (3.4%)** |

3.4%면 낮습니다. **"약한 단언이 만연하다"는 서술은 이 저장소에 대해 사실이 아닙니다.** 흥미로운 건 총량이 아니라 **분포**예요.

파일명 접미사로 갈라 보면 이렇습니다.

| 접미사 | 약한 단언만 | 전체 | 비율 |
|---|---|---|---|
| `*MapperOracleIT` | 27 | 37 | **73.0%** |
| `*IntegrationTest` | 27 | 229 | 11.8% |
| `*Test` (일반) | 210 | 7,484 | **2.8%** |
| `*OracleIT` (매퍼 아님) | 0 | 17 | 0.0% |

**실제 Oracle을 띄우는 매퍼 통합 테스트에서 약한 단언의 밀도가 일반 단위 테스트의 26배입니다.** 가장 비싼 테스트가 가장 적게 검증해요.

그런데 `*OracleIT` 중 매퍼가 아닌 것들은 **0%**입니다. 같은 Oracle 비용을 치르면서 전부 구체적으로 단언해요. 그러니 "통합 테스트라서 약하다"가 아니라 **"매퍼 테스트라서 약하다"**입니다.

원인은 §1-2가 보여줍니다. 매퍼 테스트에 **픽스처가 없으면** 단언할 값 자체가 없어요. 통제된 입력이 없으니 "실행됐다" 말고는 할 말이 없는 겁니다. 그리고 픽스처를 만드는 건 품이 들죠. 그래서 비싼 인프라를 띄워 놓고 값싼 단언을 답니다.

> 💡 writer 메모: 이 표가 본문의 수치 근거로 좋습니다. 다만 **3.4%를 숨기지 마세요.** "우리 저장소는 약한 단언 투성이"로 과장하면 정직하지 않고, 검증에서 깨집니다. 정확한 이야기는 "총량은 적은데 하필 가장 비싼 테스트에 몰려 있다"예요. 이게 훨씬 좋은 이야기이기도 합니다.

### 1-4. 기준은 이미 문서로 있었다 [원문 인용 가능]

이 사용자의 하네스 플러그인에 코딩 원칙 스킬이 있고, 그 §3이 테스트를 다룹니다. **공개 플러그인 파일이라 원문 인용이 가능합니다.**

출처: `~/.claude/plugins/cache/sr-harness/sr-harness/0.23.0/skills/dev-coding-principles/SKILL.md`

- `:38` `## §3 Test`
- `:40` **목표**: 테스트는 코드의 동작 명세다 — 구현이 아닌 의도를 검증한다.
- `:42` **given-when-then 구조** 필수
- `:51` **테스트 이름은 한국어 의도 표현**: `결제_금액이_0원이면_예외를_던진다()` ✅ / `test1()` ❌
- `:53` **단위 테스트 우선**: 도메인 로직(Entity, VO, Domain Service)은 외부 의존 없이 단위 테스트
- `:54` **통합 테스트 경계**: 외부 경계(Repository, HTTP Client)만 통합 테스트 — 비즈니스 로직 중복 검증 금지
- `:55` **픽스처 분리**: 테스트 데이터 생성은 `*Fixture` 클래스로 분리하여 재사용
- `:56` **단언은 구체적으로**: `assertThat(result).isNotNull()` ❌ → `assertThat(result.getStatus()).isEqualTo(COMPLETED)` ✅

**`:56`이 반문(反問) 없이 정확히 §1-2와 §1-3의 안티패턴을 지목합니다.** 기준이 없어서 못 지킨 게 아니에요. 기준은 있었고, 심지어 나쁜 예시로 `isNotNull()`을 콕 집어 적어 뒀는데, 264곳에서 그대로 나타납니다.

체크리스트 절(`:71-74`)도 있습니다.

```
§3 Test
[ ] given-when-then 구조인가?
[ ] 테스트 이름이 한국어로 의도를 표현하는가?
[ ] 단위/통합 테스트 경계가 올바른가?
```

> 💡 writer 메모: 이 파일은 **3편의 주인공**입니다. 1편에서는 "기준 문서는 이미 있었다"는 사실 확인까지만 쓰고, "그래서 에이전트에게 어떻게 위임하나"로 넘어가지 마세요. 다만 1편이 3편의 전제를 깔아 주는 건 좋습니다.

### 1-5. ★ 지켜진 규칙과 안 지켜진 규칙이 갈린 자리

§1-4의 체크리스트 항목을 실제 저장소에서 측정했습니다. `@Test` 메서드 10,379개 기준.

| 규칙 | 준수율 |
|---|---|
| 테스트 이름이 한국어로 의도 표현 (메서드명에 한글) | **50.0%** (5,186개) |
| `@DisplayName` 보유 | **73.6%** (7,641개) |
| 단언이 구체적 (약한 단언만 있지 않음) | 96.6% (§1-3) |

모듈별로 보면 편차가 큽니다.

| 모듈 성격 | 한글 메서드명 비율 |
|---|---|
| 최근 재구축 모듈들 | 95.6% ~ 100% |
| 결제 도메인 레거시 | 49% ~ 82% |
| 금융 프로토콜(FIX) 모듈들 | **0%** |

FIX 프로토콜 모듈이 0%인 건 위반이라기보다 **도메인 어휘가 영어**여서로 보입니다. 프로토콜 필드명이 전부 영문 약어라 한글 이름이 오히려 부자연스러운 자리예요.

**여기서 가장 날카로운 관찰**: §1-3에서 약한 단언 밀도가 73%로 최악이었던 매퍼 IT들이 속한 모듈은, **한글 테스트 이름 준수율이 95.6%로 저장소 최상위권**입니다.

즉 같은 팀이 같은 체크리스트를 보고,
- **기계적으로 확인 가능한 규칙**(이름에 한글이 있는가)은 95% 지켰고,
- **판단이 필요한 규칙**(이 단언이 구체적인가)은 73%를 어겼습니다.

체크리스트가 형식으로 만든 항목은 통과하고, 사고를 요구하는 항목은 통과하지 못했어요.

> 💡 writer 메모: **결론 후보 2순위이자, 3편으로 가는 다리입니다.** 다만 여기서 "그래서 AI에게 시키자"로 넘어가면 3편을 선점합니다. 1편에서는 "규칙의 검사 가능성이 준수율을 결정한다"까지만 쓰세요. §1-2의 "질문이 단언을 만든다"와 짝을 이루면 좋습니다.

### 1-6. 초록불인데 틀린 단언 [재구성]

레거시 시스템을 새 구조로 재구축하면서, 두 시스템의 동작 차이(drift)를 전수 대조한 문서가 있습니다. 거기서 발견된 사례 하나가 특히 날카롭습니다.

**상황**: 외부 파트너에게 위임 정보를 조회(Retrieve)했는데 실패했을 때, 원장 테이블에 행을 적재하는가?

- 레거시의 실제 동작: **적재한다** (상태값 `ISSUED`)
- 새 구현의 동작: 적재하지 않는다
- 새 구현의 테스트: `verify(billHistoryRepository, never()).insert(any())`
- 새 구현의 주석: "(레거시 동일)"

**테스트도 주석도 틀렸습니다.** 테스트는 초록불이었고, 커버리지에도 잡혔고, 레거시와 다른 동작을 "레거시와 같다"고 잠그고 있었어요.

문서의 판정을 요지만 옮기면: 테스트가 `never().insert()`로 레거시를 **잘못 단언**하고 있었다.

교정된 테스트는 이렇게 바뀝니다 (구조만).

```java
// 교정 전
verify(billHistoryRepository, never()).insert(any());

// 교정 후
ArgumentCaptor<BillHistoryRecord> captor = ArgumentCaptor.forClass(BillHistoryRecord.class);
verify(billHistoryRepository).insert(captor.capture());
assertThat(captor.getValue().getStatus()).isEqualTo(BillHistoryStatus.ISSUED);
assertThat(captor.getValue().getBid()).isEqualTo(BID);
assertThat(captor.getValue().getBuyerId()).isEqualTo(BID);
```

**부정 단언(`never()`)은 긍정 단언보다 훨씬 쉽게 틀린 이유로 통과합니다.** `never().insert()`는 이런 경우에 전부 통과해요.

1. 코드가 정말로 insert하지 않을 때 (의도한 경우)
2. 코드가 그 분기에 **도달하지 못했을 때**
3. mock이 다른 객체에 물려 있을 때
4. 조건이 바뀌어 그 경로가 죽은 코드가 됐을 때

1번만 참인 검증이고, 2~4번은 거짓 통과입니다. 반면 교정 후의 `ArgumentCaptor` 버전은 **실제로 호출되어야만** 통과해요.

`@DisplayName`도 함께 교정됐습니다. 교정 후 이름은 "Retrieve 비2xx: U513, NOTI void, 보상 없음 + 원장 INSERT(issued), 레거시 동일(Retrieve 실패에도 적재)". **이름이 명세를 통째로 지고 있어요.** 그래서 명세가 틀렸을 때 이름과 단언이 함께 틀렸고, 함께 고쳐졌습니다.

> 💡 writer 메모: "테스트 이름이 곧 명세"라는 주제를 이 사례가 양방향으로 보여줍니다. 이름이 명세를 지면 명세 오류가 이름에 드러나고, 이름만 보고 리뷰할 수 있게 되죠. 반대로 §1-2의 `빈결과_반환`처럼 이름이 단언보다 강하면 이름이 거짓말을 합니다.

### 1-7. 중복 검증을 막는 장치: 불변식 × 레이어 매핑표 [재구성]

"같은 로직을 여러 레벨에서 중복 검증하지 말 것"은 §1-4의 체크리스트에도 있는 규칙인데, 이 조직은 그걸 **표로** 만들었습니다. 구조만 옮기면 이렇습니다.

| 불변식 | L1 (도메인) | L3 (어댑터) | L5 (인수) |
|---|---|---|---|
| 큐 조회 고정 조건 | — | mapper WHERE 검증 | AT-01-8 |
| 상태 전이 | 판정표 6행 전수 | updateResult | AT-01-1~7 |
| 응답값 정규화 판정 | 정규화 케이스 전수 | — | AT-01-2~4 |
| 특정 테이블 읽기 전용 | — | 쓰기 mapper 부재 확인 | 변경 0건 |
| 만료 멱등 | 판정 로직(L2) | UPDATE 0건/1건 | AT-09-1·11·14 |
| ID 매핑 | 5케이스 전수 | — | 적용 지점 전수 |

**이 표에서 가장 중요한 칸은 `—`입니다.** "이 레이어는 이 불변식에 대해 할 말이 없다"를 명시적으로 적어 둔 거예요. 중복 검증 금지가 훈계가 아니라 **표의 빈칸**으로 구현돼 있습니다.

그리고 채워진 칸들은 서로 다른 걸 봅니다. 같은 "만료 멱등" 불변식이 L2에서는 판정 로직, L3에서는 UPDATE 영향 행 수(0건이냐 1건이냐), L5에서는 시나리오 3건으로 나뉘어요. **중복이 아니라 분해입니다.**

같은 계열의 장치가 하나 더 있습니다. 인수 시나리오 39건 중 4건에 `(L1)` 태그가 붙어 있어요. 전부 순수 계산입니다.

- 결제수단 별칭 전수 변환
- 레거시 코드값 보존
- 서명 데이터 입력 순서와 hex 소문자
- 검증 스펙 62종과 에러코드

**비즈니스가 요구하는 인수 기준이지만 I/O가 필요 없는 것들**이고, 그래서 "이건 L1에서 해결한다"고 태그로 못 박았습니다. 인수 테스트에서 다시 돌리지 않겠다는 선언이에요.

### 1-8. 테스트하지 않기로 한 것을 문서화한다 [재구성]

같은 테스트 설계 문서에 `명문화된 설계 한계 (테스트 범위 제외)` 절이 있습니다. 구조만 옮기면 이런 항목들이에요.

| 한계 | 근거와 완화책 |
|---|---|
| 동시 이중 호출 시 중복 발송 가드 없음 | 레거시 동일(분산 락 없음). 수신 측 멱등 전제. 도입은 후속 단계에서 재론 |
| 비동기 수락 후 프로세스 다운 시 발송 유실 | 레거시 동일. 상태값이 유지되므로 외부 배치 재발송 경로가 회복 수단 |
| 특정 실패 경로의 계약 미정 | 구현 전 레거시 코드 대조로 확정 |

**커버리지 퍼센트가 답하지 못하는 걸 이 표가 답합니다.** "무엇이 안 덮였나"에 대해 숫자는 "17%"라고만 말하지만, 이 표는 무엇이 왜 빠졌고 대신 뭐가 그 위험을 받아 주는지를 말해요.

Google의 커버리지 가이드가 정확히 같은 말을 합니다(§2-4): "What's not covered is more meaningful than what is covered."

### 1-9. 커버리지 임계값은 문서에만 있고 빌드에는 없다 [재구성]

이건 검증하면서 나온 결과라 특히 조심스럽게 써야 합니다.

**문서가 규정하는 것**: 인수 단계 통과 조건 다섯 개 중 하나가 "jacoco LINE 커버리지 60% 최소". 어떤 모듈의 설계 문서는 한술 더 떠서 "모듈 하한 60%, 단 **domain과 application 패키지는 LINE 80% + BRANCH 70%**"로 레이어별 차등을 둡니다. 이유도 적혀 있어요. "파일럿이 후속 단계의 전례가 되므로 핵심 레이어는 상향."

**빌드가 실제로 강제하는 것**: 재구축 트랙 4개 모듈을 확인한 결과입니다.

| 모듈 | jacoco 플러그인 | 임계값 검증 태스크 | `check`에 연결 |
|---|---|---|---|
| A | 있음 | 있음 (LINE 60%) | **없음** |
| B | 있음 | **없음** (리포트만) | 해당 없음 |
| C | 있음 | **없음** (리포트만) | 해당 없음 |
| D | 있음 | **없음** (리포트만) | 해당 없음 |

**문서가 "합격 조건"이라고 적은 60%를 강제하는 빌드는 하나도 없습니다.** 모듈 A만 검증 태스크를 정의했는데, 그마저 `check`에 걸려 있지 않아서 누가 명시적으로 호출하지 않으면 돌지 않아요. 문서가 레이어별 차등(80%/70%)을 규정한 모듈은 검증 태스크 자체가 없습니다.

저장소 전체로 넓히면 임계값이 제각각입니다: 30%, 50%, 60%, 70%, 80%. 어떤 모듈은 주석까지 달아 뒀어요. "50% 라인 커버리지 (현실적 초기 게이트)". `check`에 실제로 연결된 모듈도 있긴 합니다(별도 `testCoverage` 태스크로 묶어 둠).

> 💡 writer 메모: 여기서 "그러니 커버리지는 쓸모없다"로 가지 마세요. Marick과 Google과 Fowler 셋 다 그렇게 말하지 않습니다(§2-4). 정확한 관찰은 **"숫자가 판단을 대체하려 할 때, 조직은 조용히 그 숫자를 배선하지 않는 쪽을 택했다"**입니다. 아무도 60%를 반대하지 않았고, 아무도 켜지도 않았어요. Marick의 85% 게이트 관찰(§2-4)과 정확히 같은 힘이 반대 방향으로 작용한 사례로 읽을 수 있습니다.
>
> 그리고 **한 가지는 실제로 배선돼 있습니다**: 커버리지 제외 목록. 어떤 모듈은 순수 데이터 POJO, 커맨드/결과 레코드, 열거형, 설정 클래스, 진입점을 커버리지 계산에서 뺍니다. **"이건 테스트 대상이 아니다"라는 경계 판단이 빌드 파일에 실제로 적혀 있는 유일한 자리**예요.

### 1-10. 게이트를 끄는 두 가지 방법 [재구성]

같은 저장소의 두 모듈이 같은 문제를 정반대로 처리했고, 한쪽이 다른 쪽이 왜 틀렸는지를 주석으로 적어 뒀습니다.

**모듈 X: 게이트를 끈다**

```groovy
test {
    useJUnitPlatform()
    // 원본 parity: 52/280건이 로컬 DB 스키마·pem 키 부재로 원본부터 실패 (이관 회귀 0건 검증 완료)
    // 테스트 그린화 후 제거 예정
    ignoreFailures = true
}
```

테스트 280건 중 52건이 환경 문제로 실패하는데, 빌드는 초록불로 나옵니다.

**모듈 Y: 테스트를 가른다**

```groovy
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

(주석 원문의 중간점은 사내 코드 표기 그대로입니다. 본문에 옮길 때는 재구성이므로 쉼표로 바꿔도 됩니다.)

**같은 진단, 반대 처방입니다.** 둘 다 "환경에 좌우되는 테스트가 게이트 안에 있다"를 문제로 봤어요. X는 게이트의 민감도를 껐고, Y는 테스트를 게이트 밖으로 옮겼습니다.

Y의 주석이 X의 결과를 정확히 예측합니다: "빌드 통과"가 근거로서 무의미해진다. 그리고 Y는 한 걸음 더 나가요. **환경 의존 테스트를 게이트에 두면 "게이트를 다시 끄는 압력"이 생긴다**는 것. 이건 테스트 설계 문제가 아니라 **인센티브 설계 문제**입니다.

> 💡 writer 메모: 이게 1편의 "경계" 주제를 가장 넓게 확장하는 소재입니다. 경계는 "무엇을 단위로 볼 것인가"만이 아니라 **"무엇을 게이트 안에 둘 것인가"**이기도 해요. 그리고 후자를 잘못 그으면 게이트 자체가 무력화됩니다.
>
> ⚠️ 익명화 주의: X와 Y가 같은 조직의 다른 모듈이라는 점은 써도 되지만, 어느 쪽이 먼저인지 시간 순서나 이슈 번호는 쓰지 마세요.

### 1-11. 이 블로그 저장소의 계약 테스트 [원문 인용 가능]

여기서부터는 **원문 그대로 인용 가능**합니다. 이 블로그 저장소예요.

`test/site_output_test.rb`는 Jekyll을 실제로 빌드한 다음 **생성된 HTML을 읽어서** 단언합니다. 구현이 아니라 산출물을 봐요.

```ruby
assert_match(/<html[^>]+lang="ko"/, index)
assert_match(%r{<link rel="canonical" href="https://seokrae\.github\.io/blog/">}, index)
```
(`test/site_output_test.rb:37-38`)

각 단언에 **깨졌을 때 무슨 일이 생기는지**가 주석으로 붙어 있는 게 특징입니다.

```ruby
# 제목의 &와 따옴표가 escape돼야 한다 — 안 그러면 속성이 깨져 미리보기가 잘린다
assert_includes post, %(<meta property="og:title" content="Tom &amp; Jerry &quot;quoted&quot;">)
```
(`test/site_output_test.rb:45-46`)

부정 단언이 계약을 지킵니다. 외부 요청 0이라는 계약은 "없어야 한다"로만 표현되거든요.

```ruby
refute_match(%r{<link[^>]*\shref="https?://[^"]*\.css}, index, "외부 스타일시트를 받으면 안 된다")
refute_includes index, "fontawesome"
```
(`test/site_output_test.rb:52-53`)

```ruby
refute_match(%r{<script[^>]*\ssrc="https?://}, search, "검색은 외부 스크립트 없이 동작해야 한다")
```
(`test/site_output_test.rb:58`)

그리고 서비스 워커 tombstone처럼 **왜 이게 있어야 하는지가 자명하지 않은** 계약에는 배경까지 적혀 있습니다.

```ruby
# Chirpy PWA가 /blog/sw.min.js에 심어둔 서비스 워커를 자폭시키는 tombstone. 이 경로가
# 비면 Chirpy 시절 방문자의 브라우저가 옛 캐시(포스트 없는 홈)에 영구히 갇힌다. (#34)
sw_path = File.join(destination, "sw.min.js")
assert File.exist?(sw_path), "tombstone 서비스 워커가 /blog/sw.min.js로 발행돼야 한다"
assert_includes sw, "registration.unregister", "sw.min.js는 자기 등록을 해제해야 한다"
assert_includes sw, "caches.delete", "sw.min.js는 옛 캐시를 비워야 한다"
```
(`test/site_output_test.rb:64-70`)

**이 테스트가 좋은 이유**: 테마가 remote theme라 소스가 이 저장소에 없습니다. 구현을 테스트할 방법이 아예 없어요. 그래서 **산출물에 경계를 그었고**, 그 덕에 테마 커밋을 올려도 계약이 깨지면 바로 드러납니다. 경계를 "내가 통제할 수 있는 것"이 아니라 **"사용자가 실제로 받는 것"**에 그은 사례입니다.

### 1-12. ★ 반대 방향의 실패: 같은 파일의 과잉 구체성 [원문 인용 가능]

같은 파일에 정반대 문제가 있습니다. **자기 저장소라 마음껏 비판할 수 있는 자리예요.**

```ruby
assert_equal 30, rate_limiter_post.scan(/class="rl-mem-track"/).length,
  "패널 6개 × 눈금 5칸의 메모리 인디케이터가 있어야 한다"
```
(`test/site_output_test.rb:108-109`)

```ruby
assert_match(/\.rl-algo-embed \.rl-grid\{\s*display:grid;grid-template-columns:repeat\(3,1fr\)/,
  rate_limiter_post, "알고리즘 패널이 3열 그리드여야 한다")
```
(`test/site_output_test.rb:112-113`)

```ruby
assert_match(/th,td\{border:none;border-bottom:1px solid rgba\(0,0,0,0\.1\)/,
  css, "표 세로선이 없고 가로 구분선만 있어야 한다")
assert_match(/tbody tr:nth-child\(even\)\{background:rgba\(0,0,0,0\.025\)\}/,
  css, "지브라 스트라이프가 있어야 한다")
```
(`test/site_output_test.rb:117-120`)

```ruby
assert_equal 4, rate_limiter_post.scan(/class="tbl-good"/).length,
  "O(1) 4곳에 상태색이 있어야 한다"
```
(`test/site_output_test.rb:121-122`)

**"이 단언은 무엇이 바뀌면 실패하는가"를 물어보면 차이가 드러납니다.**

| 단언 | 실패 조건 | 그게 진짜 고장인가 |
|---|---|---|
| `lang="ko"` 없음 | 언어 표기가 사라짐 | ✅ 접근성과 SEO가 실제로 깨진다 |
| 외부 스타일시트 등장 | 외부 요청 0 계약 위반 | ✅ 의도적으로 지킨 계약이 깨진다 |
| 그리드가 3열이 아님 | 디자인을 2열로 바꿈 | ❌ **고장이 아니라 결정이다** |
| 지브라 배경이 `0.025`가 아님 | 색을 미세 조정함 | ❌ 고장이 아니다 |
| `tbl-good`이 4개가 아님 | 표에 행을 추가함 | ❌ 고장이 아니다 |

아래 셋은 **change detector**입니다. 프로덕션 코드를 바꾸면 무조건 깨지는데, 바뀐 동작이 옳은지 그른지는 아무것도 말해 주지 않아요. Google Testing Blog의 정본 정의가 정확히 이겁니다(§2-6).

**§1-2의 `isNotNull()`과 정확히 대칭입니다.**

- `isNotNull()`: 고장 났는데도 통과한다 (너무 느슨함)
- `assert_equal 30, ...scan(...)`: 고장 안 났는데도 실패한다 (너무 빡빡함)

둘 다 "단언이 실제 계약을 추적하지 못한다"는 같은 병의 양쪽 끝이에요. **구체성은 단조 증가하는 미덕이 아닙니다.**

> 💡 writer 메모: **이 대칭이 1편의 가장 좋은 뼈대입니다.** "단언은 구체적으로"라는 흔한 조언이 왜 불충분한지를 자기 코드로 보여줄 수 있어요. 올바른 질문은 "얼마나 구체적인가"가 아니라 **"무엇이 바뀌면 이게 실패해야 하는가"**입니다.
>
> 자기비판이라 안전하고, 사내 코드를 흠잡는 것보다 훨씬 설득력 있습니다. 이 소재를 아끼지 말고 쓰세요.

### 1-13. 경계가 만드는 사각지대 [원문 인용 가능]

`CLAUDE.md:34`가 이 블로그의 실제 사건을 기록합니다.

> `assets/js/search.js`는 lunr을 쓰지 않는다 — lunr 파이프라인의 trimmer가 `\W`로 토큰을 잘라 **한글 토큰을 빈 문자열로 만들기 때문에** 한국어 질의가 전부 0건이 된다 (#12). 대신 substring 매칭을 쓰고, 이 동작은 `test/search_test.js`에 잠겨 있다. HTML 계약 테스트는 JS 동작을 검증하지 못하므로 검색 로직을 고치면 **두 테스트를 모두** 돌린다.

**계약 테스트가 전부 통과하는 동안, 라이브 사이트의 한국어 검색은 항상 0건이었습니다.** HTML을 읽는 테스트는 JS를 실행하지 않으니까요. 테스트 스위트의 경계가 곧 그 스위트가 볼 수 없는 결함의 범위입니다.

고친 방법도 경계 이야기예요. lunr을 버리고 substring 매칭으로 바꾼 뒤, **JS를 실제로 실행하는 별도 테스트**를 만들었습니다.

```javascript
// 검색 매칭 계약. 한국어 질의가 조용히 0건이 되는 회귀를 막는다. (#12)
```
(`test/search_test.js:1`)

```javascript
// 한국어 — 이 블로그의 주 언어. lunr trimmer 회귀 시 전부 0건이 된다.
assert.deepStrictEqual(refs("문서"), ["flowcast"], "제목의 한글이 검색돼야 한다");
assert.deepStrictEqual(refs("다이어그램"), ["flowcast"], "본문의 한글이 검색돼야 한다");
assert.deepStrictEqual(refs("블로그"), ["type-theme"], "태그의 한글이 검색돼야 한다");
assert.deepStrictEqual(refs("회고"), ["flowcast", "type-theme"], "여러 글의 공통 태그가 모두 걸려야 한다");
```
(`test/search_test.js:32-36`)

빈 질의 처리처럼 **조용히 새는 경로**도 함께 잠갔습니다.

```javascript
// 빈 질의 — 전체 매칭으로 새지 않아야 한다
assert.deepStrictEqual(refs(""), [], "빈 질의는 0건");
assert.deepStrictEqual(refs("   "), [], "공백뿐인 질의는 0건");
assert.deepStrictEqual(refs(null), [], "null 질의는 0건");
```
(`test/search_test.js:51-54`)

> 💡 writer 메모: §1-11과 §1-13을 나란히 두면 좋습니다. 같은 저장소에서 **경계를 잘 그은 사례**(산출물 계약)와 **경계 밖이라 못 본 사례**(JS 미실행)가 함께 나와요. "모든 걸 덮는 테스트는 없고, 안 덮이는 게 무엇인지 아는 것이 경계"라는 결론으로 이어집니다.

---

## 2. 근거: 외부 (2차)

모두 실제 페이지를 열어 확보한 원문입니다. 번역하지 않았으니 writer가 필요한 부분만 옮기세요.

### 2-1. 테스트 피라미드의 출처와 원 주장

출처: https://martinfowler.com/bliki/TestPyramid.html (Martin Fowler, 2012-05-01)

> "The test pyramid is a way of thinking about how different kinds of automated tests should be used to create a balanced portfolio. Its essential point is that you should have many more low-level UnitTests than high level BroadStackTests running through a GUI."

> "In short, tests that run end-to-end through the UI are: brittle, expensive to write, and time consuming to run. So the pyramid argues that you should do much more automated testing through unit tests than you should through traditional GUI based testing."

**출처(Etymology 절 원문)**:

> "Most people know about the the Test Pyramid due to Mike Cohn, when he described it in his 2009 book Succeeding with Agile. In the book he refers to it as the “Test Automation Pyramid”, but in use it's generally referred to as just the “test pyramid”. He originally drew it in conversation with Lisa Crispin in 2003-4 and described it at a scrum gathering in 2004. Jason Huggins independently came up with the same idea around 2006."

(원문에 `the the`가 실제로 중복돼 있습니다. 인용하려면 그대로 옮기거나 그 부분을 피하세요.)

**Fowler 본인의 유보**:

> "The pyramid is based on the assumption that broad-stack tests are expensive, slow, and brittle compared to more focused tests, such as unit tests. While this is usually true, there are exceptions. If my high level tests are fast, reliable, and cheap to modify - then lower-level tests aren't needed."

> "I always argue that high-level tests are there as a second line of test defense. If you get a failure in a high level test, not just do you have a bug in your functional code, you also have a missing or incorrect unit test."

🛑 **정정 주의**: 이 페이지에 **"two points"라는 표현은 없습니다.** 원문은 `"essential point"`(단수)예요. "Fowler가 두 가지 요점을 말했다"고 쓰면 사실 오류입니다. → §3 V-2

### 2-2. 대안 형태들 (맥락이 전부다)

#### 트로피 (프론트엔드 JavaScript 맥락)

출처: https://kentcdodds.com/blog/write-tests , https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications (Kent C. Dodds)

"Write tests. Not too many. Mostly integration."의 **원 출처는 Dodds가 아니라 Guillermo Rauch의 트윗**입니다. Dodds가 직접 밝혀요.

> "A while back, Guillermo Rauch‏ (creator of Socket.io and founder of Zeit.co (the company behind a ton of the awesome stuff coming out lately)) tweeted something profound:"

트윗 원문과 날짜: `"Write tests. Not too many. Mostly integration."` (Guillermo Rauch @rauchg, 4:43 PM UTC, **December 10th, 2016**)

**★ 맥락 한정을 Dodds 본인이 명시합니다. 이게 이 절에서 가장 중요한 인용입니다.**

> "I can't speak for Guillermo, but I agreed so strongly with what he said because of my experience as a UI engineer and how I personally had come to understand the term “integration” in this context."

> "The reason I explain this background is to help you understand the way the Testing Trophy is intended to be interpreted. **I never considered whether it applied to microservices or even backend services at all.** I considered my codebase in isolation and attempted to categorize the types of tests I could write within the confines of my own code ownership."

커버리지 목표치 비판도 있습니다.

> "I've heard managers and teams mandating 100% code coverage for applications. That's a really bad idea. The problem is that you get diminishing returns on your tests as the coverage increases much beyond 70% (I made that number up... no science there)."

⚠️ 발행 연도 주의: `write-tests` 페이지 표기는 2019-07-13이지만, 트로피 글에서 Dodds가 인용한 자기 트윗은 2017-10-16입니다. **연도를 못 박지 마세요.**

#### 허니콤 (마이크로서비스 맥락)

출처: https://engineering.atspotify.com/2018/1/testing-of-microservices (André Schaffer, Rickard Dybeck, 2018-01-11)

> "Most people are familiar with the famous Testing Pyramid. For a long time this was an extremely efficient way to organize tests. In a Microservices world, this is no longer the case, and we would argue that it can be actively harmful."

> "The biggest complexity in a Microservice is not within the service itself, but in how it interacts with others, and that deserves special attention."

> "Having too many unit tests in Microservices, which are small by definition, also restricts how we can change the code without also having to change the tests. By having to change the tests we lose some confidence that the code still does what it should and it has a negative impact on the speed we iterate at."

**★ 그리고 Spotify가 스스로 "단위의 정의를 바꿨다"고 자백합니다. §2-3의 근거가 됩니다.**

> "By the way, you may have noticed that what we've been treating the Microservice as an isolated Component, tested through its contracts. In that sense the Microservice has become our new Unit, which is why we have avoided the use of the term Unit Tests for Microservices in favour of Implementation Detail Tests."

트레이드오프도 정직하게 적습니다.

> "The trade-off here is some loss of speed in test execution. The suite goes from milliseconds to a few seconds..."

### 2-3. ★ Fowler의 해소: 논쟁은 용어 정의 문제였다

출처: https://martinfowler.com/articles/2021-test-shapes.html (**Martin Fowler 본인**, 2021-06-02, 부제 "Pyramids, honeycombs, trophies, and the meaning of unit testing")

> "The second biggest issue I have with this discussion is that it's rendered opaque by the fact that it's not clear what people see as the difference between unit and integration tests."

> "So, going back to pyramids versus honeycombs, when I read advocates of honeycomb and similar shapes, I usually hear them criticize the excessive use of mocks and talk about the various problems that leads to. From this I infer that their definition of “unit test” is specifically what I would call a solitary unit test. Similarly their notion of integration test sounds very much like what I would call a sociable unit test. **This makes the pyramid versus honeycomb discussion moot**, since any descriptions I've heard of the test pyramid consider unit tests to be sociable and/or solitary."

> "The take-away here is when anyone starts talking about various testing categories, dig deeper on what they mean by their words, as they probably don't use them the same way as the last person you read did."

**그리고 Fowler가 꼽는 "biggest issue"는 Justin Searls의 말을 빌려 옵니다.**

> "People love debating what percentage of which type of tests to write, but it's a distraction. Nearly zero teams write expressive tests that establish clear boundaries, run quickly & reliably, and only fail for useful reasons. Focus on that instead."
> (Justin Searls)

🛑 **이 문장은 Searls의 것입니다. Fowler의 말로 인용하면 안 됩니다.** → §3 V-3

> 💡 writer 메모: **Searls 인용문이 1편의 주제문에 가장 가깝습니다.** "only fail for useful reasons"가 §1-12의 대칭(너무 느슨함 vs 너무 빡빡함)을 한 문장으로 요약해요. 그리고 "비율 논쟁은 distraction"이라는 판정이 이 글이 피라미드 형태 논쟁에 발을 담그지 않아야 할 이유가 됩니다.

### 2-4. 커버리지 숫자

#### Fowler

출처: https://martinfowler.com/bliki/TestCoverage.html (2012-04-17)

> "From time to time I hear people asking what value of test coverage (also called code coverage) they should aim for, or stating their coverage levels with pride. Such statements miss the point. Test coverage is a useful tool for finding untested parts of a codebase. Test coverage is of little use as a numeric statement of how good your tests are."

> "If you make a certain level of coverage a target, people will try to attain it. The trouble is that high coverage numbers are too easy to reach with low quality testing."

**★ 숫자 대신 쓸 판정 기준을 제시합니다. §1-9의 대안으로 좋습니다.**

> "Sufficiency of testing is much more complicated attribute than coverage can answer. I would say you are doing enough testing if the following is true: You rarely get bugs that escape into production, and You are rarely hesitant to change some code for fear it will cause production bugs."

> "So what is the value of coverage analysis again? Well it helps you find which bits of your code aren't being tested. It's worth running coverage tools every so often and looking at these bits of untested code. Do they worry you that they aren't being tested?"

#### Marick (원 출처, 1997)

출처: http://www.exampler.com/testing-com/writings/coverage.pdf (Brian Marick, "How to Misuse Code Coverage", Copyright 1997, 1999 재배포)

> "Code coverage tools measure how thoroughly tests exercise programs. I believe they are misused more often than they're used well."

**★ 핵심 비유: 명령이 아니라 단서**

> "I warn against it by saying that coverage tools don't give commands (“make that evaluate true”), they give clues (“you made some mistakes somewhere around there”). If you treat their clues as commands, you'll end up in the fable of the Sorcerer's Apprentice: causing a disaster because your tools do something very precisely, very enthusiastically, and with inhuman efficiency - but that something is only what you thought you wanted."

**★ 85% 게이트의 실증 관찰. §1-9와 정확히 짝을 이룹니다.**

> "Suppose a manager requires some level of coverage, perhaps 85%, as a “shipping gate”. The product is not done - and you can't ship - until you have 85% coverage."

> "when I talk about coverage to organizations that use 85%, say, as a shipping gate, I sometimes ask how many people have gotten substantially higher, perhaps 90%. There's usually a few who have, but everyone else is clustered right around 85%. Are we to believe that those other people just happened to hit 85% and were unable to find any other tests worth writing? Or did they write a first set of tests, take their coverage results, bang away at the program until they got just over 85%, and then heave a sigh of relief at having finished a not-very-fun job?"

> "Coverage numbers (like many numbers) are dangerous because they're objective but incomplete. They too often distort sensible action. Using them in isolation is as foolish as hiring based only on GPA."

> "I wouldn't have written four coverage tools if I didn't think they're helpful. But they're only helpful if they're used to enhance thought, not replace it."

⚠️ 1997년 문서입니다. "최근 연구"로 쓰면 안 됩니다.

#### Google

출처: https://testing.googleblog.com/2020/08/code-coverage-best-practices.html (Carlos Arguelles, Marko Ivanković, Adam Bender, 2020-08-07)

**★ 커버리지가 못 잡는 것의 정확한 구분**

> "Bad code being pushed to production due to missing tests could happen either because (a) your tests did not cover a specific path of code, a test gap that is easy to identify with code coverage analysis, or (b) because your tests did not cover a specific edge case in an area that did have code coverage, which is difficult or impossible to catch with code coverage analysis. **Code coverage does not guarantee that the covered lines or branches have been tested correctly, it just guarantees that they have been executed by a test.**"

> "A high code coverage percentage does not guarantee high quality in the test coverage. Focusing on getting the number as close as possible to 100% leads to a false sense of security."

**★ 목표치에 대한 입장 (§1-9의 60%와 직접 비교 가능)**

> "There is no “ideal code coverage number” that universally applies to all products. ... We cannot mandate every single team should have x% code coverage; this is a business decision best made by the owners of the product with domain-specific knowledge. ... **Be mindful that engineers may start treating your target like a checkbox and avoid increasing coverage beyond the target, even if doing so would be prudent.**"

> "Although there is no “ideal code coverage number,” at Google we offer the general guidelines of 60% as “acceptable”, 75% as “commendable” and 90% as “exemplary.” However we like to stay away from broad top-down mandates and encourage every team to select the value that makes sense for their business needs."

**★ §1-8과 정확히 같은 말**

> "More important than the percentage of lines covered is human judgment over the actual lines of code (and behaviors) that aren't being covered (analyzing the gaps in testing) and whether this risk is acceptable or not. **What's not covered is more meaningful than what is covered.**"

뮤테이션 테스팅으로 넘어가는 다리도 놓습니다.

> "Be mindful of copy/pasting tests just for the sake of increasing coverage, or adding tests with little actual value, to comply with the number. A better technique to assess whether you're adequately exercising the lines your tests cover, and adequately asserting on failures, is mutation testing."

### 2-5. 뮤테이션 테스팅: 단언 없는 테스트를 잡는 지표

출처: https://pitest.org/ (PIT 공식)

> "Mutation testing is conceptually quite simple. Faults (or mutations) are automatically seeded into your code, then your tests are run. If your tests fail then the mutation is killed, if your tests pass then the mutation lived. The quality of your tests can be gauged from the percentage of mutations killed."

**★ "What's wrong with line coverage?" 절. §1-2의 항진명제 단언을 정확히 설명합니다.**

> "Traditional test coverage (i.e line, statement, branch, etc.) measures only which code is executed by your tests. It does not check that your tests are actually able to detect faults in the executed code. It is therefore only able to identify code that is definitely not tested."

> "**The most extreme examples of the problem are tests with no assertions.** Fortunately these are uncommon in most code bases. Much more common is code that is only partially tested by its suite."

> "As it is actually able to detect whether each statement is meaningfully tested, mutation testing is the gold standard against which all other types of coverage are measured."

**내부 근거와의 연결**: 사내 저장소의 한 모듈에 pitest 플러그인이 실제로 설정돼 있습니다 (`mutators = ['DEFAULTS']`, 스레드 4개, HTML 리포트). 다만 `check`에 연결돼 있지 않아 명시적으로 호출해야 돕니다. §1-9의 커버리지 게이트와 같은 패턴이에요.

> 💡 writer 메모: Fowler의 `AssertionFreeTesting`, Google의 "adequately asserting on failures ... is mutation testing", PIT의 "tests with no assertions" 세 출처가 같은 지점을 가리킵니다. **§1-2의 "실패할 수 없는 단언"에 이름을 붙여 줄 개념**이에요. 다만 뮤테이션 테스팅 소개로 글이 새지 않게 짧게 쓰세요. 이 글의 주제는 도구가 아니라 경계입니다.

### 2-6. 단언의 구체성과 테스트 이름

#### ★ Change-detector test (§1-12의 정본 정의)

출처: https://testing.googleblog.com/2015/01/testing-on-toilet-change-detector-tests.html (Alex Eagle, 2015-01-27)

**정의**:

> "This is a change-detector test—it is a transformation of the same information in the code under test—and it breaks in response to any change to the production code, without verifying correct behavior of either the original or modified production code."

**판정**:

> "Change detectors provide negative value, since the tests do not catch any defects, and the added maintenance cost slows down development. These tests should be re-written or deleted."

**체크섬 비유**:

> "That test is clearly not useful: it contains an exact copy of the code under test and acts like a checksum. A correct or incorrect program is equally likely to pass a test that is a derivative of the code under test."

**증상 서술 (독자가 자기 코드에서 알아보게 만드는 문장)**:

> "You have just finished refactoring some code without modifying its behavior. Then you run the tests before committing and… a bunch of unit tests are failing. While fixing the tests, you get a sense that you are wasting time by mechanically applying the same transformation to many tests."

⚠️ 원문에 em dash가 있습니다. 영문 인용 블록이니 그대로 두되, 한글 본문에는 em dash를 쓰지 마세요.

#### 구현이 아니라 동작

출처: https://testing.googleblog.com/2013/08/testing-on-toilet-test-behavior-not.html (Andrew Trenk, 2013-08-05)

> "In most cases, tests should focus on testing your code's public API, and your code's implementation details shouldn't need to be exposed to tests."

**유보 조항도 함께 있습니다. "구현 테스트 금지"로 통째로 읽으면 오독입니다.**

> "There are many cases where you do want to test implementation details (e.g. you want to ensure that your implementation reads from a cache instead of from a datastore), but this should be less common since in most cases your tests should be independent of your implementation."

#### 테스트 이름

출처: https://testing.googleblog.com/2014/10/testing-on-toilet-writing-descriptive.html (Andrew Trenk, 2014-10-16)

**★ 핵심 규칙. §1-2의 `빈결과_반환` 문제를 정확히 짚습니다.**

> "Whichever pattern you use, the same advice still applies: **Make sure test names contain both the scenario being tested and the expected outcome.**"

> "The test name in the above code sample hints at the scenario being tested (“invalidLogin”), but it doesn't actually say what the expected outcome is supposed to be, so you had to read through the code to figure it out."

**이름이 곧 명세라는 논지의 근거들**:

> "If you want to know all the possible behaviors a class has, all you need to do is read through the test names in its test class, compared to spending minutes or hours digging through the test code or even the class itself trying to figure out its behavior."

> "By giving tests more explicit names, it forces you to split up testing different behaviors into separate tests."

> "You can easily tell if some functionality isn't being tested. If you don't see a test name that describes the behavior you're looking for, then you know the test doesn't exist."

예시: `isUserLockedOut_invalidLogin` → `isUserLockedOut_lockOutUserAfterThreeInvalidLoginAttempts`

### 2-7. 테스트 레벨 이름은 표준이 아니다

#### ISTQB의 정의

출처: https://istqb.org/wp-content/uploads/2024/11/ISTQB_CTFL_Syllabus_v4.0.1.pdf (ISTQB CTFL Syllabus v4.0.1, 2024-09-15, §2.2.1)

> "Test levels are groups of test activities that are organized and managed together. Each test level is an instance of the test process, performed in relation to software at a given phase of development, from individual components to complete systems or, where applicable, systems of systems."

🛑 **정정: ISTQB v4.0.1의 테스트 레벨은 4개가 아니라 5개입니다.** 원문: "In this syllabus, the following five test levels are described:"

1. Component testing (also known as unit testing)
2. Component integration testing (also known as unit integration testing)
3. System testing
4. System integration testing
5. Acceptance testing

흔히 말하는 "unit, integration, system, acceptance 4단계"는 ISTQB 원문과 다릅니다. → §3 V-4

**★ 레벨을 가르는 건 이름이 아니라 속성이라는 점이 이 글에 유용합니다.**

> "Test levels are distinguished by the following non-exhaustive list of attributes, to avoid overlapping of test activities:"
> "Test object / Test objectives / Test basis / Defects and failures / Approach and responsibilities"

#### L1~L5 숫자 명명은 표준이 아니다 (검증됨)

- ISTQB CTFL Syllabus v4.0.1 전문(78페이지)에서 정규식 `\bL[1-5]\b` 일치 **0건**.
- 실러버스에 나오는 "Level 1/2/3"은 테스트 단계가 아니라 **K-Level(인지 학습목표 수준, 시험 문제 난이도)**입니다. 원문: "Level 1: Remember (K1)", "Level 2: Understand (K2)", "Level 3: Apply (K3)". 혼동하지 마세요.
- 웹 검색 결과 L1~L5 테스트 레벨을 정의하는 **표준 제정 기관(ISTQB, ISO, IEEE)의 1차 출처는 하나도 없습니다.** 개인 블로그와 강의 사이트뿐입니다.

**결론**: L1~L5는 개별 조직의 사내 관행입니다. → §3 V-5

> 💡 writer 메모: **이 부재가 오히려 좋은 논거입니다.** §1-1의 사내 체계를 "표준이 없어서 각자 만든 것"으로 소개하면, §2-3의 Fowler("dig deeper on what they mean by their words")와 정확히 맞물려요. 그리고 그게 1편의 논지를 강화합니다. 이름을 통일하는 게 목적이 아니라, **각 레벨이 무엇을 검증하고 무엇을 검증하지 않는지 합의하는 게 목적**이라는 것.

#### 확인 불가

- **ISTQB Glossary** (https://glossary.istqb.org): SPA라 정적 요청으로는 본문을 못 받습니다. 다만 같은 기관의 CTFL 실러버스가 1차 출처이므로 실용상 대체됩니다.
- **ISO/IEC/IEEE 29119**: 유료 표준이라 원문 확보 못 함. 이번 범위 밖으로 뒀습니다.

---

## 3. 검증 기록

writer가 확정 인용하기 전에 검증한 항목들입니다. 이 절은 **근거 사슬**이므로 지우지 마세요.

| ID | 검증 대상 | 방법 | 결과 |
|---|---|---|---|
| **V-1** | "MyBatis의 `List` 반환 select는 결과가 없어도 null이 아니다" (§1-2의 핵심 전제) | 로컬 Gradle 캐시의 `mybatis-3.5.17-sources.jar`를 풀어 원본 확인 | **확정.** `DefaultResultHandler`가 필드 `private final List<Object> list;`를 생성자에서 `list = new ArrayList<>();`로 초기화하고 `getResultList()`가 그대로 반환. `DefaultResultSetHandler.handleResultSets`도 `final List<Object> multipleResults = new ArrayList<>();`로 시작. **빈 결과셋이면 빈 ArrayList가 반환되며 null이 될 수 없다.** 따라서 `isNotNull()`은 성공 경로에서 항진명제 |
| **V-2** | Fowler의 TestPyramid에 "two points"라는 표현이 있는가 | 페이지 원문 확보 후 문자열 검색 | **부정. 원문에 없음.** `"essential point"`(단수)가 실제 표현. 리서치 착수 시 가정이 틀렸음. "두 요점"으로 서술하면 사실 오류 |
| **V-3** | "People love debating what percentage..." 인용문의 화자 | test-shapes 페이지 원문에서 화자 확인 | **Justin Searls.** Fowler가 인용한 것이며 Fowler 본인의 말이 아님. Kent C. Dodds도 같은 트윗을 인용함 |
| **V-4** | ISTQB 테스트 레벨이 4개인가 | CTFL Syllabus v4.0.1 PDF 원문 확보 후 §2.2.1 확인 | **부정. 5개다.** "In this syllabus, the following five test levels are described". component / component integration / system / system integration / acceptance |
| **V-5** | L1~L5 숫자 레벨 명명이 업계 표준인가 | ISTQB 실러버스 전문 정규식 검색 + 웹 검색 | **부정.** 실러버스에서 `\bL[1-5]\b` 0건. 표준 기관 1차 출처 없음. 실러버스의 "Level 1/2/3"은 K-Level(시험 난이도)이며 테스트 단계가 아님 |
| **V-6** | 사내 문서가 규정한 커버리지 60%가 빌드에서 강제되는가 | 재구축 트랙 4개 모듈의 `build.gradle` 전수 확인 | **강제되지 않음.** 1개 모듈만 검증 태스크를 정의했고 그마저 `check`에 미연결. 나머지 3개는 검증 태스크 자체가 없음(리포트만). 레이어별 차등(80%/70%)을 문서로 규정한 모듈에도 검증 태스크 없음 |
| **V-7** | 약한 단언 비율 | 저장소 전체를 스크립트로 파싱(`@Test` 메서드 본문에서 단언 호출 추출 후 약한 단언만 남는 메서드 집계) | 단언 있는 `@Test` 7,767개 중 264개(3.4%). 접미사별로 `*MapperOracleIT` 73.0%(27/37), 일반 `*Test` 2.8%(210/7,484). ⚠️ 정규식 파싱이라 커스텀 단언 헬퍼는 놓칠 수 있음. **본문에 쓸 때 "대략"임을 밝히거나 비율 대비로만 쓸 것** |
| **V-8** | 테스트 이름 한글 비율 | 같은 스크립트로 `@Test` 메서드명의 한글 포함 여부 집계 | `@Test` 10,379개 중 한글 메서드명 5,186개(50.0%), `@DisplayName` 7,641개(73.6%). ⚠️ 같은 파싱 한계 적용 |
| **V-9** | 이 리서치 노트가 공개 저장소에 커밋되는가 | `.gitignore` 확인 + `git ls-files _drafts/` + `git remote -v` + `git check-ignore` 실측 | **커밋된다.** `!_drafts/*.research.md`가 되살림. 원격은 공개 GitHub 저장소. 선행 노트 3건 추적 중. 단 `.research.md`가 아닌 `_drafts/` 파일은 무시됨(실측 확인) |

### 3-2. 초안 확정 후 검증 (2026-08-11, verifier)

writer가 `(확인 필요)` 플래그를 하나도 남기지 않았으므로, 본문에 확정 포함된 인용을 전수로 되짚은 기록입니다.

| ID | 검증 대상 | 방법 | 결과 |
|---|---|---|---|
| **V-10** | 본문 `[원문]` 코드 인용의 줄번호와 내용 | `test/site_output_test.rb`, `test/search_test.js`, `CLAUDE.md` 실제 파일과 한 줄씩 대조 | **본문은 전부 일치.** `site_output_test.rb`의 37-38, 45-46, 52-53, 58, 64-70, 108-109, 112-113, 117-120, 121-122와 `search_test.js`의 1, 32-36, 51-54, `CLAUDE.md:34` 모두 원문 그대로이며 줄번호도 맞습니다. 다만 **이 노트 §1-11, §1-12가 적어 둔 줄번호 5곳이 1씩 밀려 있어 노트를 교정**했습니다(46-47 → 45-46, 53-54 → 52-53, 113-114 → 112-113, 118-121 → 117-120, 122-123 → 121-122). 본문은 처음부터 올바른 번호였습니다 |
| **V-11** | `[^principles]`의 `sr-harness` 0.23.0 줄번호와 인용문 | `~/.claude/plugins/cache/sr-harness/sr-harness/0.23.0/skills/dev-coding-principles/SKILL.md` 대조 | `:40`, `:54`, `:55`, `:56` 인용문 **모두 일치.** 다만 `:71`은 체크리스트의 `§3 Test` 머리말이고 항목 셋은 `:72-74`입니다. 본문이 "체크리스트 절(`:71-74`)은 세 항목"이라고 적어 항목 범위가 틀리게 읽힐 수 있어 "머리말 한 줄과 항목 셋"으로 교정 |
| **V-12** | V-1(MyBatis 빈 리스트) 재현 | 같은 `mybatis-3.5.17-sources.jar`를 다시 풀어 원본 재확인 | **재현됨.** `DefaultResultHandler`의 `private final List<Object> list;`(`:30`), 인자 없는 생성자의 `list = new ArrayList<>();`(`:33`), `getResultList()`의 `return list;`(`:46-48`), `DefaultResultSetHandler.handleResultSets`의 `final List<Object> multipleResults = new ArrayList<>();`(`:192`). 추가로 `ObjectFactory`를 받는 두 번째 생성자(`:37-39`)가 있고 이쪽은 `list = objectFactory.create(List.class);`라 역시 null이 아닙니다. 각주에 반영했습니다 |
| **V-13** | Google change-detector 인용문 | 페이지 원문을 내려받아 문자 단위 대조 | **일치.** "Change detectors provide negative value, since the tests do not catch any defects, and the added maintenance cost slows down development. These tests should be re-written or deleted." 정의문, 체크섬 비유, 증상 서술도 원문 그대로. 저자 Alex Eagle, 게재일 2015-01-27 확인 |
| **V-14** | Searls 귀속 구조 | test-shapes 원문 확보 후 인용 블록의 화자 표기 확인 | **본문 서술이 정확합니다.** 원문은 인용 블록 아래에 `-- Justin Searls`를 달고 Searls의 트윗을 링크합니다. Fowler는 이를 "My biggest issue is well-summed-up by this quote"로 끌어옵니다. 본문은 직접 인용이 아니라 풀어 쓴 형태인데 의미 왜곡 없음. 게재일 2021-06-02와 부제도 일치 |
| **V-15** | Google 테스트 이름 규칙 | 페이지 원문 대조 | **일치.** "Whichever pattern you use, the same advice still applies: Make sure test names contain both the scenario being tested and the expected outcome." 저자 Andrew Trenk, 2014-10-16. 같은 각주가 인용한 2013-08-05 글의 유보 조항은 본문이 `less common.`에서 끊어 놓아 **원문 전체 문장으로 복원**했습니다 |
| **V-16** | 나머지 외부 인용 일괄 | Google 커버리지, PIT, Marick PDF, Fowler TestCoverage와 TestPyramid, Dodds, Spotify 원문을 내려받아 각주의 전 인용문 대조 | **전부 일치.** 저자와 날짜도 확인(Google 커버리지 2020-08-07 3인, Spotify 2018-01-11 2인). 교정 3건: ① Dodds의 100% 커버리지 인용문은 「The Testing Trophy and Testing Classifications」가 아니라 「Write tests. Not too many. Mostly integration.」에 있어 출처를 나눠 적었습니다. ② Spotify 인용을 원문 시작(`By the way, `)까지 복원. ③ Marick 저작권 표기를 원문대로 "Copyright 1997 Brian Marick, 1999 Reliable Software Technologies"로 |
| **V-17** | ISTQB 관련 단정 전부 | 실러버스 PDF를 다시 내려받아 텍스트를 추출하고 재현 | **재현됨.** 총 78페이지(면주 "Page 28 of 78", 날짜 2024-09-15). §2.2.1에 "In this syllabus, the following five test levels are described:"와 다섯 레벨이 있고, `\bL[1-5]\b` 일치는 0건, K-Level 표기도 확인. 속성 목록은 **불릿 다섯 개**여서, 한 문장처럼 이어 붙였던 각주 인용을 분리했습니다 |
| **V-18** | 측정 수치의 단정 수위 | §1-3과 V-7의 한계 서술을 본문과 대조 | 본문이 절대 수치(7,767 / 264 / 3.4%)를 단정문으로 적고 있어 **"이 기준으로 세면"과 "절대 수치는 근사치"** 를 더해 그룹 간 비율 대비를 앞세우도록 낮췄습니다. 정규식 파싱 한계는 각주 `[^measure]`에 이미 명시돼 있었습니다 |
| **V-19** | 익명화 | 본문 전수 스캔(회사명, PG사, 파트너사, 도메인, `kr.co.*`류 패키지, 사내 이슈 번호 패턴, 외부 URL 전수) | **누출 없음.** 본문 URL은 전부 공개 출처와 필자 본인 GitHub입니다. `[재구성]` 블록 5곳 어디에도 경로나 줄번호가 없고, 본문 서두가 재구성임을 명시합니다. 로컬 전용 색인 파일이 무시되는 것도 `git check-ignore`로 재확인 |
| **V-20** | 커버리지 실측치를 주장하는가 | 본문의 모든 퍼센트 표기 전수 확인 | **실측 커버리지를 주장하는 문장은 없습니다.** 등장하는 퍼센트는 약한 단언 측정치(V-7), 문서가 규정한 임계값(V-6), 외부 출처의 수치(Marick 85%, Google 60/75/90, Dodds 100%)뿐입니다 |
| **V-21** | V-7·V-8 수치의 독립 재현 (오케스트레이터, 2026-08-11) | 원 측정자의 스크립트가 소실됐으므로, 노트 부록의 측정 기준 서술만 보고 파서를 **처음부터 새로 작성해** 사내 저장소 전체를 다시 집계 | **핵심 대조는 정확히 재현, 모수는 파서 의존적.** `*MapperOracleIT` 27/37(73.0%)과 `*OracleIT`(매퍼 아님) 0/17(0.0%)은 분자·분모까지 두 측정이 일치했습니다. 반면 단언 인정 목록에 BDDMockito `then()`과 `andExpect`를 포함시키자 모수가 7,767 → 8,841로 늘어 전체 3.4% → 3.0%, 일반 `*Test` 2.8% → 2.4%, 밀도 배수 26배 → 29.8배로 이동했습니다. 이름 수치는 편차가 더 큽니다(한글 메서드명 50.0% → 44.0%, `@DisplayName` 7,641 → 9,782). **결론: 그룹 간 대조는 견고하고 절대 수치와 배수는 근사치입니다.** 본문의 "26배" 단정을 "20배를 넘습니다"로 낮추고 재현 결과를 본문과 각주 `[^measure]`에 명시했습니다. ⚠️ **이름 수치(V-8)는 3편에서 쓸 때 반드시 다시 재현할 것** — 50%와 44%는 논지가 갈릴 만한 차이입니다 |

### 확인하지 못한 것

- 매퍼 통합 테스트를 실제로 실행해 `isNotNull()` 단언이 통과하는지 **직접 돌려 보지는 못했습니다.** 실제 Oracle 접속이 필요해서요. V-1의 소스 확인으로 대체했습니다. 논리는 확정이지만 실행 검증은 아닙니다.
- 커버리지 실측치(각 모듈이 실제로 몇 퍼센트인지)는 확인하지 못했습니다. 빌드를 돌려야 해서요. **본문에서 실측 커버리지 숫자를 주장하지 마세요.** 확인된 건 "임계값 설정 여부"뿐입니다.
- §1-6의 drift 사례가 언제 발견됐고 얼마나 오래 초록불이었는지는 확인하지 못했습니다. **기간을 추정해서 쓰지 마세요.**
- ~~(verifier 추가, 2026-08-11) §1-3과 §1-5의 사내 저장소 수치는 이번 검증에서 재현하지 못했습니다.~~ **→ V-21에서 해소.** 오케스트레이터가 측정 기준 서술만 보고 파서를 새로 짜 재집계했습니다. 핵심 대조(매퍼 IT 27/37, 매퍼 아닌 `*OracleIT` 0/17)는 분자와 분모까지 재현됐고, 모수와 배수는 파서에 따라 움직인다는 것이 확인됐습니다. 본문은 그에 맞춰 교정했습니다.
- **이름 수치(V-8)는 아직 근거가 한 겹입니다.** V-21의 재현에서 한글 메서드명 비율이 50.0%와 44.0%로, `@DisplayName` 총계가 7,641과 9,782로 갈렸습니다. 1편 본문은 이 수치를 쓰지 않으므로 발행에 지장이 없지만, **3편이 이 수치에 논지를 걸 예정이므로 그때 반드시 재현해야 합니다.**

---

## 4. 글의 뼈대 제안 (writer가 취사선택)

한 문장 주제: **테스트의 가치는 커버리지가 아니라 "무엇이 바뀌면 이게 실패해야 하는가"에 대한 답이 얼마나 분명한가로 결정된다.**

1. **여는 장면**: 실제 Oracle을 띄우는 테스트 11개가 전부 `isNotNull()`이다. 그리고 그 단언은 실패할 수 없다 (§1-2 가, V-1). 커버리지에는 잡힌다.
2. **왜 숫자가 답을 못 주나**: 커버리지는 실행됐음만 보장한다 (§2-4 Google의 a/b 구분). Marick의 85% 관찰(§2-4)과, 우리 조직이 60%를 문서에만 두고 배선하지 않은 것(§1-9)은 같은 힘의 양면이다.
3. **경계는 어디에 긋나**: 형태 논쟁(피라미드 vs 트로피 vs 허니콤)은 용어 정의 차이였다 (§2-3). Dodds와 Spotify 본인들이 맥락 한정을 자백한다 (§2-2). 그러니 형태를 고르지 말고 **각 레벨이 무엇을 검증하고 무엇을 안 하는지 적어라** (§1-7의 매핑표, `—` 칸).
4. **중복 검증 금지의 실제 모습**: 같은 불변식을 레이어별로 **분해**한다. 인수 기준이어도 순수 계산이면 아래로 태그를 내린다 (§1-7).
5. **단언의 구체성은 단조 증가가 아니다**: `isNotNull()`(너무 느슨)과 `assert_equal 30, scan(...)`(너무 빡빡, change detector)의 대칭 (§1-2, §1-12, §2-6). 올바른 질문은 "무엇이 바뀌면 실패해야 하는가".
6. **이름이 곧 명세**: `빈결과_반환`인데 `isNotNull()`이면 이름이 거짓말이다 (§1-2). 반대로 이름이 명세를 지면 명세 오류가 이름에 드러난다 (§1-6). 시나리오와 기대 결과를 둘 다 담아라 (§2-6).
7. **부정 단언 주의**: `never()`는 틀린 이유로 너무 쉽게 통과한다 (§1-6).
8. **경계는 게이트 설계이기도 하다**: 환경 의존 테스트를 게이트 안에 두면 게이트를 끄는 압력이 생긴다 (§1-10).
9. **닫는 자리**: 어떤 스위트도 전부를 덮지 않는다. 안 덮이는 게 무엇인지 아는 것이 경계다 (§1-8의 제외 표, §1-13의 JS 사각지대, §2-4의 "What's not covered is more meaningful").

⚠️ **1편에서 하지 말 것**:
- Spring 각론 (`ApplicationContextRunner`, `@SpringBootTest` 스코프, 컨텍스트 캐시, `@DynamicPropertySource`) → 2편
- AI, 에이전트, 위임, 자동화 체크리스트 → 3편
- 뮤테이션 테스팅 도구 소개로 길게 새는 것 (개념 한 문단이면 충분)
- 피라미드 형태 논쟁에 편들기 (§2-3이 moot라고 정리함)

---

## 5. 후속 편 근거 (1편에서 쓰지 말 것)

### 2편: Spring에서 컨텍스트를 어떻게 띄우는가

**하네스 스킬 (원문 인용 가능)**: `~/.claude/plugins/cache/sr-harness/sr-harness/0.23.0/skills/dev-testing-strategy/SKILL.md`

이 스킬이 1편과 2편의 경계를 스스로 정의합니다. 인용해 두면 2편 도입부에 그대로 쓸 수 있어요.

> `dev-coding-principles §3 Test`가 "단위냐 통합이냐"를 가른다면, 이 스킬은 "통합이라면 컨텍스트를 어떻게 띄우나"를 가른다.

스킬 구성:
- **§1 컨텍스트 구성 방식 (Runner vs Autowired)**: 세 신호 중 하나라도 걸리면 `ApplicationContextRunner`. 신호 1은 프로퍼티 조합이 메서드마다 다름, 신호 2는 `AutoConfigurations.of(...)` 조합, 신호 3은 컨텍스트 구조 자체가 단언 대상. 그리고 경고가 있습니다. "신호 1(프로퍼티 공유 여부)만 기계적으로 확인하고 판단하지 않는다."
- **§2 컨텍스트 스코프**: 좁힘이 기본, 전체는 스모크와 E2E 두 역할로만. **"좁힌 테스트와 전체 테스트는 서로 다른 결함을 잡는다"**, "본문이 빈 스모크 테스트는 전자를 구조적으로 못 잡는다 — 예외 없이 뜨기만 하면 통과하기 때문이다."
- **§3 프로퍼티 값 관리**: 하드코딩 금지, `@DynamicPropertySource`는 런타임 결정값 전용, static 메서드는 컨텍스트 리프레시 전에 실행됨.

⚠️ §2의 "좁힌 테스트와 전체 테스트는 다른 결함을 잡는다"는 **원리 자체는 1편 소재**이기도 합니다. 다만 Spring 용어로 서술돼 있으니, 1편에서 쓴다면 §1-7의 매핑표로 일반화해 쓰고 이 스킬은 인용하지 마세요.

**사내 저장소 수치 (재확인)**:
- 인자 없는 `@SpringBootTest` 425건 vs `classes=`로 좁힌 것 36건
- `@WebMvcTest` 66개, `@DataJpaTest` 4개, `@JsonTest` 2개, `@RestClientTest` 0개
- `ApplicationContextRunner` 사용 파일 10여 개 (프로파일별 프로퍼티 바인딩, 배선 검증, 메트릭 바인딩)
- 컨텍스트 캐시를 의식한 공통 베이스 클래스 존재 (계약 테스트 베이스, Oracle 통합 테스트 추상 베이스)

**이번에 추가로 확인한 2편 소재**:
- 인수 테스트 공통 베이스가 `@SpringBootTest(RANDOM_PORT)` + Testcontainers Oracle + WireMock 조합으로 정의돼 있음. L5 전용 베이스 클래스.
- 매퍼 테스트 공통 베이스가 `@SpringBootTest` + Testcontainers Oracle로 별도 정의됨. **L3 매퍼용과 L5 인수용이 서로 다른 베이스를 쓴다.** 컨텍스트 캐시 분리 의도로 보이나 미확인.
- §1-2의 매퍼 IT들은 `@MybatisTest` + `@AutoConfigureTestDatabase(replace = NONE)` + `@ActiveProfiles("oracle-it")` + `@Tag("oracle-integration")` 4종 조합. **슬라이스 애노테이션(`@MybatisTest`)을 쓰면서 실제 DB를 붙이는 하이브리드**라 2편의 좋은 사례입니다.
- Testcontainers Docker API 버전 고정 이슈: `systemProperty 'api.version', '1.44'` (Docker 25+ 데몬 호환). 여러 모듈에 반복 등장.
- 로컬 DB 부재 시 `@MockBean DataSource`로 컨텍스트 검증만 갈음하는 폴백 전략이 문서화돼 있음.

### 3편: 그 기준을 에이전트에게 위임하기

- **`dev-coding-principles §3`의 체크리스트**(§1-4에 원문 있음)가 3편의 출발점. 특히 `:56`의 `isNotNull()` 안티패턴 명시.
- **★ §1-5의 발견이 3편의 핵심 논거입니다**: 같은 체크리스트에서 **기계적으로 검사 가능한 규칙(한글 이름)은 95% 지켜졌고, 판단이 필요한 규칙(단언 구체성)은 73% 어겨졌습니다.** 에이전트에게 위임할 때 이 비대칭을 어떻게 다룰 것인가가 3편의 질문이에요.
- **이 블로그의 #12 사건**(§1-13): 계약 테스트가 통과하는 동안 라이브 검색이 0건이었고, 고친 뒤 **동작을 테스트로 잠갔습니다**(`test/search_test.js`). "기준을 코드로 잠근다"의 실례.
- **`CLAUDE.md`의 계약 잠금 서술**: "이 계약들은 `test/site_output_test.rb`에 잠겨 있다. 오버라이드를 수정하면 계약 assertion이 깨질 수 있으니 반드시 테스트를 돌린다."
- **§1-9와 §2-5의 미배선 패턴**: 커버리지 검증 태스크도, pitest도 설정은 돼 있는데 `check`에 연결돼 있지 않습니다. **"기준을 적는 것"과 "기준을 강제하는 것" 사이의 간극**이 3편 주제와 직결돼요.
- **§1-10의 인센티브 관찰**: "게이트를 다시 끄는 압력이 생긴다." 자동화된 게이트를 설계할 때 사람이 그걸 우회할 유인을 함께 설계해야 한다는 논거.
- `ownership-principles` 스킬(0.21.0부터 존재)에 인지적 부채, 굴복, 오케스트레이션 세금 개념이 있습니다. 3편에서 확인해 보세요.

---

## 부록: 재현 방법

§1-3과 §1-5의 수치는 스크립트로 산출했습니다. 재현하려면:

- 파서 스크립트: `/private/tmp/.../scratchpad/weak.py`(약한 단언), `weak2.py`(파일별 분포), `names.py`(이름 규칙). 세션 임시 디렉터리라 사라질 수 있으니, verifier가 재현해야 하면 노트의 기준 서술(§1-3 첫 문단)을 보고 다시 짜면 됩니다.
- 측정 기준을 다시 적어 둡니다. "약한 단언만 있는 메서드" = `@Test`/`@ParameterizedTest`/`@RepeatedTest` 메서드 본문에서 단언 호출(`assertThat`, `assertEquals`, `verify` 등)을 추출했을 때, `isNotNull` / `assertNotNull` / `isNotEmpty` / `assertDoesNotThrow`를 포함한 줄을 제외하면 단언이 하나도 남지 않는 메서드.
- ⚠️ 정규식 기반이라 커스텀 단언 헬퍼와 BDDMockito `then()` 스타일은 놓칩니다. **절대 수치보다 비율 대비로 쓰는 게 안전합니다.**
