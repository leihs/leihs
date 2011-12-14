Given "a $role for inventory pool '$ip_name' logs in as '$who'" do | role, ip_name, who |
  Given "a #{role} '#{who}' for inventory pool '#{ip_name}'"
  When "I log in as '#{who}' with password 'pass'" # use default pw
  @last_manager_login_name = who
end

Given "I log in as a $role for inventory pool '$ip_name'$with_access_level" do |role, ip_name,with_access_level|
  # use default user name
  Given "a #{role} 'inv_man_0' for inventory pool '#{ip_name}'#{with_access_level}"

  When "I log in as 'inv_man_0' with password 'pass'" # use default pw
  @last_manager_login_name = 'inv_man_0'
end

# This one 'really' goes through the auth process
When /^I log in as '([^']*)' with password '([^']*)'$/ do |who,password|
  When 'I go to the home page'
  fill_in 'login_user',     :with => who
  fill_in 'login_password', :with => password
  click_button 'Login'
end

Given /(his|her) password is '([^']*)'$/ do |foo,password|
  Factory.create_db_auth( :login => @user.login,
			  :password => password)
end

When 'I log in as the admin' do
  Given 'I am on the home page'
   When 'I make sure I am logged out'
    And 'I fill in "login_user" with "super_user_1"'
    And 'I fill in "login_password" with "pass"'
    And 'I press "Login"'
end


# It's possible that previous steps leave the running browser instance in a logged-in
# state, which confuses tests that rely on "When I log in as the admin".
When 'I make sure I am logged out' do
  visit "/logout"
end
