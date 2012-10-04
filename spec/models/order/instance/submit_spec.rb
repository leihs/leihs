require 'spec_helper'

describe Order do

  before :all do
    Persona.create :ramon
  end

  describe "instance methods" do

    let :inventory_pool do
      FactoryGirl.create :inventory_pool
    end
  
    context "submit" do
      it "is creating a purpose and associated to the lines" do
        order = FactoryGirl.create :order, :status_const => Order::UNSUBMITTED, :inventory_pool => inventory_pool
        order.lines << FactoryGirl.create(:order_line, :inventory_pool => inventory_pool)
        purpose_description = "This is my purpose"
        order.submit(purpose_description)
        order.lines.each do |l|
          l.purpose.description.should == purpose_description
        end
      end
    end

  end
end