require 'spec_helper'

describe Backend::AcknowledgeController do
  render_views
  
  before(:each) do
    @admin = Persona.create :ramon
    @inventory_manager = Persona.create :mike
    @lending_manager = Persona.create :pius
    @user = Persona.create :normin
    @inventory_pool = (@user.inventory_pools & @lending_manager.inventory_pools).first
    @submitted_order = FactoryGirl.create :order, :user => @user, :status_const => 2, :inventory_pool => @inventory_pool
    @model = FactoryGirl.create :model
    @item = FactoryGirl.create :item, :model => @model, :owner => @inventory_pool 
  end
  
  describe "add a line to an order during acknowledge process" do
    it "adds a line to the order by providing a inventory_code" do
      post :add_line, {:format => :json,
                                  :id => @submitted_order.id,
                                  :inventory_pool_id => @inventory_pool.id,
                                  :quantity => 1,
                                  :start_date => Date.today.to_s,
                                  :end_date => Date.tomorrow.to_s,
                                  :code => @item.inventory_code}, {user_id: @lending_manager.id}
      response.success?.should be_true
    end
    
    it "an added line has the same purpose of the existing lines" do
      @unsubmitted_order = FactoryGirl.create :order_with_lines, :status_const => 1, :inventory_pool => @inventory_pool
      purposes = @unsubmitted_order.lines.map(&:purpose)
      purposes.uniq.size.should == 1
      purposes.each {|p| p.description.blank?.should be_false }
      @unsubmitted_order.submit

      post :add_line, {:format => :json,
                                  :id => @unsubmitted_order.id,
                                  :inventory_pool_id => @inventory_pool.id,
                                  :quantity => 1,
                                  :start_date => Date.today.to_s,
                                  :end_date => Date.tomorrow.to_s,
                                  :code => @item.inventory_code}, {user_id: @lending_manager.id }
      response.success?.should be_true

      purposes = @unsubmitted_order.reload.lines.map(&:purpose)
      purposes.uniq.size.should == 1
      purposes.each {|p| p.description.blank?.should be_false }
    end
  end
  
end
