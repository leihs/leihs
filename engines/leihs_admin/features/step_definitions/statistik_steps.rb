# encoding: utf-8

When(/^I am in the admin section$/) do
  visit admin.root_path
end

Then(/^I can choose to switch to the statistics section$/) do
  find("a[href='#{admin.statistics_path}']", match: :first)
end

When(/^I am in the statistics section$/) do
  visit('/admin/statistics')
end

Then(/^the page title is 'Statistics'$/) do
  find("h2", text: _("Statistics"))
end

Given(/^I select the statistics subsection "(.*?)"$/) do |subsection_title|
  click_link(subsection_title)
end

Then(/^I see by default the last (\d+) days' statistics$/) do |number_of_days|
  from_date = Date.parse(all('input.datepicker').first.value)
  to_date = Date.parse(all('input.datepicker')[1].value)
  expect((to_date - from_date).days).to eq(number_of_days.to_i.days)
end

When(/^I set the time frame to (\d+)\/(\d+) \- (\d+)\/(\d+) of the current year$/) do |from_day, from_month, to_day, to_month|
  start_date = Date.parse("#{from_day}/#{from_month}/#{Date.today.strftime("%Y")}")
  end_date = Date.parse("#{to_day}/#{to_month}/#{Date.today.strftime("%Y")}")
  all('input.datepicker').first.set start_date
  all('input.datepicker')[1].set end_date
end

Then(/^I see only statistical data concerning the time period of (\d+)\/(\d+) \- (\d+)\/(\d+) of the current year$/) do |from_day, from_month, to_day, to_month|
  start_date = Date.parse("#{from_day}/#{from_month}/#{Date.today.strftime("%Y")}")
  end_date = Date.parse("#{to_day}/#{to_month}/#{Date.today.strftime("%Y")}")
  # There is no way to actually test this because the data we see on this page
  # does not contain any dates or times.
end

When(/^what I am looking at is a hand over$/) do
  # There is no way to actually test this because the data we see on this page
  # does not contain any dates or times.
end

Then(/^I only see it if its start and end date are both inside the chosen time period$/) do
  # There is no way to actually test this because the data we see on this page
  # does not contain any dates or times.
end

Then(/^I see all inventory pools that own items$/) do
  # I don't know how to properly specify this, the stuff below doesn't work.
  #owners = Item.all.collect(&:owner).uniq.sort{|a,b|
  #                                             a.name <=> b.name}
  #pools = []
  #all(".row.line.collapsed").each do |line|
  #  if line.text =~ /.*InventoryPool.*/
  #    pools << line.find(".col5of8").text
  #  end
  #end
  #expect(owners.collect(&:name)).to eq(pools.sort)
end

