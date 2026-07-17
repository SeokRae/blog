# 리서치: flowcast 시리즈 1편 — 문서화, 그중에서도 '시각화'가 중요한 이유와 flowcast를 만드는 배경

> 이 글은 flowcast의 사용법/구현이 아니라 **왜 이걸 만드는가(배경·문제의식)**를 세우는 1편이다.
> 근거는 "일반론"보다 이 사람이 실제로 만든 flowcast 소스·이력에서 나오는 구체적 사실을 최우선으로 모았다.
> 경로 표기: 내부 근거는 `파일:라인` 또는 커밋 해시, 외부는 URL.

관련 소스 위치(전부 접근 성공):
- flowcast 소스: `/Users/sr/IdeaProjects/claude-tools/flowcast/`
- 버전별 캐시: `/Users/sr/.claude/plugins/cache/flowcast/flowcast/<버전>/` (0.2.0 ~ 0.11.2, 총 19개 버전 스냅샷)
- 메모리 노트: `/Users/sr/.claude/projects/-Users-sr-obsidian-sr-labs/memory/project-flowcast-plugin.md`

---

## 근거

### A. flowcast의 정체성과 핵심 아이디어

- (내부) flowcast는 "흐름도를 **생성**만 하는 도구가 아니라 IF/서비스 흐름도 **작업 전반**(생성·변환·검증·편집·PPT 입출력)을 다루는 하네스"로 명시적으로 포지셔닝된다 — 출처: `flowcast/README.md:3-5`, `flowcast/CLAUDE.md:5`, 메모리 노트 line 10.
- (내부) 핵심 아이디어 = **"JSON을 사람이 손으로 짜지 않게 한다"**: 데이터와 패턴 의도를 주면 라우터가 다이어그램 단위로 쪼개고, 여러 drawer가 각자 하나씩 렌더·파일링한다 — 출처: `flowcast/README.md:5`, `flowcast/skills/flowcast/SKILL.md:11`.
- (내부) 파이프라인 = 텍스트/데이터 → 표준 JSON → `render.py` → self-contained HTML(+선택 PDF/PPTX). 스키마의 단일 진실은 `render.py` 상단 docstring이다 — 출처: `flowcast/CLAUDE.md:15`, `flowcast/scripts/render.py:1-30`(docstring), `flowcast/README.md:130`.
- (내부) 코어(render/import/생성)는 **stdlib만** 사용하고 결과물은 self-contained HTML이다(외부 의존성 없이 어디서나 열림) — 출처: `flowcast/CLAUDE.md:38`, `flowcast/README.md:33`.

### B. 탄생 계보 — 실무에서 쓰던 도구를 하네스로 재구성

- (내부) flowcast는 무에서 나온 게 아니라 **vault 로컬 스킬 `ifflow`를 self-contained Claude Code 플러그인으로 재구성한 것**이다 — 출처: 메모리 노트 line 10, `flowcast/PLAN.md:6`("ifflow 기능을 self-contained flowcast 플러그인으로 재구성").
- (내부) 최초 커밋 메시지가 이관 성격을 그대로 드러낸다: `350a0cc feat: flowcast 플러그인 초기 구축 — router/drawer 팬아웃 하네스 + 3뷰 + **render.py 이관** + 합성 예제` — 출처: `git log --reverse` 첫 커밋.
- (내부) 그 실무 뿌리는 **PSP(결제) E2E 흐름 문서화**다. 버전 진화 로그가 반복적으로 "PSP 실사용 피드백"을 개선 트리거로 기록한다 — 출처: 메모리 노트 line 22("B-out 품질 개선 v0.4.0, PSP 실사용 피드백"), line 27(v0.6.0 "ppt 상단에 무슨 내용인지 타이틀"), line 30(v0.10.0), line 31(v0.11.x "PSP 인프라2 실사용 피드백"). 관련 프로젝트 노트: `project-psp-flow-review.md`.

### C. "왜 텍스트 문서만으로 부족한가" — 뷰를 3개로 나눈 이유

- (내부) 뷰 3종은 각각 다른 것을 그리려고 존재한다: **sequence**(행위자 간 시간순 요청/응답, 스윔레인) · **topology**(인프라/존 공간 배치 + 번호 구간) · **component**(포트 달린 컴포넌트 박스 + 프로토콜 방향 엣지) — 출처: `flowcast/README.md:18-24`, 각 뷰 스킬 `flowcast/skills/{sequence,topology,component}/SKILL.md` head.
- (내부) **핵심 인사이트(근거 있음)**: "업무 순서와 인프라 배치를 topology 한 장에 겹치면 둘 다 흐려진다." 그래서 업무 서사가 있으면 sequence(비즈니스 로직)와 topology(인프라 통신)를 **2축 페어로 쪼갠다** — 출처: `flowcast/agents/diagram-router.md:28`("2축 페어링"), 메모리 노트 line 24(워크플로우 게이트 4종 v0.5.0, #23/#24).
- (내부) topology 범례에서도 같은 원리: `label`=업무 흐름(무엇을 하는가), `meta`=기술 상세(프로토콜·포트·FW)를 **분리 렌더** — "흐름 핵심이 기술 detail에 묻히지 않게" — 출처: `flowcast/skills/topology/SKILL.md`(스키마 필드 절), 메모리 노트 line 28~29.

### D. "왜 하필 자동 생성인가" — 수작업 다이어그램의 낡음/유지보수 비용을 하네스로 흡수

- (내부) **다이어그램은 문서에서 파생되며 JSON `source` 필드에 계보(원문 경로)를 기록한다. "근거 문서 없는 다이어그램은 검토·수정 때 사실 확인이 불가능해진다."** — 이 문장이 flowcast가 stale diagram 문제를 내부적으로 어떻게 정의했는지 보여준다 — 출처: `flowcast/skills/flowcast/SKILL.md:48`, 지식 계층 `SKILL.md:34-47`(개념노트→흐름문서→시나리오노트→다이어그램→PPT).
- (내부) **재렌더 전파 = anti-stale 메커니즘**: 렌더러/스타일이 개선될 때마다 기존 다이어그램 전체를 재생성한다. 로그에 "PSP pptx 11종/10종 재export·재렌더"가 반복 등장 — 손으로 그렸다면 매번 11장을 다시 그려야 할 유지보수 비용을, 생성기 한 번 고치고 재렌더로 흡수한다 — 출처: 메모리 노트 line 22(11종), 27(11종), 28(다수), 30(11세트), 31.
- (내부) **편집도 데이터로**: 기존 다이어그램 수정은 router를 다시 안 돌리고 해당 `{name}.json`만 고쳐 재렌더한다. "데이터가 안 바뀌는 수정(라벨·배치)은 JSON만 수정 → 재렌더" — 출처: `flowcast/skills/flowcast/SKILL.md:22-29`(⓪ 컨텍스트 확인, 편집 경로).
- (내부) **범위가 "생성"에서 "작업 전반"으로 재정의된 서사**: 커밋 `5c52fcc feat: PPT 입력 변환(B-in) + 하네스 범위 재정의 (#1) (#2)`. README 로드맵이 생성 → 변환(입력) → 검증 → 출력(PPT) → 편집·갱신 → 뷰 확장으로 확장됨 — 출처: `git log`, `flowcast/README.md:7-16`.
- (내부) 실무에서 다이어그램은 결국 **슬라이드(.pptx) 안에 살고 낡는다**. flowcast는 양방향 다리를 놓는다: B-in(`.pptx` 슬라이드 → draft JSON 추출, stdlib) / B-out(JSON → 편집가능 네이티브 `.pptx`) — 출처: `flowcast/README.md:12-14, 56-70`, `flowcast/CLAUDE.md:17-18`.

### E. 이 사람은 '문서 시각화'에 반복 투자해왔다 (정황 근거 — 가볍게)

- (내부) flowcast 외에도 시각화 도구가 여러 개 존재한다:
  - `sr-obsidian:visualize` — "프로젝트 문서(MD)를 HTML 시각화로 변환" (`/Users/sr/.claude/plugins/marketplaces/sr-obsidian/skills/visualize/SKILL.md`)
  - `claude-visualize` 플러그인 — "Generate self-contained HTML visualizations from documents, data, flows, system architectures..." (`/Users/sr/.claude/plugins/marketplaces/claude-visualize/skills/visualize/SKILL.md`)
  - `dataviz` 스킬 (차트/대시보드 디자인 시스템) — 세션 available-skills에 존재
  - `sr-obsidian:canvas`(의존관계 맵·다이어그램), `sr-obsidian:obsidian-bases`(데이터 집계 뷰) 등
  - 그리고 flowcast의 전신 `ifflow`(vault 로컬)
- 정황 판단: flowcast는 "문서를 눈에 보이게 만든다"는 반복된 관심의 **가장 구조화된(하네스화된) 결과물**로 보인다. 단, 이 항목은 정황 근거 수준이며 각 도구의 세부는 이 글에서 깊이 다룰 필요 없음.

### F. 외부 근거 (좁게 — 뼈대 주장 뒷받침용)

- (외부) **stale diagram 문제 + diagrams-as-code의 등장 이유**: Visio/Keynote로 그려 PNG로 내보내 위키에 박아둔 다이어그램은 "6개월 뒤 그림이 틀리고, 소스 파일 주인은 아무도 기억 못 하고, 다음 사람은 처음부터 다시 그린다." 서비스 경계를 리팩터링하거나 큐를 추가하거나 내부 API 이름을 바꾸면 위키 속 다이어그램은 조용히 fiction이 된다. diagrams-as-code(Structurizr/PlantUML/Mermaid)는 이 decay에 대한 직접적 응답 — 다이어그램을 텍스트로 코드 옆 버전관리에 두고, 코드가 바뀌면 다시 렌더한다(PR에서 diff, 시간에 따른 진화 추적, 문서-코드 동기화) — 출처: https://lukemerrett.com/c4-diagrams-as-code-architectural-joy/ , https://byteswithcoffee.com/2023/01/31/diagram-as-code/ , https://hidekazu-konishi.com/entry/diagramming_c4_plantuml_mermaid_selection_guide.html
- (외부) **오늘날 아키텍처 다이어그램 텍스트 표기의 3대장 = C4 model · PlantUML · Mermaid.** PlantUML이 가장 오래됐고, Mermaid는 Markdown 유사 문법 + GitHub 네이티브 렌더 지원 — 출처: 위 hidekazu-konishi 및 https://mermaid.js.org/syntax/c4.html
- (외부) **시각이 텍스트보다 구조 이해에 유리하다는 인지 근거**: dual coding theory(Allan Paivio, 1970s) — 뇌가 시각/언어 정보를 분리·연결된 두 시스템으로 처리하며, 그림은 두 코드를 동시에 활성화해 더 풍부한 기억 흔적을 남긴다. Picture Superiority Effect의 대표 실험(Shepard 1967): 그림 612장 재인 정확도 98% vs 단어 90%. "시각 채널은 공간 관계·구조·패턴·전체 조망을 표현하는 데 특히 강하고, 시스템·프로세스처럼 내재적 공간 구조가 있는 정보에 효과적" — 출처: https://en.wikipedia.org/wiki/Picture_superiority_effect , https://www.growthengineering.co.uk/dual-coding/
- (외부·중요한 단서) 위 인지 근거의 대부분은 **기억/재인(recall)** 실험이지 "복잡한 시스템 구조 이해" 자체를 직접 측정한 게 아니다. 그리고 "시각은 관련성 있고·잘 조직되고·언어 설명과 통합됐을 때 가장 도움이 된다"는 단서가 붙는다 — 즉 "그림이 무조건 낫다"가 아니라 "잘 만든 그림이 낫다". writer는 98% vs 90% 같은 수치를 "구조 이해"에 곧바로 갖다 붙이지 말 것 — 출처: https://www.structural-learning.com/post/dual-coding-a-teachers-guide

---

## 인사이트 후보 (이 글에서 밀 수 있는 핵심 — 3~5개)

1. **"다이어그램은 문서의 파생물이어야 한다."** flowcast는 다이어그램에 반드시 `source`(원문 문서) 계보를 요구한다. 근거 문서 없는 다이어그램은 나중에 고칠 때 사실 확인이 불가능하기 때문 — 이게 stale diagram이 생기는 진짜 이유이자, "예쁜 그림 한 장"보다 "출처가 살아있는 그림"이 중요한 이유다. (근거: SKILL.md:48, 지식계층 SKILL.md:34-47 / 외부: diagrams-as-code decay)

2. **"수작업 다이어그램의 진짜 비용은 그리는 순간이 아니라 '두 번째 수정'에서 터진다."** flowcast는 생성기를 한 번 고치고 PSP 11개 덱을 재렌더하는 식으로 유지보수 비용을 흡수한다. 손으로 그렸다면 매 개선마다 11장을 다시 그려야 했다. 자동 생성의 값어치는 첫 장이 아니라 N번째 재생성에 있다. (근거: 메모리 노트 재export/재렌더 반복 기록, 편집 경로 SKILL.md:22-29)

3. **"한 장에 다 담으려다 둘 다 흐려진다 — 그래서 뷰를 쪼갠다."** 업무 순서(sequence)와 인프라 배치(topology)를 한 그림에 겹치면 둘 다 안 보인다. flowcast가 뷰를 3개로 나누고 2축 페어링을 도입한 건 "무엇을 강조할지 결정하는 것도 문서화의 일부"라는 실무 교훈에서 나왔다. (근거: router 2축 페어링 diagram-router.md:28, 워크플로우 게이트 v0.5.0)

4. **"텍스트만으로 부족한 건 취향이 아니라 구조 때문이다."** 시스템의 존·경로·요청/응답 순서 같은 공간적·구조적 정보는 텍스트로 나열하면 독자가 머릿속에서 다시 그려야 한다. 시각 채널은 바로 그 공간 관계·전체 조망에 강하다(dual coding). 단, 근거는 "잘 조직된 그림"에 한정된다 — 그래서 flowcast는 아무 그림이 아니라 문서에서 파생된 검증 가능한 그림을 지향한다. (근거: 외부 dual coding / picture superiority + 단서)

5. **"flowcast는 '문서를 눈에 보이게'라는 반복된 관심의 하네스화된 결론이다."** ifflow(전신)에서 시작해, PSP 결제 흐름을 반복해서 그리며 겪은 고통(낡음·업무/인프라 혼재·PPT 안에서 죽는 그림)을 라우터/드로어 팬아웃 + 표준 JSON + 재렌더로 제도화한 것. 이 글은 그 여정의 1편으로, "왜 이 고생을 사서 하나"에 답한다. (근거: PLAN.md:6, 메모리 노트 계보 + 버전 진화 서사)

---

## 미해결 질문 (verifier가 검증하거나 writer가 `(확인 필요)`로 남길 것)

- **[내부·서사]** ifflow → flowcast로 재구성하기 전, "손으로/기존 방식으로 그리다 겪은 구체적 고통 사건"이 하나 있으면 글이 훨씬 산다. 메모리엔 "PSP 실사용 피드백"이 반복되지만 **최초의 트리거가 된 구체 일화**(예: 특정 덱이 낡아서 문제가 됐다든지)는 소스에 명시적으로 없다 — writer/사용자가 경험에서 채워야 함. `(확인 필요)`.
- **[외부·정직하게]** ~~"시각 자료가 텍스트보다 **복잡한 시스템 구조 이해에** 우월하다"를 직접 측정한 연구는 이번 검색에서 확정하지 못함.~~ 확보한 근거(picture superiority, dual coding)는 주로 기억/재인 실험 + 학습 맥락이다. 이 주장을 강하게 쓰려면 소프트웨어 아키텍처/다이어그램 이해도를 직접 다룬 실증 연구가 필요 — 없으면 "기억·인지 부하 경감" 선에서만 주장할 것. **→ 아래 "검증 기록"에서 해소됨 (Heijstek 2011). 결론: 직접 측정한 연구가 있고, 결과는 오히려 시각 우위를 지지하지 않는다.**
- **[개념 구분]** flowcast는 엄밀히는 손으로 쓰는 DSL 기반 **diagrams-as-code**(Mermaid/C4)와 다르다 — 사람이 JSON DSL을 쓰는 게 아니라 **에이전트가 데이터/문서에서 표준 JSON을 생성**한다("JSON을 손으로 짜지 않게 한다"). 글에서 diagrams-as-code 흐름을 인용하되 flowcast를 그 하위로 뭉뚱그리지 말고 "그 계보에서 한 걸음 더 — 저작마저 자동화"로 위치시키는 게 정확함. (근거: README.md:5, SKILL.md:11 vs 외부 diagrams-as-code)
- **[수치 인용 주의]** Shepard 1967의 98%/90%는 재인 정확도 수치다. writer가 "다이어그램이 98% 더 잘 이해된다" 식으로 오독·오인용하지 않도록 주의. `(확인 필요)` 표기 권장.
- **[범위]** 이 글은 1편(배경/동기)이다. flowcast의 라우터/드로어 팬아웃 구조·3뷰 스키마·PPT 입출력 구현 디테일은 **후속 편의 재료**이므로 1편에서 깊이 설명하지 말 것(근거는 위 A~D에 이미 정리됨).

---

## 검증 기록

> 발행본에 등장하는 **모든 외부 인용**은 여기에 서지와 확인 방법이 남아야 한다.
> 이 절이 비어 있는데 본문에 인용이 있으면 그 자체가 결함이다. (#16)

### 확정 — Heijstek et al. 2011 (위 "미해결 질문" 2번 항목 해소)

- **서지**: Werner Heijstek, Thomas Kühne, Michel R. V. Chaudron, "Experimental Analysis of Textual and Graphical Representations for Software Architecture Design", *ESEM 2011* (5th International Symposium on Empirical Software Engineering and Measurement), pp. 167–176. DOI [10.1109/ESEM.2011.25](https://doi.org/10.1109/ESEM.2011.25)
- **확인 방법**: dblp 저자 페이지에서 서지(저자·연도·페이지·DOI) 대조 + DOI content negotiation(`Accept: application/vnd.citationstyles.csl+json`)으로 doi.org 응답 확인 + Semantic Scholar·IEEE Xplore 초록 교차 확인.
- **결과 (본문 근거)**:
  - 참가자 47명(산업계·학계 혼합)의 통제 실험.
  - 다이어그램도 텍스트도 아키텍처 설계 결정 전달에서 **유의하게 더 효율적이지 않았다.**
  - 텍스트를 주로 사용한 참가자가 **전반적으로, 그리고 토폴로지 관련 문항에서 유의하게 더 높은 점수**를 받았다.
  - 다이어그램은 비영어권 참가자의 정보 추출 어려움을 완화하지 못했다.
- **본문 대비 정합성**: `_posts/2026-07-15-flowcast-1-why-visual-docs.md:77`은 토폴로지 문항만 언급하고 "유의하게"·"전반적으로"를 생략해 **논문보다 약하게** 진술한다. 과장 없음 — 그대로 두어도 된다.
- **이 인용의 역할**: 글 자신의 주장("그래서 그림을 그린다")에 **불리한 반증**. 시각 우위를 단정하지 않기 위해 일부러 넣었다.

### 확정 — 본문 DOI 3종

doi.org content negotiation으로 각 DOI가 실제로 무엇을 가리키는지 확인함. 셋 다 본문 진술과 일치.

| DOI | 실제 문헌 | 본문에서 쓰인 곳 |
|---|---|---|
| [10.1007/BF01320076](https://doi.org/10.1007/BF01320076) | Clark & Paivio, "Dual coding theory and education", *Educational Psychology Review* 3:149–210 (1991) | dual coding theory 언급 |
| [10.1016/S0022-5371(67)80067-7](https://doi.org/10.1016/S0022-5371(67)80067-7) | Shepard, "Recognition memory for words, sentences, and pictures", *Journal of Verbal Learning and Verbal Behavior* 6:156–163 (1967) | 재인 정확도 "90%대 후반" |
| [10.1109/ESEM.2011.25](https://doi.org/10.1109/ESEM.2011.25) | Heijstek, Kühne, Chaudron, ESEM 2011, pp. 167–176 | 반증 문단 |

- **수치 인용 주의 항목 해소**: 본문은 Shepard를 "재인 정확도가 90%대 후반"으로만 쓰고 "구조 이해"에 갖다 붙이지 않았다. 위 "미해결 질문"의 경고를 지킴.
- 참고: dual coding 원 출처를 Paivio 1970년대 원저가 아니라 Clark & Paivio 1991 리뷰로 인용한다. 본문이 "오래 다뤄진 주제"로만 서술하므로 리뷰 인용이 적절.

### 미해소 — 구체 일화

위 "미해결 질문" 1번(최초 트리거가 된 구체 일화)은 **여전히 미해소**다. 소스에 명시적으로 없고 경험에서 채워야 한다. 발행본에는 결국 들어가지 않았다.
