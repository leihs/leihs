# -*- encoding : utf-8 -*-

Dann(/^sehe ich die Anzahl meiner abgeschickten, noch nicht genehmigten Bestellungen auf jeder Seite$/) do
  [borrow_root_path,
   borrow_inventory_pools_path,
   borrow_current_order_path,
   borrow_current_user_path].each do |path|
    visit path
    find("nav a[href='#{borrow_orders_path}'] .badge", match: :first).text.to_i.should == @current_user.contracts.submitted.count
  end
end

Wenn(/^ich auf den Bestellungen Link drücke$/) do
  visit borrow_root_path
  find("nav a[href='#{borrow_orders_path}']", match: :first).click
end

Dann(/^sehe ich meine abgeschickten, noch nicht genehmigten Bestellungen$/) do
  @current_user.contracts.submitted.each do |contract|
    page.should have_content contract.inventory_pool.name
  end
end

Dann(/^ich sehe die Information, dass die Bestellung noch nicht genehmigt wurde$/) do
  page.should have_content _("These orders have been successfully submitted, but are NOT YET APPROVED.")
end

Dann(/^die Bestellungen sind nach Datum und Gerätepark sortiert$/) do
  titles = all(".row.padding-inset-l").map {|x| [Date.parse(x.find("h3", match: :first).text), x.find("h2", match: :first).text]}
  titles.empty?.should be_false
  expect(titles.sort == titles).to be_true
end

Dann(/^jede Bestellung zeigt die zu genehmigenden Geräte$/) do
  @current_user.contracts.submitted.each do |contract|
    contract.lines.each do |line|
      find(".line", match: :prefer_exact, text: line.model.name)
    end
  end
end

Dann(/^die Geräte der Bestellung sind alphabetisch sortiert nach Modellname$/) do
  all(".separated-top").each do |block|
    names = block.all(".line").map {|x| x.text.split("\n")[1]}
    expect(names.sort == names).to be_true
  end
end

