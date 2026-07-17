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
      assert_includes search, 'aria-label="검색"'
      refute_match(%r{<script[^>]*\ssrc="https?://}, search, "검색은 외부 스크립트 없이 동작해야 한다")
      refute_match(%r{"url": "/blog//}, search)
      assert File.exist?(File.join(destination, "page2", "index.html")), "Expected /blog/page2/ output"
      refute File.exist?(File.join(destination, "blog", "page2", "index.html")), "Unexpected duplicated /blog/blog/page2/ output"
      refute File.exist?(File.join(destination, "test")), "test/ must not be published"
    end
  end

  private

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
