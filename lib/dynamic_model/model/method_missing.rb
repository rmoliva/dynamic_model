module DynamicModel
  module Model
    module MethodMissing
      extend ::ActiveSupport::Concern
 
      
      # Attend to lazy loading of attributes
      def method_missing method_name, *args, &block
        method = method_name.to_s.match(/^(.*)=$/)
        method = method.captures.first if method
        
        # Buscar el nombre del metodo entre los attributos dinamicos
        attribute = self.class.dynamic_scope.with_name(method).first
        if attribute.blank?
          super
        else
          self.class.save_column_definition(attribute)
          
          # Una vez definido el metodo, ejecutarlo
          send(method_name, *args)
        end
      end
  
    end
  end
end
