# -*- encoding : utf-8 -*-

Angenommen /^ich öffne die Tagesansicht$/ do
  @current_inventory_pool = @user.managed_inventory_pools.first
  visit backend_inventory_pool_path(@current_inventory_pool)
  wait_until(10){ find("#daily") }
end

Wenn /^ich kehre zur Tagesansicht zurück$/ do
  step 'ich öffne die Tagesansicht'
end

Wenn /^ich öffnet eine Bestellung von "(.*?)"$/ do |arg1|
  el = find("#daily .order.line", :text => arg1)
  page.execute_script '$(":hidden").show();'
  el.find(".actions .alternatives .button .icon.edit").click
end

Dann /^sehe ich die letzten Besucher$/ do
  find("#daily .subtitle", :text => "Last Visitors")
end

Dann /^ich sehe "(.*?)" als letzten Besucher$/ do |arg1|
  find("#daily .subtitle", :text => arg1)
end

Wenn /^ich auf "(.*?)" klicke$/ do |arg1|
  find("#daily .subtitle a", :text => arg1).click
end

Dann /^wird mir ich ein Suchresultat nach "(.*?)" angezeigt/ do |arg1|
  find("#search_results h1", :text => "Search Results for \"#{arg1}\"")
end

Wenn /^ich eine Rücknahme mache$/ do
  step 'I open a take back'
end

Wenn /^etwas in das Feld "(.*?)" schreibe$/ do |field_label|
  if field_label == "Inventarcode/Name"
    find("#code").set(" ")
    page.execute_script('$("#code").trigger("focus")')
  end
end

Dann /^werden mir diejenigen Gegenstände vorgeschlagen, die in den dargestellten Rücknahmen vorkommen$/ do
  @customer.visits.take_back.first.lines.all do |line|
    find(".ui-autocomplete").should have_content line.item.inventory_code
  end
end

Wenn /^ich etwas zuweise, das nicht in den Rücknahmen vorkommt$/ do
  find("#code").set("_for_sure_this_is_not_part_of_the_take_back")
  page.execute_script('$("#process_helper").submit()')
end

Dann /^sehe ich eine Fehlermeldung$/ do
  wait_until{ @notification = find(".notification") }
end

Dann /^die Fehlermeldung lautet "(.*?)"$/ do |text|
  # default language is english, so its not so easy to test german here
end

Wenn /^einem Gegenstand einen Inventarcode manuell zuweise$/ do
  step 'I click an inventory code input field of an item line'
  step 'I select one of those'
end

Dann /^wird der Gegenstand ausgewählt und der Haken gesetzt$/ do
  @item_line_element.find(".select input").checked?.should be_true
  @item_line_element["class"].split(" ").include?("assigned").should be_true
end

Wenn /^ich eine Rücknahme mache die Optionen beinhaltet$/ do
  @ip = @user.managed_inventory_pools.first
  @customer = @ip.users.all.select {|x| x.contracts.signed.size > 0 && !x.contracts.signed.detect{|c| c.options.size > 0}.nil? }.first
  visit backend_inventory_pool_user_take_back_path(@ip, @customer)
  page.has_css?("#take_back", :visible => true)
end

Wenn /^die Anzahl einer zurückzugebenden Option manuell ändere$/ do
  @option_line = find(".option_line")
  @option_line.find(".quantity input").set 1
end

Dann /^wird die Option ausgewählt und der Haken gesetzt$/ do
  @option_line.find(".select input").checked?.should be_true
end

Wenn /^ich eine Aushändigung mache die ein Model enthält dessen Gegenstände ein nicht ausleihbares enthält$/ do
  @ip = @user.managed_inventory_pools.first
  @contract = nil
  @ip.items.unborrowable.each do |item|
    @contract = @ip.contracts.unsigned.detect{|c| c.models.include?(item.model)}
  end
  @customer = @contract.user
  visit backend_inventory_pool_user_hand_over_path(@ip, @customer)
  page.has_css?("#take_back", :visible => true)
end

Wenn /^diesem Model ein Inventarcode zuweisen möchte$/ do
  @model = @contract.models.detect{|m| m.items.unborrowable.count > 0}
  @item_line_element = find(".item_line", :text => @model.name)
  @contract_line = ContractLine.find @item_line_element["data-id"]
  @item_line_element.find(".inventory_code input").click
  page.execute_script('$(".line[data-id=#{@contract_line.id}] .inventory_code input").focus()')
end

Dann /^schlägt mir das System eine Liste von Gegenständen vor$/ do
  wait_until { find(".ui-autocomplete") }
end

Dann /^diejenigen Gegenstände sind gekennzeichnet, welche als nicht ausleihbar markiert sind$/ do
  @model.items.unborrowable.in_stock.each do |item|
    find(".ui-autocomplete .ui-menu-item a.unborrowable", :text => item.inventory_code)
  end
end

Wenn /^die ausgewählten Gegenstände auch solche beinhalten, die in einer zukünftige Aushändigung enthalten sind$/ do
  find("#add_start_date").set (Date.today+2.days).strftime("%d.%m.%Y")
  step 'I add an item to the hand over by providing an inventory code and a date range'
end

Wenn /^ich versuche, die Gegenstände auszuhändigen$/ do
  step 'I click hand over'
end

Dann /^ich kann die Gegenstände nicht aushändigen$/ do
  all(".hand_over .summary").size.should == 0
end

Angenommen /^der Kunde ist in mehreren Gruppen$/ do
  @ip = @user.managed_inventory_pools.first
  @customer = @ip.users.detect{|u| u.groups.size > 0}
  @customer.should_not be_nil
end

Wenn /^ich eine Aushändigung an diesen Kunden mache$/ do
  visit backend_inventory_pool_user_hand_over_path(@ip, @customer)
end

Wenn /^eine Zeile mit Gruppen-Partitionen editiere$/ do
  @inventory_code = @ip.models.detect {|m| m.partitions.size > 1}.items.in_stock.borrowable.first.inventory_code
  @model = Item.find_by_inventory_code(@inventory_code).model
  step 'I add an item to the hand over by providing an inventory code and a date range'
  find(".line.assigned .button", :text => "Edit").click
end

Wenn /^die Gruppenauswahl aufklappe$/ do
  wait_until {find(".partition.container")}
end

Dann /^erkenne ich, in welchen Gruppen der Kunde ist$/ do
  @customer_group_ids = @customer.groups.map(&:id)
  @model.partitions.each do |partition|
    next if partition.group_id.nil?
    if @customer_group_ids.include? partition.group_id
      find(".partition.container optgroup.customer_groups").should have_content partition.group.name
    end
  end
end

Dann /^dann erkennen ich, in welchen Gruppen der Kunde nicht ist$/ do
  @model.partitions.each do |partition|
    next if partition.group_id.nil?
    unless @customer_group_ids.include?(partition.group_id)
      find(".partition.container optgroup.other_groups").should have_content partition.group.name
    end
  end
end