When /^I open the datepicker$/ do
  find(".button.datepicker", match: :first).click
end

When /^I select a specific date$/ do
  find(".ui-datepicker", match: :first)
  find("a.ui-datepicker-next", match: :first).click
  @day = find(".ui-state-default", match: :first).text
  @month = find(".ui-datepicker-month", match: :first).text
  @year = find(".ui-datepicker-year", match: :first).text
  find(".ui-state-default", match: :first).click
end

Then /^the daily view jumps to that day$/ do
  find("h1", match: :first) do
    expect(has_content?(@day)).to be true
    expect(has_content?(@month)).to be true
    expect(has_content?(@year)).to be true
  end
end

When /^I click the open button again$/ do
  find(".button.datepicker", match: :first).click
end

Then /^the datepicker closes$/ do
  sleep(0.33) # wait until the fadeOut animation is finished
  expect(all(".ui-datepicker", :visible => true).size).to eq 0
end
