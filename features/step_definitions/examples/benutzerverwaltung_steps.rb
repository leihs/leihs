# -*- encoding : utf-8 -*-



#Angenommen /^man ist Inventar\-Verwalter oder Ausleihe\-Verwalter$/ do
Given(/^I am inventory manager or lending manager$/) do
  step 'I am %s' % ['Mike', 'Pius'].sample
  ar = @current_user.access_rights.active.where(role: [:lending_manager, :inventory_manager]).first
  expect(ar).not_to be_nil
  @inventory_pool = ar.inventory_pool
end

#Angenommen /^man ist Ausleihe\-Verwalter$/ do
Given(/^I am a lending manager$/) do
  step 'I am %s' % 'Pius'
  ar = @current_user.access_rights.active.where(role: :lending_manager).first
  expect(ar).not_to be_nil
  @inventory_pool = ar.inventory_pool
end

Given(/^I am an inventory manager$/) do
  step 'I am %s' % 'Mike'
  ar = @current_user.access_rights.active.where(role: :inventory_manager).first
  expect(ar).not_to be_nil
  @inventory_pool = ar.inventory_pool
end

# Angenommen /^man ist Administrator$/ do
#   step 'I am %s' % "Ramon"
# end

####################################################################

def check_user_list(users)
  expect(has_content?(_('List of Users'))).to be true
  within '#user-list' do
    step 'I scroll loading all pages'
    users.each do |user|
      find(".line [data-id='#{user.id}']", match: :prefer_exact, text: user.name)
    end
  end
end

#Dann /^sieht man eine Liste aller Benutzer$/ do
Then /^I see a list of all users$/ do
  users = User.order('firstname ASC').paginate(page: 1, per_page: 20)
  check_user_list(users)
end

#Dann /^man kann filtern nach "(.*?)" Rolle$/ do |role|
Then /^I can filter by the role "(.*?)"$/ do |role|
  find('#user-index-view .inline-tab-navigation .inline-tab-item', text: role).click
end


#Dann /^man kann filtern nach den folgenden Eigenschaften: gesperrt$/ do
Then /^I can filter to see only suspended users$/ do
  step 'I can filter by the role "%s"' % _('Customer')

  find("#list-filters [type='checkbox'][name='suspended']").click
  users = @inventory_pool.suspended_users.customers.paginate(page: 1, per_page: 20)
  check_user_list(users)

  find("#list-filters [type='checkbox'][name='suspended']").click
  users = @inventory_pool.users.customers.paginate(page: 1, per_page: 20)
  check_user_list(users)
end

#Dann /^man kann filtern nach den folgenden Rollen:$/ do |table|
Then /^I can filter by the following roles:$/ do |table|
  table.hashes.each do |row|
    step 'I can filter by the role "%s"' % row['tab']
    role = row['role']
    users = case role
              when 'admins'
                User.admins
              when 'no_access'
                User.where("users.id NOT IN (#{@inventory_pool.users.select("users.id").to_sql})")
              when 'customers', 'lending_managers', 'inventory_managers'
                @inventory_pool.users.send(role)
              else
                User.all
            end.paginate(page: 1, per_page: 20)
    check_user_list(users)
  end
end

#Dann /^man kann für jeden Benutzer die Editieransicht aufrufen$/ do
Then /^I can open the edit view for each user$/ do
  step 'I can filter by the role "%s"' % 'All'
  expect(has_selector?("#user-list [data-type='user-cell']")).to be true
  all('#user-list > .line').sample(5).each do |line|
    within line.find('.multibutton') do
      if has_selector?('.button', text: _('Edit'))
        find('.button', text: _('Edit'))
      else
        find('.dropdown-toggle').click
        find('.dropdown-item', text: _('Edit'))
      end
    end
    find('body').click
  end
end

# Dann(/^man kann einen neuen Benutzer erstellen$/) do
#   find(".top .content_navigation .button .icon.user")
# end

####################################################################

#Angenommen /^man editiert einen (Benutzer|Delegation)$/ do |arg1|
Given(/^I edit a (user|delegation)$/) do |user_type|
  @inventory_pool ||= @current_user.inventory_pools.managed.first
  @customer = case user_type
                when 'delegation'
                  @inventory_pool.users.customers.as_delegations

                when 'user'
                  @inventory_pool.users.customers.not_as_delegations
              end.order('RAND()').first
  @delegation = @customer # Some of the delegation tests expect this to be defined
  visit manage_edit_inventory_pool_user_path(@inventory_pool, @customer)
end

#Angenommen /^man nutzt die Sperrfunktion$/ do
When(/^I use the suspend feature$/) do
  el = find('[data-suspended-until-input]')
  el.click
  date_s = (Date.today+1.month).strftime('%d/%m/%Y') # Use UK date format (from en-GB)
  el.set(date_s)
  find('.ui-state-active').click
end

#Dann /^muss man den Grund der Sperrung eingeben$/ do
Then(/^I have to specify a reason for suspension$/) do
  el = find("[name='access_right[suspended_reason]']")
  el.click
  el.set('this is the reason')
end

#Dann /^sofern der (Benutzer|Delegation) gesperrt ist, kann man die Sperrung aufheben$/ do |arg1|
Then /^if the (user|delegation) is suspended, I can remove the suspension$/ do |arg1|
  visit manage_edit_inventory_pool_user_path(@inventory_pool, @customer)
  find('[data-suspended-until-input]').set('')
  find('.button', text: _('Save')).click
  find('.button.white', text: _('New User'))
  expect(current_path).to eq manage_inventory_pool_users_path(@inventory_pool)
  expect(@inventory_pool.suspended_users.find_by_id(@customer.id)).to eq nil
  expect(@inventory_pool.users.find_by_id(@customer.id)).not_to be_nil
  expect(@customer.access_right_for(@inventory_pool).suspended?).to be false
end

####################################################################

Then /^I can find the user administration features in the "Admin" area under "Users"$/ do
  step 'I navigate to the admin area'
  step "I open the tab '%s'" % _('Users')
end

#Angenommen /^ein (.*?)Benutzer (mit zugeteilter|ohne zugeteilte) Rolle erscheint in einer Benutzerliste$/ do |arg1, arg2|
Given /^a (.*?)user (with|without) assigned role appears in the user list$/ do |suspended, with_or_without|
  user = User.where(login: 'normin').first
  case suspended
    when 'suspended '
      user.access_rights.active.first.update_attributes(suspended_until: Date.today + 1.year, suspended_reason: 'suspended reason')
  end
  case with_or_without
    when 'with'
      expect(user.access_rights.active.empty?).to be false
    when 'without'
      user.access_rights.active.delete_all
      expect(user.access_rights.active.empty?).to be true
  end
  step %Q(I can find the user administration features in the "Admin" area under "Users")
  within '#user-list' do
    step 'I scroll loading all pages'
    @el = find('.line', match: :prefer_exact, text: user.name)
  end
end

#Dann /^sieht man folgende Informationen in folgender Reihenfolge:$/ do |table|
Then /^I see the following information, in order:$/ do |table|
  user = User.find @el.find('[data-id]')['data-id']
  access_right = user.access_right_for(@inventory_pool)

  strings = table.hashes.map do |x|
    case x[:attr]
      when 'First name/last name'
        user.name
      when 'Phone number'
        user.phone
      when 'Role'
        role = access_right.try(:role) || 'no access'
        _(role.to_s.humanize)
      when 'Suspended until dd.mm.yyyy'
        "#{_("Suspended until")} %s" % I18n.l(access_right.suspended_until)
    end
  end
  expect(@el.text).to match Regexp.new(strings.join('.*'))
end

####################################################################


#Then /^sieht man als Titel den Vornamen und Namen des Benutzers, sofern bereits vorhanden$/ do
Then /^the user's first and last name are used as a title$/ do
  find('h1.headline-l', text: @customer.to_s)
end

#Dann /^sieht man die folgenden Daten des Benutzers in der folgenden Reihenfolge:$/ do |table|
Then /^I see the following information about the user, in order:$/ do |table|
  values = table.hashes.map do |x|
    _(x[:en])
  end
  expect(page.text).to match Regexp.new(values.join('.*'), Regexp::MULTILINE)
end

#Dann /^sieht man die Sperrfunktion für diesen Benutzer$/ do
Then /^I see the suspend button for this user$/ do
  find('[data-suspended-until-input]')
end

#Dann /^sofern dieser Benutzer gesperrt ist, sieht man Grund und Dauer der Sperrung$/ do
Then /^I see reason and duration of suspension for this user, if they are suspended$/ do
  if @customer.access_right_for(@inventory_pool).suspended?
    find("[name='access_right[suspended_reason]']")
  end
end

#Dann /^man kann die Informationen ändern, sofern es sich um einen externen Benutzer handelt$/ do
Then /^I can change this user's information, as long as they use local database authentication and not another adapter$/ do
  if @customer.authentication_system.class_name == 'DatabaseAuthentication'
    @attrs = [:lastname, :firstname, :address, :zip, :city, :country, :phone, :email]
    @attrs.each do |attr|
      orig_value = @customer.send(attr)
      field = find("input[name='user[#{attr}]']")
      #f = find("input[ng-model='user.#{attr}']") # This never worked?
      expect(field.value).to eq orig_value.to_s
      field.set("#{attr}#{orig_value}")
    end
  end
end

#Dann /^man kann die Informationen nicht verändern, sofern es sich um einen Benutzer handelt, der über ein externes Authentifizierungssystem eingerichtet wurde$/ do
Then /^I cannot change this user's information if they use something other than local database authentication$/ do
  if @customer.authentication_system.class_name != 'DatabaseAuthentication'
  end
end

#Dann /^man sieht die Rollen des Benutzers und kann diese entsprechend seiner Rolle verändern$/ do
Then /^I see the user's role and can change them depending on my own role$/ do
  find("select[name='access_right[role]']")
end


#Dann /^man kann die vorgenommenen Änderungen abspeichern$/ do
Then /^my changes are saved if I save the user$/ do
  step 'I save'
  if @customer.authentication_system.class_name == 'DatabaseAuthentication'
    @customer.reload
    @attrs.each do |attr|
      expect(@customer.send(attr)).to match /^#{attr}/
    end
  end
end

####################################################################

#Dann /^kann man neue Gegenstände erstellen$/ do
Then(/^I can create new items$/) do
  c = Item.count
  attributes = {
      model_id: @inventory_pool.models.first.id
  }
  expect(page.driver.browser.process(:post, manage_create_item_path(@inventory_pool, format: :json), {item: attributes}).successful?).to be true
  expect(Item.count).to eq c+1
  @item = Item.last
end

#Dann /^diese Gegenstände ausschliesslich nicht inventarrelevant sind$/ do
Then(/^these items cannot be inventory relevant$/) do
  expect(page.driver.browser.process(:put, manage_update_item_path(@inventory_pool, @item.id, format: :json), {item: {is_inventory_relevant: true}}).successful?).to be false
end

#Dann /^diese Gegenstände können inventarrelevant sein$/ do
Then(/^these items can be inventory relevant$/) do
  expect(page.driver.browser.process(:put, manage_update_item_path(@inventory_pool, @item.id, format: :json), item: {is_inventory_relevant: true}).successful?).to be true
  expect(@item.reload.is_inventory_relevant).to be true
end

#Dann /^man kann Optionen erstellen$/ do
Then(/^I can create options$/) do
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
               when 'für'
                 page.driver.browser.process(:post, manage_inventory_pool_users_path(@inventory_pool), user: attributes, access_right: {role: :customer}, db_auth: {login: attributes[:login], password: 'password', password_confirmation: 'password'})
               when 'ohne'
                 page.driver.browser.process(:post, manage_users_path, user: attributes)
             end
  expect(User.count).to eq c+1
  id = (User.pluck(:id) - ids).first
  @user = User.find(id)
end

#Dann /^man kann neue Benutzer erstellen und für die Ausleihe sperren$/ do
Then(/^I can create and suspend users$/) do
  step 'man kann neue Benutzer erstellen für inventory_pool'
  expect(@user.access_right_for(@inventory_pool).suspended?).to be false
  expect(page.driver.browser.process(:put, manage_update_inventory_pool_user_path(@inventory_pool, @user, format: :json), access_right: {suspended_until: Date.today + 1.year, suspended_reason: 'suspended reason'}).successful?).to be true
  expect(@user.reload.access_right_for(@inventory_pool).suspended?).to be true
end

#Dann /^man kann Benutzern die folgende Rollen zuweisen und wegnehmen, wobei diese immer auf den Gerätepark bezogen ist, für den auch der Verwalter berechtigt ist$/ do |table|
Then(/^I can assign and remove roles to and from users as specified in the following table, but only in the inventory pool for which I am manager$/) do |table|
  table.hashes.map do |x|
    unknown_user = User.order('RAND()').detect { |u| not u.access_right_for(@inventory_pool) }
    expect(unknown_user).not_to be_nil

    role = case x[:role]
             when _('Customer')
               expect(unknown_user.has_role?(:customer, @inventory_pool)).to be false
               :customer
             when _('Group manager')
               expect(unknown_user.has_role?(:group_manager, @inventory_pool)).to be false
               :group_manager
             when _('Lending manager')
               expect(unknown_user.has_role?(:lending_manager, @inventory_pool)).to be false
               :lending_manager
             when _('Inventory manager')
               expect(unknown_user.has_role?(:inventory_manager, @inventory_pool)).to be false
               :inventory_manager
             when _('No access')
               # the unknown_user needs to have a role first, than it can be deleted
               data = {user: {id: unknown_user.id},
                       access_right: {role: :customer},
                       db_auth: {login: Faker::Lorem.words(3).join, password: 'password', password_confirmation: 'password'}}
               page.driver.browser.process(:put, manage_update_inventory_pool_user_path(@inventory_pool, unknown_user, format: :json), data)
               :no_access
           end

    data = {user: {id: unknown_user.id},
            access_right: {role: role, suspended_until: nil},
            db_auth: {login: Faker::Lorem.words(3).join, password: 'password', password_confirmation: 'password'}}

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



#Dann /^man kann nicht inventarrelevante Gegenstände ausmustern, sofern man deren Besitzer ist$/ do
Then(/^I can retire items if my inventory pool is their owner and they are not inventory relevant$/) do
  item = @inventory_pool.own_items.where(is_inventory_relevant: false).first
  expect(item.retired?).to be false
  attributes = {
      retired: true,
      retired_reason: 'Item is gone'
  }

  expect(page.driver.browser.process(:put, manage_update_item_path(@inventory_pool, item, format: :json), item: attributes).successful?).to be true

  expect(item.reload.retired?).to be true
  expect(item.retired).to eq Date.today
end

####################################################################

#Dann /^kann man neue Modelle erstellen$/ do
Then(/^I can create new models$/) do
  c = Model.count
  attributes = FactoryGirl.attributes_for :model

  expect(page.driver.browser.process(:post, "/manage/#{@inventory_pool.id}/models.json", model: attributes).successful?).to be true
  expect(Model.count).to eq c+1
end

#Dann /^man kann sie einem anderen Gerätepark als Besitzer zuweisen$/ do
Then(/^I can make another inventory pool the owner of the items$/) do
  attributes = {
      owner_id: (InventoryPool.order('RAND()').pluck(:id) - [@inventory_pool.id]).first
  }
  expect(@item.owner_id).not_to eq attributes[:owner_id]

  expect(page.driver.browser.process(:put, manage_update_item_path(@inventory_pool, @item, format: :json), item: attributes).successful?).to be true
  expect(@item.reload.owner_id).to eq attributes[:owner_id]
end

#Wenn /^man keine verantwortliche Abteilung auswählt$/ do
When(/^I don't choose a responsible department when creating or editing items$/) do
  @item = @inventory_pool.own_items.find &:in_stock?
  attributes = {
      inventory_pool_id: (InventoryPool.order('RAND()').pluck(:id) - [@inventory_pool.id, @item.inventory_pool_id]).first
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

#Dann /^ist die Verantwortliche Abteilung gleich wie der Besitzer$/ do
Then(/^the responsible department is the same as the owner$/) do
  expect(@item.reload.inventory_pool_id).to eq @item.owner_id
end

#Dann /^man kann Gegenstände ausmustern, sofern man deren Besitzer ist$/ do
Then(/^I can retire these items if my inventory pool is their owner$/) do
  item = @inventory_pool.own_items.find &:in_stock?
  attributes = {
      retired: true,
      retired_reason: 'retired reason'
  }
  expect(item.retired).to eq nil
  expect(item.retired_reason).to eq nil

  expect(page.driver.browser.process(:put, manage_update_item_path(@inventory_pool, item, format: :json), item: attributes).successful?).to be true
  expect(item.reload.retired).to eq Date.today
  expect(item.retired_reason).to eq attributes[:retired_reason]
end

#Dann /^man kann Ausmusterungen wieder zurücknehmen, sofern man Besitzer der jeweiligen Gegenstände ist$/ do
Then(/^I can unretire items if my inventory pool is their owner$/) do
  item = Item.unscoped { @inventory_pool.own_items.where.not(retired: nil).first }
  attributes = {
      retired: nil
  }
  expect(item.retired).not_to be_nil
  expect(item.retired_reason).not_to be_nil

  expect(page.driver.browser.process(:put, manage_update_item_path(@inventory_pool, item, format: :json), item: attributes).successful?).to be true
  expect(item.reload.retired).to eq nil
  expect(item.retired_reason).to eq nil
end


#Dann /^man kann die Arbeitstage und Ferientage seines Geräteparks anpassen$/ do
Then(/^I can specify workdays and holidays for my inventory pool$/) do
  visit manage_edit_inventory_pool_path @inventory_pool
end

#Dann /^man kann alles, was ein Ausleihe\-Verwalter kann$/ do
Then(/^I can do everything a lending manager can do$/) do
  expect(@current_user.has_role?(:lending_manager, @inventory_pool)).to be true
  expect(@current_user.has_role?(:inventory_manager, @inventory_pool)).to be true
end

####################################################################

# Dann /^kann man neue Geräteparks erstellen$/ do
#   c = InventoryPool.count
#   ids = InventoryPool.pluck(:id)
#   attributes = FactoryGirl.attributes_for :inventory_pool
#
#   page.driver.browser.process(:post, manage_inventory_pools_path, inventory_pool: attributes)
#   expect(page.status_code == 302).to be true
#
#   expect(InventoryPool.count).to eq c+1
#   id = (InventoryPool.pluck(:id) - ids).first
#
#   expect(URI.parse(current_path).path).to eq manage_inventory_pools_path
# end

# Dann /^man kann neue Benutzer erstellen und löschen$/ do
#   step 'man kann neue Benutzer erstellen ohne inventory_pool'
#
#   expect(page.driver.browser.process(:delete, manage_user_path(@user, format: :json)).successful?).to be true
#
#   assert_raises(ActiveRecord::RecordNotFound) do
#     @user.reload
#   end
# end

# Dann /^man kann Benutzern jegliche Rollen zuweisen und wegnehmen$/ do
#   user = User.where(:login => "normin").first
#   inventory_pool = InventoryPool.find_by_name "IT-Ausleihe"
#   expect(user.has_role?(:inventory_manager, inventory_pool)).to be false
#
#   expect(page.driver.browser.process(:put, manage_user_path(user, format: :json), access_right: {inventory_pool_id: inventory_pool.id, role: :inventory_manager}).successful?).to be true
#
#   expect(user.has_role?(:inventory_manager, inventory_pool)).to be true
#   expect(user.access_right_for(inventory_pool).deleted_at).to eq nil
#
#   expect(page.driver.browser.process(:put, manage_user_path(user, format: :json), access_right: {inventory_pool_id: inventory_pool.id, role: :no_access}).successful?).to be true
#
#   expect(user.has_role?(:inventory_manager, inventory_pool)).to be false
#   expect(user.access_rights.where.not(deleted_at: nil).where(inventory_pool_id: inventory_pool).first.deleted_at).not_to be_nil
# end

#Dann(/^kann man Gruppen über eine Autocomplete\-Liste hinzufügen$/) do
Then(/^I can add groups using a list with autocomplete$/) do
  @groups_added = (@inventory_pool.groups - @customer.groups)
  @groups_added.each do |group|
    find('.row.emboss', match: :prefer_exact, text: _('Groups')).find('.autocomplete').click
    find('.ui-autocomplete .ui-menu-item a', text: group.name).click
  end
end

#Dann(/^kann Gruppen entfernen$/) do
Then(/^I can remove groups$/) do
  @groups_removed = @customer.groups
  @groups_removed.each do |group|
    find('.row.emboss', match: :prefer_exact, text: _('Groups')).find('.field-inline-entry', text: group.name).find('.clickable', text: _('Remove')).click
  end
end

#Dann(/^speichert den Benutzer$/) do
Then(/^I save the user$/) do
  find('.button', text: _('Save %s') % _('User')).click
  step 'man sieht eine Bestätigungsmeldung'
end

#Dann(/^ist die Gruppenzugehörigkeit gespeichert$/) do
Then(/^their group membership is saved$/) do
  @groups_removed.each do |group|
    expect(@customer.reload.groups.include?(group)).to be false
  end
  @groups_added.each do |group|
    expect(@customer.reload.groups.include?(group)).to be true
  end
end

#Wenn(/^man in der Benutzeransicht ist$/) do
#Angenommen(/^man befindet sich auf der Benutzerliste ausserhalb der Inventarpools$/) do
#Angenommen(/^man befindet sich auf der Benutzerliste im beliebigen Inventarpool$/) do
When(/^I am looking at the user list( outside an inventory pool| in any inventory pool)?$/) do |arg1|
  visit case arg1
          when ' outside an inventory pool'
            manage_users_path
          when ' in any inventory pool'
            @current_inventory_pool = InventoryPool.first
            manage_inventory_pool_users_path(@current_inventory_pool)
          else
            manage_inventory_pool_users_path(@current_inventory_pool)
        end
end

#Wenn(/^man einen Benutzer hinzufügt$/) do
When(/^I add a user$/) do
  find_link(_('New User')).click
end

#Wenn(/^die folgenden Informationen eingibt$/) do |table|
When(/^I enter the following information$/) do |table|
  table.raw.flatten.each do |field_name|
    find('.row.emboss', match: :prefer_exact, text: field_name).find('input,textarea').set (field_name == 'E-Mail' ? 'test@test.ch' : 'test')
  end
end

#Wenn(/^man gibt eine Badge\-Id ein$/) do
When(/^I enter a badge ID$/) do
  find('.row.emboss', match: :prefer_exact, text: _('Badge ID')).find('input,textarea').set 123456
end

#Wenn(/^eine der folgenden Rollen auswählt$/) do |table|
When(/^I choose the following roles$/) do |table|
  @role_hash = table.hashes[rand table.hashes.length]
  page.select @role_hash[:tab], from: 'access_right[role]'
end

# Wenn(/^man wählt ein Sperrdatum und ein Sperrgrund$/) do
#   find(".row.emboss", match: :prefer_exact, text: _("Suspended until")).find("input").set I18n.l(Date.today + 1)
#   find(".ui-datepicker-current-day").click
#   suspended_reason = find(".row.emboss", match: :prefer_exact, text: _("Suspended reason")).find("textarea")
#   suspended_reason.set "test"
# end

#Wenn(/^man teilt mehrere Gruppen zu$/) do
When(/^I assign multiple groups$/) do
  @current_inventory_pool.groups.each do |group|
    find('#change-groups input').click
    find('.ui-autocomplete .ui-menu-item a', match: :first)
    find('.ui-autocomplete .ui-menu-item a', text: group.name).click
  end
end

#Dann(/^ist der Benutzer mit all den Informationen gespeichert$/) do
Then(/^the user and all their information is saved$/) do
  find_link _('New User')
  find('#flash .notice', text: _('User created successfully'))
  user = User.find_by_lastname 'test'
  expect(user).not_to be_nil
  expect(user.access_right_for(@current_inventory_pool).role).to eq @role_hash[:role].to_sym
  expect(user.groups).to eq @current_inventory_pool.groups
end

#Wenn(/^alle Pflichtfelder sind sichtbar und abgefüllt$/) do
When(/^all required fields are filled in$/) do
  find('.row.emboss', match: :prefer_exact, text: _('Last name')).find('input,textarea').set 'test'
  find('.row.emboss', match: :prefer_exact, text: _('First name')).find('input,textarea').set 'test'
  find('.row.emboss', match: :prefer_exact, text: _('E-Mail')).find('input,textarea').set 'test@test.ch'
end

#Wenn(/^man ein Nachname nicht eingegeben hat$/) do
When(/^I did not enter last name$/) do
  find('.row.emboss', match: :prefer_exact, text: _('Last name')).find('input,textarea').set ''
end

#Wenn(/^man ein Vorname nicht eingegeben hat$/) do
When(/^I did not enter first name$/) do
  find('.row.emboss', match: :prefer_exact, text: _('First name')).find('input,textarea').set ''
end

#Wenn(/^man ein E\-Mail nicht eingegeben hat$/) do
When(/^I did not enter email address$/) do
  find('.row.emboss', match: :prefer_exact, text: _('E-Mail')).find('input,textarea').set ''
end

#Wenn(/^man ein Sperrgrund nicht eingegeben hat$/) do
When(/^I did not enter reason for suspension$/) do
  find('.row.emboss', match: :prefer_exact, text: _('Suspended reason')).find('input,textarea').set ''
end

#Wenn(/^man von hier auf die Benutzererstellungsseite geht$/) do
When(/^I navigate from here to the user creation page$/) do
  click_link _('New User')
end

#Dann(/^wird man auf die Benutzerliste ausserhalb der Inventarpools umgeleitet$/) do
Then(/^I am redirected to the user list outside an inventory pool$/) do
  expect(current_path).to eq manage_users_path
end

#Dann(/^der neue Benutzer wurde erstellt$/) do
Then(/^the new user has been created$/) do
  @user = User.find_by_email 'test@test.ch'
end

#Dann(/^er hat keine Zugriffe auf Inventarpools und ist kein Administrator$/) do
Then(/^he does not have access to any inventory pools and is not an administrator$/) do
  expect(@user.access_rights.active.empty?).to be true
end

#Angenommen(/^man befindet sich auf der Editierseite eines Benutzers, der kein Administrator ist und der Zugriffe auf Inventarpools hat$/) do
Given(/^I am editing a user that has no access rights and is not an admin$/) do
  @user = User.find { |u| not u.has_role? :admin and u.has_role? :customer }
  @previous_access_rights = @user.access_rights.freeze
  visit manage_edit_user_path(@user)
end


#Wenn(/^man diesen Benutzer die Rolle Administrator zuweist$/) do
When(/^I assign the admin role to this user$/) do
  select _('Yes'), from: 'user_admin'
end

#Dann(/^hat dieser Benutzer die Rolle Administrator$/) do
Then(/^this user has the admin role$/) do
  expect(@user.reload.has_role?(:admin)).to be true
end


#Dann(/^alle andere Zugriffe auf Inventarpools bleiben beibehalten$/) do
Then(/^all their previous access rights remain intact$/) do
  expect((@previous_access_rights - @user.access_rights.reload).empty?).to be true
end

#Angenommen(/^man befindet sich auf der Editierseite eines Benutzers, der ein Administrator ist und der Zugriffe auf Inventarpools hat$/) do
Given(/^I am editing a user who has the admin role and access to inventory pools$/) do
  @user = User.find { |u| u.has_role? :admin and u.has_role? :customer }
  raise 'user not found' unless @user
  @previous_access_rights = @user.access_rights.select { |ar| ar.role != :admin }.freeze
  visit manage_edit_user_path(@user)
end

#Wenn(/^man diesem Benutzer die Rolle Administrator wegnimmt$/) do
When(/^I remove the admin role from this user$/) do
  select _('No'), from: 'user_admin'
end

#Dann(/^hat dieser Benutzer die Rolle Administrator nicht mehr$/) do
Then(/^this user no longer has the admin role$/) do
  expect(@user.reload.has_role?(:admin)).to be false
end

#Wenn(/^man versucht auf die Administrator Benutzererstellenansicht zu gehen$/) do
When(/^I try to access the admin area's user editing page$/) do
  @path = manage_edit_user_path(User.first)
  visit @path
end

#Dann(/^gelangt man auf diese Seite nicht$/) do
Then(/^I can't access that page$/) do
  expect(current_path).not_to eq @path
end

#Wenn(/^man versucht auf die Administrator Benutzereditieransicht zu gehen$/) do
When(/^I try to access the admin area's user creation page$/) do
  @path = '/manage/users/new'
  visit @path
end

#Wenn(/^man hat nur die folgenden Rollen zur Auswahl$/) do |table|
Then(/^I can only choose the following roles$/) do |table|
  expect(find('.row.emboss', match: :prefer_exact, text: _('Access as')).all('option').length).to eq table.raw.length
  table.raw.flatten.each do |role|
    find('.row.emboss', match: :prefer_exact, text: _('Access as')).find('option', text: _(role))
  end
end

#Angenommen(/^man editiert einen Benutzer der Kunde ist$/) do
Given(/^I edit a user who has access as customer$/) do
  access_right = AccessRight.find { |ar| ar.role == :customer and ar.inventory_pool == @current_inventory_pool }
  @user = access_right.user
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @user)
end

#Angenommen(/^man editiert einen Benutzer der Ausleihe-Verwalter ist$/) do
Given(/^I edit a user who has access as lending manager$/) do
  access_right = AccessRight.find { |ar| ar.role == :lending_manager and ar.inventory_pool == @current_inventory_pool and ar.user != @current_user }
  @user = access_right.user
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @user)
end

#Angenommen(/^man editiert in irgendeinem Inventarpool einen Benutzer der Kunde ist$/) do
Given(/^I edit a user who is customer in any inventory pool$/) do
  access_right = AccessRight.find { |ar| ar.role == :customer }
  @user = access_right.user
  @current_inventory_pool = access_right.inventory_pool
  visit manage_edit_inventory_pool_user_path(access_right.inventory_pool, @user)
end

#Wenn(/^man den Zugriff auf "Kunde" ändert$/) do
#Wenn(/^man den Zugriff auf "Ausleihe-Verwalter" ändert$/) do
#Wenn(/^man den Zugriff auf "Inventar-Verwalter" ändert$/) do
When(/^I change the access level to "(.*)"$/) do |arg1|
  s = case arg1
        when 'customer'
          _('Customer')
        when 'lending manager'
          _('Lending manager')
        when 'inventory manager'
          _('Inventory manager')
      end
  find('.row.emboss', match: :prefer_exact, text: _('Access as')).find('select').select s
end

#Dann(/^hat der Benutzer die Rolle Kunde$/) do
Then(/^the user has the role "customer"$/) do
  expect(has_content?(_('List of Users'))).to be true
  expect(@user.reload.access_right_for(@current_inventory_pool).role).to eq :customer
end

#Dann(/^hat der Benutzer die Rolle Ausleihe-Verwalter$/) do
Then(/^the user has the role "lending manager"$/) do
  find_link _('New User')
  expect(@user.reload.access_right_for(@current_inventory_pool).role).to eq :lending_manager
end

#Dann(/^hat der Benutzer die Rolle Inventar-Verwalter$/) do
Then(/^the user has the role "inventory manager"$/) do
  find('#flash .notice', text: _('User details were updated successfully.'))
  find_link _('New User')
  expect(@user.reload.access_right_for(@current_inventory_pool).role).to eq :inventory_manager
end

#Angenommen(/^man sucht sich einen Benutzer ohne Zugriffsrechte, Bestellungen und Verträge aus$/) do
Given(/^I pick a user without access rights, orders or contracts$/) do
  @user = User.find { |u| u.access_rights.active.empty? and u.reservations_bundles.empty? }
end

#Wenn(/^ich diesen Benutzer aus der Liste lösche$/) do
When(/^I delete that user from the list$/) do
  @user ||= @users.sample
  step %Q(I search for "%s") % @user.to_s
  within('#user-list .line', text: @user.name) do
    within('.multibutton') do
      find('.dropdown-toggle').click
      find('.dropdown-toggle').click
      find('.dropdown-item.red', text: _('Delete')).click
    end
  end
end

#Dann(/^wurde der Benutzer aus der Liste gelöscht$/) do
Then(/^that user has been deleted from the list$/) do
  expect(has_no_selector?('#user-list .line', text: @user.name)).to be true
end


#Dann(/^der Benutzer ist gelöscht$/) do
Then(/^that user is deleted$/) do
  find('#flash .success')
  expect(User.find_by_id(@user.id)).to eq nil
end

#Dann(/^der Benutzer ist nicht gelöscht$/) do
Then(/^the user is not deleted$/) do
  check_user_list([@user])
  expect(User.find_by_id(@user.id)).not_to be_nil
end


#Angenommen(/^man sucht sich je einen Benutzer mit Zugriffsrechten, Bestellungen und Verträgen aus$/) do
Given(/^I pick one user with access rights, one with orders and one with contracts$/) do
  @users = []
  @users << User.find { |u| not u.access_rights.active.empty? and u.reservations_bundles.empty? }
  @users << User.find { |u| not u.reservations_bundles.empty? }
  @users << User.find { |u| u.reservations_bundles.empty? }
end

# Dann(/^wird der Delete Button für diese Benutzer nicht angezeigt$/) do
#   @users.each do |user|
#     step %Q(I search for "%s") % user.name
#     within("#user-list .line", text: user.name) do
#       find(".multibutton .dropdown-toggle").click
#       expect(has_no_selector?(".multibutton .dropdown-item.red", text: _("Delete"))).to be true
#     end
#   end
# end

# Angenommen(/^man editiert einen Benutzer der Zugriff auf ein Inventarpool hat( und keine Gegenstände hat)?$/) do |arg1|
#   access_right = AccessRight.order("RAND ()").detect { |ar| ar.role == :customer and
#                                                        ar.inventory_pool.reservations.where(user: ar.user).empty? }
#   @user = access_right.user
#   @current_inventory_pool = access_right.inventory_pool
#   visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @user)
# end

#Angenommen(/^man editiert einen Benutzer der Zugriff auf das aktuelle Inventarpool hat( und keine Gegenstände hat)?$/) do |arg1|
Given(/^I am editing a user who has access to (and no items from )?(the current|an) inventory pool$/) do |arg1, arg2|
  case arg2
    when 'the current'
      access_rights = @current_inventory_pool.access_rights.active.where(role: :customer)
      @user = if arg1
                access_rights.detect { |ar| @current_inventory_pool.reservations.where(user_id: ar.user).empty? }
              else
                access_rights.order('RAND()').first
              end.user
    when 'an'
      access_right = AccessRight.active.where(role: :customer).order('RAND ()').detect {|ar| ar.inventory_pool.reservations.where(user: ar.user).empty? }
      @user = access_right.user
      @current_inventory_pool = access_right.inventory_pool
  end
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @user)
end

#Wenn(/^man den Zugriff entfernt$/) do
When(/^I remove their access$/) do
  find('.row.emboss', match: :prefer_exact, text: _('Access as')).find('select').select _('No access')
end

#Dann(/^hat der Benutzer keinen Zugriff auf das Inventarpool$/) do
Then(/^the user has no access to the inventory pool$/) do
  find_link _('New User')
  expect(@user.reload.access_right_for(@current_inventory_pool)).to eq nil
end

#Dann(/^sind die Benutzer nach ihrem Vornamen alphabetisch sortiert$/) do
Then(/^users are sorted alphabetically by first name$/) do
  within('#user-list') do
    find('.line', match: :first)
    t = if current_path == manage_users_path
          all('.line > div:nth-child(1)').map(&:text).map { |t| t.split(' ').take(2).join(' ') }
        else
          all('.line > div:nth-child(1)').map(&:text)
        end
    expect(t).to eq User.order(:firstname).paginate(page: 1, per_page: 20).map(&:name)
  end
end

#Und(/^man gibt die Login-Daten ein$/) do
When(/^I enter the login data$/) do
  find('.row.emboss', match: :prefer_exact, text: _('Login')).find('input').set 'username'
  find('.row.emboss', match: :prefer_exact, text: _('Password')).find('input').set 'password'
  find('.row.emboss', match: :prefer_exact, text: _('Password Confirmation')).find('input').set 'password'
end


#Angenommen(/^man editiert einen Benutzer der kein Zugriff auf das aktuelle Inventarpool hat$/) do
Given(/^I edit a user who doesn't have access to the current inventory pool$/) do
  @user = User.find { |u| u.access_rights.active.blank? }
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @user)
end

#Wenn(/^man ändert die Email$/) do
When(/^I change the email address$/) do
  find('.row.emboss', match: :prefer_exact, text: _('E-Mail')).find('input,textarea').set 'changed@test.ch'
end

#Dann(/^sieht man die Erfolgsbestätigung$/) do
Then(/^I see a confirmation of success on the list of users$/) do
  expect(has_content?(_('List of Users'))).to be true
  find('.notice', match: :first)
end

#Dann(/^die neue Email des Benutzers wurde gespeichert$/) do
Then(/^the user's new email address is saved$/) do
  expect(@user.reload.email).to eq 'changed@test.ch'
end

#Dann(/^der Benutzer hat nach wie vor keinen Zugriff auf das aktuelle Inventarpool$/) do
Then(/^the user still has access to the current inventory pool$/) do
  expect(@user.access_rights.active.detect { |ar| ar.inventory_pool == @current_inventory_pool }).to eq nil
end

#Angenommen(/^man editiert einen Benutzer der mal einen Zugriff auf das aktuelle Inventarpool hatte$/) do
Given(/^I edit a user who used to have access to the current inventory pool$/) do
  @current_inventory_pool = @current_user.inventory_pools.managed.where(id: AccessRight.select(:inventory_pool_id).where.not(deleted_at: nil)).order('RAND()').first
  # TODO use rewhere instead of unscope+where (from Rails 4.1.8)
  @user = @current_inventory_pool.users.unscope(where: :deleted_at).where.not(access_rights: {deleted_at: nil}).order('RAND()').first
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @user)
end

#Angenommen(/^man einen Benutzer mit Zugriffsrechten editiert$/) do
When(/^I edit a user that has access rights$/) do
  @user = User.find { |u| u.access_rights.active.count >= 2 }
  expect(@user.access_rights.active.count).to be >= 2
  visit manage_edit_user_path(@user)
end

#Dann(/^werden die ihm zugeteilt Geräteparks mit entsprechender Rolle aufgelistet$/) do
Then(/^inventory pools they have access to are listed with the respective role$/) do
  @user.access_rights.active.each do |access_right|
    find('.row.emboss .padding-inset-s', text: access_right.to_s)
  end
end

#Given(/^there exists a contract with status "(.*?)" for a user with otherwise no other contracts$/) do |arg1|
Given(/^there exists a contract with status "(.*?)" for a user without any other contracts$/) do |arg1|
  state = case arg1
            when 'submitted' then
              :submitted
            when 'approved' then
              :approved
            when 'signed' then
              :signed
          end
  @contract = @current_inventory_pool.reservations_bundles.send(state).detect { |c| c.user.reservations_bundles.all? { |c| c.status == state } }
  expect(@contract).not_to be_nil
end

When(/^I edit the user of this contract$/) do
  @user = @contract.user
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @user)
end

Then(/^this user has access to the current inventory pool$/) do
  expect(@user.access_right_for(@current_inventory_pool)).not_to be_nil
end

Then(/^I see the error message "(.*?)"$/) do |arg1|
  find('#flash .error', text: _(arg1))
end
