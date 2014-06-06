# -*- encoding : utf-8 -*-

Given /^I am ([a-zA-Z]*)$/ do |persona_name|
  step 'man ist eingeloggt als "%s"' % persona_name
  @current_inventory_pool = @current_user.managed_inventory_pools.first
end

Angenommen(/^man ist ein Kunde$/) do
  user = AccessRight.where(role: :customer).map(&:user).uniq.sample
  step "I am %s" % user.firstname
end

Angenommen(/^man ist ein Kunde mit Verträge$/) do
  user = Contract.where(status: [:signed, :closed]).select{|c| c.lines.any? &:returned_to_user}.map(&:user).select{|u| not u.access_rights.active.blank?}.uniq.sample
  step %Q(I am logged in as '#{user.login}' with password 'password')
end
