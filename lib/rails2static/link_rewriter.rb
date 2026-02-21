require "nokogiri"

module Rails2static
  class LinkRewriter
    def initialize(config = Rails2static.configuration)
      @config = config
    end

    def rewrite(html)
      doc = Nokogiri::HTML(html)

      doc.css("a[href]").each do |a|
        href = a["href"].to_s.strip
        next if skip?(href)

        a["href"] = rewrite_href(href)
      end

      doc.to_html
    end

    private

    def skip?(href)
      return true if href.empty?
      return true if href.match?(%r{\A(https?://|//|mailto:|tel:|javascript:|data:)})
      return true if href.start_with?("#")
      return true if has_extension?(href)

      false
    end

    def has_extension?(href)
      path = href.split("?").first.split("#").first
      basename = File.basename(path)
      basename.include?(".") && !basename.start_with?(".")
    end

    def rewrite_href(href)
      path = href.split("?").first.split("#").first
      fragment = href.include?("#") ? "#" + href.split("#").last : ""

      if @config.trailing_slash
        path = path.chomp("/")
        path = "/" if path.empty?
        rewritten = path == "/" ? "/" : "#{path}/"
      else
        path = path.chomp("/")
        path = "/" if path.empty?
        rewritten = path == "/" ? "/" : "#{path}.html"
      end

      "#{rewritten}#{fragment}"
    end
  end
end
