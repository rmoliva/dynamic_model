module DynamicModel
  module Model
    module Persistence
      extend ::ActiveSupport::Concern
 
      included do
        include ActiveRecord::Callbacks
        include ActiveRecord::Persistence
        
        # Implementing persistence
        after_create  :record_create
        before_update :record_update
        after_destroy :record_destroy        
      end

      module ClassMethods

        
      end
private
      def save_dynamic_values 
        # Store the dynamic attributes on a single transaction
        DynamicModel::Value.transaction do
          self.class.dynamic_columns.each do |name, data|
            set_dynamic_value(name, dynamic_attributes[name])
          end
        end
      end

      def record_create
        save_dynamic_values
      end
      
      def record_update
        save_dynamic_values
      end
      
      def record_destroy
        
        
      end
    end
  end
end
