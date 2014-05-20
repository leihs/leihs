# -*- encoding : utf-8 -*-

Angenommen(/^ich befinde mich in den Pool\-übergreifenden Einstellungen$/) do
  visit manage_edit_settings_path unless current_path == manage_edit_settings_path
end

Wenn(/^ich die Funktion "Verwaltung sperren" wähle$/) do
  @disable = true
  input_field = find(".row.emboss", text: :disable_manage_section, match: :first).find("input[name='setting[#{:disable_manage_section}]']", match: :first)
  input_field.click
end

Wenn(/^ich die Funktion "Ausleihen sperren" wähle$/) do
  @disable = true
  input_field = find(".row.emboss", text: :disable_borrow_section, match: :first).find("input[name='setting[#{:disable_borrow_section}]']", match: :first)
  input_field.click
end

Dann(/^muss ich eine Bemerkung angeben$/) do
  step 'ich speichere'
  step 'ich sehe eine Fehlermeldung'
end

Dann(/^der Bereich "Verwalten" ist für die Benutzer gesperrt$/) do
  visit logout_path
  step %Q(ich bin Mike)
  current_path.should == manage_maintenance_path
end

Dann(/^der Bereich "Ausleihen" ist für die Benutzer gesperrt$/) do
  visit logout_path
  step %Q(ich bin Normin)
  current_path.should == borrow_maintenance_path
end

Dann(/^dem Benutzer wird die eingegebene Bemerkung angezeigt$/) do
  page.should have_selector "h1", text: _("Maintenance")
  page.should have_content @disable_message
end

Wenn(/^ich eine Bemerkung für "Verwalten-Bereich" angebe$/) do
  @disable_message = Faker::Lorem.sentence
  find(".row.emboss", text: :disable_manage_section_message, match: :first).find("textarea[name='setting[#{:disable_manage_section_message}]']", match: :first).set @disable_message
end

Wenn(/^ich eine Bemerkung für "Ausleihen-Bereich" angebe$/) do
  @disable_message = Faker::Lorem.sentence
  find(".row.emboss", text: :disable_borrow_section_message, match: :first).find("textarea[name='setting[#{:disable_borrow_section_message}]']", match: :first).set @disable_message
end

Dann(/^wurde die Einstellung für "Verwalten-Bereich" erfolgreich gespeichert$/) do
  Setting.const_get(:disable_manage_section.upcase).should == @disable
  Setting.const_get(:disable_manage_section_message.upcase).to_s.should == @disable_message
end

Dann(/^wurde die Einstellung für "Ausleihen-Bereich" erfolgreich gespeichert$/) do
  Setting.const_get(:disable_borrow_section.upcase).should == @disable
  Setting.const_get(:disable_borrow_section_message.upcase).to_s.should == @disable_message
end

Wenn(/^der "Verwalten" Bereich ist gesperrt$/) do
  @setting = Setting.first
  @disable_message = Faker::Lorem.sentence
  @setting.update_attributes disable_manage_section: true, disable_manage_section_message: @disable_message
end

Wenn(/^der "Ausleihen" Bereich ist gesperrt$/) do
  @setting = Setting.first
  @disable_message = Faker::Lorem.sentence
  @setting.update_attributes disable_borrow_section: true, disable_borrow_section_message: @disable_message
end

Wenn(/^ich die Funktion "Verwaltung sperren" deselektiere$/) do
  @disable = false
  input_field = find(".row.emboss", text: :disable_manage_section, match: :first).find("input[name='setting[#{:disable_manage_section}]']", match: :first)
  input_field.click
end

Wenn(/^ich die Funktion "Ausleihen sperren" deselektiere$/) do
  @disable = false
  input_field = find(".row.emboss", text: :disable_borrow_section, match: :first).find("input[name='setting[#{:disable_borrow_section}]']", match: :first)
  input_field.click
end

Dann(/^ist der Bereich "Verwalten" für den Benutzer nicht mehr gesperrt$/) do
  visit logout_path
  step %Q(ich bin Mike)
  current_path.should == manage_inventory_path(@current_inventory_pool)
end

Dann(/^ist der Bereich "Ausleihen" für den Benutzer nicht mehr gesperrt$/) do
  visit logout_path
  step %Q(ich bin Normin)
  current_path.should == borrow_root_path
end

Dann(/^die eingegebene Meldung für "Verwalten" Bereich ist immer noch gespeichert$/) do
  @setting.reload.disable_manage_section_message.should == @disable_message
  sleep(0.33) # fix no default authentication system problem on CI
end

Dann(/^die eingegebene Meldung für "Ausleihen" Bereich ist immer noch gespeichert$/) do
  @setting.reload.disable_borrow_section_message.should == @disable_message
end
