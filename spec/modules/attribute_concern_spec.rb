

describe DynamicModel::AttributeConcern do
  before(:all) do
    @klass = class TestModel
      include DynamicModel::Model
    end
    @attrs = {      
      :name => {
        :name => "name", 
        :type => DynamicModel::Attribute.type_definition.index(:string), 
        :length => 75, 
        :required => true,
        :default => nil
      },
      :date => {
        :name => "date", 
        :type => DynamicModel::Attribute.type_definition.index(:date), 
        :length => 8, 
        :required => true,
        :default => nil
      }
    }
  end

  context "add_dynamic_column" do
    it "should add a new record" do
      expect{
        @klass.add_dynamic_column @attrs[:name]
      }.to change(DynamicModel::Attribute, :count).by(1)
    end
  end
  
  context "del_dynamic_column" do
    it "should del the record" do
      @klass.add_dynamic_column @attrs[:name]
      expect{
        @klass.del_dynamic_column @attrs[:name][:name]
      }.to change(DynamicModel::Attribute, :count).by(-1)
    end
  end

  context "columns" do
    before(:all) do
      @attrs.each do |key, params|
        @klass.add_dynamic_column params
      end
    end
    
    it "should return all the column names" do
      column_names = @klass.dynamic_column_names
      column_names.size.should == @attrs.keys.size
      @attrs.map{|k,v| v[:name]}.each{|c| column_names.include?(c).should be(true)}
    end
    
    it "should return all column information" do
      column = @klass.dynamic_columns
      column.keys.size.should == @attrs.keys.size
      @attrs.each do|k, v| 
        column[k.to_s].should == v 
      end
    end
    
  end
  
  
  
end