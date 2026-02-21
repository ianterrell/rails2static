desc "Generate a static site from this Rails app"
task rails2static: :environment do
  Rails2static.generate!
end

namespace :static do
  desc "Generate a static site from this Rails app"
  task generate: :environment do
    Rails2static.generate!
  end
end
