require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

class SiteOutputTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  IGNORED_ENTRIES = %w[.bundle .claude .git .jekyll-cache .omx _site test vendor].freeze

  def test_generated_site_contract
    Dir.mktmpdir("blog-site-test") do |source|
      source = File.realpath(source)
      copy_site_source(source)
      add_pagination_fixture(source)
      add_test_dir_fixture(source)
      add_escaping_fixture(source)

      destination = File.join(source, "_site")
      stdout, stderr, status = Open3.capture3(
        { "PAGES_REPO_NWO" => "SeokRae/blog" },
        "bundle", "exec", "jekyll", "build",
        "--source", source,
        "--destination", destination,
        chdir: source
      )
      assert status.success?, "Jekyll build failed:\n#{stdout}\n#{stderr}"

      index = File.read(File.join(destination, "index.html"))
      about = File.read(File.join(destination, "about", "index.html"))
      search = File.read(File.join(destination, "search.html"))
      sitemap = File.read(File.join(destination, "sitemap.xml"))
      post = File.read(File.join(destination, "2026", "01", "20", "escaping-fixture.html"))
      css = File.read(File.join(destination, "assets", "css", "main.css"))
      flowcast_post = File.read(File.join(destination, "2026", "07", "15", "flowcast-1-why-visual-docs.html"))

      assert_match(/<html[^>]+lang="ko"/, index)
      assert_match(%r{<link rel="canonical" href="https://seokrae\.github\.io/blog/">}, index)
      assert_match(/<meta name="description"\s+content="[^"]*&quot;왜 그런 선택을 했는지&quot;/m, index)
      assert_match(%r{<meta property="og:url" content="https://seokrae\.github\.io/blog/">}, index)
      assert_match(/<meta property="og:type" content="website">/, index)
      assert_match(/<meta property="og:locale" content="ko_KR">/, index)
      assert_match(/<meta name="twitter:card" content="summary">/, index)
      assert_match(/<meta property="og:type" content="article">/, post)
      # 제목의 &와 따옴표가 escape돼야 한다 — 안 그러면 속성이 깨져 미리보기가 잘린다
      assert_includes post, %(<meta property="og:title" content="Tom &amp; Jerry &quot;quoted&quot;">)
      assert_includes post, %(<title>Tom &amp; Jerry &quot;quoted&quot; | SeokRae</title>)
      refute_includes sitemap, "/blog/search.html"
      refute_includes sitemap, "/blog/tags.html"
      refute_includes about, "background-image: url('/blog/')"
      # 아이콘 3개(검색·RSS·GitHub)는 인라인 SVG다. 외부 요청 없이 렌더돼야 한다. (#24)
      refute_match(%r{<link[^>]*\shref="https?://[^"]*\.css}, index, "외부 스타일시트를 받으면 안 된다")
      refute_includes index, "fontawesome"
      assert_match(%r{<svg class="icon"}, index)
      assert_includes index, 'aria-label="Follow RSS feed"'
      assert_includes index, 'aria-label="Follow on GitHub"'
      assert_includes search, 'aria-label="검색"'
      refute_match(%r{<script[^>]*\ssrc="https?://}, search, "검색은 외부 스크립트 없이 동작해야 한다")
      refute_match(%r{"url": "/blog//}, search)
      assert File.exist?(File.join(destination, "page2", "index.html")), "Expected /blog/page2/ output"
      refute File.exist?(File.join(destination, "blog", "page2", "index.html")), "Unexpected duplicated /blog/blog/page2/ output"
      refute File.exist?(File.join(destination, "test")), "test/ must not be published"
      assert_low_contrast_colors_replaced(css)
      # Chirpy PWA가 /blog/sw.min.js에 심어둔 서비스 워커를 자폭시키는 tombstone. 이 경로가
      # 비면 Chirpy 시절 방문자의 브라우저가 옛 캐시(포스트 없는 홈)에 영구히 갇힌다. (#34)
      sw_path = File.join(destination, "sw.min.js")
      assert File.exist?(sw_path), "tombstone 서비스 워커가 /blog/sw.min.js로 발행돼야 한다"
      sw = File.read(sw_path)
      assert_includes sw, "registration.unregister", "sw.min.js는 자기 등록을 해제해야 한다"
      assert_includes sw, "caches.delete", "sw.min.js는 옛 캐시를 비워야 한다"
      # flowcast 1편의 예시 다이어그램은 인라인 SVG여야 한다 — 시각 문서화 글의 자기 시연이자,
      # kramdown이 raw HTML 블록을 통과시키는지의 회귀 방지. 외부 요청은 여전히 0. (#36)
      # 다크 모드 — CSS 규칙·토글 버튼·paint 전 적용 스크립트가 있어야 한다. (#38)
      assert_match(/\[data-theme=("?)dark\1\]/, css, "다크 모드 CSS가 있어야 한다")
      assert_includes index, 'id="theme-toggle"', "테마 토글 버튼이 있어야 한다"
      assert_match(/localStorage\.getItem\('theme'\)/, index, "테마 적용 스크립트가 있어야 한다")
      assert_includes flowcast_post, 'class="flowcast-embed"', "flowcast 예시 다이어그램이 있어야 한다"
      assert_match(%r{<svg[^>]*viewBox="0 0 906 553"}, flowcast_post, "flowcast 시퀀스 SVG가 인라인으로 남아야 한다")
      # 본문 표가 설명하는 세 관점(sequence·topology·component)은 그림으로도 전부 남아야 한다.
      # topology·component 예시가 인라인 SVG로 함께 발행되는지 회귀 방지. (#44)
      assert_match(%r{<svg[^>]*viewBox="12 -20 980 458"}, flowcast_post, "flowcast topology SVG가 인라인으로 남아야 한다")
      assert_match(%r{<svg[^>]*viewBox="-4 -24 648 386"}, flowcast_post, "flowcast component SVG가 인라인으로 남아야 한다")
      # 세 관점의 인터랙티브 버전으로 가는 라이브 갤러리 링크가 있어야 한다. (#44)
      assert_includes flowcast_post, "https://seokrae.github.io/flowcast/", "flowcast 갤러리 링크가 있어야 한다"
      refute_match(%r{<link[^>]*rel="stylesheet"[^>]*href="https?://}, flowcast_post, "예시 다이어그램이 외부 스타일시트를 끌어오면 안 된다")
      refute_match(%r{<script[^>]*\ssrc="https?://}, flowcast_post, "예시 다이어그램이 외부 스크립트를 끌어오면 안 된다")
      # 다이어그램은 색을 CSS 변수로만 갖는다. 다크 모드에서 사이트 테마를 따르도록
      # [data-theme="dark"] .flowcast-embed가 팔레트 변수를 다크로 오버라이드해야 한다. (#40)
      assert_match(/\[data-theme=("?)dark\1\]\s*\.flowcast-embed\s*\{/, flowcast_post,
        "다크 모드에서 flowcast 다이어그램 팔레트를 오버라이드하는 규칙이 있어야 한다")
    end
  end

  private

  # 테마 기본 색은 흰 배경에서 WCAG AA(4.5:1)에 미달했다. (#26)
  # 교체 방식이 둘로 갈리므로 검증 방식도 다르다.
  def assert_low_contrast_colors_replaced(css)
    # 1) !default 변수(link·tags·search)는 값 자체가 바뀌어 산출물에서 사라진다.
    assert_match(/a\{color:#117964/, css, "링크 #1ABC9C는 2.41:1 — #117964(5.33:1)여야 한다")
    assert_match(/background:#117964;border:1px solid #117964;color:#fff/, css,
                 ".button 배경 위 흰 글씨도 AA를 넘겨야 한다 (#1ABC9C 위 흰 글씨는 2.41:1)")
    refute_match(/#b0b0b0/i, css, "태그 #b0b0b0은 2.17:1 — 산출물에 남으면 안 된다")

    # 2) rouge 색은 _syntax.scss에 값이 박혀 있어 변수로 못 바꾼다. 같은 specificity라
    #    "나중 규칙이 이긴다"로 덮으므로 원본 문자열이 남는 게 정상 — 순서를 검증한다.
    assert_override_wins(css, ".c{color:#999988", ".c,.cm,.c1{color:#70705f}",
                         "rouge 주석색 #999988(2.89:1)")
    assert_override_wins(css, ".cp{color:#999999", ".cp,.cs,.gh,.bp{color:#6f6f6f}",
                         "rouge 의사이름색 #999999(2.85:1)")

    # 3) #1ABC9C는 .call-out에만 남는다 — 어떤 페이지도 쓰지 않는 테마 dead CSS다.
    #    살아 있는 규칙으로 새어 나오면 이 개수가 늘어 실패한다.
    assert_equal 1, css.scan(/#1ABC9C/i).length,
                 "#1ABC9C는 미사용 .call-out에만 남아야 한다"
    assert_match(/\.call-out\{[^}]*#1ABC9C/i, css)
  end

  # 같은 specificity에서는 나중 규칙이 이긴다. 오버라이드가 존재하는지와 순서를 나눠 확인해야
  # 규칙이 사라졌을 때 nil 비교로 죽지 않고 무엇이 문제인지 말해준다.
  def assert_override_wins(css, theme_rule, override_rule, what)
    theme_at = css.index(theme_rule)
    override_at = css.index(override_rule)
    refute_nil theme_at, "테마 규칙 #{theme_rule}이 사라졌다 — 오버라이드가 아직 필요한지 재확인할 것"
    refute_nil override_at, "#{what} 오버라이드 규칙이 없다"
    assert override_at > theme_at, "#{what} 오버라이드가 테마 규칙보다 뒤에 와야 이긴다"
  end

  def copy_site_source(destination)
    Dir.children(ROOT).each do |entry|
      next if IGNORED_ENTRIES.include?(entry) || entry == "Gemfile.lock"

      FileUtils.cp_r(File.join(ROOT, entry), destination)
    end
  end

  # IGNORED_ENTRIES가 실제 test/를 복사에서 빼므로, 이 fixture 없이는 "test/ 발행 금지" 계약을
  # 재현할 수 없다 — 테스트가 자기 발행을 스스로 검증하지 못하는 허점이었다. (#18)
  def add_test_dir_fixture(source)
    dir = File.join(source, "test")
    FileUtils.mkdir_p(dir)
    File.write(File.join(dir, "fixture_marker.rb"), "# must not reach _site\n")
  end

  # 실제 포스트 제목에는 &나 따옴표가 없어 이스케이핑 회귀를 잡을 수 없다. (#22)
  def add_escaping_fixture(source)
    posts = File.join(source, "_posts")
    FileUtils.mkdir_p(posts)
    File.write(
      File.join(posts, "2026-01-20-escaping-fixture.md"),
      %(---\nlayout: post\ntitle: 'Tom & Jerry "quoted"'\n---\nFixture content.\n)
    )
  end

  def add_pagination_fixture(source)
    posts = File.join(source, "_posts")
    FileUtils.mkdir_p(posts)

    6.times do |index|
      File.write(
        File.join(posts, format("2026-01-%02d-pagination-fixture.md", index + 1)),
        "---\nlayout: post\ntitle: Pagination Fixture #{index + 1}\n---\nFixture content.\n"
      )
    end
  end
end
