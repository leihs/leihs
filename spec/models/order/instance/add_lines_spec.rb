require 'spec_helper'

describe Order do

  before :all do
    @user = Persona.create :ramon
  end

  describe "instance methods" do

    let :inventory_pool do
      FactoryGirl.create :inventory_pool
    end
    let :model do
      FactoryGirl.create(:model_with_items)
    end
  
    context "add_lines" do
      it "with quantity greater than 1 for UNSUBMITTED and SUBMITTED orders" do
        possible_order_types = [Order::UNSUBMITTED, Order::SUBMITTED]
        possible_order_types.each do |type|
          order = FactoryGirl.create :order, :status_const => type, :inventory_pool => inventory_pool
          quantity = 3
          order.lines.size.should == 0
          order.add_lines(quantity, model, @user, Date.tomorrow, Date.tomorrow + 1.week, inventory_pool)
          order.reload.lines.size.should == quantity
          order.valid?.should be_true
        end
      end
    end

  end
end