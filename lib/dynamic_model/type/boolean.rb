module DynamicModel
  module Type
    class Boolean < DynamicModel::Type::Base
      # Convert it to store on the DB
      def encode(value)
        # nil has no conversion
        return nil if value.nil?
        
        # Convert first to boolean if it is a string
        value = !(value.to_s =~ /no|false|0|off/i)

        # Use yaml as the serializer
        value.to_yaml
      end
      
      
    end
  end
end