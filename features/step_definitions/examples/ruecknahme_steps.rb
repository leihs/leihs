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

Angenommen(/^ich befinde mich in einer Rücknahme$/) do
  @take_back = @current_inventory_pool.visits.take_back.select{|v| v.lines.any? {|l| l.is_a? ItemLine}}.sample
  @user = @take_back.user
  step "man die Rücknahmenansicht für den Benutzer öffnet"
end

Dann(/^ich erhalte eine Meldung$/) do
  find("#flash .notice")
end

Dann(/^ich erhalte eine Erfolgsmeldung$/) do
  find("#flash .success")
end

Wenn(/^ich einen Gegenstand über das Zuweisenfeld zurücknehme$/) do
  @contract_line = @take_back.lines.select{|l| l.is_a? ItemLine}.sample
  find("form#assign input#assign-input").set @contract_line.item.inventory_code
  find("form#assign button .icon-ok-sign").click
  @line_css = ".line[data-id='#{@contract_line.id}']"
end

Angenommen(/^ich befinde mich in einer Rücknahme mit mindestens einem verspäteten Gegenstand$/) do
  @take_back = @current_inventory_pool.visits.take_back.find {|v| v.lines.any? {|l| l.end_date.past? }}
  @user = @take_back.user
  step "man die Rücknahmenansicht für den Benutzer öffnet"
end

Wenn(/^ich einen verspäteten Gegenstand über das Zuweisenfeld zurücknehme$/) do
  @contract_line = @take_back.lines.find{|l| l.end_date.past?}
  find("form#assign input#assign-input").set @contract_line.item.inventory_code
  find("form#assign button .icon-ok-sign").click
  @line_css = ".line[data-id='#{@contract_line.id}']"
end

Dann(/^das Problemfeld für die Linie wird angezeigt$/) do
  page.has_selector? "#{@line_css} .line-info.red"
  page.has_selector? "#{@line_css} .red.tooltip"
end

Angenommen(/^ich befinde mich in einer Rücknahme mit mindestens zwei gleichen Optionen$/) do
  @take_back = @current_inventory_pool.visits.take_back.find {|v| v.lines.any? {|l| l.quantity >= 2 }}
  @user = @take_back.user
  step "man die Rücknahmenansicht für den Benutzer öffnet"
end

Wenn(/^ich eine Option über das Zuweisenfeld zurücknehme$/) do
  @contract_line = @take_back.lines.find {|l| l.quantity >= 2 }
  find("form#assign input#assign-input").set @contract_line.item.inventory_code
  find("form#assign button .icon-ok-sign").click
  @line_css = ".line[data-id='#{@contract_line.id}']"
end

Dann(/^die Zeile ist nicht grün markiert$/) do
  find(@line_css).native.attribute("class").should_not include "green"
end

Wenn(/^ich alle Optionen der gleichen Zeile zurücknehme$/) do
  (@contract_line.quantity - find(@line_css).find("input[data-quantity-returned]").value.to_i).times do
    find("form#assign input#assign-input").set @contract_line.item.inventory_code
    find("form#assign button .icon-ok-sign").click
  end
end

Angenommen(/^es existiert ein Benutzer mit einer zurückzugebender Option in zwei verschiedenen Zeitfenstern$/) do
  @user = User.find do |u|
    option_lines = u.visits.take_back.flat_map(&:lines).select {|l| l.is_a? OptionLine}
    option_lines.uniq(&:option).size < option_lines.size
  end
  @user.should_not be_nil
end

Wenn(/^ich öffne die Rücknahmeansicht für diesen Benutzer$/) do
  visit manage_take_back_path(@current_inventory_pool, @user)
end

Wenn(/^ich diese Option zurücknehme$/) do
  @option = Option.find {|o| o.option_lines.select{|l| l.contract.status == :signed and l.contract.user == @user}.count >= 2}
  find("form#assign input#assign-input").set @option.inventory_code
  find("form#assign button .icon-ok-sign").click
end

Dann(/^wird die Option dem ersten Zeitfenster hinzugefügt$/) do
  @option_lines = @option.option_lines.select{|l| l.contract.status == :signed and l.contract.user == @user}
  @option_line = @option_lines.sort{|a, b| a.end_date <=> b.end_date}.first
  first("[data-selected-lines-container]").find(".line[data-id='#{@option_line.id}'] [data-quantity-returned]").value.to_i > 0
end

Wenn(/^ich dieselbe Option nochmals hinzufüge$/) do
  find("form#assign input#assign-input").set @option.inventory_code
  find("form#assign button .icon-ok-sign").click
end

Wenn(/^im ersten Zeitfenster bereits die maximale Anzahl dieser Option erreicht ist$/) do
  until first("[data-selected-lines-container]").find(".line[data-id='#{@option_line.id}'] [data-quantity-returned]").value.to_i == @option_line.quantity
    find("form#assign input#assign-input").set @option.inventory_code
    find("form#assign button .icon-ok-sign").click
  end
end

Dann(/^wird die Option dem zweiten Zeitfenster hinzugefügt$/) do
  @option_line = @option_lines.sort{|a, b| a.end_date <=> b.end_date}.second
  all("[data-selected-lines-container]").to_a.second.find(".line[data-id='#{@option_line.id}'] [data-quantity-returned]").value.to_i > 0
end
