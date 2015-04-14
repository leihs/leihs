Given "a $role for inventory pool '$ip_name' logs in as '$who'" do | role, ip_name, who |
  step "a #{role} '#{who}' for inventory pool '#{ip_name}'"
  step "I log in as '#{who}' with password 'pass'" # use default pw
  @last_manager_login_name = who
end

# This does NOT go through the UI. It simply logs in the user.
# for 99% of our Cucumber scenarios, we don't need the UI at all!
Given "a $role for inventory pool '$ip_name' is logged in as '$who'" do | role, ip_name, who |
  step "a #{role} '#{who}' for inventory pool '#{ip_name}'"
  step "I am logged in as '#{who}' with password 'foobar'"
  @last_manager_login_name = who
end

Given "I am logged in as '$username' with password '$password'" do |username, password|
  @current_user = User.where(:login => username.downcase).first
  I18n.locale = if @current_user.language then @current_user.language.locale_name.to_sym else Language.default_language end
  @current_inventory_pool = @current_user.inventory_pools.managed.first
  case Capybara.current_driver
    when /selenium/
      visit "/"
      find("[href='#{login_path}']", match: :first).click
      fill_in 'username', :with => username
      fill_in 'password', :with => password
      find("[type='submit']", match: :first).click
    when :rack_test
      step "I log in as '%s' with password '%s'" % [username, password]
  end
end

Given "I log in as a $role for inventory pool '$ip_name'$with_access_level" do |role, ip_name,with_access_level|
  # use default user name
  step "a #{role} 'inv_man_0' for inventory pool '#{ip_name}'#{with_access_level}"

  step "I log in as 'inv_man_0' with password 'pass'" # use default pw
  @last_manager_login_name = 'inv_man_0'
end

# This one 'really' goes through the auth process
When /^I log in as '([^']*)' with password '([^']*)'$/ do |username, password|
  @current_user = User.where(:login => username.downcase).first
  @current_inventory_pool = @current_user.inventory_pools.managed.first
  post "/authenticator/db/login", {:login => {:username => username, :password => password}}
end

Given /(his|her) password is '([^']*)'$/ do |foo,password|
  LeihsFactory.create_db_auth( :login => @user.login, :password => password)
end

When 'I log in as the admin' do
  step 'I am on the home page'
  step 'I make sure I am logged out'
  step 'I fill in "login_user" with "super_user_1"'
  step 'I fill in "login_password" with "pass"'
  step 'I press "Login"'
end

# It's possible that previous steps leave the running browser instance in a logged-in
# state, which confuses tests that rely on "When I log in as the admin".
When 'I make sure I am logged out' do
  step "I log out"
end

When /^I am redirected to the "([^"]*)" section$/ do |section_name|
  find("nav#topbar .topbar-navigation .active", match: :prefer_exact, text: _(section_name))
end

#Angenommen(/^man ist eingeloggt als "(.*?)"$/) do |persona|
Given(/^I am logged in as "(.*?)"$/) do |persona|
  step "I make sure I am logged out"
  @current_user = User.where(:login => persona.downcase).first
  I18n.locale = if @current_user.language then @current_user.language.locale_name.to_sym else Language.default_language end
  page.set_rack_session user_id: @current_user.id
  step "I visit the homepage"
end
