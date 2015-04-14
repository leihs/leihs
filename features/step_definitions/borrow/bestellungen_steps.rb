# -*- encoding : utf-8 -*-

#Dann(/^sehe ich die Anzahl meiner abgeschickten, noch nicht genehmigten Bestellungen auf jeder Seite$/) do
Then(/^I see the number of submitted, unapproved orders on every page$/) do
  [borrow_root_path,
   borrow_inventory_pools_path,
   borrow_current_order_path,
   borrow_current_user_path].each do |path|
    visit path
    expect(find("nav a[href='#{borrow_orders_path}'] .badge", match: :first).text.to_i).to eq @current_user.contract_lines.submitted.count
  end
end

#Wenn(/^ich auf den Bestellungen Link drücke$/) do
When(/^I am listing my orders$/) do
  visit borrow_root_path
  find("nav a[href='#{borrow_orders_path}']", match: :first).click
end

#Dann(/^sehe ich meine abgeschickten, noch nicht genehmigten Bestellungen$/) do
Then(/^I see my submitted, unapproved orders$/) do
  @current_user.contracts.submitted.each do |contract|
    expect(has_content?(contract.inventory_pool.name)).to be true
  end
end

#Dann(/^ich sehe die Information, dass die Bestellung noch nicht genehmigt wurde$/) do
Then(/^I see the information that the order has not yet been approved$/) do
  expect(has_content?(_("These orders have been successfully submitted, but are NOT YET APPROVED."))).to be true
end

#Dann(/^die Bestellungen sind nach Datum und Gerätepark sortiert$/) do
Then(/^the orders are sorted by date and inventory pool$/) do
  titles = all(".row.padding-inset-l").map {|x| [Date.parse(x.find("h3", match: :first).text), x.find("h2", match: :first).text]}
  expect(titles.empty?).to be false
  expect(titles.sort == titles).to be true
end

#Dann(/^jede Bestellung zeigt die zu genehmigenden Geräte$/) do
Then(/^each order shows the items to approve$/) do
  @current_user.contract_lines.submitted.each do |line|
    find(".line", match: :prefer_exact, text: line.model.name)
  end
end

#Dann(/^die Geräte der Bestellung sind alphabetisch sortiert nach Modellname$/) do
Then(/^the items in the order are sorted alphabetically and by model name$/) do
  all(".separated-top").each do |block|
    names = block.all(".line").map {|x| x.text.split("\n")[1]}
    expect(names.sort == names).to be true
  end
end

