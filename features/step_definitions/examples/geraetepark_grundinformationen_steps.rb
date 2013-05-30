# encoding: utf-8

Angenommen(/^ich bin (.*)$/) do |persona|
  step "I am \"#{persona}\""
end

Wenn(/^ich den Admin\-Bereich betrete$/) do
  click_link _("Admin")
  click_link _("Inventory Pool")
end

Dann(/^kann ich die Gerätepark\-Grundinformationen eingeben$/) do |table|
  # table is a Cucumber::Ast::Table
  @table_raw = table.raw
  wait_until {not all(".inner .field").empty?}
  @table_raw.flatten.each do |field_name|
    if field_name == "Verträge drucken"
      find(".inner .field", text: field_name).find("input").set false
    else
      find(".inner .field", text: field_name).find("input,textarea").set (field_name == "E-Mail" ? "test@test.ch" : "test")
    end
  end
end

Dann(/^ich kann die angegebenen Grundinformationen speichern$/) do
  @path_before_save = current_path
  click_button _("Save %s") % _("Inventory Pool")
end

Dann(/^sind die Informationen aktualisiert$/) do
  wait_until {not all(".inner .field").empty?}
  @table_raw.flatten.each do |field_name|
    if field_name == "Verträge drucken"
      find(".inner .field", text: field_name).find("input").selected?.should be_false
    else
      find(".inner .field", text: field_name).find("input,textarea").value.should == (field_name == "E-Mail" ? "test@test.ch" : "test")
    end
  end
end

Dann(/^ich bleibe auf derselben Ansicht$/) do
  current_path == @path_before_save
end

Dann(/^sehe eine Bestätigung$/) do
  page.should have_selector ".success"
end

Wenn(/^ich die Grundinformationen des Geräteparks abfüllen möchte$/) do
  visit edit_backend_inventory_pool_path(@current_inventory_pool)
end

Dann(/^kann das Gerätepark nicht gespeichert werden$/) do
  click_button _("Save %s") % _("Inventory Pool")
  wait_until {page.should have_selector ".error"}
end

Angenommen(/^ich die folgenden Felder nicht befüllt habe$/) do |table|
  table.raw.flatten.each do |must_field_name|
    find(".field", text: must_field_name).find("input,textarea").set ""
  end
end

Angenommen(/^ich verwalte die Gerätepark Grundinformationen$/) do
  visit edit_backend_inventory_pool_path(@current_inventory_pool)
end

Wenn(/^ich die Arbeitstage Montag, Dienstag, Mittwoch, Donnerstag, Freitag, Samstag, Sonntag ändere$/) do
  @workdays = {}
  [0,1,2,3,4,5,6].each do |day|
    select = find(".field", text: I18n.t('date.day_names')[day]).find("select")
    @workdays[day] = rand > 0.5 ? _("Open") : _("Closed")
    select.find("option[label='#{@workdays[day]}']").click
  end
end

Wenn(/^ich die Änderungen speichere$/) do
  click_button _("Save %s") % _("Inventory Pool")
end

Dann(/^sind die Arbeitstage gespeichert$/) do
  @workdays.each_pair do |day, status|
    if status == "closed"
      expect(@current_inventory_pool.workday.closed_days.include?(day)).to be_true
    elsif status == "open"
      expect(@current_inventory_pool.workday.closed_days.include?(day)).to be_false
    end
  end
end

Wenn(/^ich eine oder mehrere Zeitspannen und einen Namen für die Ausleihsschliessung angebe$/) do
  @holidays = []
  [1,5,8].each do |i|
    holiday = {start_date: (Date.today + i), end_date: (Date.today + i*i), name: "Test #{i}"}
    @holidays.push holiday
    fill_in "start_date", :with => I18n.l(holiday[:start_date])
    fill_in "end_date", :with => I18n.l(holiday[:end_date])
    fill_in "name", :with => holiday[:name]
    find(".add-holiday").click
  end
end

Wenn(/^ich speichere den Gerätepark$/) do
  find(".button", :text => /#{_("Save")}/i).click
end

Dann(/^werden die Ausleihschliessungszeiten gespeichert$/) do
  @holidays.each do |holiday|
    @current_inventory_pool.holidays.where(:start_date => holiday[:start_date], :end_date => holiday[:end_date], :name => holiday[:name]).should_not be_empty
  end
end

Dann(/^ich kann die Ausleihschliessungszeiten wieder löschen$/) do
  holiday = @holidays.last
  find(".field-inline-entry", :text => holiday[:name]).find(".delete-holiday").click
  step 'ich speichere den Gerätepark'
  @current_inventory_pool.holidays.where(:start_date => holiday[:start_date], :end_date => holiday[:end_date], :name => holiday[:name]).should be_empty
end
