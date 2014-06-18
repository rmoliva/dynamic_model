require File.join(File.dirname(__FILE__), "..", "spec_helper")

  def each_column_datatype(type_list = nil)
    type_list ||= DynamicModel::Type::Base.types
    type_list = [type_list] if type_list.is_a?(String)
    
    type_list.each do |type|
      yield(type)
    end
  end

  # Params:  
  # * class_type
  # * name
  # * type
  # * length
  # * required
  # * default
  def db_add_column(definition) 
    encoder = DynamicModel::Type::Base.create_encoder(definition)
    sql = "INSERT INTO dynamic_attributes (`class_type`,`name`,`type`,`length`,`required`,`default`) VALUES ('%{class_type}','%{name}', '%{type}', %{length}, %{required}, %{default});"
    definition.required = definition.required ? 1 : 0
    definition.default = definition.default.nil? ? 'NULL' : "'#{encoder.encode(definition.default)}'" 
    ActiveRecord::Base.connection.execute(sql % definition.to_hash)
  end
  
  def db_upd_column(definition)
    encoder = DynamicModel::Type::Base.create_encoder(definition)
    sql = "UPDATE dynamic_attributes set `default`= %{default}, `length` = %{length}, `required` = %{required} where `class_type` = '%{class_type}' and `name` = '%{name}';"
    definition.required = definition.required ? 1 : 0
    definition.default = definition.default.nil? ? 'NULL' : "'#{encoder.encode(definition.default)}'" 
    ActiveRecord::Base.connection.execute(sql % definition.to_hash)
  end

describe "ActiveRecord" do
  before(:all) do
    @defaults = {
        :string => "Other",
        :boolean => false,
        :date => Date.today - 2,
        :integer => 34567,
        :float => 45.23,
        :text => (1..350).map { (('a'..'z').to_a + ('0'..'9').to_a).sample }.join
      }
    @values = {
      :string => "Some",
      :boolean => true,
      :date => Date.today,
      :integer => 76543,
      :float => 87.34,
      :text => (1..350).map { (('a'..'z').to_a + ('0'..'9').to_a).sample }.join
    }
  end
  
  each_column_datatype do |type|
    # initialize
    context "initialize" do
      context "assign dynamic attributes" do
        before(:each) do
          @klass = class TestAR < ActiveRecord::Base
            include DynamicModel::Model
            self.table_name = "test_table"
            has_dynamic_columns
          end # class TestModel

          definition = DynamicModel::AttributeDefinition.new({
            :class_type => 'TestAR',
            :name => "name_#{type}",
            :type => type,
            :length => 50,
            :required => true,
            :default => nil
          })
          
          db_add_column(definition)
          
          @name = "Test name"
          @record = @klass.new(:name => @name) 
          @record.name.should == @name
        end
        
        it "should return the dynamic attributes empty for #{type} type" do
          @record.send("name_#{type}").should be_nil
        end
        
        context "with a default value" do
          before(:each) do
            definition = DynamicModel::AttributeDefinition.new({
              :class_type => 'TestAR',
              :name => "name_#{type}",
              :type => type,
              :length => 50,
              :required => true,
              :default => @defaults[type.to_sym]
            })
              
            # Set the default value    
            db_upd_column(definition)
          end
          
          it "should return the dynamic attributes with the default value for #{type} type" do
            @record.send("name_#{type}").should == @defaults[type.to_sym]
          end
        end
        
        context "with a value" do
          it "should return the dynamic attributes with the value for #{type} type" do
            # Set to a test value
            @record.send("name_#{type}=", @values[type.to_sym])
            @record.send("name_#{type}").should == @values[type.to_sym]
          end
        end
      end # context "assign dynamic attributes"
    end # context "initialize"
    
    context "save" do
      describe "with no values given for dynamic columns" do
        before(:each) do
          @klass = class TestAR < ActiveRecord::Base
            include DynamicModel::Model
            self.table_name = "test_table"
            has_dynamic_columns
          end # class TestModel

          definition = DynamicModel::AttributeDefinition.new({
            :class_type => 'TestAR',
            :name => "name_#{type}",
            :type => type,
            :length => 50,
            :required => true,
            :default => nil
          })
          
          db_add_column(definition)
          
          @name = "Test name"
          @record = @klass.new(:name => @name) 
          @record.name.should == @name
        end # before(:each)
      
        it "should not create value records without default value for #{type} type" do
          expect{
            @record.save
          }.to change(DynamicModel::Value,:count).by(0)
        end
  
        it "should not create value records with default value for #{type} type" do
          definition = DynamicModel::AttributeDefinition.new({
            :class_type => 'TestAR',
            :name => "name_#{type}",
            :type => type,
            :length => 50,
            :required => true,
            :default => @defaults[type.to_sym]
          })
            
          # Set the default value    
          db_upd_column(definition)   
          expect{
            @record.save
          }.to change(DynamicModel::Value,:count).by(0)
          @record.send("name_#{type}").should == @defaults[type.to_sym]
        end
      end
      
      describe "with value given for dynamic columns" do
        before(:each) do
          @klass = class TestAR < ActiveRecord::Base
            include DynamicModel::Model
            self.table_name = "test_table"
            has_dynamic_columns
          end # class TestModel

          definition = DynamicModel::AttributeDefinition.new({
            :class_type => 'TestAR',
            :name => "name_#{type}",
            :type => type,
            :length => 50,
            :required => true,
            :default => nil
          })
          
          db_add_column(definition)
          
          @name = "Test name"
          @record = @klass.new(:name => @name, :"name_#{type}" => @values[type.to_sym]) 
          @record.name.should == @name
        end # before(:each)
        it "should create a value record with the value given for #{type} type" do
          expect{
            @record.save
          }.to change(DynamicModel::Value,:count).by(1)
          @record.send("name_#{type}").should == @values[type.to_sym]
        end
      end
    end # context "create"
  
    context "create!" do
      describe "with no values given for dynamic columns" do
        it "should not create value records without default value for #{type} type" do
          
        end
  
        it "should not create value records with default value for #{type} type" do
          
        end
      end
      
      describe "with value given for dynamic columns" do
        it "should create a value record with the value given for #{type} type" do
          
        end
      end
    end # context "create"
  
    context "update" do
      describe "with no values given for dynamic columns" do
        it "should not create value records without default value for #{type} type" do
          
        end
  
        it "should not create value records with default value for #{type} type" do
          
        end
      end
      
      describe "with value given for dynamic columns" do
        it "should create a value record with the value given for #{type} type" do
          
        end
      end
    end # context "create"
    
    context "delete" do
      describe "with value given for dynamic columns" do
        it "should delete the value record with the value given for #{type} type" do
          
        end
      end
    end # context "create"
    
    context "find" do
      describe "with no values given for dynamic columns" do
        it "should return the default value for #{type} type" do
          
        end
      end
      
      describe "with value given for dynamic columns" do
        it "should return the correct value for #{type} type" do
          
        end
      end
    end # context "create"
  end # each_column_datatype
end
 