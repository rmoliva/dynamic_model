

# Require core library
Dir[File.join(File.dirname(__FILE__), 'dynamic_model', '*.rb')].each do |file|
  require File.join('dynamic_model', File.basename(file, '.rb'))
end

module DynamicModel
  def self.active_record_protected_attributes?
    @active_record_protected_attributes ||= ::ActiveRecord::VERSION::MAJOR < 4 || !!defined?(ProtectedAttributes)
  end
  
end

# Ensure `ProtectedAttributes` gem gets required if it is available before the `Version` class gets loaded in
unless DynamicModel.active_record_protected_attributes?
  DynamicModel.send(:remove_instance_variable, :@active_record_protected_attributes)
  begin
    require 'protected_attributes'
  rescue LoadError; end # will rescue if `ProtectedAttributes` gem is not available
end


# Require frameworks
require 'dynamic_model/frameworks/active_record'
require 'dynamic_model/frameworks/rspec' if defined? RSpec
