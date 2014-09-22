When /^I open the datepicker|I click the open button again$/ do
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

Then /^the datepicker closes$/ do
  expect(has_no_selector?(".ui-datepicker")).to be true
end
