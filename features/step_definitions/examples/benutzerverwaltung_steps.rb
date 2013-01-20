# -*- encoding : utf-8 -*-

Angenommen /^ein Benutzer hat aus der leihs 2.0-Datenbank den Level 1 auf einem Gerätepark$/ do
  step "I am logged in as '%s' with password 'password'" % "assist"
  ar = @user.access_rights.where(:access_level => 1).first
  ar.should_not be_nil
  @inventory_pool = ar.inventory_pool
end

Dann /^gilt er in leihs 3.0 als Level 2 für diesen Gerätepark$/ do
  @user.has_at_least_access_level(2, @inventory_pool).should be_true
end

Angenommen /^man ist Inventar\-Verwalter oder Ausleihe\-Verwalter$/ do
  ar = @user.access_rights.where(:access_level => [2, 3]).first
  ar.should_not be_nil
  @inventory_pool = ar.inventory_pool
end

Dann /^findet man die Benutzeradministration im Bereich "Administration" unter "Benutzer"$/ do
  step 'I follow "Admin"'
  step 'I follow "%s"' % _("Users")
end

Dann /^sieht man eine Liste aller Benutzer$/ do
  c = @inventory_pool.users.count
  page.should have_content("List of %d Users" % c)
end

Dann /^man kann filtern nach den folgenden Eigenschaften: gesperrt$/ do
  find("[ng-model='suspended']").click
  c = @inventory_pool.suspended_users.count
  page.should have_content("List of %d Users" % c)

  find("[ng-model='suspended']").click
  c = @inventory_pool.users.count
  page.should have_content("List of %d Users" % c)
end

Dann /^man kann filtern nach den folgenden Rollen:$/ do |table|
  table.hashes.each do |row|
    step 'I follow "%s"' % row["tab"]
    role = row["role"]
    c = case role
          when "admins"
            User.admins
          when "unknown"
            User.where("users.id NOT IN (#{@inventory_pool.users.select("users.id").to_sql})")
          else
            users = @inventory_pool.users
            case role
              when "customers", "lending_managers", "inventory_managers"
                users.send(role)
              else
                users
            end
        end.count
    page.should have_content("List of %d Users" % c)
  end
end

Dann /^man kann für jeden Benutzer die Editieransicht aufrufen$/ do
  step 'I follow "%s"' % "All"
  el = find(".list ul.user")
  page.execute_script '$(":hidden").show();'
  el.find(".actions .alternatives .button .icon.user")
end

Dann /^man kann einen neuen Benutzer erstellen$/ do
  find(".top .content_navigation .button .icon.user")
end

####################################################################

Angenommen /^man editiert einen Benutzer$/ do
  #visit edit_backend_inventory_pool_user_path(@inventory_pool, @inventory_pool.users.first)
  pending
end

Angenommen /^man nutzt die Sperrfunktion$/ do
  pending # express the regexp above with the code you wish you had
end

Dann /^muss man den Grund der Sperrung eingeben$/ do
  pending # express the regexp above with the code you wish you had
end

Dann /^man muss das Enddatum der Sperrung bestimmen$/ do
  pending # express the regexp above with the code you wish you had
end

Dann /^sofern der Benutzer gesperrt ist, kann man die Sperrung aufheben$/ do
  pending # express the regexp above with the code you wish you had
end

####################################################################

Angenommen /^ein Benutzer erscheint in einer Benutzerliste$/ do
  step 'man ist Inventar-Verwalter oder Ausleihe-Verwalter'
  step 'findet man die Benutzeradministration im Bereich "Administration" unter "Benutzer"'
  step 'I follow "%s"' % _("Customer")
  find(".list ul.user .user_name")
end

Dann /^sieht man folgende Informationen in folgender Reihenfolge: Vorname, Name, Telefonnummer, Rolle, Sperr\-Status$/ do
  el = find(".list ul.user")
  el.find(".user_name + .phone + .role + .suspended_status")
end