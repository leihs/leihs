# -*- encoding : utf-8 -*-

Angenommen(/^es besteht bereits eine Aushändigung mit mindestens (\d+) zugewiesenen Gegenständen für einen Benutzer$/) do |count|
  @hand_over = @current_inventory_pool.visits.hand_over.find {|ho| ho.contract_lines.select(&:item).size >= count.to_i}
  @hand_over.should_not be_nil
end

Wenn(/^ich die Aushändigung öffne$/) do
  visit manage_hand_over_path(@current_inventory_pool, @hand_over.user)
end

Dann(/^sehe ich all die bereits zugewiesenen Gegenstände mittels Inventarcodes$/) do
  @hand_over.contract_lines.each {|l| page.has_content? l.item.inventory_code}
end
