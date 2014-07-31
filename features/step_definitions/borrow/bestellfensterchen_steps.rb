# -*- encoding : utf-8 -*-

Angenommen(/^man befindet sich auf der Bestellübersicht$/) do
  visit borrow_current_order_path
end

Dann(/^ich lande auf der Seite der Bestellübersicht$/) do
  expect(current_path).to eq borrow_current_order_path
end

Dann(/^sehe ich kein Bestellfensterchen$/) do
  expect(has_no_selector?(".col1of5 .navigation-tab-item", text: _("Order"))).to be true
end

Dann(/^sehe ich das Bestellfensterchen$/) do
  expect(has_selector?(".col1of5 .navigation-tab-item", text: _("Order"))).to be true
end

Dann(/^erscheint es im Bestellfensterchen$/) do
  visit borrow_root_path
  find("#current-order-basket", match: :first)
end

Dann(/^die Modelle im Bestellfensterchen sind alphabetisch sortiert$/) do
  @names = all("#current-order-basket #current-order-lines .line").map{|l| l[:title] }
  expect(@names.sort == @names).to be true
end

Dann(/^gleiche Modelle werden zusammengefasst$/) do
  expect(@names.uniq == @names).to be true
end

Wenn(/^das gleiche Modell nochmals hinzugefügt wird$/) do
  FactoryGirl.create(:contract_line,
                     :contract => @current_user.get_unsubmitted_contract(@inventory_pool),
                     :model => @new_contract_line.model)
  step "erscheint es im Bestellfensterchen"
end

Dann(/^wird die Anzahl dieses Modells erhöht$/) do
  line = find("#current-order-basket #current-order-lines .line[title='#{@new_contract_line.model.name}']", match: :first)
  expect(line.find("span", match: :first).text).to eq "2x #{@new_contract_line.model.name}"
end

Dann(/^ich kann zur detaillierten Bestellübersicht gelangen$/) do
  find("#current-order-basket .button.green", text: _("Complete order"))
end

Wenn(/^ich mit dem Kalender ein Modell der Bestellung hinzufüge$/) do
  step 'man sich auf der Modellliste befindet'
  step 'man ein Startdatum auswählt'
  step 'man auf einem verfügbaren Model "Zur Bestellung hinzufügen" wählt'
  step 'öffnet sich der Kalender'
  step 'alle Angaben die ich im Kalender mache gültig sind'
end

Dann(/^wird das Bestellfensterchen aktualisiert$/) do
  step 'ist das Modell mit Start- und Enddatum, Anzahl und Gerätepark der Bestellung hinzugefügt worden'
  step "erscheint es im Bestellfensterchen"
  find("#current-order-basket #current-order-lines .line[title='#{@model.name}']", match: :first, text: "#{@quantity}x #{@model.name}")
end

Angenommen(/^meine Bestellung ist leer$/) do
  expect(@current_user.contracts.unsubmitted.flat_map(&:lines).empty?).to be true
end

Dann(/^sehe ich keine Zeitanzeige$/) do
  expect(all("#current-order-basket #timeout-countdown", :visible => true).empty?).to be true
end

Dann(/^sehe ich die Zeitanzeige$/) do
  visit root_path
  expect(has_selector?("#current-order-basket #timeout-countdown", :visible => true)).to be true
  sleep(0.33)
  @timeoutStart = if @current_user.contracts.unsubmitted.empty?
                    Time.now
                  else
                    @current_user.contracts.unsubmitted.sample.updated_at
                  end
  @countdown = find("#timeout-countdown-time", match: :first).text
end

Dann(/^die Zeitanzeige ist in einer Schaltfläche im Reiter "Bestellung" auf der rechten Seite$/) do
  find("#current-order-basket .navigation-tab-item #timeout-countdown #timeout-countdown-time", match: :first)
end

Dann(/^die Zeitanzeige zählt von (\d+) Minuten herunter$/) do |timeout_minutes|
  @countdown = find("#timeout-countdown-time", match: :first).text
  minutes = @countdown.split(":")[0].to_i
  seconds = @countdown.split(":")[1].to_i
  expect(minutes >= (Contract::TIMEOUT_MINUTES - 1)).to be true
  sleep(0.66)
  expect(seconds > find("#timeout-countdown-time", match: :first).reload.text.split(":")[1].to_i).to be true
end

Angenommen(/^die Bestellung ist nicht leer$/) do
  step 'ich ein Modell der Bestellung hinzufüge'
end

Wenn(/^ich den Time-Out zurücksetze$/) do
  @countdown = find("#timeout-countdown-time", match: :first).text
  find("#timeout-countdown-refresh", match: :first).click
end

Dann(/^wird die Zeit zurückgesetzt$/) do
  seconds = @countdown.split(":")[1].to_i
  sleep(0.33)
  secondsNow = find("#timeout-countdown-time", match: :first).reload.text.split(":")[1].to_i
  expect(seconds <= secondsNow).to be true
end

Wenn(/^die Zeit abgelaufen ist$/) do
  Contract::TIMEOUT_MINUTES = 1
  step 'ich ein Modell der Bestellung hinzufüge'
  step 'sehe ich die Zeitanzeige'
  sleep(70)
end

Dann(/^werde ich auf die Timeout Page weitergeleitet$/) do
  step "ich sehe eine Information, dass die Geräte nicht mehr reserviert sind"
  expect(current_path).to eq borrow_order_timed_out_path
end

Wenn(/^die Zeit überschritten ist$/) do
  past_date = Time.now - (Contract::TIMEOUT_MINUTES + 1).minutes
  @current_user.contracts.unsubmitted.each do |contract|
    contract.update_attribute :updated_at, past_date
  end
  page.execute_script %Q{ localStorage.currentTimeout = moment("#{past_date.to_s}").toDate() }
  sleep(0.33) # fix lazy request problem
end
