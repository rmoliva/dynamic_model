module DynamicModel
  module Model
    extend ::ActiveSupport::Concern
 
    included do
      include ActiveModel::Naming
      include ActiveModel::Validations
      include ActiveModel::MassAssignmentSecurity
    end
    
    module ClassMethods
      
     # Declare this in your model to define what dynamic columns/attibutes
      # has. The first time the attribute definitions are created on the DB.
      # While next times that information is stored on a class proxy
      #
      
      def has_dynamic_columns(options = {})
        include DynamicModel::Model::MethodMissing
        include DynamicModel::Model::Column
        include DynamicModel::Model::Attribute
        include DynamicModel::Model::Persistence
        include DynamicModel::Model::Validations

        # Recorrer las columnas que ya hay en la base de datos, para cargar
        # sus definiciones
        self.dynamic_column_definitions = []
        dynamic_scope.each do |attribute|
          save_column_definition(attribute)
        end

        self
      end
      
      def dynamic_class_type
        self.name
      end
      
      def dynamic_scope
        DynamicModel::Attribute.where(:class_type => dynamic_class_type)
      end
    end
    
    def initialize(attributes = {})
      assign_attributes(attributes)
      yield(self) if block_given?
    end
    
    def assign_attributes(values, options = {})
      sanitize_for_mass_assignment(values, options[:as]).each do |k, v|
        send("#{k}=", v)
      end
    end
  end
end
