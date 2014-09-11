module DynamicModel
  module Model
    module AttributeDefinition
      extend ::ActiveSupport::Concern
 
      included do
        cattr_accessor :column_definitions
      end

      module ClassMethods
        
        def dynamic_attribute_scope
          DynamicModel::Attribute.where(:class_type => dynamic_class_type)
        end
  
        def dynamic_value_scope
          DynamicModel::Value.where(:class_type => dynamic_class_type)
        end
        
        # Recorre las definiciones de las columnas que hay de este modelo en la BD
        def dynamic_column_definitions_each 
          dynamic_attribute_scope.each do |attribute|
            yield attribute.to_definition
          end
        end
        
        # Devolver la definicion da un atributo, dado su nombre
        def get_dynamic_column_definition name
          @@column_definitions ||= {}
          @@column_definitions[name] = dynamic_attribute_scope.with_name(name).first.try(:to_definition)
        end
        
        def add_dynamic_column params
          column = dynamic_attribute_scope.with_name(params[:name]).first_or_initialize
          [:type, :length, :required, :default].each do |k|
            column.send("#{k}=", params[k])
          end
          column.save!
        end
        
        def del_dynamic_column name
          DynamicModel::Attribute.transaction do
            dynamic_attribute_scope.with_name(name).delete_all
            dynamic_value_scope.with_name(name).delete_all
          end
          @@column_definitions.delete(name)
        end

      end
    end
  end
end