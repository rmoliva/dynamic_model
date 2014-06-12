require 'dynamic_model/value_concern'

module DynamicModel
  class Value < ::ActiveRecord::Base
    include DynamicModel::ValueConcern
    class << self
      def inheritance_column
        nil
      end
    end
  end
end