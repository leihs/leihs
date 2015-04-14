# -*- encoding : utf-8 -*-

# Dann /^ich sehe "(.*?)" als letzten Besucher$/ do |arg1|
#   find("#daily-view #last-visitors", :text => arg1)
# end

# Wenn /^ich auf "(.*?)" klicke$/ do |arg1|
#   find("#daily-view #last-visitors a", :text => arg1).click
# end

# Dann /^wird mir ich ein Suchresultat nach "(.*?)" angezeigt/ do |arg1|
#   find("#search-overview h1", text: _("Search Results for \"%s\"") % arg1)
# end


Dann /^werden mir diejenigen Gegenstände vorgeschlagen, die in den dargestellten Rücknahmen vorkommen$/ do
  @customer.visits.take_back.where(inventory_pool_id: @current_inventory_pool).first.lines.all do |line|
    expect(find(".ui-autocomplete", match: :first).has_content? line.item.inventory_code).to be true
  end
end

Wenn /^ich etwas zuweise, das nicht in den Rücknahmen vorkommt$/ do
  find("[data-add-contract-line]").set "_for_sure_this_is_not_part_of_the_take_back"
  find("[data-add-contract-line] + .addon").click
end

# Wenn /^die Gruppenauswahl aufklappe$/ do
#   find("#booking-calendar-partitions")
# end

# Dann /^erkenne ich, in welchen Gruppen der Kunde ist$/ do
#   @customer_group_ids = @customer.groups.map(&:id)
#   @model.partitions.each do |partition|
#     next if partition.group_id.nil?
#     if @customer_group_ids.include? partition.group_id
#       expect(find("#booking-calendar-partitions optgroup[label='#{_("Groups of this customer")}']").has_content? partition.group.name).to be true
#     end
#   end
# end

# Dann /^dann erkennen ich, in welchen Gruppen der Kunde nicht ist$/ do
#   @model.partitions.each do |partition|
#     next if partition.group_id.nil?
#     unless @customer_group_ids.include?(partition.group_id)
#       expect(find("#booking-calendar-partitions optgroup[label='#{_("Other Groups")}']").has_content? partition.group.name).to be true
#     end
#   end
# end

# Angenommen /^ich fahre über das Problem$/ do
#   hover_for_tooltip find(".line .problems", match: first)
# end

def check_printed_contract(window_handles, ip = nil, contract_line = nil)
  while (page.driver.browser.window_handles - window_handles).empty? do end
  new_window = page.windows.find {|window|
    window if window.handle == (page.driver.browser.window_handles - window_handles).first
  }
  within_window new_window do
    find(".contract")
    expect(current_path).to eq manage_contract_path(ip, contract_line.reload.contract) if ip and contract_line
    expect(page.evaluate_script("window.printed")).to eq 1
  end
end

# Dann(/^erscheint der Benutzer unter den letzten Besuchern$/) do
#   visit manage_daily_view_path @current_inventory_pool
#   find("#last-visitors a", :text => @user.name)
# end

