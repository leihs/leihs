# -*- encoding : utf-8 -*-

def resolve_conflict_for_model name
  # open booking calender for model
  @model = Model.find {|m| [m.name, m.product].include? name }
  line = find(".line", :text => @model.name, :match => :first)
  ids = line[:"data-ids"]
  line.find(".button", :text => _("Change entry")).click
  page.should have_selector("#booking-calendar .fc-day-content")
  find("#booking-calendar-quantity").set 1
  # find available start and end date
  date = Date.today
  while all(".available:not(.closed)[data-date='#{date.to_s}']").empty? do
    date += 1
  end
  step "ich setze das Startdatum im Kalendar auf '#{I18n::l(date)}'"
  step "ich setze das Enddatum im Kalendar auf '#{I18n::l(date)}'"
  find(".modal .button.green").click
  find(".line", :text => @model.name, :match => :first)
  has_no_selector?("#booking-calendar").should be_true
  has_no_selector?(".line[data-ids='#{ids}'] .line-info.red").should be_true
end

Angenommen(/^ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde$/) do
  step "ich habe eine offene Bestellung mit Modellen"
  step "ein Modell ist nicht verfügbar"
  step "ich länger als 30 Minuten keine Aktivität ausgeführt habe"
  step "ich eine Aktivität ausführe"
  step "werde ich auf die Timeout Page geleitet"
  step "ich sehe eine Information, dass die Geräte nicht mehr reserviert sind"
end

Angenommen(/^ich zur Timeout Page mit (\d+) Konfliktmodellen weitergeleitet werde$/) do |n|
  step "ich habe eine offene Bestellung mit Modellen"
  step "#{n} Modelle sind nicht verfügbar"
  step "ich länger als 30 Minuten keine Aktivität ausgeführt habe"
  step "ich eine Aktivität ausführe"
  step "werde ich auf die Timeout Page geleitet"
  step "ich sehe eine Information, dass die Geräte nicht mehr reserviert sind"
end

Dann(/^ich sehe eine Information, dass die Geräte nicht mehr reserviert sind$/) do
  page.should have_content _("%d minutes passed. The items are not reserved for you any more!") % Contract::TIMEOUT_MINUTES
end

Dann(/^ich sehe eine Information, dass alle Geräte wieder verfügbar sind$/) do
  page.should have_content _("Your order has been modified. All reservations are now available.")
end

#########################################################################

Dann(/^sehe ich meine Bestellung$/) do
  find("#current-order-lines")
end

Dann(/^die nicht mehr verfügbaren Modelle sind hervorgehoben$/) do
  @current_user.contracts.unsubmitted.flat_map(&:lines).each do |line|
    unless line.available?
      first("[data-line-ids*='#{line.id}']").find(:xpath, "./../../..").find(".line-info.red[title='#{_("Not available")}']")
    end
  end
end

Dann(/^ich kann Einträge löschen$/) do
  all(".row.line").each do |x|
    x.first("a", text: _("Delete"))
  end
end

Dann(/^ich kann Einträge editieren$/) do
  all(".row.line").each do |x|
    x.find("button", text: _("Change entry"))
  end
end

Dann(/^ich kann zur Hauptübersicht$/) do
  find("a", text: _("Continue this order"))
end

#########################################################################

Dann(/^wird die Bestellung des Benutzers gelöscht$/) do
  @contract_ids.each do |contract_id|
    expect { Contract.find(contract_id) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

Dann(/^ich lande auf der Seite der Hauptkategorien$/) do
  current_path.should == borrow_root_path
end

#########################################################################

Angenommen(/^ich lösche einen Eintrag$/) do
  line = all(".row.line").to_a.sample
  @line_ids = line.find("button[data-line-ids]")["data-line-ids"].gsub(/\[|\]/, "").split(',').map(&:to_i)
  @line_ids.all? {|id| @current_user.contracts.unsubmitted.flat_map(&:contract_line_ids).include?(id) }.should be_true
  line.find(".dropdown-toggle").hover
  line.find("a", text: _("Delete")).click
  alert = page.driver.browser.switch_to.alert
  alert.accept
  sleep 0.5
end

Dann(/^wird der Eintrag aus der Bestellung gelöscht$/) do
  @line_ids.all? {|id| page.has_no_selector? "button[data-line-ids='[#{id}]']"}.should be_true
  @line_ids.all? {|id| not @current_user.contracts.unsubmitted.flat_map(&:contract_line_ids).include?(id) }.should be_true
end

#########################################################################

Angenommen(/^ich einen Eintrag ändere$/) do
  step "ich den Eintrag ändere"
  step "öffnet der Kalender"
  step "ich ändere die aktuellen Einstellung"
  step "speichere die Einstellungen"
end

When(/^ich die Menge eines Eintrags heraufsetze$/) do
  step "ich den Eintrag ändere"
  step "öffnet der Kalender"
  @new_quantity = find("#booking-calendar-quantity")[:max].to_i
  find("#booking-calendar-quantity").set(@new_quantity)
  step "speichere die Einstellungen"
end

When(/^ich die Menge eines Eintrags heruntersetze$/) do
  step "ich den Eintrag ändere"
  step "öffnet der Kalender"
  @new_quantity = 1
  find("#booking-calendar-quantity").set(@new_quantity)
  step "speichere die Einstellungen"
end

Dann(/^werden die Änderungen gespeichert$/) do
  step "wird der Eintrag gemäss aktuellen Einstellungen geändert"
  step "der Eintrag wird in der Liste anhand der des aktuellen Startdatums und des Geräteparks gruppiert"
end

Dann(/^lande ich wieder auf der Timeout Page$/) do
  step "werde ich auf die Timeout Page geleitet"
end

#########################################################################

Wenn(/^ein Modell nicht verfügbar ist$/) do
  @current_user.contracts.unsubmitted.flat_map(&:lines).any?{|l| not l.available?}.should be_true
end

Wenn(/^ich auf "(.*?)" drücke$/) do |arg1|
  case arg1
    when "Diese Bestellung fortsetzen"
      find(".button", text: _("Continue this order")).click
    when "Mit den verfügbaren Modellen weiterfahren"
      find(".dropdown-item", text: _("Continue with available models only")).click
    when "Delegationen"
      find(".dropdown-item", text: _("Delegations")).click
  end
end

Dann(/^ich erhalte einen Fehler$/) do
  page.should have_content _("Please solve the conflicts for all highlighted lines in order to continue.")
end

#########################################################################

Angenommen(/^die letzte Aktivität auf meiner Bestellung ist mehr als (\d+) minuten her$/) do |minutes|
  @current_user.contracts.unsubmitted.each do |contract|
    contract.update_attributes(updated_at: Time.now - (minutes.to_i+1).minutes)
  end
end

Wenn(/^ich die Seite der Hauptkategorien besuche$/) do
  step "man befindet sich auf der Seite der Hauptkategorien"
end

Dann(/^lande ich auf der Bestellung\-Abgelaufen\-Seite$/) do
  current_path.should == borrow_order_timed_out_path
end

When(/^werden die nicht verfügbaren Modelle aus der Bestellung gelöscht$/) do
  @current_user.contracts.unsubmitted.flat_map(&:lines).all? {|l| l.available? }.should be_true
end

Wenn(/^ich einen der Fehler korrigiere$/) do
  @line_ids = @current_user.contracts.unsubmitted.flat_map(&:lines).select{|l| not l.available?}.map(&:id)
  resolve_conflict_for_model find(".row.line[data-line-ids='[#{@line_ids.delete_at(0)}]']").first(".col6of10").text
end

Wenn(/^ich alle Fehler korrigiere$/) do
  @line_ids.each {|line_id| resolve_conflict_for_model find(".row.line[data-line-ids='[#{line_id}]']").first(".col6of10").text}
end

Dann(/^verschwindet die Fehlermeldung$/) do
  should_not have_content _("Please solve the conflicts for all highlighted lines in order to continue.")
end
