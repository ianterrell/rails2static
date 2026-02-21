require "fileutils"

module Rails2static
  class Generator
    def initialize(app: nil, config: Rails2static.configuration)
      @app = app || default_app
      @config = config
    end

    def run
      log("Rails2static: generating static site to #{@config.output_dir}/")

      prepare_output_dir
      pages = crawl
      rewrite_links(pages)
      write_pages(pages)
      collect_and_write_assets(pages)
      copy_public

      log("Rails2static: done! #{pages.size} pages written to #{@config.output_dir}/")
    end

    private

    def default_app
      defined?(Rails) ? Rails.application : raise("No app provided and Rails is not defined")
    end

    def prepare_output_dir
      FileUtils.rm_rf(@config.output_dir)
      FileUtils.mkdir_p(@config.output_dir)
      log("  Cleaned #{@config.output_dir}/")
    end

    def crawl
      log("  Crawling...")
      crawler = Crawler.new(app: @app, config: @config)
      crawler.crawl
    end

    def rewrite_links(pages)
      log("  Rewriting links...")
      rewriter = LinkRewriter.new(@config)
      pages.each do |page|
        next unless page.html?

        rewritten = rewriter.rewrite(page.body)
        page.instance_variable_set(:@body, rewritten)
      end
    end

    def write_pages(pages)
      log("  Writing pages...")
      writer = Writer.new(config: @config)
      writer.write_pages(pages)
    end

    def collect_and_write_assets(pages)
      return unless @config.include_assets

      log("  Collecting assets...")
      collector = AssetCollector.new(app: @app, config: @config)
      assets = collector.collect(pages)

      log("  Writing #{assets.size} assets...")
      writer = Writer.new(config: @config)
      writer.write_assets(assets)
    end

    def copy_public
      public_dir = if defined?(Rails)
                     Rails.public_path.to_s
                   else
                     "public"
                   end

      return unless File.directory?(public_dir)

      log("  Copying public/ files...")
      writer = Writer.new(config: @config)
      writer.copy_public(public_dir)
    end

    def log(message)
      $stdout.puts message
    end
  end
end
