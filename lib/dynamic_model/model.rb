module DynamicModel
  module Model
    extend ::ActiveSupport::Concern
 
    included do
      include ActiveModel::Naming
      include ActiveModel::Validations
    end
    
    module ClassMethods
      
      # Declare this in your model to use dynamic attributes in this model
      # * options: Not yet
      def has_dynamic_columns(options = {})
        include DynamicModel::Model::Attribute
        include DynamicModel::Model::AttributeDefinition
        include DynamicModel::Model::Callbacks
        include DynamicModel::Model::Initialize
        include DynamicModel::Model::MethodMissing
        include DynamicModel::Model::Persistence
        
        
        self
      end
      
      def dynamic_class_type
        self.name
      end
      
    end
  end
end
