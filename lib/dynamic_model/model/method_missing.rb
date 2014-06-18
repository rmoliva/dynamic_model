module DynamicModel
  module Model
    module MethodMissing
      extend ::ActiveSupport::Concern
      
      # Attend to lazy loading of attributes
      def method_missing method_name, *args, &block
        # Take off the = if it exists        
        accessor_name = (method_name.to_s.split('').last == '=') ? method_name.to_s[0..-2] : method_name

        # Buscar el nombre del metodo entre los attributos dinamicos
        attribute = self.class.dynamic_attribute_scope.with_name(accessor_name).first

        if attribute.blank?
          super
        else
          # Create the attributes getter/setter methods
          self.class.create_dynamic_getter_method(attribute.to_definition)
          self.class.create_dynamic_setter_method(attribute.to_definition)
                    
          # Una vez definido el metodo, ejecutarlo
          send(method_name, *args)
        end
      end
  
  
    end # MethodMissing
  end # Model
end # DynamicModel