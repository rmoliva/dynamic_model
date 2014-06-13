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
    @values = {
      :string => "Other",
      :boolean => false,
      :date => Date.today - 2,
      :integer => 34567,
      :float => 45.23,
      :text => (1..350).map { (('a'..'z').to_a + ('0'..'9').to_a).sample }.join
    }
  end # before(:all)
  
  context "configuration" do
    before(:each) do
      @klass = class TestModel1
        include DynamicModel::Model
        
        # Una columna de cada tipo
        has_dynamic_columns
      end # class TestModel 
      
      @klass.dynamic_column_definitions.size.should == 0
      $COLUMNS_DEF.each do |definition|
        @klass.add_dynamic_column(definition)
      end
    end

    it "should create columns definition authomatically" do
      $COLUMNS_DEF.each do |definition|
        col = @klass.dynamic_column_definitions.detect{|c| c[:name] == definition[:name]}
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
  
  context "attribute getter" do
    before(:each) do
      @klass = class TestModel2
        include DynamicModel::Model
        
        # Una columna de cada tipo
        has_dynamic_columns
      end # class TestModel 
      
      @klass.dynamic_column_definitions.size.should == 0
      $COLUMNS_DEF.each do |definition|
        @klass.add_dynamic_column(definition)
      end
      @record = @klass.new
      
      @values = {
        :string => "Other",
        :boolean => false,
        :date => Date.today - 2,
        :integer => 34567,
        :float => 45.23,
        :text => (1..350).map { (('a'..'z').to_a + ('0'..'9').to_a).sample }.join
      }
    end
    
    DynamicModel::Attribute.type_definition.map do |v, type|
      it "should return the attribute of type '#{type} directly calling the method" do
        name = "name_#{type}"
        
        # First of all set the value of the attribute
        @record.set_dynamic_value(name, @values[type.to_sym])
        
        # Return the value calling the method
        @record.send(name).should == @values[type.to_sym]
      end
    end
    before(:each) do
      @klass = class TestModel3
        include DynamicModel::Model
        
        # Una columna de cada tipo
        has_dynamic_columns
      end # class TestModel 
      
      @klass.dynamic_column_definitions.size.should == 0
      $COLUMNS_DEF.each do |definition|
        @klass.add_dynamic_column(definition)
      end
      @record = @klass.new
      
      @values = {
        :string => "Other",
        :boolean => false,
        :date => Date.today - 2,
        :integer => 34567,
        :float => 45.23,
        :text => (1..350).map { (('a'..'z').to_a + ('0'..'9').to_a).sample }.join
      }
    end
    
    DynamicModel::Attribute.type_definition.map do |v, type|
      it "should return the attribute of type '#{type} directly calling the method" do
        name = "name_#{type}"
        
        # First of all set the value of the attribute
        @record.set_dynamic_value(name, @values[type.to_sym])
        
        # Return the value calling the method
        @record.send(name).should == @values[type.to_sym]
      end
    end
  end
  
  context "attribute setter" do
    before(:each) do
      @klass = class TestModel4
        include DynamicModel::Model
        
        # Una columna de cada tipo
        has_dynamic_columns
      end # class TestModel 
      
      @klass.dynamic_column_definitions.size.should == 0
      $COLUMNS_DEF.each do |definition|
        @klass.add_dynamic_column(definition)
      end
      @record = @klass.new
    end
    
    DynamicModel::Attribute.type_definition.map do |v, type|
      it "should set the attribute of type '#{type} directly calling the method" do
        name = "name_#{type}"
        
        # Return the value calling the method
        @record.send("#{name}=", @values[type.to_sym]) 

        # First of all set the value of the attribute
        @record.get_dynamic_value(name).should == @values[type.to_sym]
      end
    end
  end
  
  context "dynamic loaded data from DB" do
    DynamicModel::Attribute.type_definition.map do |v, type|
      context "#{type} type" do
        before(:each) do
          # Insert an attribute on the database directly
          sql = "INSERT INTO dynamic_attributes (class_type,name,type,length,required) VALUES ('TestModel5', 'name_#{type}', '#{v}', '50', '1');"
          ActiveRecord::Base.connection.execute(sql)
          
          @klass = class TestModel5
            include DynamicModel::Model
            
            # Una columna de cada tipo
            has_dynamic_columns
          end # class TestModel
          @record = @klass.new
        end
        
        it "should have the column data" do
          @klass.dynamic_column("name_#{type}").should_not be_nil
        end
        
        it "should have a setter and a getter" do
          @record.send("name_#{type}=", @values[type])
          @record.send("name_#{type}").should == @values[type]
        end
      end #type context
    end # type_definition.each
  end
end