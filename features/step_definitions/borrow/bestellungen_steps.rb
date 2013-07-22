# -*- encoding : utf-8 -*-

Dann(/^sehe ich die Anzahl meiner abgeschickten, noch nicht genehmigten Bestellungen auf jeder Seite$/) do
  [borrow_root_path,
   borrow_inventory_pools_path,
   borrow_current_order_path,
   borrow_current_user_path].each do |path|
    visit path
    a = find(".topbar a", text: _("Orders"))
    a.find(".badge").text.to_i.should == @current_user.orders.submitted.count
  end
end

Wenn(/^ich auf den Bestellungen Link drücke$/) do
  visit borrow_root_path
  find(".topbar a", text: _("Orders")).click
end

Dann(/^sehe ich meine abgeschickten, noch nicht genehmigten Bestellungen$/) do
  @current_user.orders.submitted.each do |order|
    find(".emboss.deep", text: order.inventory_pool.name)
  end
end

Dann(/^ich sehe die Information, dass die Bestellung noch nicht genehmigt wurde$/) do
  find(".emboss.notice", text: _("These orders have been successfully submitted, but are NOT YET CONFIRMED."))
end

Dann(/^die Bestellungen sind nach Datum und Gerätepark sortiert$/) do
  names = all(".emboss.deep .headline-m").map {|x| x.text}
  expect(names.sort == names).to be_true
end

Dann(/^jede Bestellung zeigt die zu genehmigenden Geräte$/) do
  @current_user.orders.submitted.each do |order|
    x = find(".emboss.deep", text: order.inventory_pool.name)
    order.lines.each do |line|
      x.find(:xpath, "./../..").find(".line .name", text: line.model.name)
    end
  end
end

Dann(/^die Geräte sind alphabetisch sortiert nach Modellname$/) do
  @current_user.orders.submitted.each do |order|
    x = find(".emboss.deep", text: order.inventory_pool.name)
    names = x.find(:xpath, "./../..").all(".line .name").map {|x| x.text}
    expect(names.sort == names).to be_true
  end
end

