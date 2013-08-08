Given /^test data setup for "Hand over controller" feature$/ do
  @lending_manager = @current_user
  @inventory_pool = @lending_manager.inventory_pools.first
end

Given /^test data setup for scenario "Writing an unavailable inventory code"$/ do
  model = Model.all.detect do |m|
    m.contract_lines.where(returned_date: nil, item_id: nil).first and
    m.contract_lines.where(returned_date: nil).where("item_id IS NOT NULL").first 
  end
  model.should_not be_nil
  @line = model.contract_lines.where(returned_date: nil, item_id: nil).first
  @item = model.contract_lines.where(returned_date: nil).where("item_id IS NOT NULL").first.item
  @line.item.should be_nil
end

When /^an unavailable inventory code is assigned to a contract line$/ do
  @response = post assign_inventory_code_backend_inventory_pool_user_hand_over_path(@inventory_pool, @line.contract.user_id,), {:inventory_code => @item.inventory_code,
                                                                                                                            :line_id => @line.id}
end

Then /^the response from this action should not be successful$/ do
  @response.should_not be_successful
end

Then /^the contract line has no item$/ do
  @line.reload.item.should be_nil
end

Given /^visit that is overdue$/ do
  @visit = @inventory_pool.visits.hand_over.where("date < ?", Date.today).first
end

Given /^visit that is in future$/ do
  @visit = @inventory_pool.visits.hand_over.where("date >= ?", Date.today).first
end

When /^the visit is deleted$/ do
  @visit_count = Visit.count
  @response = delete delete_visit_backend_inventory_pool_user_hand_over_path(@inventory_pool, @visit.user), {:format => :json, :visit_id => @visit.id}
end

Then /^the visit does not exist anymore$/ do
  Visit.find_by_id(@visit).should be_nil
  @visit_count.should == Visit.count + 1
end

When /^the index action of the visits controller is called with the filter parameter "take back" and a given date$/ do
  @date = Date.today
  response = get backend_inventory_pool_visits_path(@inventory_pool), {date: @date.to_s, filter: "take_back", format: "json"}
  @json = JSON.parse response.body
end

When /^the index action of the visits controller is called with the filter parameter "hand over" and a given date$/ do
  @date = Date.today
  response = get backend_inventory_pool_visits_path(@inventory_pool), {date: @date.to_s, filter: "hand_over", format: "json"}
  @json = JSON.parse response.body
end

Then /^the result of this action are all take back visits for the given inventory pool and the given date$/ do
  @json.each do |visit|
    visit["action"].should == "take_back"
    if @date <= Date.today
      Date.parse(visit["date"]).should <= @date
    else 
      Date.parse(visit["date"]).should == @date
    end
  end
end

Then /^the result of this action are all hand over visits for the given inventory pool and the given date$/ do
  @json.each do |visit|
    visit["action"].should == "hand_over"
    if @date <= Date.today
      Date.parse(visit["date"]).should <= @date
    else 
      Date.parse(visit["date"]).should == @date
    end
  end
end
