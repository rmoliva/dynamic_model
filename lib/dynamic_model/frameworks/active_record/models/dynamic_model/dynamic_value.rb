require 'dynamic_model/dynamic_value_concern'

module DynamicModel
  class DynamicValue < ::ActiveRecord::Base
    include DynamicModel::DynamicValueConcern
  end
end