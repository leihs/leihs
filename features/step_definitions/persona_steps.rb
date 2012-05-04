Given /^I am "([^"]*)"$/ do |persona_name|
  step "I am logged in as '%s' with password 'password'" % persona_name.downcase
  step 'I login'
end

Angenommen /^man ist "([^"]*)"$/ do |persona_name|
  step "I am logged in as '%s' with password 'password'" % persona_name.downcase
  step 'I login'
end