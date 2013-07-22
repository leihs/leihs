# -*- encoding : utf-8 -*-

Angenommen(/^ich habe Gegenstände der Bestellung hinzugefügt$/) do
  step "ich habe eine offene Bestellung mit Modellen"
  @current_user.get_current_order.purpose = FactoryGirl.create :purpose
end

Wenn(/^ich die Bestellübersicht öffne$/) do
  visit borrow_current_order_path
  page.should have_content _("Order Overview")
  all(".line").count.should == @current_user.get_current_order.lines.count
end

#############################################################################

Dann(/^sehe ich die Einträge gruppiert nach Startdatum und Gerätepark$/) do
  @current_user.get_current_order.lines.group_by{|l| [l.start_date, l.inventory_pool]}.each do |k,v|
    find("*", text: I18n.l(k[0])).should have_content k[1].name
  end
end

Dann(/^die Modelle sind alphabetisch sortiert$/) do
  all(".emboss.deep").each do |x|
    names = x.all(".line .name").map{|name| name.text}
    expect(names.sort == names).to be_true
  end
end

Dann(/^für jeden Eintrag sehe ich die folgenden Informationen$/) do |table|
  all(".line").each do |line|
    order_lines = OrderLine.find JSON.parse line["data-line-ids"]
    table.raw.map{|e| e.first}.each do |row|
      case row
        when "Bild"
          line.find("img")[:src][order_lines.first.model.id.to_s].should be
        when "Anzahl"
           line.should have_content order_lines.sum(&:quantity)
        when "Modellname"
          line.should have_content order_lines.first.model.name
        when "Hersteller"
          line.should have_content order_lines.first.model.manufacturer
        when "Anzahl der Tage"
          line.should have_content ((order_lines.first.end_date - order_lines.first.start_date).to_i+1).to_s
        when "Enddatum"
          line.should have_content I18n.l order_lines.first.end_date
        when "die versch. Aktionen"
          line.find(".line-actions")
        else
          raise "Unbekannt"
      end
    end
  end
end

#############################################################################

def before_max_available(order)
  h = {}
  order.order_lines.each do |order_line|
    h[order_line.id] = order_line.model.availability_in(order_line.inventory_pool).maximum_available_in_period_summed_for_groups(order_line.start_date, order_line.end_date)
  end
  h
end

Wenn(/^ich einen Eintrag lösche$/) do
  lines = all(".line")
  line = lines.sample
  line.find(".dropdown-holder").click
  a = line.find("a[data-method='delete']")
  @before_max_available = before_max_available(@current_user.get_current_order)
  a.click
  step "werde ich gefragt ob ich die Bestellung wirklich löschen möchte"
end

Dann(/^wird der Eintrag aus der Bestellung entfernt$/) do
  all(".line").count.should == @current_user.get_current_order.lines.count
end

#############################################################################

Wenn(/^ich die Bestellung lösche$/) do
  @order_line_ids = @current_user.get_current_order.order_line_ids

  @before_max_available = before_max_available(@current_user.get_current_order)

  a = find("a[data-method='delete'][href='/borrow/order/remove']")
  a.click
end

Dann(/^werde ich gefragt ob ich die Bestellung wirklich löschen möchte$/) do
  alert = page.driver.browser.switch_to.alert
  alert.accept
  sleep 0.5
end

Dann(/^alle Einträge werden aus der Bestellung gelöscht$/) do
  OrderLine.where(id: @order_line_ids).count.should == 0
  Order.where(id: @current_user.get_current_order.id).count.should == 0
end

Dann(/^die Gegenstände sind wieder zur Ausleihe verfügbar$/) do
  @current_user.get_current_order.order_lines.each do |order_line|
    order_line.inventory_pool.reload # reloading the running_lines
    after_max_available = order_line.model.availability_in(order_line.inventory_pool).maximum_available_in_period_summed_for_groups(order_line.start_date, order_line.end_date)
    after_max_available.should == if OrderLine.find_by_id(order_line.id).nil?
                                    @before_max_available[order_line.id] + order_line.quantity
                                  else
                                    @before_max_available[order_line.id]
                                  end
  end
end

Dann(/^ich befinde mich wieder auf der Startseite$/) do
  current_path.should == borrow_root_path
end

#############################################################################

Wenn(/^ich einen Zweck eingebe$/) do
  find("form textarea[name='purpose']").set Faker::Lorem.sentences 2
end

Wenn(/^ich die Bestellung abschliesse$/) do
  find("form button.green").click
end

Dann(/^ändert sich der Status der Bestellung auf Abgeschickt$/) do
  @current_user.get_current_order.reload.status_const.should == Order::SUBMITTED
end

Dann(/^ich erhalte eine Bestellbestätigung$/) do
  find(".notice")
end

Dann(/^in der Bestellbestätigung wird mitgeteilt, dass die Bestellung in Kürze bearbeitet wird$/) do
  find(".notice", text: _("The order has been successfully submitted, but is NOT YET CONFIRMED."))
end

#############################################################################

Wenn(/^der Zweck nicht abgefüllt wird$/) do
  find("form textarea[name='purpose']").set ""
end

Dann(/^hat der Benutzer keine Möglichkeit die Bestellung abzuschicken$/) do
  step "ich die Bestellung abschliesse"
  step "wird die Bestellung nicht abgeschlossen"
  step "ich erhalte eine Fehlermeldung"
end

#############################################################################

Wenn(/^ich den Eintrag ändere$/) do
  @changed_lines = OrderLine.find JSON.parse find("[data-change-order-lines]")["data-line-ids"]
  find("[data-change-order-lines]").click
end

Dann(/^öffnet der Kalender$/) do
  wait_until{find("#booking-calendar .fc-widget-content")}
end

Dann(/^ich ändere die aktuellen Einstellung$/) do
  @changed_lines.first.start_date = Date.today
  while not @changed_lines.first.available?
    @new_date = @changed_lines.first.end_date = @changed_lines.first.start_date += 1.day
  end
  step "ich setze das Startdatum im Kalendar auf '#{I18n.l(@new_date)}'"
  step "ich setze das Enddatum im Kalendar auf '#{I18n.l(@new_date)}'"
end

Dann(/^speichere die Einstellungen$/) do
  find("#submit-booking-calendar").click
end

Dann(/^wird der Eintrag gemäss aktuellen Einstellungen geändert$/) do
  step "ensure there are no active requests"
  wait_until{all(".loading").empty?}
  wait_until{@changed_lines.first.reload.start_date == @new_date}
  wait_until{find("*", :text => I18n.l(@new_date))}
end

Dann(/^der Eintrag wird in der Liste anhand der des aktuellen Startdatums und des Geräteparks gruppiert$/) do
  @current_user.get_current_order.reload
  step 'sehe ich die Einträge gruppiert nach Startdatum und Gerätepark'
end
