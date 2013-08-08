# -*- encoding : utf-8 -*-

Angenommen(/^man befindet sich auf der Bestellübersicht$/) do
  visit borrow_current_order_path
end

Dann(/^ich lande auf der Seite der Bestellübersicht$/) do
  current_path.should == borrow_current_order_path
end

Dann(/^sehe ich kein Bestellfensterchen$/) do
  page.should_not have_selector(".col1of5 .navigation-tab-item", text: _("Order"))
end

Dann(/^sehe ich das Bestellfensterchen$/) do
  page.should have_selector(".col1of5 .navigation-tab-item", text: _("Order"))
end

Dann(/^erscheint es im Bestellfensterchen$/) do
  visit borrow_root_path
  find("#current-order-basket")
end

Dann(/^die Modelle im Bestellfensterchen sind alphabetisch sortiert$/) do
  @names = all("#current-order-basket #current-order-lines .line").map{|l| l[:title] }
  expect(@names.sort == @names).to be_true
end

Dann(/^gleiche Modelle werden zusammengefasst$/) do
  expect(@names.uniq == @names).to be_true
end

Wenn(/^das gleiche Modell nochmals hinzugefügt wird$/) do
  FactoryGirl.create(:order_line,
                     :order => @current_user.get_current_order,
                     :model => @new_order_line.model,
                     :inventory_pool => @inventory_pool)
  step "erscheint es im Bestellfensterchen"
end

Dann(/^wird die Anzahl dieses Modells erhöht$/) do
  line = find("#current-order-basket #current-order-lines .line[title='#{@new_order_line.model.name}']")
  line.find("span").text.should == "2x #{@new_order_line.model.name}"
end

Dann(/^ich kann zur detaillierten Bestellübersicht gelangen$/) do
  find("#current-order-basket .button.green", text: _("Order overview"))
end

Wenn(/^ich mit dem Kalender ein Modell der Bestellung hinzufüge$/) do
  step 'man sich auf der Modellliste befindet'
  step 'man auf einem Model "Zur Bestellung hinzufügen" wählt'
  step 'öffnet sich der Kalender'
  step 'alle Angaben die ich im Kalender mache gültig sind'
end

Dann(/^wird das Bestellfensterchen aktualisiert$/) do
  step 'ist das Modell mit Start- und Enddatum, Anzahl und Gerätepark der Bestellung hinzugefügt worden'
  step "erscheint es im Bestellfensterchen"
  find("#current-order-basket #current-order-lines .line[title='#{@model.name}']", :text => "#{@quantity}x #{@model.name}")
end



