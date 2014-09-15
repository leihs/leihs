# -*- encoding : utf-8 -*-

Angenommen /^man ist Inventar\-Verwalter oder Ausleihe\-Verwalter$/ do
  step 'ich bin %s' % ["Mike", "Pius"].sample
  ar = @current_user.access_rights.active.where(role: [:lending_manager, :inventory_manager]).first
  expect(ar).not_to be nil
  @inventory_pool = ar.inventory_pool
end

Angenommen /^man ist Ausleihe\-Verwalter$/ do
  step 'ich bin %s' % "Pius"
  ar = @current_user.access_rights.active.where(role: :lending_manager).first
  expect(ar).not_to be nil
  @inventory_pool = ar.inventory_pool
end

Angenommen /^man ist Inventar\-Verwalter$/ do
  step 'ich bin %s' % "Mike"
  ar = @current_user.access_rights.active.where(role: :inventory_manager).first
  expect(ar).not_to be nil
  @inventory_pool = ar.inventory_pool
end

Angenommen /^man ist Administrator$/ do
  step 'ich bin %s' % "Ramon"
end

####################################################################

def check_user_list(users)
  expect(has_content?(_("List of Users"))).to be true
  within "#user-list" do
    users.each do |user|
      expect(has_content?(user.name)).to be true
    end
  end
end

Dann /^sieht man eine Liste aller Benutzer$/ do
  users = User.order("firstname ASC").paginate(page: 1, per_page: 20)
  check_user_list(users)
end

Dann /^man kann filtern nach "(.*?)" Rolle$/ do |role|
  find("#user-index-view .inline-tab-navigation .inline-tab-item", text: role).click
end

Dann /^man kann filtern nach den folgenden Eigenschaften: gesperrt$/ do
  step 'man kann filtern nach "%s" Rolle' % _("Customer")

  find("#list-filters [type='checkbox'][name='suspended']").click
  users = @inventory_pool.suspended_users.customers.paginate(page: 1, per_page: 20)
  check_user_list(users)

  find("#list-filters [type='checkbox'][name='suspended']").click
  users = @inventory_pool.users.customers.paginate(page: 1, per_page: 20)
  check_user_list(users)
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
              User.all
            end.paginate(page:1, per_page: 20)
    check_user_list(users)
  end
end

Dann /^man kann für jeden Benutzer die Editieransicht aufrufen$/ do
  step 'man kann filtern nach "%s" Rolle' % "All"
  expect(has_selector?("#user-list [data-type='user-cell']")).to be true
  all("#user-list > .line").each do |line|
    within line.find(".multibutton") do
      find(".dropdown-toggle").click
      find(".dropdown-item", text: _("Edit"))
    end
  end
end

Dann /^man kann einen neuen Benutzer erstellen$/ do
  find(".top .content_navigation .button .icon.user")
end

####################################################################

Angenommen /^man editiert einen Benutzer$/ do
  @inventory_pool ||= @current_user.managed_inventory_pools.first
  @customer = @inventory_pool.users.customers.first
  visit manage_edit_inventory_pool_user_path(@inventory_pool, @customer)
end

Angenommen /^man nutzt die Sperrfunktion$/ do
  el = find("[data-suspended-until-input]")
  el.click
  date_s = (Date.today+1.month).strftime("%d.%m.%Y")
  el.set(date_s)
  find(".ui-state-active").click
end

Dann /^muss man den Grund der Sperrung eingeben$/ do
  el = find("[name='access_right[suspended_reason]']")
  el.click
  el.set("this is the reason")
end

Dann /^sofern der Benutzer gesperrt ist, kann man die Sperrung aufheben$/ do
  visit manage_edit_inventory_pool_user_path(@inventory_pool, @customer)
  find("[data-suspended-until-input]").set("")
  find(".button", text: _("Save")).click
  find(".button.white", :text => _("New User"))
  expect(current_path).to eq manage_inventory_pool_users_path(@inventory_pool)
  expect(@inventory_pool.suspended_users.find_by_id(@customer.id)).to eq nil
  expect(@inventory_pool.users.find_by_id(@customer.id)).not_to be nil
  expect(@customer.access_right_for(@inventory_pool).suspended?).to be false
end

####################################################################

Angenommen /^ein (.*?)Benutzer (mit zugeteilter|ohne zugeteilte) Rolle erscheint in einer Benutzerliste$/ do |arg1, arg2|
  user = Persona.get("Normin")
  step 'findet man die Benutzeradministration im Bereich "Administration" unter "Benutzer"'
  case arg1
    when "gesperrter "
      user.access_rights.active.first.update_attributes(suspended_until: Date.today + 1.year, suspended_reason: "suspended reason")
  end
  case arg2
    when "mit zugeteilter"
      expect(user.access_rights.active.empty?).to be false
    when "ohne zugeteilte"
      user.access_rights.active.delete_all
      expect(user.access_rights.active.empty?).to be true
  end
  find("#list-search").set user.to_s # this step is needed for CI in order show a line entry which would otherwise be in a non displayed scrollable page
  @el = find("#user-list .line", text: user.to_s)
end

Dann /^sieht man folgende Informationen in folgender Reihenfolge:$/ do |table|
  user = User.find @el.find("[data-id]")["data-id"]
  access_right = user.access_right_for(@inventory_pool)

  strings = table.hashes.map do |x|
    case x[:attr]
      when "Vorname Name"
        user.name
      when "Telefonnummer"
        user.phone
      when "Rolle"
        role = access_right.try(:role) || "no access"
        _(role.to_s.humanize)
      when "Sperr-Status 'Gesperrt bis dd.mm.yyyy'"
        "#{_("Suspended until")} %s" % access_right.suspended_until.strftime("%d.%m.%Y")
    end
  end

  expect(@el.text).to match Regexp.new(strings.join(".*"))
end

####################################################################

Dann /^sieht man als Titel den Vornamen und Namen des Benutzers, sofern bereits vorhanden$/ do
  find(".top h1", :text => @customer.to_s)
end

Dann /^sieht man die folgenden Daten des Benutzers in der folgenden Reihenfolge:$/ do |table|
  values = table.hashes.map do |x|
    _(x[:en])
  end
  expect(page.text).to match Regexp.new(values.join('.*'), Regexp::MULTILINE)
end

Dann /^sieht man die Sperrfunktion für diesen Benutzer$/ do
  find("[data-suspended-until-input]")
end

Dann /^sofern dieser Benutzer gesperrt ist, sieht man Grund und Dauer der Sperrung$/ do
  if @customer.access_right_for(@inventory_pool).suspended?
    find("[name='access_right[suspended_reason]']")
  end
end

Dann /^man kann die Informationen ändern, sofern es sich um einen externen Benutzer handelt$/ do
  if @customer.authentication_system.class_name == "DatabaseAuthentication"
    @attrs = [:lastname, :firstname, :address, :zip, :city, :country, :phone, :email]
    @attrs.each do |attr|
      orig_value = @customer.send(attr)
      f = find("input[ng-model='user.#{attr}']")
      expect(f.value).to eq orig_value
      f.set("#{attr}#{orig_value}")
    end
  end
end

Dann /^man kann die Informationen nicht verändern, sofern es sich um einen Benutzer handelt, der über ein externes Authentifizierungssystem eingerichtet wurde$/ do
  if @customer.authentication_system.class_name != "DatabaseAuthentication"
  end
end

Dann /^man sieht die Rollen des Benutzers und kann diese entsprechend seiner Rolle verändern$/ do
  find("select[ng-model='user.access_right.role']")
end

Dann /^man kann die vorgenommenen Änderungen abspeichern$/ do
  find(".content_navigation > button.green").click
  if @customer.authentication_system.class_name == "DatabaseAuthentication"
    sleep(0.33)
    @customer.reload
    @attrs.each do |attr|
      expect(@customer.send(attr)).to match /^#{attr}/
    end
  end
end

####################################################################

Dann /^kann man neue Gegenstände erstellen$/ do
  c = Item.count
  attributes = {
    model_id: @inventory_pool.models.first.id
  }
  expect(page.driver.browser.process(:post, manage_create_item_path(@inventory_pool, format: :json), {:item => attributes}).successful?).to be true
  expect(Item.count).to eq c+1
  @item = Item.last
end

Dann /^diese Gegenstände ausschliesslich nicht inventarrelevant sind$/ do
  expect(page.driver.browser.process(:put, manage_update_item_path(@inventory_pool, @item.id, format: :json), {:item => {is_inventory_relevant: true}}).successful?).to be false
end

Dann /^diese Gegenstände können inventarrelevant sein$/ do
  expect(page.driver.browser.process(:put, manage_update_item_path(@inventory_pool, @item.id, format: :json), item: {is_inventory_relevant: true}).successful?).to be true
  expect(@item.reload.is_inventory_relevant).to be true
end

Dann /^man kann Optionen erstellen$/ do
  c = Option.count
  factory_attributes = FactoryGirl.attributes_for(:option)
  attributes = {
    inventory_code: factory_attributes[:inventory_code],
    product: factory_attributes[:product],
    version: factory_attributes[:version],
    price: factory_attributes[:price]
  }
  expect(page.driver.browser.process(:post, manage_options_path(@inventory_pool, format: :json), option: attributes).redirection?).to be true
  expect(Option.count).to eq c+1
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
                  page.driver.browser.process(:post, manage_inventory_pool_users_path(@inventory_pool), user: attributes, access_right: {role: :customer}, db_auth: {login: attributes[:login], password: "password", password_confirmation: "password"})
               when "ohne"
                  page.driver.browser.process(:post, manage_users_path, user: attributes)
             end
  expect(User.count).to eq c+1
  id = (User.pluck(:id) - ids).first
  @user = User.find(id)
end

Dann /^man kann neue Benutzer erstellen und für die Ausleihe sperren$/ do
  step 'man kann neue Benutzer erstellen für inventory_pool'
  expect(@user.access_right_for(@inventory_pool).suspended?).to be false
  expect(page.driver.browser.process(:put, manage_update_inventory_pool_user_path(@inventory_pool, @user, format: :json), access_right: {suspended_until: Date.today + 1.year, suspended_reason: "suspended reason"}).successful?).to be true
  expect(@user.reload.access_right_for(@inventory_pool).suspended?).to be true
end

Dann /^man kann Benutzern die folgende Rollen zuweisen und wegnehmen, wobei diese immer auf den Gerätepark bezogen ist, für den auch der Verwalter berechtigt ist$/ do |table|
  table.hashes.map do |x|
    unknown_user = User.select{|u| not u.access_right_for(@inventory_pool)}.sample
    raise "No user found" unless unknown_user

    role = case x[:role]
              when _("Customer")
                expect(unknown_user.has_role?(:customer, @inventory_pool)).to be false
                :customer
              when _("Group manager")
                expect(unknown_user.has_role?(:group_manager, @inventory_pool)).to be false
                :group_manager
              when _("Lending manager")
                expect(unknown_user.has_role?(:lending_manager, @inventory_pool)).to be false
                :lending_manager
              when _("Inventory manager")
                expect(unknown_user.has_role?(:inventory_manager, @inventory_pool)).to be false
                :inventory_manager
              when _("No access")
                # the unknown_user needs to have a role first, than it can be deleted
                page.driver.browser.process(:put, manage_update_inventory_pool_user_path(@inventory_pool, unknown_user, format: :json), {user: {id: unknown_user.id}}, access_right: {role: :customer}, db_auth: {login: Faker::Lorem.words(3).join, password: "password", password_confirmation: "password"})
                :no_access
            end

    data = {user: {id: unknown_user.id},
            access_right: {role: role, suspended_until: nil},
            db_auth: {login: Faker::Lorem.words(3).join, password: "password", password_confirmation: "password"}}

    expect(page.driver.browser.process(:put, manage_update_inventory_pool_user_path(@inventory_pool, unknown_user, format: :json), data).successful?).to be true

    case role
      when :customer
        expect(unknown_user.has_role?(:customer, @inventory_pool)).to be true
      when :group_manager
        expect(unknown_user.has_role?(:group_manager, @inventory_pool)).to be true
        expect(unknown_user.has_role?(:lending_manager, @inventory_pool)).to be false
      when :lending_manager
        expect(unknown_user.has_role?(:group_manager, @inventory_pool)).to be true
        expect(unknown_user.has_role?(:lending_manager, @inventory_pool)).to be true
        expect(unknown_user.has_role?(:inventory_manager, @inventory_pool)).to be false
      when :inventory_manager
        expect(unknown_user.has_role?(:group_manager, @inventory_pool)).to be true
        expect(unknown_user.has_role?(:lending_manager, @inventory_pool)).to be true
        expect(unknown_user.has_role?(:inventory_manager, @inventory_pool)).to be true
    end
  end
end

Dann /^man kann nicht inventarrelevante Gegenstände ausmustern, sofern man deren Besitzer ist$/ do
  item = @inventory_pool.own_items.where(:is_inventory_relevant => false).first
  expect(item.retired?).to be false
  attributes = {
      retired: true,
      retired_reason: "Item is gone"
  }

  expect(page.driver.browser.process(:put, manage_update_item_path(@inventory_pool, item, format: :json), item: attributes).successful?).to be true

  expect(item.reload.retired?).to be true
  expect(item.retired).to eq Date.today
end

####################################################################

Dann /^kann man neue Modelle erstellen$/ do
  c = Model.count
  attributes = FactoryGirl.attributes_for :model

  expect(page.driver.browser.process(:post, "/manage/#{@inventory_pool.id}/models.json" , model: attributes).successful?).to be true
  expect(Model.count).to eq c+1
end

Dann /^man kann sie einem anderen Gerätepark als Besitzer zuweisen$/ do
  attributes = {
    owner_id: (InventoryPool.pluck(:id) - [@inventory_pool.id]).sample
  }
  expect(@item.owner_id).not_to eq attributes[:owner_id]

  expect(page.driver.browser.process(:put, manage_update_item_path(@inventory_pool, @item, format: :json), item: attributes).successful?).to be true
  expect(@item.reload.owner_id).to eq attributes[:owner_id]
end

Wenn /^man keine verantwortliche Abteilung auswählt$/ do
  @item = @inventory_pool.own_items.find &:in_stock?
  attributes = {
      inventory_pool_id: (InventoryPool.pluck(:id) - [@inventory_pool.id, @item.inventory_pool_id]).sample
  }
  expect(@item.inventory_pool_id).not_to eq attributes[:inventory_pool_id]

  expect(page.driver.browser.process(:put, manage_update_item_path(@inventory_pool, @item, format: :json), item: attributes).successful?).to be true
  expect(@item.reload.inventory_pool_id).to eq attributes[:inventory_pool_id]

  attributes = {
      inventory_pool_id: nil
  }
  expect(@item.inventory_pool_id).not_to eq attributes[:inventory_pool_id]

  expect(page.driver.browser.process(:put, manage_update_item_path(@inventory_pool, @item, format: :json), item: attributes).successful?).to be true
end

Dann /^ist die Verantwortliche Abteilung gleich wie der Besitzer$/ do
  expect(@item.reload.inventory_pool_id).to eq @item.owner_id
end

Dann /^man kann Gegenstände ausmustern, sofern man deren Besitzer ist$/ do
  item = @inventory_pool.own_items.find &:in_stock?
  attributes = {
      retired: true,
      retired_reason: "retired reason"
  }
  expect(item.retired).to eq nil
  expect(item.retired_reason).to eq nil

  expect(page.driver.browser.process(:put, manage_update_item_path(@inventory_pool, item, format: :json), item: attributes).successful?).to be true
  expect(item.reload.retired).to eq Date.today
  expect(item.retired_reason).to eq attributes[:retired_reason]
end

Dann /^man kann Ausmusterungen wieder zurücknehmen, sofern man Besitzer der jeweiligen Gegenstände ist$/ do
  item = Item.unscoped { @inventory_pool.own_items.where("retired IS NOT NULL").first }
  attributes = {
      retired: nil
  }
  expect(item.retired).not_to be nil
  expect(item.retired_reason).not_to be nil

  expect(page.driver.browser.process(:put, manage_update_item_path(@inventory_pool, item, format: :json), item: attributes).successful?).to be true
  expect(item.reload.retired).to eq nil
  expect(item.retired_reason).to eq nil
end

Dann /^man kann die Arbeitstage und Ferientage seines Geräteparks anpassen$/ do
  visit manage_edit_inventory_pool_path @inventory_pool
end

Dann /^man kann alles, was ein Ausleihe\-Verwalter kann$/ do
  expect(@current_user.has_role?(:lending_manager, @inventory_pool)).to be true
  expect(@current_user.has_role?(:inventory_manager, @inventory_pool)).to be true
end

####################################################################

Dann /^kann man neue Geräteparks erstellen$/ do
  c = InventoryPool.count
  ids = InventoryPool.pluck(:id)
  attributes = FactoryGirl.attributes_for :inventory_pool

  page.driver.browser.process(:post, manage_inventory_pools_path, inventory_pool: attributes)
  expect(page.status_code == 302).to be true

  expect(InventoryPool.count).to eq c+1
  id = (InventoryPool.pluck(:id) - ids).first
  
  expect(URI.parse(current_path).path).to eq manage_inventory_pools_path
end

Dann /^man kann neue Benutzer erstellen und löschen$/ do
  step 'man kann neue Benutzer erstellen ohne inventory_pool'

  expect(page.driver.browser.process(:delete, manage_user_path(@user, format: :json)).successful?).to be true

  assert_raises(ActiveRecord::RecordNotFound) do
    @user.reload
  end
end

Dann /^man kann Benutzern jegliche Rollen zuweisen und wegnehmen$/ do
  user = Persona.get "Normin"
  inventory_pool = InventoryPool.find_by_name "IT-Ausleihe"
  expect(user.has_role?(:inventory_manager, inventory_pool)).to be false

  expect(page.driver.browser.process(:put, manage_user_path(user, format: :json), access_right: {inventory_pool_id: inventory_pool.id, role: :inventory_manager}).successful?).to be true

  expect(user.has_role?(:inventory_manager, inventory_pool)).to be true
  expect(user.access_right_for(inventory_pool).deleted_at).to eq nil

  expect(page.driver.browser.process(:put, manage_user_path(user, format: :json), access_right: {inventory_pool_id: inventory_pool.id, role: :no_access}).successful?).to be true

  expect(user.has_role?(:inventory_manager, inventory_pool)).to be false
  expect(user.access_rights.where("deleted_at IS NOT NULL").where(inventory_pool_id: inventory_pool).first.deleted_at).not_to be nil
end

Dann(/^kann man Gruppen über eine Autocomplete\-Liste hinzufügen$/) do
  @groups_added = (@inventory_pool.groups - @customer.groups)
  @groups_added.each do |group|
    find(".row.emboss", match: :prefer_exact, :text => _("Groups")).find(".autocomplete").click
    find(".ui-autocomplete .ui-menu-item a", :text => group.name).click
  end
end

Dann(/^kann Gruppen entfernen$/) do
  @groups_removed = @customer.groups
  @groups_removed.each do |group|
    find(".row.emboss", match: :prefer_exact, :text => _("Groups")).find(".field-inline-entry", :text => group.name).find(".clickable", :text => _("Remove")).click
  end
end

Dann(/^speichert den Benutzer$/) do
  find(".button", :text => _("Save %s") % _("User")).click
  sleep(0.33)
  step "man sieht eine Bestätigungsmeldung"
  sleep(0.33)
end

Dann(/^ist die Gruppenzugehörigkeit gespeichert$/) do
  sleep(0.33)
  @groups_removed.each do |group|
    expect(@customer.reload.groups.include?(group)).to be false
  end
  @groups_added.each do |group|
    expect(@customer.reload.groups.include?(group)).to be true
  end
end

Wenn(/^man in der Benutzeransicht ist$/) do
  visit manage_inventory_pool_users_path(@current_inventory_pool)
end

Wenn(/^man einen Benutzer hinzufügt$/) do
  find_link(_("New User")).click
end

Wenn(/^die folgenden Informationen eingibt$/) do |table|
  table.raw.flatten.each do |field_name|
    find(".row.emboss", match: :prefer_exact, text: field_name).find("input,textarea").set (field_name == "E-Mail" ? "test@test.ch" : "test")
  end
end

Wenn(/^man gibt eine Badge\-Id ein$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Badge ID")).find("input,textarea").set 123456
end

Wenn(/^eine der folgenden Rollen auswählt$/) do |table|
  @role_hash = table.hashes[rand table.hashes.length]
  page.select @role_hash[:tab], from: "access_right[role]"
end

Wenn(/^man wählt ein Sperrdatum und ein Sperrgrund$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Suspended until")).find("input").set (Date.today + 1).strftime("%d.%m.%Y")
  find(".ui-datepicker-current-day").click
  suspended_reason = find(".row.emboss", match: :prefer_exact, text: _("Suspended reason")).find("textarea")
  suspended_reason.set "test"
end

Wenn(/^man teilt mehrere Gruppen zu$/) do
  @current_inventory_pool.groups.each do |group|
    find("#change-groups input").click
    find(".ui-autocomplete .ui-menu-item a", match: :first)
    find(".ui-autocomplete .ui-menu-item a", :text => group.name).click
  end
end

Dann(/^ist der Benutzer mit all den Informationen gespeichert$/) do
  find_link _("New User")
  find("#flash .notice", text: _("User created successfully"))
  user = User.find_by_lastname "test"
  expect(user).not_to be nil
  expect(user.access_right_for(@current_inventory_pool).role).to eq @role_hash[:role].to_sym
  expect(user.groups).to eq @current_inventory_pool.groups
end

Wenn(/^alle Pflichtfelder sind sichtbar und abgefüllt$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Last name")).find("input,textarea").set "test"
  find(".row.emboss", match: :prefer_exact, text: _("First name")).find("input,textarea").set "test"
  find(".row.emboss", match: :prefer_exact, text: _("E-Mail")).find("input,textarea").set "test@test.ch"
end

Wenn(/^man ein Nachname nicht eingegeben hat$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Last name")).find("input,textarea").set ""
end

Wenn(/^man ein Vorname nicht eingegeben hat$/) do
  find(".row.emboss", match: :prefer_exact, text: _("First name")).find("input,textarea").set ""
end

Wenn(/^man ein E\-Mail nicht eingegeben hat$/) do
  find(".row.emboss", match: :prefer_exact, text: _("E-Mail")).find("input,textarea").set ""
end

Wenn(/^man ein Sperrgrund nicht eingegeben hat$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Suspended reason")).find("input,textarea").set ""
end

Angenommen(/^man befindet sich auf der Benutzerliste ausserhalb der Inventarpools$/) do
  visit manage_users_path
end

Wenn(/^man von hier auf die Benutzererstellungsseite geht$/) do
  click_link _("New User")
end

Wenn(/^den Nachnamen eingibt$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Last name")).find("input").set "admin"
end

Wenn(/^den Vornahmen eingibt$/) do
  find(".row.emboss", match: :prefer_exact, text: _("First name")).find("input").set "test"
end

Wenn(/^die Email\-Addresse eingibt$/) do
  find(".row.emboss", match: :prefer_exact, text: _("E-Mail")).find("input").set "test@test.ch"
end

Dann(/^wird man auf die Benutzerliste ausserhalb der Inventarpools umgeleitet$/) do
  expect(current_path).to eq manage_users_path
end

Dann(/^der neue Benutzer wurde erstellt$/) do
  sleep(0.33)
  @user = User.find_by_firstname_and_lastname "test", "admin"
end

Dann(/^er hat keine Zugriffe auf Inventarpools und ist kein Administrator$/) do
  expect(@user.access_rights.active.empty?).to be true
end

Dann(/^man sieht eine Bestätigungsmeldung$/) do
  find("#flash .notice")
end

Angenommen(/^man befindet sich auf der Editierseite eines Benutzers, der kein Administrator ist und der Zugriffe auf Inventarpools hat$/) do
  @user = User.find {|u| not u.has_role? :admin and u.has_role? :customer}
  @previous_access_rights = @user.access_rights.freeze
  visit manage_edit_user_path(@user)
end

Wenn(/^man diesen Benutzer die Rolle Administrator zuweist$/) do
  select _("Yes"), from: "user_admin"
end

Dann(/^hat dieser Benutzer die Rolle Administrator$/) do
  expect(@user.reload.has_role?(:admin)).to be true
end

Dann(/^alle andere Zugriffe auf Inventarpools bleiben beibehalten$/) do
  expect((@previous_access_rights - @user.access_rights.reload).empty?).to be true
end

Angenommen(/^man befindet sich auf der Editierseite eines Benutzers, der ein Administrator ist und der Zugriffe auf Inventarpools hat$/) do
  @user = User.find {|u| u.has_role? :admin and u.has_role? :customer}
  raise "user not found" unless @user
  @previous_access_rights = @user.access_rights.select{|ar| ar.role != :admin}.freeze
  visit manage_edit_user_path(@user)
end

Wenn(/^man diesem Benutzer die Rolle Administrator wegnimmt$/) do
  select _("No"), from: "user_admin"
end

Dann(/^hat dieser Benutzer die Rolle Administrator nicht mehr$/) do
  expect(@user.reload.has_role?(:admin)).to be false
end

Wenn(/^man versucht auf die Administrator Benutzererstellenansicht zu gehen$/) do
  @path = manage_edit_user_path(User.first)
  visit @path
end

Dann(/^gelangt man auf diese Seite nicht$/) do
  expect(current_path).not_to eq @path
end

Wenn(/^man versucht auf die Administrator Benutzereditieransicht zu gehen$/) do
  @path = "/manage/users/new"
  visit @path
end

Wenn(/^man hat nur die folgenden Rollen zur Auswahl$/) do |table|
  expect(find(".row.emboss", match: :prefer_exact, text: _("Access as")).all("option").length).to eq table.raw.length
  table.raw.flatten.each do |role|
    find(".row.emboss", match: :prefer_exact, text: _("Access as")).find("option", text: _(role))
  end
end

Angenommen(/^man editiert einen Benutzer der Kunde ist$/) do
  access_right = AccessRight.find{|ar| ar.role == :customer and ar.inventory_pool == @current_inventory_pool}
  @user = access_right.user
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @user)
end

Angenommen(/^man editiert einen Benutzer der Ausleihe-Verwalter ist$/) do
  access_right = AccessRight.find{|ar| ar.role == :lending_manager and ar.inventory_pool == @current_inventory_pool and ar.user != @current_user}
  @user = access_right.user
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @user)
end

Angenommen(/^man editiert in irgendeinem Inventarpool einen Benutzer der Kunde ist$/) do
  access_right = AccessRight.find{|ar| ar.role == :customer}
  @user = access_right.user
  @current_inventory_pool = access_right.inventory_pool
  visit manage_edit_inventory_pool_user_path(access_right.inventory_pool, @user)
end

Wenn(/^man den Zugriff auf "Kunde" ändert$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Access as")).find("select").select _("Customer")
end

Wenn(/^man den Zugriff auf "Ausleihe-Verwalter" ändert$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Access as")).find("select").select _("Lending manager")
end

Wenn(/^man den Zugriff auf "Inventar-Verwalter" ändert$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Access as")).find("select").select _("Inventory manager")
end

Dann(/^hat der Benutzer die Rolle Kunde$/) do
  expect(has_content?(_("List of Users"))).to be true
  expect(@user.reload.access_right_for(@current_inventory_pool).role).to eq :customer
end

Dann(/^hat der Benutzer die Rolle Ausleihe-Verwalter$/) do
  find_link _("New User")
  expect(@user.reload.access_right_for(@current_inventory_pool).role).to eq :lending_manager
end

Dann(/^hat der Benutzer die Rolle Inventar-Verwalter$/) do
  find("#flash .notice", text: _("User details were updated successfully."))
  find_link _("New User")
  expect(@user.reload.access_right_for(@current_inventory_pool).role).to eq :inventory_manager
end

Angenommen(/^man sucht sich einen Benutzer ohne Zugriffsrechte, Bestellungen und Verträge aus$/) do
  @user = User.find {|u| u.access_rights.active.empty? and u.contracts.empty?}
end

Wenn(/^ich diesen Benutzer aus der Liste lösche$/) do
  @user ||= @users.sample
  find("#list-search").set @user.to_s
  within("#user-list .line", text: @user.name) do
    find(".multibutton .dropdown-toggle").click
    find(".multibutton .dropdown-toggle").click
    find(".multibutton .dropdown-item.red", text: _("Delete")).click
  end
end

Dann(/^wurde der Benutzer aus der Liste gelöscht$/) do
  expect(has_no_selector?("#user-list .line", text: @user.name)).to be true
end

Dann(/^der Benutzer ist gelöscht$/) do
  find("#flash .success")
  expect(User.find_by_id(@user.id)).to eq nil
end

Dann(/^der Benutzer ist nicht gelöscht$/) do
  find("#user-list")
  step 'man bis zum Ende der Liste fährt' # loading pages (but probably only the last one)
  find("#user-list .line", text: @user.name)
  expect(User.find_by_id(@user.id)).not_to be nil
end

Angenommen(/^man befindet sich auf der Benutzerliste im beliebigen Inventarpool$/) do
  visit manage_inventory_pool_users_path(InventoryPool.first)
end

Angenommen(/^man sucht sich je einen Benutzer mit Zugriffsrechten, Bestellungen und Verträgen aus$/) do
  @users = []
  @users << User.find {|u| not u.access_rights.active.empty? and u.contracts.empty?}
  @users << User.find {|u| not u.contracts.empty?}
  @users << User.find {|u| u.contracts.empty?}
end

Dann(/^wird der Delete Button für diese Benutzer nicht angezeigt$/) do
  @users.each do |user|
    find("#list-search").set user.name
    within("#user-list .line", text: user.name) do
      find(".multibutton .dropdown-toggle").click
      expect(has_no_selector?(".multibutton .dropdown-item.red", text: _("Delete"))).to be true
    end
  end
end

Angenommen(/^man editiert einen Benutzer der Zugriff auf ein Inventarpool hat$/) do
  access_right = AccessRight.find{|ar| ar.role == :customer}
  @user = access_right.user
  @current_inventory_pool = access_right.inventory_pool
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @user)
end

Angenommen(/^man editiert einen Benutzer der Zugriff auf das aktuelle Inventarpool hat$/) do
  @user = @current_inventory_pool.access_rights.active.find{|ar| ar.role == :customer}.user
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @user)
end

Angenommen(/^man editiert einen Benutzer der Zugriff auf das aktuelle Inventarpool hat und keine Gegenstände mehr zurückzugeben hat$/) do
  @user = @current_inventory_pool.access_rights.active.select{|ar| ar.role == :customer}.detect{|ar| @current_inventory_pool.contract_lines.by_user(ar.user).to_take_back.empty?}.user
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @user)
end

Wenn(/^man den Zugriff entfernt$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Access as")).find("select").select _("No access")
end

Dann(/^hat der Benutzer keinen Zugriff auf das Inventarpool$/) do
  find_link _("New User")
  expect(@user.reload.access_right_for(@current_inventory_pool)).to eq nil
end

Dann(/^sind die Benutzer nach ihrem Vornamen alphabetisch sortiert$/) do
  within("#user-list") do
    find(".line", match: :first)
    t = if current_path == manage_users_path
          all(".line > div:nth-child(1)").map(&:text).map { |t| t.split(" ").take(2).join(" ") }
        else
          all(".line > div:nth-child(1)").map(&:text)
        end
    expect(t).to eq User.order(:firstname).paginate(page:1, per_page: 20).map(&:name)
  end
end

Und(/^man gibt die Login-Daten ein$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Login")).find("input").set "username"
  find(".row.emboss", match: :prefer_exact, text: _("Password")).find("input").set "password"
  find(".row.emboss", match: :prefer_exact, text: _("Password Confirmation")).find("input").set "password"
end

Angenommen(/^man editiert einen Benutzer der kein Zugriff auf das aktuelle Inventarpool hat$/) do
  @user = User.find {|u| u.access_rights.active.blank?}
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @user)
end

Wenn(/^man ändert die Email$/) do
  find(".row.emboss", match: :prefer_exact, text: _("E-Mail")).find("input,textarea").set "changed@test.ch"
end

Dann(/^sieht man die Erfolgsbestätigung$/) do
  expect(has_content?(_("List of Users"))).to be true
  find(".notice", match: :first)
end

Dann(/^die neue Email des Benutzers wurde gespeichert$/) do
  expect(@user.reload.email).to eq "changed@test.ch"
end

Dann(/^der Benutzer hat nach wie vor keinen Zugriff auf das aktuelle Inventarpool$/) do
  expect(@user.access_rights.active.detect{|ar| ar.inventory_pool == @current_inventory_pool}).to eq nil
end

Angenommen(/^man editiert einen Benutzer der mal einen Zugriff auf das aktuelle Inventarpool hatte$/) do
  @current_inventory_pool = (@current_user.managed_inventory_pools & AccessRight.select(&:deleted_at).map(&:inventory_pool)).sample
  @user = @current_inventory_pool.access_rights.select(&:deleted_at).map(&:user).sample
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @user)
end

Angenommen(/^man einen Benutzer mit Zugriffsrechten editiert$/) do
  @user =  User.find {|u| u.access_rights.active.count >= 2 }
  expect(@user.access_rights.active.count).to be >= 2
  visit manage_edit_user_path(@user)
end

Dann(/^werden die ihm zugeteilt Geräteparks mit entsprechender Rolle aufgelistet$/) do
  @user.access_rights.active.each do |access_right|
    find(".row.emboss .padding-inset-s", text: access_right.to_s)
  end
end

Given(/^there exists a contract with status "(.*?)" for a user with otherwise no other contracts$/) do |arg1|
  state = case arg1
          when "abgeschickt" then :submitted
          when "genehmigt" then :approved
          when "unterschrieben" then :signed
          end
  @contract = @current_inventory_pool.contracts.send(state).detect {|c| c.user.contracts.all? {|c| c.status == state}}
  expect(@contract).not_to be nil
end

When(/^I edit the user of this contract$/) do
  @user = @contract.user
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @user)
end

Then(/^this user has access to the current inventory pool$/) do
  expect(@user.access_right_for(@current_inventory_pool)).not_to be nil
end

Then(/^I see the error message "(.*?)"$/) do |arg1|
  find("#flash .error", text: _(arg1))
end
