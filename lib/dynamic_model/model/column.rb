module DynamicModel
  module Model
    module AttributeDefinition
      extend ::ActiveSupport::Concern
 
      included do
      end

      module ClassMethods
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
    end
  end
end