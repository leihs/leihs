# encoding: utf-8

Angenommen /^man sucht nach einem nicht ausgeliehenen Gegenstand$/ do
  @unretired_item = Item.where(inventory_pool_id: @current_inventory_pool.id).detect {|i| not i.retired? and i.is_borrowable? and i.in_stock?}
  find_field('query').set @unretired_item.model.name
  wait_until{ not all("li.modelname").empty? }
  wait_until{ all("li.modelname").first.text == @unretired_item.model.name }
  find(".toggle .icon").click
  page.execute_script("$('.items.children .arrow').trigger('mouseover');")
  wait_until {find(".line.toggler.item", text: @unretired_item.inventory_code).find(".button", text: _("Retire Item"))}.click
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
  find_field('query').set @borrowed_item.model.name
  wait_until { find(".line.model", text: @borrowed_item.model.name).find ".arrow" }
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
  find_field('query').set @unborrowed_item_not_the_owner.model.name
  wait_until { find(".line.model", text: @unborrowed_item_not_the_owner.model.name).find ".arrow" }
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
