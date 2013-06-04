Given /^personas existing$/ do
  Persona.create_all
end

Angenommen(/^persona "(.*?)" existing$/) do |persona_name|
  Persona.create persona_name
end

Given /^I am "([^"]*)"$/ do |persona_name|
  step 'persona "%s" existing' % persona_name
  step 'man ist eingeloggt als "%s"' % persona_name
  @current_inventory_pool = @current_user.managed_inventory_pools.first 
end

Angenommen /^man ist "([^"]*)"$/ do |persona_name|
  step 'I am "%s"' % persona_name
end

Angenommen /^Personas existieren$/ do
  step 'personas existing'
end
