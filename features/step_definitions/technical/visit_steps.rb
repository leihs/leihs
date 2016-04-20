def object_with_sign_state?(object, sign_state)
  object.status == sign_state.downcase.to_sym
end

Given /^there are "(.*?)" visits$/ do |visit_type|
  if visit_type == 'overdue' then
    step 'there are "hand over" visits'
    @visits = @visits.where('date < ?', Date.today)
  else
    @visits = Visit.method(visit_type.sub(' ', '_').to_sym).call
  end
  expect(@visits).not_to be_nil
end

Then /^the associated contract of each such visit must be "(.*?)"$/ do |contract_state|
  expect(@visits.all? { |visit| object_with_sign_state? visit, contract_state }).to be true
end

Then /^(each of the reservations|at least one line) of such contract must also be "(.*?)"$/ do |arg1, line_state|
  @visits.each do |visit|
    m = case arg1
          when 'each of the reservations'
            :all?
          when 'at least one line'
            :any?
        end
    t = visit.reservations.send(m) do |line|
      object_with_sign_state? line, line_state
    end
    expect(t).to be true
  end
end

Then /^every visit with date < today is overdue$/ do
  expect(@visits.all?{ |visit| visit.date < Date.today }).to be true
end

Then(/^the other reservations of such contract must be "(.*?)"$/) do |line_state|
  @visits.each do |visit|
    signed_lines, other_lines = visit.reservations.partition {|line| object_with_sign_state? line, 'signed' }
    unless other_lines.empty?
      other_lines.all? {|line| object_with_sign_state? line, line_state }
    end
  end
end

Then /^all the generated visit ids are unique$/ do
  ids = Visit.all.map &:id
  expect(ids.size).to eq ids.uniq.size
end