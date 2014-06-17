module DynamicModel
  module Model
    module MethodMissing
      extend ::ActiveSupport::Concern
 
      
      # Attend to lazy loading of attributes
      def method_missing method_name, *args, &block
        # Take off the = if it exists
        method_name = method_name.to_s[0..-1] if method_name.to_s.split('').last == '='

        # Buscar el nombre del metodo entre los attributos dinamicos
        attribute = self.class.dynamic_scope.with_name(method_name).first
        if attribute.blank?
          super
        else
          # self.class.save_column_definition(attribute)
          # Create the attributes getter/setter methods
          self.class.create_dynamic_getter_method(method_name)
          self.class.create_dynamic_setter_method(method_name)
                    
          # Una vez definido el metodo, ejecutarlo
          send(method_name, *args)
        end
      end
  
  
    end # MethodMissing
  end # Model
end # DynamicModel