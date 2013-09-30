# -*- encoding : utf-8 -*-

Wenn(/^man auf einem Model "Zur Bestellung hinzufügen" wählt$/) do
  line = first("#model-list .line")
  @model = Model.find line["data-id"]
  line.find("button[data-create-order-line]").click
end

Dann(/^öffnet sich der Kalender$/) do
  first("#booking-calendar .fc-day-content")
end

Wenn(/^ich den Kalender schliesse$/) do
  find(".modal-close").click
end

Dann(/^schliesst das Dialogfenster$/) do
  step "ensure there are no active requests"
  page.should_not have_selector("#booking-calendar")
end

Wenn(/^man versucht ein Modell zur Bestellung hinzufügen, welches nicht verfügbar ist$/) do
  @start_date = Date.today
  @end_date = Date.today + 14
  @inventory_pool = @current_user.inventory_pools.first
  @quantity = 3
  @model = @current_user.models.borrowable.detect do |m| 
    m.availability_in(@inventory_pool).maximum_available_in_period_summed_for_groups(@start_date, @end_date, @current_user.group_ids) < @quantity and 
    m.total_borrowable_items_for_user(@current_user, @inventory_pool) >= @quantity
  end
  visit borrow_model_path(@model)
  find("*[data-create-order-line][data-model-id='#{@model.id}']").click
  step "ich setze die Anzahl im Kalendar auf #{@quantity}"
  sleep 1
  find("#submit-booking-calendar").click
end

Wenn(/^ich setze die Anzahl im Kalendar auf (\d+)$/) do |quantity|
  find("#booking-calendar-quantity")
  find(".modal.ui-shown")
  sleep 1
  find("#booking-calendar-quantity").set quantity
end

Wenn(/^ich setze das Startdatum im Kalendar auf '(.*?)'$/) do |date|
  page.should have_selector("#booking-calendar-start-date")
  page.execute_script %Q{ $("#booking-calendar-start-date").focus().select().val("#{date}").change() }
end

Wenn(/^ich setze das Enddatum im Kalendar auf '(.*?)'$/) do |date|
  page.should have_selector("#booking-calendar-end-date")
  page.execute_script %Q{ $("#booking-calendar-end-date").focus().select().val("#{date}").change() }
end

Dann(/^schlägt der Versuch es hinzufügen fehl$/) do
  find("#booking-calendar")
  @current_user.get_current_order.lines.length.should == 0
end

Dann(/^ich sehe die Fehlermeldung, dass das ausgewählte Modell im ausgewählten Zeitraum nicht verfügbar ist$/) do
  find("#booking-calendar-errors").should have_content "Der Gegenstand ist im ausgewählten Zeitraum nicht ausreichend verfügbar"
end

Wenn(/^man einen Gegenstand aus der Modellliste hinzufügt$/) do
  visit borrow_models_path(category_id: Category.find {|c| !c.models.active.blank?})
  @model_name = first(".line .line-col.col3of6").text
  @model = Model.find_by_name(@model_name)
  first(".line .button").click
end

Dann(/^der Kalender beinhaltet die folgenden Komponenten$/) do |table|
  find ".headline-m", text: @model_name
  find ".fc-header-title", text: I18n.l(Date.today, format: :month_year)
  find "#booking-calendar"
  find "#booking-calendar-inventory-pool"
  find "#booking-calendar-start-date"
  find "#booking-calendar-end-date"
  find "#booking-calendar-quantity"
  find "#submit-booking-calendar"
  find ".modal-close", text: _("Cancel")
end

Wenn(/^alle Angaben die ich im Kalender mache gültig sind$/) do
  @quantity = 1
  page.should have_selector("#booking-calendar-inventory-pool option")
  @inventory_pool = InventoryPool.find all("#booking-calendar-inventory-pool option").detect{|o| o.selected?}["data-id"]
  step "ich setze die Anzahl im Kalendar auf #{@quantity}"
  @start_date = @end_date = @inventory_pool.next_open_date
  step "ich setze das Startdatum im Kalendar auf '#{I18n::l(@start_date)}'"
  step "ich setze das Enddatum im Kalendar auf '#{I18n::l(@end_date)}'"
  find("#submit-booking-calendar").click
  page.has_no_selector? "#booking-calendar"
end

Dann(/^ist das Modell mit Start- und Enddatum, Anzahl und Gerätepark der Bestellung hinzugefügt worden$/) do
  page.has_selector? "#current-order-lines .line"
  find("#current-order-lines .line", :text => "#{@quantity}x #{@model.name}")
  @current_user.get_current_order.lines.detect{|line| line.model == @model}.should be
end

Dann(/^lässt sich das Modell mit Start\- und Enddatum, Anzahl und Gerätepark der Bestellung hinzugefügen$/) do
  step 'ist das Modell mit Start- und Enddatum, Anzahl und Gerätepark der Bestellung hinzugefügt worden'
end

Dann(/^das aktuelle Startdatum ist heute$/) do
  find("#booking-calendar-start-date").value.should == I18n.l(Date.today)
end

Dann(/^das Enddatum ist morgen$/) do
  find("#booking-calendar-end-date").value.should == I18n.l(Date.tomorrow)
end

Dann(/^die Anzahl ist 1$/) do
  find("#booking-calendar-quantity").value.should == 1.to_s
end

Dann(/^es sind alle Geräteparks angezeigt die Gegenstände von dem Modell haben$/) do
  ips = @current_user.inventory_pools.select do |ip|
    @model.total_borrowable_items_for_user(@current_user, ip)
  end

  ips_in_dropdown = all("#order-inventory_pool option").map(&:text)

  ips.each do |ip|
    ips_in_dropdown.include?(ip.name + " (#{@model.total_borrowable_items_for_user(@current_user, ip)})")
  end
end

Angenommen(/^man hat eine Zeitspanne ausgewählt$/) do
  find("#start-date").click
  find("#start-date").set I18n.l(Date.today + 1)
  find("#end-date").click
  find("#end-date").set I18n.l(Date.today + 2)
end

Wenn(/^man einen in der Zeitspanne verfügbaren Gegenstand aus der Modellliste hinzufügt$/) do
  step "ensure there are no active requests"
  @model_name = find(".line:not(.grayed-out) .line-col.col3of6", match: :first).text
  @model = Model.find_by_name(@model_name)
  find(".line .button", match: :first).click
end

Dann(/^das Startdatum entspricht dem vorausgewählten Startdatum$/) do
  find("#booking-calendar-start-date").value.should == I18n.l(Date.today + 1)
end

Dann(/^das Enddatum entspricht dem vorausgewählten Enddatum$/) do
  find("#booking-calendar-end-date").value.should == I18n.l(Date.today + 2)
end

Angenommen(/^es existiert ein Modell für das eine Bestellung vorhanden ist$/) do
  @order_line = OrderLine.find do |ol|
    ol.start_date.future? and
    @current_user.inventory_pools.include?(ol.inventory_pool)
  end

  @model = @order_line.model
end

Wenn(/^man dieses Modell aus der Modellliste hinzufügt$/) do
  visit borrow_models_path(category_id: @model.categories.first)
  find(".line", text: @model.name).find(".button").click
end

Dann(/^wird die Verfügbarkeit des Modells im Kalendar angezeigt$/) do
  @ip = InventoryPool.find_by_name find("#booking-calendar-inventory-pool option").value.split(" ").first
  av = @model.availability_in(@ip)
  changes = av.available_total_quantities

  changes.each_with_index do |change, i|
    current_calendar_date = Date.parse page.evaluate_script %Q{ $("#booking-calendar").fullCalendar("getDate").toDateString() }
    current_change_date = change[0]
    while current_calendar_date.month != current_change_date.month do
      find(".fc-button-next").click
      current_calendar_date = Date.parse page.evaluate_script %Q{ $("#booking-calendar").fullCalendar("getDate").toDateString() }
    end

    # iterate days between this change and the next one
    next_change = changes[i+1]
    if next_change
      days_between_changes = (next_change[0]-change[0]).to_i
      next_date = change[0]
      last_month = next_date.month
      days_between_changes.times do
        if next_date.month != last_month
          find(".fc-button-next").click
        end
        change_date_el = find(".fc-widget-content:not(.fc-other-month) .fc-day-number", match: :prefer_exact, :text => /#{next_date.day}/).first(:xpath, "../..")
        next unless @ip.is_open_on? change_date_el[:"data-date"].to_date
        # check borrower availability
        quantity_for_borrower = av.maximum_available_in_period_summed_for_groups next_date, next_date, @current_user.group_ids
        change_date_el.find(".fc-day-content div").text.to_i.should == quantity_for_borrower
        last_month = next_date.month
        next_date += 1.day
      end
    end
  end
end

Angenommen(/^man hat den Buchungskalender geöffnet$/) do
  step 'man sich auf der Modellliste befindet'
  step 'man auf einem Model "Zur Bestellung hinzufügen" wählt'
  step 'öffnet sich der Kalender'
end

Wenn(/^man anhand der Sprungtaste zum aktuellen Startdatum springt$/) do
  find(".fc-button-next").click
  find("#jump-to-start-date").click
end

Dann(/^wird das Startdatum im Kalender angezeigt$/) do
  find(".fc-widget-content.start-date")
end

Wenn(/^man anhand der Sprungtaste zum aktuellen Enddatum springt$/) do
  find(".fc-button-next").click
  find("#jump-to-end-date").click
end

Dann(/^wird das Enddatum im Kalender angezeigt$/) do
  find(".fc-widget-content.end-date")
end

Wenn(/^man zwischen den Monaten hin und herspring$/) do
  find(".fc-button-next").click
end

Dann(/^wird der Kalender gemäss aktuell gewähltem Monat angezeigt$/) do
  find(".fc-header-title").text.should == I18n.l(Date.today.next_month, format: :month_year)
end

Dann(/^werden die Schliesstage gemäss gewähltem Gerätepark angezeigt$/) do
  page.should have_selector("#booking-calendar-inventory-pool option")
  @inventory_pool = InventoryPool.find all("#booking-calendar-inventory-pool option").detect{|o| o.selected?}["data-id"]
  @holiday = @inventory_pool.holidays.first
  holiday_not_found = all(".fc-day-content", :text => @holiday.name).empty?
  while holiday_not_found do
    find(".fc-button-next").click
    holiday_not_found = all(".fc-day-content", :text => @holiday.name).empty?
  end
end

Wenn(/^man ein Start und Enddatum ändert$/) do
  @start = Date.today + 1.day
  @end = @start + 1.day
  step "ich setze das Startdatum im Kalendar auf '#{I18n.l(@start)}'"
  step "ich setze das Enddatum im Kalendar auf '#{I18n.l(@end)}'"
end

Dann(/^wird die Verfügbarkeit des Gegenstandes aktualisiert$/) do
  @ip = InventoryPool.find_by_name find("#booking-calendar-inventory-pool option").value.split(" ").first

  (@start..@end).each do |date|
    date_el = get_fullcalendar_day_element date
    date_el.native.attribute("class").should include "available"
    date_el.native.attribute("class").should include "selected"
  end
end

Wenn(/^man die Anzahl ändert$/) do
  step 'ich setze die Anzahl im Kalendar auf 2'  
end

Dann(/^sind nur diejenigen Geräteparks auswählbar, welche über Kapizäteten für das ausgewählte Modell verfügen$/) do
  @inventory_pools = @model.inventory_pools.reject {|ip| @model.total_borrowable_items_for_user(@current_user, ip) <= 0 }
  all("#booking-calendar-inventory-pool option").each do |option|
    expect(@inventory_pools.include?(InventoryPool.find(option["data-id"]))).to be_true
  end
end

Dann(/^die Geräteparks sind alphabetisch sortiert$/) do
  page.should have_selector("#booking-calendar-inventory-pool option")
  all("#booking-calendar-inventory-pool option").map(&:text).should == all("#booking-calendar-inventory-pool option").map(&:text).sort
end

Dann(/^wird die maximal ausleihbare Anzahl des ausgewählten Modells angezeigt$/) do
  all("#booking-calendar-inventory-pool option").each do |option|
    inventory_pool = InventoryPool.find(option["data-id"])
    option.text[/#{@model.total_borrowable_items_for_user(@current_user, inventory_pool)}/].should be
  end
end

Dann(/^man kann maximal die maximal ausleihbare Anzahl eingeben$/) do
  page.should have_selector("#booking-calendar-inventory-pool option")
  inventory_pool = InventoryPool.find(all("#booking-calendar-inventory-pool option").detect{|o| o.selected?}["data-id"])
  max_quantity = @model.total_borrowable_items_for_user(@current_user, inventory_pool)
  find("#booking-calendar-quantity").set (max_quantity+1).to_s
  find("#booking-calendar-quantity").value.should == (max_quantity).to_s
end

Dann(/^man auf dem letzten Model "Zur Bestellung hinzufügen" wählt$/) do
  all("body > .wrapper").last.click
  step "ensure there are no active requests"
  wait_until {all("#model-list .line").last["data-id"].length > 0}
  @model = Model.find all("#model-list .line").last["data-id"]
  find("#model-list .line:last button[data-create-order-line]").click
end

Wenn(/^man den letzten Gerätepark in der Geräteparkauswahl auswählt$/) do
  @ip = @current_user.inventory_pools.sort.last
  step 'man ein bestimmten Gerätepark in der Geräteparkauswahl auswählt'
end

Wenn(/^man den zweiten Gerätepark in der Geräteparkauswahl auswählt$/) do
  @ip = @current_user.inventory_pools.sort[1]
  step 'man ein bestimmten Gerätepark in der Geräteparkauswahl auswählt'
end

Angenommen(/^man die Geräteparks begrenzt$/) do
  inventory_pool_ids = all("#ip-selector .dropdown-item[data-id]", :visible => false).map{|i| i[:"data-id"]}
  find("#ip-selector").click
  find(:xpath, "(//*[@id='ip-selector']//input)[1]", :visible => true).click
  inventory_pool_ids.shift
  @inventory_pools = inventory_pool_ids.map{|id| InventoryPool.find id}
end

Angenommen(/^man ein Modell welches über alle Geräteparks der begrenzten Liste beziehbar ist zur Bestellung hinzufügt$/) do
  page.should have_selector(".line[data-id]", :visible => true)
  all(".line[data-id]").each do |line|
    model = Model.find line["data-id"]
    if @inventory_pools.all?{|ip| ip.models.include?(model)}
      @model = model
    end
  end
  find(:xpath, "(//*[@id='ip-selector']//input)[2]", :visible => true).click
  page.should have_selector(".line[data-id]", :visible => true)
  @inventory_pools.shift
  find(".line[data-id='#{@model.id}'] *[data-create-order-line]").click
end

Dann(/^es wird der alphabetisch erste Gerätepark ausgewählt der teil der begrenzten Geräteparks ist$/) do
  find("#booking-calendar-inventory-pool").value.split(" ")[0].should == @inventory_pools.first.name
end
