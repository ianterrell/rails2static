module Rails2static
  class Configuration
    attr_accessor :output_dir, :entry_paths, :host, :protocol,
                  :trailing_slash, :exclude_patterns, :include_assets,
                  :max_pages

    def initialize
      @output_dir = "_site"
      @entry_paths = ["/"]
      @host = "www.example.com"
      @protocol = "https"
      @trailing_slash = true
      @exclude_patterns = []
      @include_assets = true
      @max_pages = 10_000
    end

    def excluded?(path)
      exclude_patterns.any? { |pattern| path.match?(pattern) }
    end
  end
end
