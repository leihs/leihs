Given /^the admin$/ do
  # ensure that the super user exists - the DB should
  # be preseeded with one (see db/seeds.rb)
  @user = AccessRight.find_by_role(:admin).user
end

Given /^a customer "([^"]*)"( exists)?$/ do |name,foo|
  @user = LeihsFactory.create_user({:login => name },
                                   {:role => :customer,
                                   :inventory_pool => @inventory_pool})
  r = @user.access_rights.active.first
  r.save
end

Given /a (\w+) '([^']*)' for inventory pool '([^']*)'$/ do |role,who,ip_name|
  step "inventory pool '#{ip_name}'"
  role = role.to_sym
  @user = LeihsFactory.create_user({:login => who},
                                   {:role => role,
                                    :inventory_pool => InventoryPool.find_by_name(ip_name),
                                    :password => 'pass' })
  assert_not_nil role
  @user.save!
end

Given /^he is a (\w+)$/ do |role|
  LeihsFactory.define_role @user, @inventory_pool, role
end

Given "customer '$who' has access to inventory pool $ip_s" do |who, ip_s|
  inventory_pools = ip_s.split(" and ").collect { | ip_name |
    InventoryPool.find_by_name ip_name
  }
  user = User.find_by_login(who) || FactoryGirl.create(:user, :login => who)
  inventory_pools.each { |ip|
    LeihsFactory.define_role(user, ip, :customer)
    expect(user.inventory_pools.include?(ip)).to be true
  }
end

When /^I create a new user '([^']*)' at '([^']*)'( in ')?([^']*)'?$/ \
do |name,email,filler,ip|
  step "I create a new inventory pool '#{ip}'" unless ip.blank?

  # TODO: for some reason, cucumber sometimes won't properly clean up
  # the DB between runs
  User.find_by_login(name).try(:delete)
  # the link is called "All Users (1)" in the backend view
  # and "Users (1)" in the backend/inventory_pool view
  click_link 'Users ('
  click_link_or_button 'Create'
  fill_in 'user_lastname', :with => name
  fill_in 'user_email', :with => email
  click_button 'Submit'
end

Given "'$name' has password '$pass'" do |name,pass|
  LeihsFactory.create_db_auth(:login => name, :password => pass)
end
