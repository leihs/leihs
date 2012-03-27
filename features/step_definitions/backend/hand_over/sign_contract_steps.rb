When /^I open a hand over$/ do
  @ip = @user.managed_inventory_pools.first
  @customer = @ip.users.all.detect {|x| x.contracts.unsigned.count > 0}
  visit backend_inventory_pool_user_hand_over_path(@ip, @customer)
  page.has_css?("#hand_over", :visible => true)
end

When /^I select an item line by assigning an inventory code$/ do
  @item_line = @customer.visits.first.lines.detect {|x| x.class.to_s == "ItemLine"}
  item = @ip.items.detect {|x| x.model == @item_line.model}
  @selected_items = [item]
  @line = find("li.name",:text => @item_line.model.name).find(:xpath, "./../..")
  @line.find(".inventory_code input").set item.inventory_code
  @line.find(".inventory_code input").native.send_key(:enter)
  wait_until { @line.has_xpath?(".[contains(@class, 'assigned')]") }
end

Then /^I see a summary of the things I selected for hand over$/ do
  @selected_items.each do |item|
    find(".dialog").should have_content(item.model.name)
  end
end

When /^I click hand over$/ do
  find("#hand_over_button").click
end

When /^I click hand over inside the dialog$/ do
  find(".dialog .button", :text => "Hand Over").click
  wait_until { ! page.has_css?(".dialog")}
end

Then /^the contract is signed for the selected items$/ do
  to_take_back_lines = @customer.visits.take_back.flat_map &:contract_lines
  @selected_items.each do |item|
    to_take_back_lines.map(&:item).include?(item).should be_true
  end
end
