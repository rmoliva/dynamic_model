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

        # Recorrer las columnas que ya hay en la base de datos, para cargar
        # sus definiciones
        self.dynamic_column_definitions = []
        dynamic_scope.each do |attribute|
          save_column_definition(attribute)
        end

        # Implementing persistence
        #after_create  :record_create
        #before_update :record_update
        #after_destroy :record_destroy

        self
      end
      
      def dynamic_class_type
        self.name
      end
      
      # Define the getter method
      def create_dynamic_getter_method name
        define_method(name)  do
          get_dynamic_value(name)
        end
      end

      # Define the setter method
      def create_dynamic_setter_method name
        define_method("#{name}=")  do |value|
          set_dynamic_value(name, value)
        end
      end
    
      def dynamic_scope
        DynamicModel::Attribute.where(:class_type => dynamic_class_type)
      end
      
      # Test if a value of the given type is valid
      # with the params passed
      def is_valid? value, params
        # Test for the errors of the value 
        errors = DynamicModel::Attribute.encoder(params[:type]).errors(value, params)
        raise DynamicModel::Exception.new("Attribute: '#{self.name}' #{errors.join(', ')}") unless errors.blank? 
        true
      end
    end
    
    def set_dynamic_value name, value
      attribute_params = self.class.dynamic_column(name)

      if self.class.is_valid?(value, attribute_params)
        value_record = DynamicModel::Value
          .with_dynamic_attribute(attribute_params[:dynamic_attribute_id])
          .with_item_id(self.object_id).first_or_initialize
        value_record.class_type = self.class.name
        value_record.type = attribute_params[:type]
        value_record.name = name
        value_record.value = DynamicModel::Attribute.encode_value(attribute_params[:type],value)
        value_record.save!
      end
    end

    # Devuelve el valor de una columna en concreto
    def get_dynamic_value name
      attribute_params = self.class.dynamic_column(name)
      value_record = DynamicModel::Value
        .with_dynamic_attribute(attribute_params[:dynamic_attribute_id])
        .with_item_id(self.object_id)
        .first

      # Si no hay registro, devolver el valor por defecto
      unless value_record
        return attribute_params[:default]
      end
      
      # Devolver el valor codificado
      DynamicModel::Attribute.decode_value(attribute_params[:type],value_record.try(:value))
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
private
    def record_create
      
    end
    
    def record_update
       
    end
    
    def record_destroy
      
    end

    
  end
end
