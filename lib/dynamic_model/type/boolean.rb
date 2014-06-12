module DynamicModel
  module Type
    class Boolean < DynamicModel::Type::Base
      # Devolver el valor calculado
      def value
      end
      class << self
        # Test if the value is valid
        # *params*:
        #   *max_length*: Max valid length
        #   *required* : Required value
        # Returns an array of error definitions 
        def errors(value, params)
          # TODO: Do a real validate test
          #   depending also on the type
          e = []
          # A required boolean cannot be nil 
          e << "is required" if params[:required] and value.nil?
          e 
        end
      end
    end
  end
end