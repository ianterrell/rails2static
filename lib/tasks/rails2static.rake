desc "Generate a static site from this Rails app"
task rails2static: :environment do
  Rails2static.generate!
end

namespace :static do
  desc "Generate a static site from this Rails app"
  task generate: :environment do
    Rails2static.generate!
  end

  desc "Preview the generated static site on http://localhost:8000"
  task preview: :environment do
    dir = Rails.root.join(Rails2static.configuration.output_dir)
    abort "No #{Rails2static.configuration.output_dir}/ found. Run `rake rails2static` first." unless dir.exist?

    require "webrick"
    server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: dir.to_s)
    trap("INT") { server.shutdown }
    puts "Serving #{dir}/ at http://localhost:8000 — Ctrl-C to stop"
    server.start
  end
end
