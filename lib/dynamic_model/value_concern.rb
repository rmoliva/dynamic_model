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
    end
    
  end
  
end