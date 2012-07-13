When /^I open the datepicker$/ do
  find(".button.datepicker").click
end

When /^I select a specific date$/ do
  wait_until { find(".ui-datepicker") }
  find("a.ui-datepicker-next").click
  @day = find(".ui-state-default").text
  @month = find(".ui-datepicker-month").text
  @year = find(".ui-datepicker-year").text
  find(".ui-state-default").click
end

Then /^the daily view jumps to that day$/ do
  find("h1").should have_content @day
  find("h1").should have_content @month
  find("h1").should have_content @year
end

When /^I click the open button again$/ do
  find(".button.datepicker").click
end

Then /^the datepicker closes$/ do
  sleep(1) # wait until the fadeOut animation is finished
  wait_until { all(".ui-datepicker", :visible => true).size == 0 }
end