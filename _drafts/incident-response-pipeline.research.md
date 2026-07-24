# 리서치: 장애 대응은 기술 이전에 파이프라인이다

## 근거

### 내부 근거

- (내부) 이 블로그 저장소(`_posts/`, `_drafts/`)에 장애 대응, 인시던트, 타임아웃, 회복탄력성 관련 기존 포스트/노트 없음 — 확인: `grep -rl` 결과 NO_MATCH. 이 주제는 블로그에서 처음 다루는 영역이다.
- (내부) 소재의 핵심 경험: 결제 시스템 외부 연동 구간에서 커넥션 타임아웃 발생 → 실패율 급증 → 원인 진단 지연 → 근본 원인은 기술이 아니라 장애 대응 플로우(누가/무엇을/언제/어떻게) 미숙지 — 작성자 당일 경험 (2026-07-24). *주의: 회사/서비스/PG사 식별 정보 절대 포함 금지*.

### 커넥션 타임아웃 → 실패율 급증 메커니즘

- (외부) **재시도 폭풍(retry storm) 메커니즘**: 요청이 커넥션 풀에서 커넥션을 기다리다 타임아웃 → 클라이언트가 재시도 → 재시도도 이미 고갈된 풀에서 대기 → 풀이 더 밀림 → 더 많은 타임아웃 → 더 많은 재시도. "moderate load produces total failure within seconds" — 출처: https://howtech.substack.com/p/connection-pool-exhaustion-the-silent
- (외부) LinkedIn 4시간 장애, Stripe 결제 처리 장애가 정확히 이 커넥션 풀 고갈 → 재시도 폭풍 패턴으로 발생 — 출처: https://howtech.substack.com/p/connection-pool-exhaustion-the-silent
- (외부) **Circuit Breaker 패턴**: Michael Nygard, *Release It!* (2007)에서 제안. "many callers on an unresponsive supplier, then you can run out of critical resources leading to cascading failures across multiple systems." Martin Fowler가 이를 "prevent this kind of catastrophic cascade"로 소개 — 출처: https://martinfowler.com/bliki/CircuitBreaker.html
- (외부) Integration Points without Timeouts은 Cascading Failure를 만드는 확실한 방법. 가장 효과적 방어 패턴은 Circuit Breaker + Timeout 조합 — 출처: https://martinfowler.com/bliki/CircuitBreaker.html (Nygard 인용)
- (외부) 방어 계층: bounded queue(찬 즉시 거절), exponential backoff with jitter(재시도 분산), bulkhead pattern(서비스별 커넥션 풀 격리) — 출처: https://howtech.substack.com/p/connection-pool-exhaustion-the-silent, https://www.radview.com/blog/connection-pool-exhaustion-detect-diagnose-fix

### 장애 대응 파이프라인 (탐지 → 트리아지 → 완화 → 사후조치)

- (외부) **Google SRE Book, Chapter 14: Managing Incidents** — 역할 체계:
  - **Incident Commander**: 전체 대응 지휘, 역할 위임, 상황 파악. 기술적 트러블슈팅은 직접 하지 않음
  - **Operations Lead**: 실제 시스템 변경 수행. "The operations team should be the only group modifying the system during an incident"
  - **Communications Lead**: 이해관계자 주기적 업데이트, 정확한 문서 유지
  - **Planning Lead**: 장기 이슈 지원, 버그 등록, 교대 조율
  - 출처: https://sre.google/sre-book/managing-incidents/
- (외부) **비관리 인시던트의 문제**: 기술에 몰두해 상황 인식(situational awareness) 상실, 여러 엔지니어가 조율 없이 각자 변경("freelancing"), 리더십이 현황 파악 불가, 커뮤니케이션 단절로 위임 불가 — 출처: https://sre.google/sre-book/managing-incidents/
- (외부) "Effective incident management is key to limiting the disruption caused by an incident and restoring normal business operations" — 기술적으로 유능한 엔지니어도 프로세스 구조 없이는 혼란을 만든다. 위기 시 조율(coordination)이 개인의 기술력(individual brilliance)보다 중요 — 출처: https://sre.google/sre-book/managing-incidents/
- (외부) **7단계 인시던트 대응 라이프사이클**: Preparation → Detection/Alerting → Triage/Prioritization → Containment → Resolution/Eradication → Recovery → Postmortem — 출처: https://rootly.com/incident-response/lifecycle-process
  - 각 단계 건너뛸 때의 결과:
    - Preparation 미비: "scramble blindly when minutes matter"
    - Detection 미조정: 과잉 알림 → 피로, 느슨한 임계값 → 미탐지
    - Triage 불명확: 책임 소재 논쟁에 시간 낭비
    - Containment 미실행: 작은 장애가 전체 시스템으로 전파. "Containment rarely fixes the problem fully, but it restores breathing space"
    - Recovery 급진: "yo-yo outages" — 같은 장애 재발
    - Postmortem 미실시: "Lessons lost today guarantee repeat pain tomorrow"
- (외부) **핵심 지표**:
  - MTTA (Mean Time to Acknowledge): 문제 인지 속도
  - MTTR (Mean Time to Resolve): 탐지부터 완전 복구까지 총 소요 시간
  - "Teams that invest in observability, clear incident roles, and practised runbooks consistently achieve lower MTTR than those relying on heroic individual effort" — 출처: https://www.pagerduty.com/resources/incident-management-response/learn/best-practices-to-reduce-mttr/
- (외부) 인시던트 선언 기준: 다수 팀 관여, 고객 가시적 영향, 1시간 이상 미해결 중 하나 — 출처: https://sre.google/sre-book/managing-incidents/

### Blameless Postmortem

- (외부) **Google SRE Book, Chapter 15: Postmortem Culture** — "A blamelessly written postmortem assumes...everyone involved...had good intentions and did the right thing with the information they had." — 출처: https://sre.google/sre-book/postmortem-culture/
- (외부) "The cost of failure is education." — Devin Carraway (Google SRE 인용) — 출처: https://sre.google/sre-book/postmortem-culture/
- (외부) "You can't 'fix' people, but you can fix systems" — 사람의 행동이 아니라 시스템 설계를 바꿔야 한다 — 출처: https://sre.google/sre-book/postmortem-culture/
- (외부) "If a culture of finger pointing...prevails, people will not bring issues to light for fear of punishment." — 출처: https://sre.google/sre-book/postmortem-culture/
- (외부) **Google SRE Workbook, Postmortem Culture** — 실효성 조건:
  - 인시던트 종료 수일 내 발행 (수개월 후 X)
  - 해당 팀만이 아니라 조직 전체에 공유
  - 모든 액션 아이템에 명확한 담당자 + 추적 번호 부여
  - 액션 아이템 완료율을 체계적으로 모니터링
  - postmortem 작업을 기능 개발과 동등한 우선순위로 다룸
  - "To our users, a postmortem without subsequent action is indistinguishable from no postmortem" (Ben Treynor Sloss, VP 24/7 Operations) — 출처: https://sre.google/workbook/postmortem-culture/
- (외부) Dan Milstein 인용: "Let's plan for a future where we're all as stupid as we are today" — 사람의 개선이 아니라 시스템 개선에 집중 — 출처: https://sre.google/workbook/postmortem-culture/
- (외부) **비효과적 postmortem 패턴**: 비난 언어 사용("careless ignorance"), 모호한 액션("improve X"), 인간 행동 교정에 초점, 발행 지연, 범위 제한(팀 내부만), 이전 액션 미이행 → 같은 인시던트 반복 — 출처: https://sre.google/workbook/postmortem-culture/
- (외부) postmortem 트리거 기준: 사용자 가시적 다운타임, 데이터 유실, 온콜 엔지니어 개입(롤백/트래픽 우회), 해결 시간 임계값 초과, 모니터링 실패로 수동 발견 — 출처: https://sre.google/sre-book/postmortem-culture/

### 결제 시스템 특유의 고려사항

- (외부) **타임아웃 시 이중 결제 방지 — idempotency key**: 클라이언트가 요청에 고유 idempotency key를 포함 → 서버가 키 존재 여부 확인 → 없으면 처리 후 결과 저장 → 같은 키로 재요청 시 재처리 않고 저장된 결과 반환. "Without idempotency, a simple network timeout during a payment could result in the customer being charged twice when the request is retried" — 출처: https://dzone.com/articles/art-of-idempotency-preventing-double-charges-and-duplicate
- (외부) 결제 시스템 신뢰성은 다층적: idempotency 강제 + 상세 로깅/옵저버빌리티 + 모든 외부 호출에 적절한 타임아웃 + exponential backoff with jitter — 출처: https://dzone.com/articles/art-of-idempotency-preventing-double-charges-and-duplicate
- (외부) 결제 특유의 복잡성: 타임아웃이 "결제가 실패한 건지 성공했는데 응답만 못 받은 건지" 불분명한 상태(indeterminate state)를 만든다. 이 불확실 상태가 장애 대응에서 진단을 더 어렵게 한다 — 출처: https://medium.com/@tatomoaki/idempotency-for-payments-preventing-double-charges-8e58aed88b93

## 인사이트 후보

1. **프로세스의 부재가 기술적 원인보다 MTTR을 더 늘린다**: 커넥션 타임아웃 자체는 원인을 알면 완화할 수 있다(커넥션 풀 조정, circuit breaker, 재시도 제한). 그런데 "원인을 아는 데까지" 가는 시간이 길었던 이유는 기술 부족이 아니라, 누가 어떤 대시보드를 먼저 보고, 누가 어떤 구간을 확인하며, 누가 의사결정을 내리는지의 흐름(파이프라인)이 부재했기 때문이다 — 근거: Google SRE "coordination matters more than individual brilliance" + 비관리 인시던트의 "freelancing" 문제 + 작성자 경험
2. **장애 대응은 "알림 받고 고친다"가 아니라 7단계 파이프라인이다**: 탐지 → 트리아지 → 완화 → 해결 → 복구 → 사후분석까지 전체 흐름을 팀이 숙지해야 한다. 특히 완화(containment) 단계를 건너뛰고 바로 근본 원인을 찾으려 하면 장애 범위가 계속 확대된다. "Containment rarely fixes the problem fully, but it restores breathing space" — 근거: Rootly lifecycle + 작성자 경험
3. **결제 시스템에서 타임아웃은 '실패'보다 나쁜 '불확실'을 만든다**: 실패는 명확하다. 타임아웃은 "결제가 됐는지 안 됐는지 모르는" 상태를 만든다. 이 불확실 상태가 재시도 판단을 어렵게 하고, 재시도가 이중 결제를 만들 수 있어, idempotency 같은 안전장치 없이는 장애 대응 자체가 새로운 장애를 만든다 — 근거: DZone idempotency 문서 + Medium 결제 타임아웃 글
4. **Postmortem은 "문서 쓰기"가 아니라 "시스템 바꾸기"다**: "To our users, a postmortem without subsequent action is indistinguishable from no postmortem." 액션 아이템 없는 회고는 회고가 아니고, 액션 아이템이 실행되지 않는 회고는 다음 장애를 보장한다 — 근거: Google SRE Workbook, Ben Treynor Sloss 인용
5. **"사람을 고칠 수 없다, 시스템을 고쳐라"**: 비난 문화에서는 정보가 숨겨진다. "Let's plan for a future where we're all as stupid as we are today"(Dan Milstein) — 사람의 주의력/역량 향상에 기대는 대책은 대책이 아니다. 런북, 자동 알림, circuit breaker 같은 시스템적 방어가 진짜 대책이다 — 근거: Google SRE Book/Workbook postmortem culture

## 미해결 질문

- ~~커넥션 타임아웃 → 재시도 폭풍 메커니즘에서 LinkedIn/Stripe 사례를 구체적으로 인용하려면 원본 postmortem이나 공식 블로그 포스트를 확인해야 한다.~~ **[해소]** writer가 본문에서 LinkedIn/Stripe 구체 사례를 인용하지 않음. 미사용으로 검증 불요.
- ~~Ben Treynor Sloss의 "A postmortem without subsequent action..." 인용은 WebFetch에서 truncated됨.~~ **[해소 — 검증 기록 V-11 참조]** writer가 본문에서 이 인용을 사용함. verifier가 SRE Workbook 원문을 WebFetch로 확인, 정확한 원문은 "To our users, a postmortem without subsequent action is indistinguishable from no postmortem." — 리서치 노트 원문과 초안의 misquotation을 모두 교정 완료.
- 결제 시스템 장애 대응 관련 공식 표준(PCI DSS incident response requirement 등)이 있을 수 있으나, 이 글의 각도(프로세스 인사이트)에서 필수적이지는 않다. 필요 시 별도 확인. **[미해소 — 본문에서 미인용, 검증 불요]**
- 국내 결제 시스템 장애 대응 사례(공개된 postmortem 등)는 검색하지 않았다. 글에서 특정 사례를 참조하려면 별도 리서치 필요하나, 익명화/일반화 원칙상 사용하기 어려울 수 있다. **[미해소 — 본문에서 미인용, 검증 불요]**

## 검증 기록

검증 일시: 2026-07-24
검증 대상: `_drafts/incident-response-pipeline.md`
검증 방법: WebFetch로 1차 출처 원문 대조 (Google SRE Book/Workbook, Rootly, Martin Fowler)

### 확정 항목

**V-01. "freelancing" 개념 — Google SRE Book, Chapter 14**
- 서지/출처: Google SRE Book, Chapter 14: Managing Incidents. https://sre.google/sre-book/managing-incidents/
- 확인 방법: WebFetch로 해당 페이지 원문 확인. Malcolm이 Mary와 조율 없이 시스템을 변경하는 예시에서 freelancing 개념이 사용됨.
- 본문 대비 정합성: 본문 "비관리 인시던트에서 엔지니어들이 조율 없이 각자 시스템을 변경하는 것을 'freelancing'이라 부른다"는 정확. 단, 본문이 이어서 쓴 "상황 인식(situational awareness)"은 SRE Book에서 이 영어 용어를 사용하지 않음 — 개념(엔지니어들이 전체 상황 파악을 잃는 것)은 SRE Book이 묘사하는 바와 일치하나, 특정 영어 용어는 저자의 한국어 서술에 대한 번역 보조어로 봄. 문맥상 SRE Book이 이 용어를 쓴다고 직접 주장하지 않으므로('"이라 부른다"는 freelancing에만 사용) 오류로 판정하지 않음.

**V-02. 비관리 인시던트의 문제점 묘사 — Google SRE Book, Chapter 14**
- 서지/출처: Google SRE Book, Chapter 14: Managing Incidents. https://sre.google/sre-book/managing-incidents/
- 확인 방법: WebFetch로 해당 페이지 원문 확인.
- 본문 대비 정합성: "리더십이 현황을 파악할 수 없게 되고, 커뮤니케이션이 끊어져 위임조차 불가능해지는 상태" — SRE Book의 비관리 인시던트 묘사와 일치.

**V-03. "위기에서 조율이 개인의 기술력보다 중요하다" — 일반 원칙**
- 서지/출처: 본문이 "교과서에서 읽으면 당연한 소리"로 일반 원칙 취급. Google SRE Book Chapter 14가 이 개념을 체계적으로 다룸 ("channel the energies of enthusiastic individuals").
- 확인 방법: WebFetch로 SRE Book Ch14 확인. "individual brilliance"라는 정확한 영어 구문은 SRE Book에 없으나, 본문은 이를 SRE Book의 직접 인용으로 제시하지 않고 저자 자신의 표현으로 사용.
- 본문 대비 정합성: 개념은 정확. 영어 괄호 "(individual brilliance)"는 저자 표현.

**V-04. 7단계 인시던트 대응 라이프사이클 — Rootly**
- 서지/출처: Rootly, "Incident Response Lifecycle Process." https://rootly.com/incident-response/lifecycle-process
- 확인 방법: WebFetch로 해당 페이지 원문 확인. 단계명: Preparation, Detection and Alerting, Triage and Prioritization, Containment, Resolution and Eradication, Recovery, Postmortem and Continuous Improvement.
- 본문 대비 정합성: 본문이 사용한 7단계(준비/탐지/트리아지/완화/해결/복구/사후조치)는 Rootly 단계명의 정확한 한국어 대응. Rootly 원문의 각 단계에 붙은 보조어(and Alerting, and Prioritization 등)는 생략했으나 의미 변경 없음.

**V-05. "scramble blindly when minutes matter" — Rootly**
- 서지/출처: Rootly, "Incident Response Lifecycle Process." https://rootly.com/incident-response/lifecycle-process (Core Principles 절)
- 확인 방법: WebFetch로 해당 페이지에서 원문 확인. "Drafting clear playbooks and maintaining runbooks ensure no one scrambles blindly when minutes matter."
- 본문 대비 정합성: 본문 "분 단위로 중요한 순간에 눈먼 채로 허둥"은 원문의 정확한 의역. 괄호 안 원문도 정확.

**V-06. "Containment rarely fixes the problem fully, but it restores breathing space." — Rootly**
- 서지/출처: Rootly, "Incident Response Lifecycle Process." https://rootly.com/incident-response/lifecycle-process (Containment 절)
- 확인 방법: WebFetch로 해당 페이지에서 원문 확인. 전문: "Containment rarely fixes the problem fully, but it restores breathing space where panic would otherwise reign."
- 본문 대비 정합성: 본문은 "where panic would otherwise reign" 절을 생략. 의미 변경 없음(수사적 부가어). 블로그 인용으로 허용 범위.

**V-07. "yo-yo outages" — Rootly**
- 서지/출처: Rootly, "Incident Response Lifecycle Process." https://rootly.com/incident-response/lifecycle-process (Recovery 절)
- 확인 방법: WebFetch로 해당 페이지에서 원문 확인. "Regression monitoring ensures that the same failure mode doesn't return, sparing teams from yo-yo outages."
- 본문 대비 정합성: 본문 "요요 장애(yo-yo outages)" — 원문 그대로. 복구 급진 시 재발 맥락도 일치.

**V-08. 인시던트 선언 기준 — Google SRE Book, Chapter 14**
- 서지/출처: Google SRE Book, Chapter 14: Managing Incidents. https://sre.google/sre-book/managing-incidents/
- 확인 방법: WebFetch로 해당 페이지 원문 확인. "Do you need to involve a second team in fixing the problem? Is the outage visible to customers? Is the issue unsolved even after an hour's concentrated analysis?"
- 본문 대비 정합성: 본문 "다수 팀 관여, 고객 가시적 영향, 1시간 이상 미해결" — 세 기준 모두 정확.

**V-09. IC 역할 분리 — Google SRE Book, Chapter 14**
- 서지/출처: Google SRE Book, Chapter 14: Managing Incidents. https://sre.google/sre-book/managing-incidents/
- 확인 방법: WebFetch로 해당 페이지 원문 확인. IC: "holds the high-level state about the incident," "structure the incident response task force, assigning responsibilities." Ops Lead: "works with the incident commander to respond to the incident by applying operational tools."
- 본문 대비 정합성: 본문 "인시던트 커맨더가 직접 트러블슈팅하지 않는다"는 SRE Book에서 명시적 금지문으로 나오지 않으나, IC 역할(high-level state, 역할 위임)과 Ops Lead 역할(시스템 변경 수행)의 분리 설계에서 도출되는 핵심 원칙. "Google SRE가 강조하는 핵심"이라는 본문의 표현은 역할 분리 설계의 공정한 요약으로 봄.

**V-10. "You can't 'fix' people, but you can fix systems" — Google SRE Book, Chapter 15**
- 서지/출처: Google SRE Book, Chapter 15: Postmortem Culture: Learning from Failure. https://sre.google/sre-book/postmortem-culture/
- 확인 방법: WebFetch로 해당 페이지 원문 확인. 전문: "You can't 'fix' people, but you can fix systems and processes to better support people making the right choices..."
- 본문 대비 정합성: 본문은 "systems" 이후를 생략. 원문의 "and processes to better support people making the right choices"는 의미를 확장하나, "시스템을 고쳐라"는 핵심 메시지를 정확히 전달. 블로그 인용으로 허용 범위.

**V-12. Dan Milstein 인용 — Google SRE Workbook**
- 서지/출처: Google SRE Workbook, Postmortem Culture. https://sre.google/workbook/postmortem-culture/
- 확인 방법: WebFetch로 해당 페이지에서 원문 확인. "Let's plan for a future where we're all as stupid as we are today."
- 본문 대비 정합성: 정확히 일치. Dan Milstein 귀속도 정확.

**V-13. Postmortem 실효성 조건 — Google SRE Workbook**
- 서지/출처: Google SRE Workbook, Postmortem Culture. https://sre.google/workbook/postmortem-culture/
- 확인 방법: WebFetch로 해당 페이지에서 원문 확인. 수일 내 발행("less than a week after"), 조직 전체 공유("internal communication channels"), 액션 아이템에 담당자+추적번호("both an owner and a tracking number"), 완료율 추적("action items don't slip through the cracks"), 기능 개발과 동등 우선순위("Prioritize postmortem work").
- 본문 대비 정합성: 5개 조건 모두 SRE Workbook 원문과 일치. 본문 "파이프라인" 절(line 123)의 "3일 이내"는 저자 자신의 규칙(SRE Workbook의 "수일 내"를 구체화)으로, 외부 인용이 아님.

**V-14. Blameless postmortem 개념 — Google SRE Book, Chapter 15**
- 서지/출처: Google SRE Book, Chapter 15: Postmortem Culture. https://sre.google/sre-book/postmortem-culture/
- 확인 방법: WebFetch로 해당 페이지 원문 확인. "A blamelessly written postmortem assumes that everyone involved in an incident had good intentions..." / "If a culture of finger pointing and shaming individuals or teams for doing the 'wrong' thing prevails, people will not bring issues to light for fear of punishment."
- 본문 대비 정합성: 본문의 blameless 문화 설명은 원문과 일치.

**V-15. Idempotency key 개념 — DZone / Medium**
- 서지/출처: DZone, "Art of Idempotency: Preventing Double Charges and Duplicate." https://dzone.com/articles/art-of-idempotency-preventing-double-charges-and-duplicate / Medium, Tato Moaki, "Idempotency for Payments." https://medium.com/@tatomoaki/idempotency-for-payments-preventing-double-charges-8e58aed88b93
- 확인 방법: 리서치 노트의 DZone/Medium 출처와 대조.
- 본문 대비 정합성: 본문 "같은 키로 재요청이 오면 재처리하지 않고 저장된 결과를 돌려주는 방식"은 리서치 노트의 DZone 원문 "Without idempotency, a simple network timeout during a payment could result in the customer being charged twice when the request is retried"의 메커니즘과 정확히 일치.

**V-16. MTTA 정의**
- 서지/출처: PagerDuty, "Best Practices to Reduce MTTR." https://www.pagerduty.com/resources/incident-management-response/learn/best-practices-to-reduce-mttr/
- 확인 방법: 리서치 노트의 PagerDuty 출처와 대조.
- 본문 대비 정합성: 본문 "MTTA(Mean Time to Acknowledge)를 의식한다 — 문제를 인지하는 데 걸리는 시간이 전체 MTTR의 시작점이다"는 정확. "인지"는 한국어로 인지/확인(acknowledge) 모두를 포괄.

**V-17. Circuit Breaker 패턴 — Martin Fowler / Michael Nygard**
- 서지/출처: Martin Fowler, "CircuitBreaker." https://martinfowler.com/bliki/CircuitBreaker.html (2014) / Michael Nygard, *Release It!* (2007).
- 확인 방법: WebFetch로 Martin Fowler 페이지 원문 확인. "Michael Nygard popularized the Circuit Breaker pattern." / "many callers on a unresponsive supplier, then you can run out of critical resources leading to cascading failures across multiple systems."
- 본문 대비 정합성: 본문은 Circuit Breaker를 직접 인용하지 않고 방어 수단 목록에서 언급("circuit breaker"). 리서치 노트의 출처와 정확히 일치.

### 오류 교정 항목

**V-11. Ben Treynor Sloss 인용 misquotation — Google SRE Workbook [교정 완료]**
- 서지/출처: Google SRE Workbook, Postmortem Culture. https://sre.google/workbook/postmortem-culture/ — Ben Treynor Sloss, VP 24/7 Operations.
- 확인 방법: WebFetch로 SRE Workbook 페이지 원문 확인. 원문: "To our users, a postmortem without subsequent action is indistinguishable from no postmortem."
- 오류 내용: 초안·리서치 노트 모두 "To our users," 접두어 누락 + 비원문 "at all" 추가. 리서치 노트에 "(전문 truncated)"로 기록되어 있었으나 truncation이 아니라 변형이었음.
- 교정: 초안 blockquote 및 리서치 노트 인사이트 후보·근거 절의 인용 모두 원문으로 교정. "To our users,"는 주장을 사용자 관점으로 한정하는 중요한 수식어.

### 확인 불가 항목

없음.

### 익명화 확인

본문에 회사명, 서비스명, PG사명, 파트너사명, 특정 지표(실패율 %·응답 시간 ms), 날짜/시각 등 사건을 식별할 수 있는 정보 없음. "결제 서비스," "외부 연동 구간," "커넥션 풀" 등 일반 용어만 사용. 익명화 양호.
