require "rails2static/version"
require "rails2static/configuration"
require "rails2static/page"
require "rails2static/link_extractor"
require "rails2static/link_rewriter"
require "rails2static/crawler"
require "rails2static/asset_collector"
require "rails2static/writer"
require "rails2static/generator"
require "rails2static/railtie" if defined?(Rails::Railtie)

module Rails2static
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def generate!(app: nil)
      Generator.new(app: app).run
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
