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
  first("#current-order-basket")
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
  line = first("#current-order-basket #current-order-lines .line[title='#{@new_order_line.model.name}']")
  line.first("span").text.should == "2x #{@new_order_line.model.name}"
end

Dann(/^ich kann zur detaillierten Bestellübersicht gelangen$/) do
  first("#current-order-basket .button.green", text: _("Order overview"))
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
  first("#current-order-basket #current-order-lines .line[title='#{@model.name}']", :text => "#{@quantity}x #{@model.name}")
end

Angenommen(/^meine Bestellung ist leer$/) do
  @current_user.get_current_order.lines.empty?.should be_true
end

Dann(/^sehe ich keine Zeitanzeige$/) do
  all("#current-order-basket #timeout-countdown", :visible => true).empty?.should be_true
end

Dann(/^sehe ich die Zeitanzeige$/) do
  visit root_path
  page.should have_selector("#current-order-basket #timeout-countdown", :visible => true)
  sleep(2)
  @timeoutStart = @current_user.get_current_order.created_at
  @countdown = first("#timeout-countdown-time").text
end

Dann(/^die Zeitanzeige ist in einer Schaltfläche im Reiter "Bestellung" auf der rechten Seite$/) do
  first("#current-order-basket .navigation-tab-item #timeout-countdown #timeout-countdown-time")
end

Dann(/^die Zeitanzeige zählt von (\d+) Minuten herunter$/) do |timeout_minutes|
  @countdown = first("#timeout-countdown-time").text
  minutes = @countdown.split(":")[0].to_i
  seconds = @countdown.split(":")[1].to_i
  expect(minutes >= (Order::TIMEOUT_MINUTES - 1)).to be_true
  sleep(2)
  expect(seconds > first("#timeout-countdown-time").reload.text.split(":")[1].to_i).to be_true
end

Angenommen(/^die Bestellung ist nicht leer$/) do
  step 'ich ein Modell der Bestellung hinzufüge'
end

Wenn(/^ich den Time-Out zurücksetze$/) do
  @countdown = first("#timeout-countdown-time").text
  first("#timeout-countdown-refresh").click
end

Dann(/^wird die Zeit zurückgesetzt$/) do
  seconds = @countdown.split(":")[1].to_i
  sleep(2)
  secondsNow = first("#timeout-countdown-time").reload.text.split(":")[1].to_i
  expect(seconds <= secondsNow).to be_true
end

Wenn(/^die Zeit abgelaufen ist$/) do
  Order::TIMEOUT_MINUTES = 1
  step 'ich ein Modell der Bestellung hinzufüge'
  step 'sehe ich die Zeitanzeige'
  sleep(70)
end

Dann(/^werde ich auf die Timeout Page weitergeleitet$/) do
  step "ich sehe eine Information, dass die Geräte nicht mehr reserviert sind"
  current_path.should == borrow_order_timed_out_path
end
Wenn(/^die Zeit überschritten ist$/) do
  past_date = Time.now - (Order::TIMEOUT_MINUTES + 1).minutes
  @current_user.get_current_order.update_attribute :updated_at, past_date
  page.execute_script %Q{ localStorage.currentTimeout = moment("#{past_date.to_s}").toDate() }
end
