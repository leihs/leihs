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
  expect(@visits).not_to be nil
end

Then /^the associated contract of each such visit must be "(.*?)"$/ do |contract_state|
  expect(@visits.all? { |visit| object_with_sign_state? visit, contract_state }).to be true
end

Then /^each of the lines of such contract must also be "(.*?)"$/ do |line_state|
  t = @visits.all? do |visit|
    visit.lines.all? do |line|
      object_with_sign_state? line.contract, line_state
    end
  end
  expect(t).to be true
end

Then /^every visit with date < today is overdue$/ do
  expect(@visits.all?{ |visit| visit.date < Date.today }).to be true
end
