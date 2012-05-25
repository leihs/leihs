# -*- encoding : utf-8 -*-

Wenn /^man eine Liste von Inventar sieht$/ do
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
  pending # express the regexp above with the code you wish you had
end

########################################################################

Dann /^hat man folgende Auswahlmöglichkeiten:$/ do |table|
  pending # express the regexp above with the code you wish you had
end

Dann /^die Auswahlmöglichkeiten können nicht kombiniert werden$/ do
  pending # express the regexp above with the code you wish you had
end

########################################################################

Dann /^hat man folgende Filtermöglichkeiten$/ do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
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