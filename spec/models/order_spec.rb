require 'spec_helper'
require Rails.root + 'lib/leihs_factory'

describe Order do

  before(:all) do
    @ip = LeihsFactory.create_inventory_pool
    u = LeihsFactory.create_user({:login => 'foo', :email => 'foo@example.com'}, {:password => 'barbarbar'})
    @borrowing_user = u
    
    admin_user = LeihsFactory.create_user({:login => 'admin', :email => 'admin@example.com'}, 
                                     {:password => 'barbarbar', :role => 'admin', :inventory_pool => @ip})
    @current_user = admin_user
  end
  
  describe "approving an order" do
    it "should send a confirmation e-mail to the user when their order is confirmed" do      
      order = LeihsFactory.create_order({:inventory_pool => @ip, :user_id => @borrowing_user.id}, {:order_lines => 3})
      order.approve("That will be fine.", @current_user)
      @emails = ActionMailer::Base.deliveries

      @emails.count.should == 1
      @emails[0].subject.should == "[leihs] Reservation Confirmation"
    end
  end

end
