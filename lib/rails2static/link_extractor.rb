require "nokogiri"

module Rails2static
  class LinkExtractor
    attr_reader :page_links, :asset_urls

    def initialize(html, base_path: "/")
      @html = html
      @base_path = base_path
      @page_links = []
      @asset_urls = []
      extract
    end

    private

    def extract
      doc = Nokogiri::HTML(@html)

      doc.css("a[href]").each do |a|
        href = a["href"].to_s.strip
        next if href.empty?

        resolved = resolve(href)
        @page_links << resolved if resolved
      end

      doc.css("link[href]").each do |link|
        href = link["href"].to_s.strip
        resolved = resolve(href)
        @asset_urls << resolved if resolved
      end

      doc.css("script[src]").each do |script|
        src = script["src"].to_s.strip
        resolved = resolve(src)
        @asset_urls << resolved if resolved
      end

      doc.css("img[src]").each do |img|
        src = img["src"].to_s.strip
        resolved = resolve(src)
        @asset_urls << resolved if resolved
      end

      doc.css("img[srcset], source[srcset]").each do |el|
        parse_srcset(el["srcset"].to_s).each do |url|
          resolved = resolve(url)
          @asset_urls << resolved if resolved
        end
      end

      doc.css("video[src], audio[src], video source[src], audio source[src]").each do |el|
        src = el["src"].to_s.strip
        resolved = resolve(src)
        @asset_urls << resolved if resolved
      end

      doc.css("video[poster]").each do |el|
        poster = el["poster"].to_s.strip
        resolved = resolve(poster)
        @asset_urls << resolved if resolved
      end

      @page_links.uniq!
      @asset_urls.uniq!
    end

    def resolve(href)
      return nil if external?(href)
      return nil if non_http?(href)

      path = if href.start_with?("/")
               href
             else
               File.join(File.dirname(@base_path), href)
             end

      normalize(path)
    end

    def external?(href)
      href.match?(%r{\A(https?://|//|mailto:|tel:|javascript:)})
    end

    def non_http?(href)
      href.start_with?("#") || href.start_with?("data:")
    end

    def normalize(path)
      uri = URI.parse(path)
      clean = uri.path
      clean = clean.chomp("/") unless clean == "/"
      clean.empty? ? "/" : clean
    rescue URI::InvalidURIError
      nil
    end

    def parse_srcset(srcset)
      srcset.split(",").map { |entry| entry.strip.split(/\s+/).first }.compact
    end
  end
end
