module DynamicModel
  module Model
    module Validations
      extend ::ActiveSupport::Concern
 
      included do
        include ActiveRecord::Validations
      end

      module ClassMethods

        # Test if a value of the given type is valid
        # with the params passed
        def is_valid? value, params
          # Test for the errors of the value 
          errors = DynamicModel::Attribute.encoder(params[:type]).errors(value, params)
          raise DynamicModel::Exception.new("Attribute: '#{self.name}' #{errors.join(', ')}") unless errors.blank? 
          true
        end
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
