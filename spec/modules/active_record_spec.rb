require 'spec_helper'
require 'nulldb_rspec'

describe "ActiveRecord" do
  before(:all) do
    # Me toca los ... tener que hacer esto
    DynamicModel::Attribute.delete_all
    DynamicModel::Value.delete_all

    @values = {
      :string => "Other",
      :boolean => false,
      :date => Date.today - 2,
      :integer => 34567,
      :float => 45.23,
      :text => (1..350).map { (('a'..'z').to_a + ('0'..'9').to_a).sample }.join
    }
  end
  
  # initialize
  context "initialize" do
    DynamicModel::Attribute.type_definition.map do |v, type|
      context "#{type} type" do
        before(:each) do
          include NullDB::RSpec::NullifiedDatabase
          
          # Insert an attribute on the database directly
          sql = "INSERT INTO dynamic_attributes (class_type,name,type,length,required) VALUES ('TestModel5', 'name_#{type}', '#{v}', '50', '1');"
          ActiveRecord::Base.connection.execute(sql)
          
          @klass = class TestAR1 < ActiveRecord::Base
            include DynamicModel::Model
            
            # Una columna de cada tipo
            has_dynamic_columns
          end # class TestModel
        end
        
        it "can initialize with the attribute" do
#          @record = @klass.new("name_#{type}" => @values[type])
#          @record.send("name_#{type}").should == @values[type]
        end
      end #type context
    end # type_definition.each
  end
  
  # update_attributes
  
  
  # destroy
  
  
  
  
  
  
end
