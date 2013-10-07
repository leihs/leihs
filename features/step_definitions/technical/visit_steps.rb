def object_with_sign_state?(object, sign_state)
  object.status == sign_state.downcase.to_sym
end

Given /^there are "(.*?)" visits$/ do |visit_type|
  if visit_type == "overdue" then
    step 'there are "hand over" visits'
    @visits = @visits.where("date < ?", Date.today)
  else
    @visits = Visit.method(visit_type.sub(' ', '_').to_sym).call
  end

  @visits.should_not be_nil
end

Then /^the associated contract of each such visit must be "(.*?)"$/ do |contract_state|
  @visits.all? { |visit| object_with_sign_state? visit, contract_state }.should be_true
end

Then /^each of the lines of such contract must also be "(.*?)"$/ do |line_state|
  @visits.all? do |visit|
    visit.lines.all? do |line|
      object_with_sign_state? line.contract, line_state
    end
  end.should be_true
end

Then /^every visit with date < today is overdue$/ do
  @visits.all?{ |visit| visit.is_overdue }.should be_true
end
