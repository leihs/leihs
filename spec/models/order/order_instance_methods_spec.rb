require 'spec_helper'

describe Order do

  describe "instance methods" do
  
    context "remove line" do
      
      let :inventory_pool do
        FactoryGirl.create :inventory_pool
      end
      
      it "is removing lines for UNSUBMITTED and SUBMITTED orders" do
        possible_order_types = [Order::UNSUBMITTED, Order::SUBMITTED]
        possible_order_types.each do |type|
          order = FactoryGirl.create :order, :status_const => type, :inventory_pool => inventory_pool
          2.times {order.lines << FactoryGirl.create(:order_line, :inventory_pool => inventory_pool)}
          order.remove_line(order.lines.last, FactoryGirl.create(:user).id).should_not be_false
          order.lines.size.should == 1
          order.valid?.should be_true
        end
      end
      
      it "is NOT removing lines for APPROVED and REJECTED orders" do       
        impossible_order_types = [Order::APPROVED, Order::REJECTED]
        impossible_order_types.each do |type|
          order = FactoryGirl.create :order, :status_const => type, :inventory_pool => inventory_pool 
          2.times {order.lines << FactoryGirl.create(:order_line, :inventory_pool => inventory_pool)}
          order.remove_line(order.lines.last, FactoryGirl.create(:user).id).should be_false
          order.lines.size.should == 2
          order.valid?.should be_true # it is still valid, right because the lines were not delete
        end
      end
      
      it "is NOT deleting the last line of an SUBMITTED order" do
        order = FactoryGirl.create :order, :status_const => Order::SUBMITTED, :inventory_pool => inventory_pool
        order.lines << FactoryGirl.create(:order_line, :inventory_pool => inventory_pool)
        order.remove_line(order.lines.last, FactoryGirl.create(:user).id).should be_false
        order.lines.size.should == 1
        order.valid?.should be_true # it is still valid, right because the lines were not delete
      end
    end
  end
end