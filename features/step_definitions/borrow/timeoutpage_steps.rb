# -*- encoding : utf-8 -*-

Angenommen(/^ich zur Timeout Page weitergeleitet werde$/) do
  step "ich habe eine offene Bestellung mit Modellen"
  step "ein Modell ist nicht verfügbar"
  step "ich länger als 30 Minuten keine Aktivität ausgeführt habe"
  step "ich eine Aktivität ausführe"
  step "werde ich auf die Timeout Page geleitet"
  step "ich sehe eine Information, dass die Geräte nicht mehr reserviert sind"
end

Dann(/^ich sehe eine Information, dass die Geräte nicht mehr reserviert sind$/) do
  page.should have_content _("Your order is older than %d minutes, the items are not reserved any more!") % Order::TIMEOUT_MINUTES
end

#########################################################################

Dann(/^sehe ich meine Bestellung$/) do
  find("#current-order-lines")
end

Dann(/^die nicht mehr verfügbaren Modelle sind hervorgehoben$/) do
  @current_user.get_current_order.lines.each do |line|
    unless line.available?
      find("[data-line-ids*='#{line.id}']").find(:xpath, "./../../..").find(".line-info.red[title='#{_("Not available")}']")
    end
  end
end

Dann(/^ich kann Einträge löschen$/) do
  all(".row.line").each do |x|
    x.find("a", text: _("Delete"))
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

Dann(/^wird die Bestellung gelöscht$/) do
  expect { @current_user.get_current_order.reload }.to raise_error(ActiveRecord::RecordNotFound)
end

Dann(/^ich lande auf der Seite der Hauptkategorien$/) do
  current_path.should == borrow_root_path
end

#########################################################################

Angenommen(/^ich lösche einen Eintrag$/) do
  row = find(".row.line")
  @line_ids = row.find("button[data-line-ids]")["data-line-ids"].gsub(/\[|\]/, "").split(',').map(&:to_i)
  @line_ids.all? {|id| @current_user.get_current_order.lines.exists?(id) }.should be_true
  row = find("a", text: _("Delete")).click
end

Dann(/^wird der Eintrag aus der Bestellung gelöscht$/) do
  @current_user.get_current_order.reload
  @line_ids.all? {|id| not @current_user.get_current_order.lines.exists?(id) }.should be_true
end

#########################################################################

Angenommen(/^ich einen Eintrag ändere$/) do
  step "ich den Eintrag ändere"
  step "öffnet der Kalender"
  step "ich ändere die aktuellen Einstellung"
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
  @current_user.get_current_order.lines.any?{|l| not l.available?}.should be_true
end

Wenn(/^ich auf 'Weiter' drücke$/) do
  find(".button", :text => _("Continue this order")).click
end

Dann(/^ich erhalte ich einen Fehler$/) do
  page.should have_content _("Please solve the conflicts for all highlighted lines in order to continue")
end