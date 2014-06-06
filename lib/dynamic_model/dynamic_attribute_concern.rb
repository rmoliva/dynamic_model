require 'active_support/concern'

module DynamicModel
  module DynamicAttributeConcern
    extend ::ActiveSupport::Concern

    included do
      has_many :dynamic_value
      
      validates_presence_of :class_type, :name, :type, :length, :required      
      attr_accessible :class_type, :name, :type, :length, :required if DynamicModel.active_record_protected_attributes?

      #after_create :enforce_version_limit!
    end

    module ClassMethods
    end

    def reify(options = {})
      
    end
  end
  
end