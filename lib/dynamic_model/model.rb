module DynamicModel
  module Model
    extend ::ActiveSupport::Concern

    included do
      # A hash where the definitions of the columns/attributes is going 
      # to be stored 
      class_attribute :column_definitions
      self.column_definitions ||= []

    end
    
    module ClassMethods
      
     # Declare this in your model to define what dynamic columns/attibutes
      # has. The first time the attribute definitions are created on the DB.
      # While next times that information is stored on a class proxy
      #
      
      def has_dynamic_columns(options = {})
        # Recorrer las columnas que ya hay en la base de datos, para cargar
        # sus definiciones
        self.column_definitions = []
        dynamic_scope.each do |attribute|
          save_column_definition(attribute)
        end
        self
      end
      
      def dynamic_class_type
        self.name
      end
      
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
        column_def = (self.column_definitions || []).detect{|col| col[:name] == dynamic_attribute.name}
        
        # Save the data to the proxy
        self.column_definitions << dynamic_attribute.to_hash unless column_def
        
        # Define the getter method
        define_method(dynamic_attribute.name)  do
          get_dynamic_value(dynamic_attribute.name)
        end

        # Define the setter method
        define_method("#{dynamic_attribute.name}=")  do |value|
          set_dynamic_value(dynamic_attribute.name, value)
        end
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
        (self.column_definitions || []).detect{|col| col[:name] == name}
      end 
    
      def dynamic_scope
        DynamicModel::Attribute.where(:class_type => dynamic_class_type)
      end
      
      # Test if a value of the given type is valid
      # with the params passed
      def is_valid? value, params
        # Test for the errors of the value 
        errors = DynamicModel::Attribute.encoder(params[:type]).errors(value, params)
        raise DynamicModel::Exception.new("Attribute: '#{self.name}' #{errors.join(', ')}") unless errors.blank? 
        true
      end
    end
    
    def set_dynamic_value name, value
      attribute_params = self.class.dynamic_column(name)

      if self.class.is_valid?(value, attribute_params)
        value_record = DynamicModel::Value
          .with_dynamic_attribute(attribute_params[:dynamic_attribute_id])
          .with_item_id(self.object_id).first_or_initialize
        value_record.class_type = self.class.name
        value_record.type = attribute_params[:type]
        value_record.name = name
        value_record.value = DynamicModel::Attribute.encode_value(attribute_params[:type],value)
        value_record.save!
      end
    end

    # Devuelve el valor de una columna en concreto
    def get_dynamic_value name
      attribute_params = self.class.dynamic_column(name)
      value_record = DynamicModel::Value
        .with_dynamic_attribute(attribute_params[:dynamic_attribute_id])
        .with_item_id(self.object_id)
        .first

      # Si no hay registro, devolver el valor por defecto
      unless value_record
        return attribute_params[:default]
      end
      
      # Devolver el valor codificado
      DynamicModel::Attribute.decode_value(attribute_params[:type],value_record.try(:value))
    end
    
    
private

    
  end
end
