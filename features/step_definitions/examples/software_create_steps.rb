When(/^I create a new software license$/) do
  visit manage_new_item_path(inventory_pool_id: @current_inventory_pool.id, type: :license)
end

When(/^the possible currencies are$/) do |table|
  table.raw.flatten.each do |s|
    within "select[name='item[properties][maintenance_currency]']" do
      find("option[value='#{s}']")
    end
  end
end

When(/^I select "(.*?)" from the field currency$/) do |arg1|
  within "select[name='item[properties][maintenance_currency]']" do
    find("option[value='#{arg1}']").select_option
  end
end

When(/^I type the amount "(.*?)" into the field "(.*?)"$/) do |arg1, arg2|
  case arg2
    when "maintenance amount"
      find("input[name='item[properties][maintenance_price]']").set arg1
    else
      raise
  end
end

When /^I save$/ do
  find("button", :text => /#{_("Save")}/i).click
end

Then(/^the "(.*?)" is saved as "(.*?)"$/) do |arg1, arg2|
  last_created_software_license = @current_inventory_pool.items.licenses.sort_by(&:created_at).last
  visit manage_edit_item_path(@current_inventory_pool, last_created_software_license)
  case arg1
    when "maintenance currency"
      expect(find("select[name='item[properties][maintenance_currency]']").value).to eq arg2
    when "maintenance amount"
      expect(find("input[name='item[properties][maintenance_price]']").value).to eq arg2
    else
      raise
  end
end

