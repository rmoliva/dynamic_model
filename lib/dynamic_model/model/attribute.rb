

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
        
        # Recorre las definiciones de las columnas que hay de este modelo en la BD
        def dynamic_column_definitions_each 
          dynamic_scope.each do |attribute|
            yield attribute.to_definition
          end
        end
        
        # Devolver la definicion da un atributo, dado su nombre
        def get_dynamic_column_definition name
          dynamic_scope.with_name(name).first.try(:to_definition)
        end
        
      end
      
      def dynamic_initialize_attributes(attributes = nil, options = {})
        attributes = ActiveSupport::HashWithIndifferentAccess.new(attributes)
        
        @dynamic_attributes = {}
        # Crear los getter/setters definidos por las columnas en la BD
        self.class.dynamic_column_definitions_each do |definition|
          self.class.create_dynamic_getter_method definition
          self.class.create_dynamic_setter_method definition
          
          # Remember: persisted? has an invalid state here
          @dynamic_attributes[definition.name] = attributes[definition.name] if attributes[definition.name] 
        end
        # dynamic_update_attributes(attributes)
      end
      
      def set_dynamic_value name, raw_value
        # TODO: Comprobar que sea valido
        @dynamic_attributes[name] = raw_value
        update_dynamic_attribute name, raw_value
      end # set_dynamic_value
  
      # Devuelve el valor de una columna en concreto
      def get_dynamic_value name
        definition = self.class.get_dynamic_column_definition(name)
        if persisted?
          value_record = DynamicModel::Value
            .with_class_type(definition.class_type)
            .with_name(definition.name)
            .with_item_id(self.id)
            .first
            
          # Si no hay registro, devolver el valor por defecto
          return definition.decode(definition.default) unless value_record
          value_record.value
        else
          @dynamic_attributes[name] || definition.decode(definition.default)
        end
      end # get_dynamic_value
      
      # Performs an update/insert operation on the DB
      # if the base record is also saved (has an ID and persisted? is true) 
      def update_dynamic_attribute name, raw_value
        return unless persisted?
        definition = self.class.get_dynamic_column_definition(name)
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
          update_dynamic_attribute(name, value)
        end
      end
      
      def dynamic_after_save
        save_dynamic_attributes
      end

      def dynamic_before_destroy
        # Borrar todos los resgistros
        DynamicModel::Value.with_item_id(self.id).destroy_all
      end

      def create_or_update
        save_dynamic_attributes
        super
      end
      
      def dynamic_update_attributes(attributes)
        attributes.each do |k,v|
          self.send("#{k}=", v) if self.class.get_dynamic_column_definition(k.to_s)
        end
      end
      
      def update_attributes!(attributes)
        with_transaction_returning_status do
          dynamic_update_attributes(attributes)
          super(attributes)
        end
      end
      
      def update_attributes(attributes)
        with_transaction_returning_status do
          dynamic_update_attributes(attributes)
          super(attributes)
        end
      end

      
    end # Attribute
  end # Model
end # DynamicModel