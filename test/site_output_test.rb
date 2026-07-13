require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

class SiteOutputTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  IGNORED_ENTRIES = %w[.bundle .claude .git .jekyll-cache .omx _site test vendor].freeze

  def test_generated_site_contract
    Dir.mktmpdir("blog-site-test") do |source|
      copy_site_source(source)
      add_pagination_fixture(source)

      destination = File.join(source, "_site")
      stdout, stderr, status = Open3.capture3(
        "bundle", "exec", "jekyll", "build",
        "--source", source,
        "--destination", destination
      )
      assert status.success?, "Jekyll build failed:\n#{stdout}\n#{stderr}"

      index = File.read(File.join(destination, "index.html"))
      about = File.read(File.join(destination, "about", "index.html"))
      search = File.read(File.join(destination, "search.html"))

      assert_match(/<html[^>]+lang="ko"/, index)
      assert_match(%r{<link rel="canonical" href="https://seokrae\.github\.io/blog/">}, index)
      assert_match(/<meta name="description"\s+content="[^"]*&quot;왜 그런 선택을 했는지&quot;/m, index)
      refute_includes about, "background-image: url('/blog/')"
      assert_includes search, 'aria-label="검색"'
      assert_includes search, 'integrity="sha384-'
      refute_match(%r{"url": "/blog//}, search)
      assert File.exist?(File.join(destination, "page2", "index.html")), "Expected /blog/page2/ output"
      refute File.exist?(File.join(destination, "blog", "page2", "index.html")), "Unexpected duplicated /blog/blog/page2/ output"
    end
  end

  private

  def copy_site_source(destination)
    Dir.children(ROOT).each do |entry|
      next if IGNORED_ENTRIES.include?(entry) || entry == "Gemfile.lock"

      FileUtils.cp_r(File.join(ROOT, entry), destination)
    end
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
