Angenommen(/^es existiert eine leere Bestellung$/) do
  @current_inventory_pool = @current_user.managed_inventory_pools.first
  @customer = @current_inventory_pool.users.find{|u| u.visits.hand_over.count == 0}
  visit manage_hand_over_path @current_inventory_pool, @customer
  @contract = @current_inventory_pool.contracts.approved.where(user_id: @customer.id).last
end

Dann(/^sehe ich diese Bestellung nicht in der Liste der Bestellungen$/) do
  find('a', text: _('Orders')).click
  page.should_not have_selector("[data-id='#{@contract.id}']")
end