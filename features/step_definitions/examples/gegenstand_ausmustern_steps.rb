# encoding: utf-8

Angenommen /^man sucht nach einem nicht ausgeliehenen Gegenstand$/ do
  @unretired_item = Item.where(inventory_pool_id: @current_inventory_pool.id).detect {|i| not i.retired? and i.is_borrowable? and i.in_stock?}
  fill_in 'query', with: @unretired_item.model.name
  page.should have_selector("li.modelname")
  first("li.modelname").text.should == @unretired_item.model.name
  first(".toggle .icon").click
  page.execute_script("$('.items.children .arrow').trigger('mouseover');")
  find(".line.toggler.item", text: @unretired_item.inventory_code).find(".button", text: _("Retire Item")).click
end

Dann /^kann man diesen Gegenstand mit Angabe des Grundes erfolgreich ausmustern$/ do
  fill_in "retired_reason", with: "test"
  click_button _("Retire")
  step "ensure there are no active requests"
  @unretired_item.reload
  @unretired_item.retired.should eq Date.today
  @unretired_item.retired_reason.should eq "test"
end

Dann /^der gerade ausgemusterte Gegenstand verschwindet sofort aus der Inventarliste$/ do
  page.should_not have_content @unretired_item.inventory_code
end

Angenommen /^man sucht nach einem ausgeliehenen Gegenstand$/ do
  @borrowed_item = Item.where(inventory_pool_id: @current_inventory_pool.id).detect {|i| not (i.retired? or i.in_stock?)}
  fill_in 'query', with: @borrowed_item.model.name
  page.should have_selector(".line.model")
  first(".line.model", text: @borrowed_item.model.name).find ".arrow"
end

Dann /^hat man keine Möglichkeit übers Interface solchen Gegenstand auszumustern$/ do
  item = @borrowed_item || @unborrowed_item_not_the_owner
  all(".toggle .icon").each_with_index do |toggler, i|
    all(".toggle .icon")[i].click
  end
  page.execute_script("$('.items.children .arrow').trigger('mouseover');")
  find(".line.toggler.item", text: item.inventory_code).should_not have_content _("Retire Item")
end

Angenommen /^man sucht nach einem Gegenstand bei dem ich nicht als Besitzer eingetragen bin$/ do
  @unborrowed_item_not_the_owner = Item.where(inventory_pool_id: @current_inventory_pool.id).detect {|i| i.in_stock? and i.owner_id != @current_inventory_pool.id}
  fill_in 'query', with: @unborrowed_item_not_the_owner.model.name
  find(".line.model", text: @unborrowed_item_not_the_owner.model.name).find ".arrow"
end

Angenommen /^man gibt bei der Ausmusterung keinen Grund an$/ do
  click_button _("Retire")
  step "ensure there are no active requests"
  @unretired_item.reload
end

Dann /^sieht man eine Fehlermeldung$/ do
  find(".flash_message", :text => /\w+/)
end

Dann /^der Gegenstand ist noch nicht Ausgemustert$/ do
  @unretired_item.retired.should be_nil
end

Angenommen(/^man sucht nach einem ausgemusterten Gegenstand, wo man der Besitzer ist$/) do
  @retired_item = Item.unscoped.find {|i| i.retired? and i.owner_id == @current_inventory_pool.id}
end

Angenommen(/^man befindet sich auf der Gegenstandseditierseite dieses Gegenstands$/) do
  visit backend_inventory_pool_item_path(@current_inventory_pool, @retired_item)
  page.has_content? @retired_item.model.name
end

Wenn(/^man die Ausmusterung bei diesem Gegenstand zurück setzt$/) do
  page.has_content? _("Retirement")
  find("*[name='item[retired]']").select _("No")
end

Dann(/^wurde man auf die Inventarliste geleitet$/) do
  page.has_content? _("List of Inventory")
end

Dann(/^dieses Gegenstand ist nicht mehr ausgemustert$/) do
  @retired_item.reload.should_not be_retired
end

Wenn(/^man speichert den Gegenstand$/) do
  click_button _("Save %s") % _("Item")
end

Wenn(/^die Anschaffungskategorie ist ausgewählt$/) do
  find(".field", text: "Anschaffungskategorie").find("select option:not([value=''])", match: :first).select_option
end

Angenommen(/^man sucht nach einem ausgemusterten Gegenstand, wo man der Verantwortliche und nicht der Besitzer ist$/) do
  @retired_item = Item.unscoped.find {|i| i.retired? and i.owner != @current_inventory_pool and i.inventory_pool == @current_inventory_pool}
end
