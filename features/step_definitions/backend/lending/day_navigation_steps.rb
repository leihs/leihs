When /^I open the datepicker$/ do
  first(".button.datepicker").click
end

When /^I select a specific date$/ do
  first(".ui-datepicker")
  first("a.ui-datepicker-next").click
  @day = first(".ui-state-default").text
  @month = first(".ui-datepicker-month").text
  @year = first(".ui-datepicker-year").text
  first(".ui-state-default").click
end

Then /^the daily view jumps to that day$/ do
  first("h1").should have_content @day
  first("h1").should have_content @month
  first("h1").should have_content @year
end

When /^I click the open button again$/ do
  first(".button.datepicker").click
end

Then /^the datepicker closes$/ do
  sleep(1) # wait until the fadeOut animation is finished
  all(".ui-datepicker", :visible => true).size.should == 0
end