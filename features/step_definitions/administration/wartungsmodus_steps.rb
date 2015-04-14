# -*- encoding : utf-8 -*-

#Angenommen(/^ich befinde mich in den Pool\-übergreifenden Einstellungen$/) do
Given(/^I am in the system-wide settings$/) do
  visit manage_edit_settings_path unless current_path == manage_edit_settings_path
end

#Wenn(/^ich die Funktion "(.*)" wähle$/) do |arg1|
When(/^I choose the function "(.*)"$/) do |arg1|
  @disable = true

  case arg1
    when "Disable manage section"
      input_field = find(".row.emboss", text: :disable_manage_section, match: :first).find("input[name='setting[#{:disable_manage_section}]']", match: :first)
    when "Disable borrow section"
      input_field = find(".row.emboss", text: :disable_borrow_section, match: :first).find("input[name='setting[#{:disable_borrow_section}]']", match: :first)
    else
      raise
  end

  input_field.click
end

#Dann(/^muss ich eine Bemerkung angeben$/) do
Then(/^I have to enter a note$/) do
  step 'I save'
  step 'I see an error message'
end

#Dann(/^der Bereich "(.*)" ist für die Benutzer gesperrt$/) do |arg1|
Then(/^the "(.*)" is disabled for users$/) do |arg1|
  step "I log out"
  case arg1
    when "manage section"
      step %Q(I am Mike)
      expect(current_path).to eq manage_maintenance_path
      @section = _("Manage section")
    when "borrow section"
      step %Q(I am Normin)
      expect(current_path).to eq borrow_maintenance_path
      @section = _("Borrow section")
    else
      raise
  end
end

#Dann(/^dem Benutzer wird die eingegebene Bemerkung angezeigt$/) do
Then(/^users see the note that was defined$/) do
  expect(has_selector?("h1", text: _("%s not available") % @section)).to be true
  expect(has_content?(@disable_message)).to be true
end

#Wenn(/^ich eine Bemerkung für "(.*)" angebe$/) do |arg1|
When(/^I enter a note for the "(.*)"$/) do |arg1|
  @disable_message = Faker::Lorem.sentence
  case arg1
    when "manage section"
      find(".row.emboss", text: :disable_manage_section_message, match: :first).find("textarea[name='setting[#{:disable_manage_section_message}]']", match: :first).set @disable_message
    when "borrow section"
      find(".row.emboss", text: :disable_borrow_section_message, match: :first).find("textarea[name='setting[#{:disable_borrow_section_message}]']", match: :first).set @disable_message
    else
      raise
  end
end

#Dann(/^wurde die Einstellung für "(.*)" erfolgreich gespeichert$/) do |arg1|
Then(/^the settings for the "(.*)" were saved$/) do |arg1|
  case arg1
    when "manage section"
      expect(Setting.const_get(:disable_manage_section.upcase)).to eq @disable
      expect(Setting.const_get(:disable_manage_section_message.upcase).to_s).to eq @disable_message
    when "borrow section"
      expect(Setting.const_get(:disable_borrow_section.upcase)).to eq @disable
      expect(Setting.const_get(:disable_borrow_section_message.upcase).to_s).to eq @disable_message
    else
      raise
  end
end

#Wenn(/^der "(.*)" Bereich ist gesperrt$/) do |arg1|
When(/^the "(.*)" is disabled$/) do |arg1|
  @setting = Setting.first
  @disable_message = Faker::Lorem.sentence

  case arg1
    when "manage section"
      @setting.update_attributes disable_manage_section: true, disable_manage_section_message: @disable_message
    when "borrow section"
      @setting.update_attributes disable_borrow_section: true, disable_borrow_section_message: @disable_message
    else
      raise
  end
end

#Wenn(/^ich die Funktion "(.*)" deselektiere$/) do |arg1|
When(/^I deselect the "(.*)" option$/) do |arg1|
  @disable = false

  case arg1
    when "disable manage section"
      input_field = find(".row.emboss", text: :disable_manage_section, match: :first).find("input[name='setting[#{:disable_manage_section}]']", match: :first)
    when "disable borrow section"
      input_field = find(".row.emboss", text: :disable_borrow_section, match: :first).find("input[name='setting[#{:disable_borrow_section}]']", match: :first)
    else
      raise
  end

  input_field.click
end

#Dann(/^ist der Bereich "(.*)" für den Benutzer nicht mehr gesperrt$/) do |arg1|
Then(/^the "(.*)" is not disabled for users$/) do |arg1|
  step 'I log out'
  case arg1
  when 'manage section'
    step %Q(I am Mike)
    expect(current_path).to eq manage_inventory_path(@current_inventory_pool)
  when "borrow section"
    step %Q(I am Normin)
    expect(current_path).to eq borrow_root_path
  else
    raise
  end
end

#Dann(/^die eingegebene Meldung für "(.*)" Bereich ist immer noch gespeichert$/) do |arg1|
Then(/^the note entered for the "(.*)" is still saved$/) do |arg1|
  case arg1
    when "manage section"
      expect(@setting.reload.disable_manage_section_message).to eq @disable_message
    when "borrow section"
      expect(@setting.reload.disable_borrow_section_message).to eq @disable_message
    else
      raise
  end
end

