# -*- encoding : utf-8 -*-

Given /^personas existing$/ do
  Persona.create_all
end

Angenommen(/^persona "(.*?)" existing$/) do |persona_name|
  Persona.create persona_name
end

Given /^I am "(.*)"$/ do |persona_name|
  persona_name = persona_name.gsub "\"", ""
  step 'persona "%s" existing' % persona_name
  step 'man ist eingeloggt als "%s"' % persona_name
  @current_inventory_pool = @current_user.managed_inventory_pools.first 
end

Angenommen(/^ich bin (.*?)$/) do |persona_name|
  step 'I am "%s"' % persona_name
end

Angenommen /^man ist "([^"]*)"$/ do |persona_name|
  step 'I am "%s"' % persona_name
end

Angenommen /^Personas existieren$/ do
  step 'personas existing'
end

Angenommen(/^man ist ein Kunde$/) do
  user = AccessRight.where(role_id: Role.find_by_name("customer")).map(&:user).uniq.sample
  step 'I am "%s"' % user.firstname
end

Angenommen(/^man ist ein Kunde mit Verträge$/) do
  user = Contract.where(status: [:signed, :closed]).select{|c| c.lines.any? &:returned_to_user}.map(&:user).select{|u| not u.access_rights.blank?}.uniq.sample
  step %Q(I am logged in as '#{user.login}' with password 'password')
end
