---
name: blog-pipeline
description: "블로그(~/IdeaProjects/blog, SeokRae/blog) 포스트 작성부터 발행까지 파이프라인을 조율하는 오케스트레이터. '블로그 글 써줘', '포스트 작성해줘', '블로그에 올려줘', '블로그 발행해줘', '이 글 블로그에 올려줘' 요청 시 사용. 후속 작업 — '초안 다시 써줘', '윤문만 다시', '발행만 다시', '이전 초안 이어서 발행' 요청 시에도 반드시 이 스킬을 사용한다."
---

# Blog Pipeline Orchestrator

`~/IdeaProjects/blog` (Jekyll + Type Theme, https://seokrae.github.io/blog/) 포스트를 아이디어부터 발행까지 조율하는 오케스트레이터.

## 실행 모드: 서브 에이전트

파이프라인 각 단계가 파일(초안 md)을 순차적으로 넘겨받는 구조라 실시간 팀 통신이 필요 없다. `Agent` 도구로 각 단계를 순서대로 호출한다.

## 에이전트 구성

| 에이전트 | subagent_type | 역할 | 출력 |
|---------|---------------|------|------|
| blog-writer | blog-writer (커스텀) | 주제 → 초안 작성 | `_drafts/{slug}.md` |
| blog-editor | blog-editor (커스텀) | 초안 윤문 | `_drafts/{slug}.md` (in-place) |
| blog-publisher | blog-publisher (커스텀) | 발행 검증 + git push + 배포 확인 | `_posts/{date}-{slug}.md` + 배포 URL |

모든 Agent 호출에 `model: "opus"`를 명시한다.

## 워크플로우

### Phase 0: 컨텍스트 확인

1. `~/IdeaProjects/blog/_drafts/`에 기존 미완성 초안이 있는지, 또는 사용자 요청에 초안 파일 경로가 포함되어 있는지 확인한다
2. 분기:
   - **초안 없음 + 주제만 제공** → Phase 1부터 전체 실행
   - **초안 있음** (사용자가 직접 쓴 글 또는 이전 세션 산출물) → writer를 건너뛰고 Phase 2(editor)부터 시작
   - **"윤문만 다시"/"발행만 다시" 같은 부분 재실행 요청** → 해당 단계만 호출

### Phase 1: 초안 작성 (필요 시)

`Agent(prompt: "{주제/키워드/참고자료}", subagent_type: "blog-writer", model: "opus")`
→ 결과: `_drafts/{slug}.md`

### Phase 2: 윤문

`Agent(prompt: "_drafts/{slug}.md 윤문", subagent_type: "blog-editor", model: "opus")`
→ 윤문된 초안을 사용자에게 보여주고 확인받는다. **발행 전 필수 체크포인트다 — 승인 없이 자동으로 다음 단계로 넘어가지 않는다.**

### Phase 3: 발행

사용자가 승인하면:
`Agent(prompt: "_drafts/{slug}.md 발행", subagent_type: "blog-publisher", model: "opus")`
→ 결과: `_posts/`로 이동, git push, Pages 빌드 확인, 배포 URL 보고

### Phase 4: 결과 보고

- 최종 배포 URL, Pages 빌드 확인 결과, 걸린 시간을 요약 보고한다
- 문제가 발생했으면 어느 단계에서 멈췄는지와 남은 산출물 경로를 명시한다

## 에러 핸들링

| 상황 | 전략 |
|------|------|
| writer/editor 실패 | 1회 재시도. 재실패 시 부분 산출물(있다면)과 함께 사용자에게 보고, 수동 개입 요청 |
| publisher 로컬 빌드 실패 | 절대 자동으로 push하지 않는다 — 에러 로그 보고 후 사용자 확인 대기 |
| publisher Pages 빌드 실패 | push는 이미 완료된 상태이므로 에러 로그를 보고하고 재발행 여부를 사용자에게 확인 |

## 테스트 시나리오

### 정상 흐름
1. 사용자가 "블로그에 'Jekyll Chirpy 세팅기' 주제로 글 써줘" 요청
2. Phase 0: `_drafts/`에 기존 초안 없음 → 전체 실행
3. Phase 1: blog-writer가 `_drafts/jekyll-chirpy-setup.md` 생성
4. Phase 2: blog-editor가 윤문, 사용자에게 확인 요청
5. 사용자 승인 → Phase 3: blog-publisher가 `_posts/2026-07-07-jekyll-chirpy-setup.md`로 이동, push, Pages 빌드 확인
6. Phase 4: 배포 URL과 함께 완료 보고

### 에러 흐름
1. Phase 3에서 로컬 `jekyll build` 실패 (frontmatter 오류)
2. blog-publisher가 에러 로그와 함께 중단, push하지 않음
3. 오케스트레이터가 사용자에게 에러 내용과 `_drafts/{slug}.md` 경로를 보고
4. 사용자가 수정 후 "발행만 다시" 요청 → Phase 3부터 재실행
