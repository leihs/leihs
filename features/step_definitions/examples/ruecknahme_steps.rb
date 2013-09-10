# encoding: utf-8

Wenn(/^ich einen Gegenstand zurücknehme$/) do
  step %Q{I open a take back}
  step %Q{I select all lines of an open contract}
  step %Q{I click take back}
  step %Q{I see a summary of the things I selected for take back}
  step %Q{I click take back inside the dialog}
  step %Q{the contract is closed and all items are returned}
end

Dann(/^wird festgehalten, dass ich diesen Gegenstand zurückgenommen habe$/) do
  @contract.lines.map(&:returned_to_user_id).uniq.first.should == @current_user.id
  all("tbody td.returning_date").each do |col|
    col.should have_content @current_user.firstname[0]
    col.should have_content @current_user.lastname
  end
end