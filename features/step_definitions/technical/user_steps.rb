Given(/^there are at least (\d+) users with late take backs from at least (\d+) inventory pools where automatic suspension is activated$/) do |users_n, ips_n|
  @contract_lines = ContractLine.signed.where("end_date < ?", Date.today).uniq{|cl| cl.inventory_pool and cl.user}
  expect(@contract_lines.count).to be >= 2
end

When(/^the cronjob executes the rake task for reminding and suspending all late users$/) do
  User.remind_and_suspend_all
end

Then(/^every such user is suspended until '(\d+)\.(\d+)\.(\d+)' in the corresponding inventory pool$/) do |day, month, year|
  @contract_lines.each do |c|
    ip = c.inventory_pool
    u = c.user
    ar = u.access_right_for(ip)
    expect(ar.suspended_until).to eq Date.new(year.to_i, month.to_i, day.to_i)
  end
end

Then(/^the suspended reason is the one configured for the corresponding inventory pool$/) do
  @contract_lines.each do |c|
    ip = c.inventory_pool
    u = c.user
    ar = u.access_right_for(ip)
    ar.suspended_reason == ip.automatic_suspension_reason
  end
end


Then(/^a user with login "(.*?)" exists$/) do |arg1|
  @user = User.find_by(login: arg1)
  expect(@user).not_to be nil
end

Then(/^the login of this user is longer than (\d+) chars$/) do |arg1|
  expect(@user.login.size).to be > 40
end
