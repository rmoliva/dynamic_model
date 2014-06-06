require 'active_support/concern'

module DynamicModel
  module DynamicValueConcern
    extend ::ActiveSupport::Concern

    included do
      belongs_to :dynamic_attribute
      validates_presence_of :dynamic_attribute_id
      attr_accessible :value if DynamicModel.active_record_protected_attributes?
    end

    module ClassMethods
    end
    
  end
  
end