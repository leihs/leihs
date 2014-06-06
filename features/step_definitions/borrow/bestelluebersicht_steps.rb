# -*- encoding : utf-8 -*-

Angenommen(/^ich habe Gegenstände der Bestellung hinzugefügt$/) do
  step "ich habe eine offene Bestellung mit Modellen"
  purpose = FactoryGirl.create :purpose
  @current_user.contracts.unsubmitted.each do |contract|
    contract.purpose = purpose
  end
  @contract_ids = @current_user.contracts.unsubmitted.pluck(:id)
end

Wenn(/^ich die Bestellübersicht öffne$/) do
  visit borrow_current_order_path
  page.should have_content _("Order overview")
  all(".line").count.should == @current_user.contracts.unsubmitted.flat_map(&:lines).count
end

#############################################################################

Dann(/^sehe ich die Einträge gruppiert nach Startdatum und Gerätepark$/) do
  @current_user.contracts.unsubmitted.flat_map(&:lines).group_by{|l| [l.start_date, l.inventory_pool]}.each do |k,v|
    find("#current-order-lines .row", text: I18n.l(k[0]), match: :first).should have_content k[1].name
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
    contract_lines = ContractLine.find JSON.parse line["data-line-ids"]
    table.raw.map{|e| e.first}.each do |row|
      case row
        when "Bild"
          line.find("img", match: :first)[:src][contract_lines.first.model.id.to_s].should be
        when "Anzahl"
           line.should have_content contract_lines.sum(&:quantity)
        when "Modellname"
          line.should have_content contract_lines.first.model.name
        when "Hersteller"
          line.should have_content contract_lines.first.model.manufacturer
        when "Anzahl der Tage"
          line.should have_content ((contract_lines.first.end_date - contract_lines.first.start_date).to_i+1).to_s
        when "Enddatum"
          line.should have_content I18n.l contract_lines.first.end_date
        when "die versch. Aktionen"
          line.find(".line-actions", match: :first)
        else
          raise "Unbekannt"
      end
    end
  end
end

#############################################################################

def before_max_available(user)
  h = {}
  lines = user.contracts.unsubmitted.flat_map(&:lines)
  lines.each do |order_line|
    h[order_line.id] = order_line.model.availability_in(order_line.inventory_pool).maximum_available_in_period_summed_for_groups(order_line.start_date, order_line.end_date)
  end
  h
end

Wenn(/^ich einen Eintrag lösche$/) do
  line = find(".line", :match => :first)
  line.find(".dropdown-holder").click
  @before_max_available = before_max_available(@current_user)
  line.find("a[data-method='delete']").click
  step "werde ich gefragt ob ich die Bestellung wirklich löschen möchte"
end

Dann(/^wird der Eintrag aus der Bestellung entfernt$/) do
  all(".line").count.should == @current_user.contracts.unsubmitted.flat_map(&:lines).count
end

#############################################################################

Wenn(/^ich die Bestellung lösche$/) do
  @contract_line_ids = @current_user.contracts.unsubmitted.flat_map(&:contract_line_ids)
  @contract_ids = @current_user.contracts.unsubmitted.pluck(:id)

  @before_max_available = before_max_available(@current_user)

  a = find("a[data-method='delete'][href='/borrow/order/remove']", match: :first)
  a.click
end

Dann(/^werde ich gefragt ob ich die Bestellung wirklich löschen möchte$/) do
  alert = page.driver.browser.switch_to.alert
  alert.accept
  sleep(0.33)
end

Dann(/^alle Einträge werden aus der Bestellung gelöscht$/) do
  ContractLine.where(id: @contract_line_ids).count.should == 0
  Contract.where(id: @contract_ids).count.should == 0
end

Dann(/^die Gegenstände sind wieder zur Ausleihe verfügbar$/) do
  @current_user.contracts.unsubmitted.flat_map(&:lines).each do |contract_line|
    after_max_available = contract_line.model.availability_in(contract_line.contract.inventory_pool).maximum_available_in_period_summed_for_groups(contract_line.start_date, contract_line.end_date)
    # NOTE is this still needed ??
    #after_max_available.should == if OrderLine.find_by_id(contract_line.id).nil?
    #                                @before_max_available[contract_line.id] + contract_line.quantity
    #                              else
    #                                @before_max_available[contract_line.id]
    #                              end
    after_max_available.should == @before_max_available[contract_line.id]
  end
end

Dann(/^ich befinde mich wieder auf der Startseite$/) do
  current_path.should == borrow_root_path
end

#############################################################################

Wenn(/^ich einen Zweck eingebe$/) do
  find("form textarea[name='purpose']", match: :first).set Faker::Lorem.sentences(2).join()
end

Wenn(/^ich die Bestellung abschliesse$/) do
  find("form button.green", match: :first).click
end

Dann(/^ändert sich der Status der Bestellung auf Abgeschickt$/) do
  @current_user.contracts.find(@contract_ids).each do |contract|
    contract.status.should == :submitted
  end
end

Dann(/^ich erhalte eine Bestellbestätigung$/) do
  find(".notice", match: :first)
end

Dann(/^in der Bestellbestätigung wird mitgeteilt, dass die Bestellung in Kürze bearbeitet wird$/) do
  find(".notice", match: :first, text: _("Your order has been successfully submitted, but is NOT YET APPROVED."))
end

#############################################################################

Wenn(/^der Zweck nicht abgefüllt wird$/) do
  find("form textarea[name='purpose']", match: :first).set ""
end

Dann(/^hat der Benutzer keine Möglichkeit die Bestellung abzuschicken$/) do
  step "ich die Bestellung abschliesse"
  step "wird die Bestellung nicht abgeschlossen"
  step "ich erhalte eine Fehlermeldung"
end

#############################################################################

Wenn(/^ich den Eintrag ändere$/) do
  if @just_changed_line
    @just_changed_line.click
  else
    # try to get contract_lines where quantity is still increasable
    line_to_edit = all("[data-change-order-lines]").detect do |line|
      contract_lines = ContractLine.find JSON.parse line["data-line-ids"]
      if contract_lines.first.maximum_available_quantity > 0
        @changed_lines = contract_lines
      end
    end

    if line_to_edit
      line_to_edit.click
    else
      @changed_lines = ContractLine.find JSON.parse find("[data-change-order-lines]", match: :first)["data-line-ids"]
      find("[data-change-order-lines]", match: :first).click
    end
  end
end

Dann(/^öffnet der Kalender$/) do
  find("#booking-calendar .fc-widget-content", :match => :first)
end

Dann(/^ich ändere die aktuellen Einstellung$/) do
  @new_date = @changed_lines.first.start_date = Date.today
  @changed_lines.first.start_date = Date.today
  while not @changed_lines.first.available?
    @new_date = @changed_lines.first.end_date = @changed_lines.first.start_date += 1.day
  end
  step "ich setze das Startdatum im Kalendar auf '#{I18n.l(@new_date)}'"
  step "ich setze das Enddatum im Kalendar auf '#{I18n.l(@new_date)}'"
end

Dann(/^speichere die Einstellungen$/) do
  find("#submit-booking-calendar", match: :first).click
end

Dann(/^wird der Eintrag gemäss aktuellen Einstellungen geändert$/) do
  sleep(0.33)
  find(".line", match: :first)
  find("[data-change-order-lines]", match: :first).click
  find("#booking-calendar .fc-widget-content", :match => :first)
  find(".modal-close").click
  if @new_date
    @changed_lines.first.reload.start_date.should == @new_date
  end
  if @new_quantity
    @changed_lines.first.contract.lines.where(model_id: @changed_lines.first.model_id,
                                              start_date: @changed_lines.first.start_date,
                                              end_date: @changed_lines.first.end_date).sum(:quantity).should == @new_quantity
    
    @just_changed_line = find("[data-model-id='#{@changed_lines.first.model_id}'][data-start-date='#{@changed_lines.first.start_date}'][data-end-date='#{@changed_lines.first.end_date}']")
  end
end

Dann(/^der Eintrag wird in der Liste anhand der des aktuellen Startdatums und des Geräteparks gruppiert$/) do
  @current_user.contracts.unsubmitted.each(&:reload)
  step 'sehe ich die Einträge gruppiert nach Startdatum und Gerätepark'
end

Dann(/^sehe ich die Zeitinformationen in folgendem Format "(.*?)"$/) do |format|
  find("#timeout-countdown-time", match: :first, text: Regexp.new(format.gsub("mm", "\\d+").gsub("ss", "\\d+")))
end
