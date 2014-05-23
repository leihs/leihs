Given(/^I log out$/) do
  visit logout_path
  has_content? "You have been logged out."
end

When(/^I visit the homepage$/) do
  visit root_path
end

When(/^I login as "(.*?)" via web interface$/) do |persona|
  @current_user = User.where(:login => persona.downcase).first
  I18n.locale = if @current_user.language then @current_user.language.locale_name.to_sym else Language.default_language end
  visit root_path
  find("a[href='#{login_path}']", match: :first).click
  fill_in 'username', :with => persona.downcase
  fill_in 'password', :with => 'password'
  first("[type='submit']").click
end

Then(/^I am logged in$/) do
  page.should have_content @current_user.short_name
end

