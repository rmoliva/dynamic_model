require File.join(File.dirname(__FILE__), "..", "spec_helper")

  def each_column_datatype(type_list = nil)
    type_list ||= DynamicModel::Type::Base.types
    type_list = [type_list] if type_list.is_a?(String)
    
    type_list.each do |type|
      yield(type)
    end
  end


describe "DynamicColumn::Column" do
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
    
    build_model :test_classes do
      string :name
      # attr_accessible :name
      has_dynamic_columns
    end
    @klass = TestClass
  end
  
  each_column_datatype("string") do |type|
    context "add_dynamic_column of #{type} type" do
      before(:each) do
        @params =  {
          :name => "name_#{type}",
          :type => type,
          :length => 50,
          :required => true,
          :default => @defaults[type.to_sym]
        }
      end
      
      it "should create an attribute record" do
        expect{
          @klass.add_dynamic_column(@params)
        }.to change(DynamicModel::Attribute, :count).by(1)
        
        record = DynamicModel::Attribute.first
        record.class_type.should == @klass.name
        record.name.should == @params[:name]
        record.type.should == @params[:type]
        record.length.should == @params[:length]
        record.required.should == @params[:required]
        record.default.should == @params[:default]
      end
    end
    
    context "del_dynamic_column of #{type} type" do
      before(:each) do
        build_model :test_classes do
          string :name
          # attr_accessible :name
          has_dynamic_columns
        end
        @klass = TestClass
        
        # We create two columns
        @params = {}
        %w(first second).each do |k|
          @params[k.to_sym] =  {
            :name => "#{k}_#{type}",
            :type => type,
            :length => 50,
            :required => true,
            :default => nil
          }
          @klass.add_dynamic_column(@params[k.to_sym])
        end

        DynamicModel::Attribute.count.should == 2
        
        # We create two records
        @records = {
          :first => @klass.create!(
            :name => "First record", 
            "first_#{type}" => @values[type.to_sym], 
            "second_#{type}" => @values[type.to_sym]
          ),
          :first => @klass.create!(
            :name => "Second record", 
            "first_#{type}" => @values[type.to_sym], 
            "second_#{type}" => @values[type.to_sym]
          ),
        }
        
        DynamicModel::Value.count.should == 4
      end
      
      it "should delete the record attribute" do
        expect{
          @klass.del_dynamic_column(@params[:first][:name])
        }.to change(DynamicModel::Attribute, :count).by(-1)
      end
      
      it "should delete the record value" do
        expect{
          @klass.del_dynamic_column(@params[:first][:name])
        }.to change(DynamicModel::Value, :count).by(-2)
      end
    end  
  end # each_datatype
end
