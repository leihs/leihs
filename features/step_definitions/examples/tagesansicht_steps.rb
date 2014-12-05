# encoding: utf-8

Angenommen(/^eine Bestellungen mit zwei unterschiedlichen Zeitspannen existiert$/) do
  @customer = @current_inventory_pool.users.customers.sample
  @contract = FactoryGirl.create :contract, user: @customer, status: 'submitted', inventory_pool: @current_inventory_pool
  FactoryGirl.create :contract_line, contract_id: @contract.id, start_date: Date.today, end_date: Date.tomorrow 
  FactoryGirl.create :contract_line, contract_id: @contract.id, start_date: Date.today, end_date: Date.today+10.days 
end

Dann(/^sehe ich für diese Bestellung die längste Zeitspanne direkt auf der Linie$/) do
  line_with_max_range = @contract.item_lines.max{|line| line.end_date - line.start_date}
  range = (line_with_max_range.end_date-line_with_max_range.start_date).to_i+1
  expect(find(".line[data-id='#{@contract.id}']").has_content? "#{range} #{_('days')}").to be true
end

When(/^eigenes Benutzer sind gesperrt$/) do
  @current_inventory_pool.users.customers.each do |user|
    ensure_suspended_user(user, @current_inventory_pool)
  end
end

When(/^sehe ich auf allen Linien dieses Benutzers den Sperrstatus 'Gesperrt'$/) do
  find("[data-type='user-cell'] span.darkred-text", match: :first)
  all("[data-type='user-cell']").each do |line|
    line.find("span.darkred-text", text: "%s!" % _("Suspended"))
  end
end