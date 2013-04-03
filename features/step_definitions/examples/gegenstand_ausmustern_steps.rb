# encoding: utf-8

Angenommen /^man sucht nach einem nicht ausgeliehenen Gegenstand$/ do
  @unretired_item = Item.where(inventory_pool_id: @current_inventory_pool.id).detect {|i| not i.retired? and i.is_borrowable?}
  find_field('query').set @unretired_item.model.name
  wait_until { all("li.modelname").first.text == @unretired_item.model.name }
  find(".toggle .icon").click
  page.execute_script("$('.items.children .arrow').trigger('mouseover');")
  wait_until {find(".line.toggler.item", text: @unretired_item.name).find(".button", text: _("Retire Item"))}.click
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
  find(".toggle .icon").click
  page.execute_script("$('.items.children .arrow').trigger('mouseover');")
  find(".line.toggler.item", text: @borrowed_item.inventory_code).should_not have_content _("Retire Item")
end
