# encoding: utf-8

Wenn(/^ich einen Gegenstand zurücknehme$/) do
  step 'I open a take back'
  step 'I select all lines of an open contract'
  step 'I click take back'
  step 'I see a summary of the things I selected for take back'
  step 'I click take back inside the dialog'
  step 'the contract is closed and all items are returned'
end

Dann(/^wird festgehalten, dass ich diesen Gegenstand zurückgenommen habe$/) do
  @contract_lines_to_take_back.map(&:returned_to_user_id).uniq.first.should == @current_user.id
  step 'sieht man bei den betroffenen Linien die rücknehmende Person im Format "V. Nachname"'
end
