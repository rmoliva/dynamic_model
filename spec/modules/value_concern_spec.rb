require 'spec_helper'

describe DynamicModel::ValueConcern do

  context "default" do
    before(:all) do
      # Me toca los ... tener que hacer esto
      DynamicModel::Attribute.delete_all
      DynamicModel::Value.delete_all
      
      @klass = class TestModel
        include DynamicModel::Model
      end
      
      @record = @klass.new
    end

    context "no default, no value given" do
      DynamicModel::Attribute.type_definition.each do |v, type|
        it "returns a null #{type}" do
          @klass.dynamic_columns.keys.count.should == 0
          @klass.add_dynamic_column({
            :name => type, 
            :type => v, 
            :length => 50, 
            :required => true,
            :default => nil
          })
          @record.dynamic_value(type).should be_nil
        end
      end
    end
      # 0 - String
      # 1 - Boolean 
      # 2 - Date
      # 3 - Integer
      # 4 -Float
    
    context "default given, no value given" do
      before(:each) do
        @defaults = {
          :text => "Test",
          :boolean => true,
          :date => Date.today,
          :integer => 76543,
          :float => 23.45,
          :text => (1..350).map { (('a'..'z').to_a + ('0'..'9').to_a).sample }.join
        }
        
        
      end
      DynamicModel::Attribute.type_definition.each do |v, type|
        it "returns the #{type} attribute's default value" do
          @klass.dynamic_columns.keys.count.should == 0
          @klass.add_dynamic_column({
            :name => type, 
            :type => v, 
            :length => 50, 
            :required => true,
            :default => @defaults[type.to_sym]
          })
          @record.dynamic_value(type).should == @defaults[type.to_sym]
        end
      end

      # 0 - String
      # 1 - Boolean 
      # 2 - Date
      # 3 - Integer
      # 4 -Float

      
    end
    
    
  end
  
  
  
  
  
end