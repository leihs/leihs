Given(/^the LDAP authentication system is enabled and configured$/) do
  as = AuthenticationSystem.where(:class_name => "LdapAuthentication").first
  as.is_active = true
  expect(as.save).to be true
  Setting::LDAP_CONFIG = File.join(Rails.root, "features", "data", "LDAP_generic.yml")
end

When(/^there are some inventory pools with automatic access enabled$/) do
      3.times do
        FactoryGirl.create :inventory_pool
      end
      ips_with_automatic_access = InventoryPool.all.sample(2)
      ips_with_automatic_access.each {|ip| ip.update_attributes automatic_access: true}
end

When(/^I log in as LDAP user "(.*?)"$/) do |username|
  post 'authenticator/ldap/login', {:login => { :user => username, :password => "pass" }}, {}
end

Then(/^a leihs user should exist for "(.*?)"$/) do |username|
  expect(User.where(:login => username).exists?).to be true
end

Then(/^the user "(.*?)" should have LDAP as an authentication system$/) do |username|
  as = AuthenticationSystem.where(:class_name => "LdapAuthentication").first
  expect(as).not_to be nil
  expect(User.where(:login => username).first.authentication_system).to eq as
end

Then(/^the user "(.*?)" should not have any admin privileges$/) do |username|
  user = User.where(:login => username).first
  access_rights = user.access_rights.where(role: "customer")
  expect(access_rights.count).to be > 0
  expect(user.access_rights.active.collect(&:role).include?(:admin)).to be false
end

Then(/^the user "(.*?)" should have admin privileges$/) do |username|
  user = User.where(:login => username).first
  expect(user.access_rights.active.collect(&:role).include?(:admin)).to be true
end

