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
  step "I am logged in as '%s' with password 'password'" % "mike"
end

Dann /^findet man die Benutzeradministration im Bereich "Administration" unter "Benutzer"$/ do
  step 'I follow "Admin"'
  step 'I follow "Users"'
end

Dann /^sieht man eine Liste aller Benutzer$/ do
  pending # express the regexp above with the code you wish you had
end

Dann /^man kann filtern nach den folgenden Eigenschaften: gesperrt$/ do
  pending # express the regexp above with the code you wish you had
end

Dann /^man kann filtern nach den folgenden Rollen: Keine, Kunde, Ausleihe\-Verwalter, Inventar\-Verwalter, Administrator$/ do
  pending # express the regexp above with the code you wish you had
end

Dann /^man kann für jeden Benutzer die Editieransicht aufrufen$/ do
  pending # express the regexp above with the code you wish you had
end

Dann /^man kann einen neuen Benutzer erstellen$/ do
  pending # express the regexp above with the code you wish you had
end
