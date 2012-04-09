When /^I delete a line$/ do
  @line = @customer.contracts.unsigned.first.lines.first
  @line_element = find(".line", :text => @line.model.name)
  @line_element.find(".multibutton .trigger").click
  @line_element.find(".button", :text => "Delete").click
  wait_until{
    all(".line", :text => @line.model.name).size == 0
  }
end

Then /^this line is deleted$/ do
  lambda {@line.reload}.should raise_error(ActiveRecord::RecordNotFound) 
end