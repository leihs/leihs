require 'spec_helper'
require "#{Rails.root}/features/support/leihs_factory.rb"

describe Order do

  before(:all) do
    @ip = LeihsFactory.create_inventory_pool
    u = LeihsFactory.create_user({:login => 'foo', :email => 'foo@example.com'}, {:password => 'barbarbar'})
    @borrowing_user = u
                                    
    admin_user = Factory(:user, :firstname => "admin", :login => "admin", :email => "admin@example.com")
    admin_user.access_rights.create(:role => Role.find_by_name("manager"), :inventory_pool => @ip, :access_level => 2)
    database_authentication = Factory(:database_authentication, :user => admin_user, :password => 'barbarbar')
                                    
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
