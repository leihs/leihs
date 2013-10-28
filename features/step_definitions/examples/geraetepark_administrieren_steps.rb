# encoding: utf-8

When(/^ich in den Admin-Bereich wechsel$/) do
  first(".navigation .admin a").click
end

Angenommen(/^es existiert noch kein Gerätepark$/) do
  InventoryPool.delete_all
end

Wenn(/^ich im Admin\-Bereich unter dem Reiter Geräteparks einen neuen Gerätepark erstelle$/) do
  current_path.should == backend_inventory_pools_path
  click_link _("Create %s") % _("Inventory Pool")
end

Wenn(/^ich Name und Kurzname und Email eingebe$/) do
  find(".field", text: _("Name"), match: :first).first("input").set "test"
  find(".field", text: _("Short Name"), match: :first).first("input").set "test"
  find(".field", text: _("E-Mail"), match: :first).first("input").set "test@test.ch"
end

Wenn(/^ich speichere$/) do
  click_button _("Save %s") % _("Inventory Pool")
end

Dann(/^ist der Gerätepark gespeichert$/) do
  InventoryPool.find_by_name_and_shortname_and_email("test", "test", "test@test.ch").should_not be_nil
end

Dann(/^eine Bestätigung wird angezeigt$/) do
  page.has_selector? ".success"
end

Dann(/^ich sehe die Geräteparkliste$/) do
  page.has_content? _("List of Inventory Pools")
end

Wenn(/^ich (.+) nicht eingebe$/) do |must_field|
  step "ich Name und Kurzname und Email eingebe"
  first(".field", text: must_field).first("input").set ""
end

Dann(/^wird mir eine Fehlermeldung angezeigt$/) do
  step "ich sehe eine Fehlermeldung"
end

Dann(/^der Gerätepark wird nicht erstellt$/) do
  page.should_not have_content _("List of Inventory Pools")
  page.should_not have_selector ".success"
end

Wenn(/^ich im Admin\-Bereich unter dem Reiter Geräteparks einen bestehenden Gerätepark ändere$/) do
  @ip = InventoryPool.first
  page.has_content? _("List of Inventory Pools")
  first("ul.line", text: @ip.name).click_link _("Edit %s") % _("Inventory Pool")
end

Wenn(/^ich Name und Kurzname und Email ändere$/) do
  first(".field", text: _("Name")).first("input").set "test"
  first(".field", text: _("Short Name")).first("input").set "test"
  first(".field", text: _("E-Mail")).first("input").set "test@test.ch"
end

Dann(/^ist der Gerätepark und die eingegebenen Informationen gespeichert$/) do
  step "ist der Gerätepark gespeichert"
end

Wenn(/^ich im Admin\-Bereich unter dem Reiter Geräteparks einen bestehenden Gerätepark lösche$/) do
  @ip = InventoryPool.find &:can_destroy?
  visit backend_inventory_pools_path

  first("ul.line", text: @ip.name)
  page.execute_script("$('.trigger .arrow').trigger('mouseover');")
  first("ul.line", text: @ip.name).first(".button", text: _("Delete %s") % _("Inventory Pool")).click
end

Wenn(/^der Gerätepark wurde aus der Liste gelöscht$/) do
  step "ensure there are no active requests"
  page.has_no_text? @ip.name
end

Wenn(/^der Gerätepark wurde aus der Datenbank gelöscht$/) do
  InventoryPool.find_by_name(@ip.name).should be_nil
end

Dann(/^ich sehe die Geräteparkauswahl$/) do
  first("#ipselection").click
end

Dann(/^die Geräteparkauswahl ist alphabetish sortiert$/) do
  names = first("#ipselection .popup").text.split
  names.map(&:downcase).sort.should == names.map(&:downcase)
end
