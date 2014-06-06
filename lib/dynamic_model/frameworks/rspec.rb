require 'rspec/core'
require 'rspec/matchers'
require 'dynamic_model/frameworks/rspec/helpers'

RSpec.configure do |config|
  config.before(:each) do
  end

  config.before(:each, :versioning => true) do
  end
end

