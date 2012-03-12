Given /^I am logged out$/ do
  visit "/logout"
end

When /^I visit the homepage$/ do
  visit "/"
end

When /^I login$/ do
  find("#login").click
  fill_in 'username', :with => @user.login
  fill_in 'password', :with => 'password'
  find(".login .button").click
end

Then /^I am logged in$/ do
  page.has_css?("#main.wrapper", :visible => true)  
end