# -*- encoding : utf-8 -*-

Angenommen /^ich öffne die Tagesansicht$/ do
  @current_inventory_pool = @current_user.managed_inventory_pools.first
  visit backend_inventory_pool_path(@current_inventory_pool)
  find("#daily")
end

Wenn /^ich kehre zur Tagesansicht zurück$/ do
  step 'ich öffne die Tagesansicht'
end

Wenn /^ich öffne eine Bestellung von "(.*?)"$/ do |arg1|
  find(".toggle .text").click
  el = first("#daily .order.line", :text => arg1)
  @order = Order.find el["data-id"]
  page.execute_script '$(":hidden").show();'
  el.first(".actions .alternatives .button .icon.edit").click
end

Wenn /^ich öffne eine Bestellung$/ do
  step 'ich öffne eine Bestellung von ""'
end

Dann /^sehe ich die letzten Besucher$/ do
  find("#daily .subtitle", :text => /(Last Visitors|Letzte Besucher)/)
end

Dann /^ich sehe "(.*?)" als letzten Besucher$/ do |arg1|
  find("#daily .subtitle", :text => arg1)
end

Wenn /^ich auf "(.*?)" klicke$/ do |arg1|
  find("#daily .subtitle a", :text => arg1).click
end

Dann /^wird mir ich ein Suchresultat nach "(.*?)" angezeigt/ do |arg1|
  find("#search_results h1", :text => /(Search Results for "#{arg1}"|Suchresultate für "#{arg1}")/)
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
    first(".ui-autocomplete").should have_content line.item.inventory_code
  end
end

Wenn /^ich etwas zuweise, das nicht in den Rücknahmen vorkommt$/ do
  find("#code").set("_for_sure_this_is_not_part_of_the_take_back")
  page.execute_script('$("#process_helper").submit()')
end

Dann /^(?:sehe ich|ich sehe) eine Fehlermeldung$/ do
  page.should have_selector(".notification.error")
end

Dann /^die Fehlermeldung lautet "(.*?)"$/ do |text|
  # default language is english, so its not so easy to test german here
end

Wenn /^einem Gegenstand einen Inventarcode manuell zuweise$/ do
  step 'I click an inventory code input field of an item line'
  step 'I select one of those'
end

Dann /^wird der Gegenstand ausgewählt und der Haken gesetzt$/ do
  first(".line.assigned", :text => @item.model.name).first(".select input").checked?.should be_true
  step 'the count matches the amount of selected lines'
end

Wenn /^ich eine Rücknahme mache die Optionen beinhaltet$/ do
  @ip = @current_user.managed_inventory_pools.first
  @customer = @ip.users.all.select {|x| x.contracts.signed.size > 0 && !x.contracts.signed.detect{|c| c.options.size > 0}.nil? }.first
  visit backend_inventory_pool_user_take_back_path(@ip, @customer)
  page.has_css?("#take_back", :visible => true)
end

Wenn /^die Anzahl einer zurückzugebenden Option manuell ändere$/ do
  @option_line = first(".option_line")
  @option_line.first(".quantity input").set 1
end

Dann /^wird die Option ausgewählt und der Haken gesetzt$/ do
  @option_line.first(".select input").checked?.should be_true
  step 'the count matches the amount of selected lines'
end

Wenn /^ich eine Aushändigung mache die ein Model enthält dessen Gegenstände ein nicht ausleihbares enthält$/ do
  @ip = @current_user.managed_inventory_pools.first
  @contract_line = nil
  @contract = @ip.contracts.unsigned.detect do |c|
    @contract_line = c.lines.detect do |l|
      l.model.items.unborrowable.scoped_by_inventory_pool_id(@ip).first
    end
  end
  @model = @contract_line.model
  @customer = @contract.user
  visit backend_inventory_pool_user_hand_over_path(@ip, @customer)
  page.has_css?("#hand_over", :visible => true)
end

Wenn /^diesem Model ein Inventarcode zuweisen möchte$/ do
  @item_line_element = find(:xpath, "//ul[@data-id='#{@contract_line.id}']", :visible => true)
  @item_line_element.find(".inventory_code input").click
end

Dann /^schlägt mir das System eine Liste von Gegenständen vor$/ do
  first(".ui-autocomplete .ui-menu-item")
end

Dann /^diejenigen Gegenstände sind gekennzeichnet, welche als nicht ausleihbar markiert sind$/ do
  @model.items.unborrowable.in_stock.each do |item|
    first(".ui-autocomplete .ui-menu-item a.unborrowable", :text => item.inventory_code)
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
  @ip = @current_user.managed_inventory_pools.first
  @customer = @ip.users.detect{|u| u.groups.size > 0}
  @customer.should_not be_nil
end

Wenn /^ich eine Aushändigung an diesen Kunden mache$/ do
  visit backend_inventory_pool_user_hand_over_path(@ip, @customer)
end

Wenn /^eine Zeile mit Gruppen-Partitionen editiere$/ do
  @inventory_code = @ip.models.detect {|m| m.partitions.size > 1}.items.in_stock.borrowable.first.inventory_code
  @model = Item.find_by_inventory_code(@inventory_code).model
  step 'I assign an item to the hand over by providing an inventory code and a date range'
  first(".line.assigned .button", :text => /(Edit|Editieren)/).click
end

Wenn /^die Gruppenauswahl aufklappe$/ do
  page.should have_selector(".partition.container")
end

Dann /^erkenne ich, in welchen Gruppen der Kunde ist$/ do
  @customer_group_ids = @customer.groups.map(&:id)
  @model.partitions.each do |partition|
    next if partition.group_id.nil?
    if @customer_group_ids.include? partition.group_id
      first(".partition.container optgroup.customer_groups").should have_content partition.group.name
    end
  end
end

Dann /^dann erkennen ich, in welchen Gruppen der Kunde nicht ist$/ do
  @model.partitions.each do |partition|
    next if partition.group_id.nil?
    unless @customer_group_ids.include?(partition.group_id)
      first(".partition.container optgroup.other_groups").should have_content partition.group.name
    end
  end
end

Wenn /^ich eine Aushändigung mache mit einem Kunden der sowohl am heutigen Tag sowie in der Zukunft Abholungen hat$/ do
  @ip = @current_user.managed_inventory_pools.first
  @customer = @ip.users.detect{|u| u.visits.hand_over.size > 1}
  visit backend_inventory_pool_user_hand_over_path(@ip, @customer)
  page.has_css?("#take_back", :visible => true)
end

Wenn /^ich etwas scanne \(per Inventarcode zuweise\) und es in irgendeinem zukünftigen Vertrag existiert$/ do
  @model = @customer.contracts.unsigned.first.models.first
  @item = @model.items.borrowable.in_stock.first
  find("#code").set @item.inventory_code
  find("#process_helper .button").click
  page.should have_selector(".line.assigned")
end

Dann /^wird es zugewiesen \(unabhängig ob es ausgewählt ist\)$/ do
  find(".line.assigned .select input").checked?.should be_true
end

Wenn /^es in keinem zukünftigen Vertrag existiert$/ do
  @model_not_in_contract = (@ip.items.flat_map(&:model).uniq.delete_if{|m| m.items.borrowable.in_stock == 0} - @customer.contracts.unsigned.flat_map(&:models)).first
  @item = @model_not_in_contract.items.borrowable.in_stock.first
  find("#add_start_date").set (Date.today+7.days).strftime("%d.%m.%Y")
  find("#add_end_date").set (Date.today+8.days).strftime("%d.%m.%Y")
  find("#code").set @item.inventory_code
  @amount_lines_before = all(".line").size
  find("#process_helper .button").click
end

Dann /^wird es für die ausgewählte Zeitspanne hinzugefügt$/ do
  page.should have_selector(".line")
  @amount_lines_before.should < all(".line").size
end

Dann /^habe ich für jeden Gegenstand die Möglichkeit, eine Inspektion auszulösen$/ do
  page.execute_script '$(":hidden").show();'
  all(".item_line").all? {|x| x.first(".actions .alternatives .button", :text => /Inspektion/) }
end

Wenn /^ich bei einem Gegenstand eine Inspektion durchführen$/ do
  first(".item_line .actions .alternatives .button", :text => /Inspektion/).click
  first(".dialog")
end

Dann /^die Inspektion erlaubt es, den Status von "(.*?)" auf "(.*?)" oder "(.*?)" zu setzen$/ do |arg1, arg2, arg3|
  within("form#inspection label", :text => arg1) do
    first("option", :text => arg2)
    first("option", :text => arg3)
  end
end

Wenn /^ich Werte der Inspektion ändere$/ do
  page.should have_selector("form#inspection input[name='line_id']", visible: false)
  all("form#inspection select").each do |s|
    s.all("option").each do |o|
      o.select_option unless o.selected?
    end
  end  
end

Dann /^wenn ich die Inspektion speichere$/ do
  find("form#inspection .button.green").click
end

Dann /^wird der Gegenstand mit den aktuell gesetzten Status gespeichert$/ do
  find(".notification.success")
end

Angenommen /^man fährt über die Anzahl von Gegenständen in einer Zeile$/ do
  page.should have_selector(".line")
  @lines = all(".line")
end

Dann /^werden alle diese Gegenstände aufgelistet$/ do
  @lines.each_with_index do |line, i|
    page.execute_script("$($('.line .items')[#{i}]).trigger('mouseenter')")
    first(".tip")
  end
end

Dann /^man sieht pro Modell eine Zeile$/ do
  @lines.each_with_index do |line, i|
    page.execute_script("$($('.line .items')[#{i}]).trigger('mouseenter')")
    model_names = find(".tip", match: :first, :visible => true).all(".model_name").map{|x| x.text}
    model_names.size.should == model_names.uniq.size
  end
end

Dann /^man sieht auf jeder Zeile die Summe der Gegenstände des jeweiligen Modells$/ do
  @lines.each_with_index do |line, i|
    page.execute_script("$($('.line .items')[#{i}]).trigger('mouseenter')")
    quantities = find(".tip", match: :first, :visible => true).all(".quantity").map{|x| x.text.to_i}
    quantities.sum.should >= quantities.size
  end
end

Angenommen /^ich suche$/ do
  @search_term = "a"
  find("#search").set(@search_term)
  find("#topbar .search.item input[type=submit]").click
end

Dann /^erhalte ich Suchresultate in den Kategorien:$/ do |table|
  table.hashes.each do |t|
    case t[:category]
      when "Benutzer"
        first(".user .list .line")
      when "Modelle"
        first(".model .list .line")
      when "Gegenstände"
        first(".item .list .line")
      when "Verträge"
        first(".contract .list .line")
      when "Bestellungen"
        first(".order .list .line")
      when "Optionen"
        first(".option .list .line")
    end
  end
end

Dann /^ich sehe aus jeder Kategorie maximal die (\d+) ersten Resultate$/ do |amount|
  amount = (amount.to_i+2)
  all(".user .list .line:not(.toggle)", :visible => true).size.should <= amount
  all(".model .list .line:not(.toggle)", :visible => true).size.should <= amount
  all(".item .list .line:not(.toggle)", :visible => true).size.should <= amount
  all(".contract .list .line:not(.toggle)", :visible => true).size.should <= amount
  all(".order .list .line:not(.toggle)", :visible => true).size.should <= amount 
end

Wenn /^eine Kategorie mehr als (\d+) Resultate bringt$/ do |amount|
  @lists = []
  all(".list").each do |list|
    @lists.push(list) unless list.all(".hidden .line:not(.show-all)").empty?
  end
end

Dann /^kann ich wählen, ob ich aus einer Kategorie mehr Resultate sehen will$/ do
  @lists.each do |list|
    list.first(".toggle")
  end
end

Wenn /^ich mehr Resultate wähle$/ do
  @lists.each do |list|
    list.first(".toggle .text").click
  end
end

Dann /^sehe ich die ersten (\d+) Resultate$/ do |amount|
  amount = amount.to_i + 2
  @lists.each do |list|
    if list.all(".show-all").size > 0
      list.all(".line").size.should == amount
    end
  end
end

Wenn /^die Kategorie mehr als (\d+) Resultate bringt$/ do |amount|
  amount = amount.to_i
  @list_with_more_matches = all(".inlinetabs .badge").map do |badge|
    badge.first(:xpath, "../../..").first(".list") if badge.text.to_i > amount
  end.compact
end

Dann /^kann ich wählen, ob ich alle Resultate sehen will$/ do
  @links_of_more_results = @list_with_more_matches.map do |list|
    list.find(".line.show-all a", visible: false)[:href]
  end
end

Wenn /^ich alle Resultate wähle erhalte ich eine separate Liste aller Resultate dieser Kategorie$/ do
  @links_of_more_results.each do |link|
    visit link
    find("#search_results.focused")
  end
end

Angenommen /^ich sehe Probleme auf einer Zeile, die durch die Verfügbarkeit bedingt sind$/ do
  step 'I open a hand over'
  step 'I add so many lines that I break the maximal quantity of an model'
  @line_el = first(".line.error")
  page.evaluate_script %Q{ $(".line.error:first-child").tmplItem().data.id; }
  @line = ContractLine.find page.evaluate_script %Q{ $(".line.error:first-child").tmplItem().data.id; }
end

Angenommen /^ich fahre über das Problem$/ do
  page.execute_script %Q{ $(".line.error:first-child .problems").trigger("mouseenter"); }
  page.should have_selector(".tip")
end

Dann /^wird automatisch der Druck\-Dialog geöffnet$/ do
  step 'I select an item line and assign an inventory code'
  step 'I click hand over'
  page.execute_script ("window.print = function(){window.printed = 1;return true;}")
  find(".dialog .button", match: :first, :text => /(Hand Over|Aushändigen)/).click
  page.should have_selector(".dialog .documents")
  page.evaluate_script("window.printed").should == 1
end
