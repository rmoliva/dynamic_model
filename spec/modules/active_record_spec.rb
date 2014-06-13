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
  
  # initialize
  context "initialize" do
    DynamicModel::Attribute.type_definition.map do |v, type|
      context "#{type} type attribute previously inserted" do
        before(:each) do
          # Insert an attribute on the database directly before the class definition
          sql = "INSERT INTO dynamic_attributes (class_type,name,type,length,required) VALUES ('TestAR1', 'name_#{type}', '#{v}', '50', '1');"
          ActiveRecord::Base.connection.execute(sql)
          
          @klass = class TestAR1
            include DynamicModel::Model
            has_dynamic_columns
          end # class TestModel
        end
        
        it "can initialize" do
          @record = @klass.new("name_#{type}" => @values[type])
          @record.send("name_#{type}").should == @values[type]
        end
      end

      context "#{type} type attribute lazily inserted" do
        before(:each) do
          @klass = class TestAR2
            include DynamicModel::Model
            
            # Una columna de cada tipo
            has_dynamic_columns
          end # class TestModel
          
          # Insert an attribute on the database directly after the class definition
          sql = "INSERT INTO dynamic_attributes (class_type,name,type,length,required) VALUES ('TestAR2', 'name_#{type}', '#{v}', '50', '1');"
          ActiveRecord::Base.connection.execute(sql)
        end
        
        it "can initialize" do
          @record = @klass.new("name_#{type}" => @values[type])
          @record.send("name_#{type}").should == @values[type]
        end
      end #type context
    end # type_definition.each
    context "no use of dynamic columns" do
      before(:each) do
        # Insert an attribute on the database directly before the class definition
        sql = "INSERT INTO dynamic_attributes (class_type,name,type,length,required) VALUES ('TestAR3', 'name_string', 0, 50, 1);"
        ActiveRecord::Base.connection.execute(sql)
        
        @klass = class TestAR3
          include DynamicModel::Model
          
          # Una columna de cada tipo
          # We are testing that this model dont use dynamic_columns
        end # class TestModel
        
        # Insert an attribute on the database directly after the class definition
        sql = "INSERT INTO dynamic_attributes (class_type,name,type,length,required) VALUES ('TestAR3', 'name_boolean', 1, 50, 1);"
        ActiveRecord::Base.connection.execute(sql)
      end
      
      it "cant find methods" do
        @record.respond_to?('name_string').should be_falsey
        @record.respond_to?('name_string=').should be_falsey
        @record.respond_to?('name_boolean').should be_falsey
        @record.respond_to?('name_boolean=').should be_falsey
      end
    end
    
    
  end
end
