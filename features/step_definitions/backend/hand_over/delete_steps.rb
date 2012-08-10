When /^I delete a line$/ do
  @contract = @customer.contracts.unsigned.first
  @line = @contract.lines.first
  @line_element = find(".line[data-id='#{@line.id}']")
  step 'I delete this line element'
end

When /^I delete this line element$/ do
  @line_element.find(".multibutton .trigger").click
  @line_element.find(".button", :text => "Delete").click
  wait_until(10){ all(".loading", :visible => true ).size == 0 }  
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
  (@selected_lines & all(".line")).should be_empty
  lambda {@hand_over.reload}.should raise_error(ActiveRecord::RecordNotFound)
  step 'the count matches the amount of selected lines'
end

When /^I delete all lines of a model thats availability is blocked by these lines$/ do
  step 'I add so many lines that I break the maximal quantity of an model'

  target_linegroup = all(".line").detect{|line| line.find(".select input").checked?}.find(:xpath, "../../..")
  reference_line = all(".line.error").detect{|line| not line.find(".select input").checked?}
  @reference_id = reference_line["data-id"]

  line_ids = target_linegroup.all(".line.error", :text => @model.name).map{|line| line["data-id"]}
  line_ids.each do |id|
    if id != @reference_id
      @line_element = all(".line").detect{|line| line["data-id"] == id}
      step 'I delete this line element'
    end
  end
end

Then /^the availability of the keeped line is updated$/ do
  reference_line = all(".line").detect{|line| line["data-id"] == @reference_id}
  reference_line[:class].match("error").should be_nil
end