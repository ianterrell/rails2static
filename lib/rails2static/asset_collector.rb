require "rack/test"
require "set"

module Rails2static
  class AssetCollector
    include Rack::Test::Methods

    attr_reader :assets

    def initialize(app:, config: Rails2static.configuration)
      @app = app
      @config = config
      @assets = []
      @fetched = Set.new
    end

    def app
      @app
    end

    def collect(pages)
      asset_urls = Set.new

      pages.each do |page|
        next unless page.html?

        extractor = LinkExtractor.new(page.body, base_path: page.path)
        extractor.asset_urls.each { |url| asset_urls.add(url) }
      end

      asset_urls.each { |url| fetch_asset(url) }

      @assets
    end

    private

    def fetch_asset(path)
      return if @fetched.include?(path)

      @fetched.add(path)

      header("Host", @config.host)
      get(path)

      unless last_response.status == 200
        log("  ASSET WARNING: #{last_response.status} #{path}")
        return
      end

      content_type = last_response.content_type.to_s
      body = last_response.body

      page = Page.new(path: path, status: 200, content_type: content_type, body: body)
      @assets << page

      if page.css?
        extract_css_refs(body, path).each { |ref| fetch_asset(ref) }
      end

      log("  ASSET #{path} (#{content_type})")
    end

    def extract_css_refs(css_body, base_path)
      refs = []
      dir = File.dirname(base_path)

      css_body.scan(/url\(\s*['"]?([^'")]+?)['"]?\s*\)/) do |match|
        url = match[0].strip
        next if url.start_with?("data:")
        next if url.match?(%r{\Ahttps?://})

        resolved = if url.start_with?("/")
                     url
                   else
                     File.join(dir, url)
                   end

        clean = resolved.split("?").first.split("#").first
        refs << clean
      end

      css_body.scan(/@import\s+['"]([^'"]+)['"]/) do |match|
        url = match[0].strip
        next if url.match?(%r{\Ahttps?://})

        resolved = if url.start_with?("/")
                     url
                   else
                     File.join(dir, url)
                   end

        refs << resolved.split("?").first
      end

      refs.uniq
    end

    def log(message)
      $stdout.puts message
    end
  end
end
