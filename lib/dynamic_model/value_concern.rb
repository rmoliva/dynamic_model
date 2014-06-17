require 'active_support/concern'

module DynamicModel
  module ValueConcern
    extend ::ActiveSupport::Concern

    included do
      self.table_name = :dynamic_values
      
      attr_accessor :raw_value
      belongs_to :dynamic_attribute
      validates_presence_of :dynamic_attribute_id, :name
      attr_accessible :value if DynamicModel.active_record_protected_attributes?
    end

    module ClassMethods
      def with_dynamic_attribute(dynamic_attibute)
        where(:dynamic_attribute_id => dynamic_attibute)
      end

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
    
    def encoder
      dynamic_attribute.try(:encoder)
    end
    
    def value=(value)
      if self.encoder and value
        raw_value = value
        write_attribute(:value, encoder.encode(value))
      end 
    end

    def value
      encoder.decode(read_attribute(:value)) if self.encoder
    end
    
  end
  
end