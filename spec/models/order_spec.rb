require 'spec_helper'
require "#{Rails.root}/features/support/leihs_factory.rb"

describe Order do

  before(:all) do
    @ip = FactoryGirl.create(:inventory_pool)
    u = LeihsFactory.create_user({:login => 'foo', :email => 'foo@example.com'}, {:password => 'barbarbar'})
    @borrowing_user = u
                                    
    admin_user = FactoryGirl.create(:user, :firstname => "admin", :login => "admin", :email => "admin@example.com")
    admin_user.access_rights.create(:role => Role.find_by_name("manager"), :inventory_pool => @ip, :access_level => 2)
    database_authentication = FactoryGirl.create(:database_authentication, :user => admin_user, :password => 'barbarbar')
                                    
    @current_user = admin_user
  end
  
  describe "approving an order" do
    it "should send a confirmation e-mail to the user when their order is confirmed" do
      order = FactoryGirl.create :order, :inventory_pool => @ip
      3.times do
        FactoryGirl.create(:order_line, :order => order, :inventory_pool => @ip)
      end
      order.reload # the order has now nested lines
      order.approve("That will be fine.", @current_user)
      order.is_approved?.should be_true
      @emails = ActionMailer::Base.deliveries
      @emails.count.should == 1
      @emails[0].subject.should == "[leihs] Reservation Confirmation"
    end
  end
end
