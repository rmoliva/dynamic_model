

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
      
      def dynamic_initialize_attributes(attributes = nil, options = {})
        @dynamic_attributes = {}
      end
      
      def set_dynamic_value name, value
        # TODO: Comprobar que sea valido
        @dynamic_attributes[name] = value
        update_dynamic_attribute name, value
      end # set_dynamic_value
  
      # Devuelve el valor de una columna en concreto
      def get_dynamic_value name
        attribute = self.class.dynamic_scope.with_name(name).first
          
        if persisted?
          value_record = DynamicModel::Value
            .with_dynamic_attribute(attribute.id)
            .with_item_id(self.id)
            .first
  
          # Si no hay registro, devolver el valor por defecto
          return attribute.default unless value_record
          value_record.value
        else
          @dynamic_attributes[name] || attribute.default
        end
      end # get_dynamic_value
      
      # Performs an update/insert operation on the DB
      # if the base record is also saved (has an ID and persisted? is true) 
      def update_dynamic_attribute name, value
        return unless  persisted?

        attribute = self.class.dynamic_scope.with_name(name).first
        value_record = DynamicModel::Value
          .with_dynamic_attribute(attribute.id)
          .with_item_id(self.id).first_or_initialize
        value_record.class_type = self.class.dynamic_class_type
        value_record.name = name
        value_record.value = value
        value_record.save!
      end
      
    end # Attribute
  end # Model
end # DynamicModel