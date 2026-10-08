# 리서치: 관리자 API가 아무에게나 열리는 이유와 그것을 테스트로 잠그는 법

- slug: `missing-authorization-backend` (확정)
- 작성: 2026-10-08, blog-researcher
- 글의 성격(사용자 확정 2026-10-08): **백엔드 실무 각론.** 영상은 도입부의 계기로만 쓴다. 본론은 인가 누락이 코드에서 왜 생기는지와 그것을 테스트로 어떻게 잠그는지. 독자는 현업 백엔드 개발자
- 근거 범위: 공개 자료와 이 블로그의 기존 글만. **사내 코드와 경험은 쓰지 않는다**
- 출발 자료: `_drafts/missing-authorization-backend.sources-video.md`(git 무시 파일, 공개 금지). 영상 https://www.youtube.com/watch?v=fRyxfHkqf2M (2026-10-07 녹화, 화자 채널명 미확인). STT 전사라 **본문에서 영상 대사를 직접 인용하지 않고 출처를 밝힌 요지 서술로만 쓴다**

## 이 노트를 읽는 순서 (writer 필독)

1. **글의 전제를 먼저 조정해야 합니다.** 따릉이 사건의 공개 기록이 확정하는 것은 "가입자 정보 조회 호출이 **인증 토큰 검증 없이** 응답했다"까지입니다(D-2). "관리자용 API"라는 표현은 경찰 설명에 없고 시의원 발언에만 나오며, "인가(권한 확인)가 없었다"는 확정되지 않았습니다(D-3). 따라서 따릉이를 "인가 누락 사례"로 단정하면 안 됩니다. 대신 쓸 수 있는 다리가 표준 문서에 있습니다. OWASP는 비인증 접근과 비관리자 접근을 **같은 시나리오**에 넣고(C-2), MITRE는 인증과 인가의 경계가 웹에서 흐려진다고 적습니다(C-3). 이 다리를 어떻게 놓을지는 인사이트 후보의 첫 두 항목을 보세요
2. 본론의 사실 근거는 E-S(Spring Security 동작)와 E-T(테스트 패턴)입니다. **버전에 따라 기본값이 정반대**라는 점(5.8까지 미매칭 허용, 6.0부터 거부)이 이 글의 판단을 좌우합니다
3. 내부 근거(I절)에서 이 블로그 자신의 계약 테스트가 "엔드포인트마다 선언" 모양이라는 점이 확인됐습니다(I-2). 정직한 자기 사례로 쓸 수 있습니다
4. 소주제 이름은 `기본 허용 | 목록 대조 | 누가 무엇을 읽는가`로 확정했습니다

---

## 근거 D: 따릉이 사건 사실관계 (외부, 기사 원문 직접 대조)

> 기사 원문은 2026-10-08에 HTML을 직접 받아 본문을 추출해 대조했습니다(요약 도구 경유가 아님). 따옴표 안은 기사 문장 그대로입니다.

### D-1. 출처와 각각이 말하는 범위

| 출처 | 날짜 | 성격 | 이 글에서 쓰는 범위 |
|---|---|---|---|
| 뉴시스 「따릉이 개인정보 462만건 유출범은 중학생…」(종합), 최은수 조성하 기자. https://www.newsis.com/view/NISX20260223_0003522553 | 2026-02-23 12:54 송고 | 서울경찰청 사이버수사과 송치 발표 보도 | 연령, 시점, 발각 경위, 취약점 성격, DDoS 서술의 1차 근거 |
| 뉴시스 「호기심에 따릉이 해킹한 10대 청소년…강경처벌이 해결책일까」, 윤정민 기자. https://www.newsis.com/view/NISX20260223_0003523249 | 2026-03-01 15:00 등록 | 해설 기사 | 영상이 말한 "2026년 3월 뉴시스 기사"로 추정. 취약점 문장은 2/23 기사와 같음 |
| 비즈한국 「따릉이, 중학생한테 개인정보 털린 황당한 이유」, 강은경 기자. https://www.bizhankook.com/articles/31575.html | 2026-02-23 16:04 | 해설 기사 | "인증이나 별도 권한 확인" 표현의 출처(기자 서술) |
| 뉴시스 「서울시설공단, 따릉이 개인정보유출 2024년 알고도 미조치(종합)」, 이재은 기자. https://mobile.newsis.com/view/NISX20260206_0003505448 | 2026-02-06 | 서울시 브리핑 보도 | 2024년 당시 DDoS 판단, 장애 신고, 보고서 묵인 |
| 경향신문 「따릉이 앱 '개인정보 유출' 보고서 숨긴 시설관리공단」. https://www.khan.co.kr/article/202602061417001 | 2026-02-06 | 서울시 브리핑 보도 | 공단의 "장애 발생" 신고, 보고서 제출일 |
| 서울신문 「문성호 서울시의원, 서울시설공단 해킹 대비 물리적 인증 장치 구축 강구」. https://m.go.seoul.co.kr/news/2026/03/05/20260305500062 | 2026-03-05 | 시의원 상임위 발언 보도 | "관리자 권한" 표현의 유일한 출처. 공식 조사 결과가 아님 |
| 세계일보 「서울시설공단 "2차 피해는 없어"」. https://www.segye.com/newsView/20260721524221 | 2026-07-21 | 공단 발표 보도 | 개별 통지와 재발 방지 조치 |

### D-2. 확정된 사실 (원문)

- **규모**: "서울시 공공자전거 '따릉이' 가입자 462만건의 개인정보를 해킹해 유출한 혐의" (뉴시스 2/23). 초기 보도는 "450만건 이상"(뉴시스 2/6), 공단 통지 기준은 약 462만 명(세계일보 7/21)
- **발생 시점**: "이들은 2024년 6월 28일부터 29일 사이 서울시설공단이 운영하는 '서울자전거 따릉이' 서버에 침입해 가입자 정보를 빼돌린 혐의를 받는다." (뉴시스 2/23). 서울시 설명은 "2024년 6월28일부터 30일까지 따릉이 앱 서버를 겨냥한 디도스(DDoS) 공격이 발생했다" (뉴시스 2/6). 경찰은 이틀, 서울시는 사흘
- **연령과 학년**: "조사 결과, 현재 고등학생인 이들은 범행 당시 중학생 신분이었다." (뉴시스 2/23)
- **발각 경위**: "이번 사건은 경찰이 민간 공유 모빌리티 업체를 겨냥한 디도스(DDoS) 공격 사건을 수사하던 중, 피의자의 압수물을 분석하는 과정에서 드러났다." 이어서 "같은 해 10월 초 공격자로 B군을 특정해 검거한 경찰은 압수한 전자기기를 포렌식 하는 과정에서 따릉이 개인정보 파일을 확인하고 462만건의 데이터를 회수했다." 주범 A군은 "올해 1월 말" 검거 (뉴시스 2/23)
- **취약점 성격 (가장 중요)**:
  - 뉴시스 2/23: "이들은 가입자 정보 조회 시 필요한 최소한의 '인증 토큰' 검증 절차조차 없어, 특정 호출만 하면 서버가 무방비로 정보를 응답하는 허점을 파고든 것으로 조사됐다."
  - 같은 기사, 서울경찰청 관계자: "가입자 인증을 거쳐야 정보를 받아 오는 구조여야 하는데 그런 절차가 없어 미비했다"
  - 뉴시스 3/1: "가입자 정보 조회 시 필요한 최소한의 '인증 토큰' 검증 절차조차 없어 특정 호출만 하면 서버가 무방비로 정보에 응답한다는 걸 알아냈다." 그리고 "보안 전문가들은 이번 사건이 공공 시스템에서 기본적인 접근 통제조차 제대로 구현되지 않은 전형적인 사례라며"
  - 비즈한국 2/23(기자 서술): "수사 과정에서 확인된 침입 방식은 고도의 기술을 동원했다기보다는 가입자 인증이나 별도 권한 확인 없이도 정보 조회가 가능한 서버 설정의 취약성을 활용한 것에 가까웠다."
  - 공단 7/21 발표: 원인이 된 웹 취약점을 조치하고 이상 접속 모니터링을 강화했다는 요지(검색 요약 경유, 원문 문장 직접 대조 못 함)
- **DDoS 서술**:
  - 뉴시스 2/23: "당초 대량 트래픽 발생으로 인해 디도스 공격으로 알려지기도 했으나, 경찰 수사 결과 이는 서버 취약점을 이용한 개인정보 유출 해킹으로 확인됐다."
  - 뉴시스 2/6(서울시 설명): "시는 따릉이 앱이 약 80분간 다운되자 행정안전부에 장애 신고를 했다."
  - 경향 2/6: 따릉이 앱이 2024년 6월 28일부터 30일까지 디도스로 추정되는 사이버공격에 전산이 마비됐다는 서술(원문 괄호에 가운뎃점이 있어 요지로 둠), 그리고 "당시 공단은 관계기관에 '장애 발생' 이라고 신고했다."
- **유출을 안 뒤의 처리**:
  - 뉴시스 2/6: "이후 같은 해 7월 KT 클라우드 서버 관리 용역업체가 개인정보 유출 정황을 담은 보고서를 서울시설공단에 전달했다. 그러나 공단은 개인정보 유출 사실을 인지하고도 개인정보보호위원회 신고나 시민 공지 등 법에 따른 후속 조치를 하지 않은 채 1년7개월가량 묵인했다."
  - 경향 2/6: "그 후 서버 보안업체가 사이버공격에 대한 분석 보고서를 그해 7월 18일 공단에 제출했다. 이 보고서에는 '개인정보가 유출됐다'는 사실이 담겨 있었다." (제출 주체를 뉴시스는 "KT 클라우드 서버 관리 용역업체", 경향은 "서버 보안업체"로 씀)
- **처벌과 행정**: 정보통신망법 위반 혐의 불구속 송치(뉴시스 2/23). 서울시가 공단 관계자를 개인정보보호법 위반 등 혐의로 2026-02-09 수사 의뢰(뉴시스 2/23). 개인정보위 실태 조사 착수는 2026-01-30 전후(보도참고자료 재게시 페이지와 검색 요약 경유, pipc.go.kr 원문 미대조)

### D-3. 영상과 원 출처가 어긋나는 지점

| 영상의 주장(요지) | 원 출처 | 판정 |
|---|---|---|
| "관리자용 API"를 누구나 호출해 응답을 받을 수 있었다 | 뉴시스 두 기사 모두 "가입자 정보 조회" 호출에 "'인증 토큰' 검증 절차조차 없어"라고만 씀. "관리자"라는 단어가 없음. "서울시설공단 내 관리자 권한으로 접근 가능한 정보에 인증 장치가 미비하다는 서버 설계상 허점"은 **문성호 시의원의 상임위 발언**(서울신문 3/5)에만 나옴. (verifier 보정: 이 구절은 기사의 따옴표 밖 서술이고, 2026-03-04 교통위원회 회의록에는 '관리자'가 없음. 검증 기록 V-9) | **원 출처 미확인.** 영상이 시의원 발언 계열 서술과 섞었을 가능성. 공식 조사 결과로 "관리자 API"가 확인된 적 없음 |
| 인가(관리자 권한 확인)가 없었다 | 경찰 설명은 **인증 토큰 검증 부재**(인증). 비즈한국만 "인증이나 별도 권한 확인 없이"로 둘 다 언급(기자 서술) | 공개 기록이 확정하는 것은 "인증 없이 조회 호출이 응답했다"까지. 인가 부재 여부는 **확정하지 못함** |
| "2026년 3월 뉴시스 기사" | 3/1 뉴시스 해설 기사가 실재하고 취약점 문장이 들어 있음. 다만 DDoS 서술은 3/1 기사에 없고 2/23 기사에 있음 | 날짜는 맞음. 영상이 두 기사 내용을 합쳐 말한 것으로 보임 |
| 대량 유출을 DDoS로 오인했다 | 2024년 당시 "디도스로 추정되는 사이버공격", "장애 발생"으로 신고. 그러나 **2024년 7월 유출을 담은 분석 보고서를 받았고** 1년 7개월 미조치 | 오인은 **초기 분류에 한해** 맞음. 유출은 3주 안에 보고서로 확인됐고, 실패는 탐지가 아니라 **확인 후 처리**였음. 영상도 "확인됐는데 방치"를 함께 말하므로 영상과 정면 충돌은 아님 |
| 대량 트래픽이 곧 유출 행위였다(영상의 함의) | 뉴시스 2/23 "대량 트래픽 발생으로 인해 디도스 공격으로 알려지기도 했으나 ... 개인정보 유출 해킹으로 확인" | 문맥상 그렇게 읽히나 "장애 원인이 대량 조회였다"는 명시 문장은 없음. **확정하지 못함** |
| "고등학생" 두 명, "당시 중학생" | "현재 고등학생인 이들은 범행 당시 중학생 신분" | **어긋나지 않음.** 송치 시점 고교생, 범행 시점 중학생으로 둘 다 맞음 |
| 국가 기관에 대한 공격 | 운영 주체는 서울시설공단(서울시 산하 지방공기업), 서울시는 관리 감독 기관(비즈한국) | "공공기관"이 정확. "국가 기관"은 부정확 |
| (영상 외 보도 간 불일치) DDoS 사건 당사자 | 뉴시스 2/23: 취약점을 먼저 발견한 것은 B군, 범행 주도는 A군, DDoS 사건으로 먼저 검거된 것은 B군. 헤럴드경제 계열은 기사에 따라 B군과 A씨로 다르게 씀 | 본문에서 피의자를 구분할 필요가 없으면 "10대 2명"으로만 쓰는 편이 안전 |

### D-4. 확정하지 못한 것 (따릉이)

- 호출된 엔드포인트가 관리자 기능이었는지, 일반 회원 조회 API에 남의 식별자를 넣은 것인지(BFLA인지 BOLA인지). 공개 자료에 엔드포인트 명세가 없음
- "인증 토큰 검증 절차조차 없어"가 토큰을 아예 요구하지 않았다는 뜻인지, 토큰은 받되 서명이나 만료를 검증하지 않았다는 뜻인지. 시의원은 "개인정보를 요청할 때 필요한 암호화된 인증 정보 검증 절차가 형식적이었던 약점"이라 하고 "클라이언트가 보내는 토큰의 서명(Signature)과 만료 시간(Expiration)을 서버에서 반드시 검증하도록 강제해야 하는 토큰 검증 로직 전수 조사"를 제안했으나, 이는 발언이지 조사 결과가 아님
- 462만 건을 몇 번의 호출로 받았는지(목록 응답인지 건별 열거인지)
- 2024년 6월 약 80분 장애의 원인이 대량 조회 자체였는지
- 개인정보보호위원회의 최종 처분(2026-10-08 기준 검색 범위에서 의결 보도 없음)
- 경찰 보도자료 원문(언론 보도로만 확인)

---

## 근거 C: 분류와 표준 문서 (외부)

> OWASP와 CWE 인용은 리서치 단계에서 원본(GitHub 마크다운, cwe.mitre.org 4.20 페이지)을 직접 받아 대조했습니다. KISA 인용은 KISA 배포 PDF를 받아 텍스트 추출 후 대조했습니다.

### C-1. OWASP API Security Top 10 2023 (판본: 2023, 2019판 다음의 최신판. 정식 발행일 확정하지 못함)

- 목록: https://api-security.owasp.org/editions/2023/en/0x11-t10/ (요청 URL `owasp.org/API-Security/...`은 이리로 308 리다이렉트)
- 원본: https://github.com/OWASP/API-Security/tree/master/editions/2023/en
- **API1:2023 BOLA** (https://api-security.owasp.org/editions/2023/en/0xa1-broken-object-level-authorization/) BOLA와 BFLA를 가르는 문장이 이 페이지에 있음:
  > In the case of BOLA, it's by design that the user will have access to the vulnerable API endpoint/function. The violation happens at the object level, by manipulating the ID. If an attacker manages to access an API endpoint/function they should not have access to - this is a case of Broken Function Level Authorization (BFLA) rather than BOLA.
- **API5:2023 BFLA** (https://api-security.owasp.org/editions/2023/en/0xa5-broken-function-level-authorization/)
  - 목록 페이지 정의: "Complex access control policies with different hierarchies, groups, and roles, and an unclear separation between administrative and regular functions, tend to lead to authorization flaws. By exploiting these issues, attackers can gain access to other users' resources and/or administrative functions."
  - Threat agents, **익명 사용자를 명시**: "Exploitation requires the attacker to send legitimate API calls to an API endpoint that they should not have access to as anonymous users or regular, non-privileged users. Exposed endpoints will be easily exploited."
  - Is the API Vulnerable?: "Don't assume that an API endpoint is regular or administrative only based on the URL path."
  - Scenario #2(전체 회원 정보 노출과 같은 형태): "An API contains an endpoint that should be exposed only to administrators - `GET /api/admin/v1/users/all`. This endpoint returns the details of all the users of the application and does not implement function level authorization checks."
  - How To Prevent: "The enforcement mechanism(s) should deny all access by default, requiring explicit grants to specific roles for access to every function." (원문은 줄바꿈 포함)
  - References: CWE-285
- **API2:2023 Broken Authentication**: 인증 부재를 직접 다루는 문장은 마이크로서비스 항목 "Other microservices can access it without authentication" 하나. References는 CWE-204, CWE-307(CWE-306 없음)
- **API9:2023 Improper Inventory Management** 정의: "APIs tend to expose more endpoints than traditional web applications, making proper and updated documentation highly important." (목록 대조 소주제와 이어짐)

### C-2. OWASP Top 10 A01 Broken Access Control (2021판, 2025판)

- 2021: https://owasp.org/Top10/A01_2021-Broken_Access_Control/ , 2025: https://owasp.org/Top10/2025/A01_2025-Broken_Access_Control/ (2025판 RC 2025-11-06, 프로젝트 페이지의 "released" 전환 커밋 2025-12-24. 정식 발행일은 확정하지 못함)
- 두 판 공통 How to Prevent: "Except for public resources, deny by default."
- 두 판 공통 Scenario #2, **비인증 접근과 비관리자 접근을 한 시나리오에 넣음**: "If an unauthenticated user can access either page, it's a flaw. If a non-admin can access the admin page, this is a flaw."
- ⚠️ 분류 함정: CWE-862, 285, 284, 639는 A01에 매핑되지만 **CWE-306과 CWE-288은 A07**(2021 Identification and Authentication Failures, 2025 Authentication Failures)에 매핑됨. "A01이면서 CWE-306"이라고 쓰면 OWASP 자체 매핑과 어긋남 (하위 에이전트 확인, 리서치 단계 직접 대조 안 함)

### C-3. CWE (판본: CWE List Version 4.20, 2026-04-30)

| CWE | 이름 | Description 원문 | URL |
|---|---|---|---|
| 862 | Missing Authorization | "The product does not perform an authorization check when an actor attempts to access a resource or perform an action." | https://cwe.mitre.org/data/definitions/862.html |
| 306 | Missing Authentication for Critical Function | "The product does not perform any authentication for functionality that requires a provable user identity or consumes a significant amount of resources." | https://cwe.mitre.org/data/definitions/306.html |
| 285 | Improper Authorization | "The product does not perform or incorrectly performs an authorization check when an actor attempts to access a resource or perform an action." | https://cwe.mitre.org/data/definitions/285.html |
| 639 | Authorization Bypass Through User-Controlled Key | "The system's authorization functionality does not prevent one user from gaining access to another user's data or record by modifying the key value identifying the data." | https://cwe.mitre.org/data/definitions/639.html |
| 288 | Authentication Bypass Using an Alternate Path or Channel (306의 자식) | "The product requires authentication, but the product has an alternate path or channel that does not require authentication." | https://cwe.mitre.org/data/definitions/288.html |
| 425 | Direct Request ('Forced Browsing') (862, 288의 자식) | "The web application does not adequately enforce appropriate authorization on all restricted URLs, scripts, or files." | https://cwe.mitre.org/data/definitions/425.html |

- 계층: 306은 287(Improper Authentication)을 거쳐, 862는 285(Improper Authorization)를 거쳐 284(Pillar)로 올라감. 둘은 서로를 직접 참조하지 않음
- **인증과 인가의 경계에 대한 MITRE 문장 (이 글의 다리)**, CWE-306 Potential Mitigations: "In environments such as the World Wide Web, the line between authentication and authorization is sometimes blurred. If custom authentication routines are required instead of those provided by the server, then these routines must be applied to every single page, since these pages could be requested directly."
- CWE-862 Terminology Note(인가는 신원을 전제): "Assuming a user with a given identity, authorization is the process of determining whether that user can access a given resource, ..."
- CWE-862 Potential Mitigations: "Use a "default deny" policy when defining these ACLs."
- CWE-285는 MITRE가 Mapping Usage "Discouraged"로 두고 862, 863, 732를 권함. OWASP API1, API5와 KISA "부적절한 인가"는 모두 285를 참조하므로, 하나만 고르면 OWASP 인용과 MITRE 권고가 갈림 (하위 에이전트 확인)

### C-4. KISA, 행정안전부 「소프트웨어 개발보안 가이드」 (2021년판, 이후 개정판 없음)

- 발행: 행정안전부, 한국인터넷진흥원. 제개정 이력 마지막 항목 "2021.11. 구현단계 보안약점 기준 확대에 따른 내용 추가 및 수정"(PDF 직접 확인). KISA 게시 2021-11-29
- KISA 게시글: https://www.kisa.or.kr/2060204/form?postSeq=5&lang_type=KO&page=1 , PDF: https://www.kisa.or.kr/post/fileDownload?menuSeq=2060204&postSeq=5&attachSeq=2&lang_type=KO
- 행정안전부 게시글: https://www.mois.go.kr/frt/bbs/type001/commonSelectBoardArticle.do?bbsId=BBSMSTR_000000000015&nttId=88956
- ⚠️ 2026-10-08에 받은 KISA PDF의 메타데이터 생성일이 2026-08-31로 찍혀 있음(하위 에이전트 관찰). 재변환인지 내용 변경인지 확정하지 못함
- **설계 단계** (보안기능 8개 중 해당 항목). "인가 기능"이라는 항목명은 없음. 인가에 해당하는 것은 "중요자원 접근통제"
  - SR2-1 인증 대상 및 방식: "① 중요기능이나 리소스에 대해서는 인증 후 사용 정책이 적용되어야 한다." (PDF 대조)
  - SR2-4 중요자원 접근통제: "③ 관리자 페이지에 대한 접근통제 정책을 수립하여 적용해야 한다." (PDF 대조)
  - 설계와 구현 연관표: 인증 대상 및 방식 → 적절한 인증 없는 중요기능 허용 외 / 중요자원 접근통제 → 부적절한 인가 외
- **구현 단계** (제4장 제2절 "보안기능" 소속, 둘 다)
  - 보안기능 1. **적절한 인증 없는 중요기능 허용**(p.212), 개요: "적절한 인증과정이 없이 중요정보(계좌이체 정보, 개인정보 등)를 열람(또는 변경)할 때 발생하는 보안약점이다." 참고 CWE-306 (PDF 대조)
  - 보안기능 2. **부적절한 인가**(p.215), 개요: "프로그램이 모든 가능한 실행경로에 대해서 접근제어를 검사하지 않거나 불완전하게 검사하는 경우, 공격자는 접근 가능한 실행경로로 정보를 유출할 수 있다." 참고 CWE-285. C# 예제 "운영자 권한 검사 없이 컨트롤러와 내부의 개별액션에 접근이 가능한 C# 코드이다." (PDF 대조)
  - 부록 한 줄 설명: "부적절한 인가: 중요자원에 접근할 때 적절한 제어가 없어 비인가자의 접근이 가능한 보안약점" (PDF 대조)
  - ⚠️ 엇갈림: "적절한 인증 없는 중요기능 허용"의 Java 예제는 인증 부재가 아니라 "회원정보 수정 시 수정을 요청한 사용자와 로그인한 사용자의 일치 여부를 확인하지 않고 처리"하는 소유자 불일치 사례라, OWASP 기준으로는 BOLA 쪽에 가까움(하위 에이전트 관찰). 항목명만으로 OWASP의 객체 수준과 기능 수준을 대응시키기 어려움
- 구현 단계 49개 기준의 근거: 「행정기관 및 공공기관 정보시스템 구축 운영 지침」(정식 명칭은 '구축'과 '운영' 사이에 가운뎃점, 행정안전부고시 제2025-1호) 제52조와 별표 3. https://www.law.go.kr/LSW/admRulInfoP.do?admRulSeq=2100000252582 (별표 3에 "총 49개" 문구는 없고 하위 에이전트가 센 값. 가이드 2021 표 2-1에는 "구현단계 보안약점 제거 기준(총 49개 항목)" 문구가 있음)
- 영상의 "정부가 무료로 배포하는 소프트웨어 개발 보안 가이드"는 이 문서로 확인됨

### C-5. 따릉이를 어디에 분류하는가 (판단 근거)

| 사실관계 | CWE | OWASP | KISA 구현 / 설계 |
|---|---|---|---|
| 신원 확인 없이 익명 호출이 응답함 (경찰 설명에 가장 가까움) | CWE-306 | API5(익명 포함), A01 시나리오 | 적절한 인증 없는 중요기능 허용 / SR2-1 |
| 다른 경로엔 로그인이 있는데 이 API만 인증을 건너뜀 | CWE-288 | API5, A01 시나리오 | 같음 |
| 일반 회원 토큰으로 관리자 기능이 호출됨 | CWE-862 또는 425 | API5, A01 | 부적절한 인가 / SR2-4 ③ |
| 일반 조회 API에 남의 식별자를 넣어 열거함 | CWE-639 | API1(BOLA), A01 | (항목명으로는 애매) |

- 공개 기록으로는 첫 행이 가장 가깝지만, 엔드포인트가 관리자 기능이었는지 회원 조회였는지가 공개되지 않아 행을 확정할 수 없음(D-4)
- 글에서 "API5"로 부르는 것은 정의상 무리가 없음(익명 포함, 전체 회원 반환 시나리오). 다만 "CWE-862"로 부르는 것은 경찰 설명(인증 토큰 검증 부재)과 어긋날 수 있음

---

## 근거 E-S: Spring Security 동작 (외부, 태그 고정 소스와 문서)

> 기준: Spring Boot 3.5.16 = Spring Security 6.5.11 = Spring Framework 6.2.19. 6.x 마지막 패치가 6.5.11이고 현재 최신은 7.1.1. docs.spring.io에는 6.5, 7.0, 현재판만 남아 있고 6.0~6.4, 5.8 경로는 404라 그 판본은 GitHub 태그의 asciidoc 원본을 기준으로 함. 문서 인용은 asciidoc 원본 그대로이며 렌더 페이지에서는 `It's`가 굽은 따옴표로 보임. **앱을 띄워 실행하지는 않음.** 아래 ★ 표시는 리서치 단계에서 태그 고정 원본을 직접 받아 grep으로 대조한 것

### E-S1. 버전별 동작표

| 동작 | 5.5.0 ~ 5.8.0 | 6.0.0 ~ 6.5.11 | 7.0.0 |
|---|---|---|---|
| `authorizeHttpRequests`에서 어떤 매처에도 안 맞는 요청 | `null`(abstain) 반환, 필터 통과 | `DENY` 반환, 거부 | `DENY` |
| `AuthorizationFilter`가 null을 받았을 때 | 통과 | 통과(코드 동일) | 통과 |
| 인가 대상 디스패치 | 요청당 1회, ERROR와 ASYNC 제외 | 모든 디스패치 | 모든 디스패치 |
| `anyRequest()` 뒤에 매처 추가 | 예외 | 예외 | 예외 |
| 매핑 0개 | 예외 | 예외 | 예외 |
| `anyRequest` 누락 | 경고 없음, 예외 없음 | 경고 없음, 예외 없음 | 동일 |
| 레거시 `authorizeRequests()`의 미매칭 요청 | 통과 | 통과(6.1부터 deprecated) | API 제거 |

### E-S2. 미매칭 요청: 5.8까지 허용, 6.0부터 거부 ★

- 5.8.0 마이그레이션 가이드(https://github.com/spring-projects/spring-security/blob/5.8.0/docs/modules/ROOT/pages/migration/servlet/authorization.adoc?plain=1#L651-L658) ★:
  > In Spring Security 5.8 and earlier, requests with no authorization rule are permitted by default.
  > It is a stronger security position to deny by default, thus requiring that authorization rules be clearly defined for every endpoint.
  > As such, in 6.0, Spring Security by default denies any request that is missing an authorization rule.
  
  같은 절이 권하는 마지막 규칙은 `denyAll`: "The recommendation is ... `denyAll` since that is the implied 6.0 default." (원문은 링크 마크업 포함, 위치만 표시)
- 소스 `web/src/main/java/org/springframework/security/web/access/intercept/RequestMatcherDelegatingAuthorizationManager.java`
  - 5.8.0 L85-L86 ★: `this.logger.trace("Abstaining since did not find matching RequestMatcher");` 다음 `return null;`
  - 6.5.11 L95-L97 ★: `this.logger.trace(LogMessage.of(() -> "Denying request since did not find matching RequestMatcher"));` 다음 `return DENY;` (DENY는 L52 `new AuthorizationDecision(false)`)
  - 변경 커밋 `753e113a13aa6ad71791129510d2c17dd8fd22ed` "RequestMatcherDelegatingAuthorizationManager defaults to deny" (2022-10-13, Closes gh-11958, 마일스톤 6.0.0-RC1). https://github.com/spring-projects/spring-security/issues/11958 원문: "In Spring Security 5, the default `AuthorizationManager` for `RequestMatcherDelegatingAuthorizationManager` abstains. This default should be changed to instead deny."
- `AuthorizationFilter`는 5.8.0부터 7.0.0까지 **null이면 예외 없이 `chain.doFilter`**. 6.5.11 L96-L101: `if (result != null && !result.isGranted()) { throw new AuthorizationDeniedException("Access Denied", result); }` 다음 `chain.doFilter(request, response);` 그래서 5.x에서는 "미매칭이면 null, 그대로 통과"
- 레거시 `authorizeRequests()`(`FilterSecurityInterceptor` 계열)는 6.x에서도 미매칭 통과: `AbstractSecurityInterceptor.java` 6.5.11 L140 `private boolean rejectPublicInvocations = false;`, L201-L212에서 속성이 비면 `"Authorized public object %s"`를 남기고 통과. `HttpSecurity.authorizeRequests()`는 `@Deprecated(since = "6.1", forRemoval = true)`, 7.0에서 제거
- `anyRequest` 누락을 따로 경고하거나 막는 코드는 없음(6.5.11의 관련 세 클래스 grep 기준). 매핑 0개일 때만 `"At least one mapping is required (for example, authorizeHttpRequests().anyRequest().authenticated())"` 예외. **예외 메시지가 예로 드는 마지막 줄이 `authenticated()`라는 점**은 관찰해 둘 만함(`AuthorizeHttpRequestsConfigurer.java` 6.5.11 L169-L170)
- `anyRequest()` 뒤 매처 추가 시 `"Can't configure requestMatchers after anyRequest"` (`AbstractRequestMatcherRegistry.java` 6.5.11 L176-L179)

### E-S3. 규칙 순서와 default-deny 권장 (6.5.11 레퍼런스) ★

- https://docs.spring.io/spring-security/reference/6.5/servlet/authorization/authorize-http-requests.html (adoc: https://github.com/spring-projects/spring-security/blob/6.5.11/docs/modules/ROOT/pages/servlet/authorization/authorize-http-requests.adoc?plain=1)
- L231 ★: "`AuthorizationFilter` processes these pairs in the order listed, applying only the first match to the request." (6.1.0부터 있는 문장)
- L497 ★: "Denying the request by default is a healthy security practice since it turns the set of rules into an allow list." (TIP, 6.1.0부터)
- L765-L766 ★: "<6> Any URL that has not already been matched on is denied access. This is a good strategy if you do not want to accidentally forget to update your authorization rules." (`.anyRequest().denyAll()`에 붙은 callout)
- L8: "By default, Spring Security requires that every request be authenticated."
- L48: "This tells Spring Security that any endpoint in your application requires that the security context at a minimum be authenticated in order to allow it."
- ⚠️ 6.5.11 레퍼런스 본문에는 "anyRequest를 빼면 6.0부터 거부된다"는 명시 문장이 없음. 그 설명은 5.8 마이그레이션 가이드에만 있음
- **"`anyRequest().authenticated()`면 로그인한 누구나 관리자 API에 닿는다"를 직접 경고하는 공식 문장은 없음** (6.5.11 docs 전체 grep, 확정)

### E-S4. Spring Boot 기본 체인이 바로 그 마지막 줄이다 ★

- `SpringBootWebSecurityConfiguration.java` v3.5.16 L55-L62(https://github.com/spring-projects/spring-boot/blob/v3.5.16/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/security/servlet/SpringBootWebSecurityConfiguration.java#L55-L62). L58 ★:
  ```java
  			http.authorizeHttpRequests((requests) -> requests.anyRequest().authenticated());
  ```
- 의미: 6.0이 미매칭을 거부로 바꿨지만, Boot의 기본 체인과 그것을 본뜬 설정은 마지막 줄에 `authenticated()`를 둬서 **선언하지 않은 모든 엔드포인트를 "로그인하면 허용"으로 채움**. 6.0의 기본 거부는 `anyRequest`를 아예 안 썼을 때만 작동함(필자 해석, 위 소스와 문서에서 도출)

### E-S5. 메서드 보안은 붙인 곳만 지킨다 ★

- https://docs.spring.io/spring-security/reference/6.5/servlet/authorization/method-security.html (adoc 6.5.11)
- L37-L38 ★: "Spring Boot Starter Security does not activate method-level authorization by default." (adoc 원문은 링크 마크업 포함)
- L305-L307 ★: "It's important to remember that when you use annotation-based Method Security, then unannotated methods are not secured. To protect against this, declare a catch-all authorization rule in your `HttpSecurity` instance." (adoc 원문은 `xref:` 마크업 포함. 6.1.0부터)
- `@EnableMethodSecurity`가 `@Import(MethodSecuritySelector.class)`로 `PrePostMethodSecurityConfiguration`을 들여와야 `@PreAuthorize` 인터셉터가 등록됨(6.5.11 소스 구조). "선언하지 않으면 무시된다"는 문장 자체는 문서에 없고 구조에서 나오는 결론
- 이어지는 함정(필자 해석): 문서가 권하는 대책은 "catch-all 규칙을 선언하라"인데, 그 catch-all이 `authenticated()`면 애노테이션을 빠뜨린 관리자 메서드는 로그인한 누구에게나 열림. 문서는 authenticated와 denyAll의 차이를 이 자리에서 다루지 않음

### E-S6. 필터 체인을 아예 안 타는 경로 ★

- `WebSecurity.java` 6.5.11 L312-L313 ★: `"You are asking Spring Security to ignore " + ignoredRequest + ". This is not recommended -- please use permitAll via HttpSecurity#authorizeHttpRequests instead."` (`web.ignoring()`이 남기는 경고. 무시된 경로는 인증 자체가 없음. 따릉이형 "인증 없이 응답"이 Spring에서 생기는 길 중 하나)
- 문서 L81: "This means that Spring Security's authentication filters, exploit protections, and other filter integrations do not require authorization." (`AuthorizationFilter`보다 앞의 필터가 응답하는 경로는 인가를 거치지 않음. 링크 마크업 제외)

---

## 근거 E-T: 테스트로 잠그는 공개 패턴 (외부)

### E-T1. 공식 문서는 인벤토리 테스트를 권하지 않는다

- 6.5.11 Spring Security 문서 전체에서 `ArchUnit`, `getHandlerMethods`, `HandlerMapping` grep 결과 `HandlerMappingIntrospector` 언급 외 0건 (하위 에이전트, 확정)
- `getHandlerMethods()` Javadoc (`AbstractHandlerMethodMapping`, Spring Framework v6.2.19 L144-L147): "Return a (read-only) map with all mappings and HandlerMethod's." https://github.com/spring-projects/spring-framework/blob/v6.2.19/spring-webmvc/src/main/java/org/springframework/web/servlet/handler/AbstractHandlerMethodMapping.java#L144-L147

### E-T2. 공개 사례 (하위 에이전트가 커밋 고정 URL로 확인, 리서치 단계 직접 대조 안 함. Artemis는 verifier가 원본 대조, 검증 기록 V-33)

- **ls1intum/Artemis** (TUM, MIT). 두 겹으로 잠금
  - ArchUnit 규칙 `everyRestEndpointMustBeAuthorized` (PR #12855, 커밋 `3c46125d34b791195ed2abc61da6744c274aa7e3`, 2026-06-06). https://github.com/ls1intum/Artemis/blob/07f43f8e0b71037881624546c9dcf779498728ff/src/test/java/de/tum/cit/aet/artemis/core/authorization/AuthorizationArchitectureTest.java#L228-L263 . 이유 문자열: `"every REST endpoint must declare an Artemis authorization annotation (or be covered by class-level enforcement) so authorization cannot be forgotten"`
  - 허용 목록에 `@EnforceNothing`, `@Internal`, `@ManualConfig`가 있음. 즉 **공개 엔드포인트도 "공개"라고 선언해야 통과**(애노테이션 없음은 실패). 같은 파일 L112-L115 주석이 액추에이터 사각지대를 직접 언급: `{@code /management/**} asks for elevation explicitly because no annotated handler` / `serves the actuator endpoints.`
  - 런타임 인벤토리: `requestMappingHandlerMapping.getHandlerMethods()`로 전체 매핑을 뽑아 `testAllEndpoints`. https://github.com/ls1intum/Artemis/blob/07f43f8e0b71037881624546c9dcf779498728ff/src/test/java/de/tum/cit/aet/artemis/core/authorization/AuthorizationGeneralAndIndependentEndpointTest.java#L26-L35
  - 관찰(코드 사실): 이 런타임 테스트의 `checkForPath`는 인가 애노테이션이 0개거나 2개 이상이면 "이미 로그를 남겼다"는 주석과 함께 `return`함. 누락 검출은 실제로는 ArchUnit 규칙이 맡음. **인벤토리 테스트 자체도 틀린 이유로 통과할 수 있다는 실물 사례**로 쓸 수 있으나, 남의 프로젝트를 깎아내리는 구도로는 쓰지 말 것
- **dir-IQ/ldapportal-core** (Apache-2.0, Boot 3.5.16, 스타 0): 기동 시점 fail-fast 가드. https://github.com/dir-IQ/ldapportal-core/blob/16674f295d7a2372d623eeacdd7e80124e87ab75/core/src/main/java/com/ldapportal/auth/AuthAnnotationValidator.java#L69-L97 . Javadoc이 "누락하면 catch-all로 조용히 떨어진다"를 정확히 적음: `Endpoints under that prefix touch a specific directory and would otherwise silently fall through to the {@code SecurityConfig} catch-all that admits any {@code ADMIN} or {@code SUPERADMIN}, defeating per-feature gates.` 생성자 주석은 액추에이터가 두 번째 `RequestMappingHandlerMapping`(`controllerEndpointHandlerMapping`)을 등록하므로 `@Qualifier`가 필요하다고 씀. ⚠️ 스타 0 개인 프로젝트라 "업계 관행"의 근거로는 약함. 구조 예시로만
- Steven Schwenke, "Using Meta-Annotations in Spring MVC Controllers" (2022-10-21). https://stevenschwenke.de/usingMetaAnnotationsInSpringMVCControllers . ArchUnit으로 "모든 `@RestController` 메서드는 권한 메타 애노테이션을 가져야 한다"를 거는 규칙. 이유 문자열 `"every accessible method should define permissions for usage"`
- Baeldung "Deny Access on Missing @PreAuthorize to Spring Controller Methods": 본문은 Cloudflare 403으로 못 읽음(확정하지 못함). 예제 코드(eugenp/tutorials)는 런타임에 "애노테이션 없으면 거부"를 거는 방식이나 하드코딩이 있어 범용 인용에 부적절

### E-T3. 인벤토리의 사각지대 (`getHandlerMethods()`가 못 담는 것)

- `requestMappingHandlerMapping` 빈의 `getHandlerMethods()`는 그 인스턴스에 등록된 `@RequestMapping` 핸들러만 돌려줌(인스턴스 필드 `mappingRegistry` 기준, 소스로 확정)
- **Actuator**: 별도 빈 `webEndpointServletHandlerMapping`(`WebMvcEndpointHandlerMapping`, Boot v3.5.16 `WebMvcEndpointManagementContextConfiguration.java` L81-L84). `@ControllerEndpoint`용 `ControllerEndpointHandlerMapping`은 `RequestMappingHandlerMapping`의 하위 타입이지만 별도 빈이고 3.3.5부터 deprecated
- Boot 3.5 문서(https://docs.spring.io/spring-boot/3.5/reference/actuator/endpoints.html): "By default, only the health endpoint is exposed over HTTP and JMX." 그리고 "If Spring Security is on the classpath and no other `SecurityFilterChain` bean is present, all actuators other than `/health` are secured by Spring Boot auto-configuration. If you define a custom `SecurityFilterChain` bean, Spring Boot auto-configuration backs off and lets you fully control the actuator access rules." (adoc 원문은 javadoc 마크업 포함). **커스텀 체인을 만드는 순간 액추에이터 접근 규칙도 내 몫**이 된다는 점이 이 글에 맞음
- **함수형 엔드포인트**: `RouterFunctionMapping`은 `AbstractHandlerMapping` 계열이라 별도 빈 `routerFunctionMapping`(Framework v6.2.19)
- **정적 리소스**: `resourceHandlerMapping`. springdoc의 swagger-ui 정적 파일도 `ResourceHandlerRegistry`로 등록돼 인벤토리에 안 잡힘. `/v3/api-docs`는 `@RestController`라 잡힐 것으로 보이나 실행 확인 안 함
- **필터가 직접 응답하는 경로**: `/logout`(`LogoutFilter`가 `AuthorizationFilter`보다 앞), 로그인 처리 등
- **별도 서블릿**: H2 콘솔(`ServletRegistrationBean`)은 DispatcherServlet 바깥
- 대응: 인벤토리 테스트는 "이 목록이 무엇을 못 보는가"를 테스트 옆에 적어 두거나, 커스텀 체인의 마지막 줄을 `denyAll()`로 두어 목록 밖 경로도 기본 거부로 떨어지게 하는 이중 장치가 필요(필자 해석)

### E-T4. 403 단언이 틀린 이유로 통과하는 경로 ★(CSRF 문장)

- CSRF는 기본 활성: "Spring Security protects against CSRF attacks by default for unsafe HTTP methods, such as a POST request, so no additional code is necessary." (servlet/exploits/csrf.adoc L7, 링크 마크업 제외)
- 테스트 문서 ★: "When testing any non-safe HTTP methods and using Spring Security's CSRF protection, you must include a valid CSRF Token in the request." (servlet/test/mockmvc/csrf.adoc L4, 6.0.0, 6.5.11, 7.0.0 동일. 요청 문안의 "you must be sure to include"는 원문에 없음) https://docs.spring.io/spring-security/reference/6.5/servlet/test/mockmvc/csrf.html
- 토큰이 없으면 `CsrfFilter`(6.5.11 L125-L132)가 `ExceptionTranslationFilter`를 거치지 않고 `AccessDeniedHandler`를 직접 불러 **역할과 무관하게 403**. 즉 `@WithMockUser(roles="USER")`로 `post("/admin/...")`를 `.with(csrf())` 없이 보내 403을 단언하면, **관리자 규칙을 지워도 초록불**(소스로 도출, 실행 확인 안 함)
- 인증 안 된 요청의 상태 코드는 구성에 따라 갈림(`ExceptionHandlingConfigurer` 6.5.11 L236-L247): 인증 DSL을 하나도 안 켜면(커스텀 JWT 필터만 둔 경우 등) 기본 entry point가 `Http403ForbiddenEntryPoint`라 **익명 요청도 403**. httpBasic이면 401, formLogin만이면 302, Boot 기본처럼 둘 다면 Accept 헤더에 따라 302 또는 401. 따라서 "권한 없음 403" 테스트가 "인증 없음"과 구분되지 않는 구성이 흔함(소스로 도출, **실행 확인 안 함**)
- 공식 문서 예제의 403 테스트(authorize-http-requests.adoc `#authorizing-endpoints`)는 `@WithMockUser`와 `status().isForbidden()`, 비인증에 `isUnauthorized()`를 씀. `@WithMockUser(roles=...)`와 `isForbidden()`이 한 예제에 같이 나오는 공식 예시는 없음
- 참고(낮은 우선순위): 6.5.11 문서의 `postWhenNoWriteAuthorityThenForbidden` 예제는 이름과 달리 `get("/any")`를 보내 규칙대로면 허용돼야 하는 요청에 403을 기대함. 7.1.1에서 `post`로 고쳐짐(하위 에이전트가 두 렌더 페이지 대조). 공식 예제의 403 단언도 판본 사이에 고쳐졌다는 일화로만 쓸 수 있음

### E-T5. OWASP ASVS (보조)

- 4.0.2 V4 4.1.4 "deny by default" 항목은 4.0.3에서 "[DELETED, DUPLICATE OF 4.1.3]"로 삭제됨. 5.0.0 V8에는 "deny by default" 문구 없음, 가장 가까운 것은 8.2.1 "Verify that the application ensures that function-level access is restricted to consumers with explicit permissions." https://github.com/OWASP/ASVS/blob/v5.0.0_release/5.0/en/0x17-V8-Authorization.md (하위 에이전트 확인). 본문에 꼭 필요하지 않음

---

## 근거 E-A: AI 자동화가 바꾼 것 (도입부 맥락용, 좁게)

> 이 절은 도입부 한두 문단의 재료입니다. 본론이 아닙니다. ★는 리서치 단계 직접 대조

### E-A1. 영상의 "알텍스"는 ARTEX

- 저장소 `Autumn-27/ARTEX`, 생성 2026-07-26, AGPL-3.0, 설명 "AI 自主渗透测试系统 | 百度“agent+”攻防挑战赛冠军项目" ★(GitHub API 직접 조회). https://github.com/Autumn-27/ARTEX
- 바이두 보안응급대응센터(BSRC)가 주최한 「Agent+」攻防能力挑战赛(공지 2026-08-13, https://anquan.baidu.com/article/2010), 결선 2026-09-03 청두. 종합 1위이나 실전 공격 환경 단독 점수는 7위(하위 에이전트, 중국어 2차 사본 경유). "가장 잘 뚫는 도구"로 읽으면 과장
- 한국 언론은 "아르텍스"로 표기. 헤럴드경제 단독(2026-10-03)이 금융보안원 관계자 익명 발언으로 신한은행 로그 역추적에서 "아르텍스를 활용한 흔적"을 보도, 같은 관계자가 "사람의 개입 없이 AI가 독자적으로 공격하지는 않았다"고 함(https://v.daum.net/v/uJkyV2OctK). **규제기관의 공식 귀속은 없음**(American Banker 2026-10-06 "No regulator has publicly named ARTEX as being involved in the attack."). CrowdStrike 분석(로이터 10/8)은 "moderate confidence"

### E-A2. 2026년 가을 금융권 사고 (보도 1주일차, 사실 유동)

- 한국일보 2026-10-01 ★(https://www.hankookilbo.com/news/article/A2026100115320000186): 신한은행 공개 문안 "외부의 비인가자가 인증을 우회하는 비정상적인 방법으로 일부 서비스에 접근해 고객의 개인정보를 유출한 사실을 확인했다". 경로는 "이번 공격은 대출 모집인을 위해 제공하는 모바일 웹페이지에서 시작된 것으로 전해졌다." 그리고 "여기서 확보한 고객 번호를 기반으로 연락처, 생년월일 등을 조회할 수 있는 다른 서비스에 접근해 고객정보를 추가로 탈취한 것으로 알려졌다. 공격 대상은 홈페이지를 통한 간편 조회 서비스로, 로그인 인증이 필요한 뱅킹 서비스가 해킹된 것은 아닌 것으로 전해졌다."
- **이 글과의 연결**: 따릉이와 같은 모양. 핵심 시스템이 아니라 **주변 조회 서비스**, 그리고 한 서비스에서 얻은 식별자로 **다른 조회 서비스**를 연쇄 호출. 보도가 1주일차라 세부는 바뀔 수 있으므로 도입부에서 한 문단 이내, "보도에 따르면"으로
- 피해 업권: 은행, 저축은행, 캐피탈(시사저널e "최소 7곳"). **증권사 피해는 확인되지 않음**(글로벌이코노믹 10/6, 뉴스핌 10/7). 영상의 "증권사 포함"은 침투 흔적 수준 서술일 수 있으나 유출 피해로는 미확인
- 영상의 "피해 기업은 모두 ISMS-P 인증 기업": 부분적으로만 맞음. 신한은 보유(뚫린 시스템이 인증 범위 안인지 확인 중), KB와 하나는 뚫린 시스템이 인증 범위 밖, 예가람저축은행 등은 ISMS 미인증(헤럴드경제 10/7, 이투데이 10/8)
- 영상의 "개인정보위가 공공 시스템 점검 강화, ISMS-P 보완 대책": 대책은 실재하나 **모두 이번 사고 이전**(공공 집중관리시스템 점검 2026-03-26, ISMS-P 실효성 강화 2026-04-10, 시행령 입법예고 2026-09-16~10-26). 사고 후 개인정보위는 신한, 예가람 건을 '중요사건'으로 지정(아이뉴스24 10/8)

### E-A3. "공격 비용이 내려가면 털 가치 없던 시스템도 털 가치가 생긴다" (공개 자료로 뒷받침됨)

- Carlini et al., "LLMs unlock new paths to monetizing exploits", arXiv 2505.11449 (2025-05-16) ★초록 대조: "We argue that Large language models (LLMs) will soon alter the economics of cyberattacks." 그리고 "instead of human attackers manually searching for one difficult-to-identify bug in a product with millions of users, LLMs can find thousands of easy-to-identify bugs in products with thousands of users." https://arxiv.org/abs/2505.11449 . **영상의 "1,000원짜리 정보에 2,000원을 쓸 수 없다"(방어 비용 논리)와 정면으로 긴장하는 근거**: 공격 비용 쪽 분모가 바뀌면 "털 가치가 없다"는 계산이 바뀜
- Fang et al., "LLM Agents can Autonomously Exploit One-day Vulnerabilities", arXiv 2404.08144: "With an average overall success rate of 40%, this would require $8.80 per exploit." ⚠️ 87% 성공률은 CVE 설명을 준 조건의 수치라 비용 계산(평균 40%)과 섞지 말 것 (하위 에이전트 확인)
- 영국 NCSC, "Impact of AI on cyber threat from now to 2027" (2025-05-07): "To 2027, this will highly likely increase the volume and impact of cyber intrusions through evolution and enhancement of existing TTPs, rather than creating novel threat vectors." https://www.ncsc.gov.uk/report/impact-ai-cyber-threat-now-2027 (하위 에이전트 확인. verifier가 원본과 게시일 대조, 검증 기록 V-5). **영상의 "기법이 아니라 범위가 바뀌었다"와 같은 판단을 공적 기관이 낸 것**
- Anthropic, "Disrupting the first reported AI-orchestrated cyber espionage campaign" (2025-11-13): "The barriers to performing sophisticated cyberattacks have dropped substantially" https://www.anthropic.com/news/disrupting-AI-espionage (하위 에이전트 확인). 필자 블로그가 AI 회사의 보고서를 인용하는 맥락이 어색하면 NCSC와 Carlini로 충분

---

## 근거 I: 내부 (이 저장소, 1차)

> 사내 코드와 경험은 쓰지 않습니다. 아래는 전부 공개 저장소의 파일, 커밋, 발행본입니다. 발행본 인용은 그 시점의 기록이라 소급 수정하지 않습니다(`CLAUDE.md` 포스트 규칙).

### 독자 스택 가정

- 이 블로그는 Spring을 이미 다룹니다. 테스트 기준 2편 태그 `[테스트, Spring, 코드품질]`(`_posts/2026-08-11-test-standards-2-spring-context.md:6`), `spring-test` 6.1.11과 6.2.9 소스 원문 인용. 레이트리미터 편 태그는 `Java`
- Spring Security를 다룬 발행본은 **없습니다**(`grep` 0건). 이 글이 첫 Spring Security 글
- 2편 각주(`:614`)가 "모듈마다 Spring Boot 버전이 2.7.x부터 3.5.x까지 공존"한다고 이미 공개적으로 적었습니다. 독자층에 Spring Security 5.x(Boot 2.7)와 6.x(Boot 3)가 섞여 있다고 보는 게 맞고, **E-S1의 버전 차이가 이 글에서 실제로 의미가 있습니다**
- 태그 후보: `보안`(신규, 주제라 한국어), `Spring`(기존 표기 유지. `Spring Security`로 새로 만들면 아카이브가 갈림), `테스트`(기존)

### I-1. 이 블로그도 "기본 허용"으로 사고가 났었다 (#18)

- 커밋 `d20067e` (2026-07-17) 메시지 첫 줄: "_config.yml의 exclude에 test가 없어 계약 테스트 파일이 그대로 발행되고 있었다". 공개 URL은 같은 메시지에 `https://seokrae.github.io/blog/test/...`로 적혀 있음
- 구조: Jekyll은 `exclude` 목록에 **없는** 파일을 전부 발행합니다. 목록이 차단 목록이라 새로 생긴 디렉터리는 **아무도 결정하지 않았는데 공개**됩니다. 수정도 `_config.yml:77`에 `- test` 한 줄을 더한 것이라 여전히 차단 목록 방식입니다(`_config.yml:70-77`). Spring Security 문서의 TIP(E-S3, "turns the set of rules into an allow list")과 정확히 반대편
- 같은 계열 두 번째: `CLAUDE.md:28` "`_config.yml`의 `exclude`는 **이 저장소의 파일에만 먹고 테마 fall-through 파일에는 안 먹는다** (실험으로 확인)". 차단 목록은 **내가 쓴 것**에만 걸리고 다른 출처(원격 테마)에서 들어온 파일은 못 막음. 엔드포인트로 옮기면 "내가 만든 컨트롤러에만 규칙을 걸었는데 라이브러리가 등록한 경로(액추에이터 등)는 규칙 밖"과 같은 모양(필자 유비. 사실 근거는 E-T3)
- ⚠️ #18은 테스트 기준 3편이 이미 다뤘습니다(`_posts/2026-08-11-test-standards-3-delegating-standards.md:319-341`, 절 제목 "실패를 확인한 단언 하나"). 3편의 각도는 "검사기가 자기 최적화 때문에 자기를 못 봤다"와 "빨간불을 실제로 확인했다"였고, **"exclude가 차단 목록이라 기본이 공개"라는 각도는 쓰지 않았습니다.** 이 글은 그 각도만 가져오고 3편 서술을 되풀이하지 않는 편이 좋습니다

### I-2. 이 블로그의 계약 테스트도 "엔드포인트마다 선언" 모양이다

- `CLAUDE.md:26`은 "외부 요청 없는 페이지"를 계약으로 들고 "이 계약들은 **`test/site_output_test.rb`에 잠겨 있다.**"라고 씁니다
- 실제 부정 단언은 **페이지를 이름으로 골라서** 겁니다. 외부 스타일시트, 스크립트 부정 단언이 걸린 대상은 `index`(:75), `search`(:81), `flowcast_post`(:108-109), `rate_limiter_post`(:124-127), `jev_post`(:136-139), `jev_intro_post`(:160-163) 여섯뿐. 생성된 `_site` 전체를 훑는 반복(`Dir.glob` 등)은 파일에 **없음**
- 레이아웃(`head.html` 등) 수준의 외부 요청은 `index`와 `search`로 덮이므로 공용 부분은 사실상 잠겨 있습니다. 빈 곳은 **본문 임베드**입니다. 발행본 11편 중 본문 단언이 걸린 글은 임베드가 있는 4편이고, 나머지 7편과 about, tags, 404에 외부 스크립트를 넣어도 테스트는 통과합니다(2026-10-08 확인 시점에 실제 위반은 없음. `_posts`와 페이지 소스 `grep` 결과 0건)
- 그 단언들이 생긴 방식이 이력에 있습니다. 임베드 글이 들어올 때마다 **그 글 전용 부정 단언을 손으로 추가**했습니다. `e8d7920`(#36, flowcast), `164f512`(#82, 레이트리미터), `68a73a0`(#111, Jev), `6b2fabd`(#115, Jev 입문). 네 번 다 기억해서 넣었고, 다섯 번째를 잊으면 아무것도 실패하지 않습니다
- 연결: 이것이 "엔드포인트를 추가할 때마다 그 엔드포인트의 인가 테스트를 하나씩 쓴다"와 같은 모양입니다. 테스트가 **목록**이 아니라 **기억**에 묶여 있습니다
- ⚠️ 테스트 기준 1편은 이 테스트의 외부 요청 단언을 의도적으로 지킨 계약의 예로 들었습니다(`_posts/2026-08-11-test-standards-1-what-to-test.md:218`과 그 뒤 표의 "외부 스타일시트 등장" 행). 그 평가는 단언 하나하나의 강도에 대한 것이라 틀리지 않았고, 이 글이 보태는 것은 **단언이 걸린 범위**입니다. 1편을 반박하는 구도로 쓰지 말 것

### I-3. 테스트 기준 3부작에서 이어지는 문장 (원문, 발행본)

- 1편 주제 질문: "**"무엇이 바뀌면 이게 실패해야 하는가."**" (`test-standards-1:295`). 목록 대조 테스트의 답은 "정책을 선언하지 않은 엔드포인트가 하나라도 생기면", 역할별 403 테스트의 답은 "이 역할이 이 기능에 닿게 되면"
- 1편 체크리스트: "**부정 단언이라면, 틀린 이유로 통과할 경로가 몇 개인가.** `never()`는 코드가 그 분기에 도달조차 못 했을 때도 통과합니다." (`:476`). 403 단언은 부정 단언. CSRF가 먼저 막아도, entry point가 익명을 403으로 보내도 초록불(E-T4)
- 1편 결론: "**다섯째, 무엇이 안 덮이는지 아는 것이 경계입니다.**"로 시작해 "목표치보다 제외 규칙이 더 많은 판단을 담고 있었습니다."로 끝나는 문단 (`:466`). 목록 대조 테스트에서 판단을 담는 곳도 **공개 예외 목록**(Artemis의 `@EnforceNothing` 같은 것)
- 1편: "**테스트 스위트의 경계가 곧 그 스위트가 볼 수 없는 결함의 범위입니다.**" (`:431`)
- 3편 체크리스트: "**그 검사기가 못 보는 집단은 무엇인가.**" (`test-standards-3:382`). `RequestMappingHandlerMapping` 인벤토리가 못 보는 집단이 E-T3
- 3편 체크리스트: "**이 게이트가 실제로 빨간불이 된 적이 있는가.** 없다면, 하나라도 일부러 깨뜨려 실패를 확인해 봅니다." (`:387`). 정책 없는 더미 엔드포인트 하나로 실패를 먼저 확인하라는 근거
- 3편 결론: "**일곱째, 한 번도 빨간불이 된 적 없는 게이트는 작동을 증명한 적이 없습니다.**" (`:357`)
- 2편 결론: "**첫째, 검사하기 쉬운 기준이 하나 있으면 그게 유일한 기준인 것처럼 작동합니다.**" (`test-standards-2:583`). 인가에서 검사하기 쉬운 기준은 "로그인했는가"(`authenticated()`). 그게 유일한 기준처럼 작동하면 로그인한 누구나 관리자 기능에 닿음(필자 유비)

### I-4. AGI 편: 목록 대조로 걸린 규칙 위반

- "규칙은 적혀 있었고, 한 편에서만 조용히 안 지켜졌고, 그 사실이 일곱 주 남짓 아무에게도 걸리지 않았습니다. 규칙을 적는 것과 규칙이 돌아가는 것은 다른 일입니다. 그리고 이 건도 정독으로 발견된 게 아니라 발행본과 노트 목록을 대조하다 걸렸습니다." (`_posts/2026-09-08-agi-word-to-gate.md:242`)
- 연결: "발행본 목록 대 리서치 노트 목록" 대조가 #16 계약 위반을 찾았습니다(`CLAUDE.md` 변경 이력 2026-09-08 #101 행). "엔드포인트 목록 대 정책 표" 대조가 같은 일을 합니다. 이 블로그가 이미 한 번 효과를 본 방법

### I-5. 레이트리미터 편: 적용 범위, 기본값, 축 (발행본 본문만)

- "**완벽한 알고리즘도 안 걸린 경로는 못 막습니다.** Token Bucket이냐 Sliding Window냐를 고민하기 전에, 적용 범위부터 그렸어야 했습니다." (`_posts/2026-08-09-rate-limiter-payment-platform.md:539`). 인가로 옮기면 규칙 문법(`hasRole`, SpEL)을 고민하기 전에 **규칙이 걸린 범위**부터
- "그러니까 트레이드오프를 고르는 것보다 먼저 해야 할 일은, **지금 무엇이 나 대신 골라져 있는지 확인하는 것**입니다. 라이브러리 기본값이 곧 정책이니까요." (`:631`). 미매칭 요청 처리(E-S2)와 Boot 기본 체인(E-S4)이 "나 대신 골라진 것"
- "조금 더 넓혀 보면, 이 사고는 "기능을 구현했는가"와 "위험을 통제하고 있는가"가 서로 다른 질문이라는 이야기이기도 합니다." (`:633`). 따릉이 조회 API는 기능으로는 정상 동작했음
- "### 2. 키를 무엇으로 하는가" (`:541`). 리미터 키가 계정이려면 요청에 인증된 주체가 있어야 함. 인증 없이 응답하는 엔드포인트에서 리미터가 쓸 수 있는 키는 IP 정도(필자 추론)
- "그리고 하나 더. **"초당 몇 건"(속도)과 "동시에 몇 개"(동시성)는 다른 축입니다.**" (`:599`). 이 블로그는 이미 "한 장치로 다른 축을 막으려 하지 말라"는 논지를 한 번 썼음. 이 글의 "얼마나 많이" 대 "누가 무엇을"은 그 연장선
- ⚠️ 레이트리미터 편의 사내 정보(`rate-limiter-payment-platform.sources-internal.md`)는 쓰지 않음. 위 문장은 전부 발행본 본문

### I-6. 하네스 책 리뷰 편: 허용 목록이 금지 문장보다 강하다

- "그 약속의 실체는 프론트매터 한두 줄이다. 어떤 도구를 쥐여줄지(`tools`)를 파일에 적는 순간, 그 에이전트가 할 수 **없는** 일이 프롬프트가 아니라 파일 수준에서 정해진다. 본문에 "Write 금지"라고 써 두는 건 프롬프트일 뿐이고, 확률적으로 판단하는 시스템에서 판단은 언젠가 흔들린다." (`_posts/2026-07-29-harness-engineering-book-overview.md:73`)
- 연결: `tools`는 허용 목록, "Write 금지"는 차단 문장. 다만 **책의 주장을 요약한 리뷰**라 비유 수준으로 한 문장 이내

### I-7. 장애 대응 편: 주의력에 기대는 대책

- `_posts/2026-07-24-incident-response-pipeline.md:96`에 "사람을 고칠 수 없다. 시스템을 고쳐라"와 "사람의 주의력 향상에 기대는 대책은 대책이 아니다."가 있음(같은 줄에 em dash가 있어 노트에는 이 두 문장만 둠. 본문 인용 시 원문 그대로)
- 연결: 엔드포인트마다 `@PreAuthorize`를 "잊지 말자"는 규율은 주의력에 기대는 대책, 목록 대조는 시스템 쪽 대책
- 같은 줄의 "비난 문화에서는 정보가 숨겨진다"는 공단의 1년 7개월 미보고와 이어질 수 있으나, 이 글의 중심에서 벗어나므로 쓰더라도 한 문장

---

## 인사이트 후보

- **공개 기록이 확정하는 것은 인증 부재까지다.** 경찰 설명은 "'인증 토큰' 검증 절차조차 없어"이고, "관리자 API"와 "권한 확인 부재"는 시의원 발언과 기자 서술에만 있다. 이 글이 따릉이를 "인가 누락"이라 부르면 그 자리에서 검증 가능한 사실을 어긴다(이 블로그의 결론 "검증 가능한 사실은 그 자리에서 검증하라"). 근거: D-2, D-3
- **인증 누락과 인가 누락은 원인 자리가 같다.** OWASP는 "If an unauthenticated user can access either page, it's a flaw. If a non-admin can access the admin page, this is a flaw."를 한 시나리오로 묶고, API5는 위협 주체에 익명 사용자를 넣고, MITRE는 자체 인증 루틴을 쓰면 "these routines must be applied to every single page, since these pages could be requested directly"라고 쓴다. 둘 다 "이 경로에 어떤 정책이 걸려 있는가를 아무도 선언하지 않았다"로 수렴한다. 이 다리를 놓으면 따릉이를 정확히 인용하면서도 본론(인가)으로 넘어갈 수 있다. 근거: C-1, C-2, C-3
- **인증은 한 곳에서 걸리고 인가는 엔드포인트마다 선언해야 한다.** 인증은 "토큰이 유효한가"라 필터 하나로 끝나지만, 인가는 "누가 이 기능을"이라 기능의 의미를 알아야 한다. 그래서 선언이 엔드포인트로 흩어지고, 흩어진 선언은 빠진다. API5의 "unclear separation between administrative and regular functions", "Don't assume that an API endpoint is regular or administrative only based on the URL path." 근거: C-1. (구조 설명 자체는 필자 해석)
- **6.0의 기본 거부를 마지막 한 줄이 되돌린다.** Spring Security 6.0은 미매칭 요청을 거부로 바꿨다(gh-11958). 그런데 Boot 기본 체인의 마지막 줄이 `anyRequest().authenticated()`이고, 매핑 0개 예외 메시지가 예로 드는 줄도 그것이다. 이 줄이 있으면 선언하지 않은 모든 엔드포인트는 "로그인하면 허용"이 된다. 문서는 `denyAll()`을 권하지만(TIP, callout, 5.8 마이그레이션 가이드), `authenticated()`가 관리자 API를 연다고 경고하는 문장은 없다. 근거: E-S2, E-S3, E-S4
- **메서드 보안은 붙인 곳만 지킨다.** 문서가 "unannotated methods are not secured"라 적고 대책으로 catch-all URL 규칙을 권하는데, 그 catch-all이 `authenticated()`면 애노테이션을 빠뜨린 관리자 메서드는 로그인한 누구에게나 열린다. 두 장치가 서로를 안전망으로 믿는 구조. 근거: E-S5
- **같은 설정 코드라도 버전이 정책을 바꾼다.** 5.8까지 미매칭은 허용, 6.0부터 거부. 레거시 `authorizeRequests()`는 6.x에서도 허용. Boot 2.7과 3.x가 섞인 조직에서는 같은 습관이 모듈마다 다른 결과를 낸다. "라이브러리 기본값이 곧 정책"(레이트리미터 편)의 재등장. 근거: E-S1, I-5
- **공개도 선언이어야 목록 대조가 성립한다.** Artemis는 공개 엔드포인트에도 `@EnforceNothing`을 요구해 "애노테이션 없음"을 곧 실패로 만든다. 1편의 "제외 규칙이 더 많은 판단을 담고 있었다"와 같은 구조로, 목록 대조 테스트의 진짜 명세는 공개 예외 목록이다. 근거: E-T2, I-3
- **이 블로그의 계약 테스트도 기억에 묶여 있었다.** "외부 요청 0" 계약은 임베드 글이 생길 때마다 그 글 전용 단언을 손으로 추가하는 방식으로 네 번 자랐다. 레이아웃은 덮이지만 본문 임베드는 기억한 글만 덮인다. 엔드포인트마다 인가 테스트를 하나씩 쓰는 팀과 같은 모양. 근거: I-2. (선택: 이 글과 별개 이슈로 `_site` 전체 HTML에 외부 요청 부정 단언을 거는 개선을 할 수 있음. 미해결 질문 참조)
- **목록이 못 보는 집단을 목록 옆에 적어야 한다.** `getHandlerMethods()`는 액추에이터, 함수형 라우트, 정적 리소스, 필터가 응답하는 경로, 별도 서블릿을 못 본다. 그리고 커스텀 `SecurityFilterChain`을 만드는 순간 Boot는 액추에이터 보호에서 물러난다. 3편의 "그 검사기가 못 보는 집단은 무엇인가". 근거: E-T3, I-3
- **403은 막혔다는 사실만 말하고 누가 막았는지는 말하지 않는다.** CSRF 토큰 없는 POST는 역할과 무관하게 403이고, 인증 DSL 없는 구성에서는 익명도 403이다. 관리자 규칙을 지워도 초록불인 403 테스트가 가능하다. 대응은 같은 요청이 올바른 역할에서 2xx가 되는 짝 테스트, `.with(csrf())`, 그리고 규칙을 지워 빨간불을 확인하는 것. 근거: E-T4, I-3(1편 `:476`, 3편 `:387`). (상태 코드 분기는 실행 확인 안 됨. writer가 최소 예제를 돌려 보거나 `(확인 필요)`)
- **볼륨 신호는 장애를 알렸고 유출은 분석 보고서가 알렸다.** 따릉이는 2024년 6월 "장애 발생"으로 신고됐고 유출은 7월 18일 분석 보고서에서 확인됐다. "얼마나 많이"는 즉시 보였고 "누가 무엇을 읽었는가"는 사후 분석이 필요했다. 그리고 확인 뒤 1년 7개월 동안 처리되지 않았다(탐지가 아니라 처리의 실패). 근거: D-2, D-3
- **인증이 없으면 레이트 리미터는 "누가"를 셀 키조차 없다.** 시의원이 레이트 리미팅을 대책으로 제안했지만, 인증 없는 엔드포인트에서 리미터의 키는 IP 정도다. 462만 건을 48시간에 나누면 평균 초당 약 26.7건, 72시간이면 약 17.8건(필자 계산. 기간 가정이 경찰 이틀, 서울시 사흘로 갈리고 호출당 건수는 미상). 레이트리미터 편 "완벽한 알고리즘도 안 걸린 경로는 못 막습니다"의 인가 버전. 근거: D-2, D-4, I-5. (필자 추론 비중이 큼)
- **공격 비용이 내려가면 "털 가치"의 문턱도 내려간다.** 영상은 "보안은 비용이고 관리"라고 하면서 "AI는 자동화일 뿐"이라고도 한다. Carlini et al.은 바로 그 자동화가 "products with thousands of users"의 쉬운 버그를 수지맞는 표적으로 만든다고 쓴다. 방어 비용 계산의 분모가 바뀐다. 도입부 맥락용. 근거: E-A3

## 소주제 이름 후보 (확정 표기)

글 도입부 예고와 소제목이 이 표기를 그대로 씁니다. 순서도 이 순서를 권합니다(영상 순서가 아님).

- **기본 허용** : 인증 누락과 인가 누락의 공통 원인, 인증은 한 곳 인가는 엔드포인트마다, 6.0의 기본 거부를 되돌리는 마지막 한 줄, 메서드 보안의 붙인 곳만 원칙, 버전이 바꾸는 정책, 이 블로그 #18
  - 배우는 것: 인가는 선언한 곳에만 있고, 선언하지 않은 엔드포인트의 운명은 프레임워크 기본값과 마지막 catch-all 한 줄이 정한다. Spring Security 6이 미매칭을 거부로 바꿨어도 흔한 `anyRequest().authenticated()`가 그 자리를 "로그인하면 허용"으로 채운다
- **목록 대조** : 엔드포인트 인벤토리와 정책 표 대조, 공개도 선언으로, 인벤토리가 못 보는 집단, 이 블로그 계약 테스트의 기억 의존, 403 단언의 함정(하위 소제목 후보 "틀린 이유로 나는 403". 예고 대상은 아님)
  - 배우는 것: 엔드포인트마다 인가 테스트를 하나씩 쓰면 테스트도 사람의 기억에 묶인다. 실제 매핑 목록을 정책 표와 대조하면 "선언하지 않음"이 곧 실패가 되고, 그때 진짜 명세는 공개 예외 목록이며, 목록이 못 보는 경로를 함께 적어야 한다
- **누가 무엇을 읽는가** : 따릉이의 장애 신고와 분석 보고서, 레이트 리미터의 키, 볼륨 방어와 인가의 축 분리
  - 배우는 것: DDoS 판단과 레이트 리미터는 "얼마나 많이"를 센다. 유출은 "누가 무엇을 읽었는가"를 남겨야 보이고, 인증이 없는 엔드포인트에는 그 "누가"를 셀 키조차 없으므로 볼륨 방어가 인가를 대신할 수 없다

이름이 셋에서 멈춘 이유와 묶이지 않은 후보:
- "틀린 이유로 나는 403"은 배울 점이 뚜렷해(조용히 통과하는 테스트) 독립 소주제로도 서지만, 넷이 되면 글 한 편의 범위를 넘는다는 신호라 **목록 대조** 안의 하위 소제목으로 둠. writer가 분량상 독립시키려면 사용자 확인이 필요
- "공격 비용이 내려가면 털 가치의 문턱도 내려간다"와 2026년 가을 은행권 사고는 **도입부 재료**이지 소주제가 아님
- 공단의 1년 7개월 미보고(거버넌스)와 영상의 취업 조언은 소주제로 묶이지 않음(아래 "낮은 우선순위")

## 이미 발행된 것과의 경계 (중복 회피)

- #18 사건의 서사(테스트가 자기 최적화 때문에 자기를 못 봤다, 빨간불 확인)는 3편이 이미 했음. 이 글은 "exclude는 차단 목록"이라는 각도만
- 1편은 `site_output_test.rb`의 외부 요청 단언을 좋은 계약 예로 들었음. 이 글은 "단언이 걸린 범위"를 보태는 것이지 1편 반박이 아님
- 레이트리미터 편은 발행본 본문 문장만. 사내 노트(`.sources-internal.md`) 사용 금지
- 3부작은 "질문 목록으로 끝나는" 형식을 세 번 썼음. 이 글이 같은 형식으로 끝나면 시리즈의 연장처럼 읽힘. 의도라면 괜찮지만 반복이라면 다른 마무리를 고려

## 낮은 우선순위로 분류한 것 (쓰더라도 한두 문장 맥락)

- 정보보안기사 합격률: 공식 통계(한국방송통신전파진흥원) **확정하지 못함**. 2차 자료만 있음(인프런 계산값 2025년 필기 약 38.2%, 실기 약 23.6%). 영상의 "필기 30%, 실기 10% 미만"은 미확인
- 국립중앙의료원 진단검사의학과 전문의 CPO 겸직: **확정하지 못함**(보도를 찾지 못함)
- 정부 대책 비판: 대책은 실재하나 모두 이번 금융권 사고 이전(E-A2)
- 소프트웨어 개발보안 가이드 무료 배포: 사실(C-4). 본문에서 C-4의 두 항목을 인용하면 영상의 권유를 자연스럽게 회수할 수 있음
- WAF, NIDS/HIDS, ALB, CloudFront 배치 이해: 이 글 범위 밖

## 미해결 질문

- **글 전제의 조정(사용자 결정 필요)**: 따릉이를 "인가 누락"이 아니라 "인증조차 없었다(경찰 설명)"로 쓰고 인가를 그 형제로 다룰지, 글 제목과 slug의 "authorization"을 "접근 통제" 범위로 넓힐지. slug는 확정 상태라 유지 가능(인가가 본론이므로) → **해소**: 사용자 결정 절, 검증 기록 V-7, V-9
- 따릉이 엔드포인트의 성격(BFLA, BOLA, 관리자 기능 여부), 토큰 미요구인지 미검증인지, 80분 장애의 원인, 호출당 건수: 공개 자료 없음 (writer는 단정하지 말 것) → **미해소**(초안은 단정하지 않음, 검증 기록 V-13)
- 개인정보위 처분: 2026-10-08 기준 미발견 → **미해소**(본문 미사용)
- 2026년 가을 은행권 사고: 보도 1주일차, ARTEX 공식 귀속 없음, CrowdStrike 중간 신뢰도. 쓰면 날짜를 박은 "보도에 따르면"으로 → **본문 범위에서 해소**: 검증 기록 V-1, V-2(보도 유동성 자체는 미해소)
- E-T4의 401, 302, 403 분기와 CSRF 403: 소스로 도출했고 실행 확인 안 함. writer가 최소 MockMvc 예제를 실제로 돌려 보거나 `(확인 필요)`로 남길 것. **이 블로그는 "실행해 보는 것과 아는 것은 다르다"를 결론으로 쓴 적이 있음**(3편 `:387`) → **해소**: W-2, 검증 기록 V-32(재실행)
- springdoc `/v3/api-docs`가 런타임 `getHandlerMethods()`에 포함되는지: 애노테이션까지만 확인 → **미해소**(본문 미사용)
- 하위 에이전트만 확인하고 리서치 단계에서 직접 대조하지 않은 인용: OWASP Top 10 A07 매핑, CWE-285 Mapping Usage, Artemis와 ldapportal 코드, Schwenke 글, ASVS, Fang 수치, NCSC, Anthropic 보고서, ARTEX 대회 정보, 헤럴드경제와 기타 금융권 기사. 본문에 들어가면 verifier가 대조 필요 → **본문에 들어간 NCSC, Artemis는 해소**: 검증 기록 V-5, V-33. 나머지는 본문에 없어 미대조로 남김
- 영상 화자 채널명(STT상 "널한 개발", "널널한 개발자"로 추정): 본문에서 채널을 밝힐지 사용자 확인 필요 → **해소**: 오케스트레이터 보충 절의 oEmbed, 검증 기록 V-3
- 선택 과제(이 글과 별개): `test/site_output_test.rb`의 외부 요청 부정 단언을 `_site` 전체 HTML로 넓히는 개선. 글에서 자기 사례로 쓰고 바로 고친다면 별도 Issue로 분리할 것(Issue-Driven 규칙) → **해소**: #125, #126, 검증 기록 V-37~V-39

## 작성 시 지켜야 할 것 (writer에게)

- **영상 대사를 직접 인용하지 않습니다.** 요지 서술과 출처(영상 URL)만. 영상의 사실 주장은 D-3, E-A2 표의 판정을 따릅니다
- **따릉이를 "관리자 API", "인가 누락"으로 단정하지 않습니다.** 경찰 설명 문장(D-2)을 원문 그대로 인용하고, 분류는 C-5 표의 수준에서 멈춥니다
- **Spring 문서와 소스는 판본과 줄번호를 밝혀 원문 그대로.** adoc 원본과 렌더 페이지 차이(`It's` 굽은 따옴표, `xref:` 링크 마크업)를 주의. 렌더 페이지 문장을 쓸 거면 렌더 페이지에서 다시 복사
- **버전을 본문에 박습니다.** 기준 Boot 3.5.16 / Security 6.5.11. 5.8 이하와 레거시 `authorizeRequests()`의 차이를 언급할 때는 E-S1 표 기준
- **예시 설정 코드는 필자 작성 예시임을 표시합니다.** 이 글에는 사내 코드가 없으므로 `[재구성]`이 아니라 "예시"로 표기하고, 원문 인용(Spring 소스, 이 저장소 파일)과 섞어 보이지 않게
- 이 저장소 파일 인용은 원문 그대로(`CLAUDE.md` 포스트 규칙). 발행본 인용은 소급 수정 금지
- 문체는 습니다체 기본(블로그 규칙). 예고는 이름으로 하고 개수와 번호 라벨("세 가지를 다룹니다", "첫째") 금지
- 초안 하단 작성자 노트: `<!-- 작성자 노트: 소주제 이름 = 기본 허용 | 목록 대조 | 누가 무엇을 읽는가 -->`
- 태그 후보: `보안`, `Spring`, `테스트` (고유명사 원 표기, 주제 한국어)

---

## 사용자 결정과 오케스트레이터 보충 (2026-10-08)

> 리서치 이후 사용자가 내린 결정과, 오케스트레이터가 직접 확인한 사실입니다. writer는 위 "미해결 질문" 중 아래에서 해소된 항목을 이 절 기준으로 읽습니다.

### 사용자 결정

- **따릉이 틀**: 정확히 인용하고 다리를 놓는다. 따릉이는 경찰 설명(D-2) 그대로 "인증 토큰 검증 없이 조회 호출이 응답했다"로 쓰고, 영상의 "관리자 API" 표현은 공식 조사로 확인되지 않았다고 밝힌다. OWASP A01 시나리오(C-2), API5의 익명 위협 주체(C-1), CWE-306(C-3)을 다리로 "이 경로에 어떤 정책이 걸려 있는지 아무도 선언하지 않았다"로 모은 뒤 본론(인가)으로 넘어간다. slug 유지
- **소주제 확정**: `기본 허용 | 목록 대조 | 누가 무엇을 읽는가`. "틀린 이유로 나는 403"은 **목록 대조** 안의 하위 소제목. AI 비용 관점과 2026년 가을 은행권 사고는 도입부 재료
- **I-2 자기 사례**: 먼저 고치고 글에 넣는다. 아래 #125, #126으로 고쳤다

### 영상 메타데이터 (YouTube oEmbed 응답, 2026-10-08 조회)

- 조회 URL: `https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=fRyxfHkqf2M&format=json`
- `title`: 예상 면접질문: 따릉이와 금융권 AI 해킹사고 어떻게 막을 수 있을까?
- `author_name`: 널널한 개발자 TV
- `author_url`: https://www.youtube.com/@nullnull_not_eq_null
- 미해결 질문의 "영상 화자 채널명"은 이것으로 해소. 본문에서 채널명과 영상 제목을 밝혀 출처를 단다. 대사 직접 인용 금지 규칙은 그대로

### I-2 해소: 외부 요청 0 계약을 생성된 HTML 전체로 넓힘 (#125, #126)

- Issue: https://github.com/SeokRae/blog/issues/125 「test: 외부 요청 0 계약이 이름으로 고른 페이지 여섯 개에만 걸려 있다」
- PR: https://github.com/SeokRae/blog/pull/126 (2026-10-08 생성, **merge 대기**. 이 저장소는 squash merge라 merge 뒤 커밋 해시가 바뀌므로 본문은 Issue와 PR 번호로 가리킨다)
- 브랜치 `feature/125-site-wide-external-request-check`, 커밋 `5533e74`. merge 전에는 main에 없으므로 코드 원문은 `git show feature/125-site-wide-external-request-check:test/site_output_test.rb`로 읽는다. 인용하면 원문 그대로
- **고치기 전 재현**: main에서 `about.md` 끝에 `<script src="https://example.com/injected.js"></script>`를 붙이고 `bundle exec ruby test/site_output_test.rb` 실행. 결과 `1 runs, 181 assertions, 0 failures, 0 errors, 0 skips` (빈틈이 실제로 있음)
- **변경**: 페이지별 외부 스타일시트, 외부 스크립트 부정 단언 10개를 지우고(index, search, flowcast, 레이트리미터, Jev 두 편), 빌드한 `_site/**/*.html` 전체를 훑는 `assert_no_external_requests` 하나로 바꿈. 위반 시 파일 경로와 태그를 함께 보고
- **정상 상태**: `1 runs, 165 assertions, 0 failures, 0 errors, 0 skips`. `node test/search_test.js`는 `search_test.js: 12 assertions, 통과`
- **일부러 깨뜨린 결과**: about에 외부 스크립트, Chirpy 편에 `<link rel="stylesheet" href="//cdn.example.com/injected.css">`, 404에 `<link rel="preload" as="style" href="https://cdn.example.com/preloaded.css">`를 넣고 실행. 실패 메시지 원문:
  ```
  외부 스타일시트나 스크립트를 받는 페이지가 있다.
  Expected ["2026/07/13/chirpy-to-type-theme.html: <link rel=\"stylesheet\" href=\"//cdn.example.com/injected.css\" />", "404.html: <link rel=\"preload\" as=\"style\" href=\"https://cdn.example.com/preloaded.css\" />", "about/index.html: <script src=\"https://example.com/injected.js\">"] to be empty.
  ```
  주입한 파일은 확인 뒤 되돌림
- **범위 숫자**: 2026-10-08 실제 사이트 빌드는 HTML 18개를 발행(포스트 11, `index.html`, `page2/index.html`, `page3/index.html`, `about/index.html`, `search.html`, `tags.html`, `404.html`). 그동안 이름으로 검사하던 것은 그중 6개. 테스트 빌드는 픽스처 포스트가 더해져 더 많음
- 실제 출력에 있는 외부 주소 `<link>`는 `rel="canonical"` 18개뿐(요청이 아님). 그래서 판정은 "리소스를 받아 오는 rel(stylesheet, preload, modulepreload, prefetch, icon)이거나 href가 .css"로 잡음
- **빈 목록 가드**: 훑은 HTML 수가 원본 포스트 수 이상인지 먼저 확인한다. glob이 비면 위반 목록도 비어서 아무것도 검사하지 않고 통과하기 때문. 1편 `:476` "부정 단언이라면, 틀린 이유로 통과할 경로가 몇 개인가"의 사례
- **작업 중 관찰 (필자 작업 기록, 커밋에는 최종본만 남음. 공개 흔적은 PR #126 본문의 "`rel`과 무관한 외부 `.css`(기존 index 단언의 범위)" 항목)**: 첫 구현은 `rel="stylesheet"`인 link만 봤다. 그런데 지운 index 단언 `refute_match(%r{<link[^>]*\shref="https?://[^"]*\.css}, index, "외부 스타일시트를 받으면 안 된다")`는 rel과 무관하게 외부 `.css`를 잡고 있었다. 목록 하나로 합치면서 지운 단언 하나가 보던 범위를 잃을 뻔했고, 커밋 전에 지운 단언들과 대조해 되살렸다. 교훈 후보: 흩어진 단언을 목록 하나로 합칠 때, 새 단언은 지운 단언들이 보던 범위의 합집합을 덮어야 한다. 쓰더라도 짧게

---

## writer 실행 확인과 원문 대조 (2026-10-08, blog-writer)

> 노트가 "실행 확인 안 함"으로 남긴 상태 코드 분기를 최소 예제로 직접 돌렸고, 본문에 인용한 Spring 원문을 태그 고정 원본에서 다시 받아 대조했습니다. 데모 프로젝트는 세션 임시 디렉터리에 있어 사라지므로, 재현에 필요한 것(구성, 엔드포인트, 설정, 결과)을 여기에 남깁니다. 글에 실은 목록 대조 테스트와 짝 테스트는 실행한 코드와 같습니다(클래스 이름 `EndpointPolicyInventoryTest`).

### W-1. 실행 환경

- `spring-boot-starter-parent` 3.5.16, starter `web`, `security`, `actuator`, `test`, 그리고 `spring-security-test`. Maven이 실제로 해석한 판본: spring-boot-autoconfigure 3.5.16, spring-security-{core,config,web,test} 6.5.11, spring-webmvc 6.2.19
- Java 21(Corretto 21.0.1). 모든 테스트는 `@SpringBootTest` + `@AutoConfigureMockMvc`, 사용자는 `@WithMockUser` 또는 `user(...).roles(...)`
- 컨트롤러 하나에 엔드포인트 여섯: `GET /me`, `GET /notices`, `GET /admin/users`, `POST /admin/users/{id}/lock`, `GET /internal/members/export`(나중에 추가된, `/admin` 밖의 관리자성 기능이라는 설정), `GET /reports/sales`(`@PreAuthorize("hasRole('ADMIN')")`만 붙음)

### W-2. 결과 (체인 설정별)

| 체인 설정 | 요청 | 상태 |
|---|---|---|
| Boot 기본 체인(커스텀 체인 없음) | 익명 `GET /admin/users`, Accept 없음 | 401, `WWW-Authenticate: Basic realm="Realm"` |
| 같음 | 익명, `Accept: application/json` | 401 |
| 같음 | 익명, `Accept: text/html` | 302, `Location: http://localhost/login` |
| 같음 | 익명, `X-Requested-With: XMLHttpRequest` | 401(WWW-Authenticate 없음) |
| 같음 | USER `GET /admin/users` | **200** |
| 같음 | USER `GET /reports/sales`(`@EnableMethodSecurity` 없음) | **200** |
| `/admin/**` hasRole ADMIN + `anyRequest().authenticated()` + httpBasic | USER `GET /internal/members/export` | **200** |
| 같음 | USER `GET /admin/users` | 403 |
| 같음 | USER `POST /admin/users/1/lock`, csrf 없음 | 403 |
| 같음 | USER, `.with(csrf())` | 403 |
| 같음 | ADMIN, csrf 없음 | **403** |
| 같음 | ADMIN, `.with(csrf())` | 200 |
| 같음 | 익명 `GET /admin/users` | 401 |
| 관리자 규칙 삭제, `anyRequest().authenticated()`만 + httpBasic | USER `POST /admin/users/1/lock`, csrf 없음 | **403** (규칙을 지워도 403) |
| 같음 | USER, `.with(csrf())` | 200 |
| `/admin/**` hasRole, `/me` authenticated, **anyRequest 없음** + httpBasic | USER `GET /internal/members/export` | 403 (6.x 미매칭 거부) |
| 같음 | USER `GET /me` | 200 |
| 같음 | 익명 `GET /internal/members/export` | 401 |
| `/notices` permitAll, `/me` authenticated, `/admin/**` hasRole, `anyRequest().denyAll()` | USER, ADMIN `GET /internal/members/export` | 403, 403 |
| 같음 | USER `GET /actuator/health` | 403 |
| `formLogin()`만 | 익명 `GET /admin/users`, `Accept: application/json` | 302 → `/login` |
| 인증 DSL 없이 `addFilterBefore(자체 필터, AuthorizationFilter.class)`만 | 익명 `GET /admin/users` | **403** |
| `@EnableMethodSecurity` + `anyRequest().authenticated()` | USER `GET /reports/sales` | 403 |
| 같음 | USER `GET /internal/members/export`(애노테이션 없음) | 200 |

- E-T4의 소스 도출(인증 DSL 없으면 익명 403, httpBasic 401, formLogin 302, Boot 기본은 Accept에 따라 302 또는 401, CSRF 토큰 없으면 역할 무관 403)은 전부 실행으로 확인됨. 보탤 관찰: Boot 기본 체인에서 Accept 헤더가 없으면 302가 아니라 401
- `ExceptionHandlingConfigurer.java` 6.5.11 L236-238: 진입점 매핑이 비면 `return new Http403ForbiddenEntryPoint();`

### W-3. 인벤토리 관찰

- 같은 컨텍스트의 `HandlerMapping` 빈은 아홉 개: `welcomePageHandlerMapping`, `welcomePageNotAcceptableHandlerMapping`, `requestMappingHandlerMapping`, `beanNameHandlerMapping`, `routerFunctionMapping`, `resourceHandlerMapping`, `healthEndpointWebMvcHandlerMapping`, `webEndpointServletHandlerMapping`, `controllerEndpointHandlerMapping`
- `requestMappingHandlerMapping.getHandlerMethods()`에는 컨트롤러 엔드포인트 여섯과 함께 **직접 쓰지 않은 `BasicErrorController`의 `/error` 매핑 두 개**(`{ [/error]}`, `{ [/error], produces [text/html]}`)가 들어 있고, `/actuator/**`는 없음. E-T3의 "액추에이터는 별도 빈"을 실행으로 확인
- 목록 대조 테스트(`정책을_선언하지_않은_엔드포인트가_없다`)는 정책 표에 `/internal/members/export`가 없을 때 실패. 메시지 끝부분: `but found these extra elements:` / `  ["GET /internal/members/export"]`. 중간의 두 목록은 `Map.of` 순회 순서라 실행마다 순서가 다를 수 있음
- 짝 테스트(정책 표의 ADMIN 줄마다 USER는 403, ADMIN은 2xx, 둘 다 `.with(csrf())`) 3건 통과
- 일부러 깨뜨림 1: `/admin/**`, `/reports/**`의 `hasRole("ADMIN")`을 `authenticated()`로 바꾸면 3건 모두 USER 쪽에서 `Status expected:<403> but was:<200>`
- 일부러 깨뜨림 2: 1에 더해 `.with(csrf())`까지 빼면 GET 2건은 USER 쪽에서 같은 메시지로 실패, POST 1건은 USER 쪽 403을 통과한 뒤 ADMIN 쪽에서 `Range for response status value 403 expected:<SUCCESSFUL> but was:<CLIENT_ERROR>`로 실패. CSRF가 만든 403을 잡은 것은 짝의 2xx 단언

### W-4. 노트 밖에서 직접 대조한 원문 (본문에 인용)

- **method-security.adoc 6.5.11 L307의 링크 대상**: "a catch-all authorization rule"의 xref가 `authorize-http-requests.adoc#activate-request-security`를 가리킴(렌더 페이지 `authorize-http-requests.html#activate-request-security`로도 확인). 그 앵커(authorize-http-requests.adoc 6.5.11 L10-23)는 "Whenever you have an `HttpSecurity` instance, you should at least do:" 아래에 `.anyRequest().authenticated()` 예시를 둠. 즉 메서드 보안 문서가 미주석 메서드의 안전망으로 가리키는 예시가 `authenticated()` catch-all
- 렌더 페이지(https://docs.spring.io/spring-security/reference/6.5/servlet/authorization/method-security.html) 문장: "It’s important to remember that when you use annotation-based Method Security, then unannotated methods are not secured. To protect against this, declare a catch-all authorization rule in your HttpSecurity instance." 그리고 "Spring Boot Starter Security does not activate method-level authorization by default." (굽은 따옴표 `’`)
- 렌더 페이지(https://docs.spring.io/spring-security/reference/6.5/servlet/test/mockmvc/csrf.html): "When testing any non-safe HTTP methods and using Spring Security’s CSRF protection, you must include a valid CSRF Token in the request."
- **Authorization Events** (events.adoc 6.5.11 L4, L73. 렌더 https://docs.spring.io/spring-security/reference/6.5/servlet/authorization/events.html): "For each authorization that is denied, an AuthorizationDeniedEvent is fired." 그리고 "Because AuthorizationGrantedEvents have the potential to be quite noisy, they are not published by default." (adoc 원문은 ``` ``AuthorizationGrantedEvent``s ``` 마크업). `AuthorizeHttpRequestsConfigurer.java` 6.5.11 L78-82는 `AuthorizationEventPublisher` 빈이 있으면 그것을, 없으면 `new SpringAuthorizationEventPublisher(context)`를 쓰고, `SpringAuthorizationEventPublisher.java` 6.5.11 L63-65는 `if (result == null || result.isGranted()) {` 다음 `return;`으로 허용 결정을 발행하지 않음(verifier 보정: `if`는 L64, `return;`은 L65이고 L63은 시그니처 끝줄. 검증 기록 V-27). 본문 "누가 무엇을 읽는가"에서 "기본으로 남는 것은 거부이고, 허용된 읽기는 남지 않는다"의 근거
- `RequestMatcherDelegatingAuthorizationManager.java` 5.8.0 L85-86, 6.5.11 L94-97, `SpringBootWebSecurityConfiguration.java` v3.5.16 L58, `AuthorizeHttpRequestsConfigurer.java` 6.5.11 L170, authorize-http-requests.adoc 6.5.11 L497, L765-766, 5.8.0 migration authorization.adoc L653-655, `WebSecurity.java` 6.5.11 L312-313: E-S 절의 ★ 인용을 다시 받아 같은 줄에서 확인
- `AbstractHandlerMethodMapping.java` Spring Framework v6.2.19 **L145**(Javadoc 블록 L144-146): "Return a (read-only) map with all mappings and HandlerMethod's."
- Boot v3.5.16 `spring-boot-project/spring-boot-docs/src/docs/antora/modules/reference/pages/actuator/endpoints.adoc` L239: "If you define a custom javadoc:org.springframework.security.web.SecurityFilterChain[] bean, Spring Boot auto-configuration backs off and lets you fully control the actuator access rules." 본문은 javadoc 마크업 없는 뒤쪽 구절만 인용
- **Artemis** (커밋 `07f43f8e0b71037881624546c9dcf779498728ff`, `AuthorizationArchitectureTest.java`, 264줄): L231 `because` 문자열 "every REST endpoint must declare an Artemis authorization annotation (or be covered by class-level enforcement) so authorization cannot be forgotten", L249 위반 메시지에 "@EnforceNothing (genuinely public)", L204 예외 목록 Javadoc "fails for any NEW unannotated endpoint, so this set can only shrink."(verifier 교정: 실제 위치는 L203. 검증 기록 V-33), L114-115 "{@code /management/**} asks for elevation explicitly because no annotated handler / serves the actuator endpoints." E-T2의 하위 에이전트 확인을 원본으로 대조함
- **NCSC** (https://www.ncsc.gov.uk/report/impact-ai-cyber-threat-now-2027, 2026-10-08 HTML 직접 수신): "To 2027, this will highly likely increase the volume and impact of cyber intrusions through evolution and enhancement of existing TTPs, rather than creating novel threat vectors." 문장 확인

---

## 응집 점검 기록

### writer, 초안 저장 직후 (2026-10-08)

- 도구: `sr-blog-harness/scripts/cohesion_check.py _drafts/missing-authorization-backend.md`
- **예고 사슬**: 작성자 노트 이름 `기본 허용 | 목록 대조 | 누가 무엇을 읽는가`가 도입부 예고(굵게)와 `##` 소제목에 같은 표기, 같은 순서로 있음. "소제목에 없는 이름: 없음". "이름에 없는 소제목"은 세 소주제 아래 `###` 하위 소제목 8개와 마무리 `## 기본기와 기본값`. 마무리 절은 예고 대상이 아니라 세 소주제를 '기본'의 두 뜻으로 닫는 자리라 예고에 넣지 않음
- **개수와 번호 라벨**: 없음. 초고의 "두 가지가 눈에 띄었습니다", "경로가 두 개 나왔습니다"는 이름으로 바꿈("CSRF 쪽과 인증 실패 쪽")
- **우산**: 나열 두 곳(마지막 줄 세 곳, 목록 밖 경로 다섯) 모두 직전 문장이 우산
- **긴 문단**: 처음 7개 플래그 중 두 항목 나열 문단(`/error`와 `PUBLIC`), 축이 바뀌는 문단(레이트 리미터 인용, 이벤트 기본값의 "전부 켜자는 이야기는 아닙니다"), 마무리 첫 문단을 배열 단위로 나눔. 남은 4개(기본 허용 첫 문단, 메서드 보안 기본값, "이 순서에서 보이는 것은", 마무리 첫 문단)는 연쇄 문단이고 끝에서 출발점으로 돌아와 닫혀 그대로 둠. 문장 다듬기는 하지 않음(editor 몫)

### editor, 윤문 (2026-10-08, blog-editor)

- 도구: 같은 스크립트를 윤문 전과 후에 한 번씩 실행. 아래 줄번호는 **윤문 후** 초안 기준이다. 문단 두 곳을 나눠서 본문 줄번호가 L35부터 +2, L261부터 +4 밀렸다(윤문 전 L59 → 후 L61, 전 L259 → 후 L263, 전 L339 → 후 L343). 위 writer 기록과 아래 `## 검증 기록`의 Lnn은 윤문 전 기준이다
- **예고 사슬**: 일치. 작성자 노트 `기본 허용 | 목록 대조 | 누가 무엇을 읽는가`, 도입부 L27의 굵은 이름 세 개, `##` 소제목 L31, L121, L341이 같은 표기와 같은 순서다. "틀린 이유로 나는 403"(L279)은 `###`이고 L121과 L341 사이에 있어 **목록 대조** 아래가 맞다. 본문의 "목록 대조"(L247, L251, L263, L281, L369)도 같은 표기다. 마무리 `## 기본기와 기본값`은 writer 판단대로 예고 대상이 아니다
- **개수와 번호 라벨**: 윤문 전후 모두 없음. 도입부 예고의 "먼저", "끝으로"는 순서 부사라서 유지
- **손본 곳 (배열)**
  - L33-35: 기본 허용 첫 문단(7문장)을 둘로 나눔. 앞 문단 5문장은 인증과 인가의 대비부터 API5 인용까지의 연쇄이고, 뒤 문단 2문장은 "흩어진 선언은 빠진다"와 이 절의 질문이다. 다음 소절 첫 문장 "이 질문의 답을 한 번 뒤집었습니다"가 뒤 문단 마지막 문장을 바로 받는다
  - L259-261: 액추에이터 문단(6문장)을 4문장과 2문장으로 나눔. 액추에이터에서 출발해 Jekyll `exclude`에서 끝나 고리가 닫히지 않았다. 일반화 문장 "규칙은 내가 쓴 것에만 걸립니다."를 새 문단 앞자리로 옮겨, 액추에이터와 Jekyll 두 사례를 함께 받게 했다
  - L230: "남겨 둔 채 돌리면 ... 끝납니다"와 "일부러 남겨 두고 얻은 것입니다"가 같은 사실을 두 번 말해 하나로 합침. 코드 블록 바로 앞 문장이 "실패 메시지는 이렇게 끝납니다."가 되게 순서를 바꿨다
  - L97: 앞 문단 L93 "안전망을 다시 URL 규칙에 걸어 둡니다"를 되풀이하던 "메서드 보안은 URL 규칙을 안전망으로 가리키고"를 다음 문장과 합침. 문단이 링크, 예시, 결과 순의 연쇄로 끝난다
- **손대지 않기로 한 곳**
  - L99(6문장) 메서드 보안 기본값: "기본값 하나가 더 겹친다"에서 출발해 문서, 미선언 시 동작, 예제 결과, 켠 상태 순으로 이어지는 연쇄이고, 마지막 문장 "켠 곳에서, 붙인 메서드만"이 출발점의 기본값으로 돌아와 닫힌다
  - L349("이 순서에서 보이는 것은", 스크립트는 6문장으로 셌고 실제로는 7문장): 첫 문장 "두 신호의 속도 차이"가 우산이고 두 신호를 3문장씩 받는다. "반면"에서 나누면 우산이 한쪽만 덮게 된다
  - L363(6문장) 마무리 첫 문단: 짧은 문장의 리듬으로 기본기에서 기본값으로 넘어가는 연쇄다. 정박 문단이 아니라서 4문장 한도 대상이 아니다
  - L72(3항목), L253(5항목) 나열: 직전 문장 L65 "Boot의 기본 체인, ... 모두 그 줄입니다"와 L251 "목록 밖에 남는 경로는 이런 것들입니다"가 우산이다
  - L89와 L119의 굵은 결론이 같은 주장(선언하지 않은 경로의 정책은 마지막 한 줄이 정한다)을 되풀이: L89는 소절 결론(프레임워크 기본값과의 대비, `authenticated()`가 회원 전원에게 여는 결과)이고 L119는 절 결론이라 역할이 다르다. 하나로 줄일지는 사용자 결정
  - L281 "막혔다는 사실만 확인할 뿐 무엇이 막았는지는 확인하지 않습니다"와 L339 굵은 결론의 되풀이: 앞은 소절의 전제, 뒤는 결론인 수미상관이다
  - L277 목록 대조 결론 문단이 403 하위 소절보다 앞에 있는 배치: 403 소절은 "목록 대조는 선언이 있는지만 봅니다"로 시작하는 확장이다. 결론을 뒤로 옮기면 굵은 결론 두 개가 붙는다
  - 본문의 "누가 무엇을 읽었는가"(L349, L355, L359)와 소제목 "누가 무엇을 읽는가"의 시제 차이: 본문은 사고가 지난 뒤 남은 기록을 가리키는 신호 이름이라 과거형이 자연스럽고, 본문 안에서는 세 곳이 같은 표기다. 리서치 노트의 "배우는 것"도 같은 구분을 쓴다. 바꾸면 L349의 과거 서술과 어긋나 유지
  - L17 블록 인용의 곧은 작은따옴표 '인증 토큰'(verifier V-7이 editor 판단으로 넘김): 초안 포함 빌드로 확인하니 kramdown이 ‘인증 토큰’으로 바꿔 렌더한다. 원고의 문자는 기사와 같다. 곧은 따옴표로 렌더하려면 `&#39;` 엔티티를 써야 해서 원고가 원문과 달라지고, 발행본 전체가 같은 렌더 규칙을 따르므로 유지
  - 코드 블록 언어 태그: `java`, `yaml`, `ruby`는 맞다. 출력 블록 다섯 개는 태그가 없는데, 발행본 관례(출력은 태그 없는 펜스)와 같아 유지
- **사람 결정 대기**: 없음(편집자 노트 0건). 새 사실이 있어야 우산 문장을 쓸 수 있는 자리는 찾지 못했다
- **윤문 분량**: 문단 22개 수정(그중 2개는 나눔). 인용문, 코드 블록, 표, 각주, 주석, 링크는 윤문 전 사본과 기계 대조해 같음을 확인했다. 실제 빌드 기준 읽기 시간 계산 글자 수는 17,366자에서 17,251자(115자 감소)이고 읽기 시간은 35분 그대로다. 계산 글자의 약 44%(코드 4,199, 표 593, 블록 인용 1,103, 본문 속 영문 인용 약 1,634)가 손댈 수 없는 원문이다

---

## 검증 기록

### verifier, 2026-10-08 (blog-verifier)

> 범위: 초안 본문과 각주의 외부 인용, 숫자, 날짜, 이 저장소 자기 사례 전부. **확정한 것도 빠짐없이 적는다.** 초안의 `<!-- 검증: -->` 주석은 발행 시 지워지므로 근거 사슬은 이 절이다.
> 방법: 원문은 전부 2026-10-08에 verifier가 직접 받았다(요약 도구 경유 아님). 기사와 웹 문서는 `curl`로 HTML을 받아 태그를 벗긴 뒤 초안 문자열과 부분 문자열 일치로 대조했다. Spring 소스와 adoc은 `raw.githubusercontent.com`의 태그 고정 파일을 받아 줄번호로 대조했다. 앞 단계가 scratchpad에 받아 둔 사본은 쓰지 않았다(신뢰 경계).
> 결과: **확정 37 / 교정 3 / 확인 불가 0.** 교정은 V-8, V-9, V-33. 남은 `(확인 필요)` 플래그(NCSC 게시일)는 V-5로 해소.
> 줄번호(Lnn)는 초안 `_drafts/missing-authorization-backend.md` 기준이며, verifier는 각주 줄만 고쳐 본문 줄번호는 바뀌지 않았다.

#### 도입부: 금융권 사고, 영상, AI

**V-1. 한국일보 신한은행 보도 `[^hankook]` (확정)**
- 서지: 한국일보, 박세인 기자, 「신한은행 해킹에 2만5000명 개인정보 유출… 금감원 긴급 현장조사」, 2026-10-01 16:02 KST(`article:published_time` 2026-10-01T16:02:00+09:00). https://www.hankookilbo.com/news/article/A2026100115320000186
- 확인 방법: HTML 직접 수신, 본문 텍스트 부분 문자열 대조
- 정합성: 신한은행 문안 "외부의 비인가자가 인증을 우회하는 비정상적인 방법으로 일부 서비스에 접근해 고객의 개인정보를 유출한 사실을 확인했다"(원문은 "신한은행은 1일 ...고 공개했다"), 경로 문장 "이번 공격은 대출 모집인을 위해 제공하는 모바일 웹페이지에서 시작된 것으로 전해졌다.", "로그인 인증이 필요한 뱅킹 서비스가 해킹된 것은 아닌 것으로 전해졌다" 모두 글자 그대로. L9의 "고객 번호로 연락처와 생년월일을 조회할 수 있는 다른 서비스에 접근"은 원문 "여기서 확보한 고객 번호를 기반으로 연락처, 생년월일 등을 조회할 수 있는 다른 서비스에 접근해"의 정확한 요지. "주변의 조회 서비스"라는 해석은 원문 "공격 대상은 홈페이지를 통한 간편 조회 서비스로"와 맞음. 10-01에서 10-08은 7일이라 "보도 1주일 차" 정확
- 과제 4(유동 사실): 날짜를 박은 "2026년 10월 1일 한국일보 보도에 따르면", "전해졌습니다", "세부는 더 바뀔 수 있습니다"로 묶여 있음. 초안에 ARTEX, CrowdStrike, 증권사, ISMS-P, 피해 규모 같은 유동 사실은 들어가지 않음(grep 0건). 통과

**V-2. L9 "2026년 가을, 금융권 개인정보 유출이 연달아 보도되고 있습니다" (확정, 각주 없는 일반 진술)**
- 출처: 머니투데이, 김도엽 기자, 2026-10-05 10:57 KST 단독 기사(제목 원문에 가운뎃점이 있어 여기에는 옮기지 않음). https://www.mt.co.kr/finance/2026/10/05/2026100510005287509 . 영상 설명란에도 링크된 기사
- 확인 방법: HTML 직접 수신, 본문 대조
- 정합성: 기사는 은행, 저축은행, 캐피탈, 온투업 여러 곳에서 "공격 또는 정보유출이 잇따라 확인됐다"고 씀(나열 원문에 가운뎃점이 있어 요지로 둠). "연달아 보도"와 같은 세기

**V-3. 영상 출처 표기 `[^video]` (확정)**
- 서지: 널널한 개발자 TV, 「예상 면접질문: 따릉이와 금융권 AI 해킹사고 어떻게 막을 수 있을까?」, YouTube, https://www.youtube.com/watch?v=fRyxfHkqf2M , 게시 2026-10-06T21:14:28-07:00(한국시간 2026-10-07 13:14)
- 확인 방법: oEmbed 재조회 `https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=fRyxfHkqf2M&format=json` 결과 `title` 동일, `author_name` "널널한 개발자 TV", `author_url` https://www.youtube.com/@nullnull_not_eq_null . 시청 페이지 HTML의 `publishDate`와 `shortDescription`. 녹화 시점은 전사(`_drafts/missing-authorization-backend.sources-video.md`, git 무시) 첫머리의 화자 발언 "2026년 10월 7일 오전 11시 7분"
- 정합성: 채널명과 제목 글자 그대로. 녹화 시점은 화자 발언이라고 밝혀 적었고 게시 시각(같은 날 13:14 KST)과 모순 없음. "뒤이어 취업 준비 조언으로 넘어간다"는 전사 후반과 맞음

**V-4. 영상 요지 서술과 직접 인용 여부 (확정, 보고 사항 1건)**
- 대조 대상: 전사 원문(STT). 요지 8곳: AI가 부각되나 원인은 다른 곳(L11), AI는 기법이 아니라 자동화로 범위를 넓힘(L11), 뿌리는 기본적인 접근 통제 부재(L11), 관리자용 API를 누구나 호출해 응답(L21), 대량 유출을 DDoS로 인식(L339), 확인된 뒤 방치(L343), 기본을 무시한 사건(L359), 개발보안 가이드 읽기 권유(L121)
- 확인 방법: 전사 대조. L121의 "영상이 읽기를 권한 ... 가이드"는 영상 설명란의 「소프트웨어 개발 보안 가이드」 링크가 `[^kisa]`의 KISA 게시글 URL(https://www.kisa.or.kr/2060204/form?postSeq=5&lang_type=KO&page=1)과 같은 것으로 확인
- 정합성: 모두 전사 내용과 맞음. **문장 단위 직접 인용은 없음.** 다만 낱말 "기본"을 따옴표로 쓴 곳이 L25("영상이 "기본"이라고 부른 것")와 L359("그 "기본"을") 두 곳 있다. 대사 인용이라기보다 용어 지칭이고 STT 오인식 위험이 없는 낱말이라 고치지 않았다. 규칙 적용은 오케스트레이터 판단

**V-5. NCSC `[^ncsc]` (확정, `(확인 필요: 게시일)` 플래그 해소)**
- 서지: UK National Cyber Security Centre, "Impact of AI on cyber threat from now to 2027", report, Published 7 May 2025(수정 16 May 2025). https://www.ncsc.gov.uk/report/impact-ai-cyber-threat-now-2027
- 확인 방법: HTML 직접 수신. 구조화 데이터 `"datePublished": "7 May 2025"`, `"dateModified": "16 May 2025"`, 화면 표기 "Published 7 May 2025". 인용 문장 부분 문자열 일치
- 정합성: 각주 날짜 2025-05-07 정확, 플래그 제거. 인용 문장 글자 그대로. 문장의 주어 "this"는 직전 문장 "Cyber threat actors are almost certainly already using AI to enhance existing tactics, techniques and procedures (TTPs) in victim reconnaissance, ..."를 가리켜, L13의 요지("AI가 ... 기존 기법을 다듬는 방식으로 침입의 양과 영향을 늘릴 가능성이 높다")는 정확. "highly likely"를 "가능성이 높다"로 옮긴 것은 약하게 옮긴 쪽이라 과장 아님. 노트 E-A3의 "(하위 에이전트 확인)"은 이것으로 해소

**V-6. Carlini et al. `[^carlini]` (확정)**
- 서지: Nicholas Carlini, Milad Nasr, Edoardo Debenedetti, Barry Wang, Christopher A. Choquette-Choo, Daphne Ippolito, Florian Tramèr, Matthew Jagielski, "LLMs unlock new paths to monetizing exploits", arXiv:2505.11449 [v1], 2025-05-16. https://arxiv.org/abs/2505.11449
- 확인 방법: abs 페이지의 `citation_title`, `citation_author`, `citation_date`, `citation_arxiv_id` 메타와 초록 텍스트 대조
- 정합성: 인용 두 문장("We argue that ..."과 "instead of human attackers ...") 초록과 글자 그대로. L13의 인라인 인용 "find thousands of easy-to-identify bugs in products with thousands of users"는 그 부분 문자열. 본문 해석은 초록과 같은 세기

#### 따릉이 사실관계

**V-7. 뉴시스 2026-02-23 송치 발표 보도 `[^newsis0223]` (확정)**
- 서지: 뉴시스, 최은수 조성하 기자, 2026-02-23 14:00 KST(`article:published_time`), 서울경찰청 사이버수사과 발표 보도(제목 원문에 가운뎃점이 있어 생략). https://www.newsis.com/view/NISX20260223_0003522553
- 확인 방법: HTML 직접 수신, 부분 문자열 대조
- 정합성:
  - L17 블록 인용 "이들은 가입자 정보 조회 시 필요한 최소한의 '인증 토큰' 검증 절차조차 없어, 특정 호출만 하면 서버가 무방비로 정보를 응답하는 허점을 파고든 것으로 조사됐다." 원고와 기사 글자 그대로. 참고: 기사의 '인증 토큰'은 곧은 작은따옴표인데, kramdown 기본 스마트 따옴표가 렌더 시 ‘인증 토큰’으로 바꾼다(같은 저장소 발행본에서 곧은 따옴표가 ‘’로 렌더되는 것을 확인). 원고는 원문과 같고 차이는 렌더러가 만든다. 그대로 둘지는 editor 또는 publisher 판단
  - L19 경찰 설명 "가입자 인증을 거쳐야 정보를 받아 오는 구조여야 하는데 그런 절차가 없어 미비했다": **한 글자도 다르지 않음.** 안에 따옴표가 없어 렌더 후에도 같다. 화자는 기사대로 "서울경찰청 관계자"
  - 발각 경위 원문("이번 사건은 경찰이 ... 드러났다."), 트래픽 원문("당초 대량 트래픽 ... 확인됐다.") 글자 그대로
  - 462만건, "2024년 6월 28일부터 29일 사이", "범행 당시 이들은 중학생", "10대 2명", 서울경찰청 사이버수사과: 기사와 같음
  - L15 "2026년 2월 송치": 기사는 "불구속 송치했다고 23일 밝혔다"로 발표일만 적고 송치일은 적지 않음(3/1 기사도 "지난달 23일 ... 송치했다고 밝혔다", 헤럴드경제 송고는 2/22 저녁). 주범 검거가 "올해 1월 말"이고 그 뒤 구속영장 신청 두 번이 반려된 뒤의 송치라 2월로 읽는 것이 합리적. **발표 기준으로 확정**하되, 송치일 자체는 보도에 없다는 점을 남긴다
  - L21 "경찰 설명에는 '관리자'라는 단어가 없습니다": 이 기사 본문 텍스트에서 '관리자' 0회

**V-8. 뉴시스 2026-03-01 해설 기사 (교정)**
- 서지: 뉴시스, 윤정민 기자, 「호기심에 따릉이 해킹한 10대 청소년…강경처벌이 해결책일까」, 2026-03-01 15:04 KST. https://www.newsis.com/view/NISX20260223_0003523249 (URL의 날짜 부분이 20260223이지만 게시는 3/1)
- 확인 방법: HTML 직접 수신, 대조
- 정합성: 이 기사의 문장은 "가입자 정보 조회 시 필요한 최소한의 '인증 토큰' 검증 절차조차 없어 특정 호출만 하면 서버가 무방비로 정보에 응답한다는 걸 알아냈다."로, 앞 절반은 2/23 기사와 같고 쉼표와 어미가 다르다. 각주의 "같은 취약점 문장"은 과장
- 교정: `[^newsis0223]`의 "같은 취약점 문장이" → "거의 같은 취약점 문장이"

**V-9. 서울신문 시의원 발언 보도와 회의록 `[^seoul]`, L21 (교정 1, 확정 2)**
- 서지: 서울신문, 「문성호 서울시의원, 서울시설공단 해킹 대비 물리적 인증 장치 구축 강구… “정답은 토큰에 있었어”」, 2026-03-05 10:05 KST. https://m.go.seoul.co.kr/news/2026/03/05/20260305500062 . 각주는 말줄임표 앞의 주 제목만 옮김
- 회의록: 서울특별시의회, 제334회 임시회 제1차 교통위원회 회의록, 2026-03-04(수) 오전 10시, 의사일정 "서울시설공단 2026년 주요업무 보고". https://ms.smc.seoul.kr/record/recordView.do?key=f6bc0d664ca8bb9d6322ed05cc13fc48629d23c955edbc9df03c9b32f8515c283c9c708646516515 (제2차 회의록 https://ms.smc.seoul.kr/record/recordView.do?key=fd87af20683246e723912415ec23d06f7b684f4ec9f0104cef986dc7f19aa772bfc93ca654c53ce2 의 관련 회의 목록에서 제1차 링크와 일자 "2026.03.04 수요일"을 얻음). 회기는 2026-02-24부터 03-13
- 확인 방법: 기사 HTML과 회의록 페이지 HTML 직접 수신, 텍스트 대조
- 정합성:
  - L21 "2026년 3월 서울시의회 상임위원회": 회의가 2026-03-04 교통위원회(상임위)라 **확정**
  - L21 "관리자 권한이라는 표현은 ... 발언 보도에서만 확인됩니다": 수집한 따릉이 기사 여섯 건(뉴시스 2/23, 3/1, 2/6, 비즈한국, 경향, 서울신문) 중 '관리자'가 나오는 것은 서울신문뿐(뉴시스 세 건, 비즈한국, 경향 모두 0회). **확정**
  - 각주의 "발언 원문" 표기: 인용 구절 "서울시설공단 내 관리자 권한으로 접근 가능한 정보에 인증 장치가 미비하다는 서버 설계상 허점"은 기사에서 따옴표 밖 서술("...허점을 노려 ... 해킹을 시도했다는 점을 설명하며")이다. 그리고 회의록 페이지 텍스트에는 '관리자'가 한 번도 나오지 않으며, 문 의원은 "보안토큰이 부재하다", "물리적 토큰"이라고 말했다. 발언 원문이 아니므로 **교정**
- 교정: "발언 원문:" → "발언을 전한 기사 서술 원문:"
- 보고: 이 결과는 D-3의 "관리자 권한 ... 은 문성호 시의원의 상임위 발언에만 나옴"보다 한 단계 약하다. "관리자"는 시의원 발언의 회의록이 아니라 그 발언을 전한 기사(보도자료로 보임)에만 있다. 본문에 이 점을 더 쓸지는 writer와 사용자 판단

**V-10. 비즈한국 해설 기사 (`[^seoul]` 안) (확정)**
- 서지: 비즈한국, 「따릉이, 중학생한테 개인정보 털린 황당한 이유」, 2026-02-23 16:04 KST(`article:published_time`). https://www.bizhankook.com/articles/31575.html (bizhankook.com으로 리다이렉트)
- 확인 방법: HTML 직접 수신, 대조
- 정합성: "가입자 인증이나 별도 권한 확인 없이도 정보 조회가 가능한 서버 설정의 취약성" 글자 그대로. 날짜 정확. "기자 서술"이라는 성격 표기도 맞음(따옴표 밖 문장)

**V-11. 뉴시스 2026-02-06 서울시 브리핑 보도 `[^newsis0206]` (확정)**
- 서지: 뉴시스, 이재은 기자, 「서울시설공단, 따릉이 개인정보유출 2024년 알고도 미조치(종합)」, 2026-02-06 13:00 KST. https://mobile.newsis.com/view/NISX20260206_0003505448
- 확인 방법: HTML 직접 수신, 대조
- 정합성: 제목 글자 그대로. L339 "따릉이 앱이 약 80분간 다운되자 행정안전부에 장애 신고를 했다" 글자 그대로. 원문은 "시에 따르면 2024년 6월28일부터 30일까지 ... 공격이 발생했다. 시는 따릉이 앱이 ... 신고를 했다."라 서울시 설명을 기자가 옮긴 문장이다. 본문의 "서울시는 "..."고 설명했습니다"는 내용상 맞으나 따옴표 안이 서울시의 직접 발언은 아니라는 점만 남긴다. 미조치 원문 "그러나 공단은 ... 1년7개월가량 묵인했다." 글자 그대로. "KT 클라우드 서버 관리 용역업체", "6월28일부터 30일까지"(`[^newsis0223]`의 "서울시 설명은 6월 28일부터 30일") 정확

**V-12. 경향신문 2026-02-06 `[^khan]`, L341 (확정)**
- 서지: 경향신문, 김은성 기자, 2026-02-06 14:17 KST, https://www.khan.co.kr/article/202602061417001 . 전체 제목은 「따릉이 앱 ‘개인정보 유출’ 보고서 숨긴 시설관리공단」 뒤에 가운뎃점 세 개와 부제 "서울시 “감사할 것”"이 붙는다. 각주는 주 제목만 옮김(가운뎃점 금지 규칙과 충돌해 그대로 둠)
- 확인 방법: HTML 직접 수신, 대조
- 정합성: L341 블록 인용과 각주의 "당시 공단은 관계기관에 '장애 발생' 이라고 신고했다."는 글자 그대로이되, 원문은 굽은 작은따옴표(‘개인정보가 유출됐다’, ‘장애 발생’)이고 원고는 곧은 따옴표다. kramdown 스마트 따옴표가 렌더 시 ‘’로 바꾸므로 렌더 결과는 원문과 같아진다. "서버 보안업체", 7월 18일 제출 정확. 각주의 제출 주체 대비(경향 "서버 보안업체", 뉴시스 "KT 클라우드 서버 관리 용역업체") 정확

**V-13. 따릉이 시간 계산 (확정)**
- 근거: V-7, V-11, V-12
- 정합성: "2024년 6월 말 따릉이 앱이 멈췄고"(6/28~30) 맞음. "유출은 3주 안에 보고서로 확인"은 6/28~30에서 7/18까지 18~20일이라 맞음. "1년 7개월가량"은 뉴시스 2/6 원문 "1년7개월가량"과 같고 2024-07에서 2026-02까지와도 맞음. L345 "그 트래픽이 유출 호출 자체였는지는 공개 기록이 확정하지 않습니다"는 D-3과 같은 수준(뉴시스 2/23은 "대량 트래픽 ... 디도스 공격으로 알려지기도 했으나 ... 해킹으로 확인"까지만 씀). L345 끝의 각주가 `[^newsis0223]` 하나라 "앱이 멈췄고, 장애로 신고됐습니다"의 근거(뉴시스 2/6, 경향)는 앞 문단 각주에 있다는 점만 남긴다

#### 표준 문서

**V-14. OWASP Top 10 A01 `[^a01]` (확정)**
- 서지: OWASP Top 10:2021 A01 Broken Access Control, https://owasp.org/Top10/A01_2021-Broken_Access_Control/ (현재 top10.owasp.org를 거쳐 /2021/A01_2021-Broken_Access_Control/index.html 로 리다이렉트, 링크는 동작). OWASP Top 10:2025 A01 Broken Access Control, https://owasp.org/Top10/2025/A01_2025-Broken_Access_Control/
- 확인 방법: 두 페이지 HTML 직접 수신, 대조와 소속 절 확인
- 정합성: 두 판 모두 "Example Attack Scenarios"(2025판은 "Example attack scenarios") 안의 Scenario #2에 "If an unauthenticated user can access either page, it's a flaw. If a non-admin can access the admin page, this is a flaw." 글자 그대로. 두 판 모두 "How to Prevent"(2025판 "How to prevent")에 "Except for public resources, deny by default."

**V-15. OWASP API Security Top 10 2023 API5 `[^api5]`, L23, L33 (확정)**
- 서지: OWASP API Security Top 10 2023, API5:2023 Broken Function Level Authorization. https://api-security.owasp.org/editions/2023/en/0xa5-broken-function-level-authorization/
- 확인 방법: HTML 직접 수신, 대조. 위험 표의 칸 구조를 파싱해 소속 확인
- 정합성: "Exploitation requires the attacker to ... as anonymous users or regular, non-privileged users."는 표의 "Threat agents/Attack vectors" 칸에 있어 본문의 "위협 주체"가 맞음. "Don't assume that an API endpoint is regular or administrative only based on the URL path."는 "Is the API Vulnerable?" 절, "The enforcement mechanism(s) should deny all access by default, requiring explicit grants to specific roles for access to every function."은 "How To Prevent" 절(각주의 "대책 항목")에 있음. 모두 글자 그대로. "API5인지 API1인지 가를 수 없다"는 D-4와 같은 판단

**V-16. CWE-306, CWE-862 `[^cwe306]` (확정)**
- 서지: MITRE, CWE-306: Missing Authentication for Critical Function, CWE List Version 4.20. https://cwe.mitre.org/data/definitions/306.html . CWE-862: Missing Authorization, https://cwe.mitre.org/data/definitions/862.html
- 확인 방법: 306 페이지 HTML 직접 수신(제목에 "(4.20)"), "Potential Mitigations" 절 소속 확인. 판본 날짜는 공식 XML `https://cwe.mitre.org/data/xml/cwec_latest.xml.zip` 안 `cwec_v4.20.xml`의 루트 속성 `Version="4.20" Date="2026-04-30"`. 862 페이지 제목 "CWE-862: Missing Authorization"
- 정합성: 인용문 두 문장 글자 그대로, 소속 절 맞음. 판본과 날짜 정확

**V-17. KISA, 행정안전부 「소프트웨어 개발보안 가이드」 `[^kisa]`, L123 (확정)**
- 서지: 행정안전부, 한국인터넷진흥원, 「소프트웨어 개발보안 가이드」, 2021.11 개정판(제개정 이력 마지막 항목 "2021.11. 구현단계 보안약점 기준 확대에 따른 내용 추가 및 수정"). 게시글 https://www.kisa.or.kr/2060204/form?postSeq=5&lang_type=KO&page=1 , PDF https://www.kisa.or.kr/post/fileDownload?menuSeq=2060204&postSeq=5&attachSeq=2&lang_type=KO (381쪽)
- 확인 방법: PDF 직접 수신, `pdftotext -layout`로 텍스트 추출 후 공백 정규화 대조, 쪽 머리말과 꼬리말로 인쇄 쪽수 확인
- 정합성: L123 인용 "프로그램이 모든 가능한 실행경로에 ... 유출할 수 있다."는 PDF 217쪽(인쇄 215쪽) "2. 부적절한 인가 / 가. 개요"에 줄바꿈만 다르고 글자 그대로. 제4장(꼬리말 "구현단계 시큐어코딩 가이드") 제2절 보안기능(PDF 214쪽, 인쇄 212쪽에서 시작) 소속 맞음. "③ 관리자 페이지에 대한 접근통제 정책을 수립하여 적용해야 한다."는 설계 절 "2.4 중요자원 접근통제"(인쇄 101쪽)와 부록 "SR2‐4. 중요자원 접근통제"(인쇄 345쪽, 원문 하이픈은 U+2010) 두 곳에 글자 그대로. 각주의 "SR2-4" 식별자는 부록 표기와 같음
- 참고: PDF 메타데이터 생성일이 2026-08-31(Hancom PDF)이나 제개정 이력은 2021.11에서 끝나 각주의 판본 표기와 모순 없음

#### Spring 소스, 문서, 실행 결과

**V-18. 5.8 마이그레이션 가이드와 gh-11958 `[^sec58]`, L39-41 (확정)**
- 서지: spring-projects/spring-security 태그 5.8.0, `docs/modules/ROOT/pages/migration/servlet/authorization.adoc` L653-655. https://github.com/spring-projects/spring-security/blob/5.8.0/docs/modules/ROOT/pages/migration/servlet/authorization.adoc?plain=1#L651-L658 . 이슈 gh-11958 「`RequestMatcherDelegatingAuthorizationManager` should deny when no match」, milestone 6.0.0-RC1, closed 2022-10-13. 커밋 753e113a13aa6ad71791129510d2c17dd8fd22ed "RequestMatcherDelegatingAuthorizationManager defaults to deny"(2022-10-13, Closes gh-11958)
- 확인 방법: raw 파일 줄번호 대조, `gh api repos/spring-projects/spring-security/issues/11958`, `gh api .../commits/753e113a...`
- 정합성: 세 문장이 L653, L654, L655에 글자 그대로. 마일스톤 정확

**V-19. `RequestMatcherDelegatingAuthorizationManager` 두 판 (확정)**
- 서지: 5.8.0과 6.5.11 태그 `web/src/main/java/org/springframework/security/web/access/intercept/RequestMatcherDelegatingAuthorizationManager.java`
- 확인 방법: raw 파일 줄번호 대조, 초안 코드 블록과 공통 들여쓰기만 뺀 행 단위 비교
- 정합성: 5.8.0 L85-86, 6.5.11 L94-97 모두 들여쓰기 외 차이 없음. 6.5.11 `DENY`는 L52 `new AuthorizationDecision(false)`

**V-20. `AuthorizationFilter`의 null 처리, L59 (확정)**
- 서지: 6.5.11과 5.8.0 태그 `web/.../access/intercept/AuthorizationFilter.java`
- 정합성: 6.5.11 L98-101 `if (result != null && !result.isGranted()) { throw ... }` 다음 `chain.doFilter`, 5.8.0도 `decision != null && !decision.isGranted()`일 때만 예외. null이면 예외 없이 통과가 맞음

**V-21. 레거시 `authorizeRequests()`, L59 (확정)**
- 서지: 6.5.11 `config/.../web/builders/HttpSecurity.java` L1139 `@Deprecated(since = "6.1", forRemoval = true)`, 7.0.0 같은 파일에 `authorizeRequests(` 0회. 6.5.11 `core/.../access/intercept/AbstractSecurityInterceptor.java` L140 `rejectPublicInvocations = false`, 속성이 비면 "Authorized public object %s"를 남기고 통과
- 정합성: "미매칭 요청을 그대로 통과(6.1부터 deprecated, 7.0에서 제거)" 정확

**V-22. Boot 2와 3의 Spring Security 판본, L59 (확정)**
- 서지: spring-boot v2.7.18 `spring-boot-project/spring-boot-dependencies/build.gradle` L1847 `library("Spring Security", "5.7.11")`, v3.0.0 같은 파일 L1422 `library("Spring Security", "6.0.0")`
- 정합성: "5.x를 쓰는 Boot 2 모듈과 6.x를 쓰는 Boot 3 모듈" 정확

**V-23. Boot 기본 체인 `SpringBootWebSecurityConfiguration.java:58` (확정)**
- 서지: spring-boot v3.5.16 `spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/security/servlet/SpringBootWebSecurityConfiguration.java`
- 정합성: L58 들여쓰기 외 글자 그대로. L59-60에 `formLogin`, `httpBasic`이 있어 L298 "Boot 기본 체인 (`formLogin`과 `httpBasic`)"과도 맞음

**V-24. 매핑 0개 예외 메시지 `AuthorizeHttpRequestsConfigurer.java` 6.5.11 L170 (확정)**
- 정합성: L169 `Assert.state(this.mappingCount > 0,` 다음 L170에 메시지 문자열 글자 그대로

**V-25. `authorize-http-requests.adoc` 6.5.11 `[^authz-doc]`, L72, L85 (확정)**
- 서지: 6.5.11 태그 `docs/modules/ROOT/pages/servlet/authorization/authorize-http-requests.adoc`, 렌더 https://docs.spring.io/spring-security/reference/6.5/servlet/authorization/authorize-http-requests.html
- 확인 방법: adoc 줄번호 대조, 렌더 HTML 텍스트 대조, 6.5.11 태그 tarball(`codeload.github.com/spring-projects/spring-security/tar.gz/refs/tags/6.5.11`)의 `docs/modules` 전체 193개 adoc grep
- 정합성: 앵커 `[[activate-request-security]]` L11, 문장 "Whenever you have an `HttpSecurity` instance, you should at least do:" L12, 첫 예시의 `.anyRequest().authenticated()` L23(코드 블록은 L21-24, 탭 블록은 L14-25). 각주의 "L10-23"은 빈 줄 L10에서 시작하지만 인용 내용을 모두 포함하므로 고치지 않음. 이 페이지에 L21보다 앞선 코드 예시는 없어 "첫 예시" 맞음. TIP L497, `denyAll` callout L765-766 글자 그대로. 렌더 페이지에서도 세 문장 일치
- 부정 진술 두 건: (1) "`authenticated()`로 끝낸 설정이 로그인한 누구에게나 관리자 기능을 연다고 직접 경고하는 문장은 6.5.11 레퍼런스에 없다"(L85), (2) "anyRequest를 빼면 6.0부터 거부된다는 설명은 6.5.11 레퍼런스 본문에 없다"(각주). 전체 adoc에서 "missing an authorization rule", "no authorization rule", "denies any request", "deny by default", "unmatched", "implied 6.0 default", "permitted by default", 그리고 `authenticated()`와 admin, 권한 경고의 근접 패턴을 grep했고 해당 문장 없음. 나온 것은 TIP L497과 "Any URL that has not already been matched on is denied access."(servlet L765, L822, reactive L109)뿐이라 두 진술 모두 grep 범위에서 확정

**V-26. Method Security 문서 `[^method-doc]`, L93, L95, L97 (확정)**
- 서지: 6.5.11 태그 `docs/modules/ROOT/pages/servlet/authorization/method-security.adoc`, 렌더 https://docs.spring.io/spring-security/reference/6.5/servlet/authorization/method-security.html
- 정합성: adoc L306-307(L307에 `xref:` 링크 마크업), "does not activate" L38(링크 마크업 포함). 렌더 페이지의 "It’s important to remember ... in your HttpSecurity instance."(굽은 따옴표)와 "Spring Boot Starter Security does not activate method-level authorization by default." 초안과 글자 그대로. "a catch-all authorization rule"의 렌더 링크는 `authorize-http-requests.html#activate-request-security`(adoc은 `xref:servlet/authorization/authorize-http-requests.adoc#activate-request-security`)이고, 그 앵커의 예시가 `.anyRequest().authenticated()`인 것은 V-25. W-4 첫 항목 확정

**V-27. Authorization Events와 기본 publisher `[^events]`, L351 (확정)**
- 서지: 6.5.11 태그 `docs/.../servlet/authorization/events.adoc` L4, L73, 렌더 https://docs.spring.io/spring-security/reference/6.5/servlet/authorization/events.html . `config/.../configurers/AuthorizeHttpRequestsConfigurer.java` L78-82, `core/src/main/java/org/springframework/security/authorization/SpringAuthorizationEventPublisher.java`
- 정합성: 렌더 문장 두 개 글자 그대로(adoc L4는 백틱, L73은 ``` ``AuthorizationGrantedEvent``s ``` 마크업). L78-82는 `AuthorizationEventPublisher` 빈이 있으면 그것을, 없으면 `new SpringAuthorizationEventPublisher(context)`. publisher는 L62-63이 메서드 시그니처, **L64 `if (result == null || result.isGranted()) {`, L65 `return;`**, L66 `}`. 본문의 "L63-65"는 시그니처 끝줄에서 시작하지만 인용 내용을 포함해 고치지 않음. W-4가 적은 "L63-65는 if ... 다음 return"은 한 줄 밀린 서술

**V-28. CSRF 테스트 문서, `CsrfFilter`, 필터 순서 `[^csrf]`, L281-283 (확정)**
- 서지: 6.5.11 태그 `docs/.../servlet/test/mockmvc/csrf.adoc` L4, 렌더 https://docs.spring.io/spring-security/reference/6.5/servlet/test/mockmvc/csrf.html . `web/.../csrf/CsrfFilter.java`, `config/.../web/builders/FilterOrderRegistration.java`
- 정합성: 렌더 문장 "... Spring Security’s CSRF protection, you must include a valid CSRF Token in the request." 글자 그대로. `CsrfFilter` L125 토큰 불일치 분기, L131 `this.accessDeniedHandler.handle(...)`, L132 `return;`이라 "AccessDeniedHandler를 직접 부르고 체인을 끝낸다" 정확. `FilterOrderRegistration` L89 `CsrfFilter`, L90 `LogoutFilter`, L130 `AuthorizationFilter` 순이라 "역할을 보기도 전에"(L283)와 "`/logout`처럼 `AuthorizationFilter`보다 앞의 필터"(L254) 정확

**V-29. `ExceptionHandlingConfigurer.java` 6.5.11 L236-238 (확정)**
- 정합성: L236 `createDefaultEntryPoint`, L237 매핑이 비면, L238 `return new Http403ForbiddenEntryPoint();` 정확

**V-30. `getHandlerMethods()` Javadoc `[^handler]` (확정)**
- 서지: spring-framework v6.2.19 `spring-webmvc/src/main/java/org/springframework/web/servlet/handler/AbstractHandlerMethodMapping.java`
- 정합성: L145 "Return a (read-only) map with all mappings and HandlerMethod's." 글자 그대로(Javadoc 블록 L144-146, 메서드 L147). 링크 #L144-L147 적절

**V-31. Boot 3.5 액추에이터 문서 `[^actuator]`, L257 (확정)**
- 서지: spring-boot v3.5.16 `spring-boot-project/spring-boot-docs/src/docs/antora/modules/reference/pages/actuator/endpoints.adoc`, 렌더 https://docs.spring.io/spring-boot/3.5/reference/actuator/endpoints.html
- 정합성: L239 "If you define a custom javadoc:...SecurityFilterChain[] bean, Spring Boot auto-configuration backs off and lets you fully control the actuator access rules." 본문은 마크업 없는 뒤쪽 구절만 인용, 렌더 페이지와 일치. L171 "By default, only the health endpoint is exposed over HTTP and JMX." 글자 그대로

**V-32. MockMvc 최소 예제 실행 결과 W-1~W-3 재실행 (확정)**
- 대상: 본문 L74-83 표, L97, L249-251, L271, L285-301 두 표와 문장, L228-233 실패 메시지, L327-331 깨뜨림 두 건
- 확인 방법: 같은 세션 scratchpad의 데모 프로젝트(`authz-demo`, `spring-boot-starter-parent` 3.5.16, Java 21 Corretto 21.0.1)를 `target/probe.txt`를 비운 뒤 `mvn -o test`로 다시 돌림(31 tests, 의도한 실패 1건). 깨뜨림 두 건은 `EndpointPolicyInventoryTest`를 복사한 임시 클래스 두 개로 재현한 뒤 지움
- 결과: W-2 표 24행 전부 같은 상태 코드. 특히 Boot 기본 체인 익명 Accept 없음 401(`WWW-Authenticate: Basic realm="Realm"`), json 401, html 302(`Location: http://localhost/login`), USER `/admin/users` 200, `/reports/sales` 200, `/actuator/health` 200. `/admin/**` hasRole + authenticated에서 USER export 200, POST 토큰 없음 403, 토큰 있음 403, ADMIN 토큰 없음 403, ADMIN 토큰 있음 200. 규칙 삭제 후 USER POST 토큰 없음 403, 토큰 있음 200. anyRequest 없음에서 USER export 403. denyAll에서 USER와 ADMIN export 403, USER `/actuator/health` 403. formLogin만 302, 인증 DSL 없는 자체 필터 403. `@EnableMethodSecurity`에서 `/reports/sales` 403, export 200
- `HandlerMapping` 빈 9개(welcomePage 둘, requestMapping, beanName, routerFunction, resource, healthEndpointWebMvc, webEndpointServlet, controllerEndpoint). `getHandlerMethods()`는 컨트롤러 6개와 `BasicErrorController`의 `/error` 2개, `/actuator/**` 없음
- 목록 대조 테스트 실패 메시지 끝 두 줄 "but found these extra elements:" / `  ["GET /internal/members/export"]` 글자 그대로. 짝 테스트 3건 통과
- 깨뜨림 1(`hasRole`을 `authenticated()`로): 3건 모두 USER 쪽 `Status expected:<403> but was:<200>`. 깨뜨림 2(여기에 `.with(csrf())`도 뺌): 2건은 USER 쪽 같은 메시지, 1건은 ADMIN 쪽 단언 줄에서 `Range for response status value 403 expected:<SUCCESSFUL> but was:<CLIENT_ERROR>`. CSRF 검사를 받는 것은 POST뿐이라 ADMIN 쪽 실패 1건은 POST로 특정됨
- 초안의 예시 코드(L189-225, L262-268, L306-324)는 데모의 `EndpointPolicyInventoryTest`와 같음(체인 설정은 `@TestConfiguration`에서 꺼내 따로 실음)

#### 공개 사례

**V-33. Artemis `[^artemis]`, L241-243, L257 (교정 1, 나머지 확정)**
- 서지: ls1intum/Artemis(MIT, 조직 "TUM Applied Education Technologies", 설명 "Technical University of Munich - School of Computation, Information and Technology"), 커밋 07f43f8e0b71037881624546c9dcf779498728ff(2026-10-07T20:33:05Z), `src/test/java/de/tum/cit/aet/artemis/core/authorization/AuthorizationArchitectureTest.java`(264줄)
- 확인 방법: raw 파일과 `gh api repos/ls1intum/Artemis/contents/...?ref=07f43f8e...` 두 경로로 받아 같은 파일임을 `cmp`로 확인, 줄번호 대조. 라이선스와 소속은 `gh api repos/ls1intum/Artemis`, `gh api orgs/ls1intum`
- 정합성: L231 `because` 문자열 글자 그대로. L114-115 "no annotated handler" / "serves the actuator endpoints." 정확(본문은 두 줄을 이어 인용). L249 위반 메시지와 L204-205 Javadoc에 `@EnforceNothing`(genuinely public)이 있어 L243 서술 맞음. 예외 목록 `UNAUTHENTICATED_ENDPOINT_BASELINE`은 L208-213의 7개라 "몇 개" 맞음. "TUM", "MIT" 맞음
- 오류: "so this set can only shrink."는 **L203**에 있다. 각주와 W-4가 적은 L204는 다음 줄("The clean way to remove an entry ...")
- 교정: `[^artemis]`의 "L204(예외 목록 주석)" → "L203(예외 목록 주석)". 노트 E-T2의 "(하위 에이전트가 ... 직접 대조 안 함)"은 이것으로 해소

#### 이 저장소 자기 사례

**V-34. #18과 `_config.yml` 차단 목록, L101-113 (확정)**
- 서지: 커밋 d20067e "fix: test/ 디렉터리가 프로덕션 사이트에 발행되던 문제 수정 (#18) (#19)", 2026-07-17. main `_config.yml` L70-77
- 확인 방법: `git show d20067e -- _config.yml`(추가된 줄은 `+  - test` 하나), `git show main:_config.yml`과 초안 블록 행 단위 비교. Jekyll 발행 규칙은 https://jekyllrb.com/docs/structure/ ("Except for the special cases listed above, every other directory and file ... will be copied verbatim to the generated site.") 와 https://jekyllrb.com/docs/configuration/options/ 의 Exclude 설명
- 정합성: `_config.yml` 블록은 머리 주석 한 줄 외 원문과 같음. "2026년 7월", "`test` 한 줄을 더한 것" 정확. "Jekyll은 `exclude`에 없는 파일을 전부 발행"은 `.`, `_`, `#`, `~`로 시작하는 항목의 기본 제외를 생략한 단순화지만, `test/` 같은 일반 디렉터리에 대해서는 문서와 같아 논지에 영향 없음

**V-35. `CLAUDE.md` 인용, L129, L257 (확정)**
- 확인 방법: `git show main:CLAUDE.md`와 부분 문자열 대조
- 정합성: "외부 요청 없는 페이지", "이 계약들은 **`test/site_output_test.rb`에 잠겨 있다.**", "`_config.yml`의 `exclude`는 **이 저장소의 파일에만 먹고 테마 fall-through 파일에는 안 먹는다** (실험으로 확인)" 모두 굵게 표시까지 원문 그대로

**V-36. 발행본 인용과 링크 (확정)**
- 확인 방법: `git show main:_posts/...`와 부분 문자열 대조, 소속 절 확인. 링크 경로는 실제 사이트 빌드 산출물(V-37)의 파일 경로로 확인(`_config.yml`에 permalink 설정 없음, Jekyll 기본 date 형식)
- 레이트리미터 편(`_posts/2026-08-09-rate-limiter-payment-platform.md`): "라이브러리 기본값이 곧 정책이니까요."(L59), "키를 무엇으로 하는가"(L347, 원문은 "## 알고리즘보다 먼저 정해야 하는 것 두 가지" 아래 "### 2. 키를 무엇으로 하는가"라 "알고리즘보다 먼저 정해야 할 것으로 꼽았다"는 서술 정확), "**완벽한 알고리즘도 안 걸린 경로는 못 막습니다.**", "**"초당 몇 건"(속도)과 "동시에 몇 개"(동시성)는 다른 축입니다.**"(L349), "**지금 무엇이 나 대신 골라져 있는지 확인하는 것**"(L363) 모두 원문 그대로
- 장애 대응 편(`_posts/2026-07-24-incident-response-pipeline.md:96`): "사람의 주의력 향상에 기대는 대책은 대책이 아니다." 원문 그대로. Milstein 인용 뒤에 필자가 쓴 문장이라 "장애 대응 편에 쓴 문장" 정확
- 테스트 기준 1편: "목표치보다 제외 규칙이 더 많은 판단을 담고 있었습니다."는 "## 무엇을 배웠는가"(결론) L466, "**부정 단언이라면, 틀린 이유로 통과할 경로가 몇 개인가.**"는 "## 테스트를 쓰기 전에 물어볼 것"(체크리스트) L476. 1편이 외부 요청 부정 단언을 의도적으로 지킨 계약의 예로 든 것은 L218과 L275 표 행("✅ 의도적으로 지킨 계약이 깨진다")
- 테스트 기준 3편: "**이 게이트가 실제로 빨간불이 된 적이 있는가.**"(L387), "**그 검사기가 못 보는 집단은 무엇인가.**"(L382) 모두 "## 규칙을 넘기기 전에 물어볼 것"(체크리스트). #18을 "검사기가 자기 최적화 때문에 자기를 못 봤습니다"(L334) 각도로 다룬 것은 "### 실패를 확인한 단언 하나"(L319-341)라 L115 서술 정확
- 링크: `/2026/08/09/rate-limiter-payment-platform.html`, `/2026/08/11/test-standards-3-delegating-standards.html`, `/2026/07/24/incident-response-pipeline.html`, `/2026/08/11/test-standards-1-what-to-test.html` 모두 빌드 산출물에 존재

**V-37. #125 자기 사례의 숫자, L131-137 (확정)**
- 확인 방법: main(1cc6268)과 `feature/125-site-wide-external-request-check`(5533e74)를 `git archive`로 scratchpad에 풀어(저장소 작업 트리는 건드리지 않음) Ruby 3.4로 실행
- 이름으로 검사하던 6개: main `test/site_output_test.rb`의 외부 스타일시트, 스크립트 부정 단언 대상은 `index`(L75), `search`(L81), `flowcast_post`(L108-109), `rate_limiter_post`(L124, L126), `jev_post`(L136, L138), `jev_intro_post`(L160, L162)로 6개. 임베드 글 4편 정확
- 손으로 더한 이력: e8d7920(#36, 2026-07-18, flowcast), 164f512(#82, 2026-08-09, 레이트리미터), 68a73a0(#111, 2026-09-29, Jev), 6b2fabd(#115, 2026-09-29, Jev 입문) 각각 그 글 전용 `refute_match` 두 줄 추가 확인
- 181 assertions: main에서 `about.md` 끝에 `<script src="https://example.com/injected.js"></script>`를 붙이고 `bundle exec ruby test/site_output_test.rb` 결과 `1 runs, 181 assertions, 0 failures, 0 errors, 0 skips` 재현(주입 없이도 181)
- 지운 단언 10개: `git diff main feature/125-... -- test/site_output_test.rb`에서 지운 `refute_match` 10줄
- HTML 18개: main 실제 사이트 빌드(`bundle exec jekyll build`, 픽스처 없음) 산출물 `*.html` 18개(포스트 11, `index.html`, `page2/index.html`, `page3/index.html`, `about/index.html`, `search.html`, `tags.html`, `404.html`)
- 165 assertions: 브랜치 정상 상태 `1 runs, 165 assertions, 0 failures, 0 errors, 0 skips` 재현

**V-38. #125 인용 코드와 실패 메시지, L139-180 (확정)**
- 확인 방법: `git show feature/125-site-wide-external-request-check:test/site_output_test.rb`의 L187-209를 앞 공백 두 칸만 지워 초안 L141-163과 `diff`, main L75를 앞 공백만 지워 초안 L179와 `cmp`
- 정합성: 두 인용 모두 **들여쓰기 외 차이 없음.** 위치 표기 L187-209, L75 정확
- 실패 메시지: 브랜치에 about 외부 스크립트, Chirpy 편 `<link rel="stylesheet" href="//cdn.example.com/injected.css">`, 404 `<link rel="preload" as="style" href="https://cdn.example.com/preloaded.css">`를 넣고 실행. 출력 두 줄이 초안 L169-170과 `diff` 기준 같음. 세 곳이 한 번에 걸림(`1 runs, 5 assertions, 1 failures`)

**V-39. PR #126 상태, L137 (확정)**
- 확인 방법: `gh pr view 126` 결과 state OPEN, mergedAt null, head `feature/125-site-wide-external-request-check`. Issue #125 「test: 외부 요청 0 계약이 이름으로 고른 페이지 여섯 개에만 걸려 있다」 OPEN
- 정합성: "이 글을 쓰는 시점에 merge 대기" 2026-10-08 기준 정확. 발행 전에 merge되면 이 구절은 시점 표현이라 publisher가 확인할 것

**V-40. "첫 구현은 `rel="stylesheet"`인 link만 봤다", L175-182 (확정, 작업 기록 근거)**
- 근거: 노트 "I-2 해소"의 작업 관찰(필자 작업 기록). 커밋은 최종본 하나라 코드로 재현할 수 없음
- 정황 확인: Issue #125 본문(작성 순서상 먼저)의 변경 항목에는 프로토콜 상대 URL과 작은따옴표만 있고 `.css`가 없음. PR #126 본문에 "`rel`과 무관한 외부 `.css`(기존 index 단언의 범위)"가 추가돼 있음. 지운 main L75 단언이 rel 조건 없이 외부 `.css`를 잡는다는 것과, 최종 구현의 `href.match?(/\.css\b/i)`가 그 범위를 덮는다는 것은 코드로 확인
- 정합성: 본문 서술과 정황이 모순 없음

### 미해결 질문 대조 결과 (verifier)

- 글 전제의 조정: 해소(사용자 결정 절). 초안은 경찰 설명 그대로 인용하고 "관리자 API"가 공식 조사로 확인되지 않았다고 밝힘(V-7, V-9)
- 따릉이 엔드포인트 성격, 토큰 미요구와 미검증, 80분 장애 원인, 호출당 건수: **미해소**(공개 자료 없음). 초안은 단정하지 않음(L21, L345, `[^api5]`)
- 개인정보위 처분: 미해소. 본문 미사용
- 2026년 가을 은행권 사고: 본문 범위에서 해소(V-1, V-2). 보도 유동성 자체는 미해소
- E-T4의 401, 302, 403 분기와 CSRF 403: 해소(W-2, V-32 재실행)
- springdoc `/v3/api-docs`: 미해소. 본문 미사용
- 하위 에이전트만 확인한 인용 중 본문에 들어간 것: NCSC(V-5), Artemis(V-33) 해소. OWASP A07 매핑, CWE-285 Mapping Usage, ldapportal, Schwenke, ASVS, Fang, Anthropic, ARTEX 대회 정보, 헤럴드경제와 기타 금융권 기사는 본문에 없어 대조하지 않음(미대조로 남김)
- 영상 화자 채널명: 해소(V-3)
- 선택 과제(외부 요청 단언 확대): 해소(#125, #126, V-37~V-39)
