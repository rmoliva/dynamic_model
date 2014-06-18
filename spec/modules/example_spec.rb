require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe "Example Specs" do
  before(:each) do
    build_model :persons do
      string :name
      attr_accessible :name
      has_dynamic_columns
    end
  end
  
  it "should work as expected" do
    Person.add_dynamic_column({
      :name => "telephone1",
      :type => "string",
      :length => 50,
      :required => true,
      :default => "Nothing yet"
    })

    p1 = Person.create!(:name => "John Doe", :telephone1 => "555-23-12-78")
    p1.telephone1.should == "555-23-12-78"
    
    p2 = Person.create!(:name => "Freddie Mercury")
    p2.telephone1.should == "Nothing yet"
    p2.update_attributes!(:telephone1 => "I don't really know")
    p2.telephone1.should == "I don't really know"
    
    p3 = Person.last
    p3.telephone1.should == "I don't really know"  
    
  end

end
