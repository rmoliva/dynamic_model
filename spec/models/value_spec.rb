require 'spec_helper'

describe DynamicModel::Value do
  it "should include the `ValueConcern` module to get base functionality" do
    DynamicModel::Value.should include(DynamicModel::ValueConcern)
  end

  describe "Attributes" do
    it { should have_db_column(:class_type).of_type(:string) }
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:type).of_type(:integer) }
    it { should have_db_column(:item_id).of_type(:integer) }
    it { should have_db_column(:value).of_type(:text) }
  end

  describe "Indexes" do
    it { should have_db_index([:dynamic_attribute_id]) }
    it { should have_db_index([:dynamic_attribute_id, :item_id]) }
    it { should have_db_index([:class_type, :name, :item_id]) }
  end
end
