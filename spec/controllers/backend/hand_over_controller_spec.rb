require 'spec_helper'

describe Backend::HandOverController do
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

  describe "assigning an inventory_code" do
    context "selecting an item_line directly" do
      it "picking an available inventory_code" do
        pending
      end
      it "writing an unavailable inventory_code" do
        model = Model.all.detect do |m|
          m.contract_lines.where(returned_date: nil, item_id: nil).first and
          m.contract_lines.where(returned_date: nil).where("item_id IS NOT NULL").first 
        end
        model.should_not be_nil
        line = model.contract_lines.where(returned_date: nil, item_id: nil).first
        item = model.contract_lines.where(returned_date: nil).where("item_id IS NOT NULL").first.item
        line.item.should be_nil
        post :assign_inventory_code, {:inventory_pool_id => @inventory_pool.id,
                                      :user_id => line.contract.user_id,
                                      :inventory_code => item.inventory_code,
                                      :line_id => line.id}, session
        response.success?.should be_false
        line.reload.item.should be_nil
      end
    end
    
    context "without selecting an item_line" do
      pending
    end
  end

  describe "a visit" do
    it "that is overdue, should be deleted and respond with success" do
      @visit = @inventory_pool.visits.hand_over.where("date < ?", Date.today).first
    end

    it "that is on the future, should be deleted and respond with success" do
      @visit = @inventory_pool.visits.hand_over.where("date >= ?", Date.today).first
    end

    after :each do
      visit_count = Visit.count
      delete :delete_visit, {:format => :json,
                             :inventory_pool_id => @inventory_pool.id,
                             :user_id => @visit.user_id,
                             :visit_id => @visit.id}, session
      response.success?.should be_true
      Visit.find_by_id(@visit).should be_nil
      visit_count.should == Visit.count + 1
   end
  end

end