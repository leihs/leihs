# encoding: utf-8

When(/^ich in den Admin-Bereich wechsel$/) do
  visit backend_inventory_pools_path
  current_path.should == backend_inventory_pools_path
end
