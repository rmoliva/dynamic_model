require 'active_support/concern'

module DynamicModel
  module ValueConcern
    extend ::ActiveSupport::Concern

    included do
      self.table_name = :dynamic_values
      
      belongs_to :dynamic_attribute
      validates_presence_of :dynamic_attribute_id
      attr_accessible :value if DynamicModel.active_record_protected_attributes?
    end

    module ClassMethods
      def with_dynamic_attribute(dynamic_attibute)
        where(:dynamic_attribute_id => dynamic_attibute)
      end
      
      def with_item_id(item_id)
        where(:item_id => item_id)
      end
    end
    
  end
  
end