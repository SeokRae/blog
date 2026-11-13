# 리서치: ASD-STE100을 AI 출력 문체 통제에 적용하기

- 글 목적(사용자 확정): 이해용 입문. STE100을 처음 보는 개발자가 "이게 무엇이고, AI가 쓰는 답변과 문서에 어떻게 적용하는지" 따라올 수 있게 쓴다. 비평 글이 아니다.
- 범위: AI 출력(답변, 문서)의 문체 통제. 프롬프트 자체를 STE로 쓰기, STE 준수 검사 도구는 범위 밖.
- 내부 근거: 있음. 작성자의 전역 지침 저장소와 flowcast 플러그인에 규칙 원문과 도입 경위가 남아 있습니다.
- 주의: 카파시 원문(X 게시물)은 직접 열지 못했습니다. 아래 "미해결 질문"을 꼭 보세요.

## 근거

### 내부: 규칙 원문

- (내부) 전역 지침의 STE 절 제목은 "쉬운 기술 문장 (ASD-STE100 80%)"이고, 첫 줄이 "공식 규격이 아니고, 어절 한도는 STE의 단어 수 한도를 옮겨 정한 값"이라고 스스로 밝힙니다. (출처: 전역 지침)
- (내부) 구조 규칙은 "항상 지킨다". 문장 하나에 내용 하나, 설명문 15어절, 절차문 12어절, 문단 6문장, 능동문과 주어, 조건 먼저, 명사 3개까지, 같은 대상은 같은 말, 기술 용어는 처음 한 번 풀이, 번호 목록과 글머리표, 경고는 지시 먼저. (출처: 전역 지침)
- (내부) 어휘 규칙은 한국어 번역투와 한자어 표현을 겨냥한 9행 표입니다. 예: "수행하다, 진행하다, 실시하다 → 하다, 또는 구체적인 동사", "~를 통해 → ~로", "및 → 와/과". (출처: 전역 지침)
- (내부) 강도는 둘입니다. 80%(기본)는 대화 응답, 설명 문서, 블로그, 이슈/PR 본문에 쓰고 구조 규칙만 강제합니다. 엄격은 절차서, 런북, 운영 지침, 경고문, 에러 메시지에 쓰고 어휘 규칙까지 강제합니다. (출처: 전역 지침)
- (내부) 전후 예문 하나가 지침에 박혀 있습니다. `결제 승인 요청 처리 결과 통보 지연 시 재시도가 수행됩니다.` → `승인 결과 통보가 늦으면, 시스템이 통보를 다시 보냅니다.` 명사 나열, 수동, 조건 위치가 한 문장에서 같이 고쳐지는 예입니다. (출처: 전역 지침)
- (내부) STE 절과 짝을 이루는 안전장치가 "설명 방식" 절에 있습니다. "읽는 사람이 되묻지 않고 한 가지로만 읽게 쓴다", "짧게 쓰기는 다시 쓰기이지 요약이 아니다", "짧고 단정한 문장은 틀린 내용도 그럴듯하게 보이게 한다". (출처: 전역 지침)

### 내부: 규칙의 원본과 영어판

- (내부) 한국어 규칙의 원본은 flowcast 플러그인의 `plain-ko.md`입니다. 목표를 한 줄로 적습니다. "읽는 사람이 되묻지 않고 한 가지로만 읽게 한다. 그래서 뜻이 여럿인 단어와 구조가 여럿으로 읽히는 문장을 없앤다." (출처: `flowcast/skills/explain/references/plain-ko.md:5`)
- (내부) `plain-ko.md`는 "STE는 영어만 정의한다"고 적고, 숫자 한도는 "이 스킬이 정한 값"이라고 밝힙니다. (출처: `plain-ko.md:3`)
- (내부) `plain-ko.md`의 규칙 10은 "사실, 조건, 범위 한정어를 지우지 않는다. 다시 쓰기이지 요약이 아니다."입니다. 전역 지침에서는 이 규칙이 STE 절이 아니라 "설명 방식" 절로 옮겨 갔습니다. (출처: `plain-ko.md:25`)
- (내부) 영어판 `plain-en.md`는 절차문 20단어, 설명문 25단어, 단순 시제, 구동사 금지, 관사 생략 금지 등 12개 구조 규칙을 둡니다. 어휘 예시는 commence → start, utilize → use, prior to → before, "close"는 동사로만 쓰고 형용사는 "near". (출처: `flowcast/skills/explain/references/plain-en.md:16-42`)
- (내부) `plain-en.md`는 공식 사전(승인 단어 약 900개)을 "ASD가 재배포를 막아서" 담지 않았다고 적고, 실제 준수가 필요하면 공식 규격을 받아 단어마다 대조하라고 합니다. (출처: `plain-en.md:3`, `flowcast/skills/explain/SKILL.md:45`)
- (내부) `plain-en.md`는 "Karpathy가 쓴 방식은 \"80% of the way to ASD-STE100\"이다. 기본 강도가 이것이다."라고 적습니다. 80%라는 강도 이름의 출처가 여기입니다. 단, 이 인용은 원문 대조를 거치지 않았습니다(미해결 질문 참고). (출처: `plain-en.md:5`)
- (내부) explain 스킬은 이 규칙을 "1단계 글"로 두고, 다이어그램 라벨, HTML 본문, 영상 내레이션에도 같은 규칙을 쓰라고 합니다. 끝나면 "바꾼 문장에서 사실, 조건, 범위 한정어가 빠지지 않았는지 원문과 대조"하라고 합니다. (출처: `flowcast/skills/explain/SKILL.md:25,30`)

### 내부: 도입 경위 (git log)

1. 2026-10-02: 카파시가 X에 글을 올렸다고 flowcast 이슈가 적습니다. "LLM 출력을 이해하기 쉽게 받는 형식을 4단계로 정리했습니다. 글(ASD-STE100), 다이어그램, HTML 페이지, 설명 영상 순서" (출처: flowcast GitHub Issue #152 본문, 링크 `https://x.com/karpathy/status/2105819303471976479`)
2. 2026-10-28: flowcast에 `explain` 스킬이 생기면서 `plain-ko.md`, `plain-en.md`가 처음 들어옵니다. 이슈는 "flowcast에는 2단계와 3단계가 이미 있습니다. 비어 있는 건 1단계의 한국어 규칙과 4단계 영상"이라고 동기를 적습니다. (출처: flowcast 커밋 `51f3b80`, Issue #152, PR #153, `flowcast/CHANGELOG.md:48`)
3. 2026-10-28 ~ 2026-11-11 사이: 규칙이 전역 지침 파일(당시 git 미추적 파일)에 들어갑니다. 정확한 날짜와 사유는 기록이 없습니다. 세션 기록에서도 찾지 못했습니다.
4. 2026-11-11 08:43: 전역 지침을 비공개 지침 저장소로 옮깁니다. 첫 커밋 본문에 "includes the ASD-STE100 80% plain technical writing rules"가 있고, STE 절에는 "원본은 `.../flowcast/skills/explain/references/plain-ko.md`이며, 한쪽을 고치면 다른 쪽도 맞춘다"는 문장이 있었습니다. (출처: 비공개 지침 저장소의 첫 커밋)
5. 2026-11-11 09:00: 위의 "원본은 plain-ko.md, 한쪽을 고치면 다른 쪽도 맞춘다" 문장을 지웁니다. 같은 커밋에서 sync 스크립트도 지우고 "the symlinked CLAUDE.md is the only surface"라고 적습니다. (출처: 비공개 지침 저장소의 다음 커밋)

- (내부) 요청받은 "언제, 왜"의 답: 저장소 기록으로 보이는 "왜"는 flowcast 쪽 이슈 #152(카파시 글의 1단계를 한국어로 채우기)까지입니다. 스킬 참고 파일에서 전역 지침으로 올린 이유는 커밋과 이슈 어디에도 적혀 있지 않습니다.

### 내부: 블로그 저장소의 연결 지점

- (내부) 블로그 CLAUDE.md는 포스트 문체를 "습니다체 기본, 해요체 최소"로 정합니다. 전역 STE 80%는 "블로그"를 적용 대상으로 명시하므로(전역 지침), 이 글 자체가 STE 80% 규칙으로 쓰이는 첫 사례가 될 수 있습니다. 확인 필요: 기존 발행 포스트 중 STE 규칙이 들어온 11월 이전 글은 이 규칙 없이 쓰였습니다. (출처: 블로그 저장소 `CLAUDE.md` "포스트 규칙" 절)
- (내부) 연결 후보 포스트 하나: flowcast 1편 「서비스는 움직이는데, 문서는 멈춰 있었다」. 시각 문서화(카파시 사다리의 2단계)를 다뤘습니다. 이전 글 인용은 이 한 곳 이하로 권합니다. (출처: `_posts/2026-07-15-flowcast-1-why-visual-docs.md`)
- (내부) 하네스(sr-blog-harness)에는 STE나 어절 한도 규칙이 없습니다. "어절"이 나오는 곳은 응집 점검 스크립트의 첫 어절 추출뿐입니다. (출처: `sr-blog-harness/scripts/cohesion_check.py:4-5`)

### 외부: ASD-STE100 공식 사실

- (외부, 1차) 관리 주체: ASD(Aerospace, Security and Defence Industries Association of Europe)의 "ASD Simplified Technical English Maintenance Group (STEMG)". 역할은 "responsible for the development, production, publication, and maintenance of ASD-STE100". 1983년에 처음 만들어졌고, "When ASD was formed in 2004, the group became the STEMG". (출처: https://www.asd-europe.org/standards-specifications/simplified-technical-english/ste-maintenance-group/)
- (외부, 1차) 최신판은 Issue 9입니다. ASD 발표문은 "555 dictionary entries update"를 적고, 무료 사본을 asd-ste100.org Downloads 페이지에서 요청하라고 안내합니다. 발표문 자체에는 발행 날짜가 없습니다. 같은 발표문은 그룹 이름을 "Management Group"으로 적어 다른 페이지("Maintenance Group")와 다릅니다. (출처: https://asd-europe.org/news-media/news-events/news/simplified-technical-english-asd-ste100-issue-9)
- (외부, 2차) Issue 9 발행은 2025년 1월이고, Issue 9부터 specification이 아니라 international standard가 되었다고 Wikipedia와 검색 요약이 적습니다. 다음 Issue 10은 2028년 1월 예정이라는 정보도 검색 요약에만 있습니다. (출처: https://en.wikipedia.org/wiki/Simplified_Technical_English, https://www.tcworld.info/news/asd-ste100-issue-9-setting-a-standard-for-technical-documentation 는 직접 열지 않음)
- (외부, 2차) 문장 길이 한도: 절차문 20단어, 설명문 25단어. 문단은 주제 하나, 6문장 이내. 승인 단어 약 900개. "One word, one part of speech, one meaning" 원칙. 모두 Wikipedia에 있으나 해당 문장에 각주가 없습니다. (출처: https://en.wikipedia.org/wiki/Simplified_Technical_English)
- (외부, 2차) 기원: 1980년대 AECMA가 유럽 항공사 요청으로 개발, 1985년 AECMA Simplified English Guide 발행, 2004년 ASD 출범 뒤 ASD-STE100으로 개명. Issue 6(2013)부터 무료. (출처: 같은 Wikipedia 문서, 이 부분도 각주 없음)
- (외부, 1차) ASD/STEMG의 AI 입장문(2026년 6월, STEMG와 산하 AI Task Team): AI 도구가 "can support STE-compliant writing and translation but cannot replace human oversight". 자동 준수 검사는 "varying levels of accuracy". "the standard takes priority, and AI adoption must support, not override, STE requirements". STEMG는 AI 도구를 만들지 않고 어느 도구도 보증하지 않습니다. (출처: https://www.asd-europe.org/news-media/publications/asd-position-papers/asd-ste100-simplified-technical-english-and-artificial-intelligence-ai/)
- (외부) asd-ste100.org 본 사이트와 FAQ는 403으로 열리지 않았습니다.

### 외부: 카파시 발언

- (외부, 2차) 여러 2차 글이 카파시의 X 게시물을 다룹니다. 공통 요지: LLM에게 ASD-STE100으로 설명하라고 요청해 효과를 봤고, 규격이 엄격해서 "80%" 정도로 요청한다. 이 제안은 다이어그램, HTML 페이지, 설명 영상과 함께 나온 네 가지 중 하나다. (출처: https://justbeingresourceful.com/2026/10/19/andrej-karpathys-4-rung-ladder-for-understanding-ai-output-asd-ste100-diagrams-html-video/ , https://themenonlab.blog/blog/asd-ste100-simplified-technical-english-prompting)
- (외부, 2차) justbeingresourceful 글도 "80% of the way to ASD-STE100"을 따옴표 없이 요약으로 씁니다. 원문 문구를 그대로 옮긴 2차 출처는 찾지 못했습니다.
- (외부, 2차) Menon Lab 글은 LinkedIn 등에서 퍼진 "카파시가 새 프롬프팅 기법을 발표했다"는 표현을 반박합니다. 요지가 "사람이 모델 출력을 어떻게 소비하느냐"였다는 해석입니다. 이 글의 적용 방향(출력 문체 통제)과 맞습니다. (출처: https://themenonlab.blog/blog/asd-ste100-simplified-technical-english-prompting)

## 인사이트 후보

- **STE의 목표는 "짧게"가 아니라 "한 가지로만 읽히게"다.** 문장 길이 한도는 수단이고, 목표는 오독을 없애는 것입니다. 항공 정비 매뉴얼에서 문장이 두 가지로 읽히면 정비사가 엉뚱한 동작을 합니다. AI 답변도 사람이 읽고 바로 행동하는 글이라 같은 압력이 걸립니다. (근거: `plain-ko.md:5`, 전역 지침, `plain-ko.md:20` "조건이 문장 끝에 붙으면 동작을 먼저 해 버린다")
- **"80%"는 타협이 아니라 역할 분담이다.** 구조 규칙은 모델이 문장마다 스스로 지킬 수 있습니다. 어휘 규칙을 엄격히 지키려면 약 900개 승인 사전과 단어별 대조가 필요한데, 사전은 재배포할 수 없고 모델이 대조를 보장하지도 못합니다. 그래서 구조는 항상, 어휘는 권고로 두고, 오독 비용이 큰 글(런북, 경고문, 에러 메시지)만 엄격으로 올렸습니다. (근거: `plain-en.md:3`, `SKILL.md:45`, 전역 지침, ASD AI 입장문의 "varying levels of accuracy")
- **한국어로 옮길 때 숫자가 아니라 원칙을 옮겼다.** STE는 영어만 정의합니다. 단어 수는 어절 수로 그대로 옮길 수 없어서 15어절, 12어절은 "이 저장소가 정한 값"으로 따로 정했습니다. 어휘 표도 영어판의 commence, utilize 대신 한국어 기술 문서의 번역투("수행하다", "~에 대한", "및")를 겨냥합니다. "가장 쉬운 말, 같은 뜻에는 같은 말"이라는 원칙은 같고 표적이 다릅니다. (근거: `plain-ko.md:3,29-41`, `plain-en.md:31-42`)
- **줄이는 규칙에는 안전장치가 따라붙어야 했다.** 짧게 쓰라는 규칙만 주면 모델은 조건과 범위 한정어를 지워 문장을 줄입니다. 그래서 "다시 쓰기이지 요약이 아니다", "짧고 단정한 문장은 틀린 내용도 그럴듯하게 보이게 한다"가 STE 절 바깥, 설명 방식 절에 함께 들어갔습니다. explain 스킬도 끝 단계에서 원문 대조를 요구합니다. (근거: 전역 지침, `plain-ko.md:25`, `SKILL.md:30`)
- **스킬에서 전역 지침으로 올라가며 성격이 바뀌었다.** 처음에는 사용자가 "STE로 설명해줘"라고 부를 때만 쓰는 스킬 참고 파일이었습니다. 전역 지침에 들어가면서 모든 대화 응답과 문서의 기본 문체가 되었습니다. 이때 두 파일을 맞추라는 문장을 지웠고, 지금 두 파일은 이미 조금 다릅니다(전역에는 "기술 용어는 처음 한 번 풀이" 규칙이 있고 `plain-ko.md`에는 없음, 규칙 10은 전역에서 다른 절로 이동). (근거: 커밋 `51f3b80`, 비공개 지침 저장소의 커밋 두 개, 전역 지침)
- **카파시의 요지는 프롬프트 기법이 아니라 출력을 읽는 비용이다.** 2차 출처들과 flowcast 스킬 머리말이 같은 방향으로 읽습니다. "LLM이 일을 더 많이 맡을수록 사람의 일은 감독과 이해로 올라간다. 그래서 출력을 이해하는 비용을 줄이는 형식을 고른다." 단, 원문 직접 확인은 못 했습니다. (근거: `SKILL.md:9`, Menon Lab 글)
- **다시 한다면 바꿀 것 (후보, 작성자 확인 필요):** 15/12어절을 정한 근거가 어디에도 기록되지 않았습니다. 이 블로그의 결론 중 하나인 "'왜'를 기록할 때 검증 가능한 사실은 그 자리에서 검증하라"와 대비되는 지점이라 writer가 작성자에게 물을 만합니다.

## 소주제 이름 후보

- **항공 정비 매뉴얼의 규칙** : STE가 무엇인지(ASD, STEMG, Issue 9, 20/25단어, 단어 하나 뜻 하나), 목표가 "한 가지로만 읽히게"라는 점
- **80%라는 강도** : 구조 규칙은 항상, 어휘 규칙은 권고로 나눈 이유, 엄격으로 올리는 글의 종류, 카파시 발언과의 연결
- **한국어로 옮기기** : 단어 수 대신 어절 수, 영어 어휘 표 대신 한국어 번역투 표, 전후 예문
- **줄이지 말고 다시 쓰기** : 사실과 한정어 보존 안전장치, 짧은 단정문의 위험, 원문 대조

확정 (2026-11-13, 사용자): 네 개 모두 독립 소제목으로 쓴다. "줄이지 말고 다시 쓰기"를 접지 않는다.

메모: 네 개가 한도입니다. 입문 글로 가볍게 가려면 "줄이지 말고 다시 쓰기"를 "80%라는 강도"나 "한국어로 옮기기"의 끝 문단으로 접어 셋으로 줄일 수 있습니다. "스킬에서 전역 지침으로" 경위는 소주제가 아니라 도입부 줄거리(사건 둘: 카파시 글을 보고 스킬을 만든 일, 그 규칙을 전역 기본값으로 올린 일)로 쓰기를 권합니다.

## 미해결 질문

- **카파시 원문 미확인.** X 게시물(`https://x.com/karpathy/status/2105819303471976479`)은 402로 열리지 않았고, 다른 경로 조회는 권한 거부로 시도하지 않았습니다. 날짜(2026-10-02), "80% of the way to ASD-STE100" 문구, 4단계 사다리 구성은 flowcast 이슈 #152와 2차 블로그에만 근거합니다. writer는 직접 인용을 쓰지 말고 "카파시가 X에서 ~라고 소개했다"는 요약에 `(확인 필요)`를 붙이세요. verifier가 원문을 확인해야 합니다.
- **문장 길이 20/25단어, 문단 6문장, 승인 단어 약 900개.** 공식 사이트(asd-ste100.org)가 403이라 1차 출처로 확인하지 못했습니다. Wikipedia는 각주 없이 적습니다. verifier가 공식 규격 PDF(무료 요청)나 ASD 페이지로 확인해야 합니다.
- **Issue 9 발행일(2025년 1월)과 "specification에서 standard로" 전환.** 2차 출처만 있습니다. ASD 발표문에는 날짜가 없습니다.
- **그룹 이름 표기.** ASD 페이지마다 "Maintenance Group"과 "Management Group"이 갈립니다. 본문에는 STEMG 공식 페이지 표기인 "Maintenance Group"을 권합니다.
- **ASD의 재배포 제한.** `plain-en.md:3`은 "ASD가 재배포를 막는다"고 적지만, 외부에서 확인한 것은 "copyright and trademark of ASD, All rights reserved"(Wikipedia 참고문헌)까지입니다. 본문에서 "재배포 금지"를 단정하지 말고 "저작권이 ASD에 있고 사본은 공식 경로로 무료 요청한다" 수준으로 쓰기를 권합니다.
- **15어절, 12어절을 정한 근거.** 커밋, 이슈, 세션 기록에 없습니다. 작성자에게 물어야 합니다. 답이 없으면 "영어 한도를 어절로 옮겨 이 저장소가 정한 값"이라는 지침 원문 표현까지만 씁니다.
- **전역 지침에 언제, 왜 넣었는지.** 2026-10-28과 2026-11-11 사이 미추적 파일 시절에 들어갔습니다. 작성자의 기억으로만 채울 수 있습니다.
- **LLM 출력에 STE를 적용한 연구.** 1차 연구를 찾지 못했습니다. 한 2차 블로그가 "완전 준수 요청 시 코드 관련 사실 46.8% 손실, 느슨한 요청 시 8.5%"라는 수치를 소개했다고 검색 요약에 나오지만 원 출처를 찾지 못했습니다. 본문에 싣지 않기를 권합니다. ASD AI 입장문(1차)은 AI 보조의 한계를 말하지만 측정 결과는 없습니다.
- **효과 측정 없음.** 작성자 쪽에도 STE 규칙 적용 전후를 비교한 기록은 없습니다. 효과는 "이렇게 바뀐다"는 전후 예문으로만 보여 줄 수 있고, "얼마나 나아졌다"는 주장은 근거가 없습니다.

## 검증 기록

검증일 2026-11-13, blog-verifier. 대상 `_drafts/ste100-for-ai-output.md`. 줄 번호는 검증 전 초안 기준입니다.

### 외부 인용

- **V-1 카파시 X 게시물 (10줄, 32줄): 확인 불가.**
  - 서지/출처: Andrej Karpathy, X 게시물 `https://x.com/karpathy/status/2105819303471976479`. 2차: Search Engine Journal `https://searchenginejournal.com/karpathy-llm-aircraft-manual-writing/591813`, explainx.ai `https://explainx.ai/blog/karpathy-understand-llm-outputs-ste100-diagrams-html-video-2026`, justbeingresourceful `https://justbeingresourceful.com/2026/10/19/andrej-karpathys-4-rung-ladder-for-understanding-ai-output-asd-ste100-diagrams-html-video/`, flowcast Issue #152.
  - 확인 방법: X 원문은 리서치 단계에서 402. 이번 검증에서 공개 임베드 API 조회를 시도했으나 권한 분류기가 차단해 더 우회하지 않았습니다. 웹 검색(2026-11-13)에서도 원문 텍스트는 나오지 않았습니다. 검색 요약은 2차 글이 "80% of the way to ASD-STE100"을 전하고, 한 해설 글이 날짜를 2026-10-02로 적는다고 보여 줍니다. SEJ는 "목요일"이라고 적는데, 2026-10-02는 금요일이라 날짜가 서로 맞지 않습니다(검색 요약 기준, 페이지 직접 대조는 못 함).
  - 추가 대조 (main이 전달한 web-fetch 결과, 모두 2차): SEJ(2026-10-02 기사)는 X 원문에 링크하고 "80% of the way to ASD-STE100", "heavy constraints on clean writing style", "a lot more readable"을 따옴표로 인용합니다. 게시일은 "Thursday"라고만 씁니다. explainx(2026-10-02)는 여러 문장을 직접 인용하지만 원문 링크가 없고, 날짜를 "October 2, 2026"으로 씁니다. JBR(2026-10-19)은 원문에 링크하지만 직접 인용이 없고, 날짜를 October 2, 2026으로 씁니다. 세 곳 모두 4단계 사다리(글/STE100, 다이어그램, HTML, 영상)를 적습니다. 2026-10-02는 금요일이라 SEJ의 "Thursday"와 맞지 않습니다. 원문이 없어서 날짜를 판별할 수 없습니다. 본문에 날짜를 넣게 되면 "2026년 10월 초"처럼 단정하지 않는 표현을 씁니다.
  - 정합성: 본문은 "소개했다고 합니다", "전해졌습니다"로 전언 처리했고 날짜와 직접 인용을 싣지 않았습니다. 10줄의 "80% 정도"는 영어 원문을 직접 옮긴 인용이 아니라 한국어로 요약한 말에 따옴표를 붙인 것입니다. 2차 출처가 공통으로 전하는 "80%"와 범위가 맞습니다. 근거 범위와 맞습니다. 32줄 "80%라는 강도는 카파시의 표현에서 이름을 빌렸습니다"는 작성자 쪽 명명 경위이고, `flowcast/skills/explain/references/plain-en.md:5`와 맞습니다.
- **V-2 STE의 기원, 항공 정비 매뉴얼 (18줄): 2차 근거만 있음 (플래그 없던 주장).**
  - 서지/출처: Wikipedia "Simplified Technical English" `https://en.wikipedia.org/wiki/Simplified_Technical_English`(각주 없음: 1980년대 AECMA가 유럽 항공사 요청으로 개발, 1985년 AECMA Simplified English Guide). ASD 1차 페이지 문구는 "especially in aerospace and defence, but not only."입니다.
  - 확인 방법: main이 전달한 web-fetch 결과(ASD STEMG, position paper 페이지)와 리서치 노트를 대조했습니다.
  - 정합성: 1차 출처는 적용 분야까지만 말하고, 정비 매뉴얼용으로 만들었다는 기원은 말하지 않습니다. 본문 진술은 2차 근거로만 받쳐집니다. 문장은 고치지 않고 초안에 주석을 남겼습니다.
- **V-3 STEMG 연혁과 이름 (18줄, 20줄): 확정.**
  - 서지/출처: ASD, "STE Maintenance Group", `https://www.asd-europe.org/standards-specifications/simplified-technical-english/ste-maintenance-group/`. 원문 "Originally formed in 1983", "When ASD was formed in 2004, the group became the STEMG".
  - 확인 방법: main이 전달한 web-fetch 결과.
  - 정합성: "1983년에 만든 작업 그룹", "2004년 ASD가 출범하면서 지금 이름"은 원문과 정확히 맞습니다. 그룹 이름은 이 페이지 표기인 "Maintenance Group"을 따랐습니다. 미해결 질문의 표기 항목도 이것으로 해소됩니다.
- **V-4 Issue 9 발행일 2025년 1월 (20줄): 확인 불가.**
  - 서지/출처: ASD 발표문 `https://asd-europe.org/news-media/news-events/news/simplified-technical-english-asd-ste100-issue-9`(날짜 없음). 2차: Wikipedia. 검색 요약은 asd-ste100.org 홈이 "Issue 9 - January 15, 2025"로 적는다고 합니다.
  - 확인 방법: asd-ste100.org의 index, about_STE, STE_faq, STE_downloads 네 페이지가 모두 403이었습니다(main 전달 결과). 검색 요약은 1차 확인이 아니라서 확정 근거로 쓰지 않았습니다.
  - 정합성: 본문은 "나왔다고 알려져 있습니다"로 전언 처리해 근거 범위와 맞습니다. "Issue 9이 최신판"은 ASD 발표문(1차)으로 받쳐집니다.
- **V-5 저작권과 무료 사본 (20줄): 일부 확정.**
  - 서지/출처: 무료 사본은 위 ASD Issue 9 발표문(1차, 리서치 단계 확인)이 asd-ste100.org Downloads 페이지에서 요청하라고 안내합니다. 저작권은 Wikipedia 참고문헌의 "copyright and trademark of ASD, All rights reserved"(2차)입니다.
  - 확인 방법: 리서치 노트 대조. 이번 web-fetch에서는 두 사실 모두 찾지 못했습니다(Downloads 페이지 403).
  - 정합성: 본문은 "재배포 금지"를 단정하지 않고 "저작권은 ASD에 있다" 수준으로 썼습니다. 미해결 질문의 권고와 맞습니다. 저작권 귀속은 2차 근거만 있습니다.
- **V-6 20/25단어, 6문장, 약 900개, 단어 하나에 품사 하나 뜻 하나 (22줄): 확인 불가.**
  - 서지/출처: Wikipedia(각주 없음), `flowcast/skills/explain/references/plain-en.md:3,16,18,42`(작성자 쪽 파일이라 1차가 아님).
  - 확인 방법: asd-ste100.org 403, ASD 유럽 페이지에는 수치가 없었습니다. 웹 검색은 관련 결과를 내지 않았습니다.
  - 정합성: 본문은 이 수치를 단정형으로 씁니다. 근거는 2차뿐이므로, 발행 전에 공식 규격 PDF(무료 요청)로 대조하거나 사용자가 판단해야 합니다.
- **V-7 ASD AI 입장문 (36줄): 오류 교정 1건, 나머지 확정.**
  - 서지/출처: ASD STEMG와 AI Task Team(AITT), "ASD-STE100 Simplified Technical English and Artificial Intelligence (AI)" 백서, June 2026, `https://www.asd-europe.org/news-media/publications/asd-position-papers/asd-ste100-simplified-technical-english-and-artificial-intelligence-ai/`. 원문 "For the STE community, AI tools can support STE-compliant writing and translation but cannot replace human oversight.", "automated checks for STE compliance, but currently with varying levels of accuracy."
  - 확인 방법: main이 전달한 web-fetch 결과.
  - 정합성: "2026년 6월"과 "varying levels of accuracy"는 정확합니다. 초안은 "STE 준수 글쓰기를"이라고 써서 원문의 "and translation"을 뺐고, 그래서 원문보다 범위가 좁았습니다. 이를 "STE 준수 글쓰기와 번역을"으로 고쳤습니다. 원문 주체는 STEMG와 AITT 공동입니다. AITT가 STEMG 산하라서 본문의 "STEMG는"은 허용 범위로 봤습니다.

### 내부 인용 (작성자 저장소)

- **V-8 목표 인용 (26줄): 확정.** 출처는 `flowcast/skills/explain/references/plain-ko.md:5`입니다. 파일을 직접 읽어 한 글자씩 대조했고, 정확히 맞습니다.
- **V-9 "조건이 문장 끝에 붙으면 동작부터" (28줄): 확정.** 출처는 `plain-ko.md:20` "조건이 문장 끝에 붙으면 동작을 먼저 해 버린다"입니다. 본문은 이를 풀어 쓴 것이고 직접 인용이 아닙니다. 정확합니다.
- **V-10 강도 표 (40-43줄): 확정.** 출처는 전역 지침입니다. 쓰는 글 목록과 지키는 규칙이 원문과 맞습니다.
- **V-11 지침 머리말 인용 (51줄): 확정.** 출처는 전역 지침이고, 정확히 맞습니다.
- **V-12 15어절/12어절과 그 근거 (53줄, 95줄): 수치는 확정, 근거는 확인 불가.** 수치는 전역 지침, `plain-ko.md:17`과 맞습니다. 이 수치를 고른 근거는 flowcast 커밋 `51f3b80`, Issue #152, 비공개 지침 저장소의 커밋 기록에 없습니다. 기록에는 "STE의 단어 수 한도를 옮겨 정한 값"(전역 지침, `plain-ko.md:3`)까지만 있습니다. 95줄의 "그 문장만 남아 있다"는 진술은 이 기록과 맞습니다. 근거를 채우려면 작성자 답변이 필요합니다.
- **V-13 어휘 표와 영어판 예 (55-62줄): 확정.** 한국어 표 4행은 전역 지침과 정확히 맞습니다. commence → start, utilize → use는 `plain-en.md:33,35`와 맞습니다. 본문의 "영어판"은 플러그인 영어판 규칙을 가리키는 것으로 읽었습니다.
- **V-14 전후 예문과 분석 (68-73줄): 확정.** 출처는 전역 지침이고, 정확히 맞습니다. "결제 승인 요청 처리 결과 통보"는 명사 6개이고, "승인 결과 통보"는 명사 3개입니다. 직접 세어 맞다고 확인했습니다.
- **V-15 적용 전후 측정 (75줄): 확인 불가 (체감 서술 부분).** "측정하지 않았다"는 진술은 리서치 노트의 미해결 질문 "효과 측정 없음"과 맞습니다. 체감 차이를 더 쓰려면 작성자 답변이 필요합니다.
- **V-16 설명 방식 절 두 인용과 시점 (81-85줄): 확정.** 인용은 전역 지침과 정확히 맞습니다. "STE 규칙을 넣을 때 함께 두었다"는 진술은 비공개 지침 저장소의 첫 커밋으로 확인했습니다. 첫 추적 커밋에 STE 절과 두 문장이 이미 같이 있습니다. 그 전 미추적 기간의 순서는 판별할 수 없습니다.
- **V-17 설명 스킬의 원문 대조 (89줄): 확정.** 출처는 `flowcast/skills/explain/SKILL.md:30`이고, 맞습니다.
- **V-18 도입 경위 (12줄): 확정.** 스킬은 2026-10-28에 생겼습니다(커밋 `51f3b80`). 전역 지침은 2026-11-11 추적 시작 시점에 STE 절을 이미 갖고 있습니다(비공개 지침 저장소의 첫 커밋). 그러니 "얼마 뒤 기본 문체로 올렸다"는 순서가 맞습니다. 정확한 날짜는 미해결 질문대로 남습니다.

### 미해결 질문 처리

- 카파시 원문 미확인: 미해소. V-1. → 3회차에서 해소(V-23).
- 20/25단어, 6문장, 약 900개: 미해소. V-6. → 3회차에서 해소(V-27). 6문장 한도는 설명문 범위로 교정했습니다.
- Issue 9 발행일과 specification에서 standard로의 전환: 미해소. V-4. 본문은 전환을 다루지 않습니다. → 발행일은 3회차에서 해소(V-25). 전환은 여전히 확인하지 않았고, 본문에도 없습니다.
- 그룹 이름 표기: 해소. V-3.
- ASD의 재배포 제한: 본문이 단정하지 않으므로 해당 없음. 저작권은 V-5. → 3회차에서 1차 원문에 맞춰 "지식재산권"으로 교정(V-26).
- 15어절, 12어절의 근거: 미해소. 작성자 답변이 필요합니다(V-12).
- 전역 지침에 넣은 시점과 이유: 미해소. 본문은 "얼마 뒤"로만 씁니다(V-18).
- LLM 출력에 STE를 적용한 연구와 46.8% 수치: 본문에 없으므로 해당 없음.
- 효과 측정 없음: 본문이 그대로 진술합니다(V-15).

### 사용자 결정 (2026-11-13, main 경유)

- V-6 (22줄), V-2 (18줄): 사용자가 공식 규격 PDF를 받아 직접 대조합니다. 결과가 올 때까지 확인 불가로 둡니다. **결과가 오기 전에는 발행하지 않습니다.**
- V-12 (53줄, 95줄): 본문을 그대로 둡니다. "근거가 기록에 없다"는 사실을 교훈으로 쓰는 지금 서술을 유지합니다.
- V-15 (75줄): 본문을 그대로 둡니다. 체감 서술은 더하지 않습니다.

### 리드 판단 뒤 사용자 확인 (2026-11-13)

- V-1 (10줄), V-4 (20줄): 사용자가 전언형 유지를 철회했습니다(2026-11-13). 용어를 설명하는 입문 글에서 전언형은 확인한 사실이 아니라 추정으로 읽히기 때문입니다. 1차 출처로 확인해 단정형으로 쓰거나, 확인할 수 없으면 본문에서 뺍니다. 처리 방식은 미정입니다.

### 근거 사슬 1회차 (2026-11-13, main 요청)

- **V-19 "고친 문장에 '결제', '요청', '처리' 세 단어가 없었습니다" (99줄): 확정.**
  - 서지/출처: 전역 지침와 `flowcast/skills/explain/references/plain-ko.md:48`(예 표 둘째 행).
  - 확인 방법: 두 파일을 직접 읽어 전후 문장을 단어별로 대조했습니다. 전 "결제 승인 요청 처리 결과 통보 지연 시 재시도가 수행됩니다." 후 "승인 결과 통보가 늦으면, 시스템이 통보를 다시 보냅니다." 명사 여섯 개 가운데 "결제", "요청", "처리"는 후 문장에 없고, "승인", "결과", "통보"만 남았습니다. "지연 시"는 "늦으면"으로, "재시도가 수행됩니다"는 "다시 보냅니다"로 바꿔 쓴 것이라 빠진 단어로 세지 않았습니다.
  - 정합성: 본문 진술은 정확합니다. 빠진 단어가 정확히 그 셋입니다. 두 파일의 이 예문은 한 글자도 다르지 않습니다. 차이는 하나뿐입니다. `plain-ko.md`의 예 표에는 첫 행(유압 저장소 예문, 47줄)이 더 있고, 전역 지침에는 이 예문이 없습니다. 본문이 말하는 "지침 예문"은 두 파일에 공통인 결제 예문이라 이 차이는 진술에 영향을 주지 않습니다.
- **V-20 나누기 예문 (89-97줄): 확인 완료, 고유 이름 없음.**
  - 확인 방법: 89-97줄의 코드 블록과 앞뒤 문장을 읽었습니다. 등장하는 이름은 "캐시 서버", "원본 서버", "관리자", "강제 갱신"뿐입니다. 모두 일반 명사이고 실제 서비스명이나 내부 클래스, 필드, 키 이름은 없습니다. 본문도 "이 글을 위해 직접 만든 예"라고 밝힙니다.
  - 덧붙임 (요청 밖, 사실 대조만 함): 97줄의 "조건 셋(만료, 3초 초과, 강제 갱신)과 수치 둘(3초, 10분)이 모두 남았다"와 "문장마다 주어가 '캐시 서버'"를 전후 문장과 대조했습니다. 두 진술 모두 맞습니다.

### 근거 사슬 2회차 (2026-11-13, main 요청)

- **V-21 "설명 스킬에는 원문과 대조하는 단계가 있고, 전역 지침에는 규칙 문장만 있고 대조 단계는 없다" (109줄): 확정.**
  - 서지/출처: `flowcast/skills/explain/SKILL.md:30`. 원문은 "4. **확인한다.** 1단계는 바꾼 문장에서 사실, 조건, 범위 한정어가 빠지지 않았는지 원문과 대조한다."입니다. 비교한 곳은 전역 지침 전체입니다.
  - 확인 방법: 전역 지침에서 "대조, 확인, 원문, 검증, 빠지지, 지우지, 점검, 다시 읽, 비교, 맞춰, 전후, 되짚, 검토"를 grep으로 찾고, 걸린 줄을 하나씩 읽었습니다.
    - 전역 지침: "짧게 쓰려고 사실, 조건, 범위 한정어를 지우지 않는다." 금지 규칙일 뿐, 고친 뒤에 확인하는 단계가 아닙니다.
    - 전역 지침: "확인하지 않은 내용은 … 확인하지 않았다고 밝힌다." 미확인 사실을 밝히라는 규칙이지, 원문과 대조하는 단계가 아닙니다.
    - 전역 지침: 원인 확인, 상대 발언, 대외 문안, 메일 확인 요청에 관한 줄입니다. 문장을 고친 뒤의 대조와 관계없습니다.
    - 전역 지침의 "전후 차이를 짧게 보인다"는 가장 가까운 표현입니다. 하지만 "빠르게" 조건이 붙은 문서를 정리할 때 바뀐 점을 사용자에게 보여 주라는 규칙입니다. 사실과 조건이 빠졌는지 원문과 대조하라는 요구가 아닙니다.
    - 전역 지침(기존 문서 수정 시 적용 범위)도 대조 단계가 아닙니다.
  - 정합성: 본문 진술은 정확합니다. 다른 표현으로 된 대조 단계도 전역 지침에는 없습니다.
- **V-22 이어지는 함의 문장 (109줄 뒷부분): 범위 안.**
  - "이 규칙이 모든 답변과 문서의 기본 문체가 되었는데": 적용 범위는 전역 지침 "대화 응답, 문서, 블로그, 이슈/PR 본문 등 모든 한글 산문"이고, 영어 기술 문서도 80%를 따릅니다(전역 지침). 전역 지침의 예외(코드, 로그 등)는 "답변과 문서"라는 표현을 흔들지 않습니다.
  - "그 답변에는 대조를 요구하지 않는 셈입니다": V-21의 사실에서 바로 나오는 결론이고, "셈"으로 추론임을 밝힙니다. 범위는 전역 지침이 요구하는 것에 한정되어 있습니다. 다른 층(예: 블로그 하네스의 verifier와 editor)에 대조 장치가 있다는 사실과도 충돌하지 않습니다.
  - "다음에 고칠 곳은 이 대조 단계를 전역 지침에도 넣는 일입니다": 작성자의 계획이고 사실 주장이 아닙니다. 검증 대상이 아닙니다.

### 근거 사슬 3회차 (2026-11-13, main 요청, 1차 출처 확보)

공통 확인 방법: 아래 1차 출처는 main이 사용자 지시로 Chrome에서 직접 열고, 원문 문구를 verifier에게 전달했습니다. verifier는 이 페이지들을 다시 열지 않았습니다. asd-ste100.org는 verifier 쪽 web-fetch로는 403입니다. 판정은 전달받은 원문 문구와 본문을 대조한 결과입니다. 이 회차의 판정은 V-1, V-2, V-4, V-5, V-6의 이전 판정을 대체합니다.

- **V-23 카파시 X 게시물 (10줄): 확정, 문장 교정 (V-1 대체).**
  - 서지/출처: Andrej Karpathy, X 게시물, `https://x.com/karpathy/status/2105819303471976479`. 표시 시각 "오전 9:37 · 2026년 10월 2일"은 브라우저 현지 시각(KST로 추정)입니다. 원문 "Ask your LLM to explain something in ASD-STE100, it's a controlled language specification originally developed for aerospace maintenance documentation. LLMs well-versed in this language and it comes with heavy constraints on clean writing style that I often find a lot more readable. Sometimes I've tried to soften it a bit e.g. ask for "80% of the way to ASD-STE100" because the spec is quite stringent." 이어서 Diagrams, Web pages("in HTML"), Explainer videos가 순서대로 나옵니다.
  - 정합성: "소개했다고 합니다"와 "전해졌습니다"를 단정형("소개했습니다", "덧붙였습니다")으로 바꿨습니다. 원문의 "Sometimes"는 "가끔은"으로 살렸습니다. 초안은 이 말을 빠뜨려 늘 80%로 요청하는 것처럼 읽혔습니다. "규격이 엄격해서"는 "because the spec is quite stringent"와 맞습니다. 본문에 날짜는 넣지 않았습니다. KST 10월 2일 오전 9:37은 미국 시각으로 10월 1일(목요일)이라 SEJ의 "Thursday"와 맞을 수 있습니다. 하지만 현지 시각이 KST라는 것은 추정이므로, 날짜를 넣게 되면 "2026년 10월 초"로 씁니다. 32줄 "카파시의 표현에서 이름을 빌렸습니다"도 원문 "80% of the way to ASD-STE100"로 받쳐집니다. 시제 보정(editor 지적): 원문 "Sometimes I've tried to soften it"은 습관이 아니라 시도해 본 경험입니다. 그래서 "요청한다는 말도"를 "요청해 보기도 했다는 말도"로 고쳤습니다. 10줄 앞머리 "이 비용을 줄이는 방법으로"는 작성자의 연결 문구입니다. 원문이 LLM 출력을 읽기 쉽게 만드는 형식들을 나열하는 글이라 범위 안으로 봤습니다.
- **V-24 STE의 기원 (18줄): 오류 교정 (V-2 대체).**
  - 서지/출처: ASD STEMG, "About ASD-STE100", `https://asd-ste100.org/about_STE.html`. 원문 "a controlled natural language developed in the late 1970s (originally as AECMA Simplified English) to help the users of English-language maintenance documentation understand what they read. It was initially applicable to commercial aviation and later became a requirement for defense projects", "STE was first released in 1986 as AECMA Document, PSC-85-16598."
  - 정합성: 초안 "항공 정비 매뉴얼을 쓰려고 만들어졌습니다"는 원문 목적과 어긋납니다. 원문의 목적은 정비 문서를 읽는 사람의 이해입니다. 그래서 "영어로 된 항공 정비 문서를 읽는 사람이 내용을 이해하도록 돕기 위해 만들어졌습니다"로 고쳤습니다. "항공"은 "initially applicable to commercial aviation"과 맞습니다. 소제목과 도입부의 소주제 이름 "항공 정비 매뉴얼의 규칙"은 고치지 않았습니다. "정비 문서에서 출발한 규칙"이라는 뜻으로 원문 범위 안에 있습니다. 1970년대 후반 개발과 1986년 첫 발행은 본문에 넣지 않았습니다. 20줄 "STEMG의 뿌리는 1983년" 진술과도 충돌하지 않습니다. 언어의 개발 시점과 관리 그룹의 결성 시점은 서로 다른 사실입니다.
- **V-25 Issue 9 발행일 (20줄): 확정, 단정형으로 교정 (V-4 대체).**
  - 서지/출처: `https://asd-ste100.org/about_STE.html` "The current version of ASD-STE100 is Issue 9, January 2025.", "The release of Issue 9 ... on January 15, 2025". Zenodo 공식 레코드 DOI 10.5281/zenodo.23666005, `https://zenodo.org/records/23666006`, "Published January 15, 2025", "Issued 2025-01-15".
  - 정합성: "나왔다고 알려져 있습니다"를 "나왔습니다"로 바꿨습니다. "최신판은 Issue 9"도 1차로 확정됩니다.
- **V-26 지식재산권과 무료 사본 (20줄): 교정 (V-5 대체).**
  - 서지/출처: 위 Zenodo 레코드 Notes "ASD-STE100 Simplified Technical English is the intellectual property of ... ASD", EU Trade Mark No. 017966390. 무료 사본 요청은 ASD Issue 9 발표문 `https://asd-europe.org/news-media/news-events/news/simplified-technical-english-asd-ste100-issue-9`(1차, 리서치 단계 확인)에 있습니다.
  - 정합성: 1차 원문은 "copyright"가 아니라 "intellectual property"라고 씁니다. 그래서 "저작권"을 "지식재산권"으로 맞췄습니다. "copyright"라는 말은 2차(Wikipedia 참고문헌)에만 있습니다. 상표 등록은 본문에 넣지 않았습니다.
- **V-27 수치와 어휘 원칙 (22줄): 확정 3건, 범위 교정 2건 (V-6 대체).**
  - 서지/출처: ASD-STE100 Issue 9 PDF(Zenodo 레코드 23666006, main이 브라우저 미리보기에서 텍스트 추출, 파일 저장 안 함). p.87 Part 1 Section 5 Procedural writing "Use a maximum of 20 words in each sentence", "In STE, the maximum length of a sentence for procedures is 20 words". p.98 Section 6 Descriptive writing "Use a maximum of 25 words in each sentence", "In descriptive writing, the maximum sentence length is 25 words". p.101 Rule 6.6 "Make sure that no paragraph has more than six sentences." `https://asd-ste100.org/about_STE.html` "The dictionary contains the approved words that a writer can use (approximately 900 words, each with one meaning and one part of speech).", "In general, each word has only one meaning and is approved with only one part of speech."
  - 정합성:
    - 절차문 20단어: 확정. p.88과 p.91에 따르면 절차문 안의 note는 최대 25단어입니다. 하지만 note는 지시 문장과 다른 요소입니다. 본문의 "절차문을 20단어"는 지시 문장의 한도로 읽히므로 틀리지 않습니다. 고치지 않았습니다.
    - 설명문 25단어: 확정.
    - 약 900개: 확정.
    - 6문장 한도: 범위 교정. Rule 6.6은 Section 6 Descriptive writing에 있습니다. 초안 "문단 하나를 6문장 이내로"는 절차문까지 포함하는 것처럼 읽혀, "설명문의 문단 하나를"로 범위를 맞췄습니다. 단, Section 5(절차문)에 따로 문단 한도가 있는지는 전달받은 범위 밖이라 확인하지 않았습니다. 교정 결과는 근거보다 좁게 말할 수는 있어도 넓게 말하지는 않습니다.
    - 단어 하나에 품사 하나, 뜻 하나: 범위 교정. 원문의 "In general"을 살려 "원칙적으로"를 넣었습니다. 사전 설명 문장("each with one meaning and one part of speech")만 보면 예외가 없는 것처럼 읽힙니다. 하지만 원칙 문장이 "In general"로 한정하므로, 한정어를 지우지 않았습니다.
  - 참고: 플러그인 `plain-en.md:18`과 전역 지침(문단 6문장)은 이 한도를 모든 문단에 적용합니다. 이는 작성자의 규칙이 공식 규격보다 넓게 정한 것입니다. 본문 47줄 이하의 "한국어로 옮기기"가 다루는 작성자 규칙이므로 여기서는 고치지 않았습니다.

## 응집 점검 기록
- 예고 사슬: 이름 {항공 정비 매뉴얼의 규칙 | 80%라는 강도 | 한국어로 옮기기 | 줄이지 말고 다시 쓰기} → 도입부 L14와 소제목 전부 일치. "정리하며"는 작성자 노트대로 예고 밖 맺음 절이라 유지
- 손본 곳: L66 "박아 둔" → "넣어 둔"(구어체 비유) / L81 "두 문장을" → "두 항목을"(인용 블록이 3문장, 2문장이라 "두 문장"이 개수로 오독됨)
- 손대지 않기로 한 곳: L10, L18, L20, L22, L53, L75, L95 긴 문단 플래그는 검증 주석 때문. 본문 문장은 2~4개라 유지
- 손대지 않기로 한 곳: L93 6문장. 우산("나머지 결정이 따라왔습니다") 뒤 세 결정 나열이고 각 결정이 본문 세 소주제와 짝이라 유지
- 손대지 않기로 한 곳: L28 "두 가지로 읽으면"은 개수 라벨이 아니라 오독의 내용이라 유지
- 손대지 않기로 한 곳: L53 "먼저", L55 "다음으로"는 절 안의 두 결정을 잇는 연결어라 번호 라벨로 보지 않음
- 우산 확인: L22, L73, L93의 세 항목 이상 나열은 모두 우산 문장이 있음. writer 되돌림 없음
- 사람 결정 대기: L87 "명사를 지운 것이 아니라 풀어 썼다", "정보는 줄지 않았다"가 L69-70 예문(결제, 요청, 처리가 빠짐, 문장은 나뉘지 않음)과 어긋나 보임. 편집자 노트로 남김
- 사용자 결정 1회차 재점검(L87-101, writer 수정분): L87 연쇄로 나누기 예문 도입 → L97 우산("빠진 것은 없습니다") 뒤 조건, 수치, 예외, 주어 나열 → L99 연쇄로 지침 예문의 세 단어 누락에서 대조 단계 필요로 → L101로 이어짐. 이전 L87 편집자 노트는 해소돼 제거
- 손본 곳(재점검): L99 "규칙을 만든 제 예문" → "규칙을 쓴 제 지침의 예문"(예문이 규칙을 만든 것으로 읽힘) / L101 "설명 스킬도 같은 장치를 둡니다" → "설명 스킬에는 이 대조 단계가 있습니다"("같은 장치"의 지시 대상을 직전 문단 용어 "대조하는 단계"로 고정, "도"는 전역 지침에도 대조 단계가 있다는 근거 없는 함의를 만들어 뺌)
- 손대지 않기로 한 곳(재점검): L89-95 예문 블록의 "전:" 반말과 "후:" 습니다체 혼재는 예문 내용이라 유지 / L10, L18, L20, L22는 리드 지시로 이번 회차 제외
- 사람 결정 대기(재점검): L101 끝 문장과 "정리하며" 셋째 결정이 "규칙을 짝으로 붙였다"에 머물러, 새 교훈(대조 단계가 따로 있어야 했다)으로 고리가 닫히지 않음. 주장 범위가 바뀌는 수정이라 편집자 노트로 남김
- 사용자 결정 2회차 재점검(L101, L105, L107, L109, writer 수정분): L101 끝과 L105 셋째 결정이 "규칙만으로는 부족했다"로 L99 교훈과 고리가 닫힘. L107 "바꿀 것이 있습니다" 아래 두 문단(L107 어절 근거, L109 전역 지침의 빈틈)이 묶임. 이전 편집자 노트(맺음 고리 미완)는 해소돼 제거
- 손본 곳(2회차): L101 "줄이는 규칙에는 지우지 말라는 규칙만으로는" → "줄이는 규칙에 지우지 말라는 규칙만 붙여서는"(주제어 "규칙에는"과 "규칙만으로는"이 겹쳐 주어가 흐림) / L109 첫 문장 "전역 지침에도 빈틈이 남아 있습니다" → "바꿀 것의 다른 하나는 전역 지침에 남은 빈틈입니다"(L107 "우선"이 연 두 항목 묶음을 닫음. 아래 문장 분리로 문단이 7문장이 되지 않게 한 문장으로 둠) / L109 "이 규칙이 ... 되었는데, 그 답변에는" → "STE 규칙은 AI가 쓰는 모든 답변과 문서의 ... 되었습니다. 그런데 전역 지침은 그 답변과 문서에"("이 규칙"이 STE 규칙과 지우지 말라는 규칙 둘로 읽힘. 용어는 L12의 "AI가 쓰는 모든 답변과 문서"로 고정. 두 절을 두 문장으로 나눔)
- 손대지 않기로 한 곳(2회차): L105 6문장은 1회차 판단(우산 뒤 세 결정) 유지. 셋째 결정이 "붙였지만 부족했다"로 바뀌었어도 L109가 그 부족을 받아 이어 감 / L109 둘째 문장이 L101 첫 문장과 겹치지만 전역 지침과 대비하려는 반복이라 유지 / L10, L18, L20, L22는 리드 지시로 제외
- 3회차 재점검(L10, L18, L20, L22, verifier 수정분 V-23~V-27): L10 연쇄("이 비용을" → 카파시의 형식 → 80%) 유지. L18 정의 정박(ASD-STE100 → 통제 언어 → 이 규격) 뒤 끝 문장이 STEMG를 꺼내고 L20이 앞자리로 받는 연쇄라 유지. L22 우산("문장 구조와 어휘로 나뉩니다") 뒤 두 갈래라 유지
- 손본 곳(3회차): L20 "무료 요청할 수 있습니다" → "무료로 요청할 수 있습니다"(조사 누락)
- 손대지 않기로 한 곳(3회차): 범위 한정어 "가끔은"(L10), "설명문의 문단"(L22), "원칙적으로"(L22)는 리드 지시와 1차 출처 범위대로 유지 / L18 "만들어졌습니다" 수동형은 만든 주체(AECMA)가 본문에 없어 주어를 넣으면 새 사실이 되므로 유지 / L18 "항공 정비 문서"는 소제목 "항공 정비 매뉴얼의 규칙"과 표기가 다르지만 원문 "maintenance documentation"의 범위를 옮긴 사실 진술이라 소주제 이름으로 맞추지 않음 / L10 "요청한다는 말도 덧붙였습니다"의 현재형은 원문 "I've tried"와 시제가 다르나 V-23 확정 문장이라 유지

## 되돌림 기록

- 근거 사슬 1회차 | main → blog-verifier | 항목 2건 | 해소 2, 남음 0 | ste100-for-ai-output.md:99, 89-97
- 사용자 결정 1회차 | main → blog-editor (재점검) | 항목 1건(L87 예문 불일치) | 해소 1, 남음 0 | L87-101. 재점검 중 새 편집자 노트 1건(L101 맺음과 정리하며의 고리)
- 근거 사슬 2회차 | main → blog-verifier | 항목 2건 | 해소 2, 남음 0 | ste100-for-ai-output.md:109
- 사용자 결정 2회차 | main → blog-editor (재점검) | 항목 1건(맺음 고리 미완) | 해소 1, 남음 0 | L101, L105, L107, L109
- 근거 사슬 3회차 | main → blog-verifier | 항목 4건(10, 18, 20, 22줄) | 해소 4, 남음 0 | ste100-for-ai-output.md:10, 18, 20, 22
- 근거 사슬 재점검 3회차 | main → blog-editor (재점검) | 항목 4줄(L10, L18, L20, L22) | 해소 4, 남음 0 | 표현 수정 L20 1건
