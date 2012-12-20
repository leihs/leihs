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