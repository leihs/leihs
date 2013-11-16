# -*- encoding : utf-8 -*-

Angenommen /^ich öffne die Tagesansicht$/ do
  @current_inventory_pool = @current_user.managed_inventory_pools.sample
  visit manage_daily_view_path(@current_inventory_pool)
  find("#daily-view")
end

Wenn /^ich kehre zur Tagesansicht zurück$/ do
  step 'ich öffne die Tagesansicht'
end

Wenn /^ich öffne eine Bestellung von "(.*?)"$/ do |arg1|
  find("[data-collapsed-toggle='#open-orders']").click unless all("[data-collapsed-toggle='#open-orders']").empty?
  within("#daily-view #open-orders .line", match: :prefer_exact, :text => arg1) do
    find(".line-actions .multibutton .dropdown-holder").hover
    find(".dropdown-item", :text => _("Edit")).click
  end
end

Wenn /^ich öffne eine Bestellung$/ do
  step 'ich öffne eine Bestellung von ""'
end

Dann /^sehe ich die letzten Besucher$/ do
  find("#daily-view .straight-top > div:nth-child(2) > div:nth-child(1) > strong", :text => _("Last Visitors:"))
end

Dann /^ich sehe "(.*?)" als letzten Besucher$/ do |arg1|
  find("#daily-view #last-visitors", :text => arg1)
end

Wenn /^ich auf "(.*?)" klicke$/ do |arg1|
  find("#daily-view #last-visitors a", :text => arg1).click
end

Dann /^wird mir ich ein Suchresultat nach "(.*?)" angezeigt/ do |arg1|
  find("#search-overview h1", text: _("Search Results for \"%s\"") % arg1)
end

Wenn /^ich eine Rücknahme mache$/ do
  step 'I open a take back'
end

Wenn /^etwas in das Feld "(.*?)" schreibe$/ do |field_label|
  if field_label == "Inventarcode/Name"
    find("[data-add-contract-line]").set " "
  end
end

Dann /^werden mir diejenigen Gegenstände vorgeschlagen, die in den dargestellten Rücknahmen vorkommen$/ do
  @customer.visits.take_back.first.lines.all do |line|
    first(".ui-autocomplete").should have_content line.item.inventory_code
  end
end

Wenn /^ich etwas zuweise, das nicht in den Rücknahmen vorkommt$/ do
  find("[data-add-contract-line]").set "_for_sure_this_is_not_part_of_the_take_back"
  find("[data-add-contract-line] + .addon").click
end

Dann /^(?:sehe ich|ich sehe) eine Fehlermeldung$/ do
  find("#flash .error")
end

Dann /^die Fehlermeldung lautet "(.*?)"$/ do |text|
  # default language is english, so its not so easy to test german here
end

Wenn /^einem Gegenstand einen Inventarcode manuell zuweise$/ do
  step 'I click an inventory code input field of an item line'
  step 'I select one of those'
end

Dann /^wird der Gegenstand ausgewählt und der Haken gesetzt$/ do
  @item_line.reload
  within(".line[data-id='#{@item_line.id}']") do
    @item_line.item.inventory_code.should == @selected_inventory_code
    find("input[data-assign-item][value='#{@item_line.item.inventory_code}']")
    find("input[type='checkbox'][data-select-line]").checked?.should be_true
  end
  step 'the count matches the amount of selected lines'
end

Wenn /^ich eine Rücknahme mache die Optionen beinhaltet$/ do
  @ip = @current_user.managed_inventory_pools.first
  @customer = @ip.users.all.select {|x| x.contracts.signed.size > 0 && !x.contracts.signed.detect{|c| c.options.size > 0}.nil? }.first
  visit manage_take_back_path(@ip, @customer)
  page.has_css?("#take_back", :visible => true)
end

Wenn /^die Anzahl einer zurückzugebenden Option manuell ändere$/ do
  @option_line = find(".line[data-line-type='option_line']", match: :first)
  @option_line.find("[data-quantity-returned]").set 1
end

Dann /^wird die Option ausgewählt und der Haken gesetzt$/ do
  sleep(0.88)
  @option_line.find("input[data-select-line]").checked?.should be_true
  step 'the count matches the amount of selected lines'
end

Wenn /^ich eine Aushändigung mache die ein Model enthält dessen Gegenstände ein nicht ausleihbares enthält$/ do
  @ip = @current_user.managed_inventory_pools.first
  @contract_line = nil
  @contract = @ip.contracts.approved.detect do |c|
    @contract_line = c.lines.detect do |l|
      l.model.items.unborrowable.scoped_by_inventory_pool_id(@ip).first
    end
  end
  @model = @contract_line.model
  @customer = @contract.user
  visit manage_hand_over_path(@ip, @customer)
  page.has_css?("#hand-over-view", :visible => true)
end

Wenn /^diesem Model ein Inventarcode zuweisen möchte$/ do
  @item_line_element = find(".line[data-id='#{@contract_line.id}']", :visible => true)
  @item_line_element.find("[data-assign-item]").click
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
  find("#add-start-date").set (Date.today+2.days).strftime("%d.%m.%Y")
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
  visit manage_hand_over_path(@ip, @customer)
end

Wenn /^eine Zeile mit Gruppen-Partitionen editiere$/ do
  @inventory_code = @ip.models.detect {|m| m.partitions.size > 1}.items.in_stock.borrowable.first.inventory_code
  @model = Item.find_by_inventory_code(@inventory_code).model
  step 'I assign an item to the hand over by providing an inventory code and a date range'
  find(".line [data-assign-item][disabled]", match: :first).find(:xpath, "./../../..").find(".button", text: _("Change entry")).click
end

Wenn /^die Gruppenauswahl aufklappe$/ do
  find("#booking-calendar-partitions")
end

Dann /^erkenne ich, in welchen Gruppen der Kunde ist$/ do
  @customer_group_ids = @customer.groups.map(&:id)
  @model.partitions.each do |partition|
    next if partition.group_id.nil?
    if @customer_group_ids.include? partition.group_id
      find("#booking-calendar-partitions optgroup[label='#{_("Groups of this customer")}']").should have_content partition.group.name
    end
  end
end

Dann /^dann erkennen ich, in welchen Gruppen der Kunde nicht ist$/ do
  @model.partitions.each do |partition|
    next if partition.group_id.nil?
    unless @customer_group_ids.include?(partition.group_id)
      find("#booking-calendar-partitions optgroup[label='#{_("Other Groups")}']").should have_content partition.group.name
    end
  end
end

Wenn /^ich eine Aushändigung mache mit einem Kunden der sowohl am heutigen Tag sowie in der Zukunft Abholungen hat$/ do
  @ip = @current_user.managed_inventory_pools.first
  @customer = @ip.users.detect{|u| u.visits.hand_over.size > 1}
  visit manage_hand_over_path(@ip, @customer)
  page.has_css?("#take_back", :visible => true)
end

Wenn /^ich etwas scanne \(per Inventarcode zuweise\) und es in irgendeinem zukünftigen Vertrag existiert$/ do
  @model = @customer.contracts.approved.first.models.first
  @item = @model.items.borrowable.in_stock.first
  find("[data-add-contract-line]").set @item.inventory_code
  find("[data-add-contract-line] + .addon").click
  @assigned_line = find("[data-assign-item][disabled][value='#{@item.inventory_code}']")
end

Dann /^wird es zugewiesen \(unabhängig ob es ausgewählt ist\)$/ do
  @assigned_line.find(:xpath, "./../../..").find("input[type='checkbox'][data-select-line]").checked?.should be_true
end

Wenn /^es in keinem zukünftigen Vertrag existiert$/ do
  @model_not_in_contract = (@ip.items.flat_map(&:model).uniq.delete_if{|m| m.items.borrowable.in_stock == 0} - @customer.contracts.approved.flat_map(&:models)).first
  @item = @model_not_in_contract.items.borrowable.in_stock.first
  find("#add-start-date").set (Date.today+7.days).strftime("%d.%m.%Y")
  find("#add-end-date").set (Date.today+8.days).strftime("%d.%m.%Y")
  find("[data-add-contract-line]").set @item.inventory_code
  @amount_lines_before = all(".line").size
  find("[data-add-contract-line] + .addon").click
end

Dann /^wird es für die ausgewählte Zeitspanne hinzugefügt$/ do
  find("#flash")
  find(".line", match: :first)
  @amount_lines_before.should < all(".line").size
end

Dann /^habe ich für jeden Gegenstand die Möglichkeit, eine Inspektion auszulösen$/ do
  all(".line[data-line-type='item_line']").each do |x|
    within x.find(".multibutton") do
      find(".dropdown-toggle").hover
      find(".dropdown-holder .dropdown-item", text: _("Inspect"))
    end
  end
end

Wenn /^ich bei einem Gegenstand eine Inspektion durchführen$/ do
  within all(".line[data-line-type='item_line']").to_a.sample.find(".multibutton") do
    @item = ContractLine.find(JSON.parse(find("[data-ids]")["data-ids"]).first).item
    find(".dropdown-toggle").hover
    find(".dropdown-holder .dropdown-item", text: _("Inspect")).click
  end
  find(".modal")
end

Dann /^die Inspektion erlaubt es, den Status von "(.*?)" auf "(.*?)" oder "(.*?)" zu setzen$/ do |arg1, arg2, arg3|
  within(".col1of3", :text => arg1) do
    find("option", :text => arg2)
    find("option", :text => arg3)
  end
end

Wenn /^ich Werte der Inspektion ändere$/ do
  @is_borrowable = true
  find("select[name='is_borrowable'] option[value='true']").select_option
  @is_broken = true
  find("select[name='is_broken'] option[value='true']").select_option
  @is_incomplete = true
  find("select[name='is_incomplete'] option[value='true']").select_option
end

Dann /^wenn ich die Inspektion speichere$/ do
  find(".modal button[type='submit']").click
end

Dann /^wird der Gegenstand mit den aktuell gesetzten Status gespeichert$/ do
  visit current_path
  @item.reload
  @item.is_borrowable.should == @is_borrowable
  @item.is_broken.should == @is_broken
  @item.is_incomplete.should == @is_incomplete
end

Angenommen /^man fährt über die Anzahl von Gegenständen in einer Zeile$/ do
  find(".line [data-type='lines-cell']", match: :first)
  @lines = all(".line [data-type='lines-cell']")
end

Dann /^werden alle diese Gegenstände aufgelistet$/ do
  all(".show_more").each(&:click)
  @lines.each do |line|
    line.hover
    find(".tooltipster-default", match: :first)
  end
end

Dann /^man sieht pro Modell eine Zeile$/ do
  all(".show_more").each(&:click)
  @lines.each do |line|
    line.hover
    find(".tooltipster-default .row .col7of8:nth-child(2) strong", match: :first)
    sleep(0.88)
    model_names = find(".tooltipster-default", match: :first, :visible => true).all(".row .col7of8:nth-child(2) strong", text: /.+/).map &:text
    model_names.size.should == model_names.uniq.size
  end
end

Dann /^man sieht auf jeder Zeile die Summe der Gegenstände des jeweiligen Modells$/ do
  all(".show_more").each(&:click)
  @lines.each do |line|
    line.hover
    find(".tooltipster-default .row .col1of8:nth-child(1)", match: :first)
    sleep(0.88)
    quantities = find(".tooltipster-default", match: :first, :visible => true).all(".row .col1of8:nth-child(1)", text: /.+/).map{|x| x.text.to_i}
    quantities.sum.should >= quantities.size
  end
end

Angenommen /^ich suche$/ do
  @search_term = "a"
  find("#search_term").set(@search_term)
  find("#search_term").native.send_key :enter
end

Dann /^erhalte ich Suchresultate in den Kategorien:$/ do |table|
  table.hashes.each do |t|
    case t[:category]
      when "Benutzer"
        find("#users .list-of-lines .line", match: :first)
      when "Modelle"
        find("#models .list-of-lines .line", match: :first)
      when "Gegenstände"
        find("#items .list-of-lines .line", match: :first)
      when "Verträge"
        find("#contracts .list-of-lines .line", match: :first)
      when "Bestellungen"
        find("#orders .list-of-lines .line", match: :first)
      when "Optionen"
        find("#options .list-of-lines .line", match: :first)
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

#Angenommen /^ich sehe Probleme auf einer Zeile, die durch die Verfügbarkeit bedingt sind$/ do
#  step 'I open a hand over'
#  step 'I add so many lines that I break the maximal quantity of an model'
#  @line_el = first(".line.error")
#  page.evaluate_script %Q{ $(".line.error:first-child").tmplItem().data.id; }
#  @line = ContractLine.find page.evaluate_script %Q{ $(".line.error:first-child").tmplItem().data.id; }
#end

Angenommen /^ich fahre über das Problem$/ do
  page.execute_script %Q{ $(".line.error:first-child .problems").trigger("mouseenter"); }
  page.should have_selector(".tooltipster-default")
end

Dann /^wird automatisch der Druck\-Dialog geöffnet$/ do
  step 'I select an item line and assign an inventory code'
  step 'I click hand over'
  find(".modal .button", match: :first, :text => _("Hand Over")).click
  check_printed_contract(page.driver.browser.window_handles, @ip, @item_line.contract)
end

def check_printed_contract(window_handles, ip = nil, contract = nil)
  while (page.driver.browser.window_handles - window_handles).empty? do end
  new_window = (page.driver.browser.window_handles - window_handles).first
  page.within_window new_window do
    find(".contract")
    current_path.should == manage_contract_path(ip, contract) if ip and contract
    page.evaluate_script("window.printed").should == 1
  end
end