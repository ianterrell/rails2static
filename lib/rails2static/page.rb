module Rails2static
  class Page
    attr_reader :path, :status, :content_type, :body

    def initialize(path:, status:, content_type:, body:)
      @path = path
      @status = status
      @content_type = content_type.to_s
      @body = body
    end

    def html?
      content_type.include?("text/html")
    end

    def css?
      content_type.include?("text/css")
    end

    def ok?
      status == 200
    end

    def redirect?
      (300..399).cover?(status)
    end

    def binary?
      !content_type.start_with?("text/") && !content_type.include?("json") && !content_type.include?("xml") && !content_type.include?("javascript")
    end
  end
end
