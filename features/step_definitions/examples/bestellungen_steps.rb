# -*- encoding : utf-8 -*-

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

When(/^ich öffne eine Bestellung von ein gesperrter Benutzer$/) do
  user = @current_inventory_pool.contracts.submitted.sample.user
  ensure_suspended_user(user, @current_inventory_pool)
  step 'ich öffne eine Bestellung von "%s"' % user
end

When(/^sehe ich neben seinem Namen den Sperrstatus 'Gesperrt!'$/) do
  find("span.darkred-text", text: "%s!" % _("Suspended"))
end

def ensure_suspended_user(user, inventory_pool)
  unless user.suspended?(inventory_pool)
    user.access_rights.active.where(inventory_pool_id: inventory_pool).first.update_attributes(suspended_until: Date.today + 1.year, suspended_reason: "suspended reason")
    user.suspended?(inventory_pool).should be_true
  end
end