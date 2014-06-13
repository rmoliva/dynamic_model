require 'spec_helper'

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
  # create
  context "create" do
    before(:each) do
      @klass = class TestAR4 < ActiveRecord::Base
        self.table_name = "test_table"
        include DynamicModel::Model
        has_dynamic_columns
        self
      end # class TestModel
      
      # Add a dynamic column
      #@klass.add_dynamic_column({
      #  name: "name_string",
      #  type: 0,
      #  length: 50, 
      #  required: true,
      #  default: nil
      #})
      
      #@record = @klass.new(:name => "Test Name")
      #@record.name_string.should == @values[:string]
    end
    
    it "cant find methods" do
      # @record.should_receive(:set_dynamic_value)
      #@record.save
      #@klass.count.should == 1
    end
  end
  
  
  
  # update_attributes
  
  
  # destroy
  
  
  
  
  
  
end
