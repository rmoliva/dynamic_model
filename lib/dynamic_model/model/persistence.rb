

module DynamicModel
  module Model
    module Persistence
      extend ::ActiveSupport::Concern
 
      included do
      end

      module ClassMethods
        
        
      end # ClassMethods
      
      # ActiveRecord::create_or_update method
      def create_or_update
        save_dynamic_attributes
        super
      end
      
      # ActiveRecord::update_attributes! method
      def update_attributes!(attributes)
        with_transaction_returning_status do
          dynamic_attributes_update(attributes)
          super(attributes)
        end
      end
      
      # ActiveRecord::update_attributes method
      def update_attributes(attributes)
        with_transaction_returning_status do
          dynamic_attributes_update(attributes)
          super(attributes)
        end
      end
      
      def destroy_dynamic_values
        # Borrar todos los resgistros
        DynamicModel::Value
          .with_class_type(self.class.dynamic_class_type)
          .with_item_id(self.id).destroy_all
      end

      
    end # Persistence
  end # Model
end # DynamicModel