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
      def record_create
        
      end
      
      def record_update
         
      end
      
      def record_destroy
        
      end
    end
  end
end
