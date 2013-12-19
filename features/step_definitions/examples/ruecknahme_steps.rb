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

Angenommen(/^es existiert ein Benutzer mit mindestens 2 Rückgaben an 2 verschiedenen Tagen$/) do
  @user = User.find {|u| u.visits.take_back.select{|v| v.inventory_pool == @current_inventory_pool}.count >= 2}
end

Wenn(/^man die Rücknahmenansicht für den Benutzer öffnet$/) do
  visit manage_take_back_path(@current_inventory_pool, @user)
end

Dann(/^sind die Rücknahmen aufsteigend nach Datum sortiert$/) do
  page.has_selector? ".line[data-line-type='item_line']"

  take_backs = @user.visits.take_back.select{|v| v.inventory_pool == @current_inventory_pool}.sort {|d1, d2| d1.date <=> d2.date }
  lines = take_backs.flat_map &:lines

  all(".line[data-line-type='item_line']").each_with_index do |line, i|
    ar_line = lines[i]

    if ar_line.is_a? ItemLine
      line.text.instance_eval do
        include? ar_line.item.inventory_code
        include? ar_line.item.model.name
      end
    elsif ar_line.is_a? OptionLine
      line.text.include? ar_line.option.name
    end

  end

end

When(/^ich befinde mich in einer Rücknahme für ein gesperrter Benutzer$/) do
  step 'I open a take back'
  ensure_suspended_user(@customer, @ip)
  visit manage_take_back_path(@ip, @customer)
end
