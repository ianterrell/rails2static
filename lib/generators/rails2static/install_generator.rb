module Rails2static
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    desc "Creates a Rails2static initializer"

    def copy_initializer
      template "rails2static.rb", "config/initializers/rails2static.rb"
    end
  end
end
