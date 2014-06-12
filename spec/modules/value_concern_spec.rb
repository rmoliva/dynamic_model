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
    end # before(:all)

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
          @record.get_dynamic_value(type).should be_nil
        end # it ...
      end # type_definition.each
    end # context
    
    context "default given" do
      before(:each) do
        @defaults = {
          :string => "Test",
          :boolean => true,
          :date => Date.today,
          :integer => 76543,
          :float => 23.45,
          :text => (1..350).map { (('a'..'z').to_a + ('0'..'9').to_a).sample }.join
        }
      end
      context "no value given" do
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
            @record.get_dynamic_value(type).should == @defaults[type.to_sym]
          end # it ...
        end # type_definition.each
      end # context "no value given"
      
      context "value given" do
        before(:each) do
          @values = {
            :string => "Other",
            :boolean => false,
            :date => Date.today - 2,
            :integer => 34567,
            :float => 45.23,
            :text => (1..350).map { (('a'..'z').to_a + ('0'..'9').to_a).sample }.join
          }
        end
        DynamicModel::Attribute.type_definition.each do |v, type|
          it "returns the #{type} attribute's default value" do
            name = "name_#{type}"
            @klass.dynamic_columns.keys.count.should == 0
            @klass.add_dynamic_column({
              :name => name, 
              :type => v, 
              :length => 50, 
              :required => true,
              :default => @defaults[type.to_sym]
            })
            
            # Set a value to the record 
            @record.set_dynamic_value(name, @values[type.to_sym])
            @record.get_dynamic_value(name).should == @values[type.to_sym]
          end # it ...
        end # type_definition.each
      end # context  "value given"
    end # context "default given"
  end # context "default"
end # describe