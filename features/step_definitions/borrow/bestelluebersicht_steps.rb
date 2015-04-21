# -*- encoding : utf-8 -*-

#Angenommen(/^ich habe Gegenstände der Bestellung hinzugefügt$/) do
Given(/^I have added items to an order$/) do
  step "I have an unsubmitted order with models"
  @contracts = @current_user.reservations_bundles.unsubmitted
end

#Wenn(/^ich die Bestellübersicht öffne$/) do
When(/^I open my list of orders$/) do
  visit borrow_current_order_path
  expect(has_content?(_("Order overview"))).to be true
  expect(all(".line").count).to eq @current_user.reservations.unsubmitted.count
end

#############################################################################

#Dann(/^sehe ich die Einträge gruppiert nach Startdatum und Gerätepark$/) do
Then(/^I see entries grouped by start date and inventory pool$/) do
  @current_user.reservations.unsubmitted.group_by{|l| [l.start_date, l.inventory_pool]}.each do |k,v|
    find("#current-order-lines .row", text: /#{I18n.l(k[0])}.*#{k[1].name}/)
  end
end

#Dann(/^die Modelle sind alphabetisch sortiert$/) do
Then(/^the models are ordered alphabetically$/) do
  all(".emboss.deep").each do |x|
    names = x.all(".line .name").map{|name| name.text}
    expect(names.sort == names).to be true
  end
end

#Dann(/^für jeden Eintrag sehe ich die folgenden Informationen$/) do |table|
Then(/^each entry has the following information$/) do |table|
  all(".line").each do |line|
    reservations = Reservation.find JSON.parse line["data-ids"]
    table.raw.map{|e| e.first}.each do |row|
      case row
        when "Image"
          expect(line.find("img", match: :first)[:src][reservations.first.model.id.to_s]).to be
        when "Quantity"
          expect(line.has_content?(reservations.sum(&:quantity))).to be true
        when "Model name"
          expect(line.has_content?(reservations.first.model.name)).to be true
        when "Manufacturer"
          expect(line.has_content?(reservations.first.model.manufacturer)).to be true
        when "Number of days"
          expect(line.has_content?(((reservations.first.end_date - reservations.first.start_date).to_i+1).to_s)).to be true
        when "End date"
          expect(line.has_content?(I18n.l reservations.first.end_date)).to be true
        when "the various actions"
          line.find(".line-actions", match: :first)
        else
          raise "Unknown"
      end
    end
  end
end

#############################################################################

def before_max_available(user)
  h = {}
  lines = user.reservations.unsubmitted
  lines.each do |order_line|
    h[order_line.id] = order_line.model.availability_in(order_line.inventory_pool).maximum_available_in_period_summed_for_groups(order_line.start_date, order_line.end_date)
  end
  h
end

#Wenn(/^ich einen Eintrag lösche$/) do
When(/^I delete an entry$/) do
  line = find(".line", match: :first)
  line_ids = line["data-ids"]
  line.find(".dropdown-holder").click
  @before_max_available = before_max_available(@current_user)
  line.find("a[data-method='delete']").click
  #step "werde ich gefragt ob ich die Bestellung wirklich löschen möchte"
  step "I am asked whether I really want to delete the order"
  expect(has_no_selector?(".line[data-ids='#{line_ids}']")).to be true
end

#Dann(/^wird der Eintrag aus der Bestellung entfernt$/) do
Then(/^the entry is removed from the order$/) do
  expect(all(".line").count).to eq @current_user.reservations.unsubmitted.count
end

#############################################################################

#Wenn(/^ich die Bestellung lösche$/) do
When(/^I delete the order$/) do
  @contracts = @current_user.reservations_bundles.unsubmitted

  @before_max_available = before_max_available(@current_user)

  a = find("a[data-method='delete'][href='/borrow/order/remove']", match: :first)
  a.click
end

#Dann(/^werde ich gefragt ob ich die Bestellung wirklich löschen möchte$/) do
Then(/^I am asked whether I really want to delete the order$/) do
  alert = page.driver.browser.switch_to.alert
  alert.accept
end

#Dann(/^alle Einträge werden aus der Bestellung gelöscht$/) do
Then(/^all entries are deleted from the order$/) do
  expect(@current_user.reservations.unsubmitted).to be_empty
  expect(@current_user.reservations_bundles.unsubmitted).to be_empty
end

#Dann(/^die Gegenstände sind wieder zur Ausleihe verfügbar$/) do
Then(/^the items are available for borrowing again$/) do
  @current_user.reservations.unsubmitted.each do |reservation|
    after_max_available = reservation.model.availability_in(reservation.inventory_pool).maximum_available_in_period_summed_for_groups(reservation.start_date, reservation.end_date)
    expect(after_max_available).to eq @before_max_available[reservation.id]
  end
end

#Dann(/^ich befinde mich wieder auf der Startseite$/) do
Then(/^I am again on the borrow section's start page$/) do
  expect(current_path).to eq borrow_root_path
end

#############################################################################

#Wenn(/^ich einen Zweck eingebe$/) do
When(/^I enter a purpose$/) do
  find("form textarea[name='purpose']", match: :first).set Faker::Lorem.sentences(2).join()
end

#Wenn(/^ich die Bestellung abschliesse$/) do
When(/^I submit the order$/) do
  find("form button.green", match: :first).click
end

#Dann(/^ändert sich der Status der Bestellung auf Abgeschickt$/) do
Then(/^the order's status changes to submitted$/) do
  @contracts.each do |contract|
    expect(contract.status).to eq :submitted
  end
end

#Dann(/^ich erhalte eine Bestellbestätigung$/) do
Then(/^I see an order confirmation$/) do
  find(".notice", match: :first)
end

#Dann(/^in der Bestellbestätigung wird mitgeteilt, dass die Bestellung in Kürze bearbeitet wird$/) do
Then(/^the order confirmation lets me know that my order will be handled soon$/) do
  find(".notice", match: :first, text: _("Your order has been successfully submitted, but is NOT YET APPROVED."))
end

#############################################################################

#Wenn(/^der Zweck nicht abgefüllt wird$/) do
When(/^I don't fill in the purpose$/) do
  find("form textarea[name='purpose']", match: :first).set ""
end

#Dann(/^hat der Benutzer keine Möglichkeit die Bestellung abzuschicken$/) do
Then(/^I can't submit my order$/) do
  #step "ich die Bestellung abschliesse"
  step 'I submit the order'
  #step "wird die Bestellung nicht abgeschlossen"
  step 'the order is not submitted'
  #step "ich erhalte eine Fehlermeldung"
  step 'I see an error message'
end

#############################################################################

#Wenn(/^ich den Eintrag ändere$/) do
When(/^I change the entry$/) do
  if @just_changed_line
    @just_changed_line.click
  else
    # try to get reservations where quantity is still increasable
    line_to_edit = all("[data-change-order-lines]").detect do |line|
      reservations = Reservation.find JSON.parse line["data-ids"]
      if reservations.first.maximum_available_quantity > 0
        @changed_lines = reservations
      end
    end

    if line_to_edit
      line_to_edit.click
    else
      @changed_lines = Reservation.find JSON.parse find("[data-change-order-lines]", match: :first)["data-ids"]
      find("[data-change-order-lines]", match: :first).click
    end
  end
end

#Dann(/^öffnet der Kalender$/) do
#Then(/^the calendar opens$/) do
#  find("#booking-calendar .fc-widget-content", :match => :first)
#end

#Dann(/^ich ändere die aktuellen Einstellung$/) do
Then(/^I change the date$/) do
  @new_date = select_available_not_closed_date(:start, Date.today)
  select_available_not_closed_date(:end, @new_date)
end

#Dann(/^wird der Eintrag gemäss aktuellen Einstellungen geändert$/) do
Then(/^the entry's date is changed accordingly$/) do
  within(".line", match: :first) do
    find("[data-change-order-lines]").click
  end
  within ".modal" do
    find("#booking-calendar .fc-widget-content", :match => :first)
    find(".modal-close").click
  end
  if @new_date
    expect(@changed_lines.first.reload.start_date).to eq @new_date
  end
  if @new_quantity
    line = @changed_lines.first
    t = line.user.reservations.where(inventory_pool_id: line.inventory_pool_id,
                                       status: line.status,
                                       model_id: line.model_id,
                                       start_date: line.start_date,
                                       end_date: line.end_date).sum(:quantity)
    expect(t).to eq @new_quantity

    @just_changed_line = find("[data-model-id='#{line.model_id}'][data-start-date='#{line.start_date}'][data-end-date='#{line.end_date}']")
  end
end

#Dann(/^der Eintrag wird in der Liste anhand der des aktuellen Startdatums und des Geräteparks gruppiert$/) do
Then(/^the entry is grouped based on its current start date and inventory pool$/) do
  @current_user.reservations_bundles.unsubmitted.each(&:reload)
  step 'I see entries grouped by start date and inventory pool'
end

# Dann(/^sehe ich die Zeitinformationen in folgendem Format "(.*?)"$/) do |format|
Then(/^I see the timer formatted as "(.*?)"$/) do |format|
  find("#timeout-countdown-time", match: :first, text: Regexp.new(format.gsub("mm", "\\d+").gsub("ss", "\\d+")))
end
