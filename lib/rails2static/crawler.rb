require "rack/test"
require "set"
require "uri"

module Rails2static
  class Crawler
    include Rack::Test::Methods

    attr_reader :pages

    def initialize(app:, config: Rails2static.configuration)
      @app = app
      @config = config
      @pages = []
      @visited = Set.new
      @queue = []
    end

    def app
      @app
    end

    def crawl
      @config.entry_paths.each { |path| enqueue(path) }

      while (path = @queue.shift)
        break if @pages.size >= @config.max_pages

        fetch(path)
      end

      @pages
    end

    private

    def enqueue(path)
      normalized = normalize(path)
      return if normalized.nil?
      return if @visited.include?(normalized)
      return if @config.excluded?(normalized)

      @visited.add(normalized)
      @queue.push(normalized)
    end

    def fetch(path)
      header("Host", @config.host)
      get(path)

      status = last_response.status
      content_type = last_response.content_type.to_s
      body = last_response.body

      if (300..399).cover?(status)
        location = last_response.headers["Location"].to_s
        if !location.empty? && !external?(location)
          redirect_path = URI.parse(location).path
          enqueue(redirect_path)
        end
        log("  REDIRECT #{status} #{path} -> #{location}")
        return
      end

      unless status == 200
        log("  WARNING: #{status} #{path}")
        return
      end

      page = Page.new(path: path, status: status, content_type: content_type, body: body)
      @pages << page

      if page.html?
        extractor = LinkExtractor.new(body, base_path: path)
        extractor.page_links.each { |link| enqueue(link) }
      end

      log("  #{status} #{path} (#{content_type})")
    end

    def normalize(path)
      return nil if path.nil? || path.empty?

      uri = URI.parse(path)
      return nil if uri.scheme && !%w[http https].include?(uri.scheme)
      return nil if uri.host && uri.host != @config.host

      clean = uri.path.to_s
      clean = "/" if clean.empty?
      clean = clean.chomp("/") unless clean == "/"
      clean
    rescue URI::InvalidURIError
      nil
    end

    def external?(url)
      uri = URI.parse(url)
      uri.host && uri.host != @config.host
    rescue URI::InvalidURIError
      false
    end

    def log(message)
      $stdout.puts message
    end
  end
end
