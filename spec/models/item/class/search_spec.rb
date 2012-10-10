require 'spec_helper'

describe Item do

  before :all do
    3.times do
      FactoryGirl.create :item
    end
  end

  describe "class methods" do

    context "search" do
      it "searches in properties field" do
        string = "ABC-123"
        Item.search2(string).count.should == 0
        i = Item.first
        i.properties[:serial_number] = "ABC-123"
        i.save
        Item.search2(string).count.should == 1
      end
    end

  end
end