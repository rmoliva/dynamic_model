require 'spec_helper'

describe DynamicModel::AttributeConcern do
  before(:all) do
    # Me toca los ... tener que hacer esto
    DynamicModel::Attribute.delete_all
    DynamicModel::Value.delete_all

    @attrs = {      
      :name => {
        :name => "name", 
        :type => DynamicModel::Attribute.type_definition.key(:string), 
        :length => 75, 
        :required => true,
        :default => nil
      },
      :date => {
        :name => "date", 
        :type => DynamicModel::Attribute.type_definition.key(:date), 
        :length => 8, 
        :required => true,
        :default => nil
      }
    }
  end
  
  context "default" do
    before(:each) do
      @klass = class TestModel1
        include DynamicModel::Model
      end
      @defaults = {
        :string => "Test",
        :boolean => true,
        :date => Date.today,
        :integer => 76543,
        :float => 23.45,
        :text => (1..350).map { (('a'..'z').to_a + ('0'..'9').to_a).sample }.join
      }
    end
    
    it "should not encode nil value" do
      @klass.add_dynamic_column @attrs[:name]
      DynamicModel::Attribute.first.default.should be_nil
    end
    
    DynamicModel::Attribute.type_definition.each do |v, type|
      it "should encode correctly a default type of: #{type}" do
        @attrs[:name][:default] = @defaults[type.to_sym]
        @klass.add_dynamic_column @attrs[:name]
        attribute_record = DynamicModel::Attribute.first
        attribute_record.default.should == @attrs[:name][:default]
      end
    end
  end
  

  context "add_dynamic_column" do
    before(:each) do
      @klass = class TestModel2
        include DynamicModel::Model
      end
    end
    it "should add a new record" do
      expect{
        @klass.add_dynamic_column @attrs[:name]
      }.to change(DynamicModel::Attribute, :count).by(1)
    end
  end
  
  context "del_dynamic_column" do
    before(:each) do
      @klass = class TestModel3
        include DynamicModel::Model
      end
    end
    it "should del the record" do
      @klass.add_dynamic_column @attrs[:name]
      expect{
        @klass.del_dynamic_column @attrs[:name][:name]
      }.to change(DynamicModel::Attribute, :count).by(-1)
    end
  end

  context "columns" do
    before(:each) do
      @klass = class TestModel4
        include DynamicModel::Model
      end
      @attrs.each do |key, params|
        @klass.add_dynamic_column params
      end
    end
    
    it "should return all the column names" do
      column_names = @klass.dynamic_column_names
      column_names.size.should == @attrs.keys.size
      @attrs.map{|k,v| v[:name]}.each{|c| column_names.include?(c).should be(true)}
    end
    
    it "should return all columns information" do
      column = @klass.dynamic_columns
      column.keys.size.should == @attrs.keys.size
      @attrs.each do|k, v|
        [:type, :length, :required, :default].each do |param| 
          column[k.to_s][param].should == v[param]
        end
      end
    end
    
    it "should return one column information" do
      column = @klass.dynamic_column(@attrs[:name][:name])
      
      [:type, :length, :required, :default].each do |param| 
        column[param].should == @attrs[:name][param]
      end
    end
    
  end
  
  
  
end