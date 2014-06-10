require 'spec_helper'

describe DynamicModel::Attribute do
  it "should include the `VersionConcern` module to get base functionality" do
    DynamicModel::Attribute.should include(DynamicModel::AttributeConcern)
  end

  describe "Attributes" do
    it { should have_db_column(:class_type).of_type(:string) }
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:type).of_type(:integer) }
    it { should have_db_column(:length).of_type(:integer) }
    it { should have_db_column(:required).of_type(:boolean) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  describe "Indexes" do
    it { should have_db_index([:class_type, :name]) }
  end

#  describe "Methods" do
#    describe "Instance" do
#      subject { PaperTrail::Version.new(attributes) rescue PaperTrail::Version.new }

#      describe :terminator do
#        it { should respond_to(:terminator) }

#        let(:attributes) { {:whodunnit => Faker::Name.first_name} }

#        it "is an alias for the `whodunnit` attribute" do
#          subject.whodunnit.should == attributes[:whodunnit]
#        end
#      end

#      describe :version_author do
#        it { should respond_to(:version_author) }

#        it "should be an alias for the `terminator` method" do
#          subject.method(:version_author).should == subject.method(:terminator)
#        end
#      end
#    end
#  end
end
