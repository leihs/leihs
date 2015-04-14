Given /^test data setup for "Hand over controller" feature$/ do
  @lending_manager = @current_user
  @inventory_pool = @lending_manager.inventory_pools.first
end

Given /^test data setup for scenario "Writing an unavailable inventory code"$/ do
  model = @inventory_pool.models.detect do |m|
    m.contract_lines.joins(:contract).where(contracts: {inventory_pool_id: @inventory_pool}, returned_date: nil, item_id: nil).exists? and
      m.contract_lines.joins(:contract).where(contracts: {inventory_pool_id: @inventory_pool}, returned_date: nil).where.not(item_id: nil).exists?
  end
  expect(model).not_to be_nil
  @line = model.contract_lines.joins(:contract).where(contracts: {inventory_pool_id: @inventory_pool}, returned_date: nil, item_id: nil).order("RAND()").first
  expect(@line).not_to eq nil
  @item = model.contract_lines.joins(:contract).where(contracts: {inventory_pool_id: @inventory_pool}, returned_date: nil).where.not(item_id: nil).order("RAND()").first.item
  expect(@line.item).to eq nil
end

When /^an unavailable inventory code is assigned to a contract line$/ do
  @response = post "/manage/#{@inventory_pool.id}/contract_lines/#{@line.id}/assign", {:inventory_code => @item.inventory_code}
end

Then /^the response from this action should( not)? be successful$/ do |arg1|
  expect(@response.successful?).to be !arg1
end

Then /^the contract line has no item$/ do
  expect(@line.reload.item).to eq nil
end

Given /^visit that is (.*)$/ do |arg1|
  sign = case arg1
           when "overdue"
             "<"
           when "in future"
             ">="
           else
             raise
         end
  @visit = @inventory_pool.visits.hand_over.where("date #{sign} ?", Date.today).first
end

When /^the visit is deleted$/ do
  @visit_count = Visit.count
  @response = delete "/manage/#{@inventory_pool.id}/visits/#{@visit.id}.json"
end

Then /^the visit does not exist anymore$/ do
  expect(Visit.find_by_id(@visit)).to eq nil
  expect(@visit_count).to eq Visit.count + 1
end

When /^the index action of the visits controller is called with the filter parameter "(hand_over|take back)" and a given date$/ do |arg1|
  @date = Date.today
  path = case arg1
           when "hand over"
             "/manage/#{@inventory_pool.id}/visits/hand_overs.json"
           when "take back"
             "/manage/#{@inventory_pool.id}/visits/take_backs.json"
         end
  response = get path, {date: @date.to_s, date_comparison: "lteq"}
  @json = JSON.parse response.body
end

Then /^the result of this action are all (hand over|take back) visits for the given inventory pool and the given date$/ do |arg1|
  expect(@json.empty?).to be false
  @json.each do |visit|
    expect(visit["action"]).to eq arg1.gsub(/\s/,'_')
    if @date <= Date.today
      expect(Date.parse(visit["date"])).to be <= @date
    else 
      expect(Date.parse(visit["date"])).to eq @date
    end
  end
end
