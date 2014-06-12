require 'spec_helper'

describe DynamicModel::Model do
  before(:all) do
    # Me toca los ... tener que hacer esto
    DynamicModel::Attribute.delete_all
    DynamicModel::Value.delete_all
    
    $COLUMNS_DEF = DynamicModel::Attribute.type_definition.map do |v, type|
      {
        :name => "name_#{type}", 
        :type => DynamicModel::Attribute.type_definition.key(type), 
        :length => 75, 
        :required => true,
        :default => nil
      }
    end # type_definition.each

    @klass = class TestModel
      include DynamicModel::Model
      
      # Una columna de cada tipo
      has_dynamic_columns
    end # class TestModel 
    
    @klass.column_definitions.size.should == 0
    $COLUMNS_DEF.each do |definition|
      @klass.add_dynamic_column(definition)
    end
  end # before(:all)
  
  context "configuration" do
    it "should create columns definition authomatically" do
      $COLUMNS_DEF.each do |definition|
        col = @klass.column_definitions.detect{|c| c[:name] == definition[:name]}
        col.should_not be_nil
        column = @klass.dynamic_column(definition[:name])
        [:type, :length, :required].each do |param| 
          column[param].should == definition[param]
        end
      end
    end
    
    it "should create attribute records authomatically" do
      $COLUMNS_DEF.each do |definition|
        record = DynamicModel::Attribute.with_class_type(@klass.name).with_name(definition[:name]).first
        record.should_not be_nil
      end
    end
    
  end
  
end