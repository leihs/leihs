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
