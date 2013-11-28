# encoding: utf-8

Angenommen(/^eine Bestellungen mit zwei unterschiedlichen Zeitspannen existiert$/) do
  @customer = @current_inventory_pool.users.customers.sample
  @contract = FactoryGirl.create :contract, user_id: @customer.id, status: 'approved'
  FactoryGirl.create :contract_line, contract_id: @contract.id, start_date: Date.today, end_date: Date.tomorrow 
  FactoryGirl.create :contract_line, contract_id: @contract.id, start_date: Date.today, end_date: Date.today+10.days 
end

Dann(/^sehe ich für diese Bestellung die längste Zeitspanne direkt auf der Linie$/) do
  pending
end