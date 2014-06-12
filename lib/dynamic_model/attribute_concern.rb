require 'active_support/concern'

module DynamicModel
  module AttributeConcern
    extend ::ActiveSupport::Concern

    # 0 - String, 1 - Boolean, 2 - Date, 3 - Integer, 4 - Float, 5 - Text 

    included do
      self.table_name = :dynamic_attributes
      
      has_many :dynamic_value
      
      validates_presence_of :class_type, :name, :type, :length, :required      
      attr_accessible :class_type, :name, :type, :length, :required, :default if DynamicModel.active_record_protected_attributes?

      #after_create :enforce_version_limit!
      #after_initialize :set_default_value
    end

    module ClassMethods
      def type_definition
        {
          0 => :string,
          1 => :boolean,
          2 => :date,
          3 => :integer,
          4 => :float,
          5 => :text
        }
      end

      # Returns the value encoded, prepared to be saved to the DB
      def encode_value type, value
        return nil if value.nil?
        encoder(type).encode(value)
      end
      
      # Returns the value decoded, as readed from the DB
      def decode_value type, value
        return nil if value.nil?
        encoder(type).decode(value)
      end
      
      # Returns the class that encode the attribute value
      def encoder type
        "::DynamicModel::Type::#{type_name(type)}".constantize
      end
      
      def type_name type
        type_name = DynamicModel::Attribute.type_definition[type].to_s.camelize
      end
    end

    def to_hash
      {
        :name => self.name,
        :type => self.type,
        :length => self.length,
        :required => self.required,
        :default => self.default_decoded_value
      }
    end
    
    # Returns the default value decoded
    def default_decoded_value
      return nil if self.default.nil?
      self.class.decode_value self.type, self.default
    end
    
    def default=(value)
      write_attribute(:default, self.class.encode_value(self.type, value)) if self.type and value
    end

    def default
      self.class.decode_value(self.type, read_attribute(:default)) if self.type and read_attribute(:default)    
    end

    def set_default_value
      self.default = self.class.encode_value(self.type, self.default) if self.type and self.default
    end

    # Test if a value of the given type is valid
    # for this attirbute
    def is_valid? value
      # Test for the errors of the value 
      errors = self.class.encoder(self.type).errors(value, {
        length: self.length || 0,
        required: self.required
      })
      raise DynamicModel::Exception.new("Attribute: '#{self.name}' #{errors.join(', ')}") unless errors.blank? 
      true
    end
  end
end