When /^I pick the model "([^"]*)" from the list$/ do |model_name|
  find("tr", :text => /#{model_name}/).find_link("Show").click
end

Then /^the model "([^"]*)" should be in category "([^"]*)"$/ do |model_name, category_name|
  When "I follow the sloppy link \"All Models\""
  category_list = find("tr", :text => "#{model_name}").all("ul")[3]
  category_list.text.should =~ /#{category_name}/
  #And "I pick the model \"#{model_name}\" from the list"
  #And "I follow the sloppy link \"Categories\" within \"#model_backend_tabnav\"" 
  #Then "I should see \"#{model_name}\""  
  #And "I should see \"#{category_name}\""
end

# We wrap some steps in this so that it's guaranteed that we get a logout. This is
# necessary so any "I log in as...." steps in the Background section actually work, as
# they don't work when a user is already logged in. This prevents failing steps from
# breaking following tests.
After('@logoutafter') do
  And "I follow the sloppy link \"Logout\""
end