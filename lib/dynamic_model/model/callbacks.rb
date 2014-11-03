

module DynamicModel
  module Model
    module Callbacks
      extend ::ActiveSupport::Concern
 
      included do
        after_save :dynamic_after_save
        before_destroy :dynamic_before_destroy
      end

      module ClassMethods
        
      end # ClassMethods

      def dynamic_after_save
        save_dynamic_attributes
      end

      def dynamic_before_destroy
        destroy_dynamic_values
      end
      
    end # Callbacks
  end # Model
end # DynamicModel