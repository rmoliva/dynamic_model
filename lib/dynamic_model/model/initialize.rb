

module DynamicModel
  module Model
    module Initialize
      extend ::ActiveSupport::Concern
 
      included do
      end

      module ClassMethods
        
      end # ClassMethods

      # ActiveRecord Initializer
      def initialize(attributes = nil, options = {})
        dynamic_initialize_attributes(attributes, options)
        super(attributes, options)
      end
      
      def dynamic_initialize_attributes(attributes = nil, options = {})
        attributes = ActiveSupport::HashWithIndifferentAccess.new(attributes)
        @dynamic_attributes = {}
        
        # Crear los getter/setters definidos por las columnas en la BD
        self.class.dynamic_column_definitions_each do |definition|
          self.class.create_dynamic_getter_method definition
          self.class.create_dynamic_setter_method definition
          
          # Remember: persisted? has an invalid state here
          @dynamic_attributes[definition.name.to_sym] = attributes[definition.name] if attributes[definition.name] 
        end
      end
      
      def init_with(coder)
        @dynamic_attributes = {}
        dynamic_initialize_attributes(coder["attributes"])
        super(coder)
      end
    end # Initialize
  end # Model
end # DynamicModel