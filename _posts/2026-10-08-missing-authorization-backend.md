---
layout: post
date: 2026-10-08
title: "아무도 선언하지 않은 경로는 마지막 한 줄을 따른다"
subtitle: "따릉이 사건이 말하는 '기본'을 Spring Security 설정과 테스트의 말로 옮기기"
tags: [보안, Spring, 테스트]
---

2026년 가을, 금융권 개인정보 유출이 연달아 보도되고 있습니다. 2026년 10월 1일 한국일보 보도에 따르면, 신한은행은 "외부의 비인가자가 인증을 우회하는 비정상적인 방법으로 일부 서비스에 접근해 고객의 개인정보를 유출한 사실을 확인했다"고 밝혔습니다. 공격은 대출 모집인에게 제공하는 모바일 웹페이지에서 시작됐고, 거기서 얻은 고객 번호로 연락처와 생년월일을 조회할 수 있는 다른 서비스에 접근한 것으로 전해졌습니다. 같은 보도는 "로그인 인증이 필요한 뱅킹 서비스가 해킹된 것은 아닌 것으로 전해졌다"고 덧붙였습니다.[^hankook] 뚫린 곳이 핵심 시스템이 아니라 그 주변의 조회 서비스였다는 이야기입니다. 보도 1주일 차라 세부는 더 바뀔 수 있습니다.

이 사고들을 두고 널널한 개발자 TV의 영상 「예상 면접질문: 따릉이와 금융권 AI 해킹사고 어떻게 막을 수 있을까?」는 AI가 부각되는 것과 달리 원인은 다른 데 있다고 짚습니다.[^video] 영상의 요지는 AI가 기법을 새로 만든 게 아니라 공격을 자동화해 범위를 넓혔을 뿐이고, 사고의 뿌리는 기본적인 접근 통제가 빠진 데 있다는 것입니다. 영상은 그 예로 서울시 공공자전거 따릉이의 개인정보 유출을 듭니다.

AI에 대한 이 판단은 공적 기관의 평가와도 겹칩니다. 영국 NCSC는 2027년까지 AI가 "rather than creating novel threat vectors", 기존 기법을 다듬는 방식으로 침입의 양과 영향을 늘릴 가능성이 높다고 봤습니다.[^ncsc] 다만 "범위만 넓어졌다"를 "새로울 게 없다"로 읽으면 놓치는 것이 있어요. Carlini 등은 LLM이 사용자 수백만 명짜리 제품의 어려운 버그 하나를 찾는 대신 "find thousands of easy-to-identify bugs in products with thousands of users"할 수 있게 되면서 공격의 경제학이 바뀐다고 썼습니다.[^carlini] 사용자가 적어 털 가치가 없던 시스템의 쉬운 버그가, 찾는 비용이 내려가면 털 가치를 갖게 됩니다. 기본이 빠진 엔드포인트는 예전에도 위험했지만, 이제는 찾아질 확률이 다릅니다.

먼저 따릉이의 공개 기록을 정확히 옮깁니다. 2024년 6월 28일부터 29일 사이 따릉이 서버에서 가입자 462만 건의 정보를 빼낸 혐의로, 당시 중학생이던 10대 2명이 2026년 2월 송치됐습니다. 사건은 경찰이 다른 DDoS 사건 피의자의 압수물을 분석하다 드러났습니다.[^newsis0223] 취약점에 대한 조사 결과는 이렇게 보도됐습니다.

> 이들은 가입자 정보 조회 시 필요한 최소한의 '인증 토큰' 검증 절차조차 없어, 특정 호출만 하면 서버가 무방비로 정보를 응답하는 허점을 파고든 것으로 조사됐다.

같은 기사에서 서울경찰청 관계자는 "가입자 인증을 거쳐야 정보를 받아 오는 구조여야 하는데 그런 절차가 없어 미비했다"고 설명했습니다.

영상은 이 장면을 관리자용 API를 누구나 호출해 응답을 받을 수 있었던 일로 설명합니다. 그런데 경찰 설명에는 '관리자'라는 단어가 없습니다. 공개 기록이 확정하는 것은 **인증 토큰 검증 없이 조회 호출이 응답했다**는 데까지이고, 관리자 권한이라는 표현은 2026년 3월 서울시의회 상임위원회에서 나온 한 시의원의 발언 보도에서만 확인됩니다.[^seoul] 공식 조사로 "관리자 API"가 확인된 적은 없습니다. 호출된 엔드포인트가 관리자 기능이었는지, 일반 회원 조회 API에 남의 식별자를 넣은 것이었는지도 공개되지 않았습니다.

그렇다고 영상의 진단이 빗나간 것은 아닙니다. 인증이 없었다는 것과 인가가 없었다는 것은 원인 자리가 같고, 표준 문서들도 둘을 같은 자리에 놓습니다. OWASP Top 10의 A01 Broken Access Control은 2021판과 2025판 모두 한 시나리오 안에 "If an unauthenticated user can access either page, it's a flaw. If a non-admin can access the admin page, this is a flaw."라고 씁니다.[^a01] OWASP API Security Top 10 2023의 API5(Broken Function Level Authorization)는 공격자를 "as anonymous users or regular, non-privileged users"로 적어 익명 사용자를 위협 주체에 넣습니다.[^api5] 경찰 설명에 가장 가까운 분류인 CWE-306(Missing Authentication for Critical Function)은 대책 항목에서 웹에서는 인증과 인가의 경계가 흐려진다고 하면서, 직접 만든 인증 루틴은 "must be applied to every single page, since these pages could be requested directly"라고 적습니다.[^cwe306]

세 문장이 가리키는 곳은 하나입니다. 인증이든 인가든, **이 경로에 어떤 정책이 걸려 있는지 아무도 선언하지 않았다**는 것입니다. 영상이 "기본"이라고 부른 것을 코드의 말로 옮기면 이 문장이 된다고 저는 봅니다. 이 글의 본론은 그중 인가입니다. 인증은 대개 필터 한 곳에서 걸리지만, 인가는 기능마다 선언해야 해서 빠지기 쉽기 때문입니다.

선언하지 않은 경로에서 무슨 일이 일어나는지는 프레임워크의 기본값과 설정의 마지막 한 줄이 정합니다. 그 자리를 **기본 허용**이라는 이름으로 먼저 봅니다. 선언이 빠졌다는 사실은 사람의 기억으로는 잡히지 않고, 실제 경로 목록을 정책 표와 맞대야 드러납니다. 이 블로그의 계약 테스트에서 겪은 일과 함께 이것을 **목록 대조**로 이어 갑니다. 끝으로, DDoS 판단과 레이트 리미터가 왜 이 빈자리를 메우지 못하는지를 **누가 무엇을 읽는가**로 정리합니다.

> 기준 판본은 Spring Boot 3.5.16, Spring Security 6.5.11, Spring Framework 6.2.19입니다. Spring 소스와 문서는 태그 고정 원본에서 원문 그대로 옮기고 `[원문]`과 위치를 답니다. `예시`라고 적은 코드는 제가 쓴 것이고, 이 판본으로 MockMvc 최소 예제를 만들어 직접 돌린 결과를 함께 적었습니다. 영상 내용은 요지로만 옮깁니다.

## 기본 허용

인증과 인가는 같은 필터 체인 위에 있지만 선언되는 방식이 다릅니다. 인증은 "이 요청을 보낸 게 누구인가"라서 모든 요청에 같은 질문을 던질 수 있고, 그래서 필터 하나로 끝납니다. 인가는 "이 사람이 이 기능을 써도 되는가"라서 기능의 의미를 알아야 답할 수 있습니다. 회원 목록 내보내기가 관리자 기능이라는 사실은 URL에도 HTTP 메서드에도 적혀 있지 않거든요. API5가 "Don't assume that an API endpoint is regular or administrative only based on the URL path."라고 굳이 적어 둔 이유입니다.

의미를 아는 사람이 기능마다 선언해야 하니 선언은 엔드포인트 수만큼 흩어지고, 흩어진 선언은 언젠가 하나쯤 빠집니다. 이 절의 질문은 그 빠진 자리를 무엇이 채우느냐입니다.

### 6.0이 바꾼 기본값

Spring Security는 이 질문의 답을 한 번 뒤집었습니다. 5.8 마이그레이션 가이드의 원문입니다.[^sec58]

> In Spring Security 5.8 and earlier, requests with no authorization rule are permitted by default.
> It is a stronger security position to deny by default, thus requiring that authorization rules be clearly defined for every endpoint.
> As such, in 6.0, Spring Security by default denies any request that is missing an authorization rule.

소스에서는 한 줄 차이입니다. `authorizeHttpRequests`의 규칙을 들고 있는 `RequestMatcherDelegatingAuthorizationManager`가 어떤 매처에도 맞지 않는 요청을 만났을 때 돌려주는 값이 `null`에서 `DENY`로 바뀌었습니다.

```java
// [원문] spring-security 5.8.0, RequestMatcherDelegatingAuthorizationManager.java:85-86
this.logger.trace("Abstaining since did not find matching RequestMatcher");
return null;
```

```java
// [원문] spring-security 6.5.11, RequestMatcherDelegatingAuthorizationManager.java:94-97
if (this.logger.isTraceEnabled()) {
	this.logger.trace(LogMessage.of(() -> "Denying request since did not find matching RequestMatcher"));
}
return DENY;
```

`AuthorizationFilter`는 `null`을 받으면 예외 없이 다음 필터로 넘깁니다. 그래서 5.8까지는 "규칙 없음"이 곧 "통과"였습니다. 6.x 안에서도 레거시 `authorizeRequests()`는 미매칭 요청을 그대로 통과시킵니다(6.1부터 deprecated, 7.0에서 제거). Spring Security 5.x를 쓰는 Boot 2 모듈과 6.x를 쓰는 Boot 3 모듈이 한 조직에 섞여 있다면, 같은 설정 습관이 모듈마다 반대 결과를 낼 수 있습니다. [레이트리미터 편]({{ site.baseurl }}/2026/08/09/rate-limiter-payment-platform.html)에서 "라이브러리 기본값이 곧 정책이니까요."라고 쓴 문장이 여기서 다시 돌아옵니다.

### 기본 거부를 되돌리는 마지막 한 줄

그런데 6.0의 암묵적 거부가 실제로 작동하는 경우는 생각보다 좁습니다. 미매칭 요청이 생기려면 `anyRequest()`가 없어야 하니까요. `anyRequest()`를 쓰는 순간 미매칭은 사라지고, 나머지 전부의 정책은 그 줄이 정합니다. Spring이 스스로 보여 주는 마지막 줄은 대개 `denyAll()`이 아니라 `authenticated()`입니다. Boot의 기본 체인, Spring Security의 예외 메시지, 레퍼런스 문서의 첫 예시가 모두 그 줄입니다.

```java
// [원문] spring-boot v3.5.16, SpringBootWebSecurityConfiguration.java:58
http.authorizeHttpRequests((requests) -> requests.anyRequest().authenticated());
```

- 위는 커스텀 `SecurityFilterChain`이 없을 때 Boot가 등록하는 기본 체인입니다
- 규칙을 하나도 매핑하지 않으면 Spring Security가 던지는 예외 메시지는 `"At least one mapping is required (for example, authorizeHttpRequests().anyRequest().authenticated())"`입니다(`AuthorizeHttpRequestsConfigurer.java` 6.5.11 L170)
- 레퍼런스 문서가 "Whenever you have an `HttpSecurity` instance, you should at least do:"라며 보여 주는 첫 예시도 `.anyRequest().authenticated()`입니다[^authz-doc]

이 줄이 있으면 선언하지 않은 모든 엔드포인트는 "로그인하면 허용"이 됩니다. 최소 예제로 확인했습니다. 컨트롤러에 `/me`와 `/admin/users`를 두고, 나중에 추가된 관리자성 기능 `/internal/members/export`를 `/admin` 밖에 둔 뒤, `ROLE_USER` 사용자로 호출했습니다.

| 체인 설정 | USER의 `GET /internal/members/export` |
|---|---|
| Boot 기본 체인 (`anyRequest().authenticated()` 한 줄) | 200 |
| `/admin/**`는 `hasRole("ADMIN")`, 마지막 줄 `anyRequest().authenticated()` | 200 |
| `/admin/**`와 `/me`만 선언, `anyRequest()` 없음 | 403 |
| 마지막 줄 `anyRequest().denyAll()` | 403 |

Boot 기본 체인에서는 `/admin/users`도 USER에게 200이었습니다. 역할이라는 개념이 아예 없는 체인이니 당연한 결과지만, 커스텀 체인을 만들기 전까지는 모든 엔드포인트가 이 상태입니다.

문서가 권하는 쪽은 분명합니다. 같은 레퍼런스의 TIP은 "Denying the request by default is a healthy security practice since it turns the set of rules into an allow list."라고 쓰고, `.anyRequest().denyAll()`에 붙은 설명은 "This is a good strategy if you do not want to accidentally forget to update your authorization rules."입니다. 다만 `authenticated()`로 끝낸 설정이 로그인한 누구에게나 관리자 기능을 연다고 직접 경고하는 문장은 6.5.11 레퍼런스에 없습니다. 권장은 있는데, 가장 먼저 보이는 예시는 그 권장과 다른 줄인 셈이에요.

**선언하지 않은 엔드포인트의 정책은 프레임워크 기본값이 아니라 마지막 catch-all 한 줄이 정합니다.** `authenticated()`는 "나머지는 로그인한 사람 누구에게나"라는 정책을 고른 것이고, 그 나머지에 관리자 기능이 하나라도 섞이면 그 기능은 회원 전원에게 열립니다.

### 메서드 보안이 기대는 안전망

엔드포인트마다 `@PreAuthorize`를 붙이는 팀이라면 URL 규칙의 마지막 줄을 덜 신경 쓸지도 모릅니다. 그런데 메서드 보안 문서는 그 빈틈의 안전망을 다시 URL 규칙에 걸어 둡니다.[^method-doc]

> It’s important to remember that when you use annotation-based Method Security, then unannotated methods are not secured. To protect against this, declare a catch-all authorization rule in your HttpSecurity instance.

이 문장의 "a catch-all authorization rule"은 링크이고, 링크가 가리키는 앵커 `#activate-request-security`의 예시가 바로 앞에서 본 `.anyRequest().authenticated()`입니다. 메서드 보안이 안전망으로 가리킨 규칙의 예시가 로그인만 확인하는 줄이라, 애노테이션을 빠뜨린 관리자 메서드는 그 안전망에 떨어져 로그인한 누구에게나 열립니다.

여기에 기본값 하나가 더 겹칩니다. 같은 문서는 "Spring Boot Starter Security does not activate method-level authorization by default."라고 씁니다. `@EnableMethodSecurity`를 선언하지 않으면 `@PreAuthorize`는 붙어 있어도 아무 일도 하지 않습니다. 최소 예제에서 `@PreAuthorize("hasRole('ADMIN')")`가 붙은 `/reports/sales`를 USER로 호출하면, `@EnableMethodSecurity`가 없을 때 200, 있을 때 403이었습니다. 켠 상태에서도 애노테이션이 없는 `/internal/members/export`는 200이었고요. 메서드 보안은 켠 곳에서, 붙인 메서드만 지킵니다.

### 이 블로그의 차단 목록

이 블로그도 같은 모양으로 한 번 사고를 냈습니다. Jekyll은 `_config.yml`의 `exclude`에 **없는** 파일을 전부 발행합니다. 목록이 차단 목록이라, 새로 생긴 디렉터리는 아무도 결정하지 않았는데 공개됩니다. 계약 테스트 파일이 라이브 사이트에 그대로 발행되던 문제를 2026년 7월 #18에서 고쳤고, 그 수정도 목록에 `test` 한 줄을 더한 것이었습니다.

```yaml
# [원문] _config.yml:70-77
exclude:
  - Gemfile
  - Gemfile.lock
  - vendor
  - README.md
  - LICENSE
  - CLAUDE.md
  - test
```

이 사건의 다른 면, 검사기가 자기 최적화 때문에 자기를 못 봤다는 이야기는 [테스트 기준 3편]({{ site.baseurl }}/2026/08/11/test-standards-3-delegating-standards.html)에서 다뤘습니다. 여기서 보태는 것은 목록의 방향입니다. 차단 목록은 내가 떠올린 것만 막고, 떠올리지 못한 새 항목은 기본으로 열어 둡니다. Spring 문서가 기본 거부를 권하면서 쓴 "turns the set of rules into an allow list"의 정확히 반대편이에요.

**인가는 선언한 곳에만 있습니다. 선언하지 않은 경로의 정책은 이미 누군가 골라 두었고, 그 누군가는 대개 설정의 마지막 한 줄입니다.**

## 목록 대조

선언이 빠진다는 문제에 흔히 내놓는 답은 엔드포인트를 추가할 때마다 그 엔드포인트의 인가 테스트를 하나씩 쓰는 것입니다. 이 답은 테스트를 쓰는 사람이 그 엔드포인트를 기억할 때만 작동합니다. 선언을 빠뜨린 바로 그 순간에는 테스트도 같이 빠지죠. 영상이 읽기를 권한 행정안전부와 한국인터넷진흥원의 「소프트웨어 개발보안 가이드」는 '부적절한 인가'를 이렇게 설명합니다.[^kisa]

> 프로그램이 모든 가능한 실행경로에 대해서 접근제어를 검사하지 않거나 불완전하게 검사하는 경우, 공격자는 접근 가능한 실행경로로 정보를 유출할 수 있다.

어려운 것은 '모든'입니다. 모든 실행경로를 누가 세는가. [장애 대응 편]({{ site.baseurl }}/2026/07/24/incident-response-pipeline.html)에 쓴 문장대로 "사람의 주의력 향상에 기대는 대책은 대책이 아니다." 이 절은 세는 일을 사람의 기억에서 떼어 내는 이야기입니다.

### 기억에 묶인 계약 테스트

이 블로그에도 같은 모양의 테스트가 있었습니다. `CLAUDE.md`는 "외부 요청 없는 페이지"를 사이트 계약으로 들고 "이 계약들은 **`test/site_output_test.rb`에 잠겨 있다.**"라고 적습니다. [테스트 기준 1편]({{ site.baseurl }}/2026/08/11/test-standards-1-what-to-test.html)은 이 파일의 외부 요청 부정 단언을 의도적으로 지킨 계약의 예로 들었습니다. 단언 하나하나는 그 평가대로 단단했습니다. 이번에 들여다본 것은 단언의 강도가 아니라 **단언이 걸린 범위**입니다.

외부 스타일시트와 스크립트를 막는 부정 단언은 페이지를 이름으로 골라 걸려 있었습니다. 홈과 검색, 그리고 본문에 임베드가 있는 글 네 편까지 모두 여섯 페이지였습니다. 임베드 글이 들어올 때마다 그 글 전용 단언을 손으로 더했고(#36, #82, #111, #115), 네 번 다 기억해서 넣었습니다. 다섯 번째를 잊으면 아무것도 실패하지 않습니다. 실제로 `about.md` 끝에 외부 스크립트 한 줄을 붙이고 돌린 결과입니다.

```
1 runs, 181 assertions, 0 failures, 0 errors, 0 skips
```

엔드포인트마다 인가 테스트를 하나씩 쓰는 팀처럼, 테스트가 목록이 아니라 기억에 묶여 있었습니다. 그래서 #125에서 페이지별 단언 10개를 지우고, 빌드된 HTML 전체를 훑는 단언 하나로 바꿨습니다(PR #126). 작업 시점에 실제 사이트가 발행하던 HTML은 18개였고, 그동안 이름으로 검사하던 것은 그중 6개였습니다.

```ruby
# [원문] test/site_output_test.rb:187-209 (#126)
# 외부 요청 0 계약을 페이지 이름으로 골라 걸면, 임베드 글이 생길 때마다 단언을 손으로 더해야
# 하고 잊어도 아무것도 실패하지 않는다. 그래서 생성된 HTML 전체를 훑는다. (#125)
# 새 글에 외부 요청 단언을 따로 추가할 필요는 없다.
def assert_no_external_requests(destination, source)
  pages = Dir.glob(File.join(destination, "**", "*.html"))
  posts = Dir.glob(File.join(source, "_posts", "*.md"))
  # glob이 비면 아래 단언은 아무것도 검사하지 않고 통과한다.
  assert_operator pages.size, :>=, posts.size, "훑은 HTML이 원본 포스트 수보다 적다"

  external = %r{\A["']?(?:https?:)?//}i
  # canonical처럼 주소만 적는 link는 요청이 아니다. 리소스를 받아 오는 rel이거나 .css일 때만 본다.
  fetching = /\brel=["']?[^"'>]*\b(?:stylesheet|preload|modulepreload|prefetch|icon)\b/i
  violations = pages.flat_map do |page|
    html = File.read(page)
    links = html.scan(/<link\b[^>]*>/i).select do |tag|
      href = tag[/\bhref=(\S+)/i, 1]
      href&.match?(external) && (tag.match?(fetching) || href.match?(/\.css\b/i))
    end
    scripts = html.scan(/<script\b[^>]*>/i).select { |tag| tag[/\bsrc=(\S+)/i, 1]&.match?(external) }
    (links + scripts).map { |tag| "#{page.delete_prefix("#{destination}/")}: #{tag}" }
  end
  assert_empty violations, "외부 스타일시트나 스크립트를 받는 페이지가 있다"
end
```

일부러 깨뜨려 봤습니다. about에 외부 스크립트를, Chirpy 편에 프로토콜 상대 주소의 스타일시트를, 404에 `rel="preload"`로 받는 외부 CSS를 넣었더니 세 곳이 한 번에 걸렸습니다.

```
외부 스타일시트나 스크립트를 받는 페이지가 있다.
Expected ["2026/07/13/chirpy-to-type-theme.html: <link rel=\"stylesheet\" href=\"//cdn.example.com/injected.css\" />", "404.html: <link rel=\"preload\" as=\"style\" href=\"https://cdn.example.com/preloaded.css\" />", "about/index.html: <script src=\"https://example.com/injected.js\">"] to be empty.
```

이 단언은 위험한 자리를 하나 새로 만듭니다. `Dir.glob`이 아무것도 찾지 못하면 위반 목록도 비고, 빈 목록은 `assert_empty`를 그대로 통과합니다. 1편 체크리스트의 "**부정 단언이라면, 틀린 이유로 통과할 경로가 몇 개인가.**"가 걸리는 자리라, 훑은 HTML 수가 원본 포스트 수 이상인지부터 단언했습니다.

작업 중에 하나가 더 걸렸습니다. 첫 구현은 `rel="stylesheet"`인 link만 봤는데, 지운 단언 중 홈에 걸려 있던 것은 rel과 무관하게 외부 `.css` 주소를 잡고 있었습니다.

```ruby
# [원문] test/site_output_test.rb:75 (main, #125 이전)
refute_match(%r{<link[^>]*\shref="https?://[^"]*\.css}, index, "외부 스타일시트를 받으면 안 된다")
```

단언 열 개를 하나로 합치면서 그중 하나가 보던 범위를 잃을 뻔했고, 커밋 전에 지운 단언들과 하나씩 대조해 되살렸습니다. 흩어진 단언을 목록 하나로 합칠 때, 새 단언은 지운 단언들이 보던 범위의 합집합을 덮어야 합니다. 합치는 작업 자체에도 대조가 필요했습니다.

### 경로 목록과 정책 표

같은 전환을 Spring 엔드포인트에 적용해 봅니다. 실제 매핑 목록은 `RequestMappingHandlerMapping`이 들고 있고, `getHandlerMethods()`의 Javadoc은 "Return a (read-only) map with all mappings and HandlerMethod's."입니다.[^handler] 이 목록을 정책 표와 대조하면, 정책을 선언하지 않은 엔드포인트가 생기는 순간 누가 기억하든 말든 테스트가 실패합니다.

```java
// 예시: 필자가 쓴 목록 대조 테스트. Spring Boot 3.5.16에서 실행했다
@SpringBootTest
@AutoConfigureMockMvc
class EndpointPolicyInventoryTest {

    enum Policy { PUBLIC, AUTHENTICATED, ADMIN }

    // 정책 표. 공개 엔드포인트도 PUBLIC으로 적는다.
    static final Map<String, Policy> POLICIES = Map.of(
            "GET /notices", Policy.PUBLIC,
            "* /error", Policy.PUBLIC,
            "GET /me", Policy.AUTHENTICATED,
            "GET /admin/users", Policy.ADMIN,
            "POST /admin/users/{id}/lock", Policy.ADMIN,
            "GET /reports/sales", Policy.ADMIN);

    @Autowired
    @Qualifier("requestMappingHandlerMapping")
    RequestMappingHandlerMapping mapping;

    @Autowired MockMvc mvc;

    @Test
    void 정책을_선언하지_않은_엔드포인트가_없다() {
        Set<String> actual = new TreeSet<>();
        mapping.getHandlerMethods().keySet().forEach(info -> {
            var methods = info.getMethodsCondition().getMethods();
            for (String path : info.getPatternValues()) {
                if (methods.isEmpty()) actual.add("* " + path);
                else methods.forEach(m -> actual.add(m + " " + path));
            }
        });
        assertThat(actual).as("정책 표에 없는 엔드포인트").isSubsetOf(POLICIES.keySet());
    }

    // 체인 설정(@TestConfiguration)과 짝 테스트는 아래에 따로 싣는다
}
```

정책 표에 없는 `/internal/members/export`를 컨트롤러에 일부러 남겨 두고 돌렸습니다. 테스트 기준 3편의 체크리스트 "**이 게이트가 실제로 빨간불이 된 적이 있는가.**"를 그대로 따른 것입니다. 실패 메시지는 이렇게 끝납니다.

```
but found these extra elements:
  ["GET /internal/members/export"]
```

표를 처음 채우면서 눈여겨본 줄이 있습니다. 먼저 `* /error` 줄입니다. 저는 `/error`를 만든 적이 없습니다. Spring Boot의 `BasicErrorController`가 등록한 매핑인데, 목록에는 내가 쓴 컨트롤러와 똑같이 올라옵니다. 대조 테스트를 처음 돌리면 이렇게 내가 만들지 않은 경로부터 드러납니다.

그리고 `PUBLIC` 줄입니다. 공개 엔드포인트도 표에 적어야 통과하니, "아무 정책도 없음"과 "공개로 결정함"이 비로소 구분됩니다.

공개 프로젝트에도 같은 설계가 있습니다. 뮌헨공대(TUM)의 오픈소스 프로젝트 Artemis는 ArchUnit 규칙으로 모든 REST 엔드포인트에 인가 애노테이션을 요구하고, 그 이유를 이렇게 적습니다.[^artemis]

> every REST endpoint must declare an Artemis authorization annotation (or be covered by class-level enforcement) so authorization cannot be forgotten

진짜 공개 엔드포인트에는 `@EnforceNothing`을 붙이게 해서, 애노테이션이 없는 상태 자체를 실패로 만듭니다. 애노테이션 없이 인가하는 기존 엔드포인트 몇 개는 예외 목록으로 남겨 두되, 그 목록의 주석에 "so this set can only shrink."라고 적어 목록이 늘지 못하게 했습니다.

테스트 기준 1편의 결론 중 하나가 "목표치보다 제외 규칙이 더 많은 판단을 담고 있었습니다."였습니다. 목록 대조에서도 판단은 `ADMIN` 줄보다 `PUBLIC` 줄에 모입니다. 정책 표의 진짜 명세는 공개 예외 목록이고, 리뷰에서 가장 오래 봐야 할 줄도 거기입니다.

### 목록이 못 보는 경로

`getHandlerMethods()`가 돌려주는 것은 그 빈 하나에 등록된 `@RequestMapping` 핸들러뿐입니다. 최소 예제의 컨텍스트에는 `HandlerMapping` 빈이 아홉 개 있었고, 목록 대조가 읽은 것은 그중 하나였습니다. 목록 밖에 남는 경로는 이런 것들입니다.

- 액추에이터: `webEndpointServletHandlerMapping`, `controllerEndpointHandlerMapping` 같은 별도 빈이 맡습니다. 예제의 목록에도 `/actuator/health`는 없었습니다
- 함수형 라우트: `routerFunctionMapping`
- 정적 리소스: `resourceHandlerMapping`
- 필터가 직접 응답하는 경로: `/logout`처럼 `AuthorizationFilter`보다 앞의 필터가 처리하는 경로
- `DispatcherServlet` 바깥에 따로 등록한 서블릿

액추에이터는 특히 조심해야 합니다. Boot 3.5 문서는 커스텀 `SecurityFilterChain`을 정의하면 "Spring Boot auto-configuration backs off and lets you fully control the actuator access rules."라고 씁니다.[^actuator] 체인을 직접 만드는 순간 액추에이터 접근 규칙도 내 몫이 되는데, 그 경로는 목록 대조 테스트에 나타나지 않습니다. Artemis의 같은 테스트 파일도 `/management/**`를 두고 "no annotated handler serves the actuator endpoints"라는 이유를 달아 따로 다룹니다.

규칙은 내가 쓴 것에만 걸립니다. 이 블로그의 `CLAUDE.md`에도 "`_config.yml`의 `exclude`는 **이 저장소의 파일에만 먹고 테마 fall-through 파일에는 안 먹는다** (실험으로 확인)"라는 기록이 남아 있어요.

그래서 목록 대조는 두 겹이어야 합니다. 테스트 쪽에서는 목록이 못 보는 집단을 테스트 옆에 적어 둡니다. 3편 체크리스트의 "**그 검사기가 못 보는 집단은 무엇인가.**"를 테스트 주석으로 옮기는 일입니다. 런타임 쪽에서는 체인의 마지막 줄을 `denyAll()`로 둡니다.

```java
// 예시: 위 테스트 클래스의 @TestConfiguration에 둔 체인
http.authorizeHttpRequests(a -> a
        .requestMatchers("/notices", "/error").permitAll()
        .requestMatchers("/me").authenticated()
        .requestMatchers("/admin/**", "/reports/**").hasRole("ADMIN")
        .anyRequest().denyAll())
    .httpBasic(withDefaults());
```

이렇게 두면 목록 밖의 경로도 선언이 없으면 거부로 떨어집니다. 마지막 줄을 `denyAll()`로 둔 예제에서는 USER의 `/actuator/health`도 403이었고, 필요한 액추에이터 경로는 그때 명시적으로 열면 됩니다. 목록이 놓친 경로를 열린 채로 지나치는 대신 닫힌 채로 발견하게 만드는 것, 마지막 줄이 할 수 있는 일은 거기까지입니다.

**엔드포인트마다 테스트를 하나씩 쓰면 테스트도 사람의 기억에 묶입니다.** 실제 경로 목록을 정책 표와 대조하면 "선언하지 않음"이 곧 실패가 되고, 그때 진짜 명세는 공개 예외 목록입니다. 목록이 못 보는 경로는 목록 옆에 적고, 마지막 줄의 `denyAll()`로 받습니다.

### 틀린 이유로 나는 403

목록 대조는 선언이 있는지만 봅니다. 선언대로 막히는지는 요청을 보내 봐야 압니다. 이때 가장 흔히 쓰는 모양이 "USER로 관리자 기능을 부르면 403"이라는 단언인데, 이건 부정 단언입니다. 막혔다는 사실만 확인할 뿐 무엇이 막았는지는 확인하지 않습니다. 최소 예제에서는 이 단언이 관리자 규칙과 무관하게 통과하는 경로가 CSRF 쪽과 인증 실패 쪽에서 하나씩 나왔습니다.

CSRF부터 봅니다. Spring Security는 POST 같은 안전하지 않은 메서드에 CSRF 보호를 기본으로 켜고, 테스트 문서도 이렇게 적습니다.[^csrf]

> When testing any non-safe HTTP methods and using Spring Security’s CSRF protection, you must include a valid CSRF Token in the request.

토큰 없는 POST는 `CsrfFilter`가 역할을 보기도 전에 403으로 끝냅니다. 그래서 `.with(csrf())`를 빠뜨린 테스트는 관리자 규칙을 지워도 403을 받습니다.

| 체인 설정 | USER `POST /admin/users/1/lock`, 토큰 없음 | 같은 요청, `.with(csrf())` |
|---|---|---|
| `/admin/**`는 `hasRole("ADMIN")` | 403 | 403 |
| 관리자 규칙 삭제 (`anyRequest().authenticated()`만) | 403 | 200 |

규칙이 사라졌는데 왼쪽 열은 그대로 403입니다. 토큰을 빠뜨린 ADMIN의 요청도 403이었습니다.

인증 실패 쪽에서는 로그인하지 않은 요청이 받는 상태 코드가 인증 방식 설정에 따라 갈립니다. 같은 `GET /admin/users`를 익명으로 보낸 결과입니다.

| 인증 설정 | 익명 요청 결과 |
|---|---|
| `httpBasic()`만 | 401 |
| `formLogin()`만 | 302 (`/login`으로) |
| Boot 기본 체인 (`formLogin`과 `httpBasic`) | `Accept`가 없거나 `application/json`이면 401, `text/html`이면 302 |
| 인증 DSL 없이 자체 토큰 필터만 | 403 |

함정은 마지막 줄입니다. JWT를 자체 필터로 검증하면서 `httpBasic`이나 `formLogin`을 켜지 않는 구성이라면, 기본 entry point가 `Http403ForbiddenEntryPoint`라서(`ExceptionHandlingConfigurer.java` 6.5.11 L236-238) 익명 요청도 403을 받습니다. 테스트가 보낸 토큰이 만료돼 인증이 실패해도 403이 나오니, "권한 없음"을 확인하려던 테스트가 "인증 실패"로 통과할 수 있습니다.

두 경우 모두 같은 처방으로 드러납니다. **역할만 바꾼 같은 요청이 2xx가 되는 것**을 함께 확인하는 짝 테스트입니다. 앞의 정책 표에서 `ADMIN` 줄을 꺼내 쓰면 표와 테스트가 한 몸이 됩니다.

```java
// 예시: EndpointPolicyInventoryTest 안. 정책 표의 ADMIN 줄마다 역할만 바꿔 같은 요청을 보낸다
static Stream<String> adminEndpoints() {
    return POLICIES.entrySet().stream()
            .filter(e -> e.getValue() == Policy.ADMIN)
            .map(Map.Entry::getKey);
}

@ParameterizedTest
@MethodSource("adminEndpoints")
void 관리자_엔드포인트는_역할만_바꾼_같은_요청에서_갈린다(String endpoint) throws Exception {
    String[] parts = endpoint.split(" ");
    HttpMethod method = HttpMethod.valueOf(parts[0]);
    String path = parts[1].replace("{id}", "1");

    mvc.perform(request(method, path).with(user("u").roles("USER")).with(csrf()))
            .andExpect(status().isForbidden());
    mvc.perform(request(method, path).with(user("a").roles("ADMIN")).with(csrf()))
            .andExpect(status().is2xxSuccessful());
}
```

이것도 일부러 깨뜨려 봤습니다. `/admin/**`와 `/reports/**`의 `hasRole("ADMIN")`을 `authenticated()`로 바꾸자 세 건 모두 USER 쪽에서 `Status expected:<403> but was:<200>`로 실패했습니다. 여기에 `.with(csrf())`까지 빼자 GET 두 건은 USER 쪽에서 같은 메시지로 실패했고, POST 한 건은 USER 쪽 403 단언을 통과한 뒤 ADMIN 쪽에서 실패했습니다.

```
Range for response status value 403 expected:<SUCCESSFUL> but was:<CLIENT_ERROR>
```

CSRF가 만든 403을 잡아낸 것은 403 단언이 아니라 짝의 2xx 단언이었습니다. 403만 단언하는 테스트였다면 이 POST는 관리자 규칙 없이도 초록불이었을 겁니다.

**403은 막혔다는 사실만 말하고 누가 막았는지는 말하지 않습니다.** 역할만 바꾼 같은 요청이 통과하는 것까지 봐야 그 403이 인가 규칙의 것이 됩니다.

## 누가 무엇을 읽는가

따릉이로 돌아가면, 영상이 함께 짚은 장면이 하나 더 있습니다. 대량 유출이 일어나던 때 이를 DDoS로 인식했다는 것입니다. 기록을 시간순으로 놓으면 이 장면은 조금 다르게 보입니다. 2024년 6월 말 따릉이 앱이 멈췄고, 서울시는 "따릉이 앱이 약 80분간 다운되자 행정안전부에 장애 신고를 했다"고 설명했습니다.[^newsis0206] 공단도 관계기관에 '장애 발생'으로 신고했습니다. 같은 해 7월, 공단이 받은 분석 보고서에 유출 사실이 담겨 있었습니다.

> 그 후 서버 보안업체가 사이버공격에 대한 분석 보고서를 그해 7월 18일 공단에 제출했다. 이 보고서에는 '개인정보가 유출됐다'는 사실이 담겨 있었다.[^khan]

DDoS라는 판단은 초기 분류에 한한 것이었고, 유출은 3주 안에 보고서로 확인됐습니다. 그 뒤 1년 7개월가량 신고와 공지가 이뤄지지 않은 것은 탐지가 아니라 처리의 실패입니다.[^newsis0206] 영상도 확인된 뒤 방치됐다는 점을 함께 짚습니다.

이 순서에서 보이는 것은 두 신호의 속도 차이입니다. "얼마나 많이"는 곧바로 보였습니다. 대량 트래픽이 있었고, 앱이 멈췄고, 장애로 신고됐습니다.[^newsis0223] 다만 그 트래픽이 유출 호출 자체였는지는 공개 기록이 확정하지 않습니다. 반면 "누가 무엇을 읽었는가"는 사후 분석을 거쳐서야 보였습니다. 인증 토큰 검증 없이 응답하는 엔드포인트라면 그 "누가"는 처음부터 기록될 수 없었습니다. 요청에 인증된 주체가 없으니까요.

레이트 리미터가 대책으로 떠오르는 자리가 여기입니다. 그런데 리미터가 셀 수 있는 것도 "얼마나 많이"입니다. 레이트리미터 편은 알고리즘보다 먼저 정해야 할 것으로 "키를 무엇으로 하는가"를 꼽았고, 키가 계정이려면 요청에 인증된 주체가 있어야 합니다. 인증 없이 응답하는 엔드포인트에서 리미터가 쓸 수 있는 키는 IP 정도이고, 한도 안쪽에서 천천히 읽어 가는 호출은 리미터에게 정상 트래픽과 구분되지 않습니다.

같은 글에 쓴 "**완벽한 알고리즘도 안 걸린 경로는 못 막습니다.**"가 인가에서도 그대로 성립합니다. 그 글은 "**"초당 몇 건"(속도)과 "동시에 몇 개"(동시성)는 다른 축입니다.**"라고도 했는데, "얼마나 많이"와 "누가 무엇을"도 다른 축입니다. 한 장치로 다른 축을 막을 수는 없습니다.

"누가 무엇을 읽었는가"를 남기는 일에도 기본값이 있습니다. Spring Security 문서는 "For each authorization that is denied, an AuthorizationDeniedEvent is fired."라고 쓰고, 허용된 쪽에 대해서는 "Because AuthorizationGrantedEvents have the potential to be quite noisy, they are not published by default."라고 씁니다.[^events] `authorizeHttpRequests`가 쓰는 기본 publisher인 `SpringAuthorizationEventPublisher`도 허용 결정이면 아무것도 발행하지 않고 돌아갑니다(6.5.11 L63-65). 기본으로 발행되는 인가 이벤트는 막힌 요청 쪽인데, 유출은 허용된 읽기로 일어납니다. 소음을 이유로 꺼 둔 그 이벤트가 유출을 사후에 재구성할 때 필요한 기록입니다.

전부 켜자는 이야기는 아닙니다. 문서 말대로 허용 이벤트는 시끄럽습니다. 회원 정보를 대량으로 돌려주는 조회처럼 남겨야 할 읽기를 고르는 일은 기능의 의미를 아는 사람의 몫이고, 인가 선언과 같은 성질의 일이에요.

**볼륨 방어는 "얼마나 많이"를 세고, 유출은 "누가 무엇을 읽었는가"에서 드러납니다.** 인증이 없는 경로에는 그 "누가"가 없고, 인증이 있어도 허용된 읽기는 기본으로 남지 않습니다. 볼륨 방어가 인가를 대신할 수는 없습니다.

## 기본기와 기본값

영상은 따릉이를 기본을 무시한 사건으로 정리합니다. 이 글을 쓰는 동안 그 "기본"을 여러 번 고쳐 읽었습니다. 처음에는 기본기로 읽었습니다. 인증을 하고, 권한을 확인하는 것. 그런데 코드로 내려가자 "기본"은 다른 얼굴로 나타났습니다. 기본값입니다.

이 글에서 만난 기본값을 늘어놓으면 이렇습니다. 5.8까지 규칙 없는 요청을 허용하던 기본값, 6.0부터 거부하는 기본값, 그 위를 덮는 Boot 기본 체인의 마지막 한 줄이 있었습니다. 메서드 보안을 켜지 않는 스타터, 인증 DSL이 없으면 익명에게도 403을 주는 entry point, 허용된 읽기를 남기지 않는 이벤트도 모두 기본값이었습니다. 이 블로그의 `exclude`도 목록에 없는 것은 공개하는 기본값이었고요.

한국어로는 둘 다 "기본"이라 구분 없이 써 왔는데, 따라가 보니 둘은 이렇게 이어져 있었습니다. **기본기를 지킨다는 것은 기본값을 직접 고른다는 것입니다.** 선언하지 않은 경로에서 무슨 일이 일어나는지 말할 수 있으면 그건 내가 고른 정책이고, 말할 수 없으면 누군가 대신 고른 정책입니다. 레이트리미터 편에서 "**지금 무엇이 나 대신 골라져 있는지 확인하는 것**"이라고 쓴 것과 같은 이야기를, 이번에는 인가에서 다시 만났습니다.

그 확인을 사람의 기억에 맡기지 않는 방법이 목록 대조였습니다. 가이드가 말한 '모든 가능한 실행경로'는 사람이 외워서 세는 목록이 아니라, 실행 중인 애플리케이션에서 뽑아 정책 표와 맞대는 목록이어야 합니다. AI가 쉬운 버그를 찾는 비용을 계속 낮춘다면, 아무도 선언하지 않은 경로는 머지않아 누군가가 먼저 세게 됩니다. 그 목록을 먼저 세는 쪽은 우리 테스트여야 합니다.

[^hankook]: 한국일보, 2026-10-01. [hankookilbo.com](https://www.hankookilbo.com/news/article/A2026100115320000186). 경로 원문: "이번 공격은 대출 모집인을 위해 제공하는 모바일 웹페이지에서 시작된 것으로 전해졌다." 2026-10-08 기준 보도 1주일 차라 피해 범위와 경위는 바뀔 수 있다.
[^video]: 널널한 개발자 TV, 「예상 면접질문: 따릉이와 금융권 AI 해킹사고 어떻게 막을 수 있을까?」. [youtube.com/watch?v=fRyxfHkqf2M](https://www.youtube.com/watch?v=fRyxfHkqf2M). 영상 속 화자가 밝힌 녹화 시점은 2026년 10월 7일이다. 영상은 뒤이어 취업 준비 조언으로 넘어가는데, 이 글은 앞부분의 사고 진단만 계기로 삼는다.
[^ncsc]: UK NCSC, "Impact of AI on cyber threat from now to 2027", 2025-05-07. 원문: "To 2027, this will highly likely increase the volume and impact of cyber intrusions through evolution and enhancement of existing TTPs, rather than creating novel threat vectors." [ncsc.gov.uk](https://www.ncsc.gov.uk/report/impact-ai-cyber-threat-now-2027)
[^carlini]: Carlini et al., "LLMs unlock new paths to monetizing exploits", arXiv:2505.11449, 2025-05-16. 초록 원문: "We argue that Large language models (LLMs) will soon alter the economics of cyberattacks." 그리고 "instead of human attackers manually searching for one difficult-to-identify bug in a product with millions of users, LLMs can find thousands of easy-to-identify bugs in products with thousands of users." [arxiv.org/abs/2505.11449](https://arxiv.org/abs/2505.11449)
[^newsis0223]: 뉴시스, 2026-02-23 (최은수, 조성하 기자), 서울경찰청 사이버수사과 송치 발표 보도. [newsis.com](https://www.newsis.com/view/NISX20260223_0003522553). 발각 경위 원문: "이번 사건은 경찰이 민간 공유 모빌리티 업체를 겨냥한 디도스(DDoS) 공격 사건을 수사하던 중, 피의자의 압수물을 분석하는 과정에서 드러났다." 침입 기간은 경찰 발표 기준이며, 서울시 설명은 6월 28일부터 30일로 하루 차이가 있다. 트래픽 원문: "당초 대량 트래픽 발생으로 인해 디도스 공격으로 알려지기도 했으나, 경찰 수사 결과 이는 서버 취약점을 이용한 개인정보 유출 해킹으로 확인됐다." 거의 같은 취약점 문장이 2026-03-01 뉴시스 해설 기사([newsis.com](https://www.newsis.com/view/NISX20260223_0003523249))에도 있다.
[^seoul]: 서울신문, 「문성호 서울시의원, 서울시설공단 해킹 대비 물리적 인증 장치 구축 강구」, 2026-03-05. [m.go.seoul.co.kr](https://m.go.seoul.co.kr/news/2026/03/05/20260305500062). 발언을 전한 기사 서술 원문: "서울시설공단 내 관리자 권한으로 접근 가능한 정보에 인증 장치가 미비하다는 서버 설계상 허점". 상임위 발언이며 공식 조사 결과가 아니다. 비즈한국 해설 기사(2026-02-23, [bizhankook.com](https://www.bizhankook.com/articles/31575.html))는 기자 서술로 "가입자 인증이나 별도 권한 확인 없이도 정보 조회가 가능한 서버 설정의 취약성"이라고 썼다.
[^a01]: OWASP Top 10 A01 Broken Access Control, [2021판](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)과 [2025판](https://owasp.org/Top10/2025/A01_2025-Broken_Access_Control/)의 Scenario #2. 두 판의 How to Prevent에는 "Except for public resources, deny by default."가 있다.
[^api5]: OWASP API Security Top 10 2023, [API5:2023 Broken Function Level Authorization](https://api-security.owasp.org/editions/2023/en/0xa5-broken-function-level-authorization/). 위협 주체 원문: "Exploitation requires the attacker to send legitimate API calls to an API endpoint that they should not have access to as anonymous users or regular, non-privileged users." 대책 항목에는 "The enforcement mechanism(s) should deny all access by default, requiring explicit grants to specific roles for access to every function."이 있다. 공개 기록만으로는 따릉이 엔드포인트가 기능 수준(API5)의 문제였는지 객체 수준(API1, BOLA)의 문제였는지 가를 수 없다.
[^cwe306]: MITRE, [CWE-306: Missing Authentication for Critical Function](https://cwe.mitre.org/data/definitions/306.html), CWE List Version 4.20 (2026-04-30). Potential Mitigations 원문: "In environments such as the World Wide Web, the line between authentication and authorization is sometimes blurred. If custom authentication routines are required instead of those provided by the server, then these routines must be applied to every single page, since these pages could be requested directly." 인가 누락은 별도 항목인 CWE-862(Missing Authorization)다.
[^sec58]: spring-security 5.8.0 태그, `docs/modules/ROOT/pages/migration/servlet/authorization.adoc` L653-655. [github.com](https://github.com/spring-projects/spring-security/blob/5.8.0/docs/modules/ROOT/pages/migration/servlet/authorization.adoc?plain=1#L651-L658). 기본값 변경은 [gh-11958](https://github.com/spring-projects/spring-security/issues/11958)로 6.0.0-RC1에 들어갔다.
[^authz-doc]: spring-security 6.5.11 태그, `docs/modules/ROOT/pages/servlet/authorization/authorize-http-requests.adoc` L10-23(첫 예시), L497(TIP), L765-766(`denyAll` 설명). 렌더 페이지: [docs.spring.io](https://docs.spring.io/spring-security/reference/6.5/servlet/authorization/authorize-http-requests.html). "anyRequest를 빼면 6.0부터 거부된다"는 설명은 6.5.11 레퍼런스 본문에는 없고 5.8 마이그레이션 가이드에만 있다.
[^method-doc]: [Method Security](https://docs.spring.io/spring-security/reference/6.5/servlet/authorization/method-security.html) 렌더 페이지 문장. adoc 원본은 6.5.11 태그 `method-security.adoc` L306-307(링크 마크업 포함)이고, "does not activate" 문장은 L38이다. "a catch-all authorization rule"의 링크 대상은 `authorize-http-requests.adoc#activate-request-security`다.
[^kisa]: 행정안전부, 한국인터넷진흥원, 「소프트웨어 개발보안 가이드」(2021.11), 제4장 제2절 보안기능 "2. 부적절한 인가" 개요(p.215). [KISA 게시글](https://www.kisa.or.kr/2060204/form?postSeq=5&lang_type=KO&page=1). 설계 단계 항목 SR2-4 중요자원 접근통제에는 "③ 관리자 페이지에 대한 접근통제 정책을 수립하여 적용해야 한다."가 있다.
[^handler]: Spring Framework v6.2.19, `AbstractHandlerMethodMapping.java` L145. [github.com](https://github.com/spring-projects/spring-framework/blob/v6.2.19/spring-webmvc/src/main/java/org/springframework/web/servlet/handler/AbstractHandlerMethodMapping.java#L144-L147)
[^artemis]: [ls1intum/Artemis](https://github.com/ls1intum/Artemis) (MIT), 커밋 `07f43f8e0b71037881624546c9dcf779498728ff`의 [`AuthorizationArchitectureTest.java`](https://github.com/ls1intum/Artemis/blob/07f43f8e0b71037881624546c9dcf779498728ff/src/test/java/de/tum/cit/aet/artemis/core/authorization/AuthorizationArchitectureTest.java). 인용 위치는 L231(규칙의 `because` 문자열), L203(예외 목록 주석), L114-115(액추에이터 주석)다.
[^actuator]: Spring Boot v3.5.16 `spring-boot-project/spring-boot-docs/src/docs/antora/modules/reference/pages/actuator/endpoints.adoc` L239. 렌더 페이지: [docs.spring.io](https://docs.spring.io/spring-boot/3.5/reference/actuator/endpoints.html). 같은 문서는 "By default, only the health endpoint is exposed over HTTP and JMX."라고도 쓴다(L171).
[^csrf]: [Testing with CSRF Protection](https://docs.spring.io/spring-security/reference/6.5/servlet/test/mockmvc/csrf.html) 렌더 페이지 문장. adoc 원본은 6.5.11 태그 `servlet/test/mockmvc/csrf.adoc` L4다. 토큰 검증에 실패하면 `CsrfFilter`(6.5.11 L125-132)는 `AccessDeniedHandler`를 직접 부르고 체인을 끝낸다.
[^newsis0206]: 뉴시스, 「서울시설공단, 따릉이 개인정보유출 2024년 알고도 미조치(종합)」, 2026-02-06. [mobile.newsis.com](https://mobile.newsis.com/view/NISX20260206_0003505448). 미조치 원문: "그러나 공단은 개인정보 유출 사실을 인지하고도 개인정보보호위원회 신고나 시민 공지 등 법에 따른 후속 조치를 하지 않은 채 1년7개월가량 묵인했다."
[^khan]: 경향신문, 「따릉이 앱 '개인정보 유출' 보고서 숨긴 시설관리공단」, 2026-02-06. [khan.co.kr](https://www.khan.co.kr/article/202602061417001). 공단의 신고 원문: "당시 공단은 관계기관에 '장애 발생' 이라고 신고했다." 보고서 제출 주체를 경향은 "서버 보안업체", 뉴시스(2026-02-06)는 "KT 클라우드 서버 관리 용역업체"로 쓴다.
[^events]: [Authorization Events](https://docs.spring.io/spring-security/reference/6.5/servlet/authorization/events.html) 렌더 페이지 문장. adoc 원본은 6.5.11 태그 `servlet/authorization/events.adoc` L4, L73이다. `AuthorizeHttpRequestsConfigurer.java` 6.5.11 L78-82는 `AuthorizationEventPublisher` 빈이 없으면 `SpringAuthorizationEventPublisher`를 쓴다.
