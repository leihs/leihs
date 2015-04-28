Given(/^I log out$/) do
  visit logout_path
  find('#flash') #FIXME#translation problem# text: _("You have been logged out.")
end

When(/^I visit the homepage$/) do
  visit root_path
end

When(/^I login as "(.*?)" via web interface$/) do |persona|
  @current_user = User.where(login: persona.downcase).first
  I18n.locale = if @current_user.language then
                  @current_user.language.locale_name.to_sym
                else
                  Language.default_language
                end
  step 'I visit the homepage'
  find("a[href='#{login_path}']", match: :first).click
  fill_in 'username', with: persona.downcase
  fill_in 'password', with: 'password'
  find("[type='submit']", match: :first).click
end

Then(/^I am logged in$/) do
  expect(has_content?(@current_user.short_name)).to be true
end

Given(/^my authentication system is "(.*?)"$/) do |arg1|
  expect(@current_user.authentication_system.class_name).to eq arg1
end

When(/^I hover over my name$/) do
  find("nav.topbar ul.topbar-navigation a[href='/borrow/user']", text: @current_user.short_name).hover
end

When(/^I view my user data$/) do
  find("ul.dropdown a.dropdown-item[href='/borrow/user']", text: _('User data')).click
  step %Q(I get to the "User Data" page)
end

Then(/^I get to the "(.*?)" page$/) do |arg1|
  case arg1
    when 'User Data'
      expect(current_path).to eq borrow_current_user_path
    else
      raise
  end
end

When(/^I change my password$/) do
  @new_password = Faker::Internet.password(6)
  find('.row', match: :prefer_exact, text: _('Password')).find("input[name='db_auth[password]']").set @new_password
  find('.row', match: :prefer_exact, text: _('Password Confirmation')).find("input[name='db_auth[password_confirmation]']").set @new_password
  find(".row button[type='submit']", text: _('Save')).click
  step %Q(I get to the "User Data" page)
end

Then(/^my password is changed$/) do
  find('#flash .success', text: _('Password changed'))
  dbauth = DatabaseAuthentication.authenticate(@current_user.login, @new_password)
  expect(dbauth).not_to be_nil
  expect(dbauth.user).to eq @current_user
end
