require 'dynamic_model/value_concern'

module DynamicModel
  class Value < ::ActiveRecord::Base
    include DynamicModel::ValueConcern
  end
end