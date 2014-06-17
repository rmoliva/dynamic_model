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
        include DynamicModel::Model::MethodMissing

        self
      end
      
      def dynamic_class_type
        self.name
      end
      
      def dynamic_scope
        DynamicModel::Attribute.where(:class_type => dynamic_class_type)
      end
    end
    
    def initialize(attributes = nil, options = {})
      dynamic_initialize_attributes(attributes, options)
      super
    end
    
    
  end
end
