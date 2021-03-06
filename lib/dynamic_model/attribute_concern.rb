require 'active_support/concern'

module DynamicModel
  module AttributeConcern
    extend ::ActiveSupport::Concern

    # 0 - String, 1 - Boolean, 2 - Date, 3 - Integer, 4 - Float, 5 - Text 

    included do
      self.table_name = :dynamic_attributes
      
      attr_accessor :raw_default
      
      validates_presence_of :class_type, :name, :type, :length
      validates_inclusion_of :type, :in => DynamicModel::Type::Base.types
      attr_accessible :class_type, :name, :type, :length, :required, :default if DynamicModel.active_record_protected_attributes?

      #after_create :enforce_version_limit!
      #after_initialize :set_default_value
    end

    module ClassMethods
      # Scopes
      def with_name(name)
        where(:name => name)
      end

      def with_class_type(class_type)
        where(:class_type => class_type)
      end
    end
    
    def encoder
      DynamicModel::Type::Base.create_encoder({
        :type => self.type,
        :length => self.length,
        :required => self.required
      })
    end
    
    # Returns the default value as it is stored on the DB
    def to_definition
      DynamicModel::AttributeDefinition.new({
        :class_type => self.class_type,
        :name => self.name,
        :type => self.type,
        :length => self.length,
        :required => self.required,
        :default => self.default
      })
    end
    
    def default
      encoder.decode(read_attribute(:default)) if encoder
    end
    
    def default= value
      write_attribute(:default, encoder.encode(value)) if encoder
    end
    
  end
end