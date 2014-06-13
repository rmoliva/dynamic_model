module DynamicModel
  module Model
    module Column
      extend ::ActiveSupport::Concern
 
      included do
        # A hash where the definitions of the columns/attributes is going 
        # to be stored 
        class_attribute :dynamic_column_definitions
        self.dynamic_column_definitions ||= []
      end

      module ClassMethods
        # Anadir una columna dinamica
        # *params*: 
        #  *name* 
        #  *type*
        #  *length*
        #  *required*
        def add_dynamic_column params
          dynamic_attribute = dynamic_scope.create!(params)
          save_column_definition(dynamic_attribute)
          dynamic_attribute
        end
  
        def save_column_definition dynamic_attribute
          column_def = (self.dynamic_column_definitions || []).detect{|col| col[:name] == dynamic_attribute.name}
          
          # Save the data to the proxy
          self.dynamic_column_definitions << dynamic_attribute.to_hash unless column_def
          
          create_dynamic_getter_method(dynamic_attribute.name)
          create_dynamic_setter_method(dynamic_attribute.name)
        end
  
        # Borrar una columna existente
        def del_dynamic_column name
          dynamic_scope.where(:name => name).first.destroy
        end
  
        # Devuelve solamente los nombres de las columnas 
        # dinamicas de este modelo      
        def dynamic_column_names
          dynamic_scope.select('name').map(&:name)
        end
      
        # Devuelve un hash nombre => parametros con la informacion 
        # de todas las columnas dinamicas
        def dynamic_columns
          dynamic_scope.inject(Hash.new(0)) do |res, record|
            res[record.name] = record.to_hash
            res
          end
        end
        
        # Devuelve la informacion de una columna en concreto
        def dynamic_column name
          # Cogerlo del proxy
          # dynamic_scope.where(:name => name).first.to_hash
          (self.dynamic_column_definitions || []).detect{|col| col[:name] == name}
        end 
      end
    end
  end
end
