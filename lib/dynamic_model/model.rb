module DynamicModel
  module Model
    extend ::ActiveSupport::Concern
 
    included do
      include ActiveModel::Naming
      include ActiveModel::Validations
      include ActiveModel::MassAssignmentSecurity

      # A hash where the definitions of the columns/attributes is going 
      # to be stored 
      class_attribute :dynamic_column_definitions
      self.dynamic_column_definitions ||= []

      # A flag to prevent method_missing to execute on models that dont use 
      # dynamic attributes
      class_attribute :dynamic_column_use

    end
    
    module ClassMethods
      
     # Declare this in your model to define what dynamic columns/attibutes
      # has. The first time the attribute definitions are created on the DB.
      # While next times that information is stored on a class proxy
      #
      
      def has_dynamic_columns(options = {})
        # Recorrer las columnas que ya hay en la base de datos, para cargar
        # sus definiciones
        self.dynamic_column_definitions = []
        dynamic_scope.each do |attribute|
          save_column_definition(attribute)
        end
        
        # Set this model to use dynamic columns
        self.dynamic_column_use = true
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
        column_def = (self.dynamic_column_definitions || []).detect{|col| col[:name] == dynamic_attribute.name}
        
        # Save the data to the proxy
        self.dynamic_column_definitions << dynamic_attribute.to_hash unless column_def
        
        create_dynamic_getter_method(dynamic_attribute.name)
        create_dynamic_setter_method(dynamic_attribute.name)
      end

      # Define the getter method
      def create_dynamic_getter_method name
        define_method(name)  do
          get_dynamic_value(name)
        end
      end

      # Define the setter method
      def create_dynamic_setter_method name
        define_method("#{name}=")  do |value|
          set_dynamic_value(name, value)
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
        (self.dynamic_column_definitions || []).detect{|col| col[:name] == name}
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
    
    # Attend to lazy loading of attributes
    def method_missing method_name, *args, &block
      # Dont bother with dynamic columns if this model dont use them
      return super unless self.class.dynamic_column_use
      
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

    def initialize(attributes = {})
      assign_attributes(attributes)
      yield(self) if block_given?
    end
    
    def assign_attributes(values, options = {})
      sanitize_for_mass_assignment(values, options[:as]).each do |k, v|
        send("#{k}=", v)
      end
    end
private

    
  end
end
