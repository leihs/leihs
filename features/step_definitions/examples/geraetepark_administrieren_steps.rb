# encoding: utf-8

When(/^ich in den Admin-Bereich wechsel$/) do
  find(".topbar-navigation a", text: _("Admin")).click
end

Angenommen(/^es existiert noch kein Gerätepark$/) do
  InventoryPool.delete_all
end

Wenn(/^ich im Admin\-Bereich unter dem Reiter Geräteparks einen neuen Gerätepark erstelle$/) do
  expect(current_path).to eq manage_inventory_pools_path
  click_link _("Create %s") % _("Inventory Pool")
end

Wenn(/^ich Name und Kurzname und Email eingebe$/) do
  find("input[name='inventory_pool[name]']").set "test"
  find("input[name='inventory_pool[shortname]']").set "test"
  find("input[name='inventory_pool[email]']").set "test@test.ch"
end

Wenn(/^ich speichere$/) do
  find("button", :text => /#{_("Save")}/i).click
end

Dann(/^ist der Gerätepark gespeichert$/) do
  expect(InventoryPool.find_by_name_and_shortname_and_email("test", "test", "test@test.ch")).not_to be nil
end

Dann(/^ich sehe die Geräteparkliste$/) do
  expect(has_content?(_("List of Inventory Pools"))).to be true
end

Wenn(/^ich (.+) nicht eingebe$/) do |must_field|
  step "ich Name und Kurzname und Email eingebe"
  find(".row .col1of2 strong", text: must_field).find(:xpath, "./../..").find("input").set ""
end

Dann(/^wird mir eine Fehlermeldung angezeigt$/) do
  step "ich sehe eine Fehlermeldung"
end

Dann(/^der Gerätepark wird nicht erstellt$/) do
  expect(has_no_content?(_("List of Inventory Pools"))).to be true
  expect(has_no_selector?(".success")).to be true
end

Wenn(/^ich im Admin\-Bereich unter dem Reiter Geräteparks einen bestehenden Gerätepark ändere$/) do
  @current_inventory_pool = InventoryPool.first
  expect(has_content?(_("List of Inventory Pools"))).to be true
  find(".line", match: :prefer_exact, text: @current_inventory_pool.name).click_link _("Edit")
end

Wenn(/^ich Name und Kurzname und Email ändere$/) do
  find(".row .col1of2 strong", text: _("Name")).find(:xpath, "./../..").find("input").set "test"
  find(".row .col1of2 strong", text: _("Short Name")).find(:xpath, "./../..").find("input").set "test"
  find(".row .col1of2 strong", text: _("E-Mail")).find(:xpath, "./../..").find("input").set "test@test.ch"
end

Dann(/^ist der Gerätepark und die eingegebenen Informationen gespeichert$/) do
  step "ist der Gerätepark gespeichert"
end

Wenn(/^ich im Admin\-Bereich unter dem Reiter Geräteparks einen bestehenden Gerätepark lösche$/) do
  @current_inventory_pool = InventoryPool.find(&:can_destroy?) || FactoryGirl.create(:inventory_pool)
  visit manage_inventory_pools_path
  within(".line", text: @current_inventory_pool.name) do
    find(:xpath, ".").click # NOTE it scrolls to the target line
    find(".multibutton .dropdown-toggle").click
    find(".multibutton a", text: _("Delete")).click
  end
end

Wenn(/^der Gerätepark wurde aus der Liste gelöscht$/) do
  find("#flash .success", text: _("%s successfully deleted") % _("Inventory Pool"))
  expect(has_no_content?(@current_inventory_pool.name)).to be true
end

Wenn(/^der Gerätepark wurde aus der Datenbank gelöscht$/) do
  expect(InventoryPool.find_by_name(@current_inventory_pool.name)).to eq nil
end

Dann(/^die Geräteparkauswahl ist alphabetish sortiert$/) do
  names = all("div.dropdown-holder:nth-child(1) .dropdown .dropdown-item").map(&:text)
  expect(names.map(&:downcase).sort).to eq names.map(&:downcase)
end

Then(/^I see all the inventory pools$/) do
  within "#ip-dropdown-menu" do
    InventoryPool.all.each {|ip| has_content? ip.name}
  end
end
