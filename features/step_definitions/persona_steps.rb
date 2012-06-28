Given /^personas existing$/ do
  Persona.create_all
end

Given /^I am "([^"]*)"$/ do |persona_name|
  step "I am logged in as '%s' with password 'password'" % persona_name.downcase
  step 'I login'
end

Angenommen /^man ist "([^"]*)"$/ do |persona_name|
  step "I am logged in as '%s' with password 'password'" % persona_name.downcase
  step 'I login'
end

Angenommen /^Personas existieren$/ do
  step 'personas existing'
end