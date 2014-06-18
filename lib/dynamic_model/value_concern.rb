require 'active_support/concern'

module DynamicModel
  module ValueConcern
    extend ::ActiveSupport::Concern

    included do
      self.table_name = :dynamic_values
      
      attr_accessor :raw_value
      attr_accessible :value if DynamicModel.active_record_protected_attributes?
    end

    module ClassMethods
      def with_class_type(class_type)
        where(:class_type => class_type)
      end

      def with_name(name)
        where(:name => name)
      end
      
      def with_item_id(item_id)
        where(:item_id => item_id)
      end
    end
    
    def get_attribute_definition
      # Cache the query
      @attr_definition ||= DynamicModel::Attribute
        .with_class_type(class_type)
        .with_name(name)
        .first
        .try(:to_definition) 
    end
    
    def value
      definition = get_attribute_definition
      definition.decode(read_attribute(:value)) if definition 
    end
    
    def value= value
      definition = get_attribute_definition
      raw_value = value
      write_attribute(:value, definition.encode(value)) if definition 
    end
    
  end
  
end