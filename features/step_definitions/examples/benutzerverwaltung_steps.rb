# -*- encoding : utf-8 -*-

Angenommen /^ein Benutzer hat aus der leihs 2.0-Datenbank den Level 1 auf einem Gerätepark$/ do
  step 'man ist "%s"' % "Assist"
  ar = @current_user.access_rights.where(:access_level => 1).first
  ar.should_not be_nil
  @inventory_pool = ar.inventory_pool
end

Dann /^gilt er in leihs 3.0 als Level 2 für diesen Gerätepark$/ do
  @current_user.has_at_least_access_level(2, @inventory_pool).should be_true
end

####################################################################

Angenommen /^man ist Inventar\-Verwalter oder Ausleihe\-Verwalter$/ do
  step 'man ist "%s"' % ["Mike", "Pius"].shuffle.first
  ar = @current_user.access_rights.where(:access_level => [2, 3]).first
  ar.should_not be_nil
  @inventory_pool = ar.inventory_pool
end

Angenommen /^man ist Ausleihe\-Verwalter$/ do
  step 'man ist "%s"' % "Pius"
  ar = @current_user.access_rights.where(:access_level => [1, 2]).first
  ar.should_not be_nil
  @inventory_pool = ar.inventory_pool
end

Angenommen /^man ist Inventar\-Verwalter$/ do
  step 'man ist "%s"' % "Mike"
  ar = @current_user.access_rights.where(:access_level => 3).first
  ar.should_not be_nil
  @inventory_pool = ar.inventory_pool
end

Angenommen /^man ist Administrator$/ do
  step 'man ist "%s"' % "Ramon"
end

####################################################################

Dann /^findet man die Benutzeradministration im Bereich "Administration" unter "Benutzer"$/ do
  step 'I follow "Admin"'
  step 'I follow "%s"' % _("Users")
end

Dann /^sieht man eine Liste aller Benutzer$/ do
  User.scoped.paginate(page: 1, per_page: 20).each do |user|
    page.should have_content(user.name)
  end
  page.should have_content _("List of Users")
end

Dann /^man kann filtern nach "(.*?)" Rolle$/ do |role|
  find(".inlinetabs > .tab", :text => role).click
end

Dann /^man kann filtern nach den folgenden Eigenschaften: gesperrt$/ do
  step 'man kann filtern nach "%s" Rolle' % _("Customer")
  wait_until { all(".loading", :visible => true).empty? }

  find("[ng-model='suspended']").click
  wait_until { all(".loading", :visible => true).empty? }
  @inventory_pool.suspended_users.customers.paginate(page: 1, per_page: 20).each do |user|
    page.should have_content(user.name)
  end
  page.should have_content _("List of Users")

  find("[ng-model='suspended']").click
  wait_until { all(".loading", :visible => true).empty? }
  @inventory_pool.users.customers.paginate(page: 1, per_page: 20).each do |user|
    page.should have_content(user.name)
  end
  page.should have_content _("List of Users")
end

Dann /^man kann filtern nach den folgenden Rollen:$/ do |table|
  table.hashes.each do |row|
    step 'man kann filtern nach "%s" Rolle' % row["tab"]
    role = row["role"]
    users = case role
            when "admins"
              User.admins
            when "no_access"
              User.where("users.id NOT IN (#{@inventory_pool.users.select("users.id").to_sql})")
            when "customers", "lending_managers", "inventory_managers"
              @inventory_pool.users.send(role)
            else
              User.scoped
            end.paginate(page:1, per_page: 20)
    wait_until { all(".loading", :visible => true).empty? }
    users.each do |user|
      page.should have_content(user.name)
    end
    page.should have_content _("List of Users")
  end
end

Dann /^man kann für jeden Benutzer die Editieransicht aufrufen$/ do
  step 'man kann filtern nach "%s" Rolle' % "All"
  el = find(".list ul.user")
  page.execute_script '$(":hidden").show();'
  el.find(".actions .button .icon.user")
end

Dann /^man kann einen neuen Benutzer erstellen$/ do
  find(".top .content_navigation .button .icon.user")
end

####################################################################

Angenommen /^man editiert einen Benutzer$/ do
  @inventory_pool ||= @current_user.managed_inventory_pools.first
  @customer = @inventory_pool.users.customers.first
  visit edit_backend_inventory_pool_user_path(@inventory_pool, @customer)
end

Angenommen /^man nutzt die Sperrfunktion$/ do
  el = find("[ng-model='user.access_right.suspended_until']")
  el.click
  date_s = (Date.today+1.month).strftime("%d.%m.%Y")
  el.set(date_s)
end

Dann /^muss man den Grund der Sperrung eingeben$/ do
  el = find("[ng-model='user.access_right.suspended_reason']")
  el.click
  el.set("this is the reason")
end

Dann /^sofern der Benutzer gesperrt ist, kann man die Sperrung aufheben$/ do
  visit edit_backend_inventory_pool_user_path(@inventory_pool, @customer)
  find("[ng-model='user.access_right.suspended_until']").set("")
  find(".content_navigation > button.green").click
  wait_until { find(".button.white", :text => _("New User")) }
  current_path.should == backend_inventory_pool_users_path(@inventory_pool)
  @inventory_pool.suspended_users.find_by_id(@customer.id).should be_nil
  @inventory_pool.users.find_by_id(@customer.id).should_not be_nil
  @customer.access_right_for(@inventory_pool).suspended?.should be_false
end

####################################################################

Angenommen /^ein (.*?)Benutzer (mit zugeteilter|ohne zugeteilte) Rolle erscheint in einer Benutzerliste$/ do |arg1, arg2|
  user = Persona.get("Normin")
  step 'findet man die Benutzeradministration im Bereich "Administration" unter "Benutzer"'
  case arg1
    when "gesperrter "
      user.access_rights.first.update_attributes(suspended_until: Date.today + 1.year, suspended_reason: "suspended reason")
  end
  case arg2
    when "mit zugeteilter"
      user.access_rights.should_not be_empty
    when "ohne zugeteilte"
      user.access_rights.delete_all
      user.access_rights.should be_empty
  end
  @el = find(".list ul.user", text: user.to_s)
end

Dann /^sieht man folgende Informationen in folgender Reihenfolge:$/ do |table|
  classes = table.hashes.map do |x|
    case x[:attr]
      when "Vorname Name"
        ".user_name"
      when "Telefonnummer"
        ".phone"
      when "Rolle"
        ".role"
      when "Sperr-Status 'Gesperrt bis dd.mm.yyyy'"
        @el.find(".suspended_status", text: "Gesperrt bis\n%s" % (Date.today + 1.year).strftime("%d.%m.%Y"))
        ".suspended_status"
    end
  end

  @el.find(classes.join(' + '))
end

####################################################################

Dann /^sieht man als Titel den Vornamen und Namen des Benutzers, sofern bereits vorhanden$/ do
  find(".top h1", :text => @customer.to_s)
end

Dann /^sieht man die folgenden Daten des Benutzers in der folgenden Reihenfolge:$/ do |table|
  values = table.hashes.map do |x|
    _(x[:en])
  end
  (page.text =~ Regexp.new(values.join('.*'), Regexp::MULTILINE)).should_not be_nil
end

Dann /^sieht man die Sperrfunktion für diesen Benutzer$/ do
  find("[ng-model='user.access_right.suspended_until']")
end

Dann /^sofern dieser Benutzer gesperrt ist, sieht man Grund und Dauer der Sperrung$/ do
  if @customer.access_right_for(@inventory_pool).suspended?
    find("[ng-model='user.access_right.suspended_reason']")
  end
end

Dann /^man kann die Informationen ändern, sofern es sich um einen externen Benutzer handelt$/ do
  if @customer.authentication_system.class_name == "DatabaseAuthentication"
    @attrs = [:lastname, :firstname, :address, :zip, :city, :country, :phone, :email]
    @attrs.each do |attr|
      orig_value = @customer.send(attr)
      f = find("input[ng-model='user.#{attr}']")
      f.value.should == orig_value
      f.set("#{attr}#{orig_value}")
    end
  end
end

Dann /^man kann die Informationen nicht verändern, sofern es sich um einen Benutzer handelt, der über ein externes Authentifizierungssystem eingerichtet wurde$/ do
  if @customer.authentication_system.class_name != "DatabaseAuthentication"
  end
end

Dann /^man sieht die Rollen des Benutzers und kann diese entsprechend seiner Rolle verändern$/ do
  find("select[ng-model='user.access_right.role_name']")
end

Dann /^man kann die vorgenommenen Änderungen abspeichern$/ do
  find(".content_navigation > button.green").click
  if @customer.authentication_system.class_name == "DatabaseAuthentication"
    sleep(0.5)
    @customer.reload
    @attrs.each do |attr|
      (@customer.send(attr) =~ /^#{attr}/).should_not be_nil
    end
  end
end

####################################################################

Dann /^kann man neue Gegenstände erstellen$/ do
  c = Item.count
  attributes = {
    model_id: @inventory_pool.models.first.id
  }
  page.driver.browser.process(:post, backend_inventory_pool_items_path(@inventory_pool, format: :json), {:item => attributes})
  expect(page.status_code == 200).to be_true
  Item.count.should == c+1
  @item = Item.last
end

Dann /^diese Gegenstände ausschliesslich nicht inventarrelevant sind$/ do
  page.driver.browser.process(:put, backend_inventory_pool_item_path(@inventory_pool, @item.id, format: :json), {:item => {is_inventory_relevant: true}})
  expect(page.status_code == 200).to be_false
end

Dann /^diese Gegenstände können inventarrelevant sein$/ do
  
  page.driver.browser.process(:put, backend_inventory_pool_item_path(@inventory_pool, @item.id, format: :json), item: {is_inventory_relevant: true})
  expect(page.status_code == 200).to be_true
  
  @item.reload.is_inventory_relevant.should be_true
end

Dann /^man kann Optionen erstellen$/ do
  c = Option.count
  factory_attributes = FactoryGirl.attributes_for(:option)
  attributes = {
    inventory_code: factory_attributes[:inventory_code],
    name: factory_attributes[:name],
    price: factory_attributes[:price]
  }
  page.driver.browser.process(:post, backend_inventory_pool_options_path(@inventory_pool, format: :json), option: attributes)
  expect(page.status_code == 200).to be_true
  Option.count.should == c+1
end

Dann /^man kann neue Benutzer erstellen (.*?) inventory_pool$/ do |arg1|
  c = User.count
  ids = User.pluck(:id)
  factory_attributes = FactoryGirl.attributes_for(:user)
  attributes = {}
  [:login, :firstname, :lastname, :phone, :email, :badge_id, :address, :city, :country, :zip].each do |a|
    attributes[a] = factory_attributes[a]
  end
  response = case arg1
                when "für"
                  page.driver.browser.process(:post, backend_inventory_pool_users_path(@inventory_pool), user: attributes, access_right: {role_name: "customer"}, db_auth: {login: attributes[:login], password: "password", password_confirmation: "password"})
               when "ohne"
                  page.driver.browser.process(:post, backend_users_path, user: attributes)
             end
  User.count.should == c+1
  id = (User.pluck(:id) - ids).first
  @user = User.find(id)
end

Dann /^man kann neue Benutzer erstellen und für die Ausleihe sperren$/ do
  step 'man kann neue Benutzer erstellen für inventory_pool'
  @user.access_right_for(@inventory_pool).suspended?.should be_false
  page.driver.browser.process(:put, backend_inventory_pool_user_path(@inventory_pool, @user, format: :json), access_right: {suspended_until: Date.today + 1.year, suspended_reason: "suspended reason"})
  expect(page.status_code == 200).to be_true
  @user.reload.access_right_for(@inventory_pool).suspended?.should be_true
end

Dann /^man kann Benutzern die folgende Rollen zuweisen und wegnehmen, wobei diese immer auf den Gerätepark bezogen ist, für den auch der Verwalter berechtigt ist$/ do |table|
  table.hashes.map do |x|
    unknown_user = User.no_access_for(@inventory_pool).order("RAND()").first
    raise "No user found" unless unknown_user

    role_name = case x[:role]
                  when _("Customer")
                    unknown_user.has_role?("customer", @inventory_pool).should be_false
                    "customer"
                  when _("Lending manager")
                    unknown_user.has_role?("manager", @inventory_pool).should be_false
                    "lending_manager"
                  when _("Inventory manager")
                    unknown_user.has_role?("manager", @inventory_pool).should be_false
                    "inventory_manager"
                  when _("No access")
                    # the unknown_user needs to have a role first, than it can be deleted
                    page.driver.browser.process(:put, backend_inventory_pool_user_path(@inventory_pool, unknown_user, format: :json), access_right: {role_name: "customer"}, db_auth: {login: Faker::Lorem.words(3).join, password: "password", password_confirmation: "password"})
                    "no_access"
                end

    data = {access_right: {role_name: role_name, suspended_until: nil},
            db_auth: {login: Faker::Lorem.words(3).join, password: "password", password_confirmation: "password"}}
    page.driver.browser.process(:put, backend_inventory_pool_user_path(@inventory_pool, unknown_user, format: :json), data)
    expect(page.status_code == 200).to be_true
    
    case role_name
      when "customer"
        unknown_user.has_role?("customer", @inventory_pool).should be_true
      when "lending_manager"
        unknown_user.has_role?("manager", @inventory_pool).should be_true
        unknown_user.has_at_least_access_level(2, @inventory_pool).should be_true
        unknown_user.has_at_least_access_level(3, @inventory_pool).should be_false
      when "inventory_manager"
        unknown_user.has_role?("manager", @inventory_pool).should be_true
        unknown_user.has_at_least_access_level(3, @inventory_pool).should be_true
    end
  end
end

Dann /^man kann nicht inventarrelevante Gegenstände ausmustern, sofern man deren Besitzer ist$/ do
  item = @inventory_pool.own_items.where(:is_inventory_relevant => false).first
  item.retired?.should be_false
  attributes = {
      retired: true,
      retired_reason: "Item is gone"
  }

  page.driver.browser.process(:put, backend_inventory_pool_item_path(@inventory_pool, item, format: :json), item: attributes)
  expect(page.status_code == 200).to be_true

  item.reload.retired?.should be_true
  item.retired.should == Date.today
end

####################################################################

Dann /^kann man neue Modelle erstellen$/ do
  c = Model.count
  attributes = FactoryGirl.attributes_for :model

  page.driver.browser.process(:post, backend_inventory_pool_models_path(@inventory_pool, format: :json), model: attributes)
  expect(page.status_code == 200).to be_true

  Model.count.should == c+1
end

Dann /^man kann sie einem anderen Gerätepark als Besitzer zuweisen$/ do
  attributes = {
    owner_id: (InventoryPool.pluck(:id) - [@inventory_pool.id]).shuffle.first
  }
  @item.owner_id.should_not == attributes[:owner_id]

  page.driver.browser.process(:put, backend_inventory_pool_item_path(@inventory_pool, @item, format: :json), item: attributes)
  expect(page.status_code == 200).to be_true

  @item.reload.owner_id.should == attributes[:owner_id]
end

Dann /^man kann die verantwortliche Abteilung eines Gegenstands frei wählen$/ do
  item = @inventory_pool.own_items.first
  attributes = {
      inventory_pool_id: (InventoryPool.pluck(:id) - [@inventory_pool.id]).shuffle.first
  }
  item.inventory_pool_id.should_not == attributes[:inventory_pool_id]

  page.driver.browser.process(:put, backend_inventory_pool_item_path(@inventory_pool, item, format: :json), item: attributes)
  expect(page.status_code == 200).to be_true

  item.reload.inventory_pool_id.should == attributes[:inventory_pool_id]

  attributes = {
      inventory_pool_id: nil
  }
  item.inventory_pool_id.should_not == attributes[:inventory_pool_id]

  page.driver.browser.process(:put, backend_inventory_pool_item_path(@inventory_pool, item, format: :json), item: attributes)
  expect(page.status_code == 200).to be_true

  item.reload.inventory_pool_id.should == attributes[:inventory_pool_id]
end

Dann /^man kann Gegenstände ausmustern, sofern man deren Besitzer ist$/ do
  item = @inventory_pool.own_items.first
  attributes = {
      retired: true,
      retired_reason: "retired reason"
  }
  item.retired.should be_nil
  item.retired_reason.should be_nil

  page.driver.browser.process(:put, backend_inventory_pool_item_path(@inventory_pool, item, format: :json), item: attributes)
  expect(page.status_code == 200).to be_true

  item.reload.retired.should == Date.today
  item.retired_reason.should == attributes[:retired_reason]
end

Dann /^man kann Ausmusterungen wieder zurücknehmen, sofern man Besitzer der jeweiligen Gegenstände ist$/ do
  item = Item.unscoped { @inventory_pool.own_items.where("retired IS NOT NULL").first }
  attributes = {
      retired: nil
  }
  item.retired.should_not be_nil
  item.retired_reason.should_not be_nil

  page.driver.browser.process(:put, backend_inventory_pool_item_path(@inventory_pool, item, format: :json), item: attributes)
  expect(page.status_code == 200).to be_true

  item.reload.retired.should be_nil
  item.retired_reason.should be_nil
end

Dann /^man kann die Arbeitstage und Ferientage seines Geräteparks anpassen$/ do
  %w(saturday sunday).each do |day|
    @inventory_pool.workday.send(day).should be_false
    visit open_backend_inventory_pool_workdays_path(@inventory_pool, :day => day)
    @inventory_pool.workday.reload.send(day).should be_true
  end

  %w(monday tuesday).each do |day|
    @inventory_pool.workday.send(day).should be_true
    visit close_backend_inventory_pool_workdays_path(@inventory_pool, :day => day)
    @inventory_pool.workday.reload.send(day).should be_false
  end
end

Dann /^man kann alles, was ein Ausleihe\-Verwalter kann$/ do
  @current_user.has_at_least_access_level(2, @inventory_pool).should be_true
  @current_user.has_at_least_access_level(3, @inventory_pool).should be_true
end

####################################################################

Dann /^kann man neue Geräteparks erstellen$/ do
  c = InventoryPool.count
  ids = InventoryPool.pluck(:id)
  attributes = FactoryGirl.attributes_for :inventory_pool

  page.driver.browser.process(:post, backend_inventory_pools_path, inventory_pool: attributes)
  expect(page.status_code == 302).to be_true

  InventoryPool.count.should == c+1
  id = (InventoryPool.pluck(:id) - ids).first
  
  URI.parse(current_path).path.should == backend_inventory_pools_path
end

Dann /^man kann neue Benutzer erstellen und löschen$/ do
  step 'man kann neue Benutzer erstellen ohne inventory_pool'

  page.driver.browser.process(:delete, backend_user_path(@user, format: :json))
  expect(page.status_code == 200).to be_true

  assert_raises(ActiveRecord::RecordNotFound) do
    @user.reload
  end
end

Dann /^man kann Benutzern jegliche Rollen zuweisen und wegnehmen$/ do
  user = Persona.get "Normin"
  inventory_pool = InventoryPool.find_by_name "IT-Ausleihe"
  user.has_at_least_access_level(3, inventory_pool).should be_false

  page.driver.browser.process(:put, backend_user_path(user, format: :json), access_right: {inventory_pool_id: inventory_pool.id, role_name: "inventory_manager"})
  expect(page.status_code == 200).to be_true

  user.has_at_least_access_level(3, inventory_pool).should be_true
  user.access_right_for(inventory_pool).deleted_at.should be_nil

  page.driver.browser.process(:put, backend_user_path(user, format: :json), access_right: {inventory_pool_id: inventory_pool.id, role_name: "no_access"})
  expect(page.status_code == 200).to be_true

  user.has_at_least_access_level(3, inventory_pool).should be_false
  user.deleted_access_rights.scoped_by_inventory_pool_id(inventory_pool).first.deleted_at.should_not be_nil
end

Dann(/^kann man Gruppen über eine Autocomplete\-Liste hinzufügen$/) do
  @groups_added = (@inventory_pool.groups - @customer.groups)
  @groups_added.each do |group|
    find(".field", :text => _("Groups")).find(".autocomplete").click
    find(".ui-autocomplete .ui-menu-item a", :text => group.name).click
  end
end

Dann(/^kann Gruppen entfernen$/) do
  @groups_removed = @customer.groups
  @groups_removed.each do |group|
    find(".field", :text => _("Groups")).find(".field-inline-entry", :text => group.name).find(".clickable", :text => _("Remove")).click
  end
end

Dann(/^speichert den Benutzer$/) do
  find(".button", :text => _("Save %s") % _("User")).click
end

Dann(/^ist die Gruppenzugehörigkeit gespeichert$/) do
  sleep(1)
  @groups_removed.each {|group| @customer.reload.groups.include?(group).should be_false}
  @groups_added.each {|group| @customer.reload.groups.include?(group).should be_true}
end

Wenn(/^man in der Benutzeransicht ist$/) do
  visit backend_inventory_pool_users_path(@current_inventory_pool)
end

Wenn(/^man einen Benutzer hinzufügt$/) do
  link = wait_until { find "a", text: _("New User")}
  link.click
end

Wenn(/^die folgenden Informationen eingibt$/) do |table|
  table.raw.flatten.each do |field_name|
    find(".field", text: field_name).find("input,textarea").set (field_name == "E-Mail" ? "test@test.ch" : "test")
  end
end

Wenn(/^man gibt eine Badge\-Id ein$/) do
  find(".field", text: _("Badge ID")).find("input,textarea").set 123456
end

Wenn(/^eine der folgenden Rollen auswählt$/) do |table|
  @role_hash = table.hashes[rand table.hashes.length]
  page.select @role_hash[:tab], from: "access_right_role_name"
end

Wenn(/^man wählt ein Sperrdatum und ein Sperrgrund$/) do
  find(".field", text: _("Suspended until")).find("input").set (Date.today + 1).strftime("%d.%m.%Y")
  find(".ui-datepicker-current-day").click
  suspended_reason = wait_until { find(".field", text: _("Suspended reason")).find("textarea") }
  suspended_reason.set "test"
end

Wenn(/^man teilt mehrere Gruppen zu$/) do
  @current_inventory_pool.groups.each do |group|
    find(".field", :text => _("Groups")).find(".autocomplete").click
    find(".ui-autocomplete .ui-menu-item a", :text => group.name).click
  end
end

Wenn(/^man speichert$/) do
  find(".button", :text => _("Create %s") % _("User")).click
end

Dann(/^ist der Benutzer mit all den Informationen gespeichert$/) do
  wait_until { find_link _("New User") }
  user = User.find_by_lastname "test"
  user.should_not be_nil
  user.access_right_for(@current_inventory_pool).role_name.should eq @role_hash[:role]
  user.groups.should == @current_inventory_pool.groups
end

Wenn(/^alle Pflichtfelder sind sichtbar und abgefüllt$/) do
  find(".field", text: _("Last name")).find("input,textarea").set "test"
  find(".field", text: _("First name")).find("input,textarea").set "test"
  find(".field", text: _("E-Mail")).find("input,textarea").set "test@test.ch"
end

Wenn(/^man ein Nachname nicht eingegeben hat$/) do
  find(".field", text: _("Last name")).find("input,textarea").set ""
end

Wenn(/^man ein Vorname nicht eingegeben hat$/) do
  find(".field", text: _("First name")).find("input,textarea").set ""
end

Wenn(/^man ein E\-Mail nicht eingegeben hat$/) do
  find(".field", text: _("E-Mail")).find("input,textarea").set ""
end

Wenn(/^man ein Sperrgrund nicht eingegeben hat$/) do
  find(".field", text: _("Suspended reason")).find("input,textarea").set ""
end

Angenommen(/^man befindet sich auf der Benutzerliste ausserhalb der Inventarpools$/) do
  visit backend_users_path
end

Wenn(/^man von hier auf die Benutzererstellungsseite geht$/) do
  click_link _("New User")
end

Wenn(/^den Nachnamen eingibt$/) do
  find(".field", text: _("Last name")).find("input").set "admin"
end

Wenn(/^den Vornahmen eingibt$/) do
  find(".field", text: _("First name")).find("input").set "test"
end

Wenn(/^die Email\-Addresse eingibt$/) do
  find(".field", text: _("E-Mail")).find("input").set "test@test.ch"
end

Dann(/^wird man auf die Benutzerliste ausserhalb der Inventarpools umgeleitet$/) do
  current_path.should == backend_users_path
end

Dann(/^der neue Benutzer wurde erstellt$/) do
  @user = User.find_by_firstname_and_lastname "test", "admin"
end

Dann(/^er hat keine Zugriffe auf Inventarpools und ist kein Administrator$/) do
  @user.access_rights.should be_empty
end

Dann(/^man sieht eine Bestätigungsmeldung$/) do
  wait_until { find ".pagination_container" }
  page.should have_selector ".success"
end

Angenommen(/^man befindet sich auf der Editierseite eines Benutzers, der kein Administrator ist$/) do
  @user = User.find {|u| not u.has_role? "admin"}
  visit edit_backend_user_path(@user)
end

Wenn(/^man diesen Benutzer die Rolle Administrator zuweist$/) do
  select _("Yes"), from: "user_admin"
end

Dann(/^hat dieser Benutzer die Rolle Administrator$/) do
  @user.reload.has_role?("admin").should be_true
end

Wenn(/^man speichert den Benutzer$/) do
  find(".button", text: _("Save %s") % _("User")).click
end

Wenn(/^man speichert den neuen Benutzer$/) do
  find(".button", text: _("Create %s") % _("User")).click
end

Angenommen(/^man befindet sich auf der Editierseite eines Benutzers, der ein Administrator ist$/) do
  @user = User.find {|u| u.has_role? "admin"}
  visit edit_backend_user_path(@user)
end

Wenn(/^man diesem Benutzer die Rolle Administrator wegnimmt$/) do
  select _("No"), from: "user_admin"
end

Dann(/^hat dieser Benutzer die Rolle Administrator nicht mehr$/) do
  @user.reload.has_role?("admin").should be_false
end

Wenn(/^man versucht auf die Administrator Benutzererstellenansicht zu gehen$/) do
  @path = edit_backend_user_path(User.first)
  visit @path
end

Dann(/^gelangt man auf diese Seite nicht$/) do
  current_path.should_not == @path
end

Wenn(/^man versucht auf die Administrator Benutzereditieransicht zu gehen$/) do
  @path = new_backend_user_path
  visit @path
end

Wenn(/^man hat nur die folgenden Rollen zur Auswahl$/) do |table|
  find(".field", text: _("Access as")).all("option").length.should == table.raw.length
  table.raw.flatten.each do |role|
    find(".field", text: _("Access as")).find("option", text: _(role))
  end
end

Angenommen(/^man editiert einen Benutzer der Kunde ist$/) do
  access_right = AccessRight.find{|ar| ar.role_name == "customer" and ar.inventory_pool == @current_inventory_pool}
  @user = access_right.user
  visit edit_backend_inventory_pool_user_path(@current_inventory_pool, @user)
end

Angenommen(/^man editiert einen Benutzer der Ausleihe-Verwalter ist$/) do
  access_right = AccessRight.find{|ar| ar.role_name == "lending_manager" and ar.inventory_pool == @current_inventory_pool and ar.user != @current_user}
  @user = access_right.user
  visit edit_backend_inventory_pool_user_path(@current_inventory_pool, @user)
end

Angenommen(/^man editiert in irgendeinem Inventarpool einen Benutzer der Kunde ist$/) do
  access_right = AccessRight.find{|ar| ar.role_name == "customer"}
  @user = access_right.user
  @current_inventory_pool = access_right.inventory_pool
  visit edit_backend_inventory_pool_user_path(access_right.inventory_pool, @user)
end

Wenn(/^man den Zugriff auf "Kunde" ändert$/) do
  find(".field", text: _("Access as")).find("select").select _("Customer")
end

Wenn(/^man den Zugriff auf "Ausleihe-Verwalter" ändert$/) do
  find(".field", text: _("Access as")).find("select").select _("Lending manager")
end

Wenn(/^man den Zugriff auf "Inventar-Verwalter" ändert$/) do
  find(".field", text: _("Access as")).find("select").select _("Inventory manager")
end

Dann(/^hat der Benutzer die Rolle Kunde$/) do
  page.has_content? _("List of Users")
  @user.reload.access_right_for(@current_inventory_pool).role_name.should == "customer"
end

Dann(/^hat der Benutzer die Rolle Ausleihe-Verwalter$/) do
  wait_until { find_link _("New User") }
  @user.reload.access_right_for(@current_inventory_pool).role_name.should == "lending_manager"
end

Dann(/^hat der Benutzer die Rolle Inventar-Verwalter$/) do
  wait_until { find_link _("New User") }
  @user.reload.access_right_for(@current_inventory_pool).role_name.should == "inventory_manager"
end

Angenommen(/^man sucht sich einen Benutzer ohne Zugriffsrechte, Bestellungen und Verträge aus$/) do
  @user = User.find {|u| u.access_rights.empty? and u.orders.empty? and u.contracts.empty?}
end

Wenn(/^ich diesen Benutzer aus der Liste lösche$/) do
  #find_field('query').set @model.name
  #wait_until { all("li.modelname").first.text == @model.name }
  wait_until { find(".line.user") }
  page.execute_script("$('.trigger .arrow').trigger('mouseover');")
  wait_until {find(".line.user", text: @user.name).find(".button", text: _("Delete %s") % _("User"))}.click
end

Dann(/^wurde der Benutzer aus der Liste gelöscht$/) do
  page.should_not have_content @user.name
end

Dann(/^der Benutzer ist gelöscht$/) do
  step "ensure there are no active requests"
  User.find_by_id(@user.id).should be_nil
end

Angenommen(/^man befindet sich auf der Benutzerliste im beliebigen Inventarpool$/) do
  visit backend_inventory_pool_users_path(InventoryPool.first)
end

Angenommen(/^man sucht sich je einen Benutzer mit Zugriffsrechten, Bestellungen und Verträgen aus$/) do
  @users = []
  @users << User.find {|u| not u.access_rights.empty? and u.orders.empty? and u.contracts.empty?}
  @users << User.find {|u| u.orders.empty? and not u.contracts.empty?}
  @users << User.find {|u| not u.orders.empty? and u.contracts.empty?}
end

Dann(/^wird der Delete Button für diese Benutzer nicht angezeigt$/) do
  @users.each do |user|
    find('.innercontent .search input').set user.name
    wait_until { find(".line.user", text: user.name) }
    page.execute_script("$('.trigger .arrow').trigger('mouseover');")
    find(".line.user", text: user.name).text.should_not match /#{_("Delete %s") % _("User")}/
  end
end

Angenommen(/^man editiert einen Benutzer der Zugriff auf ein Inventarpool hat$/) do
  access_right = AccessRight.find{|ar| ar.role_name == "customer"}
  @user = access_right.user
  @current_inventory_pool = access_right.inventory_pool
  visit edit_backend_inventory_pool_user_path(@current_inventory_pool, @user)
end

Angenommen(/^man editiert einen Benutzer der Zugriff auf das aktuelle Inventarpool hat$/) do
  @user = @current_inventory_pool.access_rights.find{|ar| ar.role_name == "customer"}.user
  visit edit_backend_inventory_pool_user_path(@current_inventory_pool, @user)
end

Angenommen(/^man editiert einen Benutzer der Zugriff auf das aktuelle Inventarpool hat und keine Gegenstände mehr zurückzugeben hat$/) do
  @user = @current_inventory_pool.access_rights.select{|ar| ar.role_name == "customer"}.detect{|ar| @current_inventory_pool.contract_lines.by_user(ar.user).to_take_back.empty?}.user
  visit edit_backend_inventory_pool_user_path(@current_inventory_pool, @user)
end

Wenn(/^man den Zugriff entfernt$/) do
  find(".field", text: _("Access as")).find("select").select _("No access")
end

Dann(/^hat der Benutzer keinen Zugriff auf das Inventarpool$/) do
  wait_until { find_link _("New User") }
  @user.reload.access_right_for(@current_inventory_pool).should be_nil
end

Dann(/^sind die Benutzer nach ihrem Vornamen alphabetisch sortiert$/) do
  wait_until { find ".line.user" }

  if current_path == backend_users_path
    all("li.user_name").map(&:text).map{|t| t.split("\n").second}
  else
    all("li.user_name").map(&:text)
  end.should == User.scoped.order(:firstname).paginate(page:1, per_page: 20).map(&:name)
end

Und(/^man gibt die Login-Daten ein$/) do
  find(".field", text: _("Login")).find("input").set "username"
  find(".field", text: _("Password")).find("input").set "password"
  find(".field", text: _("Password Confirmation")).find("input").set "password"
end

Angenommen(/^man editiert einen Benutzer der kein Zugriff auf das aktuelle Inventarpool hat$/) do
  @user = User.find {|u| u.access_rights.blank?}
  visit edit_backend_inventory_pool_user_path(@current_inventory_pool, @user)
end

Wenn(/^man ändert die Email$/) do
  find(".field", text: _("E-Mail")).find("input,textarea").set "changed@test.ch"
end

Dann(/^sieht man die Erfolgsbestätigung$/) do
  page.has_content? _("List of Users")
  page.has_selector? ".notice"
end

Dann(/^die neue Email des Benutzers wurde gespeichert$/) do
  @user.reload.email.should == "changed@test.ch"
end

Dann(/^der Benutzer hat nach wie vor keinen Zugriff auf das aktuelle Inventarpool$/) do
  @user.access_rights.detect{|ar| ar.inventory_pool == @current_inventory_pool}.should be_nil
end

Angenommen(/^man editiert einen Benutzer der mal einen Zugriff auf das aktuelle Inventarpool hatte$/) do
  @user = User.find_by_login "normin"
  @current_inventory_pool = (@current_user.managed_inventory_pools & @user.all_access_rights.select(&:deleted_at).map(&:inventory_pool)).first
  visit edit_backend_inventory_pool_user_path(@current_inventory_pool, @user)
end
