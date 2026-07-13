# SeokRae 기술 블로그

개발 과정에서 얻은 판단, 트레이드오프, 인사이트를 기록하는 Jekyll 블로그입니다.
GitHub Pages 프로젝트 사이트인 <https://seokrae.github.io/blog/>로 배포됩니다.

## 기술 구성

- Jekyll 및 GitHub Pages
- [Type Theme](https://github.com/rohanchandra/type-theme)
- `jekyll-remote-theme`, `jekyll-paginate`, `jekyll-feed`, `jekyll-sitemap`

원격 테마는 재현 가능한 빌드를 위해 `_config.yml`에서 검증된 커밋으로 고정합니다.
접근성과 메타데이터 개선은 `_layouts`, `_includes`, `assets/css/main.scss`의 최소 오버라이드로 관리합니다.

## 로컬 실행

Ruby와 Bundler를 설치한 뒤 다음 명령을 실행합니다.

```shell
bundle install
bundle exec jekyll serve
```

로컬 주소는 <http://localhost:4000/blog/>입니다.

## 검증

```shell
bundle exec ruby test/site_output_test.rb
```

검증 스크립트는 임시 게시글 6개로 사이트를 빌드하여 다음 계약을 확인합니다.

- `/blog/page2/` 페이지네이션 경로
- 한국어 문서 언어와 절대 canonical URL
- 유효한 설명 메타 태그
- 접근 가능한 검색 컨트롤
- 검색 URL의 이중 슬래시 방지
- 빈 feature image의 불필요한 홈페이지 요청 방지

## 글 작성

게시글은 `_posts/YYYY-MM-DD-title.md` 형식으로 추가합니다.

```markdown
---
layout: post
title: "글 제목"
tags: [tag]
---

본문
```

`main` 브랜치에 반영하면 GitHub Pages가 사이트를 배포합니다. GitHub Actions는 동일한 빌드 계약을 먼저 검증합니다.
