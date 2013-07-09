# -*- encoding : utf-8 -*-

Angenommen(/^ich habe Gegenstände der Bestellung hinzugefügt$/) do
  order = @current_user.get_current_order
  order.purpose = FactoryGirl.create :purpose
  rand(3..10).times do
    order.order_lines << FactoryGirl.create(:order_line,
                                            :order => order,
                                            :inventory_pool => @current_user.inventory_pools.sample)
  end
end

Wenn(/^ich die Bestellübersicht öffne$/) do
  visit borrow_unsubmitted_order_path
  find("h1", text: _("Order Overview"))
  @order = @current_user.get_current_order
  all(".line").count.should == @order.lines.count
end

#############################################################################

Dann(/^sehe ich die Einträge gruppiert nach Startdatum und Gerätepark$/) do
  all(".emboss.deep").count.should == @order.lines.group_by{|l| [l.start_date, l.inventory_pool] }.keys.count
end

Dann(/^die Modelle sind alphabetisch sortiert$/) do
  all(".emboss.deep").each do |x|
    names = x.all(".line .name").map{|name| name.text}
    expect(names.sort == names).to be_true
  end
end

Dann(/^für jeden Eintrag sehe ich die folgenden Informationen$/) do |table|
  line = find(".line")
  table.raw.map{|e| e.first}.each do |row|
    case row
      when "Bild"
        line.find(".image img") #.find("img[src*='#{model.id}']")
      when "Anzahl"
        line.find(".amount")
      when "Modellname"
        line.find(".name")
      when "Hersteller"
        line.find(".manufacturer")
      when "Anzahl der Tage"
        line.find(".end_date")
      when "Enddatum"
        line.find(".end_date")
      when "die versch. Aktionen"
        line.find(".line-actions")
      else
        raise "Unbekannt"
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
  a = line.find(".line-actions a[data-method='delete']")

  @before_max_available = before_max_available(@order)

  a.click
  step "werde ich gefragt ob ich die Bestellung wirklich löschen möchte"
end

Dann(/^wird der Eintrag aus der Bestellung entfernt$/) do
  all(".line").count.should == @order.lines.count
end

#############################################################################

Wenn(/^ich die Bestellung lösche$/) do
  @order_line_ids = @order.order_line_ids

  @before_max_available = before_max_available(@order)

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
  Order.where(id: @order.id).count.should == 0
end

Dann(/^die Gegenstände sind wieder zur Ausleihe verfügbar$/) do
  @order.order_lines.each do |order_line|
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
  current_path.should == borrow_start_path
end

#############################################################################

Wenn(/^ich einen Zweck eingebe$/) do
  find("form textarea[name='purpose']").set Faker::Lorem.sentences 2
end

Wenn(/^ich die Bestellung abschliesse$/) do
  find("form button.green").click
end

Dann(/^ändert sich der Status der Bestellung auf Abgeschickt$/) do
  @order.reload.status_const.should == Order::SUBMITTED
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
  current_path.should == borrow_unsubmitted_order_path
  find(".error", text: _("Please provide a purpose..."))
  @order.reload.status_const.should == Order::UNSUBMITTED
end
