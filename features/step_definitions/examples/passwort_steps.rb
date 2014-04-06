# encoding: utf-8

def fill_in_user_information(attrs)
  find(".row.emboss", match: :prefer_exact, text: _("Last name")).find("input").set attrs[:firstname] if attrs[:lastname]
  find(".row.emboss", match: :prefer_exact, text: _("First name")).find("input").set attrs[:firstname] if attrs[:firstname]
  find(".row.emboss", match: :prefer_exact, text: _("E-Mail")).find("input").set attrs[:email] if attrs[:email]
  find(".row.emboss", match: :prefer_exact, text: _("Login")).find("input").set attrs[:login] if attrs[:login]
  find(".row.emboss", match: :prefer_exact, text: _("Password")).find("input").set attrs[:password] if attrs[:password]
  find(".row.emboss", match: :prefer_exact, text: _("Password Confirmation")).find("input").set attrs[:password_confirmation] if attrs[:password_confirmation]
  click_button _("Save")
end

Angenommen(/^man befindet sich auf der Benutzerliste$/) do
  if @current_user == User.find_by_login("gino")
    step "man befindet sich auf der Benutzerliste ausserhalb der Inventarpools"
  else
    @inventory_pool = @current_inventory_pool || @current_user.inventory_pools.sample
    visit manage_inventory_pool_users_path(@inventory_pool)
  end
end

Wenn(/^ich einen Benutzer mit Login "(.*?)" und Passwort "(.*?)" erstellt habe$/) do |login, password|
  step "man einen Benutzer hinzufügt"
  fill_in_user_information(firstname: "test", lastname: "test", email: "test@test.ch", login: login, password: password, password_confirmation: password)
  page.has_content? _("List of Users")
  @user = User.find_by_login login
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
  page.should have_content @user.short_name
end

Wenn(/^ich das Passwort von "(.*?)" auf "(.*?)" ändere$/) do |persona, password|
  fill_in_user_information(password: password, password_confirmation: password)
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
  sleep(0.66)
end

Wenn(/^ich den Benutzernamen auf "(.*?)" und das Passwort auf "(.*?)" ändere$/) do |login, password|
  fill_in_user_information(login: login, password: password, password_confirmation: password)
  page.has_content? _("List of Users")
  @user = User.find_by_login login
  DatabaseAuthentication.find_by_user_id(@user.id).should_not be_nil
end

Wenn(/^ich den Benutzernamen von "(.*?)" auf "(.*?)" ändere$/) do |person, login|
  fill_in_user_information(login: login)
  page.has_content? _("List of Users")
  @user = User.find_by_login login
  DatabaseAuthentication.find_by_user_id(@user.id).should_not be_nil
end

Wenn(/^ich einen Benutzer ohne Loginnamen erstellen probiere$/) do
  step "man einen Benutzer hinzufügt"
  fill_in_user_information(firstname: "test", lastname: "test", email: "test@test.ch", password: "newpassword", password_confirmation: "newpassword")
end

Wenn(/^ich einen Benutzer mit falscher Passwort\-Bestätigung erstellen probiere$/) do
  step "man einen Benutzer hinzufügt"
  fill_in_user_information(firstname: "test", lastname: "test", email: "test@test.ch", login: "new_username", password: "newpassword", password_confirmation: "wrongconfir")
end

Wenn(/^ich einen Benutzer mit fehlenden Passwortangaben erstellen probiere$/) do
  step "man einen Benutzer hinzufügt"
  fill_in_user_information(firstname: "test", lastname: "test", email: "test@test.ch", login: "new_username")
end

Wenn(/^ich den Benutzernamen von nicht ausfülle und speichere$/) do
  fill_in_user_information(login: "a", password: "newpassword", password_confirmation: "newpassword")
end

Wenn(/^ich eine falsche Passwort\-Bestägigung eingebe und speichere$/) do
  fill_in_user_information(login: "newlogin", password: "newpassword", password_confirmation: "newpasswordxyz")
end

Wenn(/^ich die Passwort\-Angaben nicht eingebe und speichere$/) do
  fill_in_user_information(login: "newlogin", password: " ", password_confirmation: " ")
end
