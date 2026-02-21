module Rails2static
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path("../tasks/rails2static.rake", __dir__)
    end
  end
end
