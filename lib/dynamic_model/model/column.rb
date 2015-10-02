module DynamicModel
  module Model
    module AttributeDefinition
      extend ::ActiveSupport::Concern
 
      included do
        cattr_accessor :column_definitions do
          nil
        end
        # La siguiente son solumnas que seguro no estan en la
        # lista de dynamic models
        cattr_accessor :column_definition_blacklist do
          nil
        end
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
          if !self.column_definitions.nil?
            self.column_definitions.each do |name, definition|
              yield definition if definition
            end
          else 
            self.column_definitions = {}
            dynamic_attribute_scope.each do |attribute|
              definition = attribute.to_definition
              
              if definition
                self.column_definitions[attribute.name] = definition
                yield definition
              end
            end
          end
        end
        
        # Devolver la definicion da un atributo, dado su nombre
        def get_dynamic_column_definition name
          self.column_definitions ||= {}
          self.column_definition_blacklist ||= []

          # Si esta columna ya esta en la lista de columnas que no son 
          # dinamicas devolver nil
          return nil if column_definition_blacklist.include?(name)

          # Si esta columna ya se encuentra cacheada, devolverla
          return self.column_definitions[name] if self.column_definitions[name]

          # Comprobar si esta columna es dinamica 
          if(definition = dynamic_attribute_scope.with_name(name).first.try(:to_definition))
            # Es una columna dinamica, incluirla en la cache
            self.column_definitions[name] ||= definition
            return definition
          else
            # No es una columna dinamica incluirla en la lista de no dinamicas
            self.column_definition_blacklist << name
          end
        end
        
        def add_dynamic_column params
          self.column_definitions = nil
          
          column = dynamic_attribute_scope.with_name(params[:name]).first_or_initialize
          [:type, :length, :required, :default].each do |k|
            column.send("#{k}=", params[k])
          end
          column.save!
          
          # Quitarla de la blacklist si es que estaba
          self.column_definition_blacklist.delete(name) if self.column_definition_blacklist.include?(name)
        end
        
        def del_dynamic_column name
          DynamicModel::Attribute.transaction do
            dynamic_attribute_scope.with_name(name).delete_all
            dynamic_value_scope.with_name(name).delete_all
          end
          self.column_definitions ||= {}
          self.column_definitions.delete(name)
        end
        
        def dynamic_column_names
          dynamic_attribute_scope.pluck(:name)
        end

      end
    end
  end
end 