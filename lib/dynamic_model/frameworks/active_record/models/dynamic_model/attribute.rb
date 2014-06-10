require 'dynamic_model/attribute_concern'

module DynamicModel
  class Attribute < ::ActiveRecord::Base
    include DynamicModel::AttributeConcern
    
    class << self
      def inheritance_column
        nil
      end
    end
  end
end
