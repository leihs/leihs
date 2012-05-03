When /^I delete a line$/ do
  @contract = @customer.contracts.unsigned.first
  @line = @contract.lines.first
  @line_element = find(".line", :text => @line.model.name)
  step 'I delete this line element'
end

When /^I delete this line element$/ do
  @line_element.find(".multibutton .trigger").click
  @line_element.find(".button", :text => "Delete").click
  wait_until{ all(".loading", :visible => true ).size == 0 }  
  sleep(0.6)
end

Then /^this line is deleted$/ do
  lambda {@line.reload}.should raise_error(ActiveRecord::RecordNotFound) 
end

When /^I select multiple lines$/ do
  @selected_lines = @hand_over.lines.map do |line|
    line = all(".line", :text => line.model.name).detect {|x| not x.find(".select input").checked?}
    line.find(".select input").click
    line
  end
end

When /^I delete the seleted lines$/ do
  page.execute_script('$("#selection_actions .multibutton .button").show()')
  find("#selection_actions .multibutton .button", :text => "Delete").click
  wait_until { all(".loading", :visible => true).size == 0 }
  sleep(0.5)
end

Then /^these lines are deleted$/ do
  @selected_lines.each do |line|
    lambda {line.click}.should raise_error(Selenium::WebDriver::Error::StaleElementReferenceError) 
  end
  lambda {@hand_over.reload}.should raise_error(ActiveRecord::RecordNotFound)
end

When /^I delete all lines of a model thats availability is blocked by these lines$/ do
  step 'I add so many lines that I break the maximal quantity of an model'
  all(".line", :text => @model.name).each do |line|
    line[:class].match("error").should be_true
  end
  
  (all(".line", :text => @model.name).size-1).times do
    @line_element = find(".line", :text => @model.name)
    step 'I delete this line element'
  end
end

Then /^the availability of the keeped line is updated$/ do
  line = find(".line", :text => @model.name)[:class].match("error").should be_nil
end