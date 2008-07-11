require "spec_helper"
require "app"

describe 'Callbacks' do

  before do
    @country = Country.create!(:name => 'India')
    @citizen = Citizen.create!(:name => 'Sebestian Bach')
  end

  it "pairs added in callback invocation should reflect on the scope map passed" do
    scope_map = {}
    @country.class.class_eval do
      def before_citizen_add citizen, scope
        scope[:foo] = 'bar'
      end
    end
    @country.citizens.send(:callback, :before_add, @citizen, scope_map)
    scope_map[:foo].should == 'bar'
    @country.class.class_eval do
      def before_citizen_add citizen, scope; end
    end
  end

  describe "on add" do
    it "should invoke callbacks" do
      @country.citizens.should_receive(:callback).with(:before_add, @citizen, {})
      mock_citizenship = Citizenship.create!(:country => @country, :citizen => @citizen)
      Citizenship.stub!(:create!).and_return(mock_citizenship)
      @country.citizens.should_receive(:callback).with(:after_add, @citizen, mock_citizenship)
      @country.citizens << @citizen
    end
  end

  describe "remove" do
    it "should invoke callbacks" do
      @country.citizens << @citizen
      @country.reload
      @country.citizens.should_receive(:callback).with(:before_remove, @citizen)
      @country.citizens.should_receive(:callback).with(:after_remove, @citizen)
      @country.citizens.delete(@citizen)
    end
  end
end
