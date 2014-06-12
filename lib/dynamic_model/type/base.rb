module DynamicModel
  module Type
    class Base
      # Se inicializa con los registros de definicion de columna
      # y con el regitro del valor
      # *DynamicModel::Attribute* 
      # *DynamicModel::Value* 
      def initialize(attribute_record, value_record)
        @attribute_record = attribute_record
        @value_record = value_record
      end
      
      class << self
        # Convert it to store on the DB
        def encode(value)
          # Use yaml as the serializer
          value.to_yaml
        end
        
        # Convert it from the format of the DB
        def decode(value)
          YAML.load(value)
        end
        
        # Test if the value is valid
        # *params*:
        #   *max_length*: Max valid length
        #   *required* : Required value
        # Returns an array of error definitions 
        def errors(value, params)
          # TODO: Do a real validate test
          #   depending also on the type
          e = []
          e << "is required" if params[:required] and !value
          e 
        end
      end
    end
  end
end