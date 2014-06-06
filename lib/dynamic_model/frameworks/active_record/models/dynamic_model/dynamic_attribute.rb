require 'dynamic_model/dynamic_attribute_concern'

module DynamicModel
  class DynamicAttribute < ::ActiveRecord::Base
    include DynamicModel::DynamicAttributeConcern
  end
end
