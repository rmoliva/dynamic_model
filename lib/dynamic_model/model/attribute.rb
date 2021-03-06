

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
            get_dynamic_value(definition.name.to_sym)
          end if definition
        end

        # Define the setter method
        def create_dynamic_setter_method definition
          self.send(:define_method, "#{definition.name}=") do |value|
            set_dynamic_value(definition.name.to_sym, value)
          end if definition
        end

        # Remove a getter method
        def remove_dynamic_getter_method definition
          if definition and self.method_defined?(definition.name)
            self.send(:remove_method, definition.name)
          end
        end

        # Remove a setter method
        def remove_dynamic_setter_method definition
          if definition and self.method_defined?("#{definition.name}=")
            self.send(:remove_method, "#{definition.name}=")
          end
        end
      end

      def set_dynamic_value name, raw_value
        # TODO: Comprobar que sea valido
        @dynamic_attributes[name.to_sym] = raw_value
        update_dynamic_attribute name, raw_value
      end # set_dynamic_value

      # Devuelve el valor de una columna en concreto
      def get_dynamic_value name
        definition = self.class.get_dynamic_column_definition(name)

        if persisted?
          return @dynamic_attributes[name.to_sym] unless @dynamic_attributes[name.to_sym].nil?

          # .with_name(definition.name)
          values_record = DynamicModel::Value
            .with_class_type(definition.class_type)
            .with_item_id(self.id).order('id desc')

          values_record.each do |record|

            attr_definition = self.class.get_dynamic_column_definition(record.name)
            if attr_definition
              @dynamic_attributes[record.name.to_sym] = attr_definition.decode(record.read_attribute(:value))
            end
          end
          # Si no hay registro, devolver el valor por defecto
          @dynamic_attributes[name.to_sym] = @dynamic_attributes[name.to_sym].nil? ? definition.default : @dynamic_attributes[name.to_sym]

          # return definition.default unless value_record
          # value_record.value
        else
          @dynamic_attributes[name.to_sym] || definition.default
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
        return unless persisted?
        inserts = []

        self.class.transaction do
          # Obetner los valores persisitidos en la base de datos
          persisted_values = DynamicModel::Value
            .with_class_type(self.class.dynamic_class_type)
            .with_item_id(self.id)
            .with_name(@dynamic_attributes.map(&:first))

          # Recorrer los atributos y generar sentencias SQL de insercion masiva
          @dynamic_attributes.each do |name, raw_value|
            definition = self.class.get_dynamic_column_definition(name)
            if definition
              # Comprobar si se ha cambiado el valor
              persisted_value = persisted_values.detect{|pv| pv.name == name.to_s}
              # value = raw_value.nil? ? 'NULL' : definition.encode(raw_value)

              if persisted_value
                if raw_value
                  persisted_value.update_attributes!(:value => raw_value) if persisted_value.value != raw_value
                else
                  persisted_value.delete
                end
              else
                new_value = DynamicModel::Value.new
                new_value.class_type = self.class.dynamic_class_type
                new_value.item_id = self.id
                new_value.name = name
                new_value.value = raw_value
                new_value.save!
              end
            end # if definition
          end # @dynamic_attributes.each
        end # transaction
      end

      def dynamic_attributes_update(attributes)
        # TODO: Comprobar que sea valido
        @dynamic_attributes = attributes
        save_dynamic_attributes
      end

      def read_attribute(name)
        # Leer el campo dinamico si es que es dinamico, si no delegar
        # en ActiveRecord
        if self.class.get_dynamic_column_definition(name)
          get_dynamic_value(name)
        else
          super
        end
      end
    end # Attribute
  end # Model
end # DynamicModel
