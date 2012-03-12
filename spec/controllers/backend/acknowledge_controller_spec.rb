require 'spec_helper'

describe Backend::AcknowledgeController do
  render_views
  
  before(:each) do
    @admin = Persona.create :ramon
    @inventory_manager = Persona.create :mike
    @lending_manager = Persona.create :pius
    @user = Persona.create :normin
    @inventory_pool = (@user.inventory_pools & @lending_manager.inventory_pools).first
    @order = Factory :order, :user => @user, :status_const => 2, :inventory_pool => @inventory_pool
    @model = Factory :model
    @item = Factory :item, :model => @model, :owner => @inventory_pool 
  end
  
  describe "add a line to an order during acknowledge process" do
    
    it "adds a line to the order by providing a serial_number" do
       post :add_line, {:format => :json,
                        :id => @order.id,
                        :inventory_pool_id => @inventory_pool.id,
                        :quantity => 1,
                        :start_date => Date.today,
                        :end_date => Date.tomorrow,
                        :code => @item.serial_number},
                       {user_id: @lending_manager.id}
        
    end
    
    it "adds a line to the order by providing a inventory_code" do
      
    end
    
    it "adds a line to the order by providing a model_id" do
      
    end
  end
end
