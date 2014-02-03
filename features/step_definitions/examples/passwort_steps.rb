# encoding: utf-8

def fill_in_required_user_information
  find(".row.emboss", match: :prefer_exact, text: _("Last name")).find("input").set "test"
  find(".row.emboss", match: :prefer_exact, text: _("First name")).find("input").set "test"
  find(".row.emboss", match: :prefer_exact, text: _("E-Mail")).find("input").set "test@test.ch"
end

Angenommen(/^man befindet sich auf der Benutzerliste$/) do
  if @current_user == User.find_by_login("gino")
    step "man befindet sich auf der Benutzerliste ausserhalb der Inventarpools"
  else
    @inventory_pool = @current_user.inventory_pools.first
    visit manage_inventory_pool_users_path(@inventory_pool)
  end
end

Wenn(/^ich einen Benutzer mit Login "(.*?)" und Passwort "(.*?)" erstellt habe$/) do |login, password|
  step "man einen Benutzer hinzufügt"
  fill_in_required_user_information

  find(".row.emboss", match: :prefer_exact, text: _("Login")).find("input").set "#{@login = login}"
  find(".row.emboss", match: :prefer_exact, text: _("Password")).find("input").set "#{@password = password}"
  find(".row.emboss", match: :prefer_exact, text: _("Password Confirmation")).find("input").set "#{password}"

  click_button _("Save")
  page.has_content? _("List of Users")
  @user = User.find_by_login "#{@login}"
  DatabaseAuthentication.find_by_user_id(@user.id).should_not be_nil
end

Wenn(/^der Benutzer hat Zugriff auf ein Inventarpool$/) do
  attributes = {user_id: @user.id, inventory_pool_id: @inventory_pool.try(:id) || InventoryPool.first.id, role: :customer}
  AccessRight.create(attributes) unless AccessRight.where(attributes).first
end

Dann(/^kann sich der Benutzer "(.*?)" mit "(.*?)" anmelden$/) do |login, password|
  step 'I make sure I am logged out'
  visit login_path
  step %Q{I fill in "username" with "#{login}"}
  step %Q{I fill in "password" with "#{password}"}
  step 'I press "Login"'
  page.should have_content @user.name
end

Wenn(/^ich das Passwort von "(.*?)" auf "(.*?)" ändere$/) do |persona, new_password|
  find(".row.emboss", match: :prefer_exact, text: _("Password")).find("input").set "#{@password = new_password}"
  find(".row.emboss", match: :prefer_exact, text: _("Password Confirmation")).find("input").set "#{new_password}"

  step "man speichert den Benutzer"
  page.has_content? _("List of Users")
  @user = User.find_by_login "#{User.find_by_login("normin").login}"
  DatabaseAuthentication.find_by_user_id(@user.id).should_not be_nil
end

Angenommen(/^man befindet sich auf der Benutzereditieransicht von "(.*?)"$/) do |persona|
  step 'persona "%s" existing' % persona
  @user = User.find_by_firstname persona
  if @current_user.access_rights.active.map(&:role).include? :admin
    visit manage_edit_user_path @user
  else
    visit manage_edit_inventory_pool_user_path((@user.inventory_pools & @current_user.managed_inventory_pools).first, @user)
  end
  sleep(0.88)
end

Wenn(/^ich den Benutzernamen auf "(.*?)" und das Passwort auf "(.*?)" ändere$/) do |new_username, new_password|
  find(".row.emboss", match: :prefer_exact, text: _("Login")).find("input").set "#{@login = new_username}"
  find(".row.emboss", match: :prefer_exact, text: _("Password")).find("input").set "#{@password = new_password}"
  find(".row.emboss", match: :prefer_exact, text: _("Password Confirmation")).find("input").set "#{new_password}"

  step "man speichert den Benutzer"
  page.has_content? _("List of Users")
  @user = User.find_by_login "#{@login}"
  DatabaseAuthentication.find_by_user_id(@user.id).should_not be_nil
end

Wenn(/^ich den Benutzernamen von "(.*?)" auf "(.*?)" ändere$/) do |person, new_username|
  find(".row.emboss", match: :prefer_exact, text: _("Login")).find("input").set "#{@login = new_username}"

  step "man speichert den Benutzer"
  page.has_content? _("List of Users")
  @user = User.find_by_login @login
  DatabaseAuthentication.find_by_user_id(@user.id).should_not be_nil
end

Wenn(/^ich einen Benutzer ohne Loginnamen erstellen probiere$/) do
  step "man einen Benutzer hinzufügt"
  fill_in_required_user_information

  find(".row.emboss", match: :prefer_exact, text: _("Password")).find("input").set "newpassword}"
  find(".row.emboss", match: :prefer_exact, text: _("Password Confirmation")).find("input").set "newpassword"

  click_button _("Save")
end

Wenn(/^ich einen Benutzer mit falscher Passwort\-Bestätigung erstellen probiere$/) do
  step "man einen Benutzer hinzufügt"
  fill_in_required_user_information

  find(".row.emboss", match: :prefer_exact, text: _("Login")).find("input").set "new_username"
  find(".row.emboss", match: :prefer_exact, text: _("Password")).find("input").set "newpassword"
  find(".row.emboss", match: :prefer_exact, text: _("Password Confirmation")).find("input").set "wrongconfir"

  click_button _("Save")
end

Wenn(/^ich einen Benutzer mit fehlenden Passwortangaben erstellen probiere$/) do
  step "man einen Benutzer hinzufügt"
  fill_in_required_user_information
  find(".row.emboss", match: :prefer_exact, text: _("Login")).find("input").set "new_username"
  click_button _("Save")
end

Wenn(/^ich den Benutzernamen von nicht ausfülle und speichere$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Login")).find("input").set "a"
  find(".row.emboss", match: :prefer_exact, text: _("Password")).find("input").set "newpassword"
  find(".row.emboss", match: :prefer_exact, text: _("Password Confirmation")).find("input").set "newpassword"
  step "man speichert den Benutzer"
end

Wenn(/^ich eine falsche Passwort\-Bestägigung eingebe und speichere$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Login")).find("input").set "newlogin"
  find(".row.emboss", match: :prefer_exact, text: _("Password")).find("input").set "newpassword"
  find(".row.emboss", match: :prefer_exact, text: _("Password Confirmation")).find("input").set "newpasswordxyz"
  step "man speichert den Benutzer"
end

Wenn(/^ich die Passwort\-Angaben nicht eingebe und speichere$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Login")).find("input").set "newlogin"
  find(".row.emboss", match: :prefer_exact, text: _("Password")).find("input").set " "
  find(".row.emboss", match: :prefer_exact, text: _("Password Confirmation")).find("input").set " "
  step "man speichert den Benutzer"
end
