require "rails2static"

RSpec.configure do |config|
  config.before(:each) do
    Rails2static.reset_configuration!
  end
end
