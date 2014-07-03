

module DynamicModel
  module Model
    module Attribute
      extend ::ActiveSupport::Concern
 
      included do
      end

      module ClassMethods
        # Define the getter method
        def create_dynamic_getter_method definition
          self.send(:define_method, definition.name) do |*args|
            get_dynamic_value(definition.name)
          end
        end
  
        # Define the setter method
        def create_dynamic_setter_method definition
          self.send(:define_method, "#{definition.name}=") do |value|
            set_dynamic_value(definition.name, value)
          end
        end
      end
      
      def set_dynamic_value name, raw_value
        # TODO: Comprobar que sea valido
        @dynamic_attributes[name] = raw_value
        update_dynamic_attribute name, raw_value
      end # set_dynamic_value
  
      # Devuelve el valor de una columna en concreto
      def get_dynamic_value name
        definition = self.class.get_dynamic_column_definition(name)
        return unless definition
        
        if persisted?
          value_record = DynamicModel::Value
            .with_class_type(definition.class_type)
            .with_name(definition.name)
            .with_item_id(self.id)
            .first
            
          # Si no hay registro, devolver el valor por defecto
          return definition.default unless value_record
          value_record.value
        else
          @dynamic_attributes[name] || definition.default
        end
      end # get_dynamic_value
      
      # Performs an update/insert operation on the DB
      # if the base record is also saved (has an ID and persisted? is true) 
      def update_dynamic_attribute name, raw_value
        return unless persisted?
        definition = self.class.get_dynamic_column_definition(name)
        return unless definition
        
        value_record = DynamicModel::Value
          .with_class_type(definition.class_type)
          .with_name(definition.name)
          .with_item_id(self.id).first_or_initialize
        value_record.value = raw_value
        value_record.save
      end
      
      def save_dynamic_attributes
        # Recorrer los atributos y guardarlos
        @dynamic_attributes.each do |name, value|
          update_dynamic_attribute(name, value) if self.class.get_dynamic_column_definition(name.to_s)
        end
      end

      def dynamic_attributes_update(attributes)
        attributes.each do |k,v|
          self.send("#{k}=", v) if self.class.get_dynamic_column_definition(k.to_s)
        end
      end
      
      
    end # Attribute
  end # Model
end # DynamicModel