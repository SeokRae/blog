# blog

This file provides guidance to Claude Code when working with code in this repository.

> SeokRae.github.io/blog — 인사이트 중심 개발 기술 블로그 (Jekyll + Type Theme). 절차 나열이 아니라 "왜"와 "무엇을 배웠는지"에 초점을 둔다.

## 하네스: 블로그 글쓰기 파이프라인

**목표:** 주제 제시부터 윤문·발행까지 인사이트 중심 블로그 포스트 작성 파이프라인을 자동화한다.

**트리거:** 블로그 글 작성/윤문/발행 요청 시 `blog-pipeline` 스킬을 사용하라. 단순 설정 질문은 직접 응답 가능.

**변경 이력:**
| 날짜 | 변경 내용 | 대상 | 사유 |
|------|----------|------|------|
| 2026-07-07 | 초기 구성 (writer/editor/publisher 파이프라인) | 전체 | - |
| 2026-07-07 | 인사이트 중심 컨셉 반영 (튜토리얼 나열 지양, "왜/교훈" 강조) | `_config.yml`, `agents/blog-writer.md`, `agents/blog-editor.md` | 사용자가 블로그 컨셉을 "인사이트를 위한 글"로 명확화 |
| 2026-07-07 | Chirpy → Type Theme 테마 교체 (사이드바 없는 단일 컬럼, 인사이트 글쓰기 컨셉에 맞춤. Chirpy 저장소는 archived 상태라 유지보수 대신 교체 선택) | `_config.yml`, `Gemfile`, `index.html`/`about.md`/`404.md`/`search.html`/`tags.html`, `.claude/agents/*`, `.claude/skills/blog-pipeline/SKILL.md` | 사용자가 인사이트 중심 컨셉에 맞는 테마로 전환 요청 |
