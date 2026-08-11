# 리서치: Spring 컨텍스트를 어떻게 띄우는가 (테스트 기준 2편)

**slug**: `test-standards-2-spring-context`
**수집일**: 2026-08-11
**시리즈**: 3부작 2편. 1편은 「무엇을 테스트할 것인가」(발행됨), 3편은 「기준을 에이전트에게 위임하기」.

---

## ⚠️ 0. writer가 먼저 읽어야 할 제약 (1편에서 승계)

### 0-1. 이 노트는 공개 저장소에 커밋된다

`.gitignore:17-18`이 `_drafts/*`를 무시하되 `!_drafts/*.research.md`로 리서치 노트만 되살립니다. `origin`은 공개 GitHub 저장소예요. 그래서 **이 노트 자체를 익명화된 상태로 작성했습니다.**

사내 원본 추적이 필요하면 같은 디렉터리의 `test-standards-2-spring-context.sources-internal.md`를 보세요. 그 파일은 `_drafts/*` 규칙에 걸려 커밋되지 않습니다(`git check-ignore`로 실측 확인). **그 파일의 내용은 본문에도 이 노트에도 옮기지 않습니다.**

### 0-2. 익명화 (필수, 예외 없음)

회사와 PG사 실명, 파트너사 실명, 도메인과 IP, 패키지와 클래스와 모듈 실명, 테이블명, 사내 이슈 번호, 계약 수치는 본문에도 이 노트에도 넣지 않습니다.

**모듈은 라벨로만 부릅니다.** 아래 라벨은 이 노트 안에서만 통용되는 이름이고 실제 모듈명과는 무관합니다.

| 라벨 | 성격 | Spring Boot |
|---|---|---|
| 모듈 A | 운영 알림 배치. 1편의 매퍼 IT들이 여기 있다 | 2.7.x |
| 모듈 B | 결제 SPI. 1편 §게이트 이야기의 "모듈 Y" | 2.7.x |
| 모듈 C | 레거시 결제 서비스. 저장소 최대 규모 | 3.1.x |
| 모듈 D | QA용 모듈 | 2.7.x |
| 모듈 E | 웹훅 (원본). 사내 로컬 컨벤션 스킬을 가진 모듈이자 이번 실측 대상 | 3.5.x |
| 모듈 E′ | 웹훅 (재구축 트랙) | 3.2.x |
| 모듈 F | 결제 (재구축 트랙) | 3.2.x |
| 모듈 G | API (재구축 트랙) | 3.2.x |
| 모듈 H | API (원본) | 3.3.x |
| 모듈 I | 결제 (원본) | 3.4.x |
| 모듈 J | SPI (재구축 트랙) | 3.2.x |
| 모듈 K | 환율 원장 | 3.2.x |

### 0-3. 인용 두 종류를 분리한다 (1편과 동일)

| 종류 | 대상 | 본문에서 다루는 법 |
|---|---|---|
| **A. 원문 그대로 인용 가능** | 이 블로그 저장소, **Spring / Spring Boot 소스와 공식 문서**, `sr-harness` 공개 플러그인 스킬 | 파일과 줄번호(또는 URL)를 밝히고 원문 그대로 |
| **B. 재구성 예제로만 가능** | 사내 저장소 코드, 사내 문서, **사내 프로젝트 로컬 스킬** | 클래스명을 중립 이름으로 치환, **파일 경로를 달지 않음**, 본문에 "구조만 남기고 재구성했다"고 명시 |

아래에서 A는 `[원문]`, B는 `[재구성]`으로 표시했습니다. **B를 쓸 때는 반드시 본문에 재구성임을 밝힙니다.**

> ⚠️ 이번 편은 B가 하나 늘었습니다. 사내 프로젝트에 **프로젝트 로컬 스킬 문서**가 있는데, 이건 공개 `sr-harness` 스킬과 달리 사내 저장소 파일이라 원문 인용 대상이 아닙니다. 두 문서가 내용이 비슷해서 헷갈리기 쉬우니 주의하세요. **`sr-harness`는 원문, 사내 로컬 스킬은 재구성입니다.**

### 0-4. 1편에서 이미 쓴 것 (되풀이 금지)

단언의 구체성, change detector, 커버리지 숫자, 테스트 이름, L1~L5 레벨 체계의 정의, 게이트 설계(`ignoreFailures`), 피라미드 형태 논쟁. 필요하면 **"1편에서 다뤘다"고 한 줄로 참조**하고 넘어갑니다.

### 0-5. 3편 것 (이번 편에서 쓰지 말 것)

AI, 에이전트, 위임, 체크리스트 자동화, 그리고 **테스트 이름 수치(한글 50.0% vs 44.0%)**. 발견된 것은 §7에 쌓아 뒀습니다.

---

## ★★ 이 노트를 쓰는 기준: 배울 점이 있어야 한다

이 블로그는 인사이트 중심입니다(`CLAUDE.md`: "절차 나열이 아니라 '왜'와 '무엇을 배웠는지'에 초점"). **2편은 3부작 중 이 기준을 놓치기 가장 쉬운 편입니다.** Spring 각론이라 자칫 "`ApplicationContextRunner`는 이렇게 씁니다" 식 사용법 나열이 되는데, 그건 공식 문서가 더 잘합니다.

그래서 이 노트는 아래 네 종류의 근거를 우선 배치했습니다. **writer는 이 네 갈래에 해당하지 않는 재료를 본문의 중심에 놓지 마세요.**

| 갈래 | 왜 값어치가 있나 | 이 노트의 자리 |
|---|---|---|
| **A. 조용히 깨진 사례** | 문서를 읽어서는 배울 수 없고 겪어야만 안다 | §5-3, §5-4, §6-6 (셋 다 실물) |
| **B. 보이지 않는 메커니즘이 좋아 보이는 원칙을 배신하는 구조** | "좁혀라", "재사용해라"는 누가 봐도 옳은데 기계적으로 적용하면 손해가 난다 | §1, §2-3, §3-5, §6-6 |
| **C. 판단이 갈리는 지점과 사람들이 반대쪽을 고르는 이유** | 규칙만 적으면 다음 사람이 같은 자리에서 또 틀린다 | §5-0 (기준이 1개에서 3개로 자란 이력) |
| **D. 결정의 흔적** | 트레이드오프를 인지하고 내린 결정의 기록이라 원칙보다 잘 가르친다 | §1(베이스 주석), §3-7, §5-5, §6-5, §6-6 |

### 가져갈 문장 후보 (writer가 다듬어 쓸 것)

1편이 잘된 이유는 "규율이 아니라 질문이 단언을 구체적으로 만든다", "구체성은 단조 증가하는 미덕이 아니다" 같은 **가져갈 문장**이 있었기 때문입니다. 2편의 후보는 이렇습니다.

1. **"좁힘과 공유는 대립하지 않는다. 둘 다 '설정을 어디에 적는가'의 문제다."** (§1)
2. **"1편은 기준이 있는데 안 지켜진 이야기였고, 2편은 기준이 지켜졌는데 기준이 틀렸던 이야기다."** (§5-0. 이게 2편의 주제문 1순위)
3. **"애노테이션이 약속하는 것과 런타임이 하는 일은 다를 수 있다. `withReuse(true)`는 재사용하지 않고, `@ActiveProfiles`는 정렬하지 않는다."** (§2-3, §6-6)
4. **"컨텍스트 구성 방식은 그 테스트가 쓸 수 있는 단언의 집합을 미리 정한다."** (§5-4, §6-4)
5. **"가장 좁힌 컨텍스트는 컨텍스트를 안 띄우는 것이다."** (§3-8)

---

## 1. ★ 중심 가설과 판정

오케스트레이터가 세운 가설은 이랬습니다.

> 스킬 §2는 "컨텍스트 스코프는 좁힘이 기본"이라고 한다. 그런데 현실에서는 "설정을 통일해 컨텍스트 캐시를 공유하라"가 테스트 실행 시간을 지배한다. 좁힘은 "의미 단위"에서 하고, 캐시 공유는 "설정 단위"에서 한다. 클래스마다 `classes=` 목록을 손으로 다르게 적는 건 좁힘이 아니라 파편화다.

### 판정: **확인됨. 다만 원인 변수가 가설보다 하나 더 앞에 있습니다.**

가설은 파편화의 원인으로 `classes=`를 지목했습니다. 실제로 세어 보니 **파편화를 예측하는 변수는 `classes=`가 아니라 "공통 베이스 클래스가 있는가"였습니다.**

| 모듈 | 테스트 클래스 | 서로 다른 컨텍스트 | 재사용 비 | 공통 베이스 |
|---|---|---|---|---|
| 모듈 G | 16 | **2** | 8.0 | 있음 (15클래스가 하나 상속) |
| 모듈 I | 45 | **5** | 9.0 | 있음 (31 + 12로 둘) |
| 모듈 H | 12 | **12** | 1.0 | 없음 |
| 모듈 E | 12 | **11** | 1.1 | 없음 |
| 모듈 E′ | 9 | **9** | 1.0 | 없음 |
| 모듈 F | 4 | **4** | 1.0 | 없음 |

모듈 G와 모듈 H는 **같은 애플리케이션의 재구축본과 원본**입니다. 같은 도메인, 비슷한 테스트인데 한쪽은 16클래스가 컨텍스트 2개를 쓰고 다른 쪽은 12클래스가 12개를 씁니다. 차이는 베이스 클래스 하나예요.

그리고 저장소가 이 판단을 **주석으로 적어 뒀습니다.** 모듈 I의 계약 테스트 베이스입니다. `[재구성]`

```java
// [재구성]
/**
 * 인바운드 HTTP 표면 계약 특성 테스트 공통 베이스.
 *
 * DB 없이 풀 컨텍스트 + MockMvc를 기동한다.
 * 설정을 통일해 컨텍스트 캐시를 공유하므로, 하위 클래스는 @TestPropertySource를
 * 추가하지 말고 이 베이스의 컨텍스트를 그대로 사용한다.
 */
@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {
        "spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.OracleDialect",
        "spring.jpa.hibernate.ddl-auto=none",
        "management.health.db.enabled=false"
})
public abstract class HttpContractTestBase {

    @Autowired
    protected MockMvc mockMvc;

    @MockitoBean
    DataSource dataSource;
}
```

> 💡 writer 메모: **"설정을 통일해 컨텍스트 캐시를 공유하므로, 하위 클래스는 `@TestPropertySource`를 추가하지 말라"**. 이 한 문장이 2편의 주제문 후보 1순위입니다. 가설을 저장소가 자기 말로 먼저 적어 놨어요. 그리고 이 베이스는 `@MockitoBean`도 베이스에 답니다. **mock을 베이스에 달면 캐시 키가 하나로 모이고, 클래스마다 달면 클래스마다 갈립니다**(§3-4). 그 이유는 §2에서 메커니즘으로 설명됩니다.

### 가설이 틀린 부분: `classes=`는 범인이 아니었습니다

`classes=`로 좁힌 클래스는 저장소 전체에서 **39개**(정적 분석 기준)이고 컨텍스트 26개를 만듭니다. 반면 무인자 `@SpringBootTest` 계열은 754클래스가 118개를 만들어요. 겉보기 비율(1.5 vs 6.4)만 보면 가설대로지만, `classes=`를 쓴 자리를 실제로 열어 보면 **대부분 그게 옳은 선택**입니다.

가장 선명한 예가 모듈 E의 프로파일 바인딩 테스트 5종입니다. 각각 `@SpringBootTest(classes = 자기TestConfig.class, webEnvironment = NONE)` + `@ActiveProfiles("dev"|"prod"|"stg"|"dr"|"test")`예요. 다섯 개가 각자 다른 컨텍스트를 만드는데, **`@ActiveProfiles`가 이미 다르므로 `classes=`를 지워도 여전히 다섯 개**입니다. 여기서 `classes=`는 파편화를 만든 게 아니라, 5개 컨텍스트를 각각 **작게** 만든 거예요.

**그러니 정확한 명제는 이렇습니다.**

- 파편화를 만드는 것은 **키를 가르는 축이 클래스마다 제각각인 것**이지 `classes=` 자체가 아니다.
- 키를 가르는 축에는 `classes=` 말고도 `@ActiveProfiles`, `@TestPropertySource`, `@MockBean` 조합, `@AutoConfigure*`가 있고, **실측해 보면 뒤의 셋이 훨씬 많이 가른다.**
- 좁힘과 캐시 공유는 대립하지 않는다. **베이스 클래스가 좁힘을 정의하면 둘 다 얻는다.**

---

## 2. 근거: 캐시 키가 무엇으로 결정되는가 [원문 인용 가능]

추측 금지 지시가 있었으므로 **Spring 소스와 공식 문서로 먼저 확정**했습니다.

### 2-1. 공식 문서의 키 구성 목록

출처: [Spring Framework Reference: Context Caching](https://docs.spring.io/spring-framework/reference/testing/testcontext-framework/ctx-management/caching.html)

키를 이루는 파라미터 목록(원문 그대로):

- `locations` (from `@ContextConfiguration`)
- `classes` (from `@ContextConfiguration`)
- `contextInitializerClasses` (from `@ContextConfiguration`)
- `contextCustomizers` (from `ContextCustomizerFactory`) – this includes `@DynamicPropertySource` methods, bean overrides (such as `@TestBean`, `@MockitoBean`, `@MockitoSpyBean` etc.), as well as various features from Spring Boot's testing support.
- `contextLoader` (from `@ContextConfiguration`)
- `parent` (from `@ContextHierarchy`)
- `activeProfiles` (from `@ActiveProfiles`)
- `propertySourceDescriptors` (from `@TestPropertySource`)
- `propertySourceProperties` (from `@TestPropertySource`)
- `resourceBasePath` (from `@WebAppConfiguration`)

캐시 크기와 축출:

> "The size of the context cache is bounded with a default maximum size of 32. Whenever the maximum size is reached, a least recently used (LRU) eviction policy is used to evict and close stale contexts. You can configure the maximum size from the command line or a build script by setting a JVM system property named `spring.test.context.cache.maxSize`."

**★ 캐시의 범위. 이 문단이 2편의 숨은 반전입니다.**

> "The Spring TestContext framework stores application contexts in a static cache. This means that the context is literally stored in a `static` variable. In other words, if tests run in separate processes, the static cache is cleared between each test execution, which effectively disables the caching mechanism."

> "To benefit from the caching mechanism, all tests must run within the same process or test suite."

### 2-2. 소스로 재확인

로컬 Gradle 캐시의 sources jar를 풀어 직접 확인했습니다. `spring-test` 5.3.31(Boot 2.7.18 대응), 6.1.11, 6.2.9(Boot 3.5.4가 실제로 쓰는 버전, 실행 로그로 확인)를 모두 봤습니다.

`MergedContextConfiguration.hashCode()` 원문 (6.1.11):

```java
// [원문] spring-test 6.1.11, org/springframework/test/context/MergedContextConfiguration.java:537-548
public int hashCode() {
    int result = Arrays.hashCode(this.locations);
    result = 31 * result + Arrays.hashCode(this.classes);
    result = 31 * result + this.contextInitializerClasses.hashCode();
    result = 31 * result + Arrays.hashCode(this.activeProfiles);
    result = 31 * result + this.propertySourceDescriptors.hashCode();
    result = 31 * result + Arrays.hashCode(this.propertySourceProperties);
    result = 31 * result + this.contextCustomizers.hashCode();
    result = 31 * result + (this.parent != null ? this.parent.hashCode() : 0);
    result = 31 * result + nullSafeClassName(this.contextLoader).hashCode();
    return result;
}
```

5.3.31은 `propertySourceDescriptors` 자리가 `Arrays.hashCode(this.propertySourceLocations)`라는 점만 다르고 나머지는 글자까지 같습니다. **Boot 2.7부터 3.5까지 캐시 키의 구조는 사실상 바뀌지 않았습니다.**

기본 크기와 축출 정책도 소스에 있습니다.

```java
// [원문] spring-test 6.1.11, org/springframework/test/context/cache/ContextCache.java:66,79
int DEFAULT_MAX_CONTEXT_CACHE_SIZE = 32;
String MAX_CONTEXT_CACHE_SIZE_PROPERTY_NAME = "spring.test.context.cache.maxSize";
```

```java
// [원문] spring-test 6.1.11, org/springframework/test/context/cache/DefaultContextCache.java:307,320
private class LruCache extends LinkedHashMap<MergedContextConfiguration, ApplicationContext> {
    protected boolean removeEldestEntry(Map.Entry<MergedContextConfiguration, ApplicationContext> eldest) {
```

캐시가 static이라는 것도 소스에 그대로 있습니다.

```java
// [원문] spring-test 6.1.11, org/springframework/test/context/cache/DefaultCacheAwareContextLoaderDelegate.java:68-71
/**
 * Default static cache of Spring application contexts.
 */
static final ContextCache defaultContextCache = new DefaultContextCache();
```

`5.3.31`도 `DEFAULT_MAX_CONTEXT_CACHE_SIZE = 32`로 같습니다.

### 2-3. ★ 비자명한 사실 셋 (문서에는 안 나오고 소스에만 있는 것)

이 셋이 2편에서 가장 값어치 있는 대목입니다. 전부 소스 원문으로 확정했어요.

#### (1) `@ActiveProfiles`는 **정렬되지 않는다**. 선언 순서가 키를 가른다.

```java
// [원문] spring-test 6.1.11과 6.2.9, MergedContextConfiguration.processActiveProfiles
private static String[] processActiveProfiles(@Nullable String[] activeProfiles) {
    if (activeProfiles == null) {
        return EMPTY_STRING_ARRAY;
    }

    // Active profiles must be unique
    Set<String> profilesSet = new LinkedHashSet<>(Arrays.asList(activeProfiles));
    return StringUtils.toStringArray(profilesSet);
}
```

`LinkedHashSet`은 중복만 제거하고 **삽입 순서를 유지**합니다. 정렬하지 않아요. 그리고 키는 `Arrays.hashCode(this.activeProfiles)`, 즉 **배열의 순서까지 보는 해시**입니다. 5.3.31도 같은 코드예요.

따라서 `{"a","b","c"}`와 `{"a","c","b"}`는 **활성 프로파일 집합이 완전히 같은데도 서로 다른 컨텍스트**가 됩니다. 애플리케이션 입장에서는 아무 차이가 없고요.

> 💡 writer 메모: 이건 코드를 읽어서는 절대 안 보이는 캐시 미스입니다. 그리고 사내 저장소에 **실제로 두 건 있습니다**(§3-5). 2편의 가장 좋은 "이걸 어떻게 알아채나" 소재예요.

#### (2) `@DynamicPropertySource`는 **값이 아니라 메서드**로 키에 참여한다.

```java
// [원문] spring-test 6.2.9, org/springframework/test/context/support/DynamicPropertiesContextCustomizer.java
private final Set<Method> methods;

@Override
public boolean equals(@Nullable Object other) {
    return (this == other || (other instanceof DynamicPropertiesContextCustomizer that &&
            this.methods.equals(that.methods)));
}

@Override
public int hashCode() {
    return this.methods.hashCode();
}
```

6.1.11도 같은 코드입니다. 등록하는 **값**이 아니라 `Set<Method>`가 키예요. 그래서:

- 베이스 클래스에 `@DynamicPropertySource` 메서드가 하나 있으면, 하위 클래스 전부가 **같은 `Method` 객체**를 공유 → 같은 커스터마이저 → **컨텍스트 공유**.
- 클래스마다 자기 `@DynamicPropertySource` static 메서드를 따로 두면, **똑같은 값을 등록해도** `Method`가 달라 컨텍스트가 갈립니다.

**§1의 "베이스 클래스가 변수다"에 대한 메커니즘 설명이 바로 이겁니다.** Testcontainers를 쓰는 통합 테스트는 거의 반드시 `@DynamicPropertySource`가 필요한데, 그걸 어디에 두느냐가 컨테이너 하나를 공유하느냐 마느냐를 결정합니다.

#### (3) `@MockBean` / `@MockitoBean`은 **정의 집합**으로 키에 참여한다.

```java
// [원문] spring-boot-test 2.7.18, org/springframework/boot/test/mock/mockito/MockitoContextCustomizer.java
class MockitoContextCustomizer implements ContextCustomizer {

    private final Set<Definition> definitions;
    ...
    @Override
    public boolean equals(Object obj) {
        ...
        MockitoContextCustomizer other = (MockitoContextCustomizer) obj;
        return this.definitions.equals(other.definitions);
    }

    @Override
    public int hashCode() {
        return this.definitions.hashCode();
    }
}
```

`Set`의 `equals`라 **선언 순서는 무관**합니다(프로파일과 반대!). 하지만 **어떤 타입을 mock하는지의 집합**이 다르면 컨텍스트가 갈려요. mock 하나를 추가하면 그 클래스는 자기만의 컨텍스트를 갖게 됩니다.

> 💡 writer 메모: 프로파일은 순서를 보고 mock은 순서를 안 보는 이 비대칭이 재밌습니다. 둘 다 "같은 뜻인데 표기가 다르면?"에 대한 답인데 정반대예요. 짧게 한 문장으로 짚고 넘어가면 좋습니다.

### 2-4. `ApplicationContextRunner`는 캐시에 아예 참여하지 않는다

이게 §1 Runner vs Autowired 선택의 숨은 비용입니다.

```java
// [원문] spring-boot-test 3.2.8, org/springframework/boot/test/context/runner/AbstractApplicationContextRunner.java:79
 * assertions to the context. Upon completion, the context is automatically closed.
```

```java
// [원문] 같은 파일 :362
try (A context = createAssertableContext(refresh)) {
```

`run()` 호출마다 컨텍스트를 새로 만들고 try-with-resources로 닫습니다. 캐시를 거치지 않아요. 사내 저장소의 Runner 기반 테스트 8개 파일에서 `run()` 호출은 총 17회입니다. 즉 **컨텍스트 17개를 만들었다가 버립니다.**

그런데 이게 손해가 아닌 이유가 있어요. Runner가 만드는 컨텍스트는 `withUserConfiguration(TestConfig.class)` + 필요한 자동설정 몇 개뿐이라 **DataSource도 MyBatis도 없습니다.** 앱 전체를 띄우는 컨텍스트를 캐시에서 꺼내는 것보다, 빈 5개짜리 컨텍스트를 새로 만드는 게 더 쌉니다.

> 💡 writer 메모: "캐시를 공유하라"와 "Runner를 써라"가 충돌하는 것처럼 보이는데 충돌하지 않습니다. **캐시 공유는 비싼 컨텍스트에서만 의미가 있고, Runner는 애초에 싼 컨텍스트를 만드니까요.** 이 대비가 §2 스코프 원칙("좁힘이 기본")을 캐시 관점에서 재해석하는 좋은 자리입니다.

### 2-5. `ApplicationContextRunner`와 `@ContextConfiguration`은 yml을 자동으로 읽지 않는다

```java
// [원문] spring-boot-test 3.2.8, org/springframework/boot/test/context/ConfigDataApplicationContextInitializer.java:29-33 (javadoc)
/**
 * {@link ApplicationContextInitializer} that can be used with the
 * {@link ContextConfiguration#initializers()} to trigger loading of {@link ConfigData}
 * such as {@literal application.properties}.
 */
```

`@SpringBootTest`는 `SpringApplication`을 거치므로 `application.yml`이 자동으로 로드됩니다. `ApplicationContextRunner`와 `@ExtendWith(SpringExtension.class)` + `@ContextConfiguration`은 그 경로를 안 거쳐요. 그래서 값을 리터럴로 때우기 쉬워지고, 그게 §3 하드코딩 문제로 이어집니다. 해법은 `ConfigDataApplicationContextInitializer`입니다.

⚠️ 그리고 이 initializer는 `contextInitializerClasses`로 **캐시 키에 참여**합니다(§2-1 목록). 붙이는 순간 안 붙인 것과 다른 컨텍스트가 돼요.

---

## 3. 근거: 사내 저장소 정적 집계 [재구성]

### 3-1. 방법과 한계

파서를 새로 작성해 `src/test/java` 아래 Java 파일을 전부 훑고, 클래스 레벨 애노테이션과 **상속 체인**을 합쳐 "이 클래스가 실제로 요구하는 컨텍스트 설정"을 튜플로 만든 뒤 중복을 셌습니다.

⚠️ **한계를 먼저 적습니다.**

- 정적 근사입니다. `contextCustomizerFactory`가 실제로 만드는 커스터마이저 목록(Boot는 12개를 붙입니다. §4-3 참조), 중첩 `@TestConfiguration`이 `classes` 배열에 더해지는 방식, `@AutoConfigure*`가 생성하는 property source의 세부값은 반영하지 못합니다.
- 그래서 이 집계는 **서로 다른 컨텍스트 수의 하한**입니다. 실제 개수는 이보다 크거나 같아요.
- 파서 버그가 하나 있었습니다. 처음엔 클래스 선언 앞을 `}` 기준으로 잘랐는데 `@SpringBootTest(classes = {A.class, B.class})`의 `}`에 걸려 애노테이션을 통째로 놓쳤습니다. 뒤로 훑는 방식으로 고친 뒤 대상 클래스가 775 → 892로 늘었어요. **재현하는 사람은 이 함정을 조심하세요.**

### 3-2. ★ 결정적 사전 정리: "425건"은 애초에 한 덩어리가 아니다

1편 노트가 넘겨준 숫자는 "인자 없는 `@SpringBootTest` 425건"이었습니다(이번 재집계로는 426줄). 그런데 §2-1의 마지막 인용이 이 질문을 무너뜨립니다.

> "To benefit from the caching mechanism, all tests must run within the same process or test suite."

이 저장소는 모노레포지만 **Gradle 빌드가 40개로 갈라져 있습니다.** 각 모듈이 자기 `settings.gradle`을 갖고, 자기 `test` 태스크에서 자기 JVM을 띄웁니다. 컨텍스트 캐시는 그 JVM의 `static` 변수예요.

**그러니 "426건이 몇 개의 컨텍스트로 수렴하는가"는 성립하지 않는 질문입니다.** 426건은 40개의 JVM에 흩어져 있고, 캐시는 JVM 경계를 넘지 못합니다. 의미 있는 질문은 **"한 모듈 안에서 몇 개인가"**뿐이에요.

> 💡 writer 메모: **여기가 2편의 첫 번째 전환점입니다.** 리서치 착수 시 오케스트레이터가 던진 질문 자체가 틀렸고, 왜 틀렸는지가 공식 문서 한 문장에 있습니다. "저장소 전체 수치"를 세는 습관이 이 주제에서는 왜 답을 못 주는지 보여주는 자리예요. 1편의 "숫자가 판단을 대체하려 할 때"와 결이 같습니다.

### 3-3. 모듈별 집계

컨텍스트를 띄우는 구체 클래스(추상 베이스 제외) **892개**, 서로 다른 컨텍스트 키 **213개**. 모듈 40개에 걸쳐서요.

클래스가 4개 이상인 모듈만 옮기면 이렇습니다.

| 모듈 | 클래스 | 컨텍스트 | 재사용 비 |
|---|---|---|---|
| 모듈 C | 259 | 10 | **25.9** |
| 모듈 B | 65 | 12 | 5.4 |
| 모듈 I | 45 | 5 | 9.0 |
| 모듈 D | 46 | **34** | **1.4** |
| 모듈 A | 37 | 7 | 5.3 |
| 모듈 G | 16 | 2 | 8.0 |
| 모듈 H | 12 | 12 | **1.0** |
| 모듈 E | 12 | 11 | 1.1 |
| 모듈 J | 12 | 8 | 1.5 |
| 모듈 E′ | 9 | 9 | **1.0** |
| 모듈 F | 4 | 4 | **1.0** |
| **전체** | **892** | **213** | **4.2** |

**모듈 C가 결정적입니다.** 259개 클래스 중 **175개가 컨텍스트 하나를 공유**합니다. 전부 인자 없는 `@SpringBootTest`이고, 전부 같은 추상 베이스를 상속해요. 저장소에서 무인자 `@SpringBootTest`가 가장 많이 몰린 자리가 동시에 **캐시 효율이 가장 좋은 자리**입니다.

**모듈 D는 반대 극단이고, 여기가 진짜 문제입니다.** 46클래스 → 34컨텍스트. 기본 `maxSize`가 32이므로 **이 모듈은 한 번의 테스트 실행에서 LRU 축출이 실제로 일어납니다.** 축출된 컨텍스트는 닫히고, 그 설정이 다시 필요해지면 처음부터 다시 뜹니다.

> 💡 writer 메모: `maxSize=32`를 넘긴 모듈이 저장소 전체에서 **딱 하나**입니다. 이건 "우리 조직은 캐시를 망치고 있다"가 아니라 **"한 곳에서만 망가졌고, 그 한 곳을 특정할 수 있다"**는 이야기예요. 1편의 "총량은 적은데 하필 비싼 곳에 몰려 있다"와 정확히 같은 형태의 서술입니다. 과장하지 마세요.

### 3-4. 무엇이 컨텍스트를 가르는가 (원인별 기여)

같은 데이터에서 `@MockBean` 조합만 무시하고 다시 세어, mock이 만든 증가분을 뽑았습니다.

| 모듈 | 실제 컨텍스트 | mock 무시 시 | mock이 만든 증가 |
|---|---|---|---|
| 모듈 D | 34 | 29 | **+5** |
| 모듈 B | 12 | 6 | **+6** |
| 모듈 J | 8 | 5 | +3 |
| 모듈 A | 7 | 6 | +1 |
| 모듈 C | 10 | 10 | 0 |
| 모듈 G | 2 | 2 | 0 |
| 모듈 H | 12 | 12 | 0 |
| 모듈 E | 11 | 11 | 0 |
| 모듈 I | 5 | 5 | **0** |

모듈 I가 45클래스 중 14개에 mock을 다는데 증가가 **0**입니다. 이유는 §1에 있어요. mock을 **베이스 클래스에** 달았기 때문입니다. 클래스마다 달았으면 14개로 갈렸을 거예요.

반대로 모듈 D는 31클래스가 mock을 다는데 조합이 **29가지**입니다. 사실상 클래스마다 다릅니다. mock이 많은 클래스도 여기 몰려 있어요. 모듈 A에는 mock을 **16종**, **15종** 선언한 클래스가 하나씩 있고 각자 고유 컨텍스트를 갖습니다.

**정리하면 키를 가르는 축의 실제 기여 순서는 이렇습니다.**

1. `@ActiveProfiles` 조합 (가장 많이 가른다. 모듈 C의 10개 중 9개, 모듈 E의 11개 중 5개가 여기서 갈림)
2. `@MockBean` 조합
3. `@TestPropertySource` / `@AutoConfigure*`
4. `classes=` (가장 적게 가른다)

### 3-5. ★ 같은 프로파일 집합인데 순서가 달라 갈린 자리 (실측 2건)

§2-3 (1)의 이론이 실제로 나타났습니다. 모듈 C에서, 전부 같은 베이스를 상속하는 클래스들입니다. `[재구성]`

```java
// [재구성] 같은 모듈, 같은 베이스, 같은 프로파일 집합. 순서만 다르다.
@ActiveProfiles(profiles = {"default", "prod", "bset", "rest"})   // 클래스 하나
@ActiveProfiles(profiles = {"default", "rest", "prod", "bset"})   // 나머지

@ActiveProfiles(profiles = {"default", "dev", "l4", "rest"})      // 클래스 하나
@ActiveProfiles(profiles = {"default", "rest", "dev", "l4"})      // 나머지 다수
```

각 쌍은 활성 프로파일이 완전히 같습니다. 애플리케이션 동작도 같아요. **그런데 컨텍스트는 두 개 뜹니다.** `Arrays.hashCode`가 순서를 보니까요.

덤으로 하나 더 있습니다. 어떤 클래스는 프로파일 목록 안에서 항목 하나만 주석 처리했습니다.

```java
// [재구성]
@ActiveProfiles(profiles = {"default", "rest", "dev"
//  , "l4"
})
```

이건 세 번째 조합이 됩니다. 주석 한 줄이 컨텍스트 하나를 더 만들었어요.

> 💡 writer 메모: **2편의 하이라이트 후보입니다.** 코드 리뷰로는 절대 안 걸립니다. 실행해도 안 걸려요. 테스트는 전부 초록불이고, 느려질 뿐입니다. 1편의 주제 질문("무엇이 바뀌면 이게 실패해야 하는가")을 뒤집으면 이건 **"아무것도 실패하지 않는데 비용만 는다"**는 종류의 결함이에요. 테스트 자체가 아니라 테스트를 돌리는 인프라의 문제라 어떤 단언도 이걸 잡지 못합니다.

### 3-6. 슬라이스 애노테이션 + 실제 DB 하이브리드 [재구성]

1편에서 다룬 매퍼 IT들이 모듈 A에 있고, 이번 집계에서 그 조합이 어떻게 보이는지가 나왔습니다.

```java
// [재구성] 16개 클래스가 이 4줄을 글자까지 똑같이 갖는다
@MybatisTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ActiveProfiles("oracle-it")
@Tag("oracle-integration")
```

**16개 클래스 전부가 컨텍스트 하나를 공유합니다.** 모듈 A의 37클래스가 7컨텍스트인데, 그중 가장 큰 덩어리가 이 16개예요.

이게 왜 중요하냐면, **1편에서 가장 심하게 비판한 그 테스트들이 컨텍스트 관점에서는 저장소에서 가장 잘 만들어진 축**이기 때문입니다.

- `@MybatisTest`는 슬라이스입니다. 웹 레이어, 서비스 빈, 대부분의 자동설정을 뺍니다. **좁힘이 애노테이션 하나로 표현돼 있어요.**
- `@AutoConfigureTestDatabase(replace = NONE)`은 슬라이스의 기본 동작(인메모리 DB로 치환)을 끄고 실제 DB를 씁니다.
- 네 줄이 16개 클래스에서 **동일**하므로 캐시 키도 동일합니다.

**가설이 말한 "의미 단위 좁힘 + 설정 단위 공유"의 교과서적 사례입니다.** `@MybatisTest`라는 이름 자체가 "이건 매퍼 테스트다"를 선언하고, 그 선언이 동시에 캐시 키가 됩니다. 손으로 `classes = {MapperConfig.class, DataSourceConfig.class, ...}`를 적었다면 클래스마다 목록이 미묘하게 달라졌을 거예요.

> 💡 writer 메모: **이 대비가 1편과 2편을 잇는 가장 좋은 다리입니다.** 같은 코드가 한 축(단언)에서는 최악이고 다른 축(컨텍스트 구성)에서는 최선입니다. "테스트가 좋다/나쁘다"는 단일 축 판정이 왜 안 되는지 보여줘요. 그리고 1편 결론("경계 선택은 옳았고 단언이 틀렸다")을 정량적으로 확인해 줍니다.
>
> ⚠️ 다만 1편 본문의 서술을 소급해 고치는 식으로 쓰지 마세요. "1편에서 비판한 그 테스트"라고만 참조합니다.

### 3-7. L3 매퍼용과 L5 인수용이 다른 베이스를 쓰는 이유: **캐시 분리가 아니었다**

1편 노트 §5가 "컨텍스트 캐시 분리 의도로 보이나 미확인"으로 남긴 항목입니다. **확인했고, 부정입니다.**

두 베이스는 **서로 다른 Gradle 프로젝트, 서로 다른 애플리케이션**에 있습니다. 같은 JVM에서 만날 일이 애초에 없어요. 캐시를 나눌 이유가 없으니 나눈 게 아니라, 나뉜 것을 나눴다고 볼 수도 없는 겁니다.

실제 이유는 매퍼 베이스의 주석에 적혀 있습니다. `[재구성]`

```java
// [재구성] L3 매퍼 테스트 공통 베이스
/**
 * 인프라 계약:
 * - Oracle: 싱글턴 static 컨테이너(클래스 간 1회 기동 공유), schema-test.sql 1회 init
 * - 이 앱은 단일 datasource → spring.datasource.{url,username,password} 오버라이드
 *   (웹훅 쪽의 master/slave 라우팅과 다름)
 */
@SpringBootTest
@ActiveProfiles("test")
public abstract class MapperTestBase {

    protected static final OracleContainer ORACLE = ...;

    static { ORACLE.start(); }

    @DynamicPropertySource
    static void overrideDataSourceProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", ORACLE::getJdbcUrl);
        registry.add("spring.datasource.username", ORACLE::getUsername);
        registry.add("spring.datasource.password", ORACLE::getPassword);
    }
    ...
}
```

**데이터소스 구조가 다른 애플리케이션이라 프로퍼티 키가 다릅니다.** 한쪽은 `spring.datasource.*`, 다른 쪽은 `spring.datasource.master.*` / `spring.datasource.slave.*`예요.

같은 주석에 **실패에서 배운 기록**이 함께 있습니다(구조만 옮깁니다).

> `withReuse`와 `withInitScript`를 같이 쓰면 재사용 컨테이너에서 init script가 재실행되지 않고 ready 로그 재관측에 실패해 기동이 깨진다. 콜드 기동이 Testcontainers 기본 대기 타임아웃을 넘기므로 기동 타임아웃을 명시적으로 늘린다.

인수 테스트 베이스에도 같은 성격의 기록이 있어요. HTTP/2 평문 업그레이드를 끄지 않으면 첫 요청이 RST_STREAM으로 끊겨 스텁 서버의 요청 저널이 유실된다는 내용입니다.

> 💡 writer 메모: 이 두 주석은 "베이스 클래스가 캐시 공유 장치이기 전에 **인프라 계약의 기록 장소**"라는 걸 보여줍니다. 컨테이너를 어떻게 띄우고 왜 그렇게 띄우는지가 한 군데 모여 있어요. 클래스마다 컨테이너를 띄웠으면 이 지식도 흩어졌을 겁니다. **캐시 효율은 그 구조의 부산물**이라는 각도가 좋습니다.

---

### 3-8. ★ 가장 좁힌 컨텍스트는 컨텍스트를 안 띄우는 것이다 [재구성]

§5-0의 그 하루에 일어난 일 중 가장 큰 것은 Runner를 `@Autowired`로 바꾼 게 아닙니다. **다섯 개 파일이 Spring 컨텍스트를 통째로 버렸습니다.**

교정 커밋의 근거를 요지만 옮기면 이렇습니다.

> `@ConfigurationProperties` 클래스들이 이미 생성자 코드로 필수값을 검증하고 `IllegalStateException`을 던지는 순수 자바 클래스라는 점을 활용한다. Spring 컨텍스트를 띄울 필요 없이 `new XxxProperties(...)`를 직접 호출해 `assertThatThrownBy`로 검증하면 된다. `ApplicationContextRunner`, `TestConfig` 중첩 클래스, 헬퍼를 전부 제거한다.

**그런데 여기서 멈추지 않은 게 중요합니다.** 컨텍스트를 버리면 못 보게 되는 것이 무엇인지 함께 적고, 그 책임을 한 군데로 모았어요.

> Spring의 kebab-case 프로퍼티 키에서 생성자 파라미터로 이어지는 relaxed binding 자체를 검증하는 책임은 실제 yml을 로드하는 테스트 하나로 모은다. 커버리지 공백을 메우려고 프로퍼티 클래스 하나를 그 테스트에 새로 추가했다.

**이게 스킬 §2의 "좁힌 테스트와 전체 테스트는 서로 다른 결함을 잡는다"를 실제로 집행한 모습입니다.** 생성자 직접 호출은 "필수값이 없으면 예외를 던지는가"를 검증하고, yml 로드 테스트는 "yml의 `read-timeout`이 생성자의 `readTimeout` 파라미터에 실제로 꽂히는가"를 검증합니다. 오타나 필드 뒤바뀜은 앞쪽이 절대 못 잡아요.

그리고 부수 효과로 **테스트 이름이 함께 바뀌었습니다.**

> 일부 테스트명을 "…기동에_실패한다"에서 "…예외를_던진다"로 바꿨다. 더 이상 Spring 컨텍스트 기동이 아니라 생성자 예외를 검증하므로 이름이 실제 동작과 맞아야 한다.

> 💡 writer 메모: 세 가지가 한 번에 나옵니다.
> 1. **가장 좁힌 컨텍스트는 컨텍스트를 안 띄우는 것.** "스코프를 좁혀라"의 극단은 Spring을 아예 안 쓰는 것이고, 실제로 그게 답인 자리가 있었습니다.
> 2. **버릴 때 무엇을 못 보게 되는지 함께 적었다.** 이게 1편의 "무엇이 안 덮이는지 아는 것이 경계"와 같은 동작이에요.
> 3. **1편의 "이름이 곧 명세"가 여기서 저절로 따라왔습니다.** 컨텍스트를 걷어내니 이름이 거짓말이 됐고, 같은 커밋에서 고쳐졌습니다. 1편을 되풀이하지 말고 **"경계를 옮기면 이름도 함께 옮겨야 한다"**는 한 줄로만 참조하세요.

## 4. 근거: 실측 [재구성. 대상은 사내 모듈이지만 수치와 방법은 그대로]

정적 분석만으로는 "실제로 몇 번 뜨는가"를 못 봅니다. 그래서 **실제로 돌렸습니다.**

### 4-1. 방법

- 대상: 모듈 E (Spring Boot 3.5.4 / Spring Framework 6.2.9. 실행 로그에서 확인)
- `org.springframework.test.context.cache` 로거를 DEBUG로 올리면 `DefaultContextCache.logStatistics()`가 매 컨텍스트 요청마다 `size / maxSize / hitCount / missCount / failureCount`를 찍습니다.
- 저장소를 수정하지 않기 위해 Gradle **init script**로 테스트 JVM에만 설정을 주입했습니다.

⚠️ **함정 하나를 기록해 둡니다.** `-Dlogback.configurationFile`로 로거를 켜면 처음엔 찍히다가 **중간에 멈춥니다.** 첫 `@SpringBootTest`가 뜨는 순간 Spring Boot의 `LogbackLoggingSystem`이 클래스패스의 `logback-test.xml`로 로깅을 재초기화해서 내 설정을 덮어쓰기 때문이에요. `logging.level.org.springframework.test.context.cache=DEBUG`를 **시스템 프로퍼티로 함께** 줘야 끝까지 찍힙니다. 첫 측정에서 이걸 놓쳐 컨텍스트 2개만 관측했고, 고친 뒤 10개가 나왔습니다.

### 4-2. 결과 (깨끗한 측정)

모듈 E의 공통 지원 패키지 테스트 24개 클래스를 돌렸습니다. **BUILD SUCCESSFUL, 실패 0건.**

```
size = 10, maxSize = 32, parentContextCount = 0, hitCount = 914, missCount = 10, failureCount = 0
```

- 컨텍스트 요청 **924회**
- 실제로 로드된 컨텍스트 **10개**
- 캐시 히트 **914회** → 재사용 비 **91.4 : 1**
- `maxSize` 32에 도달하지 않음

정적 분석이 이 모듈에 대해 예측한 값은 "12클래스 → 11컨텍스트"였는데, 실측 대상은 그중 일부 패키지라 직접 비교는 안 됩니다. 다만 **`maxSize`를 넘지 않는다**는 정적 예측은 실측과 일치합니다.

미스 10건이 발생한 지점을 로그에서 되짚으면, 5건이 프로파일 바인딩 테스트 5종(프로파일이 각자 다르니 당연)이고 나머지 5건이 `@ContextConfiguration` 기반 테스트들이었습니다.

### 4-3. ★ 실패 로그가 캐시 키 실물을 통째로 뱉는다

컨텍스트 로드가 실패하면 Spring이 `MergedContextConfiguration`을 **전부 출력**합니다. 캐시 키를 눈으로 볼 수 있는 유일한 자리예요. 클래스명만 중립화해 옮기면 이렇습니다. `[재구성. 값은 실제 출력]`

```
Failed to load ApplicationContext for [MergedContextConfiguration@... 
  testClass = ProdProfileBindingTest,
  locations = [],
  classes = [ProdProfileBindingTest.TestConfig],
  contextInitializerClasses = [],
  activeProfiles = ["prod"],
  propertySourceDescriptors = [],
  propertySourceProperties = ["org.springframework.boot.test.context.SpringBootTestContextBootstrapper=true",
                              "spring.main.web-application-type=none"],
  contextCustomizers = [ServiceConnectionContextCustomizer@0,
                        OnFailureConditionReportContextCustomizer@3751acd7,
                        DisableObservabilityContextCustomizer@1f,
                        PropertyMappingContextCustomizer@0,
                        WebDriverContextCustomizer@1aedf08d,
                        ExcludeFilterContextCustomizer@3962ec84,
                        DuplicateJsonObjectContextCustomizer@3cf55e0c,
                        MockitoContextCustomizer@0,
                        TestRestTemplateContextCustomizer@5980fa73,
                        DisableReactorResourceFactoryGlobalResourcesContextCustomizerCustomizer@216f01,
                        DynamicPropertiesContextCustomizer@0,
                        SpringBootTestAnnotation@4ffa5e9d],
  contextLoader = org.springframework.boot.test.context.SpringBootContextLoader,
  parent = null]
```

여기서 읽을 게 많습니다.

- **`@SpringBootTest` 하나만 달아도 커스터마이저가 12개** 붙습니다. Spring Boot가 자동으로요.
- `MockitoContextCustomizer@0`과 `DynamicPropertiesContextCustomizer@0`. 해시코드 0은 **빈 집합**입니다. mock도 `@DynamicPropertySource`도 없는 상태예요. 빈 것끼리는 같으므로 이 자리는 키를 가르지 않습니다. **하나라도 추가하는 순간 갈립니다.**
- `SpringBootTestAnnotation@...`이 별도 커스터마이저입니다. `@SpringBootTest`의 `webEnvironment`, `properties`, `args`가 여기로 들어가요.
- Boot가 `propertySourceProperties`에 두 줄을 자동으로 넣습니다.

> 💡 writer 메모: **이 덤프를 본문에 실으면 "캐시 키가 뭔지"를 설명할 필요가 없어집니다.** 독자가 자기 프로젝트에서 재현할 수 있는 방법(일부러 컨텍스트를 깨뜨리거나 캐시 로거를 켜기)도 함께 알려 주면 실용적이에요.

### 4-4. 실측하지 못한 것 (중요)

- **모듈 전체 실행은 신뢰할 수 없습니다.** 전체를 돌리면 413건 중 17건이 실패하고 BUILD FAILED가 납니다. 그런데 **같은 클래스들이 부분 실행에서는 전부 통과**했어요. 원인은 이 환경 문제로 보입니다(오프라인 의존성 부족으로 인한 `ClassNotFoundException` 11건, 나머지는 git에 실값이 없는 프로퍼티). **저장소가 원래 깨져 있다고 쓰면 안 됩니다.**
  - 참고로 그 실패 실행의 통계는 `size = 10, hitCount = 440, missCount = 15, failureCount = 5`였습니다. `failureCount`는 로드에 실패한 컨텍스트 수예요. **실패한 컨텍스트도 키로 세어진다**는 건 알 수 있지만, 이 수치를 정상 실행의 근거로 쓰지 마세요.
- **모듈 D(`maxSize` 34개 초과 의심)는 실행하지 못했습니다.** 정적 예측뿐입니다. **본문에서 "실제로 축출이 일어났다"고 쓰면 안 됩니다.** "정적으로 세면 34가지이고, 기본 상한이 32이므로 축출이 일어날 조건에 있다"까지가 확인된 사실입니다.
- **컨텍스트 로드에 걸리는 시간은 측정하지 않았습니다.** "캐시 미스 하나가 몇 초"라는 식의 수치를 쓰지 마세요.
- **다른 모듈은 전부 정적 분석뿐입니다.** 실측한 것은 모듈 E 하나입니다.

---

## 5. 근거: Runner vs Autowired, 세 신호의 실제 사례

`sr-harness`의 `dev-testing-strategy` 스킬 §1은 세 신호 중 하나라도 걸리면 `ApplicationContextRunner`라고 합니다. 사내 저장소에서 **세 신호에 하나씩 대응하는 실물**을 찾았습니다.

### 5-0. ★★ 그 경고는 왜 붙어 있나: 기준이 하나였다가 셋이 된 이력 [재구성]

**이 절이 2편에서 가장 값어치 있는 근거입니다.** 스킬 `:34`는 "신호 1만 기계적으로 확인하고 판단하지 않는다"고 경고합니다. 경고가 존재한다는 건 누군가 그 함정에 빠졌다는 뜻이에요. **사내 저장소의 커밋 이력이 그 과정을 날짜 단위로 남기고 있습니다.**

#### 2026-08-09: 기준은 하나였다

그날 하루 동안 `ApplicationContextRunner`를 걷어내는 작업이 연달아 있었습니다. 커밋 제목만 옮기면 이런 흐름이에요.

- properties와 config 테스트에서 **`ApplicationContextRunner` 제거와 최소화**
- 어댑터 통합 테스트 3종을 **`@SpringBootTest` + `@Autowired` 단일 컨텍스트로 통일**
- 테스트 티어 재구성(접미사 불일치 6건 정리)
- 그리고 그날 밤 **컨벤션 스킬 신설**

그 최초 스킬의 선택 기준은 이렇게 시작합니다(요지만 옮깁니다).

> **기준은 하나: 클래스 안의 테스트 메서드마다 유효 프로퍼티 조합이 달라지는가.**

**기준이 하나뿐이었습니다.** 그리고 그 기준으로 보면 대부분의 Runner는 걷어내는 게 맞았어요.

#### 같은 문서, 같은 날, 이미 붙어 있던 예외

그런데 그 최초 버전의 같은 절 맨 아래에 **예외 조항이 하나 달려 있습니다.**

> **주의 — `AutoConfigurations.of(...)`를 쓰는 파일은 `Runner`를 유지한다(2026-08-09 실측).** (…) **실측 결과 `HikariDataSource.getMetricsTrackerFactory()`가 조용히 `null`이 됐다.**

**기준을 적은 날에 이미 예외를 발견했다는 뜻입니다.** 걷어내다가 하나가 깨졌고, 깨진 걸 되돌리면서 규칙과 예외를 함께 적었어요.

그날의 Runner 제거 커밋 본문에도 그 흔적이 남아 있습니다. 어떤 클래스를 왜 안전하게 전환할 수 있었는지 설명하면서 **깨진 쪽을 명시적으로 대조**합니다(요지만 옮깁니다).

> 이 설정 클래스는 생성자가 빌더를 주입받는 구조라, 자동설정을 `@ContextConfiguration(classes=...)`로 직접 로드해도 빈 그래프 순서에 영향받지 않는다(생성자 의존은 선언 순서가 아니라 의존 그래프로 해석됨). **`BeanPostProcessor` 기반 배선과는 다른 케이스다.**

#### 2026-08-10: 예외가 기준으로 승격되고, 세 번째가 나타났다

다음 날 스킬이 개정됩니다. 바뀐 것은 셋입니다.

1. **"기준은 하나"가 "세 기준 중 하나라도 해당하면"으로** 바뀜.
2. 어제의 "주의" 예외가 **기준 2로 승격**됨.
3. **기준 3이 새로 추가**됨(컨텍스트 구조 자체가 단언 대상인가, "2026-08-10 확정").

그리고 머리말에 경고 문장이 붙습니다.

> 프로퍼티 공유 여부(기준 1) 하나만 보고 기계적으로 판단하지 않는다. 기준 3에 해당하는데 기준 1만 보고 옮기면 조용히 잘못된 선택이 된다.

**즉 경고는 예방적 조언이 아니라 사후 기록입니다.** 그리고 공개 `sr-harness` 스킬 `:34`의 "주의" 문장이 바로 이것의 일반화판이에요.

#### ★ 여기서 나오는 결론

**함정에 빠진 게 아니라 규칙이 불완전했던 겁니다.** 기준 1이 유일한 기준이던 시절에는, 기준 1만 보고 판단하는 것이 **규칙을 정확히 지키는 행동**이었습니다.

그러니 "왜 사람들이 습관적으로 반대쪽을 고르는가"의 답은 이렇습니다.

- 기준 1은 **코드를 보면 바로 확인됩니다.** 메서드마다 `withPropertyValues`가 다른지만 보면 돼요.
- 기준 2와 3은 **무엇이 깨지는지 알아야 확인됩니다.** 자동설정 순서 보장이 뭔지, `@Autowired`로 표현할 수 없는 단언이 뭔지를 미리 알아야 합니다.
- 검사하기 쉬운 기준이 하나 있으면, **그게 유일한 기준인 것처럼 작동합니다.**

> 💡 writer 메모: **2편의 주제문 1순위가 여기 있습니다.** 1편은 "기준이 문서에 있었는데 260곳에서 안 지켜졌다"였습니다. 2편은 정반대예요. **기준이 지켜졌는데, 기준이 틀렸습니다.** 같은 사람이 같은 날 규칙을 적고 그 규칙의 예외를 발견했고, 하루 뒤 예외를 규칙으로 올렸습니다.
>
> 그리고 1편의 §1-5(기계적으로 검사 가능한 규칙은 95% 지켜지고 판단이 필요한 규칙은 73% 어겨졌다)와 정확히 같은 축입니다. 여기서는 **검사하기 쉬운 기준이 나머지를 가려 버렸어요.** 다만 1편 수치를 다시 인용하지는 마세요. 구조만 참조합니다.
>
> ⚠️ 익명화: 커밋 해시, 사내 이슈 번호, 실제 클래스명은 쓰지 마세요. 날짜(2026-08-09 → 08-10)와 "기준이 1개에서 3개로"라는 구조만 씁니다.

### 5-1. 스킬 원문 [원문 인용 가능]

출처: `~/.claude/plugins/cache/sr-harness/sr-harness/0.23.0/skills/dev-testing-strategy/SKILL.md`. 필자가 GitHub 마켓플레이스로 배포하는 공개 플러그인이라 원문 인용이 가능합니다. 저장소는 [SeokRae/sr-harness](https://github.com/SeokRae/sr-harness).

- `:8` "Spring 통합 테스트를 작성하기 전, 각 섹션의 원칙을 확인하고 구현에 반영한다. `dev-coding-principles §3 Test`가 "단위냐 통합이냐"를 가른다면, 이 스킬은 "통합이라면 컨텍스트를 어떻게 띄우나"를 가른다."
- `:19` "아래 세 신호 중 **하나라도 해당하면** `ApplicationContextRunner`(프로그래밍 방식). 셋 다 아니면 `@ExtendWith(SpringExtension.class)` + `@ContextConfiguration`/`@SpringBootTest(classes=...)` + `@Autowired`로 클래스당 컨텍스트 하나만 띄운다."
- `:21` "- **신호 1 — 프로퍼티 조합이 테스트 메서드마다 다르다**: 필수값 누락 시 기동 실패를 검증하거나, 메서드별로 다른 프로파일/프로퍼티를 쓴다. `@Autowired`는 클래스당 컨텍스트 하나가 전제라 실패 시나리오를 예외 없이 우아하게 받을 수 없다(컨텍스트 준비 단계에서 바로 에러가 터진다)."
- `:22` "- **신호 2 — `AutoConfigurations.of(...)`로 여러 자동설정을 조합한다**: 자동설정끼리는 `@AutoConfigureAfter` 등으로 순서가 정해져 있다. `@ContextConfiguration(classes=...)`는 선언 순서로만 처리해 이 보장이 깨진다 — 특히 `BeanPostProcessor`를 등록하는 자동설정이 얽히면 조용히 깨진다(컴파일도 되고 다른 단언도 다 통과하는데 특정 값 하나만 예상과 달라지는 식이라 알아채기 어렵다)."
- `:23` "- **신호 3 — 컨텍스트 구조 자체가 단언 대상이다**: 빈의 존재/부재, 두 빈이 같은 인스턴스인지, 기동 성공/실패 — 이런 건 `@Autowired`로 표현할 방법이 없다. 주입할 대상이 "없어야 정상"인 케이스를 우아하게 확인할 수 없고, 컨텍스트가 실패하면 테스트 메서드가 실행되기도 전에 셋업 단계에서 예외가 터진다."
- `:34` "**주의**: 신호 1(프로퍼티 공유 여부)만 기계적으로 확인하고 판단하지 않는다. 프로퍼티는 완전히 고정 공유하는데 신호 3에 걸려 있는 테스트를 신호 1만 보고 `@Autowired`로 옮기면 조용히 잘못된 선택이 된다."

`:25-32`에 신호 3 예시 코드 블록도 있습니다. 본문(`:26-31`)은 이렇습니다.

```java
// [원문] sr-harness 0.23.0 dev-testing-strategy/SKILL.md:26-31
// 신호 3 예시 — 이 이름의 빈이 없어야 정상인 케이스
contextRunner.run(context -> {
    assertThat(context).hasNotFailed();
    assertThat(context).doesNotHaveBean("sharedHttpClient");
    assertThat(context).hasBean("dedicatedHttpClient");
});
```

### 5-2. 신호 1의 실물 [재구성]

액추에이터 노출 정책 테스트입니다. 테스트 4개 중 3개는 `test` 프로파일을 쓰고 마지막 하나만 `dev`를 씁니다.

```java
// [재구성]
class ActuatorExposureIntegrationTest {

    private final ApplicationContextRunner contextRunner = new ApplicationContextRunner()
            .withInitializer(new ConfigDataApplicationContextInitializer())
            .withPropertyValues("spring.profiles.active=test")
            .withUserConfiguration(TestConfig.class);

    @Test
    void dev_프로필_오버라이드는_base_노출을_잃지_않는다() {
        ApplicationContextRunner devRunner = new ApplicationContextRunner()
                .withInitializer(new ConfigDataApplicationContextInitializer())
                .withPropertyValues("spring.profiles.active=dev")
                .withUserConfiguration(TestConfig.class);

        devRunner.run(context -> { ... });
    }
}
```

클래스 javadoc이 이 테스트가 존재하는 이유를 적어 뒀습니다. 요지만 옮기면, 액추에이터 노출 목록은 프로파일 파일에서 다시 선언하면 base 목록을 **병합하지 않고 통째로 대체**한다는 것. base의 항목들을 dev 쪽에 다시 적지 않으면 메트릭 엔드포인트가 dev에서 조용히 사라집니다.

**`@Autowired` 방식으로는 이 테스트를 한 클래스에 담을 수 없습니다.** 클래스당 컨텍스트 하나가 전제니까요. 클래스를 둘로 쪼개면 되지만, 그러면 "base와 dev를 대조한다"는 이 테스트의 목적이 두 파일로 흩어집니다.

### 5-3. 신호 2의 실물, 그리고 ★ "조용히 깨진 사건" [재구성]

오케스트레이터가 찾아 달라고 한 "`@ContextConfiguration(classes=...)`가 자동설정 순서 보장을 깨뜨려 조용히 값 하나만 달라진" 사건이 **실재합니다.** 그것도 사내 컨벤션 문서에 실측 결과로 기록돼 있어요.

커넥션 풀 메트릭 배선을 검증하는 테스트입니다.

```java
// [재구성]
class PoolMetricsBindingIntegrationTest {

    private final ApplicationContextRunner contextRunner = new ApplicationContextRunner()
            .withConfiguration(AutoConfigurations.of(
                    MetricsAutoConfiguration.class,
                    SimpleMetricsExportAutoConfiguration.class,
                    DataSourcePoolMetricsAutoConfiguration.class))
            .withUserConfiguration(TestConfig.class);

    @Test
    void master와_slave에_Micrometer_트래커가_배선된다() {
        contextRunner.run(context -> {
            HikariDataSource master = (HikariDataSource) context.getBean("masterDataSource", DataSource.class);
            HikariDataSource slave = (HikariDataSource) context.getBean("slaveDataSource", DataSource.class);

            assertThat(master.getMetricsTrackerFactory()).isInstanceOf(MicrometerMetricsTrackerFactory.class);
            assertThat(slave.getMetricsTrackerFactory()).isInstanceOf(MicrometerMetricsTrackerFactory.class);
        });
    }
    ...
}
```

**이 클래스는 모든 테스트가 같은 프로퍼티 조합을 씁니다. 즉 신호 1에 걸리지 않아요.** 그런데도 Runner입니다. 사내 컨벤션 문서가 그 이유를 이렇게 적습니다(구조와 요지만 옮깁니다).

> 모든 테스트가 같은 프로퍼티 조합을 쓰는데도(기준 1 미해당) `ApplicationContextRunner`를 쓴다. `AutoConfigurations.of(...)`가 등록하는 `BeanPostProcessor`는 자동설정 간 순서(`@AutoConfigureAfter`)를 실제 앱 기동과 동일하게 보장하는데, `@ContextConfiguration(classes=...)`는 선언 순서로만 처리해 이 보장이 깨진다. **실측 결과 `HikariDataSource.getMetricsTrackerFactory()`가 조용히 `null`이 됐다.** `AutoConfigurations.of(...)`로 자동설정 클래스(특히 `BeanPostProcessor`를 등록하는 것)를 끌어오는 파일을 전환할 때는 컴파일과 테스트 통과만으로 안전하다고 판단하지 말고 실제 값까지 확인한다.

**이게 스킬 §1 신호 2의 원본 사건입니다.** 컴파일 통과, 컨텍스트 기동 성공, 다른 단언 통과. 오직 `getMetricsTrackerFactory()`만 `null`이 됐어요. 그리고 그 값이 `null`이면 운영 대시보드에서 커넥션 풀 지표가 사라집니다.

같은 클래스의 세 번째 테스트에는 더 재밌는 게 있습니다.

```java
// [재구성]
@Test
void 커넥션을_열기_전에는_풀_시리즈가_없다() {
    // HikariDataSource(no-arg 생성 + 프로퍼티 세팅) 방식은 첫 getConnection() 전까지
    // 내부 풀을 만들지 않는다. Micrometer 게이지는 풀 생성 시점에 등록되므로,
    // 여기서는 트래커 팩토리만 배선되고 실제 시리즈는 아직 없다 — 운영 대시보드에서
    // 기동 직후 "No data"로 보이는 것이 정상이라는 근거.
    contextRunner.run(context -> {
        MeterRegistry registry = context.getBean(MeterRegistry.class);
        assertThat(registry.find("hikaricp.connections.max").gauges()).isEmpty();
    });
}
```

**"운영에서 이렇게 보이는 게 정상"을 테스트가 근거로 잠그고 있습니다.** 1편의 "이 테스트는 무슨 질문에 답하는가"에 대한 답이 주석에 그대로 있어요.

### 5-4. 신호 3의 실물 [재구성]

알림 전용 스레드풀과 HTTP 클라이언트의 배선을 검증합니다.

```java
// [재구성]
/**
 * 이 테스트가 필요한 이유: @Async("alertExecutor")는 지정한 executor를 찾지 못하면
 * 경고만 남기고 기본 executor로 조용히 폴백한다. 즉 빈 이름이 어긋나면 "알림이 웹훅 풀을
 * 잠식하지 않는다"는 이 도메인의 핵심 설계가 무력화되는데도 다른 테스트는 전부 초록이다.
 */
class AlertWiringIntegrationTest {

    private final ApplicationContextRunner contextRunner = new ApplicationContextRunner()
            .withInitializer(new ConfigDataApplicationContextInitializer())
            .withPropertyValues("spring.profiles.active=test")
            .withConfiguration(AutoConfigurations.of(TaskExecutionAutoConfiguration.class))
            .withUserConfiguration(TestConfig.class);

    @Test
    void alertExecutor가_sharedExecutor와_분리된_별개_풀이다() {
        contextRunner.run(context -> {
            assertThat(context).hasBean("alertExecutor").hasBean("sharedExecutor");

            ThreadPoolTaskExecutor alert = context.getBean("alertExecutor", ThreadPoolTaskExecutor.class);
            ThreadPoolTaskExecutor shared = context.getBean("sharedExecutor", ThreadPoolTaskExecutor.class);

            // 같은 인스턴스를 공유하면 알림 폭주가 웹훅 처리량을 잠식한다
            assertThat(alert).isNotSameAs(shared);
            assertThat(alert.getThreadNamePrefix()).isEqualTo("alert-");
        });
    }

    @Test
    void 공유_HTTP_클라이언트가_없어도_알림용은_독립적으로_만들어진다() {
        contextRunner.run(context -> {
            assertThat(context).hasNotFailed();
            assertThat(context).doesNotHaveBean("sharedHttpClient");
            assertThat(context).hasBean("alertHttpClient");
        });
    }
}
```

**세 테스트 전부 프로퍼티를 고정 공유합니다. 신호 1에 안 걸려요.** 그런데 `doesNotHaveBean`과 `isNotSameAs`는 `@Autowired`로 표현할 방법이 없습니다. "없어야 정상인 빈"을 주입받을 수는 없으니까요.

그리고 이 클래스도 "조용히 깨지는" 이야기입니다. **`@Async("이름")`은 그 이름의 executor를 못 찾으면 경고만 남기고 기본 executor로 폴백**합니다. 예외가 아니라 경고예요. 빈 이름 오타 하나로 격리 설계가 무너지는데 모든 테스트가 초록불입니다.

> ⛔ **이 문단의 메커니즘 서술은 틀렸습니다. W-28에서 뒤집혔습니다.** Spring 소스 확인 결과 이름을 준 `@Async`는 executor를 못 찾으면 `NoSuchBeanDefinitionException`을 **던집니다.** 경고 후 폴백은 이름을 **주지 않은** `@Async`의 경로예요. 다만 예외 시점이 컨텍스트 기동이 아니라 메서드 호출 시점이라 "컨텍스트는 초록불로 뜬다"는 결론은 유지됩니다. 진짜 무음 케이스는 두 이름이 **같은 인스턴스로 해석되는** 경우이고, 그게 이 테스트의 `isNotSameAs`가 잡는 것입니다. 발행본은 이 교정판을 실었습니다.

> 💡 writer 메모: 5-3과 5-4가 **같은 구조의 사건 두 개**입니다. 둘 다 "예외가 안 나고, 값 하나만 조용히 달라지고, 그 값이 운영에서 중요한" 유형이에요. 그리고 둘 다 **`@Autowired`로는 표현조차 못 하는 단언**을 필요로 합니다. 1편이 "실패할 수 없는 단언"을 다뤘다면, 2편의 이 대목은 **"컨텍스트 구성 방식이 표현 가능한 단언의 집합을 제한한다"**입니다. 좋은 논지예요.

### 5-5. 반대 방향. 셋 다 아니라서 `@Autowired`를 고른 자리 [재구성]

스킬이 "셋 다 아니면 `@Autowired`"라고 하는데, 그 판단을 **주석으로 남긴** 클래스가 있습니다.

```java
// [재구성] 프로파일별 프로퍼티 바인딩 테스트 (Dev / Prod / Stg / Dr / yaml 다섯 벌)
/**
 * 이 클래스의 테스트는 전부 prod 프로파일 하나만 쓰므로 ApplicationContextRunner 대신
 * @ActiveProfiles + @Autowired로 컨텍스트를 한 번만 띄운다. 필드별 검증은 @ParameterizedTest로
 * 뽑아 각 값이 실패할 때 어느 필드인지 리포트에서 바로 드러나게 한다.
 */
@SpringBootTest(classes = ProdProfileBindingTest.TestConfig.class, webEnvironment = SpringBootTest.WebEnvironment.NONE)
@ActiveProfiles("prod")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class ProdProfileBindingTest {

    @Autowired
    private ServiceProperties serviceProperties;
    @Autowired
    private AlertProperties alertProperties;

    @ParameterizedTest(name = "{0}")
    @MethodSource("expectations")
    void prod_프로파일은_실서비스_설정으로_바인딩된다(String property, Executable assertion) throws Throwable {
        assertion.execute();
    }

    private Stream<Arguments> expectations() {
        return Stream.of(
                Arguments.of("service.mode", (Executable) () -> assertThat(...).isEqualTo("real")),
                Arguments.of("alert.enabled", (Executable) () -> assertThat(...).isTrue()),
                ...);
    }

    @Configuration
    @EnableConfigurationProperties({ServiceProperties.class, AlertProperties.class})
    static class TestConfig { }
}
```

같은 javadoc에 **왜 이 테스트가 필요한지**도 있습니다. 요지만 옮기면, 알림 서버 주소가 stg와 prod에서 완전히 동일하고 두 환경을 가르는 값은 `enabled` 하나뿐이라는 것. 주소만 보고 "같은 서버니 안전하다"고 넘기면 `enabled` 하나를 놓치는 순간 운영 알림이 prod에서 무음이 되거나 stg에서 새어 나갈 수 있습니다.

**그리고 이게 §1에서 말한 "`classes=`가 범인이 아닌" 자리입니다.** 다섯 벌이 각자 `TestConfig`를 갖지만, `@ActiveProfiles`가 이미 다르므로 `classes=`를 지워도 컨텍스트는 여전히 다섯 개예요. `classes=`가 한 일은 다섯 개를 각각 **작게** 만든 것뿐입니다. 실측에서 이 다섯 컨텍스트는 각각 0.03초 안팎에 떴습니다.

---

## 6. 근거: 프로퍼티 값 관리 (스킬 §3)

### 6-1. 스킬 원문 [원문 인용 가능]

`sr-harness` 0.23.0 `dev-testing-strategy/SKILL.md`:

- `:50` "**하드코딩 금지**: URI, 타임아웃, 재시도 횟수처럼 이미 실제 yml/properties에 있는 값을 테스트 코드에 리터럴로 다시 적지 않는다. 실제 설정 파일을 그대로 로드해서 쓴다 — 운영 값이 바뀌면 테스트도 자동으로 따라가야 한다."
- `:51` "**`@DynamicPropertySource`는 런타임에만 정해지는 값 전용**: 스텁 서버 포트, Testcontainers가 뜬 뒤에만 알 수 있는 접속 정보처럼 미리 알 수 없는 값에만 쓴다. 이미 설정 파일에 있는 값을 여기서 다시 적으면 하드코딩과 같은 문제가 재발한다."
- `:52` "**정적 메서드 실행 시점을 기억한다**: `@DynamicPropertySource` static 메서드는 컨텍스트 리프레시 **전에** 실행된다 — 그 시점엔 `@Autowired`로 다른 설정값을 읽을 수 없다. 정확한 값이 필요하면(예: 요청 경로) 컨텍스트가 뜬 뒤 `@Autowired`로 실제 설정을 읽어 기대값을 계산하거나, 값에 의존하지 않는 catch-all 방식으로 설계한다."

### 6-2. `@DynamicPropertySource` 전수 조사 결과

저장소의 `@DynamicPropertySource` 등록을 전부 훑었습니다. **대부분은 규칙대로입니다.** Testcontainers JDBC URL/계정, 스텁 서버 포트, WireMock 포트뿐이에요.

**예외가 한 자리 있습니다.** 모듈 K입니다. `[재구성]`

```java
// [재구성] 모듈 K의 통합 테스트 베이스
@Testcontainers
public abstract class PostgresTestBase {

    @Container
    static final PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
            .withDatabaseName("...")
            .withUsername("...")
            .withPassword("...")
            .withReuse(true);

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);          // ✅ 런타임 결정값
        registry.add("spring.datasource.username", postgres::getUsername);    // ✅
        registry.add("spring.datasource.password", postgres::getPassword);    // ✅
        registry.add("spring.datasource.driver-class-name", () -> "org.postgresql.Driver");   // ❌ 상수
        registry.add("spring.jpa.hibernate.ddl-auto", () -> "create-drop");                   // ❌ 상수
        registry.add("spring.jpa.properties.hibernate.dialect", () -> "...PostgreSQLDialect");// ❌ 상수
        registry.add("spring.flyway.enabled", () -> "false");                                 // ❌ 상수
    }
}
```

앞의 셋은 컨테이너가 떠야 알 수 있는 값입니다. 뒤의 넷은 **상수예요.** 그리고 결정타가 있습니다. **같은 모듈의 `application-test.yml`에 그 값들이 이미 있는데, 값이 다릅니다.**

| 키 | `application-test.yml` | `@DynamicPropertySource` |
|---|---|---|
| `spring.datasource.driver-class-name` | H2 드라이버 | PostgreSQL 드라이버 |
| `spring.jpa.hibernate.ddl-auto` | `create-drop` | `create-drop` |
| `spring.flyway.enabled` | `false` | `false` |

**설정 파일은 H2를 말하고 베이스 클래스는 PostgreSQL을 말합니다.** 둘 중 하나는 죽은 코드고, 어느 쪽인지는 파일만 봐서는 알 수 없어요. 스킬 `:51`이 경고한 "하드코딩과 같은 문제가 재발한다"가 이겁니다.

같은 파일이 자매 모듈에도 하나 더 있습니다(쌍둥이).

> 💡 writer 메모: 이 표가 좋은 이유는 **한 줄만 다르다**는 점입니다. 나머지는 값이 우연히 같아서 아무 증상이 없어요. "값이 우연히 같으면 읽는 사람이 매번 다시 판단해야 한다"가 문제의 본질입니다.

### 6-3. `@DynamicPropertySource`의 실행 시점 제약에 정면으로 부딪힌 사례 [재구성]

스킬 `:52`가 말하는 "static 메서드는 컨텍스트 리프레시 전에 실행된다"에 실제로 걸린 자리가 있고, **회피 설계까지 기록돼 있습니다.**

사내 컨벤션 문서의 요지를 옮기면 이렇습니다.

> 스텁 서버는 컨텍스트 기동 전에 뜬다. 정확한 경로를 몰라도 되게 설계한다. `@DynamicPropertySource` static 메서드는 컨텍스트 리프레시 전에 실행되므로, 그 시점엔 아직 `@Autowired`로 실제 프로퍼티 값(URI 템플릿)을 읽을 수 없다. 정확한 경로를 미리 등록하는 대신, HTTP 메서드와 경로 접미사로 분기하는 catch-all 핸들러(`"/"` 하나만 등록) 하나면 충분하다. 경로 템플릿 치환 자체를 검증해야 하면, 컨텍스트가 뜬 뒤 `@Autowired`로 실제 템플릿을 읽어 기대값을 계산한다.

```java
// [재구성]
@DynamicPropertySource
static void partnerDomain(DynamicPropertyRegistry registry) {
    stub = HttpServer.create(new InetSocketAddress("localhost", 0), 0);
    stub.createContext("/", exchange -> {
        String method = exchange.getRequestMethod();
        String path = exchange.getRequestURI().getPath();
        if ("POST".equals(method) && path.endsWith("/accept")) { /* ... */ }
        else if ("POST".equals(method) && path.endsWith("/reject")) { /* ... */ }
        else { /* retrieve(GET) */ }
    });
    stub.start();
    registry.add("partner.domain", () -> "http://localhost:" + stub.getAddress().getPort());
}
```

**스킬이 제시한 두 가지 회피책(컨텍스트 기동 후 읽기, catch-all 설계)이 둘 다 실물로 있습니다.**

### 6-4. ★ 자기충족 단언. 1편의 항진명제가 Spring에서 나타나는 모양 [재구성]

**2편에서 1편으로 되돌아가는 가장 좋은 다리입니다.**

어제 날짜의 커밋 하나가 두 가지를 함께 고쳤습니다. 커밋 메시지와 컨벤션 문서에 이유가 남아 있어요(요지만 옮깁니다).

**(1) 테스트가 주입한 값을 그 테스트가 단언하던 구조**

> 개정 전에는 `spring.task.execution.thread-name-prefix=async-`를 테스트가 주입하고 `startsWith("async-")`를 단언했다. yml이 바뀌어도 영원히 초록불인 자기충족 구조였다.

교정은 주입을 지우고 `ConfigDataApplicationContextInitializer` + `@ActiveProfiles("test")`로 **실제 yml에서 읽게** 바꾸는 것이었습니다.

**(2) `@Autowired` 필드에 대한 `isNotNull()`**

같은 커밋이 다른 클래스에서 `isNotNull()` 단언 3건을 지웠습니다. 커밋 메시지의 이유가 정확합니다.

> `@Autowired` 주입이 실패하면 컨텍스트 로드 단계에서 이미 깨지므로 빨간불이 나는 경로가 없었다.

**1편의 매퍼 IT는 MyBatis가 빈 리스트를 반환해서 `isNotNull()`이 항진명제였습니다. 여기서는 Spring의 주입 실패가 테스트 메서드 실행 전에 터져서 항진명제입니다.** 원인은 다르고 형태는 같아요. 그리고 이건 **`@Autowired` 방식을 고른 순간 구조적으로 생기는 함정**입니다. Runner였다면 `hasNotFailed()`가 진짜 단언이 됩니다.

### 6-5. 오버라이드가 정당한 세 가지. 사내 문서가 스킬보다 하나 더 갖고 있다 [재구성]

공개 스킬 §3은 `@DynamicPropertySource`의 정당한 용도로 "런타임에만 정해지는 값"만 규정합니다. 사내 컨벤션 문서는 셋으로 나눠 놨어요(요지만 옮깁니다).

1. **런타임에만 정해지는 값**: Testcontainers JDBC URL, 스텁 서버 포트.
2. **git 밖에서 와야 하는 값**: 시크릿, yml 어디에도 실값이 없는 환경 의존값.
3. **검증 조건을 만드는 값**. 그리고 **왜 yml 값과 다른지 반드시 주석으로 남긴다.** 안 적으면 다음 사람이 리터럴 중복으로 보고 지운다.

3번의 실물이 §6-4의 그 클래스입니다.

```java
// [재구성]
@TestPropertySource(properties = {
        // 값이 아니라 검증 조건이다 — 아래 동시성 테스트가 30개 호출로 8개 스레드를 재사용하게 만들어야
        // MDC 데코레이터의 격리가 드러난다. yml 기본값(20)이면 스레드 재사용이 일어나지 않아
        // 그 테스트가 아무것도 검증하지 못한다. thread-name-prefix는 여기서 덮지 않는다.
        "spring.task.execution.pool.core-size=8",
        "spring.task.execution.pool.max-size=8",
        "spring.task.execution.pool.queue-capacity=50"
})
```

**같은 파일 안에서 한 프로퍼티는 지워졌고 다른 프로퍼티는 남았습니다. 기준은 "이 값이 검증을 만드는가, 검증을 대신하는가"였어요.**

⚠️ 캐시 관점의 부작용도 함께 짚을 수 있습니다. `@TestPropertySource(properties=...)`는 `propertySourceProperties`로 **키에 참여**합니다. 검증 조건 세 줄을 추가하는 순간 그 클래스는 자기 컨텍스트를 갖게 돼요. 정당한 비용이지만 공짜는 아닙니다.

---

### 6-6. ★★ `withReuse(true)`는 재사용하지 않는다 [재구성 + 공식 문서 확인]

**세 번째 "조용히 깨진 사례"이고, 이 편에서 유일하게 실측 시간이 붙는 근거입니다.**

#### 증상

어떤 모듈의 테스트가 **전체 실행 5회 중 3회가 서로 다른 테스트로 깨졌습니다.** 개별로 돌리면 통과해요. 원인 두 가지 중 하나가 이번 주제와 직결됩니다.

DB가 필요한 테스트 클래스마다 컨테이너를 각자 선언하고 있었습니다.

```java
// [재구성] 교정 전 — 클래스마다 이것을 각자 갖고 있었다
@Testcontainers
class SomeDbIntegrationTest {

    @Container
    static final OracleContainer ORACLE = new OracleContainer("...")
            .withReuse(true);   // ← 이게 공유해 줄 거라고 생각했다
}
```

**`withReuse(true)`가 붙어 있으니 컨테이너가 재사용될 것 같습니다. 그런데 아닙니다.**

#### 왜 배신하나 [공식 문서로 확인]

출처: [Testcontainers for Java: Reusable Containers](https://java.testcontainers.org/features/reuse/)

재사용이 실제로 켜지려면 **두 조건이 모두** 필요합니다.

1. 환경별 opt-in: 환경변수 `TESTCONTAINERS_REUSE_ENABLE=true` 또는 `~/.testcontainers.properties`에 `testcontainers.reuse.enable=true`
2. 컨테이너에 `withReuse(true)`

> ⚠️ **조건이 둘이 아니라 넷입니다. W-30에서 보강됐습니다.** 문서 원문은 "start the container manually by calling `start()` method, do not call `stop()` method directly or indirectly via `try-with-resources` or `JUnit integration`, and enable it manually through an opt-in mechanism per environment"입니다. 위 "교정 전" 코드는 `@Testcontainers` + `@Container`를 쓰므로 **환경 opt-in과 JUnit 통합 두 군데서** 조건을 어긴 셈이고, 교정 후 주석의 "`@Testcontainers`/`@Container`는 붙이지 않는다"가 공식 문서와 정확히 맞아떨어집니다. 발행본에 반영했습니다.

문서 원문은 "enable it manually through an **opt-in mechanism per environment**"라고 적고, 한 걸음 더 나가 **"Reusable containers are not suited for CI usage"**라고 못 박습니다.

즉 **`withReuse(true)`는 코드에 적혀 있지만, 그 옵션이 실제로 동작하는지는 코드 밖(개발자 각자의 홈 디렉터리 파일)에 달려 있습니다.** 그 파일을 켜 둔 사람의 머신에서는 잘 돌고, 새 체크아웃과 CI에서는 클래스 수만큼 컨테이너가 뜹니다.

#### 그래서 무슨 일이 일어났나 [재구성]

교정 커밋의 기록을 요지만 옮기면 이렇습니다.

> 켜지 않은 환경(CI, 새 체크아웃)에서는 클래스 수만큼 컨테이너가 뜨고, 무거운 이미지가 기본 대기 시간(60초) 안에 준비 로그를 못 뱉어 `ContainerLaunchException`으로 실패했다.

**실패가 "재사용이 안 됐다"로 나타나지 않습니다. "컨테이너 기동 타임아웃"으로 나타납니다.** 증상과 원인이 두 단계 떨어져 있어요. 게다가 켜 둔 머신에서는 재현되지 않습니다.

#### 교정과 실측 결과 [재구성]

싱글턴 컨테이너 하나로 묶고 JUnit 라이프사이클 애노테이션을 뗐습니다. 교정된 클래스의 주석이 판단 근거를 그대로 지고 있어요.

```java
// [재구성]
/**
 * Oracle 컨테이너를 JVM당 하나만 띄우는 싱글톤 컨테이너(Testcontainers 공식 권장 패턴).
 *
 * 도입 배경: 이전에는 DB가 필요한 테스트 클래스마다 @Container static OracleContainer를
 * 각자 선언했다. withReuse(true)가 붙어 있었지만 그 옵션은 개발자가 자기 머신의
 * ~/.testcontainers.properties에 testcontainers.reuse.enable=true를 직접 켜야 동작한다.
 *
 * 여기서는 static 초기화로 한 번만 시작하고 stop()을 호출하지 않는다 — 정리는
 * Testcontainers의 Ryuk 사이드카가 JVM 종료 후 맡는다.
 *
 * @Testcontainers/@Container는 붙이지 않는다 — 그 애노테이션이 컨테이너
 * 라이프사이클을 클래스 단위로 되돌려 싱글톤이 무의미해진다.
 */
public final class OracleTestContainer {

    /** 기본 대기 시간(60s)으로는 느린 머신에서 기동 로그를 놓친다 — 여유를 명시적으로 준다. */
    private static final Duration STARTUP_TIMEOUT = Duration.ofMinutes(5);
    ...
}
```

**교정 커밋이 남긴 실측 수치는 이렇습니다**(요지만 옮깁니다).

> 검증: 전체 테스트 5회 연속 통과. 부수 효과로 **전체 실행 시간이 로컬 기준 1분 20초대에서 27초대로 줄었다 — 컨테이너 기동이 3회에서 1회가 됐다.**

⚠️ **이 수치를 컨텍스트 캐시의 효과로 쓰면 안 됩니다.** 줄어든 것은 **Testcontainers 컨테이너 기동 횟수**(3회 → 1회)이지 Spring 컨텍스트 로드 횟수가 아닙니다. 다만 **구조는 같습니다.** 클래스마다 선언하던 무거운 자원을 한 군데로 모은 것이고, 그 "한 군데"가 §1의 베이스 클래스와 같은 자리예요.

#### ★ 여기서 나오는 결론

**애노테이션이 약속하는 것과 런타임이 하는 일은 다를 수 있습니다.**

- `withReuse(true)`는 "재사용한다"고 읽히지만, 실제 동작은 코드 밖 설정 파일에 달려 있습니다.
- `@ActiveProfiles({"a","b"})`는 "이 프로파일들을 켠다"로 읽히지만, **적은 순서가 캐시 키를 가릅니다**(§2-3).
- `@Async("이름")`은 "이 executor를 쓴다"로 읽히지만, 못 찾으면 **경고만 남기고 기본 executor로 폴백**합니다(§5-4).
- `@ContextConfiguration(classes = {A, B})`는 "이 둘을 등록한다"로 읽히지만, **자동설정 순서 보장을 잃습니다**(§5-3).

넷 다 **선언은 맞고 런타임이 다른** 경우이고, 넷 다 **예외가 나지 않습니다.**

> 💡 writer 메모: **§5-3, §5-4, §6-6 세 사례를 한 자리에 모으면 2편의 중심이 됩니다.** 그리고 이 목록이 1편의 주제 질문("무엇이 바뀌면 이게 실패해야 하는가")에 답할 수 없는 종류의 결함이라는 점을 짚으면 두 편이 이어져요. 단언이 아무리 좋아도 이건 못 잡습니다. **테스트가 아니라 테스트를 띄우는 방식의 문제**니까요.
>
> ⚠️ Testcontainers 사용법 설명으로 새지 마세요. 요점은 컨테이너가 아니라 "선언과 런타임의 간극"입니다.

## 7. 스킬이 두 벌이라는 사실

이건 3편으로 가는 다리라 **2편에서는 사실 확인까지만** 쓰고 논지를 펼치지 마세요.

- 모듈 E에는 **프로젝트 로컬 스킬**이 있습니다. `.claude/skills/` 아래에 있고, Runner vs Autowired 세 기준, 컨텍스트 스코프(스모크/E2E), 프로퍼티 값 관리를 다룹니다. **공개 `sr-harness` 스킬과 구조가 거의 같아요.**
- 그런데 **내용의 밀도가 다릅니다.** 사내 로컬 스킬에는 날짜가 박혀 있습니다("2026-08-09 실측", "2026-08-10 확정"). 각 기준마다 그 기준을 만든 **실제 클래스와 줄번호**가 붙어 있고, §5-3의 `null` 사건 같은 **실측 결과**가 적혀 있습니다.
- 공개 스킬은 그 전부를 걷어내고 세 신호만 남겼습니다. 그래서 다른 프로젝트에 붙일 수 있게 됐고, 동시에 **"왜 이 규칙이 생겼는지"를 잃었습니다.**
- **시간 순서**: 사내 로컬 스킬이 2026-08-09에 생겼고, 공개 하네스의 `dev-testing-strategy` 스킬은 **그 다음 날인 2026-08-10에 추가**됐습니다. 공개 쪽은 검증 가능합니다. [SeokRae/sr-harness](https://github.com/SeokRae/sr-harness) 커밋 `b6e270e`, "feat: dev-testing-strategy 스킬 추가 + v0.23.0 (#107)", 2026-08-10 13:45 +0900.
- 사내 로컬 스킬은 그 뒤로도 계속 갱신됩니다(2026-08-10, 2026-08-11). §6-4의 교정 커밋은 **코드와 스킬 문서를 같은 PR에서 함께 고쳤고**, 커밋 메시지에 이유가 적혀 있습니다. "코드만 고치면 다음에 같은 판단을 처음부터 다시 하게 되므로, 이번에 확정한 규약을 스킬 문서에 남긴다."

> 💡 writer 메모: **2편에서는 "규칙이 프로젝트에서 태어나 하네스로 올라갔다"는 사실 관찰까지만.** 3편이 "그래서 그 규칙을 에이전트가 어떻게 쓰는가"를 다룹니다. 2편에서 위임 이야기로 넘어가면 3편을 선점합니다.
>
> 다만 2편 마무리에 한 줄 연결은 좋습니다. 1편이 "기준은 있었는데 안 지켜졌다"였고, 2편은 "그 기준이 실측에서 나왔다"이며, 3편이 "그 기준을 누가 지키게 하는가"입니다.

---

## 8. 검증 기록

writer가 확정 인용하기 전에 검증한 항목입니다. 이 절은 **근거 사슬**이므로 지우지 마세요.

| ID | 검증 대상 | 방법 | 결과 |
|---|---|---|---|
| **W-1** | 컨텍스트 캐시 키의 구성 요소 | Spring 공식 문서(Context Caching) 확보 + 로컬 Gradle 캐시의 `spring-test` sources jar 3종(5.3.31 / 6.1.11 / 6.2.9) 압축 해제 후 `MergedContextConfiguration.equals`/`hashCode` 원문 대조 | **확정.** 문서의 10개 항목과 소스의 9개 필드가 일치(문서의 `resourceBasePath`는 `MergedContextConfiguration`의 하위 타입 `WebMergedContextConfiguration` 소관). **5.3.31 → 6.2.9 사이에 키 구조 변화 없음.** `propertySourceLocations` → `propertySourceDescriptors` 개명만 있음 |
| **W-2** | `spring.test.context.cache.maxSize` 기본값 | `ContextCache.java` 원문 + 공식 문서 | **확정. 32.** 5.3.31과 6.1.11 모두 `int DEFAULT_MAX_CONTEXT_CACHE_SIZE = 32;`. 문서도 "a default maximum size of 32" |
| **W-3** | 상한 초과 시 LRU 축출 여부 | `DefaultContextCache.java` 원문 | **확정.** `private class LruCache extends LinkedHashMap<...>` + `removeEldestEntry` 오버라이드. 생성 시 `new LruCache(32, 0.75f)`. 문서도 "least recently used (LRU) eviction policy is used to evict and close stale contexts" |
| **W-4** | 캐시가 JVM(프로세스) 범위인가 | `DefaultCacheAwareContextLoaderDelegate.java:69-71` + 공식 문서 | **확정.** `static final ContextCache defaultContextCache`. 문서: "if tests run in separate processes, the static cache is cleared between each test execution, which effectively disables the caching mechanism" / "To benefit from the caching mechanism, all tests must run within the same process or test suite." → **§3-2의 "426건은 한 덩어리가 아니다"의 근거** |
| **W-5** | `@ActiveProfiles`가 정렬되는가 | `MergedContextConfiguration.processActiveProfiles` 원문 (5.3.31 / 6.1.11 / 6.2.9) | **부정. 정렬하지 않는다.** `new LinkedHashSet<>(Arrays.asList(activeProfiles))`가 중복만 제거하고 삽입 순서 유지. 키는 `Arrays.hashCode`라 순서를 본다. **집합이 같아도 순서가 다르면 다른 컨텍스트** |
| **W-6** | `@DynamicPropertySource`가 값으로 키에 참여하는가 | `DynamicPropertiesContextCustomizer` 원문 (6.1.11 / 6.2.9) | **부정. `Set<Method>`가 키다.** `equals`/`hashCode` 모두 `this.methods` 기준. 등록하는 값은 키에 안 들어간다. → 베이스 클래스에 두면 하위 전부가 컨텍스트 공유 |
| **W-7** | `@MockBean`이 캐시를 어떻게 깨뜨리는가 | `spring-boot-test` 2.7.18 `MockitoContextCustomizer` 원문 | **확정. `Set<Definition>` 기준.** 순서 무관, 집합이 다르면 컨텍스트가 갈린다. 실행 로그에서 빈 집합일 때 `MockitoContextCustomizer@0`(hashCode 0)임을 확인 |
| **W-8** | 사내 저장소의 Spring Boot 버전 | 각 모듈 `build.gradle` / `gradle/libs.versions.toml` 확인 + 실행 로그 | **모듈마다 다르다.** 2.7.8, 2.7.17, 2.7.18, 3.1.x, 3.2.x, 3.3.0, 3.4.13, 3.5.4가 공존. 실측 대상 모듈은 로그에서 "Running with Spring Boot v3.5.4, Spring v6.2.9"로 확인. **본문에서 "우리 저장소의 Spring Boot 버전은 X"라고 단수로 쓰면 사실 오류** |
| **W-9** | `@MockitoBean` 도입 여부 | 저장소 전수 grep | `@MockBean` 259건, `@MockitoBean` **1건**. 유일한 `@MockitoBean`은 Boot 3.4.x 모듈의 **베이스 클래스**에 있다. 나머지는 전부 `@MockBean`. **"이 조직은 `@MockitoBean`으로 옮겼다"고 쓰면 안 된다** |
| **W-10** | 컨텍스트 키 정적 집계 | 파서를 새로 작성해 892개 구체 클래스의 상속 체인 + 애노테이션을 튜플로 집계 | 892클래스 → 213키(40개 Gradle 프로젝트에 분산). ⚠️ **하한값이다.** contextCustomizerFactory가 실제로 만드는 커스터마이저 목록을 반영하지 못하므로 실제 개수는 이보다 크거나 같다 |
| **W-11** | 프로파일 순서 파편화가 실재하는가 | 집계 결과에서 "집합은 같고 순서만 다른" 쌍을 뽑은 뒤 **해당 파일을 직접 열어 주석 처리 여부까지 확인** | **실재. 2쌍.** 둘 다 같은 모듈, 같은 베이스 상속, 주석 아님. 추가로 프로파일 목록 안에서 항목 하나만 주석 처리한 사례 1건 |
| **W-12** | 베이스 클래스가 컨텍스트를 모으는가 | 집계 결과를 상속 체인별로 재분류 | **확정.** 베이스 있는 모듈: 15클래스→1키, 31클래스→2키, 12클래스→1키. 베이스 없는 모듈: 12→12, 12→11, 9→9, 4→4 |
| **W-13** | 컨텍스트 로드 횟수 실측 | 실측 대상 모듈을 `./gradlew test`로 실제 실행. `org.springframework.test.context.cache` 로거 DEBUG. 저장소 무수정(Gradle init script로 주입) | **성공.** 부분 실행(24클래스): `size=10, maxSize=32, hitCount=914, missCount=10, failureCount=0`, BUILD SUCCESSFUL. ⚠️ **전체 모듈 실행은 이 환경에서 17건 실패**(오프라인 의존성 부족 등). 같은 클래스가 부분 실행에선 통과했으므로 **저장소가 원래 깨졌다고 쓰면 안 된다** |
| **W-14** | 캐시 로거가 중간에 꺼지는 현상 | 1차 측정에서 통계가 114줄만 찍히고 멈춘 원인 추적 | **원인 확정.** 첫 `@SpringBootTest`가 뜨면 Spring Boot `LogbackLoggingSystem`이 클래스패스 `logback-test.xml`로 재초기화해 외부 logback 설정을 덮어쓴다. `logging.level.*`를 시스템 프로퍼티로 함께 주면 해결. **재현하는 사람이 반드시 알아야 할 함정** |
| **W-15** | `ApplicationContextRunner`가 캐시를 쓰는가 | `spring-boot-test` 3.2.8 `AbstractApplicationContextRunner` 원문 | **부정. 캐시 미참여.** javadoc `:79` "Upon completion, the context is automatically closed.", `:362` `try (A context = createAssertableContext(refresh))`. `run()` 호출마다 생성하고 폐기 |
| **W-16** | Runner/`@ContextConfiguration`이 yml을 안 읽는다는 사내 서술 | `spring-boot-test` 3.2.8 `ConfigDataApplicationContextInitializer` javadoc 원문 | **뒷받침됨.** "can be used with the `ContextConfiguration#initializers()` to trigger loading of `ConfigData` such as `application.properties`" |
| **W-17** | L3/L5 베이스 분리가 캐시 분리 의도인가 (1편 노트 §5의 미확인 항목) | 두 베이스 파일과 각 모듈의 `settings.gradle` 확인 | **부정.** 서로 다른 Gradle 프로젝트의 서로 다른 애플리케이션이라 같은 JVM에서 만나지 않는다. 실제 사유는 데이터소스 구조 차이(단일 vs master/slave 라우팅)이며 베이스 주석에 적혀 있다 |
| **W-18** | `@MybatisTest` 하이브리드 16건이 컨텍스트를 공유하는가 | 16개 파일의 애노테이션 4줄을 전수 대조 + 집계 결과 확인 | **공유한다.** 16개 파일이 4줄을 글자까지 동일하게 갖는다. 집계에서도 키 1개 |
| **W-19** | `@DynamicPropertySource` 오용 사례 | 저장소의 모든 `registry.add(...)` 호출을 훑어 런타임 결정값인지 상수인지 분류 | **1개 모듈(쌍둥이 2파일)에서 발견.** 상수 4건(driver-class-name, ddl-auto, dialect, flyway.enabled). 같은 모듈 `application-test.yml`에 driver-class-name이 **다른 값**으로 존재 → 두 소스가 모순 |
| **W-20** | 자기충족 단언 교정 사례 | 해당 커밋의 diff와 커밋 메시지 확인 | **확인.** 주입한 값을 스스로 단언하던 프로퍼티 1건 제거, `@Autowired` 필드에 대한 `isNotNull()` 3건 제거. 커밋 메시지에 이유 기록 |
| **W-21** | 사내 로컬 스킬과 공개 스킬의 선후 | 사내 저장소 git log(스킬 파일 경로) + `sr-harness` 저장소 git log | **사내 로컬이 하루 먼저.** 사내 2026-08-09 신설, 공개 `sr-harness` 커밋 `b6e270e` 2026-08-10 13:45 +0900. **공개 쪽만 본문에 커밋 해시와 함께 인용 가능** |
| **W-22** | 익명화 | 이 노트 전수 스캔(회사명, PG사, 파트너사, 도메인, IP, 패키지, 모듈 실명, 클래스 실명, 테이블명, 사내 이슈 번호) | **누출 없음.** 모듈은 A~K 라벨, 클래스는 중립 이름으로 치환. `[재구성]` 블록 어디에도 경로와 줄번호 없음. 외부 URL은 Spring 공식 문서와 필자 본인 GitHub뿐. 사내 색인 파일이 무시되는 것을 `git check-ignore`로 재확인 |

| **W-23** | 스킬 `:34`의 "신호 1만 기계적으로 확인하지 말라" 경고에 실제 원인이 있는가 | 사내 저장소의 커밋 이력을 날짜순으로 훑고, 컨벤션 스킬 파일의 **최초 버전과 개정판을 직접 대조** | **실재. 사후 기록이다.** 최초 버전(2026-08-09)은 "기준은 하나"로 시작하고, 같은 절 아래에 `AutoConfigurations.of(...)` 예외가 "주의 (2026-08-09 실측)"로 달려 있다. 하루 뒤 개정에서 그 주의가 **기준 2로 승격**되고 **기준 3이 추가**되며 경고 문장이 머리말에 붙었다. 같은 날 Runner 제거 커밋 본문도 "`BeanPostProcessor` 기반 배선과는 다른 케이스"로 깨진 쪽을 대조한다 |
| **W-24** | `withReuse(true)`만으로 컨테이너가 재사용되는가 | 사내 교정 커밋의 주장을 **Testcontainers 공식 문서로 독립 확인** | **부정. 두 조건이 모두 필요하다.** 환경변수 `TESTCONTAINERS_REUSE_ENABLE=true` 또는 `~/.testcontainers.properties`의 `testcontainers.reuse.enable=true` **그리고** `withReuse(true)`. 문서 원문 "enable it manually through an opt-in mechanism per environment", 그리고 "Reusable containers are not suited for CI usage". 사내 커밋의 서술이 정확하다 |
| **W-25** | 컨테이너 통합의 실행 시간 효과 | 사내 교정 커밋이 남긴 실측 기록 확인 | **커밋에 기록됨.** 전체 실행 5회 중 3회 실패 → 5회 연속 통과, 전체 실행 시간 1분 20초대 → 27초대, 컨테이너 기동 3회 → 1회. ⚠️ **이건 Testcontainers 컨테이너 기동 수치이지 Spring 컨텍스트 캐시 수치가 아니다.** 본문에서 섞으면 사실 오류. 그리고 필자가 직접 5회 재현한 것이 아니라 **커밋 기록을 인용하는 것** |
| **W-26** | "컨텍스트를 아예 안 띄우는 전환"이 실재하는가 | Runner 제거 커밋의 diff와 본문 확인 | **실재.** properties 검증 테스트 5개 파일에서 Spring 컨텍스트를 완전히 제거하고 `new XxxProperties(...)` 생성자 직접 호출로 전환. 동시에 relaxed binding 검증 책임을 실제 yml을 로드하는 테스트 하나로 모으고 커버리지 공백을 메움. 테스트명도 "…기동에_실패한다" → "…예외를_던진다"로 교정 |
| **W-27** | 실측 모듈의 전체 실행 실패가 저장소 문제인가 | 사내 커밋 이력에서 동일 증상("전체 실행에서 간헐 실패")의 교정 커밋을 확인하고, 그 커밋이 내 체크아웃에 포함돼 있는지 대조 | **내 환경 문제로 판단.** 저장소는 2026-08-11에 간헐 실패를 이미 교정했고 그 커밋이 체크아웃에 포함돼 있다. 내가 본 실패는 성격이 다르다(오프라인 의존성 부족으로 인한 `ClassNotFoundException`). **다만 "저장소가 원래 깨져 있다"고도 "완전히 안정적이다"라고도 단정하지 말 것** |

### 8-1. 초안 검증에서 추가된 항목 (verifier, 2026-08-11)

| ID | 검증 대상 | 방법 | 결과 |
|---|---|---|---|
| **W-28** | `@Async("이름")`이 executor를 못 찾으면 "경고만 남기고 기본 executor로 폴백"하는가 (§5-4 재구성 javadoc의 서술) | `spring-aop` 5.3.31 / 6.2.9의 `AsyncExecutionAspectSupport`와 `spring-beans` 6.2.9의 `BeanFactoryAnnotationUtils` sources jar 원문 대조 | **부정. 초안이 틀렸고 교정했다.** 이름을 준 `@Async`는 `determineAsyncExecutor` → `findQualifiedExecutor` → `qualifiedBeanOfType(beanFactory, Executor.class, qualifier)`로 가고, 일치하는 빈이 없으면 `NoSuchBeanDefinitionException`을 **던진다**(`BeanFactoryAnnotationUtils.java:137-138`). 폴백은 없다. 로그를 남기고 `SimpleAsyncTaskExecutor`로 폴백하는 것은 **이름을 주지 않은** `@Async`의 경로다(`AsyncExecutionAspectSupport.java:238` 이하 + `AsyncExecutionInterceptor.java:158-161`). `findQualifiedExecutor`는 5.3.31과 6.2.9가 같은 코드. **다만 예외 시점은 컨텍스트 기동이 아니라 그 메서드 호출 시점**이므로 "컨텍스트는 초록불로 뜬다"는 논지는 살아 있다. 본문은 진짜 무음 케이스(두 이름이 같은 인스턴스로 해석)로 옮겨 적고 각주 `[^async]`를 달았다 |
| **W-29** | `@SpringBootTest`의 `properties`가 `SpringBootTestAnnotation` 커스터마이저로 들어가는가 (§4-3 판독) | `spring-boot-test` 3.5.4의 `SpringBootTestAnnotation`과 `SpringBootTestContextBootstrapper` 원문 대조 | **부정. 초안이 틀렸고 교정했다.** `SpringBootTestAnnotation`의 필드는 `args`, `webEnvironment`, `useMainMethod` 셋뿐이고 `equals`/`hashCode`도 이 셋만 본다. `properties`는 `SpringBootTestContextBootstrapper.processPropertySourceProperties`가 `propertySourceProperties` 앞쪽에 넣는다. 같은 메서드가 `webEnvironment`도 프로퍼티로 번역해 `RANDOM_PORT`면 `server.port=0`, `NONE`이면 `spring.main.web-application-type=none`을 덧붙인다. **§4-3 덤프에 그 줄이 있는 이유가 이것**이라 교정이 오히려 덤프 판독을 완성시킨다. 각주 `[^sbta]` 추가 |
| **W-30** | Testcontainers 재사용의 필요 조건이 "두 개"인가 (§6-6 서술) | 공식 문서 [Reusable Containers](https://java.testcontainers.org/features/reuse/) 원문 재확인 | **불완전했고 보강했다.** 문서 한 문장이 조건을 모아 둔다. "To use it, start the container manually by calling `start()` method, do not call `stop()` method directly or indirectly via `try-with-resources` or `JUnit integration`, and enable it manually through an opt-in mechanism per environment." 즉 `withReuse(true)` + 환경 opt-in 외에 **수동 `start()`와 JUnit 통합 미사용**이 함께 필요하다. 노트 §6-6의 "교정 전" 코드는 `@Testcontainers` + `@Container`를 쓰므로 **환경 opt-in과 JUnit 통합 두 군데서** 조건을 어긴 것이고, 교정 후 주석의 "`@Testcontainers`/`@Container`는 붙이지 않는다"가 공식 문서와 정확히 일치한다. 본문에 이 대목을 반영했다 |
| **W-31** | 공개 `sr-harness` 스킬 인용의 줄번호와 문자 일치 | `~/.claude/plugins/cache/sr-harness/sr-harness/0.23.0/skills/dev-testing-strategy/SKILL.md`(70줄) 전문과 본문 각주 `[^skill]`을 문자 단위 대조 | **전부 일치.** `:19`, `:21`, `:22`, `:23`, `:34` 모두 줄번호와 인용문이 원문과 정확히 같다. 본문은 `:8`과 `:26-31`은 인용하지 않았다 |
| **W-32** | 공개 `sr-harness` 커밋 `b6e270e`의 날짜 | `gh api repos/SeokRae/sr-harness/commits/b6e270e` | **확정.** `b6e270ea4798c14815a1a32e17c873c42161ce00`, `2026-08-10T04:45:01Z` = **2026-08-10 13:45 +0900**, "feat: dev-testing-strategy 스킬 추가 + v0.23.0 (#107)". 각주 `[^skill]`의 서술과 일치 |
| **W-33** | Spring 공식 문서 인용(캐시 키 10항목, `maxSize` 32, static 캐시) | [Context Caching](https://docs.spring.io/spring-framework/reference/testing/testcontext-framework/ctx-management/caching.html) 원문 재확보 후 각주 `[^caching]`과 본문 인용문을 문자 단위 대조 | **전부 일치.** 10개 항목의 `(from @...)` 표기와 `contextCustomizers` 설명문, `maxSize` 문단, static 캐시 문단, "To benefit from the caching mechanism, all tests must run within the same process or test suite."까지 원문 그대로 |
| **W-34** | Spring 소스 인용의 줄번호와 문자 일치 | 로컬 Gradle 캐시 sources jar를 풀어 본문 코드블록과 각주 `[^mcc]`를 대조 | **전부 일치.** `MergedContextConfiguration.hashCode`는 6.1.11 기준 **정확히 537-548행**. `processActiveProfiles`는 5.3.31 / 6.1.11 / 6.2.9가 같은 코드. 5.3.31 `hashCode`는 `propertySourceDescriptors` 자리만 `Arrays.hashCode(this.propertySourceLocations)`. `ContextCache.java:66,79`, `DefaultContextCache.java:307,320`, `DefaultCacheAwareContextLoaderDelegate.java:68-71` 모두 각주가 말한 줄에 있다. `resourceBasePath`는 `MergedContextConfiguration`에 **0건**이고 `WebMergedContextConfiguration:64`에 있다(각주의 설명과 일치). `DynamicPropertiesContextCustomizer`(6.2.9 :53, :91-99)와 `MockitoContextCustomizer`(2.7.18 :34, :49-62)도 원문 일치 |
| **W-35** | 1편 링크 경로가 유효한가 | `_config.yml`(`baseurl: "/blog"`) + 빌드 산출물 `_site/2026/08/11/test-standards-1-what-to-test.html` 확인 | **유효.** 본문의 `/blog/2026/08/11/test-standards-1-what-to-test.html`이 맞다 |
| **W-36** | 본문이 되짚는 1편 수치가 발행본과 맞는가 | 발행된 `_posts/2026-08-11-test-standards-1-what-to-test.md` 대조 | **일치.** "260곳 남짓"은 1편 본문 2곳에 그대로 있고, "3.4%"도 1편이 발행한 값이다(1편 각주가 모수 재집계 시 3.0%로 움직인다는 단서를 이미 달아 뒀다). 두 수치 모두 본문에서 **한 문장짜리 역참조**로만 쓰였다. 3편 소재인 이름 통계(한글 50.0% vs 44.0%)와 1편 §1-5의 95%/73%는 **본문에 없음**(전수 grep 확인) |
| **W-37** | 익명화 재확인 (초안 전수) | 초안 전문을 회사와 PG사와 파트너사 실명, 사내 패키지 접두사, 도메인, IP, 사내 이슈 번호, 커밋 해시 패턴으로 전수 grep (검색에 쓴 사내 문자열 자체는 이 노트가 공개 커밋되므로 여기 적지 않는다) | **누출 없음.** 16진 문자열은 전부 실행 로그의 JVM identity hashCode(`@3751acd7` 등)이고, 유일한 커밋 해시는 공개 저장소의 `b6e270e`다. 외부 URL은 Spring 공식 문서, Testcontainers 공식 문서, 필자 본인 GitHub뿐. `[재구성]` 블록에 경로와 줄번호 없음. 사내 색인 파일(`*.sources-internal.md`)의 내용은 본문과 노트 어디에도 옮기지 않았다 |

### 8-2. 외부 검토 후 교정 (2026-08-11, 오케스트레이터)

발행 직전에 다른 모델(Fable)에게 비평을 받고, 지적을 하나씩 근거와 대조해 반영했습니다. 지적 중 하나(377줄 "가립니다" 오탈자)는 **오탐이었습니다.** 본문은 처음부터 "가릅니다"였고 파일 전체에 "가립니다"는 0건입니다. 이 저장소에는 외부 검토가 근거 없이 판정해 문제를 놓친 전례가 있어(`CLAUDE.md` #26) 전 항목을 대조했습니다.

| ID | 검증 대상 | 방법 | 결과 |
|---|---|---|---|
| **W-38** | "프로파일 순서가 달라도 애플리케이션 동작은 완전히 같다"가 참인가 | Spring Boot Reference "Externalized Configuration"의 Profile Specific Files 절 원문 확인 | **부정. 본문이 틀렸고 교정했다.** "If several profiles are specified, a **last-wins strategy** applies. For example, if profiles `prod,live` are specified by the `spring.profiles.active` property, values in `application-prod.properties` can be overridden by those in `application-live.properties`." 프로파일 목록의 순서는 프로퍼티 우선순위를 결정하므로, 두 프로파일이 같은 키를 다르게 정의하면 순서가 유효값을 바꾼다. **논지는 오히려 깊어졌다** — Spring이 순서를 키에 넣는 것은 변덕이 아니라 순서가 의미를 가질 수 있기 때문이고, 문제는 의미를 갖는 자리에서 의미 없이 섞어 쓴 우리 쪽에 있다. 각주 `[^lastwins]` 추가. 사내 두 쌍에 대한 "동작도 같다"도 근거가 없어(겹치는 키 유무 미확인) "순서가 의도된 것이었다면 두 표기가 섞여 있을 이유가 없다"는 서술로 바꿨다 |
| **W-39** | `@DynamicPropertySource`와 yml이 충돌할 때 "어느 쪽이 죽은 코드인지 알 수 없다"가 참인가 | Spring Framework Reference "Dynamic Property Sources" 원문 확인 | **부정. 본문이 틀렸고 교정했다.** "Dynamic properties have higher precedence than those loaded from `@TestPropertySource`, the operating system's environment, Java system properties, or property sources added by the application declaratively by using `@PropertySource` or programmatically." 승자는 정해져 있다. 알 수 없는 것은 **어느 쪽이 의도였는가**다. 각주 `[^dynprec]` 추가 |
| **W-40** | "`doesNotHaveBean`/`isNotSameAs`/`hasNotFailed`는 `@Autowired`로 표현할 방법이 없다"가 참인가 | 반례 검토 | **과했고 좁혔다.** `ApplicationContext`를 통째로 주입받아 `containsBean`을 물으면 빈의 존재와 부재는 확인 가능하다. 진짜 불가능한 것은 **기동 실패가 기대 결과인 케이스** 하나다(셋업 단계에서 예외). 본문 3곳(도입, 배움 둘째, 체크리스트)을 "필드 주입만으로는"으로 좁혔다. ⚠️ 스킬 원문 `:23`은 "`@Autowired`로 표현할 방법이 없다"라고 적혀 있으나 **그건 인용이므로 그대로 두고 본문 자기 목소리만 고쳤다** |
| **W-41** | "넷 다 단언을 아무리 잘 써도 못 잡는다"가 본문 자신과 맞는가 | 본문 내부 대조 | **모순이었고 갈라 적었다.** 본문은 Hikari `null`이 "하필 이 테스트가 그 값을 단언하고 있었기 때문에" 드러났다고 쓰고(57줄), `@Async` 별칭은 "위 테스트의 `isNotSameAs`가 잡는 것이 정확히 이 경우"라고 쓴다. 즉 넷 중 둘은 **구성 자체를 단언하는 테스트가 있으면** 잡힌다. 어떤 단언으로도 못 잡는 것은 프로파일 순서(증상이 비용뿐)와 `withReuse`(증상이 인프라 타임아웃) 둘이다 |
| **W-42** | 「규칙이 어디서 왔는가」 절이 3편 재료를 선점하는가 | 이 노트 §10 대조 | **선점 확인. 절을 통째로 삭제했다.** §10이 "규칙과 코드를 같은 PR에서 고친 사례"와 커밋 메시지 인용을 명시적으로 3편용으로 묶어 뒀는데 본문이 그 인용을 그대로 썼다. 이 절의 내용은 96줄, 배움 첫째, 마무리와도 겹쳐 삭제해도 잃는 것이 적다 |
| **W-43** | "밟은 사람과 문장을 적은 사람이 같다" | 근거 확인 시도 | **근거 없어 제거했다.** 이 노트의 검증 기록은 날짜, 기준 개수 변화, 판본 문장까지만 확정했고 커밋 저자 동일성은 확인하지 않았다. 사내 저장소는 이 세션에서 git 저장소로 접근되지 않아 확인도 불가능했다. "밟은 자리와 문장이 적힌 자리 사이의 거리가 하루였다"로 바꿨다 |
| **W-44** | 377줄 "가장 적게 가립니다" 오탈자 지적 | 본문 grep | **오탐. 반영하지 않았다.** 본문은 "가장 적게 **가릅니다**"이고 "가립니다"는 파일 전체에 0건이다 |

그 외 반영: 합산 비율(39→26, 754→118)이 40개 JVM 합산이라 캐시 관점에서 의미가 없다는 단서 추가, 가설 인용 앞에 스코프 원칙의 출처 소개 추가, 주석 처리 사례가 순서 쌍과 종류가 다르다는 구분 추가("집합 자체가 달라졌으니 동작에도 영향"), "저장소에서 가장 잘 만들어진 축" → "교과서적으로 짜여 있습니다"(수치상 재사용 비가 더 높은 모듈이 따로 있음), "앞 절의 셋" → "앞에서 소스로 읽었던 키의 구성요소들"(실제로는 다섯 절 전이고 덤프에 보이는 것은 필드다).

분량은 631줄에서 619줄로 줄였습니다. 사실 교정으로 약 15줄이 늘고 덜어내기로 27줄을 줄인 결과입니다. 덜어낸 곳은 「규칙이 어디서 왔는가」 절 전체, 계약 테스트 베이스 코드 블록(javadoc 핵심 문장과 선언부만 남김), Runner 예제 코드 블록(클래스 선언과 중복 설정 생략)입니다.

### 확인하지 못한 것

- **모듈 D의 LRU 축출을 실제로 관측하지 못했습니다.** 정적 집계로 34가지 조합이 나왔고 기본 상한이 32라는 것까지만 확정입니다. 그 모듈을 실행하지는 못했어요. **본문에서 "실제로 축출이 일어났다"고 단정하지 마세요.** "축출이 일어날 조건에 있다"가 정확합니다.
- **컨텍스트 로드에 걸리는 시간을 측정하지 않았습니다.** 실행 로그에 개별 컨텍스트의 `Started ... in 0.027 seconds` 같은 줄이 있지만, 그건 작은 `classes=` 컨텍스트라 대표값이 아닙니다. **"캐시 미스 하나가 몇 초"라는 수치를 쓰지 마세요.** 컨텍스트 캐시로 인한 전체 시간 단축량도 측정하지 않았습니다.
  - ⚠️ §6-6의 "1분 20초대 → 27초대"는 **Testcontainers 컨테이너 기동 통합**의 효과이고, 필자가 잰 것이 아니라 **사내 교정 커밋에 기록된 값을 인용**한 것입니다. 컨텍스트 캐시의 효과로 옮겨 쓰면 사실 오류입니다(W-25).
- **§5-0의 이력은 커밋 메시지와 스킬 파일의 판본 대조로 복원한 것입니다.** 그 당시 어떤 판단이 오갔는지는 커밋에 남은 만큼만 압니다. **"이때 이런 논의가 있었다"고 추측해 서술하지 마세요.** 확정된 것은 날짜, 기준의 개수 변화, 그리고 각 판본에 실제로 적힌 문장뿐입니다.
- **`getMetricsTrackerFactory()`가 `null`이 되는 현상을 직접 재현하지 않았습니다.** 사내 문서의 "2026-08-09 실측" 기록과, 같은 날 커밋 본문의 대조 서술이 근거입니다. 메커니즘(자동설정 간 `@AutoConfigureAfter` 순서 보장 vs `@ContextConfiguration(classes=...)`의 선언 순서 처리)은 공개 스킬과 사내 문서가 같게 서술하지만, **필자가 직접 깨뜨려 본 것은 아닙니다.**
- **실측한 모듈은 하나뿐입니다.** 나머지 39개 Gradle 프로젝트는 정적 분석뿐이에요. 특히 재사용 비 25.9로 가장 좋았던 모듈 C는 실행하지 않았습니다.
- **정적 집계는 하한입니다.** `contextCustomizerFactory`가 실제로 붙이는 커스터마이저(실측 로그에서 12개 확인)를 파서가 재현하지 못하므로, 실제 컨텍스트 수는 213보다 클 수 있습니다. **"213개다"라고 단정하지 말고 "정적으로 세면 최소 213가지"로 쓰세요.**
- **전체 모듈 실행의 17건 실패 원인을 완전히 규명하지 못했습니다.** 오프라인 의존성 부족으로 보이지만 단정하지 못합니다. 부분 실행에서는 같은 클래스가 통과했다는 사실만 확정입니다.
- **`forkEvery` / `maxParallelForks` 설정을 저장소 전체에서 조사하지 않았습니다.** 실측 모듈에는 없어서 단일 JVM이었고 캐시 인스턴스도 하나였습니다(로그의 `DefaultContextCache@...` 해시가 하나). 다른 모듈이 포크를 나눠 쓴다면 캐시가 더 잘게 쪼개집니다. **"모듈당 캐시 하나"라고 일반화하지 마세요.**
- **`@AutoConfigure*` 애노테이션이 만드는 property source의 세부값을 추적하지 않았습니다.** 파서는 애노테이션 존재 여부만 봤습니다.

---

## 9. 글의 뼈대 제안 (writer가 취사선택)

한 문장 주제: **좁힘과 공유는 대립하지 않는다. 둘 다 "설정을 어디에 적는가"의 문제다. 그리고 이 판단이 어려운 이유는 애노테이션이 약속하는 것과 런타임이 하는 일이 다르기 때문이다.**

**규칙: 각 항목에 "독자가 여기서 무엇을 배우는가"가 한 줄로 붙습니다. 한 줄이 안 나오는 항목은 뼈대에서 뺐습니다.**

| # | 내용 | **독자가 배우는 것** |
|---|---|---|
| 1 | **여는 장면**: 1편이 비판한 매퍼 테스트 16개가 컨텍스트 관점에서는 저장소 최선이다(§3-6) | 테스트의 좋고 나쁨은 단일 축으로 판정할 수 없다. 같은 코드가 단언 축에서 최악이고 구성 축에서 최선일 수 있다 |
| 2 | **틀린 질문 버리기**: "426건이 몇 개의 컨텍스트가 되나"는 성립하지 않는다. 캐시는 JVM의 `static`이고 빌드가 40개다(§3-2) | 저장소 전체 수치를 세는 습관이 답을 못 주는 문제가 있다. 캐시를 논하기 전에 캐시의 경계를 먼저 확인해야 한다 |
| 3 | **키를 먼저 확정한다**: 문서와 소스로 9개 필드(§2) | 추측으로 캐시를 논하지 않는 법. 키 구성은 문서에 목록으로 있고 소스에서 `hashCode` 한 메서드로 확인된다 |
| 4 | ★ **비자명한 셋**(§2-3): 프로파일은 정렬 안 됨, `@DynamicPropertySource`는 메서드가 키, mock은 정의 집합이 키 | **선언과 런타임이 어긋나는 지점.** 그리고 왜 `@DynamicPropertySource`를 베이스에 둬야 하는지가 여기서 기계적으로 설명된다 |
| 5 | ★ **아무도 못 보는 캐시 미스**: 같은 프로파일 집합, 다른 순서. 실물 2건(§3-5) | 리뷰로도 실행으로도 안 걸리는 결함이 있다. 전부 초록불이고 느려지기만 한다 |
| 6 | ★ **변수는 베이스 클래스였다**: 같은 앱의 원본과 재구축본이 12→12와 16→2(§1, §3-3). 저장소가 이유를 주석에 적어 놨다 | **좁힘과 공유는 같은 자리에서 해결된다.** 클래스마다 손으로 적으면 파편화, 베이스에 한 번 적으면 좁힘이자 공유 |
| 7 | ★ **가장 좁힌 컨텍스트는 안 띄우는 것**(§3-8). 대신 못 보게 되는 것을 함께 적고 한 군데로 모았다 | "스코프를 좁혀라"의 극단은 Spring을 안 쓰는 것이다. 그리고 버릴 때는 무엇을 못 보게 되는지 함께 적어야 한다 |
| 8 | **실측**: 924회 요청 → 컨텍스트 10개(§4-2). 캐시 키 실물을 보는 법(§4-3), 로거가 꺼지는 함정(§4-1) | 자기 프로젝트에서 오늘 바로 확인하는 방법. 추정 대신 측정 |
| 9 | ★★ **기준이 하나였다가 셋이 됐다**(§5-0) | **1편은 기준이 있는데 안 지켜진 이야기, 2편은 기준이 지켜졌는데 기준이 틀렸던 이야기.** 검사하기 쉬운 기준 하나가 있으면 그게 유일한 기준처럼 작동한다 |
| 10 | ★ **컨텍스트 구성이 쓸 수 있는 단언을 미리 정한다**: `doesNotHaveBean`/`isNotSameAs`/`hasNotFailed()`는 `@Autowired`로 못 쓴다(§5-4). 반대로 `@Autowired` 필드의 `isNotNull()`은 항진명제다(§6-4) | 구성 방식을 고르는 것은 곧 **표현 가능한 단언의 집합을 고르는 것**이다. 1편의 주제가 한 층 아래에서 다시 나타난다 |
| 11 | ★★ **조용히 깨진 것 셋**: 자동설정 순서로 `getMetricsTrackerFactory()`가 `null`(§5-3), `@Async("이름")` 폴백(§5-4), `withReuse(true)`가 재사용 안 함(§6-6) | **선언은 맞고 런타임이 다른데 예외가 안 난다.** 어떤 단언으로도 못 잡는다. 테스트가 아니라 테스트를 띄우는 방식의 문제이기 때문 |
| 12 | **설정 파일과 테스트가 다른 말을 하는 자리**(§6-2), 오버라이드가 정당한 셋과 "왜 다른지 주석으로"(§6-5) | 값이 우연히 같으면 읽는 사람이 매번 다시 판단해야 한다. 그래서 예외에는 이유를 적어야 한다 |
| 13 | **닫는 자리**: 규칙이 실측에서 태어났다(§7). 3편 예고 한 줄 | 규칙은 위에서 내려오지 않고 깨진 자리에서 자란다 |

**뼈대에서 뺀 것** (배울 점이 한 줄로 안 나옴): 슬라이스 애노테이션 카탈로그, `ApplicationContextRunner` API 사용법, `@AutoConfigure*` 옵션 목록, Testcontainers 설정 방법, `maxSize` 튜닝 가이드. **필요하면 공식 문서 링크 한 줄로 대체하세요.**

⚠️ **2편에서 하지 말 것**:
- 1편 재탕(단언 구체성, change detector, 커버리지, 테스트 이름, 레벨 체계 정의, 게이트 설계). 이름 이야기는 §3-8의 "경계를 옮기면 이름도 옮겨야 한다" 한 줄로만.
- AI, 에이전트, 위임, 자동화(→ 3편)
- 테스트 이름 수치(→ 3편)
- **사용법 나열.** "이렇게 쓰면 됩니다"는 공식 문서가 더 잘합니다.
- **컨텍스트 캐시로 줄어든 실행 시간 수치.** 측정하지 않았습니다. §6-6의 80초에서 27초는 **컨테이너 기동** 수치이지 컨텍스트 캐시가 아닙니다. 섞어 쓰면 사실 오류입니다.
- "우리는 Spring Boot 3.x다" 같은 단수 서술 (W-8)

---

## 10. 후속 편 근거 (3편에서 쓸 것)

- **★ 스킬이 두 벌이라는 구조**(§7). 프로젝트 로컬 스킬에는 날짜와 실측과 파일 줄번호가 있고, 공개 하네스 스킬은 그걸 걷어내고 세 신호만 남겼다. **"일반화하면 재사용 가능해지고 동시에 근거를 잃는다"**가 3편의 좋은 출발점이다.
- **규칙과 코드를 같은 PR에서 고친 사례**(§6-4, §7). 커밋 메시지: "코드만 고치면 다음에 같은 판단을 처음부터 다시 하게 되므로, 이번에 확정한 규약을 스킬 문서에 남긴다." 1편의 "기준은 있었는데 안 지켜졌다"에 대한 실제 대응이다.
- **기계적으로 검사 가능한 규칙 vs 판단이 필요한 규칙**. 2편에서 새로 나온 사례: `@ActiveProfiles` 순서 통일은 **기계가 완벽하게 검사할 수 있다**(정렬해서 비교하면 끝). 반면 "이 테스트가 신호 3에 해당하는가"는 판단이 필요하다. 1편 §1-5의 비대칭(한글 이름 95% 준수 vs 단언 구체성 73% 위반)과 정확히 같은 축이다.
- **스킬 자신이 기계적 판단을 경고한다**: `sr-harness` `dev-testing-strategy` `:34` "신호 1(프로퍼티 공유 여부)만 기계적으로 확인하고 판단하지 않는다. ... 신호 1만 보고 `@Autowired`로 옮기면 조용히 잘못된 선택이 된다." **체크리스트가 자기 오용법을 문서에 적어 둔 자리**다. 3편의 핵심 인용 후보.
- **접미사가 실제 동작과 어긋나면 고친다는 규칙**. 사내 로컬 스킬에 "`Test`인데 실제로는 Spring 컨텍스트를 띄우면 `XxxIntegrationTest`로 고친다"가 있고, 실제로 6건을 한 날에 일괄 리네임한 기록이 있다. **이름을 실제 동작에 맞추는 작업은 기계가 도울 수 있는 종류**다.
- **테스트 이름 수치(1편 노트 V-8/V-21)**: 한글 메서드명 50.0% vs 44.0%, `@DisplayName` 7,641 vs 9,782. **3편이 이 수치에 논지를 걸 예정이므로 그때 반드시 재현할 것.** 아직 근거가 한 겹이다.
- `ownership-principles` 스킬(인지적 부채, 굴복, 오케스트레이션 세금)을 3편에서 확인할 것.

---

## 부록: 재현 방법

### 정적 집계

파서 스크립트는 세션 임시 디렉터리(`scratchpad/ctxkey.py`)에 있어 사라질 수 있습니다. 다시 짜야 하면 기준은 이렇습니다.

1. `src/test/java` 아래 `.java` 파일을 전부 읽는다. `build/` 제외.
2. 최상위 클래스 선언 앞의 애노테이션 블록을 파싱한다. **⚠️ 클래스 선언 앞을 `}` 기준으로 자르면 안 된다**. `@SpringBootTest(classes = {A.class, B.class})`의 `}`에 걸린다. 선언 위치에서 **뒤로** 훑으며 짝이 맞는 괄호를 찾는 방식으로 구현한다.
3. `extends`로 상속 체인을 따라가며 애노테이션을 합친다(하위 우선). Spring 애노테이션은 `@Inherited`다.
4. 각 클래스의 키 튜플: `@SpringBootTest` 인자, `@ContextConfiguration` 인자, 슬라이스 애노테이션(`@WebMvcTest`/`@MybatisTest`/…), `@ActiveProfiles`, `@TestPropertySource`, `@Import`, `@AutoConfigure*` 목록, mock 타입 집합(`@MockBean`/`@SpyBean`/`@MockitoBean`/`@MockitoSpyBean`), `@DynamicPropertySource` 존재 여부, `@EnableAutoConfiguration`.
5. **모듈 단위로 집계한다.** 모듈 = 가장 가까운 조상 중 `build.gradle`(또는 `.kts`)을 가진 디렉터리. 저장소 전체 합계는 캐시 의미상 무의미하다(§3-2).
6. 추상 클래스는 제외한다(실행되지 않음).

⚠️ 이 방식은 **하한**을 준다. 실제 `contextCustomizerFactory` 목록을 반영하지 못하므로 실제 컨텍스트 수는 더 많을 수 있다.

### 실측 (컨텍스트 로드 횟수)

저장소를 수정하지 않고 측정하려면 Gradle init script를 쓴다.

```groovy
// init-ctxcache.gradle
allprojects {
    tasks.withType(Test).configureEach {
        // 순수 logback 경로용 (SpringApplication 미경유 테스트)
        systemProperty 'logback.configurationFile', '/절대경로/logback-ctxcache.xml'
        // ★ Spring Boot LoggingSystem 이 logback-test.xml 로 재초기화해도 살아남는 경로
        systemProperty 'logging.level.org.springframework.test.context.cache', 'DEBUG'
        testLogging { showStandardStreams = true }
    }
}
```

```xml
<!-- logback-ctxcache.xml -->
<configuration>
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder><pattern>[%-5level] [%-45.45logger{45}] - %msg%n</pattern></encoder>
    </appender>
    <logger name="org.springframework.test.context.cache" level="DEBUG"/>
    <root level="WARN"><appender-ref ref="CONSOLE"/></root>
</configuration>
```

```bash
./gradlew test --init-script /절대경로/init-ctxcache.gradle
```

출력에서 이 줄을 찾는다.

```
Spring test ApplicationContext cache statistics:
  [DefaultContextCache@... size = 10, maxSize = 32, parentContextCount = 0,
   hitCount = 914, missCount = 10, failureCount = 0]
```

- `missCount` = 실제로 로드된 컨텍스트 수
- `size` = 현재 캐시에 살아 있는 수 (`missCount`보다 작으면 축출이 일어났다는 뜻)
- `DefaultContextCache@해시`가 여러 개면 JVM 포크가 여럿이라는 뜻이고, 그만큼 캐시가 쪼개진 것이다

⚠️ **두 시스템 프로퍼티를 둘 다 줘야 한다.** `logback.configurationFile`만 주면 첫 `@SpringBootTest`가 뜨는 순간 Spring Boot가 클래스패스의 `logback-test.xml`로 로깅을 재초기화해 캐시 로거가 꺼진다. 이 함정 때문에 1차 측정이 10개 중 2개만 관측했다.

### 캐시 키 실물 보기

컨텍스트 로드를 일부러 실패시키면 Spring이 `MergedContextConfiguration`을 통째로 출력한다(§4-3). 존재하지 않는 프로퍼티를 필수로 요구하게 하거나, 없는 빈을 주입받게 하면 된다. 커스터마이저 목록까지 전부 보인다.
