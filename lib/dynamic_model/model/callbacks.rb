

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
        # Borrar todos los resgistros
        DynamicModel::Value.with_item_id(self.id).destroy_all
      end
      
    end # Callbacks
  end # Model
end # DynamicModel