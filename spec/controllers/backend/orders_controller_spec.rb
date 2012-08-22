require 'spec_helper'

describe Backend::OrdersController do
  render_views
  
  before :all do
    Persona.create :petra
    Persona.create :normin
    @lending_manager = Persona.create :pius
    @inventory_pool = @lending_manager.inventory_pools.first
  end

  let :session do
    {user_id: @lending_manager.id}
  end

  describe "index" do
    
    it "provides all submitted/pending orders" do
      get :index, {inventory_pool_id: @inventory_pool, filter: "pending", format: "json"}, session
      json = JSON.parse response.body
      json.each do |order|
        order["lines"].each do |line|
          OrderLine.find_by_id(line["id"].to_i).order.status_const.should == Order::SUBMITTED
        end
      end
    end
  end
end