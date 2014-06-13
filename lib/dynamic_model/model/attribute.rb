module DynamicModel
  module Model
    module Attribute
      extend ::ActiveSupport::Concern
 
      included do
      end

      module ClassMethods
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
    end
  end
end
