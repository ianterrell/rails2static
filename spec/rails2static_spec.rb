require "spec_helper"
require "rack"
require "tmpdir"

# A minimal Rack app for testing
def build_test_app(pages = {})
  Rack::Builder.new do
    run lambda { |env|
      path = env["PATH_INFO"]
      path = "/" if path.empty?

      if pages.key?(path)
        page = pages[path]
        status = page[:status] || 200
        content_type = page[:content_type] || "text/html"
        body = page[:body] || ""
        headers = { "Content-Type" => content_type }

        if page[:redirect_to]
          status = page[:status] || 302
          headers["Location"] = page[:redirect_to]
          body = ""
        end

        [status, headers, [body]]
      else
        [404, { "Content-Type" => "text/html" }, ["Not Found"]]
      end
    }
  end
end

RSpec.describe Rails2static do
  describe "VERSION" do
    it "has a version" do
      expect(Rails2static::VERSION).to match(/\d+\.\d+\.\d+/)
    end
  end

  describe Rails2static::Configuration do
    it "has sensible defaults" do
      config = Rails2static::Configuration.new
      expect(config.output_dir).to eq("_site")
      expect(config.entry_paths).to eq(["/"])
      expect(config.trailing_slash).to be true
      expect(config.max_pages).to eq(10_000)
    end

    it "can check exclusion patterns" do
      config = Rails2static::Configuration.new
      config.exclude_patterns = [%r{/admin}]
      expect(config.excluded?("/admin/dashboard")).to be true
      expect(config.excluded?("/about")).to be false
    end
  end

  describe Rails2static::LinkExtractor do
    it "extracts page links from anchor tags" do
      html = '<html><body><a href="/about">About</a><a href="/contact">Contact</a></body></html>'
      extractor = Rails2static::LinkExtractor.new(html)
      expect(extractor.page_links).to contain_exactly("/about", "/contact")
    end

    it "extracts asset URLs" do
      html = '<html><head><link href="/style.css" rel="stylesheet"><script src="/app.js"></script></head><body><img src="/logo.png"></body></html>'
      extractor = Rails2static::LinkExtractor.new(html)
      expect(extractor.asset_urls).to contain_exactly("/style.css", "/app.js", "/logo.png")
    end

    it "skips external links" do
      html = '<html><body><a href="https://example.com">Ext</a><a href="/local">Local</a></body></html>'
      extractor = Rails2static::LinkExtractor.new(html)
      expect(extractor.page_links).to eq(["/local"])
    end

    it "skips mailto and tel links" do
      html = '<html><body><a href="mailto:a@b.com">Email</a><a href="tel:123">Call</a></body></html>'
      extractor = Rails2static::LinkExtractor.new(html)
      expect(extractor.page_links).to be_empty
    end

    it "strips query strings and fragments" do
      html = '<html><body><a href="/page?q=1#section">Link</a></body></html>'
      extractor = Rails2static::LinkExtractor.new(html)
      expect(extractor.page_links).to eq(["/page"])
    end

    it "extracts srcset URLs" do
      html = '<html><body><img srcset="/img-1x.png 1x, /img-2x.png 2x"></body></html>'
      extractor = Rails2static::LinkExtractor.new(html)
      expect(extractor.asset_urls).to contain_exactly("/img-1x.png", "/img-2x.png")
    end
  end

  describe Rails2static::LinkRewriter do
    it "rewrites internal links for trailing_slash mode" do
      config = Rails2static::Configuration.new
      config.trailing_slash = true
      rewriter = Rails2static::LinkRewriter.new(config)

      html = '<html><body><a href="/about">About</a></body></html>'
      result = rewriter.rewrite(html)
      expect(result).to include('href="/about/"')
    end

    it "rewrites internal links for non-trailing_slash mode" do
      config = Rails2static::Configuration.new
      config.trailing_slash = false
      rewriter = Rails2static::LinkRewriter.new(config)

      html = '<html><body><a href="/about">About</a></body></html>'
      result = rewriter.rewrite(html)
      expect(result).to include('href="/about.html"')
    end

    it "does not rewrite external links" do
      rewriter = Rails2static::LinkRewriter.new
      html = '<html><body><a href="https://example.com">Ext</a></body></html>'
      result = rewriter.rewrite(html)
      expect(result).to include('href="https://example.com"')
    end

    it "does not rewrite links with file extensions" do
      rewriter = Rails2static::LinkRewriter.new
      html = '<html><body><a href="/feed.xml">Feed</a></body></html>'
      result = rewriter.rewrite(html)
      expect(result).to include('href="/feed.xml"')
    end

    it "preserves fragments" do
      config = Rails2static::Configuration.new
      config.trailing_slash = true
      rewriter = Rails2static::LinkRewriter.new(config)

      html = '<html><body><a href="/about#team">Team</a></body></html>'
      result = rewriter.rewrite(html)
      expect(result).to include('href="/about/#team"')
    end

    it "does not rewrite root path excessively" do
      rewriter = Rails2static::LinkRewriter.new
      html = '<html><body><a href="/">Home</a></body></html>'
      result = rewriter.rewrite(html)
      expect(result).to include('href="/"')
    end
  end

  describe Rails2static::Page do
    it "detects HTML content" do
      page = Rails2static::Page.new(path: "/", status: 200, content_type: "text/html; charset=utf-8", body: "<html></html>")
      expect(page.html?).to be true
      expect(page.css?).to be false
    end

    it "detects CSS content" do
      page = Rails2static::Page.new(path: "/style.css", status: 200, content_type: "text/css", body: "body {}")
      expect(page.css?).to be true
    end

    it "detects binary content" do
      page = Rails2static::Page.new(path: "/image.png", status: 200, content_type: "image/png", body: "\x89PNG")
      expect(page.binary?).to be true
    end
  end

  describe Rails2static::Crawler do
    it "crawls pages following links" do
      app = build_test_app(
        "/" => { body: '<html><body><a href="/about">About</a></body></html>' },
        "/about" => { body: '<html><body><a href="/">Home</a></body></html>' }
      )

      crawler = Rails2static::Crawler.new(app: app)
      pages = crawler.crawl

      paths = pages.map(&:path)
      expect(paths).to contain_exactly("/", "/about")
    end

    it "handles redirects" do
      app = build_test_app(
        "/" => { body: '<html><body><a href="/old">Old</a></body></html>' },
        "/old" => { redirect_to: "/new", status: 301 },
        "/new" => { body: '<html><body>New page</body></html>' }
      )

      crawler = Rails2static::Crawler.new(app: app)
      pages = crawler.crawl

      paths = pages.map(&:path)
      expect(paths).to contain_exactly("/", "/new")
      expect(paths).not_to include("/old")
    end

    it "skips excluded paths" do
      app = build_test_app(
        "/" => { body: '<html><body><a href="/admin">Admin</a><a href="/about">About</a></body></html>' },
        "/admin" => { body: '<html><body>Admin</body></html>' },
        "/about" => { body: '<html><body>About</body></html>' }
      )

      config = Rails2static.configuration
      config.exclude_patterns = [%r{/admin}]

      crawler = Rails2static::Crawler.new(app: app, config: config)
      pages = crawler.crawl

      paths = pages.map(&:path)
      expect(paths).to contain_exactly("/", "/about")
    end

    it "respects max_pages limit" do
      pages_hash = { "/" => { body: '<html><body><a href="/p1">1</a><a href="/p2">2</a><a href="/p3">3</a></body></html>' } }
      (1..3).each { |i| pages_hash["/p#{i}"] = { body: "<html><body>Page #{i}</body></html>" } }

      app = build_test_app(pages_hash)
      config = Rails2static.configuration
      config.max_pages = 2

      crawler = Rails2static::Crawler.new(app: app, config: config)
      pages = crawler.crawl

      expect(pages.size).to eq(2)
    end

    it "handles 404s gracefully" do
      app = build_test_app(
        "/" => { body: '<html><body><a href="/missing">Missing</a></body></html>' }
      )

      crawler = Rails2static::Crawler.new(app: app)
      pages = crawler.crawl

      paths = pages.map(&:path)
      expect(paths).to eq(["/"])
    end
  end

  describe Rails2static::Writer do
    it "writes HTML pages with trailing slash convention" do
      Dir.mktmpdir do |tmpdir|
        config = Rails2static.configuration
        config.output_dir = tmpdir
        config.trailing_slash = true

        pages = [
          Rails2static::Page.new(path: "/", status: 200, content_type: "text/html", body: "<html>Home</html>"),
          Rails2static::Page.new(path: "/about", status: 200, content_type: "text/html", body: "<html>About</html>")
        ]

        writer = Rails2static::Writer.new(config: config)
        writer.write_pages(pages)

        expect(File.read(File.join(tmpdir, "index.html"))).to eq("<html>Home</html>")
        expect(File.read(File.join(tmpdir, "about", "index.html"))).to eq("<html>About</html>")
      end
    end

    it "writes HTML pages without trailing slash" do
      Dir.mktmpdir do |tmpdir|
        config = Rails2static.configuration
        config.output_dir = tmpdir
        config.trailing_slash = false

        pages = [
          Rails2static::Page.new(path: "/", status: 200, content_type: "text/html", body: "<html>Home</html>"),
          Rails2static::Page.new(path: "/about", status: 200, content_type: "text/html", body: "<html>About</html>")
        ]

        writer = Rails2static::Writer.new(config: config)
        writer.write_pages(pages)

        expect(File.read(File.join(tmpdir, "index.html"))).to eq("<html>Home</html>")
        expect(File.read(File.join(tmpdir, "about.html"))).to eq("<html>About</html>")
      end
    end

    it "writes non-HTML content with original path" do
      Dir.mktmpdir do |tmpdir|
        config = Rails2static.configuration
        config.output_dir = tmpdir

        pages = [
          Rails2static::Page.new(path: "/feed.xml", status: 200, content_type: "application/xml", body: "<rss></rss>")
        ]

        writer = Rails2static::Writer.new(config: config)
        writer.write_pages(pages)

        expect(File.read(File.join(tmpdir, "feed.xml"))).to eq("<rss></rss>")
      end
    end
  end

  describe Rails2static::AssetCollector do
    it "collects assets referenced in HTML pages" do
      app = build_test_app(
        "/style.css" => { content_type: "text/css", body: "body { color: red; }" },
        "/app.js" => { content_type: "application/javascript", body: "console.log('hi')" }
      )

      pages = [
        Rails2static::Page.new(
          path: "/",
          status: 200,
          content_type: "text/html",
          body: '<html><head><link href="/style.css"><script src="/app.js"></script></head></html>'
        )
      ]

      collector = Rails2static::AssetCollector.new(app: app)
      assets = collector.collect(pages)

      asset_paths = assets.map(&:path)
      expect(asset_paths).to contain_exactly("/style.css", "/app.js")
    end

    it "follows CSS url() references" do
      app = build_test_app(
        "/style.css" => { content_type: "text/css", body: "body { background: url('/bg.png'); }" },
        "/bg.png" => { content_type: "image/png", body: "\x89PNG" }
      )

      pages = [
        Rails2static::Page.new(
          path: "/",
          status: 200,
          content_type: "text/html",
          body: '<html><head><link href="/style.css"></head></html>'
        )
      ]

      collector = Rails2static::AssetCollector.new(app: app)
      assets = collector.collect(pages)

      asset_paths = assets.map(&:path)
      expect(asset_paths).to include("/bg.png")
    end
  end

  describe Rails2static::Generator do
    it "generates a complete static site" do
      Dir.mktmpdir do |tmpdir|
        app = build_test_app(
          "/" => { body: '<html><head><link href="/style.css"></head><body><a href="/about">About</a></body></html>' },
          "/about" => { body: '<html><body><a href="/">Home</a></body></html>' },
          "/style.css" => { content_type: "text/css", body: "body { margin: 0; }" }
        )

        config = Rails2static.configuration
        config.output_dir = tmpdir

        generator = Rails2static::Generator.new(app: app, config: config)
        generator.run

        expect(File.exist?(File.join(tmpdir, "index.html"))).to be true
        expect(File.exist?(File.join(tmpdir, "about", "index.html"))).to be true
        expect(File.exist?(File.join(tmpdir, "style.css"))).to be true

        index_html = File.read(File.join(tmpdir, "index.html"))
        expect(index_html).to include('href="/about/"')
      end
    end
  end
end
