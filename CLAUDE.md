# blog

This file provides guidance to Claude Code when working with code in this repository.

> SeokRae.github.io/blog — 인사이트 중심 개발 기술 블로그 (Jekyll + Type Theme). 절차 나열이 아니라 "왜"와 "무엇을 배웠는지"에 초점을 둔다.

## 명령어

```bash
bundle install                              # 의존성 설치 (github-pages gem이 Jekyll·플러그인 버전 고정)
bundle exec jekyll serve                    # 로컬 서버 → http://localhost:4000/blog/
bundle exec ruby test/site_output_test.rb   # 사이트 계약 검증 (CI와 동일 · 커밋 전 필수)
```

이 머신에서 jekyll 실행 전 PATH 설정 필요: `export PATH="/opt/homebrew/opt/ruby@3.4/bin:$PATH"` (Ruby 3.4).

## 아키텍처: remote theme + 최소 오버라이드

테마는 `_config.yml`의 `remote_theme`로 **커밋 고정**된 Type Theme다 (재현 가능한 빌드). 저장소의 파일은 같은 경로의 테마 파일을 **shadow**하고, 없는 파일은 고정된 원격 테마로 fall-through한다.

- **로컬 오버라이드 (이 저장소에 있음)**: `_layouts/{default,page,post}.html`, `_includes/{head,header}.html`, `assets/css/main.scss`(`type-theme` import 후 a11y 규칙만 추가), 페이지 파일(`index.html`·`about.md`·`search.html`·`tags.html`·`404.md`).
- **테마 상속 (저장소에 없음 — 여기서 찾지 말 것)**: `_layouts/{home,tags}.html`, `_includes/{footer,icons,tags_list,post_nav,disqus}.html`, `_sass/type-theme.scss`, `assets/js/search.js`.

오버라이드는 특정 계약을 고치려고 존재한다 — 한국어 `lang`, 절대 canonical URL, escape된 description meta, 접근 가능한 검색(`aria-label`), 검색 URL 이중 슬래시 방지, `/blog/page2/` 페이지네이션 경로. 이 계약들은 **`test/site_output_test.rb`에 잠겨 있다.** 오버라이드를 수정하면 계약 assertion이 깨질 수 있으니 반드시 테스트를 돌린다.

## 배포: main 직접 push (글로벌 Issue-Driven 규칙의 예외)

GitHub Pages가 main push 시 네이티브 빌드한다. `.github/workflows/site-check.yml`가 push/PR마다 계약 테스트를 먼저 돌린다. **blog-publisher는 포스트를 main에 직접 push한다 — Issue/브랜치/PR 없이.** 이는 글로벌 CLAUDE.md의 Issue-Driven·PR 워크플로우에 대한 의도된 예외다(개인 블로그, sr-labs vault와 무관한 별도 저장소). 블로그 글에는 Issue나 PR을 만들지 않는다.

## 하네스: 블로그 글쓰기 파이프라인

**목표:** 주제 제시부터 윤문·발행까지 인사이트 중심 블로그 포스트 작성 파이프라인을 자동화한다.

**트리거:** 블로그 글 작성/윤문/발행 요청 시 `blog-pipeline` 스킬을 사용하라. 단순 설정 질문은 직접 응답 가능.

**변경 이력:**
| 날짜 | 변경 내용 | 대상 | 사유 |
|------|----------|------|------|
| 2026-07-07 | 초기 구성 (writer/editor/publisher 파이프라인) | 전체 | - |
| 2026-07-07 | 인사이트 중심 컨셉 반영 (튜토리얼 나열 지양, "왜/교훈" 강조) | `_config.yml`, `agents/blog-writer.md`, `agents/blog-editor.md` | 사용자가 블로그 컨셉을 "인사이트를 위한 글"로 명확화 |
| 2026-07-07 | Chirpy → Type Theme 테마 교체 (사이드바 없는 단일 컬럼, 인사이트 글쓰기 컨셉에 맞춤. Chirpy 저장소는 archived 상태라 유지보수 대신 교체 선택) | `_config.yml`, `Gemfile`, `index.html`/`about.md`/`404.md`/`search.html`/`tags.html`, `.claude/agents/*`, `.claude/skills/blog-pipeline/SKILL.md` | 사용자가 인사이트 중심 컨셉에 맞는 테마로 전환 요청 |
| 2026-07-13 | 명령어·remote theme 오버라이드 아키텍처·main 직접 push 예외 섹션 추가 (`/init`) | `CLAUDE.md` | 신규 Claude 인스턴스 온보딩에 필요한 빌드/검증 명령과 비자명한 구조를 문서화 |
| 2026-07-13 | 파이프라인에 근거 수집(Phase 0.5)·사실 검증(Phase 1.5) 단계 추가 | `agents/blog-researcher.md`, `agents/blog-verifier.md`, `agents/blog-writer.md`, `skills/blog-pipeline/SKILL.md` | writer의 `(확인 필요)` 플래그를 해소할 단계가 없던 구멍을 메움. 내부 근거 1차·외부 검증 2차로 인사이트 컨셉 유지 |
