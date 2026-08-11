---
layout: post
date: 2026-08-11
title: "기준대로 걷어냈더니 하나가 조용히 깨졌다"
subtitle: "Spring 컨텍스트를 어떻게 띄울 것인가 (테스트 기준 2편)"
tags: [테스트, Spring, 코드품질]
---

2026년 8월 9일, 어떤 저장소에서 `ApplicationContextRunner`를 걷어내는 작업이 하루 종일 이어졌습니다. 프로그래밍 방식으로 컨텍스트를 조립하던 테스트들을 `@SpringBootTest` + `@Autowired`로 옮기는 일이었습니다. 판단 기준은 문서로 적혀 있었고, 딱 하나였습니다.

> **기준은 하나: 클래스 안의 테스트 메서드마다 유효 프로퍼티 조합이 달라지는가.**

기준대로 보면 대부분의 Runner는 걷어내는 게 맞았습니다. 메서드마다 다른 프로퍼티를 쓰지 않는데 Runner를 쓸 이유가 없으니까요. 그렇게 옮겼습니다. 컴파일은 통과했고, 컨텍스트도 정상적으로 떴고, 예외도 나지 않았습니다.

그런데 그중 한 파일에서 `HikariDataSource.getMetricsTrackerFactory()`가 조용히 `null`이 됐습니다.

[1편](/blog/2026/08/11/test-standards-1-what-to-test.html)은 기준이 문서에 있는데 260곳 남짓에서 안 지켜진 이야기였습니다. 이 글은 정반대입니다. **기준이 지켜졌는데, 기준이 틀렸습니다.**

> ⚠️ 아래 예제 중 `[재구성]` 표시가 붙은 것은 **사내 저장소 코드의 구조만 남기고 재구성한 것**입니다. 클래스명과 도메인 이름을 중립적인 것으로 바꿨고 파일 경로와 줄번호는 달지 않습니다. **사내 문서와 커밋 메시지를 옮긴 인용문도 마찬가지로 전부 요지만 옮긴 것**이고 원문 그대로가 아닙니다. 반면 `[원문]` 표시가 붙은 것은 **Spring / Spring Boot의 소스와 공식 문서, 그리고 필자가 공개 배포하는 플러그인 스킬**이라 원문 그대로이며 출처를 밝힙니다. 모듈 이름은 전부 이 글 안에서만 통용되는 임의의 라벨입니다.

## 값 하나만 달라지는 고장

문제의 테스트는 커넥션 풀 메트릭이 제대로 배선됐는지 검증합니다.

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
}
```

이 클래스는 모든 테스트가 같은 프로퍼티 조합을 씁니다. 그러니까 **기준 1에 걸리지 않습니다.** 기준대로라면 `@Autowired`로 옮기는 것이 맞습니다.

옮기면 무슨 일이 생기는지를 그날의 컨벤션 문서가 실측 결과로 기록해 뒀습니다. 구조와 요지만 옮기면 이렇습니다.

> `AutoConfigurations.of(...)`가 등록하는 `BeanPostProcessor`는 자동설정 간 순서(`@AutoConfigureAfter`)를 실제 앱 기동과 동일하게 보장하는데, `@ContextConfiguration(classes=...)`는 선언 순서로만 처리해 이 보장이 깨진다. **실측 결과 `HikariDataSource.getMetricsTrackerFactory()`가 조용히 `null`이 됐다.** `AutoConfigurations.of(...)`로 자동설정 클래스(특히 `BeanPostProcessor`를 등록하는 것)를 끌어오는 파일을 전환할 때는 컴파일과 테스트 통과만으로 안전하다고 판단하지 말고 실제 값까지 확인한다.

오직 `getMetricsTrackerFactory()`만 `null`이 됐습니다. 그리고 그 값이 `null`이면 운영 대시보드에서 커넥션 풀 지표가 사라집니다.

**이게 드러난 이유는 하필 이 테스트가 그 값을 단언하고 있었기 때문입니다.** 트래커 팩토리의 타입을 직접 확인하는 두 줄이 없었다면, 컨텍스트는 잘 뜨고 빈도 잘 주입되고 아무도 아무것도 모릅니다. 전환이 안전한지 여부가 **그 전환과 무관한 어떤 단언이 마침 있었는가**에 달려 있었습니다.

한 가지를 분명히 해 두겠습니다. 이 `null`을 **필자가 직접 재현한 것은 아닙니다.** 근거는 그날 사내 문서에 "실측"으로 기록된 문장과, 같은 날 Runner 제거 커밋 본문이 깨지지 않은 쪽을 왜 안전하게 옮길 수 있었는지 대조해 둔 서술입니다. 그 커밋은 이렇게 적었습니다(요지만 옮깁니다).

> 이 설정 클래스는 생성자가 빌더를 주입받는 구조라, 자동설정을 `@ContextConfiguration(classes=...)`로 직접 로드해도 빈 그래프 순서에 영향받지 않는다(생성자 의존은 선언 순서가 아니라 의존 그래프로 해석됨). **`BeanPostProcessor` 기반 배선과는 다른 케이스다.**

같은 커밋이 "이건 안전하다"와 "저건 다르다"를 나란히 적었습니다. 옮기다 하나가 깨졌고, 되돌리면서 왜 나머지는 괜찮은지까지 함께 적은 흔적입니다.

## 기준이 하루 만에 하나에서 셋이 됐다

여기서 흥미로운 건 고장 자체가 아니라 **그 뒤에 벌어진 일**입니다.

기준을 적은 그 문서의 최초 버전, 그러니까 2026-08-09 판본에는 "기준은 하나"라는 문장 아래에 이미 예외 조항이 하나 달려 있습니다.

> **주의. `AutoConfigurations.of(...)`를 쓰는 파일은 `Runner`를 유지한다(2026-08-09 실측).** (…) **실측 결과 `HikariDataSource.getMetricsTrackerFactory()`가 조용히 `null`이 됐다.**

**기준을 적은 날에 이미 예외를 발견했다는 뜻입니다.** 규칙을 세우는 일과 규칙이 안 통하는 자리를 만나는 일이 같은 날에 일어났습니다.

하루 뒤인 2026-08-10에 그 문서가 개정됩니다. 바뀐 것은 셋입니다.

1. "기준은 하나"가 **"세 기준 중 하나라도 해당하면"**으로 바뀝니다.
2. 어제의 "주의" 예외가 **기준 2로 승격**됩니다.
3. **기준 3이 새로 추가**됩니다. "컨텍스트 구조 자체가 단언 대상인가", 날짜는 "2026-08-10 확정".

그리고 머리말에 경고 문장이 붙습니다.

> 프로퍼티 공유 여부(기준 1) 하나만 보고 기계적으로 판단하지 않는다. 기준 3에 해당하는데 기준 1만 보고 옮기면 조용히 잘못된 선택이 된다.

**이 경고는 예방적 조언이 아니라 사후 기록입니다.** 누군가 그 자리를 밟았기 때문에 붙은 문장이고, 밟은 자리와 문장이 적힌 자리 사이의 거리가 하루였습니다.

다만 이것을 부주의로 읽으면 진단을 놓칩니다. **문제는 규칙이 불완전했다는 것입니다.** 기준 1이 유일한 기준이던 시절에는 기준 1만 보고 판단하는 것이 **규칙을 정확히 지키는 행동**이었습니다. 규율의 문제가 아니었습니다.

그러면 왜 기준 1만 먼저 있었을까요.

- 기준 1은 **코드를 보면 바로 확인됩니다.** 메서드마다 `withPropertyValues`가 다른지만 보면 돼요.
- 기준 2와 3은 **무엇이 깨지는지 알아야 확인됩니다.** 자동설정 순서 보장이 무엇인지, `@Autowired`로 표현할 수 없는 단언이 무엇인지를 미리 알아야 합니다.

**검사하기 쉬운 기준이 하나 있으면 그게 유일한 기준인 것처럼 작동합니다.** 이 사건에서는 나머지 둘이 아직 문서에 없었고, 없었던 이유가 바로 확인 비용입니다. 무엇이 깨지는지 알기 전에는 기준으로 적을 수조차 없으니까요. 그리고 기준이 이미 셋 다 적혀 있는 지금도 같은 힘이 남아 있습니다. 확인이 싼 기준이 먼저 소진되고, 비싼 기준은 뒤로 밀립니다.

지금 그 문서의 세 기준은 공개 플러그인 스킬로도 일반화돼 있는데, 원문은 이렇습니다.[^skill]

> 아래 세 신호 중 **하나라도 해당하면** `ApplicationContextRunner`(프로그래밍 방식). 셋 다 아니면 `@ExtendWith(SpringExtension.class)` + `@ContextConfiguration`/`@SpringBootTest(classes=...)` + `@Autowired`로 클래스당 컨텍스트 하나만 띄운다.

## 기준 1은 틀리지 않았습니다

기준 1이 유일했던 게 문제였다는 말은 기준 1이 틀렸다는 말이 아닙니다. 기준 1이 실제로 필요한 자리부터 보겠습니다. 액추에이터 노출 정책을 검증하는 테스트입니다.

```java
// [재구성] 같은 클래스 안에서 프로파일만 바꿔 두 컨텍스트를 띄운다
private final ApplicationContextRunner contextRunner = new ApplicationContextRunner()
        .withInitializer(new ConfigDataApplicationContextInitializer())
        .withPropertyValues("spring.profiles.active=test")
        .withUserConfiguration(TestConfig.class);

@Test
void dev_프로필_오버라이드는_base_노출을_잃지_않는다() {
    ApplicationContextRunner devRunner = /* 위와 같고 profiles.active=dev */;
    devRunner.run(context -> { ... });
}
```

클래스 javadoc이 이 테스트가 존재하는 이유를 적어 뒀습니다. 액추에이터 노출 목록은 프로파일 파일에서 다시 선언하면 base 목록을 병합하지 않고 **통째로 대체**한다는 것. base의 항목들을 dev 쪽에 다시 적지 않으면 메트릭 엔드포인트가 dev에서 조용히 사라집니다.

**`@Autowired` 방식으로는 이 테스트를 한 클래스에 담을 수 없습니다.** 클래스당 컨텍스트 하나가 전제니까요. 클래스를 둘로 쪼개면 되지만, 그러면 "base와 dev를 대조한다"는 이 테스트의 목적이 두 파일로 흩어집니다.

기준 1은 정확합니다. 문제는 기준 1이 **전부인 것처럼** 쓰였다는 데 있었습니다.

## `@Autowired`로는 쓸 수 없는 단언들

기준 3, 그러니까 "컨텍스트 구조 자체가 단언 대상인가"의 실물을 보겠습니다. 알림 전용 스레드풀과 HTTP 클라이언트의 배선을 검증하는 테스트입니다.

```java
// [재구성]
/**
 * 이 테스트가 필요한 이유: @Async("alertExecutor")의 빈 이름이 어긋나 알림용과 공용이
 * 같은 인스턴스로 해석되면 "알림이 웹훅 풀을 잠식하지 않는다"는 이 도메인의 핵심 설계가
 * 무력화되는데도, 컨텍스트는 정상으로 뜨고 다른 테스트는 전부 초록이다.
 */
class AlertWiringIntegrationTest {

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

이 클래스도 프로퍼티를 고정 공유합니다. 기준 1에 걸리지 않습니다. 그런데 `doesNotHaveBean`과 `isNotSameAs`와 `hasNotFailed`는 **필드 주입만으로는 표현할 수 없습니다.** "없어야 정상인 빈"을 주입받을 수는 없으니까요.

정확히 하자면 `ApplicationContext`를 통째로 주입받아 `containsBean`을 직접 물으면 빈의 존재와 부재는 확인할 수 있습니다. 그러나 그렇게 하는 순간 그 테스트는 컨텍스트를 조립하는 게 아니라 이미 조립된 컨텍스트를 심문하는 일이 됩니다. 그리고 **기동에 실패해야 정상인 케이스는 그 방법으로도 안 됩니다.** `@Autowired`에서는 테스트 메서드가 실행되기도 전에 셋업 단계에서 예외가 터지니까요.

**컨텍스트 구성 방식은 그 테스트가 쓸 수 있는 단언의 집합을 미리 정합니다.** 구성 방식을 고르는 것은 문법 취향의 문제가 아니라, 무엇을 검증할 수 있는지를 고르는 일입니다.

그리고 이 클래스도 "조용히 깨지는" 이야기인데, 조용한 지점이 어디인지는 정확히 짚어야 합니다. `@Async("이름")`이 그 이름의 executor를 **못 찾는** 경우는 조용하지 않습니다. Spring은 `NoSuchBeanDefinitionException`을 던집니다.[^async] 다만 그 예외는 컨텍스트 기동이 아니라 **그 메서드를 실제로 호출하는 시점**에 납니다. 컨텍스트는 초록불로 뜨고, 그 경로를 밟지 않는 테스트는 전부 통과합니다.

소리가 정말 안 나는 쪽은 이름이 **찾아지긴 하는데 의도한 풀이 아닌** 경우입니다. 두 이름이 같은 인스턴스로 해석되면 예외도 경고도 없고 격리 설계만 무너집니다. 위 테스트의 `isNotSameAs`가 잡는 것이 정확히 이 경우입니다.

### 반대 방향으로도 똑같이 작동합니다

구성 방식이 단언을 정한다면, 잘못 고른 구성은 **항진명제를 만들어 냅니다.**

2026-08-10의 커밋 하나가 `@Autowired` 필드에 대한 `isNotNull()` 단언 3건을 지웠습니다. 커밋 메시지의 이유가 정확합니다.

> `@Autowired` 주입이 실패하면 컨텍스트 로드 단계에서 이미 깨지므로 빨간불이 나는 경로가 없었다.

1편의 매퍼 통합 테스트에서 `isNotNull()`이 항진명제였던 이유는 MyBatis가 결과 없을 때 빈 리스트를 반환하기 때문이었습니다. 여기서는 Spring의 주입 실패가 테스트 메서드 실행 **전에** 터지기 때문입니다. **원인은 다르고 형태는 같습니다.** 그리고 이건 `@Autowired` 방식을 고른 순간 구조적으로 생기는 함정입니다. 같은 단언이 Runner에서는 `hasNotFailed()`로 실제 검증이 됩니다.

같은 커밋이 하나를 더 고쳤습니다. 이번엔 프로퍼티 쪽입니다.

> 개정 전에는 `spring.task.execution.thread-name-prefix=async-`를 테스트가 주입하고 `startsWith("async-")`를 단언했다. yml이 바뀌어도 영원히 초록불인 자기충족 구조였다.

교정은 주입을 지우고 실제 yml에서 읽게 바꾸는 것이었습니다. 그런데 **같은 파일의 다른 프로퍼티 세 개는 남았습니다.**

```java
// [재구성]
@TestPropertySource(properties = {
        // 값이 아니라 검증 조건이다. 아래 동시성 테스트가 30개 호출로 8개 스레드를 재사용하게 만들어야
        // MDC 데코레이터의 격리가 드러난다. yml 기본값(20)이면 스레드 재사용이 일어나지 않아
        // 그 테스트가 아무것도 검증하지 못한다. thread-name-prefix는 여기서 덮지 않는다.
        "spring.task.execution.pool.core-size=8",
        "spring.task.execution.pool.max-size=8",
        "spring.task.execution.pool.queue-capacity=50"
})
```

같은 파일 안에서 한 프로퍼티는 지워졌고 다른 프로퍼티는 남았습니다. 기준은 **"이 값이 검증을 만드는가, 검증을 대신하는가"**였습니다. 스레드 풀 크기를 8로 좁히는 것은 재사용을 강제해 검증 조건을 만드는 일이고, 스레드 이름 접두사를 주입하는 것은 검증해야 할 것을 대신 적어 주는 일입니다.

그래서 주석이 필요합니다. **적지 않으면 다음 사람이 리터럴 중복으로 보고 지웁니다.** 같은 저장소의 컨벤션 문서가 정당한 오버라이드를 나열하면서 "왜 yml 값과 다른지 반드시 주석으로 남긴다"를 붙여 둔 이유입니다.

### 그래서 값이 우연히 같으면 문제가 됩니다

반대 사례도 있습니다. 어떤 모듈의 통합 테스트 베이스가 `@DynamicPropertySource`로 이런 값을 등록합니다.

```java
// [재구성]
@DynamicPropertySource
static void configureProperties(DynamicPropertyRegistry registry) {
    registry.add("spring.datasource.url", postgres::getJdbcUrl);          // 런타임 결정값
    registry.add("spring.datasource.username", postgres::getUsername);    // 런타임 결정값
    registry.add("spring.datasource.password", postgres::getPassword);    // 런타임 결정값
    registry.add("spring.datasource.driver-class-name", () -> "org.postgresql.Driver");   // 상수
    registry.add("spring.jpa.hibernate.ddl-auto", () -> "create-drop");                   // 상수
    registry.add("spring.jpa.properties.hibernate.dialect", () -> "...PostgreSQLDialect");// 상수
    registry.add("spring.flyway.enabled", () -> "false");                                 // 상수
}
```

앞의 셋은 컨테이너가 떠야 알 수 있는 값이라 여기 있는 게 맞습니다. 뒤의 넷은 상수입니다. 그리고 그중 셋이 같은 모듈의 `application-test.yml`에도 있는데, **한 줄이 다릅니다.**

| 키 | `application-test.yml` | `@DynamicPropertySource` |
|---|---|---|
| `spring.datasource.driver-class-name` | H2 드라이버 | PostgreSQL 드라이버 |
| `spring.jpa.hibernate.ddl-auto` | `create-drop` | `create-drop` |
| `spring.flyway.enabled` | `false` | `false` |

설정 파일은 H2를 말하고 베이스 클래스는 PostgreSQL을 말합니다. 승부는 이미 정해져 있어요. `@DynamicPropertySource`로 등록한 값은 `@TestPropertySource`와 OS 환경변수와 시스템 프로퍼티와 `@PropertySource`보다 우선하므로[^dynprec] PostgreSQL이 이기고 yml의 H2 설정은 죽은 코드입니다. **파일만 봐서 알 수 없는 것은 승자가 아니라 어느 쪽이 의도였는가입니다.**

**이 표가 무서운 이유는 나머지 두 줄이 우연히 같다는 데 있습니다.** 값이 같으면 아무 증상이 없고, 아무 증상이 없으면 아무도 확인하지 않습니다. 그러다 한 줄이 갈라지면 그때부터는 읽는 사람이 매번 처음부터 다시 판단해야 합니다.

## 여기서 가설을 하나 검증했습니다

지금까지가 "어떻게 띄우는가"의 판단 이야기였다면, 남은 절반은 "그래서 몇 개가 뜨는가"입니다. 같은 스킬 문서에는 세 신호 말고 스코프 원칙도 있습니다. 검증 대상 빈과 필요한 설정만 최소로 구성하는 것이 기본이고, 전체 자동설정을 올리는 것은 스모크와 E2E 두 역할로만 한정하라는 내용이에요.

여기서 걸리는 게 있었습니다. 좁히라는 원칙과, 앞에서 본 베이스 클래스 주석의 "설정을 통일해 캐시를 공유하라"가 서로 반대 방향을 가리키는 것처럼 보이거든요. 그래서 이 글을 쓰기 전에 가설을 하나 세웠습니다.

> 좁힘과 캐시 공유가 부딪힌다. 클래스마다 `classes=` 목록을 손으로 다르게 적는 건 좁힘이 아니라 파편화다.

결론부터 말하면 **가설의 방향은 맞았고 지목한 범인은 틀렸습니다.** 파편화는 실제로 있었지만 `classes=`가 만든 것이 아니었습니다. 확인한 순서대로 옮기겠습니다.

### 먼저, 질문 자체가 성립하지 않았습니다

1편을 쓰면서 모아 둔 숫자 중에 "인자 없는 `@SpringBootTest` 425건"이 있었습니다. 자연스럽게 나오는 다음 질문은 "그 425건이 몇 개의 컨텍스트로 수렴하는가"입니다.

그런데 공식 문서의 한 문단이 이 질문을 무너뜨립니다.[^caching]

> "The Spring TestContext framework stores application contexts in a static cache. This means that the context is literally stored in a `static` variable. In other words, if tests run in separate processes, the static cache is cleared between each test execution, which effectively disables the caching mechanism."
>
> "To benefit from the caching mechanism, all tests must run within the same process or test suite."

캐시는 JVM의 `static` 변수입니다.[^mcc] 그리고 이 저장소는 모노레포지만 **Gradle 빌드가 40개로 갈라져 있습니다.** 각 모듈이 자기 `test` 태스크에서 자기 JVM을 띄웁니다.

**그러니 "425건이 몇 개의 컨텍스트가 되는가"는 성립하지 않는 질문입니다.** 그 건수는 40개의 JVM에 흩어져 있고, 캐시는 JVM 경계를 넘지 못합니다. 의미 있는 질문은 **"한 모듈 안에서 몇 개인가"**뿐입니다.

1편에서도 비슷한 자리를 지났습니다. 저장소 전체의 약한 단언 비율 3.4%는 분포를 가리고 있었고, 접미사 그룹으로 쪼개니 그제서야 진단이 나왔습니다. 여기서는 한 걸음 더 나갑니다. **총량이 진단을 가리는 게 아니라, 총량이라는 개념 자체가 이 주제에는 없습니다.**

### 키를 먼저 확정합니다

무엇이 컨텍스트를 가르는지를 추측으로 논하지 않기 위해, 공식 문서의 목록과 소스를 대조했습니다. 캐시 키를 이루는 파라미터는 문서에 목록으로 있고[^caching], 소스에서는 `hashCode` 한 메서드로 확인됩니다.

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

Boot 2.7이 쓰는 5.3.31부터 3.5가 쓰는 6.2.9까지 이 구조는 사실상 바뀌지 않았습니다. 필드 이름 하나가 바뀌었을 뿐입니다.[^mcc]

여기서 읽어야 할 것은 목록 자체가 아니라 **목록에 들어간 세 항목이 상식과 다르게 동작한다**는 사실입니다.

### 비자명한 셋

**첫째, `@ActiveProfiles`는 정렬되지 않습니다. 선언 순서가 키를 가릅니다.**

```java
// [원문] spring-test 6.1.11, MergedContextConfiguration.processActiveProfiles
private static String[] processActiveProfiles(@Nullable String[] activeProfiles) {
    if (activeProfiles == null) {
        return EMPTY_STRING_ARRAY;
    }

    // Active profiles must be unique
    Set<String> profilesSet = new LinkedHashSet<>(Arrays.asList(activeProfiles));
    return StringUtils.toStringArray(profilesSet);
}
```

`LinkedHashSet`은 중복만 제거하고 삽입 순서를 유지합니다. 정렬하지 않습니다. 그리고 키는 `Arrays.hashCode(this.activeProfiles)`, 그러니까 **배열의 순서까지 보는 해시**입니다. 따라서 `{"a","b","c"}`와 `{"a","c","b"}`는 활성 프로파일 집합이 같은데도 **서로 다른 컨텍스트**가 됩니다.

여기서 프레임워크를 탓하기 쉬운데, 순서를 무시하는 쪽이 오히려 틀립니다. Spring Boot는 여러 프로파일이 지정되면 **나중에 적은 것이 이기는** 전략을 씁니다. `prod,live`를 켜면 `application-live`의 값이 `application-prod`의 값을 덮어써요.[^lastwins] 두 프로파일이 같은 키를 다르게 정의하고 있으면 순서가 실제 동작을 바꿉니다. 순서가 의미를 가질 수 있으니 캐시 키도 순서를 봐야 하는 겁니다.

**그러니 문제는 프레임워크가 아니라 우리 쪽에 있습니다.** 순서가 의미를 갖는 자리에서 순서를 의미 없이 섞어 쓰면, 그 대가를 컨텍스트 하나를 더 띄우는 비용으로 치릅니다.

**둘째, `@DynamicPropertySource`는 값이 아니라 메서드로 키에 참여합니다.**

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

등록하는 값이 아니라 `Set<Method>`가 키입니다. 그래서 베이스 클래스에 `@DynamicPropertySource` 메서드가 하나 있으면 하위 클래스 전부가 **같은 `Method` 객체**를 공유해 컨텍스트가 하나로 모입니다. 반대로 클래스마다 자기 static 메서드를 따로 두면 **똑같은 값을 등록해도** 컨텍스트가 갈립니다.

**셋째, `@MockBean` 계열은 정의 집합으로 키에 참여합니다.** `Set`의 `equals`를 쓰므로 **선언 순서는 무관**합니다.[^mockito] 프로파일과 정반대인데, 이것도 변덕이 아니라 각자의 의미론을 따른 결과입니다. mock을 어느 순서로 선언하든 동작은 달라질 수 없으니 집합으로 보고, 프로파일은 순서가 값을 바꿀 수 있으니 순서까지 봅니다. **캐시 키 설계를 읽으면 그 프레임워크가 무엇을 의미 있는 차이로 여기는지가 드러납니다.**

**셋 다 애노테이션의 겉모습으로는 알 수 없고, 소스를 열어야 알 수 있습니다.** 다음 두 절은 이 셋이 만든 결과입니다.

### 아무도 못 보는 캐시 미스

프로파일 순서 이야기는 이론에 그치지 않았습니다. 한 모듈에서, 전부 같은 베이스를 상속하는 클래스들 사이에 이런 쌍이 **실제로 두 건** 있었습니다.

```java
// [재구성] 같은 모듈, 같은 베이스, 같은 프로파일 집합. 순서만 다르다.
@ActiveProfiles(profiles = {"default", "prod", "bset", "rest"})   // 클래스 하나
@ActiveProfiles(profiles = {"default", "rest", "prod", "bset"})   // 나머지

@ActiveProfiles(profiles = {"default", "dev", "l4", "rest"})      // 클래스 하나
@ActiveProfiles(profiles = {"default", "rest", "dev", "l4"})      // 나머지 다수
```

각 쌍은 활성 프로파일 집합이 완전히 같은데 컨텍스트는 두 개 뜹니다. 순서가 의도된 것이었다면 같은 모듈, 같은 베이스 아래에서 두 표기가 섞여 있을 이유가 없으니, 이건 의미 없는 차이가 비용을 만든 자리로 보입니다.

덤이 하나 더 있습니다. 어떤 클래스는 프로파일 목록 안에서 항목 하나만 주석 처리했습니다.

```java
// [재구성]
@ActiveProfiles(profiles = {"default", "rest", "dev"
//  , "l4"
})
```

주석 한 줄이 세 번째 조합을 만들었습니다. 다만 이건 앞의 두 쌍과 종류가 다릅니다. 순서가 아니라 **집합 자체가 달라졌으니** 그 프로파일이 정의하던 값이 통째로 빠지고, 캐시만이 아니라 동작에도 영향이 갑니다. 반대로 말하면 이쪽은 언젠가 무언가 실패해서 드러날 여지라도 있습니다.

**순서만 다른 두 쌍은 그렇지 않습니다. 코드 리뷰로 안 걸리고 실행해도 안 걸립니다.** 테스트는 전부 초록불이고, 느려질 뿐입니다. 1편의 주제 질문은 "무엇이 바뀌면 이게 실패해야 하는가"였는데, 이 결함은 그 질문의 사각지대에 있습니다. **아무것도 실패하지 않는데 비용만 늡니다.** 테스트가 아니라 테스트를 돌리는 인프라의 문제라서, 어떤 단언을 어떻게 써도 이걸 잡지 못합니다.

### 그래서 직접 세어 봤습니다

여기서 원래 가설로 돌아갑니다. 파서를 새로 짜서 `src/test/java` 아래 Java 파일을 전부 훑고, 클래스 레벨 애노테이션과 상속 체인을 합쳐 "이 클래스가 실제로 요구하는 컨텍스트 설정"을 튜플로 만든 뒤 중복을 셌습니다.[^count]

겉보기 숫자는 가설을 지지했습니다. `classes=`로 좁힌 39개 클래스가 컨텍스트 26개를 만들고(1.5 대 1), 무인자 `@SpringBootTest` 계열 754클래스가 118개를 만듭니다(6.4 대 1). 재사용 비만 보면 `classes=`가 범인 같습니다. 물론 이 합산도 방금 말한 함정을 그대로 밟고 있어요. 40개 JVM에 흩어진 숫자를 더한 것이라 캐시 관점에서는 의미가 없습니다. 그래서 이건 가설을 세운 근거로만 쓰고 버립니다.

그런데 **`classes=`를 쓴 자리를 실제로 열어 보면 대부분 그게 옳은 선택입니다.** 가장 선명한 예가 프로파일 바인딩 테스트 다섯 벌입니다. 각각 `@SpringBootTest(classes = 자기TestConfig.class, webEnvironment = NONE)`에 `@ActiveProfiles`가 `dev`, `prod`, `stg`, `dr`, `test`로 다릅니다. 다섯 개가 각자 다른 컨텍스트를 만드는데, **`@ActiveProfiles`가 이미 다르므로 `classes=`를 지워도 여전히 다섯 개**입니다. 여기서 `classes=`가 한 일은 파편화가 아니라, 다섯 개를 각각 **작게** 만든 것입니다.

실제로 파편화를 예측한 변수는 따로 있었습니다. **공통 베이스 클래스의 유무**입니다.

| 모듈 | 테스트 클래스 | 서로 다른 컨텍스트 | 재사용 비 | 공통 베이스 |
|---|---|---|---|---|
| 모듈 G | 16 | 2 | 8.0 | 있음 (15클래스가 하나 상속) |
| 모듈 I | 45 | 5 | 9.0 | 있음 (31 + 12로 둘) |
| 모듈 H | 12 | 12 | 1.0 | 없음 |
| 모듈 E | 12 | 11 | 1.1 | 없음 |
| 모듈 E′ | 9 | 9 | 1.0 | 없음 |
| 모듈 F | 4 | 4 | 1.0 | 없음 |

**모듈 G와 모듈 H는 같은 애플리케이션의 재구축본과 원본입니다.** 같은 도메인, 비슷한 테스트인데 한쪽은 16클래스가 컨텍스트 2개를 쓰고 다른 쪽은 12클래스가 12개를 씁니다. 차이는 베이스 클래스 하나입니다.

키를 가르는 축의 실제 기여 순서를 세어 보면 `@ActiveProfiles` 조합이 가장 많이 가르고, 그 다음이 `@MockBean` 조합, 그 다음이 `@TestPropertySource`와 `@AutoConfigure*`이며, `classes=`가 가장 적게 가릅니다. **파편화를 만드는 것은 키를 가르는 축이 클래스마다 제각각인 것이지 `classes=` 자체가 아니었습니다.**

`@MockBean` 쪽 수치가 이 진단을 확인해 줍니다. 어떤 모듈은 45클래스 중 14개에 mock을 다는데 mock이 만든 컨텍스트 증가가 **0**입니다. mock을 **베이스 클래스에** 달았기 때문입니다. 클래스마다 달았으면 14개로 갈렸을 겁니다. 반대편에는 31클래스가 mock을 다는데 조합이 29가지인 모듈이 있습니다. 사실상 클래스마다 다릅니다.

그리고 저장소가 이 판단을 **주석으로 먼저 적어 뒀습니다.**

```java
// [재구성] 계약 테스트 공통 베이스의 javadoc과 선언부
/**
 * 설정을 통일해 컨텍스트 캐시를 공유하므로, 하위 클래스는 @TestPropertySource를
 * 추가하지 말고 이 베이스의 컨텍스트를 그대로 사용한다.
 */
@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = { /* dialect, ddl-auto, health 3종 */ })
public abstract class HttpContractTestBase {

    @MockitoBean
    DataSource dataSource;
}
```

**"하위 클래스는 `@TestPropertySource`를 추가하지 말라."** 프로퍼티도 mock도 베이스에만 답니다. 앞에서 본 대로 그러면 키가 하나로 모입니다.

그러니 정확한 명제는 이렇습니다. **좁힘과 공유는 대립하지 않습니다. 둘 다 "설정을 어디에 적는가"의 문제이고, 베이스 클래스가 좁힘을 정의하면 둘 다 얻습니다.**

이 대비를 가장 잘 보여 주는 자리가 하필 1편에서 가장 심하게 비판한 그 매퍼 통합 테스트들입니다. 16개 클래스가 이 네 줄을 글자까지 똑같이 갖고 있습니다.

```java
// [재구성] 16개 클래스가 이 4줄을 글자까지 똑같이 갖는다
@MybatisTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ActiveProfiles("oracle-it")
@Tag("oracle-integration")
```

**16개 전부가 컨텍스트 하나를 공유합니다.** `@MybatisTest`는 슬라이스라 웹 레이어, 서비스 빈, 대부분의 자동설정을 뺍니다. 좁힘이 애노테이션 하나로 표현돼 있고, 그 선언이 동시에 캐시 키가 됩니다. 손으로 `classes = {MapperConfig.class, DataSourceConfig.class, ...}`를 적었다면 클래스마다 목록이 미묘하게 달라졌을 겁니다.

**1편에서 약한 단언이 가장 심하게 몰려 있다고 지목한 코드가, 컨텍스트 구성 축에서는 교과서적으로 짜여 있습니다.** 테스트가 좋다거나 나쁘다는 판정을 단일 축으로 내릴 수 없다는 게 여기서 숫자로 확인됩니다.

### 가장 좁힌 컨텍스트는 컨텍스트를 안 띄우는 것입니다

2026-08-09 그 하루에 일어난 일 중 가장 큰 것은 Runner를 `@Autowired`로 바꾼 게 아니었습니다. **다섯 개 파일이 Spring 컨텍스트를 통째로 버렸습니다.**

교정 커밋의 근거를 요지만 옮기면 이렇습니다.

> `@ConfigurationProperties` 클래스들이 이미 생성자 코드로 필수값을 검증하고 `IllegalStateException`을 던지는 순수 자바 클래스라는 점을 활용한다. Spring 컨텍스트를 띄울 필요 없이 `new XxxProperties(...)`를 직접 호출해 `assertThatThrownBy`로 검증하면 된다. `ApplicationContextRunner`, `TestConfig` 중첩 클래스, 헬퍼를 전부 제거한다.

**그런데 여기서 멈추지 않은 게 중요합니다.** 같은 커밋이 컨텍스트를 버리면 못 보게 되는 것을 함께 적고, 그 책임을 한 군데로 모았습니다.

> Spring의 kebab-case 프로퍼티 키에서 생성자 파라미터로 이어지는 relaxed binding 자체를 검증하는 책임은 실제 yml을 로드하는 테스트 하나로 모은다. 커버리지 공백을 메우려고 프로퍼티 클래스 하나를 그 테스트에 새로 추가했다.

생성자 직접 호출은 "필수값이 없으면 예외를 던지는가"를 검증하고, yml 로드 테스트는 "yml의 `read-timeout`이 생성자의 `readTimeout` 파라미터에 실제로 꽂히는가"를 검증합니다. 오타나 필드 뒤바뀜은 앞쪽이 절대 못 잡아요. **버린 것과 그래서 잃은 것과 그것을 대신 받는 자리가 한 커밋 안에 다 있습니다.**

테스트 이름도 같은 커밋에서 함께 바뀌었습니다.

> 일부 테스트명을 "…기동에_실패한다"에서 "…예외를_던진다"로 바꿨다. 더 이상 Spring 컨텍스트 기동이 아니라 생성자 예외를 검증하므로 이름이 실제 동작과 맞아야 한다.

1편에서 이름이 곧 명세라는 이야기를 길게 했는데, 여기서는 한 줄이면 됩니다. **경계를 옮기면 이름도 함께 옮겨야 합니다.** 컨텍스트를 걷어내는 순간 기존 이름이 거짓말이 됐으니까요.

## 추정 말고 측정

여기까지는 전부 정적 분석입니다. 파일을 읽고 세었을 뿐 실제로 몇 번 뜨는지는 못 봤습니다. 그래서 한 모듈을 실제로 돌렸습니다.[^measure]

`org.springframework.test.context.cache` 로거를 DEBUG로 올리면 매 컨텍스트 요청마다 통계가 찍힙니다. 저장소를 수정하지 않으려고 Gradle init script로 테스트 JVM에만 설정을 주입했습니다. 공통 지원 패키지의 24개 클래스를 돌린 결과는 이렇습니다.

```
size = 10, maxSize = 32, parentContextCount = 0, hitCount = 914, missCount = 10, failureCount = 0
```

컨텍스트 요청 924회에 실제로 로드된 컨텍스트는 10개, 캐시 히트 914회입니다. 재사용 비 91.4 대 1이고 `maxSize` 32에 도달하지 않았습니다. 미스 10건을 로그에서 되짚으면 5건이 앞에서 본 프로파일 바인딩 테스트 다섯 벌(프로파일이 각자 다르니 당연)이고 나머지 5건이 `@ContextConfiguration` 기반 테스트들이었습니다.

측정에는 함정이 하나 있었습니다. `-Dlogback.configurationFile`로 로거를 켜면 처음엔 찍히다가 **중간에 멈춥니다.** 첫 `@SpringBootTest`가 뜨는 순간 Spring Boot의 `LogbackLoggingSystem`이 클래스패스의 `logback-test.xml`로 로깅을 재초기화해서 설정을 덮어쓰기 때문입니다. `logging.level.org.springframework.test.context.cache=DEBUG`를 시스템 프로퍼티로 **함께** 줘야 끝까지 찍힙니다. 이걸 놓친 1차 측정에서는 컨텍스트를 2개만 관측했고, 고친 뒤 10개가 나왔습니다.

### 캐시 키 실물을 보는 법

컨텍스트 로드가 실패하면 Spring이 `MergedContextConfiguration`을 **전부 출력합니다.** 캐시 키를 눈으로 볼 수 있는 유일한 자리입니다.

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

클래스명만 중립화했고 값은 실제 출력입니다. 앞에서 소스로 읽었던 키의 구성요소들이 여기서는 값으로 보입니다.

- **`@SpringBootTest` 하나만 달아도 커스터마이저가 12개** 붙습니다. 전부 Spring Boot가 자동으로 붙인 것입니다.
- `MockitoContextCustomizer@0`과 `DynamicPropertiesContextCustomizer@0`의 해시코드 0은 **빈 집합**입니다. mock도 `@DynamicPropertySource`도 없으니 이 자리는 아직 키를 가르지 않습니다. **하나라도 추가하는 순간 갈립니다.**
- `webEnvironment`는 `SpringBootTestAnnotation` 커스터마이저와 `propertySourceProperties` **양쪽에** 흔적을 남깁니다. 덤프의 `spring.main.web-application-type=none`이 `webEnvironment = NONE`을 프로퍼티 한 줄로 번역한 자국입니다.[^sbta]

**키를 추측하지 않고 확인할 수 있다는 것이 이 절의 요점입니다.** 캐시 로거를 켜서 통계를 보거나, 컨텍스트를 일부러 하나 깨뜨려 키 실물을 보면 됩니다.

### 실측하지 못한 것

정직하게 적어 두겠습니다. **실측한 모듈은 하나뿐입니다.** 나머지 39개 Gradle 프로젝트는 정적 분석뿐입니다.

정적 집계에서 46클래스가 34가지 조합을 만드는 모듈이 하나 나왔습니다. 기본 `maxSize`가 32이므로 **축출이 일어날 조건에 있습니다.** 다만 그 모듈은 실행하지 못했으니 "실제로 축출이 일어났다"고는 쓸 수 없어요. 그리고 저장소 전체를 통틀어 상한을 넘긴 모듈은 그 하나뿐입니다. "우리 조직은 캐시를 망치고 있다"가 아니라 **"한 곳에서만 망가졌고 그 한 곳을 특정할 수 있다"**가 정확한 진단입니다.

**컨텍스트 로드에 걸리는 시간도 측정하지 않았습니다.** 그래서 이 글에는 "캐시 미스 하나가 몇 초"라는 수치가 없습니다. 정적 집계 자체도 하한값입니다. 실행 로그에서 확인한 커스터마이저 12개를 파서가 재현하지 못하므로, 실제 컨텍스트 수는 센 것보다 많을 수 있습니다.

## 그리고 애노테이션이 거짓말을 합니다

마지막 사례는 Spring 밖에서 왔지만 같은 병입니다.

어떤 모듈의 테스트가 **전체 실행 5회 중 3회가 서로 다른 테스트로 깨졌습니다.** 개별로 돌리면 통과해요. 원인 중 하나가 이것이었습니다.

```java
// [재구성] 교정 전. 클래스마다 이것을 각자 갖고 있었다
@Testcontainers
class SomeDbIntegrationTest {

    @Container
    static final OracleContainer ORACLE = new OracleContainer("...")
            .withReuse(true);   // ← 이게 공유해 줄 거라고 생각했다
}
```

`withReuse(true)`가 붙어 있으니 컨테이너가 재사용될 것 같습니다. **그런데 아닙니다.** 공식 문서가 요구하는 조건은 `withReuse(true)` 말고도 더 있습니다.[^reuse]

> "To use it, start the container manually by calling `start()` method, do not call `stop()` method directly or indirectly via `try-with-resources` or `JUnit integration`, and enable it manually through an **opt-in mechanism per environment**."

여기서 말하는 환경별 opt-in은 환경변수 `TESTCONTAINERS_REUSE_ENABLE=true`이거나 `~/.testcontainers.properties`의 `testcontainers.reuse.enable=true`입니다. 그리고 문서는 한 걸음 더 나가 **"Reusable containers are not suited for CI usage"**라고 못 박습니다.

위 코드는 두 군데서 조건을 어깁니다. 하나는 환경 opt-in이 안 켜져 있다는 것이고, 다른 하나는 `@Testcontainers` + `@Container`라는 **JUnit 통합** 자체가 문서가 쓰지 말라고 지목한 것이라는 점입니다. 그 애노테이션이 클래스 단위로 컨테이너를 시작하고 멈춰 버리니까요.

**즉 `withReuse(true)`는 코드에 적혀 있지만, 그 옵션이 실제로 동작하는지는 코드 밖에 달려 있습니다.** 개발자 각자의 홈 디렉터리 파일입니다. 켜 둔 사람의 머신에서는 잘 돌고, 그렇지 않은 곳에서는 이렇게 됩니다.

> 켜지 않은 환경(CI, 새 체크아웃)에서는 클래스 수만큼 컨테이너가 뜨고, 무거운 이미지가 기본 대기 시간(60초) 안에 준비 로그를 못 뱉어 `ContainerLaunchException`으로 실패했다.

**여기서 진짜 어려운 부분은 증상과 원인이 두 단계 떨어져 있다는 점입니다.** 실패가 "재사용이 안 됐다"로 나타나지 않고 "컨테이너 기동 타임아웃"으로 나타납니다. 그리고 재사용을 켜 둔 머신에서는 재현조차 되지 않습니다.

교정은 컨테이너를 싱글턴 하나로 묶는 것이었고, 교정된 클래스의 주석이 판단 근거를 그대로 지고 있습니다.

```java
// [재구성]
/**
 * Oracle 컨테이너를 JVM당 하나만 띄우는 싱글톤 컨테이너(Testcontainers 공식 권장 패턴).
 *
 * 도입 배경: 이전에는 DB가 필요한 테스트 클래스마다 @Container static OracleContainer를
 * 각자 선언했다. withReuse(true)가 붙어 있었지만 그 옵션은 개발자가 자기 머신의
 * ~/.testcontainers.properties에 testcontainers.reuse.enable=true를 직접 켜야 동작한다.
 *
 * 여기서는 static 초기화로 한 번만 시작하고 stop()을 호출하지 않는다. 정리는
 * Testcontainers의 Ryuk 사이드카가 JVM 종료 후 맡는다.
 *
 * @Testcontainers/@Container는 붙이지 않는다. 그 애노테이션이 컨테이너
 * 라이프사이클을 클래스 단위로 되돌려 싱글톤이 무의미해진다.
 */
public final class OracleTestContainer {

    /** 기본 대기 시간(60s)으로는 느린 머신에서 기동 로그를 놓친다. 여유를 명시적으로 준다. */
    private static final Duration STARTUP_TIMEOUT = Duration.ofMinutes(5);
    ...
}
```

그 커밋이 남긴 실측 기록은 이렇습니다.

> 검증: 전체 테스트 5회 연속 통과. 부수 효과로 **전체 실행 시간이 로컬 기준 1분 20초대에서 27초대로 줄었다. 컨테이너 기동이 3회에서 1회가 됐다.**

이 수치에 두 가지 단서를 답니다. 첫째, 필자가 직접 5회 재현한 것이 아니라 **커밋에 기록된 값을 인용**한 것입니다. 둘째, 줄어든 것은 **Testcontainers 컨테이너 기동 횟수**이지 Spring 컨텍스트 로드 횟수가 아닙니다. 컨텍스트 캐시의 효과로 옮겨 읽으면 사실이 어긋나요.

다만 **구조는 같습니다.** 클래스마다 선언하던 무거운 자원을 한 군데로 모은 것이고, 그 "한 군데"가 앞에서 본 베이스 클래스와 정확히 같은 자리입니다.

## 선언은 맞고 런타임이 다릅니다

지금까지 나온 고장을 한 줄씩 모으면 같은 모양입니다.

| 선언 | 읽히는 뜻 | 실제 | 증상 |
|---|---|---|---|
| `withReuse(true)` | 컨테이너를 재사용한다 | 코드 밖 설정 파일이 켜져 있어야 동작 | 기동 타임아웃 |
| `@ActiveProfiles({"a","b"})` | 이 프로파일들을 켠다 | 적은 순서가 캐시 키를 가른다 | 없음 (느려질 뿐) |
| `@Async("이름")` | 이 풀을 따로 쓴다 | 같은 인스턴스로 해석돼도 아무 말이 없다 | 없음 (격리만 무너짐) |
| `@ContextConfiguration(classes = {A, B})` | 이 둘을 등록한다 | 자동설정 간 순서 보장을 잃는다 | 값 하나만 `null` |

**넷 다 예외가 나지 않습니다.** 다만 잡히는 방식은 둘로 갈립니다.

아래 둘은 **구성 자체를 단언하는 테스트가 있으면** 잡힙니다. Hikari의 `null`이 드러난 것은 하필 그 값을 확인하는 두 줄이 있었기 때문이고, `@Async` 별칭 충돌은 두 executor가 다른 인스턴스인지 묻는 단언이 잡습니다. 다만 둘 다 **그 전환과 무관한 단언이 마침 거기 있었기 때문에** 걸린 것이지, 전환의 안전성을 확인하려고 쓴 단언이 아니었습니다.

위의 둘은 어떤 단언으로도 잡히지 않습니다. 프로파일 순서는 증상이 비용뿐이고, `withReuse`는 증상이 인프라 타임아웃으로 나타나 원인과 두 단계 떨어져 있어요. **"무엇이 바뀌면 이 테스트가 실패해야 하는가"를 아무리 잘 물어도**, 여기서 바뀌는 것은 테스트가 아니라 테스트를 띄우는 방식이니까요.

## 무엇을 배웠는가

**첫째, 검사하기 쉬운 기준이 하나 있으면 그게 유일한 기준인 것처럼 작동합니다.** 기준 1은 코드를 보면 바로 확인되고 기준 2와 3은 무엇이 깨지는지 알아야 확인됩니다. 그래서 하루 동안 기준 1만 작동했고, 그 하루에 하나가 조용히 깨졌습니다. 1편은 기준이 있는데 안 지켜진 이야기였고, 이 편은 **기준이 지켜졌는데 기준이 틀렸던** 이야기입니다.

**둘째, 컨텍스트 구성 방식은 그 테스트가 쓸 수 있는 단언의 집합을 미리 정합니다.** 기동 실패가 기대 결과인 케이스는 `@Autowired`로 표현할 방법이 아예 없고, 빈의 부재나 동일성은 컨텍스트를 통째로 주입받아야 겨우 물을 수 있습니다. 반대로 `@Autowired` 필드에 대한 `isNotNull()`은 구조적으로 항진명제가 됩니다. 구성 선택은 문법 취향이 아니라 검증 범위의 선택입니다.

**셋째, 좁힘과 공유는 대립하지 않습니다.** 둘 다 "설정을 어디에 적는가"의 문제이고, 베이스 클래스가 좁힘을 정의하면 둘 다 얻습니다. 파편화를 만든 건 `classes=`가 아니라 키를 가르는 축이 클래스마다 제각각인 것이었습니다. 같은 애플리케이션의 원본과 재구축본이 12클래스 12컨텍스트와 16클래스 2컨텍스트로 갈린 차이가 베이스 클래스 하나였습니다.

**넷째, 가장 좁힌 컨텍스트는 컨텍스트를 안 띄우는 것입니다.** 그리고 버릴 때는 **무엇을 못 보게 되는지 함께 적고 그 책임을 어디로 옮겼는지까지** 적어야 합니다. 다섯 파일에서 Spring을 걷어낸 커밋이 relaxed binding 검증 책임을 실제 yml을 로드하는 테스트 하나로 모은 것이 그 모습입니다.

**다섯째, 선언이 맞아도 런타임은 다를 수 있고, 그때 예외는 나지 않습니다.** `withReuse(true)`는 재사용하지 않고, `@ActiveProfiles`는 정렬하지 않습니다. 이런 결함은 단언의 문제가 아니라 구성의 문제입니다. 구성 자체를 단언하는 테스트가 있으면 일부는 걸리지만, 증상이 비용이나 인프라 오류로만 나타나는 나머지는 그마저도 비껴갑니다.

**여섯째, 캐시를 논하기 전에 캐시의 경계를 먼저 확인해야 합니다.** 컨텍스트 캐시는 JVM의 `static` 변수입니다. 빌드가 40개로 갈라진 저장소에서 "전체 몇 건"이라는 숫자는 처음부터 의미가 없었습니다.

## 컨텍스트를 띄우기 전에 물어볼 것

1편이 단언을 쓰기 전에 물어볼 목록으로 끝났으니, 이 편은 컨텍스트를 띄우기 전에 물어볼 목록으로 끝내겠습니다.

- **이 테스트가 확인하려는 것이 컨텍스트 구조 자체인가.** 빈의 존재나 부재, 두 빈이 같은 인스턴스인지, 기동 성공이나 실패라면 `@Autowired`로는 표현할 수 없습니다.
- **자동설정을 조합해 끌어오고 있는가.** 그렇다면 `@ContextConfiguration(classes=...)`처럼 선언 순서로 처리되는 방식으로 옮길 때, 컴파일과 테스트 통과만으로 안전하다고 판단하지 말고 실제 값까지 확인합니다.
- **이 클래스가 키를 가르는 축을 자기만 다르게 갖고 있지 않은가.** 프로파일 순서, mock 조합, `@TestPropertySource` 한 줄. 형제 클래스와 다르면 컨텍스트가 하나 더 뜹니다.
- **이 설정을 클래스에 적고 있는가, 베이스에 적고 있는가.** `@DynamicPropertySource`는 값이 아니라 메서드가 키라서, 같은 값을 클래스마다 적으면 컨텍스트가 그만큼 갈립니다.
- **이 프로퍼티는 검증을 만드는가, 검증을 대신하는가.** 대신하는 쪽이면 지우고 실제 설정 파일에서 읽습니다. 만드는 쪽이면 남기되 왜 yml과 다른지 주석으로 적습니다.
- **이 애노테이션이 약속한 것이 이 환경에서 실제로 켜지는가.** 코드 밖 설정에 달린 옵션이라면, 켜 둔 내 머신에서는 영원히 재현되지 않습니다.
- **애초에 컨텍스트가 필요한가.** 순수 자바 객체로 확인할 수 있다면 그게 가장 좁힌 컨텍스트입니다. 대신 그렇게 해서 못 보게 되는 것을 어디서 볼지 함께 정합니다.

이 글은 3부작의 2편입니다. 1편이 "기준은 있었는데 안 지켜졌다"였다면 이 편은 "그 기준이 실측에서 나왔다"입니다. 3편에서는 그 기준을 누가 지키게 하는가를 다루겠습니다.

[^skill]: 이 스킬 파일은 사내 문서가 아니라 필자가 GitHub 마켓플레이스로 배포하는 공개 하네스 플러그인의 일부라 원문을 그대로 옮긴다. `sr-harness` 0.23.0의 `skills/dev-testing-strategy/SKILL.md`다. `:19` "아래 세 신호 중 **하나라도 해당하면** `ApplicationContextRunner`(프로그래밍 방식). 셋 다 아니면 `@ExtendWith(SpringExtension.class)` + `@ContextConfiguration`/`@SpringBootTest(classes=...)` + `@Autowired`로 클래스당 컨텍스트 하나만 띄운다." `:21` 신호 1은 "프로퍼티 조합이 테스트 메서드마다 다르다", `:22` 신호 2는 "`AutoConfigurations.of(...)`로 여러 자동설정을 조합한다"이며 "특히 `BeanPostProcessor`를 등록하는 자동설정이 얽히면 조용히 깨진다(컴파일도 되고 다른 단언도 다 통과하는데 특정 값 하나만 예상과 달라지는 식이라 알아채기 어렵다)"가 붙어 있다. `:23` 신호 3은 "컨텍스트 구조 자체가 단언 대상이다"다. `:34` "**주의**: 신호 1(프로퍼티 공유 여부)만 기계적으로 확인하고 판단하지 않는다. 프로퍼티는 완전히 고정 공유하는데 신호 3에 걸려 있는 테스트를 신호 1만 보고 `@Autowired`로 옮기면 조용히 잘못된 선택이 된다." 이 공개 스킬은 사내 문서보다 하루 늦은 2026-08-10에 추가됐다(커밋 `b6e270e`). 출처: [SeokRae/sr-harness](https://github.com/SeokRae/sr-harness)
[^caching]: Spring Framework Reference, "Context Caching". 캐시 키를 이루는 파라미터를 열 개로 나열한다. `locations`, `classes`, `contextInitializerClasses`, `contextCustomizers`, `contextLoader`, `parent`, `activeProfiles`, `propertySourceDescriptors`, `propertySourceProperties`, `resourceBasePath`. `contextCustomizers` 항목에는 "this includes `@DynamicPropertySource` methods, bean overrides (such as `@TestBean`, `@MockitoBean`, `@MockitoSpyBean` etc.), as well as various features from Spring Boot's testing support"라는 설명이 붙는다. 캐시 크기: "The size of the context cache is bounded with a default maximum size of 32. Whenever the maximum size is reached, a least recently used (LRU) eviction policy is used to evict and close stale contexts. You can configure the maximum size from the command line or a build script by setting a JVM system property named `spring.test.context.cache.maxSize`." 캐시 범위: "The Spring TestContext framework stores application contexts in a static cache. This means that the context is literally stored in a `static` variable. In other words, if tests run in separate processes, the static cache is cleared between each test execution, which effectively disables the caching mechanism." 그리고 "To benefit from the caching mechanism, all tests must run within the same process or test suite." 출처: [Spring Framework Reference](https://docs.spring.io/spring-framework/reference/testing/testcontext-framework/ctx-management/caching.html)
[^mcc]: 로컬 Gradle 캐시의 sources jar를 풀어 `spring-test` 5.3.31(Boot 2.7.18 대응), 6.1.11, 6.2.9(실측 대상 모듈이 실제로 쓰는 버전. 실행 로그에서 확인)를 모두 대조했다. 본문의 `hashCode`는 6.1.11이며, 5.3.31은 `propertySourceDescriptors` 자리가 `Arrays.hashCode(this.propertySourceLocations)`라는 점만 다르고 나머지는 글자까지 같다. **Boot 2.7부터 3.5까지 캐시 키의 구조는 사실상 바뀌지 않았다.** 기본 크기와 축출 정책도 소스에 있다. `ContextCache.java:66,79`의 `int DEFAULT_MAX_CONTEXT_CACHE_SIZE = 32;`와 `String MAX_CONTEXT_CACHE_SIZE_PROPERTY_NAME = "spring.test.context.cache.maxSize";`, 그리고 `DefaultContextCache.java:307`의 `private class LruCache extends LinkedHashMap<MergedContextConfiguration, ApplicationContext>`와 `:320`의 `removeEldestEntry` 오버라이드다. 캐시가 static이라는 것도 `DefaultCacheAwareContextLoaderDelegate.java:68-71`에 `static final ContextCache defaultContextCache = new DefaultContextCache();`로 있다. `processActiveProfiles`는 5.3.31, 6.1.11, 6.2.9 세 버전이 모두 같은 코드다. 문서의 열 개 항목 중 `resourceBasePath`는 `MergedContextConfiguration`의 하위 타입인 `WebMergedContextConfiguration` 소관이라 본문 `hashCode`에는 나타나지 않는다.
[^lastwins]: Spring Boot Reference, "Externalized Configuration"의 Profile Specific Files 절. "If several profiles are specified, a last-wins strategy applies. For example, if profiles `prod,live` are specified by the `spring.profiles.active` property, values in `application-prod.properties` can be overridden by those in `application-live.properties`." 즉 프로파일 목록의 순서는 프로퍼티 우선순위를 결정하므로, 두 프로파일이 같은 키를 다르게 정의하면 순서에 따라 유효값이 달라진다. 출처: [Spring Boot Reference](https://docs.spring.io/spring-boot/reference/features/external-config.html)
[^dynprec]: Spring Framework Reference, "Context Configuration with Dynamic Property Sources". "Dynamic properties have higher precedence than those loaded from `@TestPropertySource`, the operating system's environment, Java system properties, or property sources added by the application declaratively by using `@PropertySource` or programmatically. Thus, dynamic properties can be used to selectively override properties loaded via `@TestPropertySource`, system property sources, and application property sources." 출처: [Spring Framework Reference](https://docs.spring.io/spring-framework/reference/testing/testcontext-framework/ctx-management/dynamic-property-sources.html)
[^mockito]: `spring-boot-test` 2.7.18의 `org/springframework/boot/test/mock/mockito/MockitoContextCustomizer`는 `private final Set<Definition> definitions;`를 갖고 `equals`와 `hashCode`를 모두 `this.definitions` 기준으로 구현한다. `Set`의 `equals`이므로 선언 순서는 키에 영향을 주지 않고, 어떤 타입을 mock하는지의 집합만 본다. 참고로 이 저장소는 `@MockBean` 259건에 `@MockitoBean` 1건으로 대부분 구 애노테이션을 쓴다. 유일한 `@MockitoBean`은 Boot 3.4.x 모듈의 베이스 클래스에 있다. 모듈마다 Spring Boot 버전이 2.7.x부터 3.5.x까지 공존하므로 이 저장소를 하나의 버전으로 서술할 수는 없다.
[^reuse]: Testcontainers for Java, "Reusable Containers (Experimental)". 문서는 사용 조건을 한 문장에 모아 둔다. "To use it, start the container manually by calling `start()` method, do not call `stop()` method directly or indirectly via `try-with-resources` or `JUnit integration`, and enable it manually through an opt-in mechanism per environment." 즉 컨테이너의 `withReuse(true)` 외에 수동 `start()`, `stop()` 미호출(`try-with-resources`와 JUnit 통합 포함), 환경별 opt-in이 함께 필요하다. 환경별 opt-in은 "Enable `Reusable Containers` through environment variable `TESTCONTAINERS_REUSE_ENABLE=true` through user property file `~/.testcontainers.properties`, by adding `testcontainers.reuse.enable=true`"로 안내된다. CI 부적합은 "Reusable containers are not suited for CI usage and as an experimental feature not all Testcontainers features are fully working (e.g., resource cleanup or networking)."라는 문장의 앞부분이다. 사내 교정 커밋의 서술을 이 문서로 독립 확인했다. 출처: [java.testcontainers.org](https://java.testcontainers.org/features/reuse/)
[^async]: `@Async`에 이름을 주면 `AsyncExecutionAspectSupport.determineAsyncExecutor`가 `findQualifiedExecutor`로 내려가고, 그것이 `BeanFactoryAnnotationUtils.qualifiedBeanOfType(beanFactory, Executor.class, qualifier)`를 호출한다. 일치하는 빈이 없으면 `NoSuchBeanDefinitionException`을 던진다(`spring-beans` 6.2.9 `BeanFactoryAnnotationUtils.java:137-138`). `findQualifiedExecutor`는 5.3.31과 6.2.9가 같은 코드다. 이름을 **주지 않은** `@Async`는 경로가 다르다. 그쪽은 `AsyncExecutionAspectSupport.getDefaultExecutor`가 로그를 남기며 후보를 찾고, 끝내 못 찾으면 `AsyncExecutionInterceptor.getDefaultExecutor`가 `new SimpleAsyncTaskExecutor()`로 폴백한다(`spring-aop` 6.2.9 `AsyncExecutionAspectSupport.java:238` 이하와 `AsyncExecutionInterceptor.java:158-161`). "지정한 이름을 못 찾으면 경고 후 기본 executor로 폴백한다"는 흔한 서술은 이 두 경로를 섞은 것이다. 그리고 이름을 못 찾는 경우든 찾는 경우든 executor 해석은 `determineAsyncExecutor`가 호출되는 시점, 즉 그 메서드를 실제로 부를 때 일어나므로 컨텍스트 기동은 영향받지 않는다.
[^sbta]: `spring-boot-test` 3.5.4의 `org/springframework/boot/test/context/SpringBootTestAnnotation.java`가 갖는 필드는 `args`, `webEnvironment`, `useMainMethod` 셋이고 `equals`와 `hashCode`도 이 셋만 본다. `@SpringBootTest(properties = ...)`는 이 커스터마이저가 아니라 `SpringBootTestContextBootstrapper.processPropertySourceProperties`를 거쳐 `propertySourceProperties` 앞쪽에 실린다. 같은 메서드가 `webEnvironment`를 프로퍼티로도 번역해서, `RANDOM_PORT`면 `server.port=0`을, `NONE`이면 `spring.main.web-application-type=none`을 덧붙인다. 그래서 `webEnvironment`는 커스터마이저와 `propertySourceProperties` 양쪽에 흔적을 남긴다.
[^count]: 파서를 새로 작성해 `src/test/java` 아래 `.java` 파일을 전부 읽고, 클래스 레벨 애노테이션과 `extends` 상속 체인을 합쳐 키 튜플(`@SpringBootTest` 인자, `@ContextConfiguration` 인자, 슬라이스 애노테이션, `@ActiveProfiles`, `@TestPropertySource`, `@Import`, `@AutoConfigure*` 목록, mock 타입 집합, `@DynamicPropertySource` 존재 여부, `@EnableAutoConfiguration`)을 만든 뒤 모듈 단위로 중복을 셌다. 추상 베이스는 실행되지 않으므로 제외했다. 결과는 구체 클래스 892개에 서로 다른 키 213개이며 40개 Gradle 프로젝트에 분산돼 있다. **이 값은 하한이다.** 실행 로그에서 확인한 커스터마이저 12개를 파서가 재현하지 못하고, 중첩 `@TestConfiguration`이 `classes` 배열에 더해지는 방식과 `@AutoConfigure*`가 만드는 property source의 세부값도 반영하지 못한다. 실제 컨텍스트 수는 이보다 크거나 같다. 재현하려는 사람을 위해 함정을 하나 적어 둔다. 클래스 선언 앞을 `}` 기준으로 자르면 `@SpringBootTest(classes = {A.class, B.class})`의 `}`에 걸려 애노테이션을 통째로 놓친다. 선언 위치에서 뒤로 훑으며 짝이 맞는 괄호를 찾아야 한다. 이 버그를 고친 뒤 대상 클래스가 775개에서 892개로 늘었다.
[^measure]: 대상은 Spring Boot 3.5.4 / Spring Framework 6.2.9를 쓰는 모듈 하나다(실행 로그의 "Running with Spring Boot v3.5.4, Spring v6.2.9"로 확인). `org.springframework.test.context.cache` 로거를 DEBUG로 올리면 `DefaultContextCache.logStatistics()`가 매 컨텍스트 요청마다 `size / maxSize / hitCount / missCount / failureCount`를 찍는다. 저장소를 수정하지 않기 위해 Gradle init script로 테스트 JVM에만 `systemProperty 'logback.configurationFile'`과 `systemProperty 'logging.level.org.springframework.test.context.cache', 'DEBUG'`를 함께 주입했다. 본문에 적은 함정 때문에 **두 프로퍼티를 모두 줘야 한다.** 공통 지원 패키지 24개 클래스 부분 실행은 BUILD SUCCESSFUL이었고 통계는 `size = 10, maxSize = 32, parentContextCount = 0, hitCount = 914, missCount = 10, failureCount = 0`이다. ⚠️ 같은 모듈의 **전체 실행은 이 환경에서 413건 중 17건이 실패**했는데, 같은 클래스들이 부분 실행에서는 전부 통과했다. 오프라인 의존성 부족으로 인한 `ClassNotFoundException`과 git에 실값이 없는 프로퍼티가 원인으로 보이지만 완전히 규명하지 못했다. **저장소가 원래 깨져 있다고도, 완전히 안정적이라고도 단정할 수 없다.** 그래서 본문에는 깨끗한 부분 실행 수치만 실었다. 또한 이 모듈에는 `forkEvery`나 `maxParallelForks` 설정이 없어 단일 JVM이었고 캐시 인스턴스도 하나였다(로그의 `DefaultContextCache@` 해시가 하나). 다른 모듈이 포크를 나눠 쓴다면 캐시는 더 잘게 쪼개지므로 "모듈당 캐시 하나"로 일반화할 수 없다.
