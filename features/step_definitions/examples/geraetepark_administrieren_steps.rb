# encoding: utf-8

Angenommen(/^es existiert noch kein Gerätepark$/) do
  InventoryPool.delete_all
end

Wenn(/^ich im Admin\-Bereich unter dem Reiter Geräteparks einen neuen Gerätepark erstelle$/) do
  wait_until {current_path == backend_inventory_pools_path}
  click_link _("Create %s") % _("Inventory Pool")
end

Wenn(/^ich Name und Kurzname und Email eingebe$/) do
  find(".field", text: _("Name")).find("input").set "test"
  find(".field", text: _("Short Name")).find("input").set "test"
  find(".field", text: _("E-Mail")).find("input").set "test@test.ch"
end

Wenn(/^ich speichere$/) do
  click_button _("Save %s") % _("Inventory Pool")
end

Dann(/^ist der Gerätepark gespeichert$/) do
  InventoryPool.find_by_name_and_shortname_and_email("test", "test", "test@test.ch").should_not be_nil
end

Dann(/^eine Bestätigung wird angezeigt$/) do
  wait_until {page.has_selector? ".success"}
end

Dann(/^ich sehe die Geräteparkliste$/) do
  wait_until {page.has_content? _("List of Inventory Pools")}
end

Wenn(/^ich (.+) nicht eingebe$/) do |must_field|
  step "ich Name und Kurzname und Email eingebe"
  find(".field", text: must_field).find("input").set ""
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
  wait_until {page.has_content? _("List of Inventory Pools")}
  find("ul.line", text: @ip.name).click_link _("Edit %s") % _("Inventory Pool")
end

Wenn(/^ich Name und Kurzname und Email ändere$/) do
  find(".field", text: _("Name")).find("input").set "test"
  find(".field", text: _("Short Name")).find("input").set "test"
  find(".field", text: _("E-Mail")).find("input").set "test@test.ch"
end

Dann(/^ist der Gerätepark und die eingegebenen Informationen gespeichert$/) do
  step "ist der Gerätepark gespeichert"
end

Wenn(/^ich im Admin\-Bereich unter dem Reiter Geräteparks einen bestehenden Gerätepark lösche$/) do
  @ip = InventoryPool.find &:can_destroy?
  visit backend_inventory_pools_path

  wait_until { find("ul.line", text: @ip.name) }
  page.execute_script("$('.trigger .arrow').trigger('mouseover');")
  find("ul.line", text: @ip.name).find(".button", text: _("Delete %s") % _("Inventory Pool")).click
end

Wenn(/^der Gerätepark wurde aus der Liste gelöscht$/) do
  page.has_no_selector? "ul.line", text: @ip.name
end

Wenn(/^der Gerätepark wurde aus der Datenbank gelöscht$/) do
  InventoryPool.find_by_name(@ip.name).should be_nil
end

