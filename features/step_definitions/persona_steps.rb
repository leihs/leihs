Given /^personas are loaded$/ do

  #Persona.create("Ramon") # Ramon should created wirst, he is setting up the Application
  #Persona.create("Mike") 
  #Persona.create("Pius") 

end

Given /^I am "(\w+)"$/ do |persona_name|
  step 'I am logged in as "%s" with password "password"' % persona_name.downcase
end
