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
    encoder = DynamicModel::Type::Base.get_encoder(definition)
    sql = "INSERT INTO dynamic_attributes (`class_type`,`name`,`type`,`length`,`required`,`default`) VALUES ('%{class_type}','%{name}', '%{type}', %{length}, %{required}, %{default});"
    definition.required = definition.required ? 1 : 0
    definition.default = definition.default ? "'#{encoder.encode(definition.default)}'" : 'NULL'
    ActiveRecord::Base.connection.execute(sql % definition.to_hash)
  end
  
  def db_upd_column(definition)
    encoder = DynamicModel::Type::Base.get_encoder(definition)
    sql = "UPDATE dynamic_attributes set `default`= %{default}, `length` = %{length}, `required` = %{required} where `class_type` = '%{class_type}' and `name` = '%{name}';"
    definition.required = definition.required ? 1 : 0
    definition.default = definition.default ? "'#{encoder.encode(definition.default)}'" : 'NULL'
    ActiveRecord::Base.connection.execute(sql % definition.to_hash)
  end

describe "ActiveRecord" do
  before(:all) do
  end
  
  # initialize
  context "initialize" do
    context "assign dynamic attributes" do
      each_column_datatype("string") do |type|
        before(:each) do
          definition = DynamicModel::AttributeDefinition.new({
            :class_type => 'TestAR',
            :name => "name_#{type}",
            :type => type,
            :length => 50,
            :required => true,
            :default => nil
          })
          
          db_add_column(definition)
          
          @klass = class TestAR < ActiveRecord::Base
            include DynamicModel::Model
            self.table_name = "test_table"
            has_dynamic_columns
          end # class TestModel
          
          @name = "Test name"
          @record = @klass.new(:name => @name) 
          @record.name.should == @name
        end
        
        it "should return the dynamic attributes empty" do
          @record.send("name_#{type}").should be_nil
        end
        
        context "with a default value" do
          before(:each) do
            @defaults = {
                :string => "Other",
                :boolean => false,
                :date => Date.today - 2,
                :integer => 34567,
                :float => 45.23,
                :text => (1..350).map { (('a'..'z').to_a + ('0'..'9').to_a).sample }.join
              }
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
          
          it "should return the dynamic attributes with the default value" do
            @record.send("name_#{type}").should == @defaults[type.to_sym]
          end
        end
        
        context "with a value" do
          before(:each) do
            @values = {
              :string => "Some",
              :boolean => true,
              :date => Date.today,
              :integer => 76543,
              :float => 87.34,
              :text => (1..350).map { (('a'..'z').to_a + ('0'..'9').to_a).sample }.join
            }
          end
          it "should return the dynamic attributes with the value" do
            # Set to a test value
            @record.send("name_#{type}=", @values[type.to_sym])
            @record.send("name_#{type}").should == @values[type.to_sym]
          end
        end
      
      
      end # each_type
    end # context "assign dynamic attributes"
  end
end
