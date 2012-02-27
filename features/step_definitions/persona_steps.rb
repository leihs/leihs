Given /^personas are loaded$/ do

  Persona.create("Mike") # Mike should be created first, he is setting up the application

end

Given /^I am "(\w+)"$/ do |persona_name|
  # step 'I log in as "%s" with password "password"' % persona_name.downcase
  # step 'I am logged in as "%s"' % persona_name.downcase
end
