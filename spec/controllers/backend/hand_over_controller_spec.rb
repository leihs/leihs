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
      pending
    end
    
    context "without selecting an item_line" do
      pending
    end
  end

  describe "a visit" do
    it "that is overdue, should be deleted and respond with success" do
      @visit = Visit.hand_over.where("date < ?", Date.today).first
    end

    it "that is on the future, should be deleted and respond with success" do
      @visit = Visit.hand_over.where("date >= ?", Date.today).first
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