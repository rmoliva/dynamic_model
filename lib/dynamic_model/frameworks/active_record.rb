
# This file only needs to be loaded if the gem is being used outside of Rails, since otherwise
# the model(s) will get loaded in via the `Rails::Engine`
Dir[File.join(File.dirname(__FILE__), 'active_record', 'models', 'dynamic_model', '*.rb')].each do |file|
  require "dynamic_model/frameworks/active_record/models/dynamic_model/#{File.basename(file, '.rb')}"
end