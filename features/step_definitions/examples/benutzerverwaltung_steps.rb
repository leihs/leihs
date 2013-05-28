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
  c = User.count
  page.should have_content(_("List of %d Users") % c)
end

Dann /^man kann filtern nach "(.*?)" Rolle$/ do |role|
  find(".inlinetabs > .tab", :text => role).click
end

Dann /^man kann filtern nach den folgenden Eigenschaften: gesperrt$/ do
  step 'man kann filtern nach "%s" Rolle' % _("Customer")
  wait_until { all(".loading", :visible => true).empty? }

  find("[ng-model='suspended']").click
  wait_until { all(".loading", :visible => true).empty? }
  c = @inventory_pool.suspended_users.customers.count
  page.should have_content(_("List of %d Users") % c)

  find("[ng-model='suspended']").click
  wait_until { all(".loading", :visible => true).empty? }
  c = @inventory_pool.users.customers.count
  page.should have_content(_("List of %d Users") % c)
end

Dann /^man kann filtern nach den folgenden Rollen:$/ do |table|
  table.hashes.each do |row|
    step 'man kann filtern nach "%s" Rolle' % row["tab"]
    role = row["role"]
    c = case role
          when "admins"
            User.admins
          when "unknown"
            User.where("users.id NOT IN (#{@inventory_pool.users.select("users.id").to_sql})")
          when "customers", "lending_managers", "inventory_managers"
            @inventory_pool.users.send(role)
          else
            User.scoped
        end.count
    wait_until { all(".loading", :visible => true).empty? }
    page.should have_content(_("List of %d Users") % c)
  end
end

Dann /^man kann für jeden Benutzer die Editieransicht aufrufen$/ do
  step 'man kann filtern nach "%s" Rolle' % "All"
  el = find(".list ul.user")
  page.execute_script '$(":hidden").show();'
  el.find(".actions .alternatives .button .icon.user")
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

Dann /^man muss das Enddatum der Sperrung bestimmen$/ do
  find(".content_navigation > button.green").click
  wait_until { find(".button.white", :text => _("Edit %s") % _("User")) }
  current_path.should == backend_inventory_pool_user_path(@inventory_pool, @customer)
  @inventory_pool.suspended_users.find_by_id(@customer.id).should_not be_nil
  @customer.access_right_for(@inventory_pool).suspended?.should be_true
end

Dann /^sofern der Benutzer gesperrt ist, kann man die Sperrung aufheben$/ do
  visit edit_backend_inventory_pool_user_path(@inventory_pool, @customer)
  find("[ng-model='user.access_right.suspended_until']").set("")
  find(".content_navigation > button.green").click
  wait_until { find(".button.white", :text => _("Edit %s") % _("User")) }
  current_path.should == backend_inventory_pool_user_path(@inventory_pool, @customer)
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
    all(".readonly span.ng-binding").size.should == 8
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
  response = post backend_inventory_pool_items_path(@inventory_pool, format: :json), item: attributes
  response.should be_successful
  @json = JSON.parse response.body
  @json["id"].should_not be_blank
  Item.count.should == c+1
end

Dann /^diese Gegenstände ausschliesslich nicht inventarrelevant sind$/ do
  @json["is_inventory_relevant"].should be_false
  response = put backend_inventory_pool_item_path(@inventory_pool, @json["id"], format: :json), item: {is_inventory_relevant: true}
  response.should_not be_successful
  Item.find(@json["id"]).is_inventory_relevant.should be_false
end

Dann /^diese Gegenstände können inventarrelevant sein$/ do
  @json["is_inventory_relevant"].should be_false
  response = put backend_inventory_pool_item_path(@inventory_pool, @json["id"], format: :json), item: {is_inventory_relevant: true}
  json = JSON.parse response.body
  response.should be_successful
  json["is_inventory_relevant"].should be_true
  @item = Item.find(@json["id"])
  @item.is_inventory_relevant.should be_true
end

Dann /^man kann Optionen erstellen$/ do
  c = Option.count
  factory_attributes = FactoryGirl.attributes_for(:option)
  attributes = {
    inventory_code: factory_attributes[:inventory_code],
    name: factory_attributes[:name],
    price: factory_attributes[:price]
  }
  response = post backend_inventory_pool_options_path(@inventory_pool, format: :json), option: attributes
  response.should be_successful
  json = JSON.parse response.body
  Option.exists?(json["id"]).should be_true
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
                 post backend_inventory_pool_users_path(@inventory_pool), user: attributes
               when "ohne"
                 post backend_users_path, user: attributes
             end
  response.should be_redirect
  User.count.should == c+1
  id = (User.pluck(:id) - ids).first
  case arg1
    when "für"
      URI.parse(response.location).path.should == backend_inventory_pool_user_path(@inventory_pool, id)
    when "ohne"
      URI.parse(response.location).path.should == backend_user_path(id)
  end
  @user = User.find(id)
end

Dann /^man kann neue Benutzer erstellen und für die Ausleihe sperren$/ do
  step 'man kann neue Benutzer erstellen für inventory_pool'
  @user.access_right_for(@inventory_pool).suspended?.should be_false
  response = put backend_inventory_pool_user_path(@inventory_pool, @user, format: :json), access_right: {suspended_until: Date.today + 1.year, suspended_reason: "suspended reason"}
  response.should be_successful
  @user.reload.access_right_for(@inventory_pool).suspended?.should be_true
end

Dann /^man kann Benutzern die folgende Rollen zuweisen und wegnehmen, wobei diese immer auf den Gerätepark bezogen ist, für den auch der Verwalter berechtigt ist$/ do |table|
  table.hashes.map do |x|
    role_name = case x[:role]
                  when _("Customer")
                    "customer"
                  when _("Lending manager")
                    "lending_manager"
                  when _("Inventory manager")
                    "inventory_manager"
                  #when _("Unknown")
                  #  "unknown"
                end

    unknown_user = User.unknown_for(@inventory_pool).order("RAND()").first

    case role_name
      when "customer"
        unknown_user.has_role?("customer", @inventory_pool).should be_false
      when "lending_manager"
        unknown_user.has_role?("manager", @inventory_pool).should be_false
      when "inventory_manager"
        unknown_user.has_role?("manager", @inventory_pool).should be_false
    end

    response = put backend_inventory_pool_user_path(@inventory_pool, unknown_user, format: :json), access_right: {role_name: role_name, suspended_until: nil}
    response.should be_successful
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

    response = put backend_inventory_pool_user_path(@inventory_pool, unknown_user, format: :json), access_right: {role_name: "unknown"}
    response.should be_successful
    case role_name
      when "customer"
        unknown_user.has_role?("customer", @inventory_pool).should be_false
      when "lending_manager"
        unknown_user.has_role?("manager", @inventory_pool).should be_false
      when "inventory_manager"
        unknown_user.has_role?("manager", @inventory_pool).should be_false
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
  response = put backend_inventory_pool_item_path(@inventory_pool, item, format: :json), item: attributes
  response.should be_successful
  item.reload.retired?.should be_true
  item.retired.should == Date.today
end

####################################################################

Dann /^kann man neue Modelle erstellen$/ do
  c = Model.count
  attributes = FactoryGirl.attributes_for :model
  response = post backend_inventory_pool_models_path(@inventory_pool, format: :json), model: attributes
  response.should be_successful
  json = JSON.parse response.body
  json["id"].should_not be_blank
  Model.count.should == c+1
end

Dann /^man kann sie einem anderen Gerätepark als Besitzer zuweisen$/ do
  attributes = {
    owner_id: (InventoryPool.pluck(:id) - [@inventory_pool.id]).shuffle.first
  }
  @item.owner_id.should_not == attributes[:owner_id]
  response = put backend_inventory_pool_item_path(@inventory_pool, @item, format: :json), item: attributes
  response.should be_successful
  @item.reload.owner_id.should == attributes[:owner_id]
end

Dann /^man kann die verantwortliche Abteilung eines Gegenstands frei wählen$/ do
  item = @inventory_pool.own_items.first
  attributes = {
      inventory_pool_id: (InventoryPool.pluck(:id) - [@inventory_pool.id]).shuffle.first
  }
  item.inventory_pool_id.should_not == attributes[:inventory_pool_id]
  response = put backend_inventory_pool_item_path(@inventory_pool, item, format: :json), item: attributes
  response.should be_successful
  item.reload.inventory_pool_id.should == attributes[:inventory_pool_id]

  attributes = {
      inventory_pool_id: nil
  }
  item.inventory_pool_id.should_not == attributes[:inventory_pool_id]
  response = put backend_inventory_pool_item_path(@inventory_pool, item, format: :json), item: attributes
  response.should be_successful
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
  response = put backend_inventory_pool_item_path(@inventory_pool, item, format: :json), item: attributes
  response.should be_successful
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
  response = put backend_inventory_pool_item_path(@inventory_pool, item, format: :json), item: attributes
  response.should be_successful
  item.reload.retired.should be_nil
  item.retired_reason.should be_nil
end

Dann /^man kann die Arbeitstage und Ferientage seines Geräteparks anpassen$/ do
  %w(saturday sunday).each do |day|
    @inventory_pool.workday.send(day).should be_false
    get open_backend_inventory_pool_workdays_path(@inventory_pool, :day => day)
    @inventory_pool.workday.reload.send(day).should be_true
  end

  %w(monday tuesday).each do |day|
    @inventory_pool.workday.send(day).should be_true
    get close_backend_inventory_pool_workdays_path(@inventory_pool, :day => day)
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
  response = post backend_inventory_pools_path, inventory_pool: attributes
  response.should be_redirect
  InventoryPool.count.should == c+1
  id = (InventoryPool.pluck(:id) - ids).first
  URI.parse(response.location).path.should == backend_inventory_pools_path
end

Dann /^man kann neue Benutzer erstellen und löschen$/ do
  step 'man kann neue Benutzer erstellen ohne inventory_pool'
  response = delete backend_user_path(@user, format: :json)
  response.should be_successful
  assert_raises(ActiveRecord::RecordNotFound) do
    @user.reload
  end
end

Dann /^man kann Benutzern jegliche Rollen zuweisen und wegnehmen$/ do
  user = Persona.get "Normin"
  inventory_pool = InventoryPool.find_by_name "IT-Ausleihe"
  user.has_at_least_access_level(3, inventory_pool).should be_false

  response = put backend_user_path(user, format: :json), access_right: {inventory_pool_id: inventory_pool.id, role_name: "inventory_manager"}
  response.should be_successful
  user.has_at_least_access_level(3, inventory_pool).should be_true
  user.access_right_for(inventory_pool).deleted_at.should be_nil

  response = put backend_user_path(user, format: :json), access_right: {inventory_pool_id: inventory_pool.id, role_name: "unknown"}
  response.should be_successful
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
