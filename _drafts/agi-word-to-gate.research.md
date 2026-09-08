---
슬러그: agi-word-to-gate
주제: AGI에 대해 개발자가 실무적으로 어떻게 접근해야 하는가 (각도 = 용어부터 걷어내기)
작성일: 2026-09-08
---

# 리서치: AGI라는 단어를 실무 질문으로 바꿔 듣기

## 이 노트를 읽는 순서

이 글의 위험은 하나입니다. **담론을 걷어낸 자리가 비면 외부 자료 요약글이 됩니다.** 그래서 근거를 두 덩이로 나눠 뒀습니다. E 계열(외부)은 "그 단어가 실무 판단을 나른 적이 없다"를 뒷받침하고, I 계열(내부)은 "그 자리에 실제로 무엇이 돌아가고 있는가"를 채웁니다. **분량과 밀도는 I 계열이 주(主)여야 합니다.** E 계열은 도입부와 한 절 분량을 넘기면 각도가 무너집니다.

E 계열은 전부 1차 출처에서 원문과 날짜를 확보했습니다. 확보하지 못한 것은 `## 미해결 질문`에 그대로 남겼고, 채워 넣지 않았습니다.

---

## 근거 E: 외부 (좁게, 1차 출처 확인 완료)

### E-1. AGI 정의는 기관마다 다르고, 그 사실이 논문으로 정리돼 있습니다

- 서지: Meredith Ringel Morris, Jascha Sohl-Dickstein, Noah Fiedel, Tris Warkentin, Allan Dafoe, Aleksandra Faust, Clement Farabet, Shane Legg, "Levels of AGI for Operationalizing Progress on the Path to AGI", arXiv:2311.02462. v1 2023-11-04 제출, 최신 v5 2025-09-24.
- 확인 방법: `https://arxiv.org/abs/2311.02462` 초록 및 `https://arxiv.org/html/2311.02462v5`, `https://arxiv.org/html/2311.02462v2` 본문 조회 (2026-09-08).
- 내용: 이 논문은 기존 AGI 정의를 **9개의 사례 연구**로 나열하고 비평합니다. 순서대로 The Turing Test | Strong AI – Systems Possessing Consciousness | Analogies to the Human Brain | Human-Level Performance on Cognitive Tasks | Ability to Learn Tasks | Economically Valuable Work | Flexible and General – The "Coffee Test" | Artificial Capable Intelligence | SOTA LLMs as Generalists.
- 초록 원문 중: "To develop our framework, we analyze existing definitions of AGI, and distill six principles that a useful ontology for AGI should satisfy."
- **글에서 쓸 방식**: "정의가 여러 개다"를 나열로 소비하지 마세요. 숫자 9만 쓰고, 진짜 재료는 E-2입니다.

### E-2. ★ 가장 진지한 조작화 시도가 "배포"를 정의에서 명시적으로 뺐습니다

- 서지: 위와 같음, 3절 "Defining AGI: Six Principles" 중 원리 4.
- 원문 그대로: `"Demonstrating that a system can perform a requisite set of tasks at a given level of performance should be sufficient for declaring the system to be an AGI; deployment of such a system in the open world should not be inherent in the definition of AGI."`
- 원리 6개 이름 원문: `"Focus on Capabilities, not Processes"` | `"Focus on Generality and Performance"` | `"Focus on Cognitive and Metacognitive, but not Physical, Tasks"` | `"Focus on Potential, not Deployment"` | `"Focus on Ecological Validity"` | `"Focus on the Path to AGI, not a Single Endpoint"`
- 같은 논문 5절(Testing for AGI) 원문: `"It is impossible to enumerate the full set of tasks achievable by a sufficiently general intelligence."`
- 같은 논문 4절 원문: `"While theoretically an 'Expert' level system, in practice the system may only be 'Competent,' because prompting interfaces are too complex for most end-users to elicit optimal performance."`
- **왜 결정적인가**: 실무자의 질문은 전부 배포 쪽에 있습니다. "내 파이프라인에서 이게 돌아가는가", "틀리면 무엇이 알려주는가". 그런데 정의를 가장 성실하게 조작화하려 한 쪽이 배포를 정의에서 **의도적으로** 제외했습니다. 즉 이 단어가 실무 질문에 답하지 않는 것은 단어가 부실해서가 아니라 **설계상 그렇게 그어져 있기 때문**입니다. 게다가 같은 논문이 "이론상 Expert지만 실제로는 Competent일 수 있다"고 스스로 적습니다. 정의가 자기 바깥에 무엇이 남는지를 알고 있어요.
- ⚠️ 인용 시 주의: 원리 4의 두 번째 문장은 논문의 설명 문단이 아니라 원리 진술문입니다. 축약하지 마세요.

### E-3. ★ 이 산업에서 가장 구속력 있던 AGI 조항이 6개월 만에 사라졌습니다

세 시점을 날짜로 고정합니다.

| 시점 | 문서 | AGI가 하는 일 |
|---|---|---|
| 2018-04 | OpenAI Charter | 능력 정의 (`"highly autonomous systems that outperform humans at most economically valuable work"`) |
| 2025-10-28 | Microsoft 공식 블로그 | 전문가 패널이 **검증하는 선언** |
| 2026-04-27 | Microsoft 공식 블로그 | 문서 전체에 **언급 없음** |

- Charter 정의 확인 방법: `openai.com/charter/` 직접 조회는 **HTTP 403**으로 실패했습니다. 대신 E-1 논문이 사례 연구 6(Economically Valuable Work)에서 이 문장을 축자 인용하고 있어 그것으로 확인했습니다. 발행일 2018-04(일부 2차 출처는 Charter 최초 게시를 2018-04로 적습니다).
- 2025-10-28 확인 방법: `https://blogs.microsoft.com/blog/2025/10/28/the-next-chapter-of-the-microsoft-openai-partnership/` 조회. 원문 그대로 `"Once AGI is declared by OpenAI, that declaration will now be verified by an independent expert panel."` / `"Microsoft's IP rights to research...will remain until either the expert panel verifies AGI or through 2030, whichever is first."` / `"Microsoft's IP rights for both models and products are extended through 2032 and now include models post-AGI, with appropriate safety guardrails."`
- 2026-04-27 확인 방법: `https://blogs.microsoft.com/blog/2026/04/27/the-next-phase-of-the-microsoft-openai-partnership/` 조회. **AGI와 expert panel 모두 문서 내 언급 0건.** 대신 원문 그대로 `"Revenue share payments from OpenAI to Microsoft continue through 2030, independent of OpenAI's technology progress, at the same percentage but subject to a total cap."`
- 배경(2차 출처, 참고용): Simon Willison, "Tracking the history of the now-deceased OpenAI Microsoft AGI clause", 2026-04-27, `https://simonwillison.net/2026/Apr/27/now-deceased-agi-clause/`. 2024-12 The Information 보도로 알려진 이익 기준(약 1,000억 달러) 정의와 2026-02-27 "정의와 절차는 변경 없음" 재확인을 시간순으로 정리합니다.
- **글에서 쓸 방식**: 이 표의 마지막 칸이 핵심입니다. 계약이 AGI를 버린 방식은 "도달했다"도 "도달 못 했다"도 아니라 **"기술 진척과 무관하게"**입니다. 판정할 수 없는 조건을 계약에서 빼는 가장 흔한 방법이고, 실무에서 우리가 이미 아는 동작이에요.
- ⚠️ 오늘(2026-09-08) 기준 최신 상태로 확인했습니다. 발행 시점이 밀리면 다시 확인해야 합니다.

### E-4. 체감과 측정이 반대 방향이었던 RCT 하나

- 서지: Joel Becker, Nate Rush, Elizabeth Barnes, David Rein, "Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity", arXiv:2507.09089. v1 2025-07-12, v2 2025-07-25. 블로그 공개 2025-07-10 (`https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/`).
- 초록 원문 중: `"16 developers with moderate AI experience complete 246 tasks in mature projects on which they have an average of 5 years of prior experience."` / `"Before starting tasks, developers forecast that allowing AI will reduce completion time by 24%. After completing the study, developers estimate that allowing AI reduced completion time by 20%. Surprisingly, we find that allowing AI actually increases completion time by 19%--AI tooling slowed developers down."` / `"This slowdown also contradicts predictions from experts in economics (39% shorter) and ML (38% shorter)."`
- 저자들이 스스로 단 한계 원문: `"Although the influence of experimental artifacts cannot be entirely ruled out, the robustness of the slowdown effect across our analyses suggests it is unlikely to primarily be a function of our experimental design."`
- **⚠️ 이 근거를 쓸 때의 제약**: 이건 "AI가 느리게 만든다"는 주장의 근거가 **아닙니다.** 개발자 16명, 2025년 2~6월 프론티어, 5년 경력의 성숙한 자기 저장소라는 조건이 붙습니다. 이 글에서 이걸 쓰는 이유는 딱 하나예요. **일을 끝낸 당사자의 사후 체감(20% 빨라짐)과 측정(19% 느려짐)이 방향까지 반대였다**는 것. 벤치마크 담론이 아니라 "보고를 믿을 것인가 측정을 믿을 것인가"에 걸립니다. 속도 주장으로 확장하면 근거를 넘습니다.

---

## 근거 I: 내부 (이 저장소와 하네스 플러그인, 1차)

### 왜 단계를 쪼갰는가

**I-1. 파이프라인이 다섯 단계로 갈린 이유는 능력이 아니라 권한입니다**

- 출처: `~/.claude/plugins/cache/sr-blog-harness/sr-blog-harness/0.1.0/README.md`, `skills/blog-pipeline/SKILL.md`
- 단계: 0.5 근거 수집(researcher) → 1 초안(writer) → 1.5 사실 검증(verifier) → 2 윤문(editor) → 3 발행(publisher).
- 각 에이전트 정의가 **자기가 하면 안 되는 일**을 명시합니다. 이게 분할의 실체입니다.
  - `agents/blog-verifier.md:37` 원문: `- **문체·구조·표현은 건드리지 않는다.** 문장을 짧게 나누거나 번역투를 고치는 것은 editor의 일이다. verifier는 **사실이 걸린 지점만** 만진다`
  - `agents/blog-editor.md:17` 원문: `- **내용을 추가·삭제·왜곡하지 않는다.** 기술적 주장, 숫자, 코드 결과를 임의로 바꾸지 않는다. 애매하면 원문을 유지한다 — 윤문은 문장 표현의 문제이지 사실관계의 문제가 아니다`
  - `agents/blog-editor.md:86` 원문: `- 기술적으로 틀린 것 같은 문장을 발견해도 임의로 고치지 않는다. 파일 하단에 \`<!-- 편집자 노트: ... -->\` 형태로 의심되는 부분을 남긴다`
- **판단**: 이건 "한 모델이 다 못 해서" 나눈 게 아닙니다. 같은 모델이 다섯 단계를 전부 돕니다. 나눈 이유는 **한 판단이 다른 판단을 조용히 덮어쓰는 것을 막기 위해서**입니다. editor가 사실을 고치면 검증 기록 없이 사실이 바뀌고, verifier가 문장을 다듬으면 무엇이 사실 교정이었는지 구분되지 않아요.

**I-2. sr-harness는 "빌드가 되는가"와 "계획한 것을 만들었는가"를 다른 스킬로 갈랐습니다**

- 출처: `~/.claude/plugins/cache/sr-harness/sr-harness/0.26.0/skills/analyze/SKILL.md:8` 원문: `**"빌드가 되는가"가 아니라 "계획한 것을 만들었는가"를 검증한다.**`
- 같은 파일 `:13-16` 역할 분리 표 원문: `| \`analyze\` | 의도 정합성 | Issue 요구사항대로 만들었는가? |` / `| \`verify\` | 기술 정상성 | 빌드·테스트가 통과하는가? |`
- 같은 파일 `:18` 원문: `analyze는 코드를 실행하지 않는다. **Issue(계획)와 diff(구현)를 텍스트로 대조**한다.`
- **판단**: 테스트 통과는 의도 정합성을 증명하지 않습니다. 이 둘을 한 스킬에 넣으면 초록불 하나가 두 질문에 동시에 답한 것처럼 읽히고, 실제로는 한쪽만 답한 것이죠.

### 그럴듯하게 틀린 사건들 (전부 같은 형태)

**I-3. ★ 외부 검토가 정확한 수치를 달고 틀렸고, `grep` 한 줄이 뒤집었습니다 (#26)**

- 출처: 이 저장소 Issue #26 "a11y: 링크·주석·태그 색이 WCAG AA 대비에 미달한다" (2026-07-17 생성)
- 이슈 본문 원문 그대로: `rouge 주석색 \`#999988\` 대비 ≈2.8:1(AA 미달) ... 링크색 teal(\`#008080\`)은 ≈4.8:1로 AA 통과`
- 이슈의 반박 원문 그대로: `**링크는 teal이 아니다.** 빌드된 CSS에서 \`teal\`은 rouge 문법 강조 클래스(\`.na\`·\`.no\`·\`.nv\` — Name.Attribute/Constant/Variable)의 색이고, 링크는 \`a{color:#1ABC9C}\`다.`
- 반박에 쓰인 명령 원문 그대로:
  ```
  $ grep -oE "[^{};]{0,40}\{[^}]*#1ABC9C[^}]*\}" _site/assets/css/main.css
  a{color:#1ABC9C;text-decoration:none}
  .button-link:hover,a.button:hover{background:#1ABC9C;...;color:#fff}
  .call-out{...background-color:#1ABC9C;...color:#FFF}

  $ grep -oE "[^{};]{0,40}\{[^}]*teal[^}]*\}" _site/assets/css/main.css
  .na{color:teal}  .no{color:teal}  .nv{color:teal}
  ```
- 이슈의 결론 원문 그대로: `즉 검토가 "통과"라고 넘긴 링크가 **자기가 지적한 주석색보다 더 나쁘고**, 본문 전체에 걸려 영향도 훨씬 크다.`
- 실제 값: 링크색 `#1ABC9C`는 **2.41:1**, 교체한 `#117964`는 **5.33:1**. 검토가 "통과"라 한 것이 실제로는 AA에 크게 미달했습니다.
- **왜 결정적인가**: 검토는 모호하게 틀린 게 아니라 **구체적인 수치를 달고** 틀렸습니다(≈4.8:1). 그리고 그것을 뒤집은 것은 더 나은 검토자가 아니라 빌드 산출물에 건 `grep` 두 줄입니다. **"어느 규칙이 그 색을 갖는가"는 판단이 아니라 조회입니다.**
- 이 저장소의 `CLAUDE.md`가 이 사건을 한 줄로 기록해 두고 있습니다. 원문 그대로: `Fable 검토는 "링크 teal은 통과"라 했으나 teal은 rouge \`.na\`/\`.no\`/\`.nv\` 색이었고 링크가 아니었음 (#26)`

**I-4. 결론이 "그 자리에서 검증하라"인 글이 인용을 다듬었습니다 (#30)**

- 출처: Issue #30 "fix: '검증하라'는 글의 코드 인용이 실제 파일과 다르다" (2026-07-17)
- 이슈 본문 원문 그대로 (대조표): 포스트는 `refute_match %r{"url": "/blog//"}, search`, 실제 발행 시점 파일(`1574064`)은 `refute_match(%r{"url": "/blog//}, search)`
- 이슈 원문 그대로: `정규식 안에 **없는 \`"\`를 넣었고 괄호를 뺐다.** 의미는 같지만, 하필 이 글의 결론이 **"'왜'를 기록할 때 그 안에 섞인 '검증 가능한 사실'은 그 자리에서 검증하라"** 다. 인용은 원문 그대로가 맞다.`
- 이슈 원문 그대로: `발행 시점 파일과 대조해 확인했으므로 "나중에 바뀐 것"이 아니라 **처음부터 잘못 옮긴 것**이다.`
- **판단**: 의미는 보존됐습니다. 그래서 읽어서는 안 잡힙니다. 문자 단위 대조만 잡습니다.

**I-5. ★ 변경 사유로 적힌 사실이 오기였고, 6일 뒤 API 조회로 정정됐습니다**

- 출처: 커밋 `29bf70f` (2026-07-13), 커밋 메시지 원문 그대로: `* docs: CLAUDE.md 이력 정정 — 'Chirpy archived' 오기 바로잡음 (실제로는 Type Theme가 archived)`
- 정정 전 `CLAUDE.md` 원문 그대로: `Chirpy 저장소는 archived 상태라 유지보수 대신 교체 선택`
- 정정 후 `CLAUDE.md` 원문 그대로: `⚠️ 당시 사유로 적은 "Chirpy가 archived"는 오기 — 2026-07-13 GitHub API 확인 시 Chirpy는 활성(v7.6.0)·오히려 Type Theme가 archived(2025-07-26)였음. 실제 교체 근거는 디자인/컨셉 적합성`
- **왜 결정적인가**: 이건 코드가 아니라 **결정의 이유**가 틀린 사례입니다. 그럴듯했고(archived 저장소를 떠난다는 건 흔한 이유), 6일 동안 아무도 의심하지 않았고, 확인 방법은 단 하나였습니다. API 한 번 호출하기. 그리고 정정하는 대신 **틀린 기록을 남기고 옆에 정정을 붙였습니다.** 뒤에서 다시 씁니다(I-9).

**I-6. ★ 검증 5라운드가 수렴하지 않았고, 뒤 라운드가 앞 라운드의 "정확함" 판정을 두 번 뒤집었습니다**

- 출처: `_drafts/harness-engineering-book-overview.research.md` (869줄). 포스트 한 편의 검증 기록입니다.
- 라운드별 결과 (원문 요약줄 그대로 인용):
  | 라운드 | 원문 |
  |---|---|
  | 1차 `:432` | `결과 요약: **오류 교정 7건 / 확정 20건 / 확인 불가 0건**` |
  | 2차 `:526` | `결과 요약: **오류 교정 6건 / 확정 10건(항목 묶음) / 확인 불가 0건**` |
  | 3차 `:622` | `결과 요약: **오류 교정 2건 / 확정 8건(항목 묶음) / 확인 불가 0건**` |
  | 4차 `:699` | `결과 요약: **오류 교정 1건 / 확정 9건(항목 묶음) / 확인 불가 0건**` |
  | 5차 `:792` | `결과 요약: **오류 교정 3건 / 확정 7건(항목 묶음) / 확인 불가 0건**` |
- **7 → 6 → 2 → 1 → 3.** 단조 감소가 아닙니다. 마지막 라운드가 직전 라운드보다 더 많이 잡았습니다.
- 뒤집힌 판정 1 (`:637` 원문 그대로): `주의: 1차 검증 기록 14번은 이 문장을 "결론 문장 축자 대조 → 정확"으로 판정했으나 **괄호 누락을 놓친 오판**이다. 재사용 금지.`
- 뒤집힌 판정 2 (`:801` 원문 그대로): `**4차 검증 기록 64번**은 이 문자열을 "**원문의 연속된 부분문자열**이라 인용으로서 정확하다"고 판정하고 "유지가 옳은 것 1건"으로 명시했다. **오판이다** — 내부 따옴표 2개를 지워야만 연속이 된다.`
- 5차 라운드가 스스로 밝힌 방침 (`:788` 원문 그대로): `이 방침을 택한 이유는 이 노트 자체가 앞서 두 번 "이전 라운드의 판정이 오판이었다"를 기록했기 때문이다(3차 50번이 1차 14번을 뒤집고, 검증 기록 7번이 근거 D·인사이트 7을 뒤집음). 실제로 이번에도 **4차 판정 1건이 뒤집혔다**(70번).`
- **글에서 쓸 방식**: 이게 이 글에서 가장 강한 내부 데이터입니다. "검증을 한 번 더 돌리면 되지 않나"에 대한 실측 답이에요. **다섯 번 돌렸고 수렴하지 않았습니다.**

**I-7. ★ 그 뒤집기를 결정한 것은 판단이 아니라 히트 수 0이었습니다**

- 출처: 같은 노트 `:798` (5차 70번의 확인 방법), 원문 그대로: `초안이 인용부호로 묶은 문자열 전체를 \`grep -c -F "스스로 고쳐서 통과 처리하는 문제를 구조적으로 차단" chapter_13_레거시_마이그레이션_팀.md\` → **히트 0건.** 이어서 \`sed -n '283p' | tr '.' '\n'\`로 해당 문장을 분리 출력해 책의 인용부호가 "통과 처리"에서 닫히는 것을 실물 확인.`
- 무엇이 틀렸는지 (`:799` 원문 그대로): `책은 \`"스스로 고쳐서 통과 처리"\`까지만 인용부호로 묶고 \`하는 문제를 구조적으로 차단하기 위함입니다\`는 저자의 산문이다. 발행본과 4차본은 그 **내부 닫는 따옴표를 삭제해 뒤 산문까지 인용 안으로 끌어왔고**, 그 결과 원문에 존재하지 않는 문자열이 축자 인용의 외형을 갖게 됐다.`
- 같은 라운드가 이어서 한 일 (`:824`, 74번 항목의 확인 방법, 원문 그대로): `블록인용 행을 제외한 본문에서 정규식 \`"([^"\n]{6,})"\`로 인용부호 문자열 50건을 추출해 전역 \`grep -rF\`로 1건씩 대조. 70번을 적발한 방법을 표본이 아니라 **전수**로 확대한 것이다.`
- **왜 결정적인가**: 네 번의 라운드에서 사람과 모델이 읽고 "정확하다"고 판정한 문자열이, `grep -c -F`의 반환값 0 앞에서 한 번에 무너졌습니다. 그리고 개선책은 더 나은 판단이 아니라 **같은 조회를 표본에서 전수로 넓힌 것**이었습니다.
- 부수 발견 (`:631` 원문 그대로): `**1차 검증 기록에 "본문의 외부 인용 전량 대조"라 적힌 것은 각주가 붙은 외부 URL 인용에 한정된 진술이었다.**` — "전량 대조"라는 보고가 읽는 사람 생각보다 좁은 범위였습니다. 보고서의 단어와 실제 범위가 갈리는 전형입니다.

**I-8. 계약을 지키는 대신 계약이 있다는 사실만 남았던 자리 (#101)**

- 출처: 커밋 `8cdfc8f` (2026-09-08), 메시지 원문 그대로: `발행본 7편 중 이 한 편만 리서치 노트가 저장소에 없었다. 각주 14개로 외부 자료를 인용하는데 근거를 되짚을 수 없는 상태였다. CLAUDE.md가 #16으로 못박은 계약이 여기서만 끊겨 있었다.`
- 선행 사건 #16 (2026-07-17): 발행본이 DOI까지 달아 인용한 논문을 리서치 노트는 "확정하지 못함"으로 남겨 뒀습니다. 이슈 본문 원문 그대로: `verifier가 검증해 확정했지만 **그 흔적을 어디에도 남기지 않았다.**` / `**사실 오류는 아니다 — 추적성 문제다**`
- **판단**: #16은 규칙을 만들었고, #101은 그 규칙이 한 편에서만 조용히 안 지켜진 것을 **7주 뒤에** 발견한 기록입니다. 규칙을 적는 것과 규칙이 돌아가는 것은 다른 일이에요.

### 그 자리에 실제로 무엇이 놓여 있는가

**I-9. ★ 게이트의 절반은 "보고 대신 산출물을 재는" 스크립트입니다**

- 출처: `~/.claude/plugins/cache/flowcast/flowcast/0.20.0/scripts/validate_rendered_pairs.py` 상단 docstring, 원문 그대로:
  ```
  """렌더 산출물을 manifest 와 대조하는 **dispatch 후 전용** 검증기.

  `validate_manifest.py` 는 drawer 팬아웃 **전** 게이트라 선언값만 본다(pair 당
  sequence 1 + topology 1, `segment_numbers` 동일성). 그런데 그 번호가 실제로
  그려졌는지, `source_ref` 가 렌더 JSON `source` 로 전사됐는지는 아무도 확인하지
  않았다(#88 · #94 핸드오프). 이 스크립트가 그 두 실측 대조를 맡는다:
  ```
- 같은 docstring, 무엇이 구멍이었는지 원문 그대로: `drawer 가 구간을 쪼개(1..4 → 1..6) 그려도 반환 에코는 그대로라 preflight 게이트가 형식적으로만 통과하던 구멍을 닫는다.`
- 같은 docstring, 자동 수정 금지 원문 그대로: `불일치는 **자동 수정하지 않는다** — 양쪽 값을 나란히 보고하고 사람이 원문·번호를 확인한다(#88 전반의 "자동 재번호 금지" 원칙).`
- **왜 결정적인가**: 서브에이전트가 "1..4 그렸습니다"라고 **정확히 시킨 대로 보고**하는데 실제 렌더 결과는 1..6이었습니다. 게이트는 통과합니다. 보고를 읽었으니까요. 이 스크립트는 보고를 안 읽고 **산출물 파일을 열어서 셉니다.** 그리고 다르면 고치지 않고 양쪽 값을 나란히 놓고 멈춥니다.
- 짝 스크립트: `scripts/scan-sensitive.sh:5-6` 원문 그대로: `# push / 공개 / CI 에서 이 스크립트가 0건(exit 0)일 때만 통과한다.` / `# 한 건이라도 매치되면 exit 1 로 파이프라인을 세운다.` — 확률적 판단을 exit 코드로 귀결시키는 같은 형태입니다.
- 또 하나: `sr-blog-harness/scripts/cohesion_check.py` docstring `:4-6` 원문 그대로: `판정하지 않는다. 주제열(각 문장의 첫 어절)과 문단 크기, 나열 위치, 예고 사슬을 사람이 볼 수 있게 펼쳐 놓을 뿐이다. 한국어 문장 분리와 어절 추출은 근사치이므로 플래그가 붙었다고 문제인 것도, 안 붙었다고 통과인 것도 아니다.` — **자기가 판정자가 아님을 자기 안에 적어 둔** 스크립트입니다.

**I-10. ★ 나머지 절반은 사람인데, 자리가 능력이 아니라 되돌림 가능성으로 정해져 있습니다**

- 출처: `~/.claude/plugins/cache/sr-harness/sr-harness/0.26.0/CLAUDE.md:20-32`
- 원문 그대로:
  ```
  ## 모델 자동 호출 차단 기준

  다음 넷 중 하나에 해당하는 스킬은 frontmatter에 `disable-model-invocation: true`를 단다.
  현재 대상: `ralph`, `goal`, `release`, `finish`, `abort`, `meta`.

  | 기준 | 예 |
  |------|-----|
  | 세션 전체를 자율 루프로 바꾼다 | `ralph`, `goal` (Stop hook 설치) |
  | 저장소 밖으로 나간다 | `release` (태그 push, GitHub Release) |
  | 되돌리는 데 별도 작업이 필요하다 | `finish` (머지, 브랜치 삭제), `abort` (브랜치 삭제) |
  | 하네스 자신을 고친다 | `meta` |

  되돌리기 쉽고 워크플로우 체인의 핵심인 스킬(`submit`, `issue`)에는 달지 않는다.
  ```
- 실물 확인: `grep -l "disable-model-invocation" */SKILL.md` → `abort` `goal` `meta` `finish` `release` `ralph` 6개. 각 파일 `:4`에 `disable-model-invocation: true`. 전체 스킬 25개 중 6개입니다 (`plugin.json` version 0.26.0).
- 같은 파일 `:34-35` 원문 그대로: `이 플래그는 **다른 스킬 본문이 호출을 지시하는 경로까지** 막는다. 체인이 그 앞에서 멈추는 자리에서는 슬래시 커맨드를 안내하고 대기하도록 해당 스킬 문구를 함께 고친다 (\`submit\`, \`pause\`, \`start\`).`
- **왜 결정적인가**: 네 기준 어디에도 "모델이 이건 잘 못한다"가 없습니다. 전부 **결과의 성질**입니다. 되돌리는 데 별도 작업이 필요한가, 저장소 밖으로 나가는가, 자기 자신을 고치는가. 모델이 아무리 좋아져도 머지는 여전히 되돌리는 데 별도 작업이 필요합니다. **이 자리는 모델 성능 축에 안 놓여 있어서, 모델이 좋아져도 옮겨지지 않습니다.**
- 같은 규칙이 블로그 파이프라인에도 있습니다. `sr-blog-harness/README.md` 원문 그대로: `발행은 Issue → feature 브랜치 → PR(\`Closes #N\`)까지만 자동화한다. **main 직접 push·자동 merge는 하지 않는다 — merge는 사용자가 한다.**`
- `agents/blog-publisher.md:12` 원문 그대로: `본문에 눈에 보이는 미해소 마커 \`(확인 필요)\`가 남아 있으면 **이동·발행하지 말고 중단**해 사용자에게 보고한다`

**I-11. 진화 루프에도 "근거 없으면 채택 금지" 게이트가 붙어 있습니다**

- 출처: `~/.claude/plugins/cache/sr-harness/sr-harness/0.26.0/evals/rubric.md`
- 왜 필요한가 `:7-9` 원문 그대로: `\`meta\`는 매 iteration마다 후보 3개를 강제로 만듭니다. "이미 최적"이라는 조기 종료가 금지돼 있으니, 루프는 구조적으로 **바꿀 게 없어도 바꾸는 쪽**으로 편향됩니다. 판정 기준이 없으면 그 편향이 그대로 채택됩니다.` / `루브릭의 가중치는 그 편향을 상쇄하도록 배분했습니다. 진화 루프가 팔고 싶어하는 것(새 메커니즘)에는 점수를 주지 않고, 진화 루프가 깨뜨리기 쉬운 것(워크플로우 계약, 안전성)에 절반 이상을 몰아줍니다.`
- 측정 근거가 없을 때 `:66` 원문 그대로: `그런 근거가 하나도 없으면 **채점하지 않고 후보를 미검증으로 표시합니다.**`
- 같은 절 `:73` 원문 그대로: `근거 없이 "개선으로 보인다"고 채택하는 것이 이 루브릭이 막으려는 정확한 실패입니다.`
- baseline 격리 `:47` 원문 그대로: `가장 틀리기 쉬운 지점입니다. **격리하지 않고 재면 스킬을 자기 자신과 비교하게 됩니다.**`
- **판단**: "개선으로 보인다"를 근거로 치지 않겠다고 규칙에 적어 둔 자리입니다. 벤치마크 담론이 실무에서 쓸모없어지는 지점을 정확히 짚습니다. **측정 조건을 격리하지 않은 점수는 조건이 아니라 자기 자신을 재고 있어요.**

**I-12. 자동 반복 구간일수록 사람 체크포인트를 더 명시하라는 규칙**

- 출처: `~/.claude/plugins/cache/sr-harness/sr-harness/0.26.0/skills/ownership-principles/SKILL.md`
- `:8` 원문 그대로: `에이전트가 실행을 대신할수록, 사람이 유지해야 하는 것은 "무엇을 했는가"가 아니라 "왜 그것을 승인했는가"다.`
- `:15` 원문 그대로: `- 사람 개입 없이 반복하는 구간(ralph·goal)일수록 outer loop 체크포인트를 매 반복 명시적으로 남긴다 — 자동 반복이 outer loop 자체를 지워버리면 안 된다`
- `:21` 원문 그대로: `- **게이트**: 설명할 수 없다면 출시하지 마라 (Explain it or don't ship it) — 변경 이유를 한 문장으로 말할 수 없으면 merge·promise 금지`
- ⚠️ **중복 주의**: 이 스킬은 테스트 기준 3편이 이미 각주로 인용했습니다(`[^ownership]`). 같은 문장을 다시 인용하면 재탕으로 읽힙니다. 이 글에서는 `:15`(자동 반복 구간일수록 체크포인트를 더 남긴다)만 새로 쓸 수 있고, `:8`과 `:26`은 피하는 게 낫습니다.

---

## 인사이트 후보

**A. 이 단어로는 아무 결정도 내려지지 않았습니다.**
정의가 아홉 개라서가 아닙니다(E-1). 가장 진지한 조작화 시도가 **배포를 정의 밖으로 명시적으로 밀어냈고**(E-2), 가장 구속력 있던 계약은 그 단어를 판정하는 대신 **삭제했습니다**(E-3). 판정 불가능한 조건을 계약에서 빼는 건 우리가 스펙 작업에서 늘 하는 일이에요. 그러니 "AGI가 오면"으로 시작하는 문장은 실무 문장이 아닙니다. 근거: E-1, E-2, E-3.

**B. 실무자가 실제로 묻는 질문은 정의 안에 없습니다.**
"내 파이프라인에서 이게 맞다는 걸 무엇이 알려주는가"는 배포 쪽 질문이고, E-2가 그걸 정의에서 뺐습니다. 그래서 단어를 걷어내도 잃는 게 없습니다. 애초에 그 자리에 답이 없었으니까요. 근거: E-2, I-2.

**C. 실패의 형태가 일정합니다. 모델은 모호하게 틀리지 않고 구체적으로 틀립니다.**
#26은 `≈4.8:1`이라는 수치를 달고 틀렸습니다(I-3). #30은 의미를 보존한 채 문자만 틀렸습니다(I-4). Chirpy 건은 이유가 그럴듯해서 6일을 살아남았습니다(I-5). 인용 하나는 네 라운드를 통과했습니다(I-7). **읽어서 걸리지 않는 형태로 틀린다는 게 공통점입니다.**

**D. ★ 검증을 더 돌리는 것으로는 수렴하지 않습니다. 이건 추측이 아니라 이 저장소의 실측입니다.**
7 → 6 → 2 → 1 → 3. 5차가 4차보다 많이 잡았고, 4차의 "정확함" 판정을 뒤집었습니다(I-6). 이게 왜 중요하냐면, "모델이 더 좋아지면 검토가 정확해진다"는 기대가 여기서 검증 가능한 형태로 반박되기 때문입니다. 같은 초안을 같은 방식으로 다섯 번 봤고, 마지막 라운드가 새 오류를 찾았습니다.

**E. ★ 뒤집은 것은 언제나 조회였습니다.**
`grep -oE`가 어떤 CSS 규칙이 그 색을 갖는지 답했고(I-3), `grep -c -F`가 히트 0으로 인용을 무너뜨렸고(I-7), GitHub API가 어느 저장소가 archived인지 답했고(I-5), `validate_rendered_pairs.py`가 보고 대신 렌더 파일을 셌습니다(I-9). **이 넷 다 판단이 아니라 조회입니다.** 그리고 조회는 모델 성능과 무관하게 같은 답을 냅니다.

**F. ★ 게이트가 그어진 자리가 모델 능력 축에 안 놓여 있습니다.**
`disable-model-invocation` 네 기준은 전부 결과의 성질입니다. 되돌리는 데 별도 작업이 필요한가, 저장소 밖으로 나가는가, 세션을 자율 루프로 바꾸는가, 자기 자신을 고치는가(I-10). 모델이 좋아져도 머지는 여전히 되돌리기 어렵습니다. **그래서 이 자리는 안 옮겨집니다.** 이게 하네스 책 편이 열어 두고 닫지 않은 질문("그때가 언제이고 무엇이 남는지")에 대해 이 글이 낼 수 있는 부분적 답입니다.

**G. 체감은 방향까지 틀릴 수 있습니다.**
개발자 본인이 20% 빨라졌다고 답한 조건에서 측정은 19% 느려짐이었습니다(E-4). 조건이 좁으니 일반화하면 안 되지만, **"직접 써 보니 좋더라"가 근거가 되는 자리에서 이 한 건이 방향까지 반대였다**는 사실은 남습니다. 그래서 게이트가 개인 체감이 아니라 산출물 측정 위에 서야 합니다.

**H. 정직한 한계, 이 글이 답하지 못하는 것.**
게이트를 늘리면 비용이 듭니다. 5라운드 검증은 포스트 한 편에 869줄짜리 노트를 남겼습니다. 어디까지가 적정선인지 이 저장소 데이터로는 판정되지 않습니다. 그리고 게이트 자체가 사각지대를 갖는다는 건 테스트 기준 3편이 이미 다뤘습니다. 이 글은 그 위에 "그럼 어디에 긋는가"만 더합니다.

---

## 소주제 이름 후보

세 개로 확정합니다. 네 번째 후보(사람이 남는 자리)는 셋째 이름 안에 접었습니다. 게이트의 두 절반(결정론적 조회와 사람 승인)이 **같은 기준으로 배치돼 있어서** 나누면 오히려 논지가 흩어집니다.

- **판정하는 대신 지운 단어** : 인사이트 A, B. AGI 정의가 여럿이라는 사실보다, 조작화 시도가 배포를 정의 밖으로 밀어냈다는 것과 그 단어를 판정하는 대신 지웠다는 것이 본체입니다. 근거 E-1, E-2, E-3.
  - ⚠️ 이름을 확정하며 바꿨습니다(2026-09-08, 사용자 결정). 처음 후보는 "계약에서 사라진 단어"였으나, 미해결 질문 3이 경고한 대로 확인된 것은 Microsoft 발표문에서 언급이 0건이라는 사실이지 계약 원문이 아닙니다. 계약은 비공개라 확보가 어렵습니다. 이름이 "계약"을 단정하면 이 글의 결론(확인 가능한 것만 말하라)을 제목에서 어깁니다. 본문에서도 인용 범위를 "Microsoft 발표문"으로 명시하세요.
- **그럴듯하게 틀린 자리** : 인사이트 C, D, G. 실패가 구체적인 수치와 함께 오고, 다섯 라운드를 돌려도 수렴하지 않았다는 실측. 근거 I-3, I-4, I-5, I-6, I-7, I-8, E-4.
- **모델이 좋아져도 안 옮겨지는 자리** : 인사이트 E, F. 뒤집은 것은 전부 조회였고, 사람이 남는 자리는 능력이 아니라 되돌림 가능성으로 정해져 있습니다. 근거 I-7, I-9, I-10, I-11, I-12, I-1, I-2.

표기 규칙: 세 이름 모두 순수 한국어라 태그 표기 충돌이 없습니다. 도입부 예고와 소제목에 이 표기를 그대로 씁니다. **개수나 번호 라벨("세 가지를 다룹니다", "첫째")은 쓰지 않습니다.**

태그 후보: `AGI`(고유명사 원 표기, 대문자 유지) | `에이전트` | `검증` | `하네스엔지니어링`. 마지막 것은 하네스 책 편이 이미 쓰는 태그라 시리즈성이 생깁니다. 넣을지는 writer가 결정하세요.

---

## 이미 발행된 것과의 경계 (중복 회피, 필독)

발행본 8편을 전수 확인했습니다. 이 글이 **다시 말하면 안 되는 것**과 **그 위에 더하는 것**입니다.

| 발행본 | 이미 말한 것 | 이 글이 겹치면 안 되는 지점 |
|---|---|---|
| 하네스 책 편 (2026-07-29) | "모델이 아니라 하네스가 결과를 결정한다", Build to Delete, 유효기간, `모델이 강해질수록 하네스의 한계 효용은 줄어든다` | **명제 소개를 반복하지 마세요.** 그 편은 "언제이고 무엇이 남는지에 대한 답은 아니다"로 끝냈습니다. 이 글은 그 질문 중 **"무엇이 남는가"에만** 답합니다(인사이트 F). 답의 형태는 예측이 아니라 이미 그어진 선의 관찰입니다 |
| 테스트 기준 3편 (2026-08-11) | `verify`의 Iron Law 블록 원문, Red Flags 표 원문, `ownership-principles` 각주, `검사기의 사각지대는 거의 무작위가 아닙니다` | **Iron Law와 Red Flags 표를 다시 인용하지 마세요.** 이 글의 게이트 재료는 `validate_rendered_pairs.py`, `scan-sensitive.sh`, `cohesion_check.py`, `disable-model-invocation` 네 기준, `rubric.md`입니다. 전부 미발행입니다(전수 grep 확인) |
| 테스트 기준 1편 | 커버리지 숫자가 구분 못 하는 것, change detector | 게이트 비용 논의는 그 편이 이미 했습니다. 이 글은 비용이 아니라 **위치**만 다룹니다 |
| flowcast 1편 (2026-07-15) | 에이전트가 자료에서 관계를 추출해 렌더하는 구조, 근거 경로 남기기 | flowcast를 소개하지 마세요. `validate_rendered_pairs.py` **한 파일의 docstring**만 씁니다 |
| Chirpy 편 (2026-07-13) | 적어둔 이유가 사실이 아니었다 (테마 교체 사유) | ⚠️ **주의.** I-5(Chirpy archived 오기)는 그 편의 주제와 인접합니다. 그 편은 "왜 옮겼는지 이유를 잘못 적었다"였고, 이 글에서 쓸 각도는 **"틀린 기록을 지우지 않고 옆에 정정을 붙였다"**입니다. 겹치면 잘라내세요 |

**미발행 확인(전수 grep, `_posts/*.md`)**: `Fable` 0건 | `teal` 0건 | `grep -F` 0건 | `5차` 0건 | `disable-model-invocation` 0건 | `validate_rendered` 0건 | `검증 기록` 0건 | `AGI` 0건.

---

## 미해결 질문

verifier가 처리할 항목입니다. 채워 넣지 않았습니다.

1. **OpenAI Charter 원문을 1차로 못 봤습니다.** `openai.com/charter/` 조회가 HTTP 403으로 실패했습니다. `"highly autonomous systems that outperform humans at most economically valuable work"`는 E-1 논문(arXiv:2311.02462)이 축자 인용한 것으로 확인했습니다. **본문에서 이 문장을 인용한다면 출처를 Charter가 아니라 "Charter를 인용한 Morris 등"으로 다는 게 정확합니다.** 발행 전에 Charter 직접 접근을 한 번 더 시도해 주세요. Charter 게시일(2018-04)도 2차 출처 기준입니다.
2. **2026-04-27 OpenAI 측 발표문을 못 봤습니다.** Microsoft 공식 블로그(`blogs.microsoft.com/blog/2026/04/27/...`)는 원문을 확인했습니다. OpenAI 측(`openai.com/index/next-phase-of-microsoft-partnership/`)은 조회하지 않았습니다. 두 발표문의 문구가 다를 수 있으니 **"Microsoft 공식 블로그"로 한정해 인용하거나**, OpenAI 측을 추가 확인하세요.
3. **"AGI 언급 0건"은 한 문서에 대한 진술입니다.** 2026-04-27 Microsoft 블로그 본문에서 AGI와 expert panel 언급이 없음을 확인했습니다. 이걸 "계약에서 사라졌다"로 확장하면 계약 원문이 아니라 발표문을 근거로 계약을 말하는 셈입니다. **표현을 "발표문에서 사라졌다"로 좁히거나, 계약 원문 근거를 따로 확보해야 합니다.** 이 글의 결론이 "확인 가능한 것만 말하라"이므로 여기서 어기면 #30과 같은 사고입니다.
4. **The Information의 1,000억 달러 이익 기준은 2차 출처만 있습니다.** Simon Willison의 정리(2026-04-27)로 확인했고 원 보도(2024-12)는 유료 장벽입니다. **인용한다면 "보도에 따르면"으로 명시하거나 빼세요.** 이 글의 논지(계약이 그 단어를 판정 대신 삭제했다)는 이 수치 없이도 성립합니다.
5. **CNBC 2026-04-27 기사 조회가 403이었습니다.** 매출 배분 상한 380억 달러 같은 숫자는 이 글에 필요 없습니다. 넣지 마세요.
6. **METR 후속 연구가 나왔는지 확정하지 못했습니다.** 검색 결과에 "두 번째 생산성 연구가 광범위한 AI 도입으로 선택 효과를 겪어 설계를 다시 짜고 있다"는 취지의 언급이 있었으나 1차 출처를 확보하지 못했습니다. **E-4는 2025-07 판만 쓰고, 후속을 언급하지 마세요.**
7. **`validate_rendered_pairs.py`의 `#88 · #94`는 flowcast 저장소 이슈 번호이고, 이 저장소 이슈와 번호가 겹칩니다.** 본문에서 인용할 때 어느 저장소의 이슈인지 명시하지 않으면 독자가 혼동합니다. docstring을 원문 그대로 인용하되 문장으로 소속을 밝히세요.
8. **검증 라운드 수치 7/6/2/1/3의 해석 한계.** 라운드마다 검증 대상 초안이 달랐습니다(1·2차는 보강본, 3차는 구조 재작성본, 4·5차는 같은 초안). **5차만 4차와 동일 초안이라 "같은 것을 다시 봤는데 더 나왔다"가 엄밀하게 성립하는 구간은 4차 → 5차입니다.** 앞 구간은 초안이 바뀌었으니 단조 감소를 기대할 이유 자체가 약합니다. 이 구분을 본문에서 흐리면 과장이 됩니다. 노트 `:787`이 근거입니다.

---

## 작성 시 지켜야 할 것 (writer에게)

- **E 계열을 앞에 몰지 마세요.** 도입부에서 계약 표(E-3) 한 번, 정의 원리(E-2) 한 번이면 충분합니다. 나머지 분량은 I 계열입니다. 외부 자료가 절반을 넘으면 이 글은 실패입니다.
- **"정의가 모호하다"로 끝내지 마세요.** 그건 관찰이고, 이 글의 결론은 **대체 질문**입니다. "이 산출물이 틀렸다는 걸 무엇이 알려주는가", 그리고 "그 답이 조회인가 판단인가".
- **인용은 원문 그대로.** 이 노트의 코드 블록과 인용문은 전부 원문에서 그대로 옮겼습니다. 축약, 괄호 생략, 정규식 손질 금지입니다(`CLAUDE.md` #30).
- **전망을 쓰지 마세요.** "언제 AGI가 온다"류는 이 글의 각도가 아닙니다. 인사이트 F도 예측이 아니라 **이미 그어진 선의 성질**에 대한 관찰로 써야 합니다.
- **개수와 번호 라벨 금지.** 도입부 예고는 소주제 이름 세 개를 산문으로 흘리되 "세 가지"라고 세지 않습니다.
- 습니다체 기본, 해요체는 리듬 변주로만.

---

## 검증 기록

verifier가 2026-09-08에 초안 `_drafts/agi-word-to-gate.md`를 전수 검증한 기록입니다. **본문의 모든 외부 인용과 내부 인용을 원문에서 직접 조회해 대조했고, 리서처와 writer의 보고를 근거로 삼지 않았습니다.** 확정 항목은 여기서 되짚을 수 있어야 합니다(`CLAUDE.md` #16).

검증은 두 라운드로 나뉩니다. **1차(V-1~V-38)는 WebFetch와 `curl`로 조회했고 openai.com 두 문서가 HTTP 403이라 확인 불가 2건을 남겼습니다. 2차(V-39~V-43)는 브라우저 자동화로 그 두 문서를 직접 열어 확인 불가를 모두 해소했습니다.** 1차 기록은 지우지 않고 그대로 두고 2차를 아래 D절에 덧붙입니다. 이 저장소가 Chirpy 오기를 정정할 때 쓴 방식이고(본문 `:136`), 무엇을 근거로 삼았다가 어떻게 바뀌었는지가 남아야 하기 때문입니다.

결과 요약(두 라운드 합계): **검증 항목 44건(V-1~V-44) / 초안 교정 8건 / 노트 교정 1건 / 확인 불가 0건**

- 1차에서 초안을 고친 것: V-5(미해소 플래그 제거), V-16(커밋 `29bf70f` 서술), V-19("7주" → "일곱 주 남짓"), V-21(2차 라운드 헤더 인용의 괄호 누락).
- 2차에서 초안을 고친 것: V-39(Charter를 1차 출처로 승격), V-40(`:61` 생략 부호 제거), V-41(매출 배분을 동일 항목으로 대조), V-42(양측 발표문으로 범위 확대).
- 노트를 고친 것: V-22(이 노트 I-7의 행 번호 `:800` → `:798`, `:802` → `:799`).
- 나머지 항목은 원문 대조 결과 이상 없음(확정)입니다.

### A. 외부 근거 (E 계열)

**V-1. Morris 등 논문 서지와 초록 인용 — 확정**
- 대상: 본문 `:19`, `:23`, 각주 `[^levels]`.
- 확인 방법: `https://arxiv.org/abs/2311.02462` 조회(2026-09-08). 초록 전문을 받아 대조.
- 결과: 초록에 `"To develop our framework, we analyze existing definitions of AGI, and distill six principles that a useful ontology for AGI should satisfy."`가 축자로 존재. 제출 이력 v1 2023-11-04, 최신 v5 2025-09-24로 각주와 일치. 저자 8인 표기도 일치.

**V-2. 사례 연구가 아홉 개이고 6번이 Economically Valuable Work인 것 — 확정**
- 대상: 본문 `:19`("아홉 개의 사례 연구"), `:49`("사례 연구 6번").
- 확인 방법: `https://arxiv.org/html/2311.02462v5` 2절 조회. 사례 연구 제목을 번호와 함께 전부 열거해 확인.
- 결과: 총 9건. 1 The Turing Test, 2 Strong AI – Systems Possessing Consciousness, 3 Analogies to the Human Brain, 4 Human-Level Performance on Cognitive Tasks, 5 Ability to Learn Tasks, **6 Economically Valuable Work**, 7 Flexible and General – The "Coffee Test" and Related Challenges, 8 Artificial Capable Intelligence, 9 SOTA LLMs as Generalists. 본문의 번호 지정이 정확합니다.

**V-3. 원리 4의 이름과 진술문 — 확정**
- 대상: 본문 `:25`, `:27`.
- 확인 방법: 같은 HTML 3절 "Defining AGI: Six Principles" 조회.
- 결과: 표제는 `"4. Focus on Potential, not Deployment."`이고 본문이 인용한 `"Focus on Potential, not Deployment"`는 번호와 종지부를 뺀 이름 부분과 축자 일치. 진술문 `"Demonstrating that a system can perform a requisite set of tasks at a given level of performance should be sufficient for declaring the system to be an AGI; deployment of such a system in the open world should not be inherent in the definition of AGI."` 축자 일치.

**V-4. 4절과 5절 인용 — 확정**
- 대상: 본문 `:33`, `:37`.
- 확인 방법: 같은 HTML 4절, 5절 조회.
- 결과: `"While theoretically an 'Expert' level system, in practice the system may only be 'Competent,' because prompting interfaces are too complex for most end-users to elicit optimal performance."` 축자 일치. `"It is impossible to enumerate the full set of tasks achievable by a sufficiently general intelligence."` 축자 일치.

**V-5. Charter 정의 문장의 출처 귀속 — 확정(2차 출처로 확정, 1차는 확인 불가)**
- 대상: 본문 `:45` 표, `:49`.
- 확인 방법: ① `https://openai.com/charter/` 직접 조회를 **재시도**했습니다. WebFetch **HTTP 403**, 브라우저 User-Agent를 준 `curl -L`도 **HTTP 403**. `web.archive.org` 경유도 이 환경에서 차단돼 사용할 수 없었습니다. ② 대신 `https://arxiv.org/html/2311.02462v5` 사례 연구 6을 조회.
- 결과: 논문이 `OpenAI's charter defines AGI as 'highly autonomous systems that outperform humans at most economically valuable work' (OpenAI, 2018).`로 축자 인용하고 있음을 확인. 따라서 본문이 출처를 **"Charter를 인용한 Morris 등"**으로 달고 403 사실을 밝힌 현재 서술이 정확합니다. 논문의 인용 표기는 연도(2018)까지만이므로 **게시월 2018-04는 여전히 2차 출처 기준**이며 본문도 그렇게 적고 있습니다.
- 처리: writer가 남긴 `(확인 필요: 발행 전 Charter 직접 접근을 한 번 더 시도해 1차 확인으로 승격할 수 있는지)` 플래그를 **제거**했습니다. 재시도했고 실패했으므로 플래그가 더 살아 있을 이유가 없고, 서술은 그대로 유지했습니다. 미해결 질문 1은 이것으로 닫힙니다.

**V-6. 2025-10-28 Microsoft 발표문의 두 인용 — 확정**
- 대상: 본문 `:53`, `:57`.
- 확인 방법: `https://blogs.microsoft.com/blog/2025/10/28/the-next-chapter-of-the-microsoft-openai-partnership/` 조회(2026-09-08). 본문 불릿 전문을 받아 대조.
- 결과: `"Once AGI is declared by OpenAI, that declaration will now be verified by an independent expert panel."` 축자 일치.
- ⚠️ `:57`의 인용은 **생략 부호가 있는 인용**입니다. 원문 전문은 `"Microsoft's IP rights to research, defined as the confidential methods used in the development of models and systems, will remain until either the expert panel verifies AGI or through 2030, whichever is first. Research IP includes, for example, models intended for internal deployment or research only. Beyond that research IP does not include model architecture, model weights, inference code, finetuning code, and any IP related to data center hardware and software; and Microsoft retains these non-Research IP rights."`이고, 본문은 첫 문장에서 동격절 `, defined as the confidential methods used in the development of models and systems,`를 `...`로 표시해 생략했습니다. 표시된 생략이라 은폐가 아니며 문장의 뜻도 보존되지만, 전문을 여기 남겨 두어 되짚을 수 있게 합니다.

**V-7. ★ 2025-10-28 발표문에서 매출 배분 자체가 AGI 검증에 걸려 있었다는 사실 — 확정(신규 확인)**
- 대상: 본문 `:63`("판정 대상이던 것이 무관하다고 명시된 항목으로 바뀌고, 그 자리를 날짜가 대신했습니다")의 근거 보강.
- 확인 방법: 위와 같은 조회에서 불릿 전수 확인.
- 결과: 2025-10-28 발표문에 다음 불릿이 있습니다. 원문 그대로 `The revenue share agreement remains until the expert panel verifies AGI, though payments will be made over a longer period of time.` 즉 2025-10-28에는 **매출 배분 조건 자체가 expert panel의 AGI 검증에 걸려** 있었고, 2026-04-27에는 같은 항목이 `independent of OpenAI's technology progress` + `through 2030`으로 바뀝니다. 본문 `:63`의 진술이 **동일 항목에서 성립**함을 확인했습니다.
- 참고: 본문은 `:57`에서 IP 조항 쪽을 인용하고 `:61`에서 매출 배분 쪽을 인용해 서로 다른 항목을 나란히 놓았습니다. 위 불릿을 쓰면 같은 항목에서 게이트가 날짜로 바뀐 것을 보일 수 있습니다. 사실 오류가 아니므로 본문은 손대지 않았고, 채택 여부는 사용자와 writer의 판단으로 남깁니다.

**V-8. 2026-04-27 Microsoft 발표문의 인용과 "언급 없음" — 확정**
- 대상: 본문 `:47` 표, `:59`, `:61`, 각주 `[^ms2026]`.
- 확인 방법: `https://blogs.microsoft.com/blog/2026/04/27/the-next-phase-of-the-microsoft-openai-partnership/` 조회(2026-09-08). 본문 전문을 받아 `AGI`와 `expert panel` 문자열을 조회.
- 결과: 본문 전체에 `AGI` **0건**, `expert panel` **0건**. 인용문 `"Revenue share payments from OpenAI to Microsoft continue through 2030, independent of OpenAI's technology progress, at the same percentage but subject to a total cap."` 축자 일치. 게시일 2026-04-27 일치. 각주가 "이 문서 본문에서 조회한 결과이며 계약 원문에 대한 진술이 아니다"로 범위를 밝힌 것이 정확합니다.

**V-9. OpenAI 측 2026-04-27 발표문 — 확인 불가**
- 대상: 미해결 질문 2.
- 확인 방법: `https://openai.com/index/next-phase-of-microsoft-partnership/`를 WebFetch로 조회 **HTTP 403**, 브라우저 User-Agent를 준 `curl -L`도 **HTTP 403**. `web.archive.org` 경유는 이 환경에서 차단. 웹 검색으로는 문서의 존재와 2차 보도만 확인되고 원문 본문은 확보하지 못했습니다.
- 결과: **확인 불가.** 따라서 본문의 인용 범위가 "Microsoft 공식 블로그"로 한정된 현재 상태가 유지되어야 합니다. 본문 `:46`, `:47` 표의 문서 칸, `:59`, `:65` 모두 "Microsoft 공식 블로그"로 명시돼 있음을 확인했습니다. OpenAI 측 문구를 근거로 한 서술은 본문에 **하나도 없습니다.**

**V-10. ★ 인용 범위 전수 감사(미해결 질문 3) — 확정**
- 대상: 본문 전체.
- 확인 방법: 초안에서 `계약`, `조항`, `발표문` 세 낱말을 전수 조회(`grep -n`)해 한 건씩 문맥을 읽었습니다.
- 결과: `계약`은 5회 나오는데 `:65`(범위 진술, "계약에서 AGI 조항이 빠졌다"를 **쓸 수 없다고 부정하는** 문장), `:107`(이 저장소의 계약 테스트), `:230`(#16이 못박은 하네스 계약, 커밋 인용문 안), `:328`(루브릭의 "워크플로우 계약", 인용문 안), 각주 `[^ms2026]`(계약 원문에 대한 진술이 아님을 밝히는 문장)입니다. **OpenAI와 Microsoft의 계약 내용을 주장하는 용례는 0건.** `조항`은 3회이고 `:65`(부정문 안), `:314`, `:352`는 모두 하네스 에이전트 정의의 조항을 가리킵니다. `:391` 결말도 "발표문은 여섯 달 뒤 그 절차째로 그 단어를 지웠습니다"로 발표문에 한정돼 있습니다. **본문이 발표문에서 계약으로 넓힌 자리는 없습니다.**

**V-11. METR RCT 인용 세 건과 서지 — 확정**
- 대상: 본문 `:204`, `:206`, `:208`, `:212`, `:214`, 각주 `[^metr]`.
- 확인 방법: `https://arxiv.org/abs/2507.09089` 조회(2026-09-08). 초록 전문과 제출 이력을 받아 대조.
- 결과: 세 인용 모두 축자 일치. `"Before starting tasks, developers forecast that allowing AI will reduce completion time by 24%. After completing the study, developers estimate that allowing AI reduced completion time by 20%. Surprisingly, we find that allowing AI actually increases completion time by 19%--AI tooling slowed developers down."` / `"16 developers with moderate AI experience complete 246 tasks in mature projects on which they have an average of 5 years of prior experience."` / `"Although the influence of experimental artifacts cannot be entirely ruled out, the robustness of the slowdown effect across our analyses suggests it is unlikely to primarily be a function of our experimental design."` 저자 4인, v1 2025-07-12, v2 2025-07-25 모두 각주와 일치. 초록의 `"AI tools at the February-June 2025 frontier"`가 본문 `:206`의 "2025년 초 프론티어 모델"과 어긋나지 않습니다. 후속 연구 언급은 본문에 없습니다(미해결 질문 6 준수).

**V-12. 2차 출처를 넣지 않았다는 것 — 확정**
- 대상: 미해결 질문 4, 5.
- 확인 방법: 초안에서 `1,000억`, `1000억`, `380억`, `The Information`, `CNBC` 조회.
- 결과: 전부 0건. `:65`가 "그 무렵 보도된 이익 기준 수치나 상한 금액도 넣지 않았습니다"로 명시하고 Willison 정리를 각주로만 답니다. 미해결 질문 4, 5의 지시를 지켰습니다.

### B. 내부 근거 (I 계열)

**V-13. 이슈 #26 인용 4건 — 확정**
- 확인 방법: `gh issue view 26`으로 본문 원문을 받아 문자 단위 대조.
- 결과: 검토 인용(`rouge 주석색 #999988 대비 ≈2.8:1(AA 미달) ... 링크색 teal(#008080)은 ≈4.8:1로 AA 통과`), 반박문, `grep -oE` 두 줄과 그 출력 블록, 결론문 모두 **축자 일치**. 생성일 2026-07-17로 본문 `:77`과 일치.
- 수치: 이슈 표의 `#1ABC9C` = **2.41:1**, 접근 절의 `#117964`(5.33:1) 모두 본문 `:101`과 일치. 검토가 적은 `≈4.8:1`도 이슈 인용문 그대로입니다.

**V-14. 이슈 #30 인용 3건과 대조표 — 확정**
- 확인 방법: `gh issue view 30`으로 본문 원문을 받아 대조.
- 결과: 대조표 두 칸(`refute_match %r{"url": "/blog//"}, search` / `refute_match(%r{"url": "/blog//}, search)`), 판단문, "처음부터 잘못 옮긴 것" 문장 모두 **축자 일치**. 생성일 2026-07-17로 `:107`의 "같은 날"과 일치.
- 추가 실물 확인: 이슈가 근거로 든 커밋을 직접 열었습니다. `git show 1574064:test/site_output_test.rb | grep -n 'blog//'` → `33:      refute_match(%r{"url": "/blog//}, search)`. 커밋 `1574064`(2026-07-13)가 실재하고 **표의 "실제" 칸이 그 시점 파일과 문자 단위로 일치**함을 이슈 본문에 의존하지 않고 확인했습니다.

**V-15. 이슈 #16 인용 2건 — 확정**
- 확인 방법: `gh issue view 16`으로 본문 원문을 받아 대조.
- 결과: `verifier가 검증해 확정했지만 **그 흔적을 어디에도 남기지 않았다.**` 축자 일치. `**사실 오류는 아니다 — 추적성 문제다**`는 이슈에서 `## ` 표제로 쓰인 문자열이고 본문은 블록인용으로 옮겼습니다(문자는 동일, 마크다운 레벨만 다름). 생성일 2026-07-17로 본문 `:218`과 일치. 본문 `:226`이 요약한 규칙("본문의 외부 인용은 리서치 노트에 반드시 존재해야 하고, 검증 결과는 노트에 남긴다")은 이슈의 "할 일" 세 번째 항목과 일치합니다.

**V-16. 커밋 `29bf70f` — 교정 1건**
- 확인 방법: `git log -1 --format=%B 29bf70f`로 커밋 메시지 전문을 조회.
- 발견: `29bf70f`는 PR #3을 스쿼시 머지한 커밋이고 **제목 줄은 `블로그 파이프라인 정비: 리서치·검증 단계 추가 + 발행 정책 Issue-Driven화 (#3)`** 입니다. 초안이 "커밋 메시지 원문"이라 부른 문자열은 제목이 아니라 **메시지 본문 13번째 줄**이고, 원문에는 앞에 `* `가 붙어 있습니다.
- 처리: 본문을 교정했습니다. "커밋 메시지 원문은 ..."을 "여러 작업을 묶어 머지한 커밋이라 정정은 메시지 본문의 한 줄로 들어가 있습니다. 그 줄 원문은 `* docs: CLAUDE.md 이력 정정 — 'Chirpy archived' 오기 바로잡음 (실제로는 Type Theme가 archived)`입니다."로 바꿔 `* `까지 살렸습니다. **하필 이 글이 "문자 단위 대조"를 논거로 쓰는 절이라 그대로 둘 수 없었습니다.**

**V-17. 정정 전후 `CLAUDE.md` 원문과 엿새라는 간격 — 확정**
- 확인 방법: `git show 29bf70f^:CLAUDE.md`와 `git show 29bf70f:CLAUDE.md`를 각각 조회해 해당 표 행을 대조. 테마 교체 커밋은 `git log --all`로 조회.
- 결과: 정정 전 `Chirpy 저장소는 archived 상태라 유지보수 대신 교체 선택` 축자 존재(변경 이력 표 셀의 괄호 안). 정정 후 `⚠️ 당시 사유로 적은 "Chirpy가 archived"는 오기 — 2026-07-13 GitHub API 확인 시 Chirpy는 활성(v7.6.0)·오히려 Type Theme가 archived(2025-07-26)였음. 실제 교체 근거는 디자인/컨셉 적합성` 축자 존재. 테마 교체는 `75e1f63`(2026-07-07), 정정은 `29bf70f`(2026-07-13)이므로 **엿새 뒤가 맞습니다**.

**V-18. 커밋 `8cdfc8f` 인용 — 확정**
- 확인 방법: `git log -1 --format=%b 8cdfc8f`로 본문 조회.
- 결과: 본문 `:228-230`의 세 줄이 커밋 메시지 첫 문단과 **축자 일치**(줄바꿈 위치까지 동일). 날짜 2026-09-08 일치.

**V-19. #16에서 #101까지의 간격 — 교정 1건**
- 확인 방법: #16 생성일 2026-07-17T12:37:51Z, 커밋 `8cdfc8f` 2026-09-08. 일수를 셌습니다. 7월 14일 + 8월 31일 + 9월 8일 = **53일**.
- 발견: 초안이 두 곳(`:226`, `:232`)에서 "7주"라고 적었으나 7주는 49일이고 실제는 53일(7주 4일)입니다.
- 처리: 두 곳 모두 "일곱 주 남짓"으로 교정했습니다. 자릿수가 어긋나는 수치를 이 글이 그대로 싣는 것은 논지와 충돌합니다.

**V-20. 하네스 책 리뷰 노트의 라운드별 결과 요약줄 다섯 개 — 확정**
- 확인 방법: `_drafts/harness-engineering-book-overview.research.md`에서 `grep -n "결과 요약"`으로 다섯 줄을 행 번호와 함께 추출해 본문 표와 대조. 파일 총 행수는 `wc -l`.
- 결과: `:432` 7건 / `:526` 6건 / `:622` 2건 / `:699` 1건 / `:792` 3건. 본문 표의 **행 번호와 문자열이 모두 일치**합니다. 7 → 6 → 2 → 1 → 3이 맞습니다. 파일 869줄도 본문 `:144`, `:388`과 일치.

**V-21. ★ 라운드별 검증 대상 초안이 달랐다는 한계 진술(미해결 질문 8) — 확정, 인용 1건 교정**
- 확인 방법: 같은 노트에서 `grep -n "검증 대상"`으로 다섯 라운드의 헤더를 전부 추출해 본문 `:156-160`과 대조.
- 결과: 원문 헤더는 이렇습니다. `:428` 1차는 초안 경로만. `:522` 2차 "발행본(`_posts/2026-07-29-harness-engineering-book-overview.md`)을 writer가 노트의 미사용 소재로 보강한 판". `:617` 3차 "사용자 피드백(...)에 따라 blog-writer가 **구조만** 재작성한 판". `:694` 4차 "Fable 모델의 두 차례 독립 피드백(...)을 반영해 blog-writer가 절 순서·서두 방식을 재작성한 판". `:787` 5차 "`_drafts/harness-engineering-book-overview.md` (4차 절 순서·서두 재작성본 = 4차 라운드와 동일한 초안). 기준선은 발행본 `_posts/2026-07-29-harness-engineering-book-overview.md`."
- 확정: **"같은 것을 다시 봤는데 더 나왔다"가 엄밀히 성립하는 구간이 4차 → 5차뿐**이라는 본문의 한계 진술이 정확합니다. 5차 헤더만 "4차 라운드와 동일한 초안"을 명시하고 나머지 넷은 서로 다른 판을 대상으로 합니다. 본문 `:160`이 "앞 구간은 초안이 바뀌었으니 애초에 단조 감소를 기대할 이유가 약합니다"까지 적어 과장을 막고 있습니다. 본문 `:158`의 5차 헤더 인용도 축자 일치(뒤 문장에서 끊었을 뿐 고친 곳 없음).
- 교정: 본문 `:156`이 2차 헤더를 `"발행본을 writer가 노트의 미사용 소재로 보강한 판"`으로 따옴표에 넣었는데, 원문은 "발행본(`_posts/...`)을 writer가 ..."라서 **따옴표 안에서 괄호가 빠진 상태**였습니다. `2차는 발행본을 "writer가 노트의 미사용 소재로 보강한 판"이고`로 고쳐 따옴표 안이 원문의 연속된 부분문자열이 되게 했습니다. `CLAUDE.md` #30이 금지한 바로 그 형태이고, 이 글 안에서 #30을 인용하는 절 바로 뒤라 더 그렇습니다.

**V-22. 5차 라운드의 뒤집기 기록 인용 6건 — 확정, 노트 행 번호 2건 교정**
- 확인 방법: 같은 노트에서 인용된 문자열을 `grep -n`으로 직접 찾아 행 번호를 다시 매기고 문자 단위로 대조.
- 결과(전부 축자 일치):
  - 본문 `:164`(4차 64번 뒤집기) → 실제 위치 `:801`. 원문은 "- **선행 기록 정정 2건 — 재사용 금지:** ① **4차 검증 기록 64번**은 ..."로 시작하고 본문은 ① 이후의 연속된 부분을 옮겼습니다.
  - 본문 `:168`(1차 14번 뒤집기) → `:637` 축자 일치.
  - 본문 `:172`(5차가 밝힌 방침) → `:788` 축자 일치.
  - 본문 `:180`(70번 확인 방법, `grep -c -F` 히트 0건) → **실제 위치 `:798`**. 이 노트의 I-7이 `:800`으로 적었으나 `:800`은 교정 내용 줄입니다. 본문은 행 번호를 달지 않아 발행본에는 영향 없음.
  - 본문 `:184`(내부 닫는 따옴표 삭제) → **실제 위치 `:799`**. I-7이 `:802`로 적었으나 `:802`는 빈 줄입니다. 본문은 행 번호를 달지 않아 발행본에는 영향 없음.
  - 본문 `:190`(74번 전수 확대) → `:824` 축자 일치.
  - 본문 `:196`("전량 대조"의 실제 범위) → `:631` 축자 일치.
- 교정: **이 노트 I-7의 행 번호 `:800`과 `:802`를 각각 `:798`과 `:799`로 정정합니다.** 노트가 근거 좌표를 틀리게 들고 있으면 다음 사람이 되짚을 때 어긋납니다.
- 부수 확정: 70번 항목의 표제는 `**70. ★ 마이그레이션 팀 인용 — 원문의 내부 닫는 따옴표를 지워 없는 문자열을 인용으로 제시한 것 (4차 64번 판정 뒤집음)**`(`:796`), 74번은 `**74. 인라인 인용부호 문자열 50건 전수 대조 — 70번 외 추가 이탈 없음**`(`:822`)로, 본문이 "70번", "74번"이라 부른 것이 맞습니다.

**V-23. flowcast `validate_rendered_pairs.py` docstring 인용 3건 — 확정**
- 확인 방법: `~/.claude/plugins/cache/flowcast/flowcast/0.20.0/scripts/validate_rendered_pairs.py`를 행 번호와 함께 출력해 대조.
- 결과: 본문 `:247-253` 코드 블록은 파일 `:2-7`과 **축자 일치**(줄바꿈 위치 포함). 본문 `:257`("drawer 가 구간을 쪼개...")는 `:11-12`, 본문 `:263`("불일치는 자동 수정하지 않는다...")는 `:18-19`와 축자 일치(원문 줄바꿈만 이어 붙임).

**V-24. `#88 · #94`가 flowcast 저장소 이슈라는 것(미해결 질문 7) — 확정**
- 확인 방법: `gh issue view 88 -R SeokRae/flowcast`, `gh issue view 94 -R SeokRae/flowcast`.
- 결과: #88 `feat: 2축 페어 번호가 렌더 결과와 대조되지 않는다 — rendered_numbers 도입`, #94 `fix: source 계보 미강제 + unit.title 소비처 미정의`. 둘 다 실재하고 docstring의 맥락과 일치합니다. 본문 `:244`가 "이 블로그 저장소가 아니라 flowcast 저장소의 이슈 번호"라고 밝힌 것이 정확합니다.

**V-25. `scan-sensitive.sh:5-6` — 확정**
- 확인 방법: 같은 플러그인의 `scripts/scan-sensitive.sh`를 행 번호와 함께 출력.
- 결과: `:5` `# push / 공개 / CI 에서 이 스크립트가 0건(exit 0)일 때만 통과한다.`, `:6` `# 한 건이라도 매치되면 exit 1 로 파이프라인을 세운다.` **행 번호와 문자 모두 일치.**

**V-26. `cohesion_check.py` docstring `:4-6` — 확정**
- 확인 방법: `~/.claude/plugins/cache/sr-blog-harness/sr-blog-harness/0.1.0/scripts/cohesion_check.py`를 행 번호와 함께 출력.
- 결과: `:4-6`이 "판정하지 않는다. 주제열(각 문장의 첫 어절)과 문단 크기, 나열 위치, 예고 사슬을 사람이 볼 수 있게 펼쳐 놓을 뿐이다. 한국어 문장 분리와 어절 추출은 근사치이므로 플래그가 붙었다고 문제인 것도, 안 붙었다고 통과인 것도 아니다."로 **행 번호와 문자 모두 일치.**

**V-27. `sr-harness` `CLAUDE.md:20-32` 블록 — 확정**
- 확인 방법: `~/.claude/plugins/cache/sr-harness/sr-harness/0.26.0/CLAUDE.md`를 행 번호와 함께 출력.
- 결과: 본문 `:283-296` 코드 블록이 파일 `:20-32`와 **행 단위로 정확히 일치**합니다. 표제, 네 기준 표, 마지막 문장까지 전부 축자.

**V-28. ★ `disable-model-invocation` 6개와 전체 스킬 25개 — 확정(직접 계수)**
- 확인 방법: 문서가 선언한 값을 믿지 않고 실물을 셌습니다. `grep -l "disable-model-invocation" */SKILL.md` → `abort` `goal` `meta` `ralph` `finish` `release` 여섯 건. 같은 명령에 `| wc -l` → **6**. `ls -d */SKILL.md | wc -l` → **25**. 각 파일 `:4`가 `disable-model-invocation: true`임도 확인. `.claude-plugin/plugin.json`의 `version` → **0.26.0**.
- 결과: 본문 `:298`의 "여섯 개", "전체 스킬은 25개", "플러그인 0.26.0 기준" 모두 정확. `CLAUDE.md:23`이 선언한 목록(`ralph`, `goal`, `release`, `finish`, `abort`, `meta`)과 실물 집합이 일치하므로 본문 `:298`의 "문서의 목록과 실물이 일치합니다"도 정확합니다.
- 참고: `grep -l`의 출력 **순서**는 디렉터리 순서라 환경에 따라 달라집니다(이 환경에서는 abort, goal, meta, ralph, finish, release). 본문은 여섯 개의 집합만 주장하고 순서를 근거로 쓰지 않으므로 그대로 두었습니다.
- 전체 25개 목록: abort, analyze, brainstorm, debug, dev-architecture, dev-coding-principles, dev-documentation-principles, dev-monitoring-design, dev-stack-java, dev-testing-conventions, dev-testing-strategy, execute, finish, goal, issue, meta, ownership-principles, pause, plan, ralph, release, review, start, submit, verify.

**V-29. `CLAUDE.md:34-35`의 플래그 강도 문장 — 확정**
- 결과: 본문 `:306` 인용이 파일 `:34-35`와 축자 일치(원문 줄바꿈만 이어 붙임).

**V-30. `evals/rubric.md` 인용 5건 — 확정**
- 확인 방법: 같은 플러그인의 `evals/rubric.md`를 행 번호와 함께 출력해 대조.
- 결과: 본문 `:324` → 파일 `:7` 축자 일치. 본문 `:328` → `:9` 축자 일치. 본문 `:332` → `:66`의 마지막 문장 축자 일치. 본문 `:334` → `:73` 축자 일치. 본문 `:338` → `:47` 축자 일치. 본문이 단 행 번호 `:66`, `:73`, `:47` **전부 정확**합니다.

**V-31. `ownership-principles/SKILL.md:15` — 확정**
- 결과: 파일 `:15`가 `- 사람 개입 없이 반복하는 구간(ralph·goal)일수록 outer loop 체크포인트를 매 반복 명시적으로 남긴다 — 자동 반복이 outer loop 자체를 지워버리면 안 된다`로 본문 `:344`와 **행 번호까지 일치**. 이 노트 I-12가 경고한 중복 회피(`:8`과 `:21`은 테스트 기준 3편이 이미 인용)도 지켜져, 본문은 `:15` 하나만 씁니다.

**V-32. 블로그 하네스 `README.md:19` — 확정**
- 결과: 파일 `:19`가 "발행은 Issue → feature 브랜치 → PR(`Closes #N`)까지만 자동화한다. **main 직접 push·자동 merge는 하지 않는다 — merge는 사용자가 한다.**"로 본문 `:312`와 **행 번호까지 일치**.

**V-33. `agents/blog-publisher.md:12` — 확정(부분 인용임을 명시)**
- 확인 방법: 파일 `:12`를 그대로 출력.
- 결과: 본문 `:316`의 인용문은 `:12` 안에 **문자 그대로 존재**합니다. 다만 `:12`는 긴 한 항목이고 전문은 "2. **발행 전 정리(sanitize) 후 이동.** ... 그리고 본문에 눈에 보이는 미해소 마커 `(확인 필요)`가 남아 있으면 **이동·발행하지 말고 중단**해 사용자에게 보고한다 — 검증이 끝나지 않은 내용을 공개하는 것이다(Phase 1.5로 되돌림). ..."입니다. 본문은 앞의 "그리고 "와 뒤의 부연을 잘라 냈을 뿐 인용 구간 안을 고치지 않았습니다.
- ⚠️ **본문 `:316`의 `(확인 필요)` 문자열은 미해소 마커가 아니라 이 인용문의 일부입니다.** publisher가 발행 전 마커를 조회할 때 오탐할 수 있으니 지우지 마세요.

**V-34. `agents/blog-verifier.md:37`, `agents/blog-editor.md:17`, `:86` — 확정**
- 결과: 세 인용 모두 **행 번호와 문자가 정확히 일치**합니다. verifier `:37`은 "- **문체·구조·표현은 건드리지 않는다.** ...", editor `:17`은 "- **내용을 추가·삭제·왜곡하지 않는다.** ...", editor `:86`은 "- 기술적으로 틀린 것 같은 문장을 발견해도 임의로 고치지 않는다. ...".

**V-35. `analyze/SKILL.md` 인용 3건 — 확정**
- 결과: 본문 `:368` → 파일 `:8` 축자 일치. 본문 `:372-375` 역할 분리 표 → 파일 `:13-16` 축자 일치. 본문 `:379` → 파일 `:18` 축자 일치. 본문이 단 행 번호 `:8`, `:18` 모두 정확합니다.

**V-36. 파이프라인이 다섯 단계라는 것 — 확정**
- 결과: 블로그 하네스 `README.md:11-17` 표가 0.5 근거 수집 → 1 초안 → 1.5 사실 검증 → 2 윤문 → 3 발행 다섯 단계를 정의합니다. 본문 `:350`과 일치.

**V-37. 내부 링크 두 건 — 확정**
- 확인 방법: `_posts/` 목록과 기존 포스트의 내부 링크 형식을 대조.
- 결과: `_posts/2026-07-29-harness-engineering-book-overview.md`와 `_posts/2026-08-11-test-standards-3-delegating-standards.md` 실재. 본문 `:385`, `:389`의 URL 형식(`/blog/YYYY/MM/DD/slug.html`)이 기존 발행본이 서로를 가리킬 때 쓰는 형식과 동일합니다.

**V-38. 소주제 이름 세 개 — 표기 유지**
- 확인 방법: 본문 `:13` 도입부 예고, `:17`/`:71`/`:236` 소제목, `:401` 작성자 노트 주석을 대조.
- 결과: `판정하는 대신 지운 단어` | `그럴듯하게 틀린 자리` | `모델이 좋아져도 안 옮겨지는 자리` 세 이름이 네 자리에서 **동일 표기로 일치**합니다. 사실로 틀린 부분이 없으므로 표기를 바꾸지 않았습니다(`agents/blog-verifier.md:38` 준수).

### C. 1차 라운드의 확인 불가 (2건) — ⚠️ 2차 라운드에서 **모두 해소됨**, D절 참조

1. **OpenAI Charter 원문 1차 확인** (V-5). `openai.com/charter/`가 WebFetch와 `curl` 모두 HTTP 403이고 `web.archive.org`도 이 환경에서 차단됩니다. 본문은 출처를 "Charter를 인용한 Morris 등"으로 달고 403 사실을 밝히고 있어 현재 서술이 정확합니다. 게시월 2018-04는 2차 출처 기준임도 본문에 적혀 있습니다. **추가 조치 없이 발행 가능하지만, 이 상태를 사용자가 알고 있어야 합니다.**
2. **OpenAI 측 2026-04-27 발표문** (V-9). 같은 이유로 403입니다. 본문은 인용 범위를 "Microsoft 공식 블로그"로 한정했고 OpenAI 측 문구에 기대는 서술이 없으므로 **논지에 구멍이 생기지 않습니다.**

두 건 모두 접근 차단이 원인이고 본문 서술은 그 한계 안에 머물러 있습니다.

⚠️ **위 두 항목은 2차 라운드에서 원문을 확보해 해소됐습니다.** 기록을 지우지 않고 남겨 둡니다. 무엇을 못 봤고 그 상태에서 본문을 어떻게 좁혀 뒀는지가, 나중에 원문을 봤다는 사실만큼이나 되짚을 값어치가 있기 때문입니다.

---

### D. 2차 라운드 (2026-09-08, 브라우저 직접 조회)

**이 라운드의 성격:** 1차에서 HTTP 403으로 못 본 openai.com 두 문서를 실제 Chrome 세션으로 열어 본문을 받았습니다. 팀 리드가 먼저 확보해 알려 줬지만 **그 보고를 근거로 삼지 않고 verifier가 같은 두 페이지를 직접 열어 다시 받았습니다.** 이 글의 논지가 "보고 대신 조회"이므로 보고를 근거로 확정하면 글이 자기 주장을 어깁니다.

**V-39. ★ OpenAI Charter 원문 — 1차 출처로 승격, 초안 교정**
- 확인 방법: 브라우저로 `https://openai.com/charter/` 를 열어 본문 텍스트 전문을 추출(2026-09-08). WebFetch와 `curl`은 여전히 403이고, 브라우저 세션에서만 열립니다.
- 원문 그대로: `OpenAI's mission is to ensure that artificial general intelligence (AGI)—by which we mean highly autonomous systems that outperform humans at most economically valuable work—benefits all of humanity.`
- ★ **발견:** 흔히 인용되는 그 문구는 **독립된 정의 조항이 아니라 미션 문장 안에 `by which we mean`으로 삽입된 동격절**입니다. Morris 등의 인용(`OpenAI's charter defines AGI as '...'`)은 발췌로서 정확하지만, 원문에서 이것이 정의 조항의 형태를 갖고 있지는 않습니다. 이 차이는 이 글의 논지에 유리한 방향이라 오히려 조심해서 적었습니다.
- 게시일: **여전히 확인 불가.** 페이지 본문에 게시일 표기가 없고 `This document reflects the strategy we've refined over the past two years.` 만 있습니다. 그래서 2018-04는 2차 출처 기준이라는 단서를 유지했습니다.
- 처리: 본문 `:49-53`을 1차 확인으로 갱신하고 원문 블록인용을 넣었습니다. "403으로 실패했다", "출처는 Charter가 아니라 Morris 등이다"는 서술은 더 이상 사실이 아니므로 제거했습니다. 각주 `[^charter]`를 신설했습니다.
- ⚠️ 인용문의 em dash 두 개는 **원문 그대로**입니다. 이 블로그의 em dash 금지는 저자의 산문에 적용되는 규칙이고 인용문에는 `CLAUDE.md` #30(원문 그대로)이 우선합니다.
- **쓰지 않기로 한 재료:** 같은 문서의 `We will work out specifics in case-by-case agreements, but a typical triggering condition might be "a better-than-even chance of success in the next two years."` 는 판정 조건이 `might be` 예시로만 적혀 있다는 점에서 이 글의 논지와 맞물립니다. 다만 이 조건은 **AGI 선언의 판정 조건이 아니라 "다른 프로젝트가 근접하면 경쟁을 멈추고 돕는다"는 약속의 발동 조건**입니다. 둘을 나란히 놓으면 독자가 AGI 판정 절차로 읽을 수 있어 넣지 않았습니다. 필요하면 이 구분을 명시한 채로만 쓰세요.

**V-40. `:61` 표시된 생략 제거 — 초안 교정**
- 처리: 사용자 결정에 따라 `Microsoft's IP rights to research...will remain` 을 V-6에 남겨 둔 원문 전문으로 교체했습니다. 현재 본문 `:61`은 `"Microsoft's IP rights to research, defined as the confidential methods used in the development of models and systems, will remain until either the expert panel verifies AGI or through 2030, whichever is first."` 로 **생략 부호 없이 첫 문장 전체**입니다.

**V-41. 2025-10-28 매출 배분 불릿을 본문에 반영 — 초안 교정**
- 처리: 사용자 결정에 따라 V-7에서 확인한 불릿을 본문 `:63-65`에 넣었습니다. 원문 그대로 `The revenue share agreement remains until the expert panel verifies AGI, though payments will be made over a longer period of time.`
- 효과: 본문 `:71`이 "여섯 달 전 expert panel의 AGI 검증에 걸려 있던 바로 그 항목입니다"로 이어져, **게이트가 날짜로 바뀐 것이 동일 항목에서** 드러납니다. 1차 검증에서 지적한 항목 불일치(IP 조항과 매출 배분을 나란히 놓은 것)가 해소됐습니다.

**V-42. ★ OpenAI 측 2026-04-27 발표문 — 확보, 범위 확대**
- 확인 방법: 브라우저로 `https://openai.com/index/next-phase-of-microsoft-partnership/` 를 열었습니다. 최초 조회는 `/ko-KR/` 로케일로 리다이렉트돼 국문판이 나왔고, 축자 대조를 위해 `/en-US/` 로 다시 열어 영문 원문을 받았습니다.
- 결과: 게시일 `April 27, 2026`. 본문 전체에 **`AGI` 0건, `expert panel` 0건.** 불릿 다섯 개 중 매출 배분 항목은 원문 그대로 `Revenue share payments from OpenAI to Microsoft continue through 2030, independent of OpenAI's technology progress, at the same percentage but subject to a total cap.` 로 **Microsoft 발표문의 같은 불릿과 문구까지 동일**함을 확인했습니다.
- 참고: 두 발표문이 전부 같지는 않습니다. 도입 문단이 OpenAI판은 `flexibility, certainty, and a focus`, Microsoft판은 `flexibility, certainty and a focus`로 쉼표가 다릅니다. **동일하다고 말할 수 있는 것은 매출 배분 불릿이고, 본문도 딱 그것만 주장합니다.**
- IP 불릿 원문(본문 미사용): `Microsoft will continue to have a license to OpenAI IP for models and products through 2032. Microsoft's license will now be non-exclusive.`
- 처리: 본문 `:47` 표를 "Microsoft와 OpenAI 발표문 / 양쪽 모두 언급 없음"으로, `:67`을 "Microsoft와 OpenAI가 각각 낸 발표문 어느 쪽에도"로, `:73` 범위 진술을 "세 발표문의 본문을 봤고", "2026-04-27 양측 발표문 어디에도"로 갱신했습니다. 각주 `[^oai2026]`을 신설했습니다.

**V-43. 계약 원문에 대한 한계는 유지 — 확정**
- 확인 방법: 갱신 후 본문에서 `계약`, `조항`을 다시 전수 조회했습니다(V-10의 재실행).
- 결과: 범위 진술(`:73`)이 여전히 "계약 원문은 보지 못했습니다. 계약은 공개돼 있지 않습니다"로 시작하고 "계약에서 AGI 조항이 빠졌다"를 **쓸 수 없다고 부정**합니다. 각주 `[^ms2026]`과 신설한 `[^oai2026]` 모두 "계약 원문에 대한 진술이 아니다"를 답니다. **양측 발표문으로 넓어졌지만 계약으로는 넓어지지 않았습니다.** 이 글에서 가장 중요한 한 줄이 유지됐습니다.

**V-44. 영문 인용의 활자 정규화 — 확정(전 글 일관), 판단 필요 없음**
- 확인 방법: 초안에서 곡선 아포스트로피(U+2019)와 곡선 큰따옴표(U+201C/U+201D)를 조회.
- 결과: **0건.** 초안은 영문 인용을 전부 직선 부호로 옮깁니다. 원문 쪽은 openai.com과 blogs.microsoft.com 모두 곡선 부호를 씁니다(`OpenAI’s`, `“a better-than-even chance…”`).
- 판단: 이것은 글 전체에 일관되게 적용된 활자 정규화이고, Morris, METR, Microsoft, OpenAI 인용에 똑같이 걸려 있습니다. 낱말과 구두점 배열은 보존되고 글자꼴만 바뀐 것이라 `**` 강조 기호를 뺀 것과 같은 층위로 봤습니다. #30이 문제 삼은 것은 **없는 문자를 넣고 괄호를 뺀** 내용 변경이지 활자 정규화가 아닙니다.
- ⚠️ 다만 이건 verifier가 단독으로 뒤집을 사안이 아닙니다. 곡선 부호로 되돌리려면 **영문 인용 전체**를 함께 바꿔야 하고, 그건 이 한 글이 아니라 발행본 전체에 걸린 표기 규칙 문제입니다. 현재 상태를 유지하고 사실만 여기 남깁니다.

**확인 불가 잔여: 0건.** 다만 Charter **게시일**만은 원문에 표기가 없어 2018-04가 2차 출처 기준으로 남습니다. 본문이 그 단서를 그대로 달고 있으므로 미해소 항목이 아니라 명시된 한계입니다.

---

## 응집 점검 기록

점검 도구는 하네스의 `scripts/cohesion_check.py`이고, 윤문 전과 후에 각각 한 번씩 돌렸습니다. 아래 줄번호는 **윤문 후 초안 기준**입니다.

### 예고 사슬

- 이름 `{판정하는 대신 지운 단어 | 그럴듯하게 틀린 자리 | 모델이 좋아져도 안 옮겨지는 자리}` → H2 소제목 **전부 일치**(`소제목에 없는 이름: 없음`). 도입부 `:13` 예고 문장이 세 이름을 굵게 그대로 부르는 것도 확인했습니다. **표기는 한 글자도 손대지 않았습니다.**
- 스크립트가 "이름에 없는 소제목"으로 뽑은 13개는 전부 H3 하위 절과 마무리 H2(`남는 것과, 이 글이 답하지 못하는 것`)입니다. 소주제 이름 계약의 대상이 아니라 판정에서 제외했습니다.

### 배열을 손본 문단 (4개)

| 위치 | 문제 | 처리 |
|---|---|---|
| `:73` | 범위 진술 7문장 [긴 문단] | 2~3번 문장을 하나로 합치고("계약 원문은 공개돼 있지 않아 보지 못했습니다"), 이익 기준 수치를 뺀 이유는 `:75`로 문단 분리. 5문장 + 2문장 |
| `:39` | 5절 인용(`impossible to enumerate`) 뒤에 그것을 받는 저자 문장이 없어 인용이 허공에 떴음 | 앞 인용 두 개를 받는 연결 문장 한 줄 추가. **새 사실 없음**입니다. 이미 인용된 원리 4와 5절 문장을 그대로 되받는 문장이에요 |
| `:310` | 표를 그대로 다시 나열하는 문장이 표 네 줄 아래 있었음 | 재나열 문장 삭제. 바로 다음 문단(`:312`)이 머지와 태그 push로 구체 예를 드므로 잃는 게 없습니다 |
| `:397` | 결론 6문장 [긴 문단], 마지막 문장이 `:312`의 굵은 문장과 거의 같은 말 | 마지막 문장 삭제. 5문장 |

### 손대지 않기로 한 곳 (3건)

- **`:401` 마무리 문단 6문장 [긴 문단]**: 스크립트에 유일하게 남은 플래그입니다. 실제로는 저자 문장 3개 + 굵은 질문 3개이고, 질문 세 개는 이 글이 도달하려던 목적지라 쪼개면 힘이 빠집니다. 유지.
- **`:55`~`:65` 인용 3연속**: 발표문 인용 사이의 저자 문장이 한 줄씩뿐이지만, 각 한 줄이 "절차를 붙였다 / 기한을 걸었다 / 매출 배분도 걸려 있었다"로 인용마다 다른 일을 지정합니다. 우산 + 항목 배열이 성립하므로 인용을 줄이거나 합치지 않았습니다. 시제만 `붙입니다` → `걸어 뒀습니다`로 앞 문장에 맞췄습니다.
- **`:53`의 Charter 게시일 단서**: 각주 `[^charter]`가 같은 말을 하고 있어 중복이지만, 표(`:45`)의 `2018-04`와 각주가 멀어 본문에서 한 번 짚는 편이 낫다고 봤습니다. 유지.

### 사람 결정 대기

- 없음. 우산 문장이 필요한데 문단 안 정보로 쓸 수 없는 자리는 나오지 않았습니다.

### 문체와 군더더기 (배열 밖)

- **해요체 17곳 → 5곳.** 블로그 전용 규칙(습니다체 기본, 해요체는 리듬 변주로만)에 맞춰 12곳을 습니다체로 되돌렸습니다. 남긴 5곳은 `:77`, `:166`, `:196`, `:269`, `:360`으로, 무거운 인용 뒤에 짧게 끊는 자리에만 뒀습니다.
- **개수 라벨 1건 제거.** 스크립트는 0건으로 봤지만 `:79`의 "남는 질문은 배포 쪽에 있고, 두 개입니다"를 개수 라벨로 보고 "남는 질문은 배포 쪽에 있습니다"로 고쳤습니다. 굵은 질문 두 개가 바로 뒤에 이어지므로 미리 셀 이유가 없습니다.
- **같은 말 반복 제거**: `:132`(안 잡힌다는 말을 두 문장이 각각 함), `:224`(METR 절의 "속도 이야기로 읽으면 안 된다"가 `:216` 경고와 중복), `:242`("일곱 주 남짓"이 `:236`과 붙어서 두 번), `:356`(인용문의 후반부를 그대로 되풀이하던 문장), `:269`("이 문장을 천천히 읽을 만합니다" 같은 독법 지시).
- **em dash와 중간점**: 저자 산문에는 0건입니다. 남은 것은 전부 축자 인용 안입니다. Charter 원문(`:51`), 이슈와 CLAUDE.md 인용(`:93`, `:144`), 커밋 메시지 원문(`:140`, 인라인 코드), flowcast docstring의 `#88 · #94`(`:254`, 인라인 코드), analyze 스킬의 표(`:385`). **#30 규칙대로 손대지 않았습니다.**
- **`(확인 필요)` 문자열**(`:326`)은 `agents/blog-publisher.md:12` 축자 인용 안의 문자열이라 그대로 뒀습니다.

### 검증 기록과의 대조

V-42가 인용한 `:73` 문장을 두 문장에서 한 문장으로 합쳤습니다. 문구는 바뀌었지만 **주장은 그대로**입니다. V-43이 확인한 "계약 원문을 보지 못했다"와 "계약에서 AGI 조항이 빠졌다고 쓸 수 없다"가 합친 뒤에도 각각 문장으로 남아 있는 것을 재조회로 확인했습니다.
