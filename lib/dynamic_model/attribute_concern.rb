require 'active_support/concern'

module DynamicModel
  module AttributeConcern
    extend ::ActiveSupport::Concern

    # 0 - String, 1 - Boolean, 2 - Date, 3 - Integer, 4 - Float, 5 - Text 

    included do
      self.table_name = :dynamic_attributes
      
      has_many :dynamic_value
      
      validates_presence_of :class_type, :name, :type, :length, :required      
      attr_accessible :class_type, :name, :type, :length, :required if DynamicModel.active_record_protected_attributes?

      #after_create :enforce_version_limit!
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
    end

    def to_hash
      {
        :name => self.name,
        :type => self.type,
        :length => self.length,
        :required => self.required,
        :default => self.default
      }
      
    end
  end
  
end