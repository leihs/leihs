require 'spec_helper'

describe Backend::VisitsController do
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
    

    context "provides by specific date" do

      before :all do
        @date = Date.today
      end

      it "provides take backs" do
        get :index, {inventory_pool_id: @inventory_pool, date: @date.to_s, filter: "take_back", format: "json"}, session
        json = JSON.parse response.body
        json.each do |visit|
          visit["action"].should == "take_back"
          if @date <= Date.today
            Date.parse(visit["date"]).should <= @date
          else 
            Date.parse(visit["date"]).should == @date
          end
        end
      end

      it "provides hand overs" do
        get :index, {inventory_pool_id: @inventory_pool, date: @date.to_s, filter: "hand_over", format: "json"}, session
        json = JSON.parse response.body
        json.each do |visit|
          visit["action"].should == "hand_over"
          if @date <= Date.today
            Date.parse(visit["date"]).should <= @date
          else 
            Date.parse(visit["date"]).should == @date
          end
        end
      end
    end
  end
end