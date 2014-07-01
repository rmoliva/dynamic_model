

module DynamicModel
  module Model
    module Inspect
      extend ::ActiveSupport::Concern
 
      included do
      end

      module ClassMethods
      end

      def inspect
        inspection = [] 
        
        self.class.dynamic_column_definitions_each do |definition|
          inspection << "*#{definition.name}: \"#{get_dynamic_value(definition.name)}\""
        end
        
        "#{super[0..-2]}, #{inspection.join(', ')}>" 
      end
    end # Attribute
  end # Model
end # DynamicModel