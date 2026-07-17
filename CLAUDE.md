# blog

This file provides guidance to Claude Code when working with code in this repository.

> SeokRae.github.io/blog — 인사이트 중심 개발 기술 블로그 (Jekyll + Type Theme). 절차 나열이 아니라 "왜"와 "무엇을 배웠는지"에 초점을 둔다.

## 명령어

```bash
bundle install                              # 의존성 설치 (github-pages gem이 Jekyll·플러그인 버전 고정)
bundle exec jekyll serve                    # 로컬 서버 → http://localhost:4000/blog/
bundle exec ruby test/site_output_test.rb   # 사이트 계약 검증 (CI와 동일 · 커밋 전 필수)
node test/search_test.js                    # 검색 매칭 계약 검증 (CI와 동일 · 커밋 전 필수)
```

이 머신에서 jekyll 실행 전 PATH 설정 필요: `export PATH="/opt/homebrew/opt/ruby@3.4/bin:$PATH"` (Ruby 3.4).

## 아키텍처: remote theme + 최소 오버라이드

테마는 `_config.yml`의 `remote_theme`로 **커밋 고정**된 Type Theme다 (재현 가능한 빌드). 저장소의 파일은 같은 경로의 테마 파일을 **shadow**하고, 없는 파일은 고정된 원격 테마로 fall-through한다.

- **로컬 오버라이드 (이 저장소에 있음)**: `_layouts/{default,page,post}.html`, `_includes/{head,header,icons}.html`, `assets/css/main.scss`(`type-theme` import 후 a11y·아이콘 규칙만 추가), `assets/js/search.js`, 페이지 파일(`index.html`·`about.md`·`search.html`·`tags.html`·`404.md`).
- **테마 상속 (저장소에 없음 — 여기서 찾지 말 것)**: `_layouts/{home,tags}.html`, `_includes/{footer,tags_list,post_nav,disqus}.html`, `_sass/type-theme.scss`.

오버라이드는 특정 계약을 고치려고 존재한다 — 한국어 `lang`, 절대 canonical URL, escape된 description meta, 링크 공유용 OG/Twitter 메타, 접근 가능한 검색(`aria-label`), 검색 URL 이중 슬래시 방지, `/blog/page2/` 페이지네이션 경로, **외부 요청 없는 페이지**(스크립트·스타일시트 모두), **WCAG AA 색 대비**. 이 계약들은 **`test/site_output_test.rb`에 잠겨 있다.** 오버라이드를 수정하면 계약 assertion이 깨질 수 있으니 반드시 테스트를 돌린다.

`_includes/icons.html`은 **쓰는 아이콘만** 인라인 SVG로 담는다 — 테마 원본은 20여 개 소셜 서비스를 FontAwesome으로 분기하는데, 그 55KB를 아이콘 3개 때문에 받고 있었다 (#24). ⚠️ `_config.yml`에서 여기 없는 서비스(twitter 등)를 켜도 렌더되지 않으니 아이콘을 함께 추가해야 한다.

`assets/css/main.scss`는 `@import "type-theme"` **전에** `$link-color`·`$search-color`·`$tags-color`를 재정의한다 — 테마 기본값이 WCAG AA 대비에 미달하고, `!default` 변수라 import 전이 정석이다. 값이 박힌 rouge 색은 import 후 규칙으로 덮는다 (#26).

`assets/js/search.js`는 lunr을 쓰지 않는다 — lunr 파이프라인의 trimmer가 `\W`로 토큰을 잘라 **한글 토큰을 빈 문자열로 만들기 때문에** 한국어 질의가 전부 0건이 된다 (#12). 대신 substring 매칭을 쓰고, 이 동작은 `test/search_test.js`에 잠겨 있다. HTML 계약 테스트는 JS 동작을 검증하지 못하므로 검색 로직을 고치면 **두 테스트를 모두** 돌린다.

## 포스트 규칙

frontmatter 필드 순서는 `layout → date → title → subtitle → tags`로 통일한다 (#30).

태그는 **고유명사는 원 표기, 주제는 한국어**다 — `Jekyll`·`GitHub Pages`·`AI`·`flowcast`(소문자가 프로젝트 정식 표기) / `문서화`·`아키텍처`·`회고`. `tags.html` 아카이브가 태그명을 그대로 키로 쓰므로 표기가 흔들리면 같은 주제가 갈라진다.

**본문에서 저장소 코드를 인용할 때는 원문 그대로 옮긴다.** 축약·괄호 생략·정규식 손질 금지. 이 블로그의 결론 중 하나가 "'왜'를 기록할 때 그 안에 섞인 '검증 가능한 사실'은 그 자리에서 검증하라"인데, 인용을 다듬으면 그 자리에서 어긴다 (#30).

발행된 포스트는 **그 시점의 기록**이다. 나중에 코드가 바뀌어 인용과 어긋나도 소급해 고치지 않는다 — 예: Chirpy 편이 인용한 `assert_includes search, 'integrity="sha384-'`는 발행 당시 실재했고 #12에서 제거됐지만 본문은 그대로 둔다. 지금 것으로 바꾸면 "그때 이렇게 했다"는 기록이 거짓이 된다.

## 배포: Issue-Driven + GitFlow (포스트 포함, 예외 없음)

GitHub Pages가 main push(= PR merge) 시 네이티브 빌드한다. `.github/workflows/site-check.yml`가 push/PR마다 계약 테스트를 먼저 돌린다. **모든 작업은 예외 없이 Issue → main에서 feature 브랜치 분기 → PR(`Closes #N`) → merge로 진행한다 — 블로그 포스트도 마찬가지다.** merge가 main에 반영되는 순간 Pages 빌드가 트리거되므로 배포는 그대로 동작한다. blog-publisher도 main에 직접 push하지 않고 feature 브랜치 + PR로 발행하며, merge는 사용자가 한다. (2026-07-13 이전엔 "포스트는 main 직접 push" 예외를 뒀으나 사용자 지시로 폐기 — 글로벌 Issue-Driven 규칙을 그대로 따른다.)

## 하네스: 블로그 글쓰기 파이프라인

**목표:** 주제 제시부터 윤문·발행까지 인사이트 중심 블로그 포스트 작성 파이프라인을 자동화한다.

**트리거:** 블로그 글 작성/윤문/발행 요청 시 `blog-pipeline` 스킬을 사용하라. 단순 설정 질문은 직접 응답 가능.

**변경 이력:**
| 날짜 | 변경 내용 | 대상 | 사유 |
|------|----------|------|------|
| 2026-07-07 | 초기 구성 (writer/editor/publisher 파이프라인) | 전체 | - |
| 2026-07-07 | 인사이트 중심 컨셉 반영 (튜토리얼 나열 지양, "왜/교훈" 강조) | `_config.yml`, `agents/blog-writer.md`, `agents/blog-editor.md` | 사용자가 블로그 컨셉을 "인사이트를 위한 글"로 명확화 |
| 2026-07-07 | Chirpy → Type Theme 테마 교체 (사이드바 없는 단일 컬럼, 인사이트 글쓰기 컨셉에 맞춤. ⚠️ 당시 사유로 적은 "Chirpy가 archived"는 오기 — 2026-07-13 GitHub API 확인 시 Chirpy는 활성(v7.6.0)·오히려 Type Theme가 archived(2025-07-26)였음. 실제 교체 근거는 디자인/컨셉 적합성) | `_config.yml`, `Gemfile`, `index.html`/`about.md`/`404.md`/`search.html`/`tags.html`, `.claude/agents/*`, `.claude/skills/blog-pipeline/SKILL.md` | 사용자가 인사이트 중심 컨셉에 맞는 테마로 전환 요청 |
| 2026-07-13 | 명령어·remote theme 오버라이드 아키텍처·main 직접 push 예외 섹션 추가 (`/init`) | `CLAUDE.md` | 신규 Claude 인스턴스 온보딩에 필요한 빌드/검증 명령과 비자명한 구조를 문서화 |
| 2026-07-13 | 파이프라인에 근거 수집(Phase 0.5)·사실 검증(Phase 1.5) 단계 추가 | `agents/blog-researcher.md`, `agents/blog-verifier.md`, `agents/blog-writer.md`, `skills/blog-pipeline/SKILL.md` | writer의 `(확인 필요)` 플래그를 해소할 단계가 없던 구멍을 메움. 내부 근거 1차·외부 검증 2차로 인사이트 컨셉 유지 |
| 2026-07-13 | 발행 정책을 Issue-Driven + GitFlow로 통일 — "main 직접 push" 예외 폐기(포스트도 Issue→feature→PR→merge). blog-publisher·SKILL Phase 3를 PR 기반 발행으로 갱신 | `CLAUDE.md`, `agents/blog-publisher.md`, `skills/blog-pipeline/SKILL.md` | 사용자가 "모든 작업은 Issue-Driven GitFlow(feature 단위)"로 정책 확정 (#2) |
| 2026-07-17 | `assets/js/search.js`를 로컬 오버라이드로 승격(lunr 제거 → substring 매칭), 검색 JS 계약 테스트·CI step 추가 | `assets/js/search.js`, `search.html`, `test/{site_output_test.rb,search_test.js}`, `.github/workflows/site-check.yml`, `CLAUDE.md` | lunr trimmer가 한글 토큰을 비워 한국어 검색이 라이브에서 항상 0건이었음. JS 미검증 사각지대가 이를 은폐 (#12) |
| 2026-07-17 | 근거 사슬 확보 — 리서치 노트를 git 추적으로 되돌리고(`_drafts/*` + `!*.research.md`), verifier가 **확정 포함 전 검증 결과**를 노트의 `## 검증 기록`에 남기도록 강제. writer는 노트에 근거 없는 외부 인용 금지, publisher는 노트를 포스트와 함께 커밋하고 근거 사슬 미비 시 발행 중단 | `.gitignore`, `agents/blog-{writer,verifier,publisher}.md`, `skills/blog-pipeline/SKILL.md` | 발행본이 DOI까지 달아 인용한 논문을 리서치 노트는 "확정하지 못함"으로 남겨둠. 확정 시 근거를 안 남기는 설계 + 초안 주석을 발행 시 삭제하는 설계가 겹쳐 검증이 흔적 없이 증발 (#16) |
| 2026-07-17 | 링크 공유용 OG/Twitter 메타 추가(jekyll-seo-tag 대신 수동 — 플러그인이 title·canonical·description을 중복 emit하고 계약 테스트가 잠근 canonical 형식과 어긋남), `<title>` 이스케이프, search·tags `sitemap: false` | `_includes/head.html`, `search.html`, `tags.html`, `test/site_output_test.rb` | 렌더된 head에 og:*·twitter:*가 전무해 링크 공유 미리보기가 fallback에만 의존 (#22) |
| 2026-07-17 | FontAwesome 제거 — `_includes/icons.html`을 로컬 오버라이드로 승격하고 아이콘 3개(검색·RSS·GitHub)를 인라인 SVG로. aria-label 부여, `.icon` 크기 규칙 추가 | `_includes/{head,header,icons}.html`, `assets/css/main.scss`, `test/site_output_test.rb` | 아이콘 3개 때문에 all.css 55KB를 렌더 블로킹으로 받고 있었음. 제거로 사이트의 외부 리소스 요청이 0이 됨 (#24) |
| 2026-07-17 | 색 대비 AA 확보 — `main.scss`에서 `@import` **전에** `$link-color`(#1ABC9C 2.41:1 → #117964 5.33:1)·`$search-color`·`$tags-color` 재정의(`!default`라 import 전이 정석), import 후 rouge 주석·의사이름색 오버라이드 | `assets/css/main.scss`, `test/site_output_test.rb` | 링크색이 본문 전체에서 AA에 크게 미달. Fable 검토는 "링크 teal은 통과"라 했으나 teal은 rouge `.na`/`.no`/`.nv` 색이었고 링크가 아니었음 (#26) |
| 2026-07-17 | 포스트 규칙 명문화 — frontmatter 필드 순서(`layout → date → title → subtitle → tags`), 태그 표기(고유명사 원 표기·주제 한국어), 코드 인용은 원문 그대로, 발행본은 시점 기록이므로 소급 수정 금지 | `CLAUDE.md`, `_posts/2026-07-13-chirpy-to-type-theme.md` | Chirpy 편이 계약 테스트를 인용하며 정규식에 없는 `"`를 넣고 괄호를 뺌 — 하필 "검증 가능한 사실은 그 자리에서 검증하라"가 결론인 글이었음 (#30) |
