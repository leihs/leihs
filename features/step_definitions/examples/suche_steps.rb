Angenommen /^ich gebe den Inventarcode eines Gegenstandes der einem Vertrag zugewisen ist in die Suche ein$/ do
  @contract = @current_user.inventory_pools.first.contracts.signed.first
  @item = @contract.items.first
end

Dann /^sehe ich den Vertrag dem der Gegenstand zugewisen ist in der Ergebnisanzeige$/ do
  @current_user.inventory_pools.first.contracts.search(@item.inventory_code).should include @contract
end