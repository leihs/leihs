# -*- encoding : utf-8 -*-

Given(/^I hit the timeout page with a model that has conflicts$/) do
  step "I have an unsubmitted order with models"
  step "a model is not available"
  step "I have performed no activity for more than 30 minutes"
  step "I perform some activity"
  step "I am redirected to the timeout page"
  step 'I am informed that my items are no longer reserved for me'
end

#Angenommen(/^ich zur Timeout Page mit (\d+) Konfliktmodellen weitergeleitet werde$/) do |n|
Given(/^I hit the timeout page with (\d+) models that have conflicts$/) do |n|
  step "I have an unsubmitted order with models"
  step "#{n} models are not available"
  step "I have performed no activity for more than 30 minutes"
  step "I perform some activity"
  step "I am redirected to the timeout page"
  step 'I am informed that my items are no longer reserved for me'
end

#Dann(/^ich sehe eine Information, dass die Geräte nicht mehr reserviert sind$/) do
Then(/^I am informed that my items are no longer reserved for me$/) do
  expect(has_content?(_("%d minutes passed. The items are not reserved for you any more!") % Contract::TIMEOUT_MINUTES)).to be true
end

#Dann(/^ich sehe eine Information, dass alle Geräte wieder verfügbar sind$/) do
Then(/^I am informed that the remaining models are all available$/) do
  expect(has_content?(_("Your order has been modified. All reservations are now available."))).to be true
end

#########################################################################

#Dann(/^sehe ich meine Bestellung$/) do
Then(/^I see my order$/) do
  find("#current-order-lines")
end

#Dann(/^die nicht mehr verfügbaren Modelle sind hervorgehoben$/) do
Then(/^the no longer available items are highlighted$/) do
  @current_user.contract_lines.unsubmitted.each do |line|
    unless line.available?
      find("[data-ids*='#{line.id}']", match: :first).find(:xpath, "./../../..").find(".line-info.red[title='#{_("Not available")}']")
    end
  end
end

#Dann(/^ich kann Einträge löschen$/) do
Then(/^I can delete entries$/) do
  all(".row.line").each do |x|
    x.find("a", match: :first, text: _("Delete"))
  end
end

#Dann(/^ich kann Einträge editieren$/) do
Then(/^I can edit entries$/) do
  all(".row.line").each do |x|
    x.find("button", text: _("Change entry"))
  end
end

#Dann(/^ich kann zur Hauptübersicht$/) do
Then(/^I can return to the main order overview$/) do
  find("a", text: _("Continue this order"))
end

#########################################################################

#Dann(/^wird die Bestellung des Benutzers gelöscht$/) do
Then(/^the user's order has been deleted$/) do
  @contracts.each do |contract|
    expect { contract.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

#Dann(/^ich lande auf der Seite der Hauptkategorien$/) do
Then(/^I am on the root category list$/) do
  expect(current_path).to eq borrow_root_path
end

#########################################################################

#Angenommen(/^ich lösche einen Eintrag$/) do
Given(/^I delete one entry$/) do
  line = all(".row.line").to_a.sample
  @line_ids = line.find("button[data-ids]")["data-ids"].gsub(/\[|\]/, "").split(',').map(&:to_i)
  expect(@line_ids.all? { |id| @current_user.contract_lines.unsubmitted.map(&:id).include?(id) }).to be true
  line.find(".dropdown-toggle").click
  line.find("a", text: _("Delete")).click
  alert = page.driver.browser.switch_to.alert
  alert.accept
end

#Dann(/^wird der Eintrag aus der Bestellung gelöscht$/) do
Then(/^the entry is deleted from the order$/) do
  expect(@line_ids.all? { |id| page.has_no_selector? "button[data-ids='[#{id}]']" }).to be true
  expect(@line_ids.all? { |id| not @current_user.contract_lines.unsubmitted.map(&:id).include?(id) }).to be true
end

#########################################################################

#Angenommen(/^ich einen Eintrag ändere$/) do
# Given(/^I modify one entry$/) do
#   #step "ich den Eintrag ändere"
#   step 'I change the entry'
#   #step "öffnet der Kalender"
#   step 'the calendar opens'
#   #step "ich ändere die aktuellen Einstellung"
#   step 'I change the date'
#   step "I save the booking calendar"
# end

#When(/^ich die Menge eines Eintrags (heraufsetze|heruntersetze)$/) do |arg1|
When(/^I (increase|decrease) the quantity of one entry$/) do |arg1|
  #step "ich den Eintrag ändere"
  step 'I change the entry'
  #step "öffnet der Kalender"
  step 'the calendar opens'
  @new_quantity = case arg1
                    when "increase"
                      find("#booking-calendar-quantity")[:max].to_i
                    when "decrease"
                      1
                    else
                      raise
                  end
  find("#booking-calendar-quantity").set(@new_quantity)
  step "I save the booking calendar"
  step "the booking calendar is closed"
end

#Dann(/^werden die Änderungen gespeichert$/) do
# Then(/^the changes I made are saved$/) do
#   #step "wird der Eintrag gemäss aktuellen Einstellungen geändert"
#   step "the entry's date is changed accordingly"
#   #step "der Eintrag wird in der Liste anhand der des aktuellen Startdatums und des Geräteparks gruppiert"
#   step 'the entry is grouped based on its current start date and inventory pool'
# end

#Dann(/^lande ich wieder auf der Timeout Page$/) do
#  #step "werde ich auf die Timeout Page geleitet"
#  step "I am redirected to the timeout page"
#end

#########################################################################

#Wenn(/^ein Modell nicht verfügbar ist$/) do
#When(/^a model is not available$/) do
#  expect(@current_user.contract_lines.unsubmitted.any? { |l| not l.available? }).to be true
#end


# Dann(/^ich erhalte einen Fehler$/) do
#   expect(has_content?(_("Please solve the conflicts for all highlighted lines in order to continue."))).to be true
# end

#########################################################################

#Angenommen(/^die letzte Aktivität auf meiner Bestellung ist mehr als (\d+) minuten her$/) do |minutes|
#Wenn(/^ich länger als (\d+) Minuten keine Aktivität ausgeführt habe$/) do |arg1|
When(/^I have performed no activity for more than (\d+) minutes$/) do |minutes|
  Timecop.travel(Time.now + (minutes.to_i + 1).minutes)
end

#Wenn(/^ich die Seite der Hauptkategorien besuche$/) do
#  #step "man befindet sich auf der Seite der Hauptkategorien"
#  step "I am listing the root categories"
#end

#Dann(/^lande ich auf der Bestellung\-Abgelaufen\-Seite$/) do
#  expect(current_path).to eq borrow_order_timed_out_path
#end

#When(/^werden die nicht verfügbaren Modelle aus der Bestellung gelöscht$/) do
When(/^the unavailable models are deleted from the order$/) do
  expect(@current_user.contract_lines.unsubmitted.all? { |l| l.available? }).to be true
end

#Wenn(/^ich einen der Fehler korrigiere$/) do
When(/^I correct one of the errors$/) do
  @line_ids = @current_user.contract_lines.unsubmitted.select { |l| not l.available? }.map(&:id)
  resolve_conflict_for_contract_line @line_ids.delete_at(0)
end

#Wenn(/^ich alle Fehler korrigiere$/) do
When(/^I correct all errors$/) do
  @line_ids.each do |line_id|
    resolve_conflict_for_contract_line line_id
  end
end

#Dann(/^verschwindet die Fehlermeldung$/) do
Then(/^the error message appears$/) do
  expect(has_no_content? _("Please solve the conflicts for all highlighted lines in order to continue.")).to be true
end

def resolve_conflict_for_contract_line(line_id)
  within ".line[data-ids='[#{line_id}]']" do
    find(".button", :text => _("Change entry")).click
  end
  expect(has_selector?("#booking-calendar .fc-day-content")).to be true
  find("#booking-calendar-quantity").set 1

  start_date = select_available_not_closed_date
  select_available_not_closed_date(:end, start_date)
  find(".modal .button.green").click

  step "the booking calendar is closed"
  within ".line[data-ids='[#{line_id}]']" do
    expect(has_no_selector?(".line-info.red")).to be true
  end
end
