# -*- encoding : utf-8 -*-

Angenommen /^man öffnet die Liste des Inventars$/ do
  ip = @user.managed_inventory_pools.first
  visit backend_inventory_pool_models_path(ip)
end

Dann /^sieht man Modelle$/ do
  all(".model.line").empty?.should be_false
end

Dann /^man sieht Optionen$/ do
  all(".option.line").empty?.should be_false
end

Dann /^man sieht Pakete$/ do
  binding.pry
  all(".model.package.line").empty?.should be_false
end

########################################################################

Dann /^hat man folgende Auswahlmöglichkeiten:$/ do |table|
  section_tabs = find("section .inlinetabs")
  table.hashes.each do |row|
    case row["auswahlmöglichkeit"]
      when "Alles"
        section_tabs.find("a")[:href].match(/\?/).should be_nil
      when "Ausgemustert"
        section_tabs.find(:xpath, "a[contains(@href,'borrowable=true')]")
      when "Ausleihbar"
        section_tabs.find(:xpath, "a[contains(@href,'borrowable=false')]")
      when "Nicht ausleihbar"
        section_tabs.find(:xpath, "a[contains(@href,'retired=true')]")
    end
  end
end

Dann /^die Auswahlmöglichkeiten können nicht kombiniert werden$/ do
  # how to test this?
end

########################################################################

Dann /^hat man folgende Filtermöglichkeiten$/ do |table|
  section_tabs = find("section .inlinetabs")
  table.hashes.each do |row|
    section_tabs.find("span", :text => row["filtermöglichkeit"])
  end
end

Dann /^die Filter können kombiniert werden$/ do
  pending # express the regexp above with the code you wish you had
end

########################################################################

Dann /^ist erstmal die Auswahl "(.*?)" aktiviert$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Dann /^es sind keine Filtermöglichkeiten aktiviert$/ do
  pending # express the regexp above with the code you wish you had
end