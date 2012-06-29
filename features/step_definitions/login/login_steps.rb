When /^"([^"]*)" sign in successfully he is redirected to the "([^"]*)" section$/ do |login, section_name|
  visit "/logout"
  visit "/"
  find("#login").click
  fill_in 'username', :with => login.downcase
  fill_in 'password', :with => 'password'
  find(".login .button").click
  page.has_css?("#main.wrapper", :visible => true)
  find(".navigation .active.#{section_name.downcase}")
end