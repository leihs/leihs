# -*- encoding : utf-8 -*-

Angenommen(/^ich befinde mich in den Pool\-übergreifenden Einstellungen$/) do
  visit manage_edit_settings_path unless current_path == manage_edit_settings_path
end

Wenn(/^ich die Funktion "(.*)" wähle$/) do |arg1|
  @disable = true

  case arg1
    when "Verwaltung sperren"
      input_field = find(".row.emboss", text: :disable_manage_section, match: :first).find("input[name='setting[#{:disable_manage_section}]']", match: :first)
    when "Ausleihen sperren"
      input_field = find(".row.emboss", text: :disable_borrow_section, match: :first).find("input[name='setting[#{:disable_borrow_section}]']", match: :first)
    else
      raise "not found"
  end

  input_field.click
end

Dann(/^muss ich eine Bemerkung angeben$/) do
  step 'ich speichere'
  step 'ich sehe eine Fehlermeldung'
end

Dann(/^der Bereich "(.*)" ist für die Benutzer gesperrt$/) do |arg1|
  visit logout_path
  case arg1
    when "Verwalten"
      step %Q(ich bin Mike)
      current_path.should == manage_maintenance_path
      @section = _("Manage section")
    when "Ausleihen"
      step %Q(ich bin Normin)
      current_path.should == borrow_maintenance_path
      @section = _("Borrow section")
    else
      raise "not found"
  end
end

Dann(/^dem Benutzer wird die eingegebene Bemerkung angezeigt$/) do
  page.should have_selector "h1", text: _("%s not available") % @section
  page.should have_content @disable_message
end

Wenn(/^ich eine Bemerkung für "(.*)" angebe$/) do |arg1|
  @disable_message = Faker::Lorem.sentence
  case arg1
    when "Verwalten-Bereich"
      find(".row.emboss", text: :disable_manage_section_message, match: :first).find("textarea[name='setting[#{:disable_manage_section_message}]']", match: :first).set @disable_message
    when "Ausleihen-Bereich"
      find(".row.emboss", text: :disable_borrow_section_message, match: :first).find("textarea[name='setting[#{:disable_borrow_section_message}]']", match: :first).set @disable_message
    else
      raise "not found"
  end
end

Dann(/^wurde die Einstellung für "(.*)" erfolgreich gespeichert$/) do |arg1|
  case arg1
    when "Verwalten-Bereich"
      Setting.const_get(:disable_manage_section.upcase).should == @disable
      Setting.const_get(:disable_manage_section_message.upcase).to_s.should == @disable_message
    when "Ausleihen-Bereich"
      Setting.const_get(:disable_borrow_section.upcase).should == @disable
      Setting.const_get(:disable_borrow_section_message.upcase).to_s.should == @disable_message
    else
      raise "not found"
  end
end

Wenn(/^der "(.*)" Bereich ist gesperrt$/) do |arg1|
  @setting = Setting.first
  @disable_message = Faker::Lorem.sentence

  case arg1
    when "Verwalten"
      @setting.update_attributes disable_manage_section: true, disable_manage_section_message: @disable_message
    when "Ausleihen"
      @setting.update_attributes disable_borrow_section: true, disable_borrow_section_message: @disable_message
    else
      raise "not found"
  end
end

Wenn(/^ich die Funktion "(.*)" deselektiere$/) do |arg1|
  @disable = false

  case arg1
    when "Verwaltung sperren"
      input_field = find(".row.emboss", text: :disable_manage_section, match: :first).find("input[name='setting[#{:disable_manage_section}]']", match: :first)
    when "Ausleihen sperren"
      input_field = find(".row.emboss", text: :disable_borrow_section, match: :first).find("input[name='setting[#{:disable_borrow_section}]']", match: :first)
    else
      raise "not found"
  end

  input_field.click
end

Dann(/^ist der Bereich "(.*)" für den Benutzer nicht mehr gesperrt$/) do |arg1|
  visit logout_path
  case arg1
    when "Verwalten"
      step %Q(ich bin Mike)
      current_path.should == manage_inventory_path(@current_inventory_pool)
    when "Ausleihen"
      step %Q(ich bin Normin)
      current_path.should == borrow_root_path
    else
      raise "not found"
  end
end

Dann(/^die eingegebene Meldung für "(.*)" Bereich ist immer noch gespeichert$/) do |arg1|
  case arg1
    when "Verwalten"
      @setting.reload.disable_manage_section_message.should == @disable_message
      sleep(0.33) # fix no default authentication system problem on CI
    when "Ausleihen"
      @setting.reload.disable_borrow_section_message.should == @disable_message
    else
      raise "not found"
  end
end

