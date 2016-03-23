# -*- encoding : utf-8 -*-

When(/^Julie is in a delegation$/) do
  @user = User.where(login: 'julie').first
  expect(@user.delegations.empty?).to be false
end

Then(/^I see all results for Julie or the delegation named Julie$/) do
  q = '%Julie%'
  delegations = @current_inventory_pool.users.as_delegations.where(User.arel_table[:firstname].matches(q))
  ([@user] + delegations).each do |u|
    find('#users .list-of-lines .line', match: :prefer_exact, text: u.to_s)
  end
  # TODO also check contracts matches, etc...
end

Then(/^I see all delegations Julie is a member of$/) do
  (@user.delegations & @current_inventory_pool.users).each do |u|
    find('#users .list-of-lines .line', match: :prefer_exact, text: u.to_s)
  end
  # TODO also check contracts matches, etc...
end

Then(/^I can restrict the user list to show only (users|delegations)$/) do |arg1|
  t, b = case arg1
           when 'users'
             [_('Users'), false]
           when 'delegations'
             [_('Delegations'), true]
         end

  find('#user-index-view form#list-filters select#type').select t
  within '#user-list.list-of-lines' do
    find('.line', match: :first)
    ids = all(".line [data-type='user-cell']").map { |user_data| user_data['data-id'] }
    expect(User.find(ids).any?(&:delegation?)).to be b
  end
end

Given(/^I open the tab '(.*)'$/) do |arg1|
  if @current_inventory_pool
    find('nav ul li a.navigation-tab-item', text: arg1).click
    find('nav ul li a.navigation-tab-item.active', text: arg1)
  else
    find('.nav-tabs li a', text: arg1).click
    find('.nav-tabs li.active a', text: arg1)
  end
  find('#user-index-view ')
end

When(/^I create a new delegation$/) do
  within('.multibutton', text: _('New User')) do
    find('.dropdown-toggle').click
    find('.dropdown-item', text: _('New Delegation')).click
  end
end

When(/^I give the delegation access to the current inventory pool$/) do
  find("select[name='access_right[role]']").select(_('Customer'))
end

When(/^I give the delegation a name$/) do
  @name = Faker::Lorem.sentence
  find("input[name='user[firstname]']").set @name
end

When(/^I assign none, one or more people to the delegation$/) do
  @delegated_users = []
  rand(0..2).times do
    find('[data-search-users]').set ' '
    find('ul.ui-autocomplete')
    el = all('ul.ui-autocomplete > li').to_a.sample
    @delegated_users << el.text
    el.click
  end
end

When(/^I assign none, one or more groups to the delegation$/) do
  rand(0..2).times do
    find('#change-groups input').click
    find('ul.ui-autocomplete')
    el = all('ul.ui-autocomplete > li').to_a.sample
    el.click
  end
end

When(/^I cannot assign a delegation to the delegation$/) do
  find('[data-search-users]').set @current_inventory_pool.users.as_delegations.order('RAND()').first.name
  expect(has_no_selector?('ul.ui-autocomplete > li')).to be true
end

When(/^I enter exactly one responsible person$/) do
  @responsible ||= @current_inventory_pool.users.not_as_delegations.order('RAND()').first
  find('.row.emboss', text: _('Responsible')).find("input[data-type='autocomplete']").set @responsible.name
  find('ul.ui-autocomplete > li').click
end

Then(/^the new delegation is saved with the current information$/) do
  delegation = User.find_by_firstname(@name)
  expect(delegation.delegator_user).to eq @responsible
  delegation.delegated_users.each {|du| @delegated_users.include? du.name}
  delegation.delegated_users.count == (@delegated_users + [@resonsible]).uniq.count
end

When(/^I search for a delegation$/) do
  @delegation = @current_inventory_pool.users.as_delegations.order('RAND()').first
  #step "ich suche '%s'" % @delegation.firstname
  step "I search for '%s'" % @delegation.firstname
end

When(/^I hover over the delegation name$/) do
  find('#users .list-of-lines .line', match: :prefer_exact, text: @delegation.to_s).find("[data-type='user-cell']").hover
end

Then(/^the tooltip shows name and responsible person for the delegation$/) do
  find('body > .tooltipster-base', text: @delegation.delegator_user.to_s)
end

Then(/^I see the delegations I am assigned to$/) do
  @current_user.delegations.customers.each do |delegation|
    find('.line strong', match: :prefer_exact, text: delegation.to_s)
  end
end

When(/^I pick a delegation to represent$/) do
  within(all('.line').to_a.sample) do
    id = find('.line-actions a.button')[:href].gsub(/.*\//, '')
    @delegation = @current_user.delegations.customers.find(id)
    find('strong', match: :prefer_exact, text: @delegation.to_s)
    find('.line-actions a.button').click
  end
end

Then(/^I am logged in as that delegation$/) do
  find("nav.topbar ul.topbar-navigation .topbar-item", text: @delegation.short_name)
  @delegated_user = @current_user
  @current_user = @delegation
end

Then(/^the delegation is saved as borrower$/) do
  @contracts.each do |contract|
    expect(contract.user).to eq @delegation
  end
end

Then(/^I am saved as contact person$/) do
  @contracts.each do |contract|
    expect(contract.delegated_user).to eq @delegated_user
  end
end

Given(/^there is an order for a delegation$/) do
  @contract = @current_inventory_pool.reservations_bundles.submitted.find {|c| c.user.delegation? }
  expect(@contract).not_to be_nil
end

Given(/^I am editing a delegation's order$/) do
  @contract = @current_inventory_pool.reservations_bundles.find {|c| [:submitted, :approved].include? c.status and c.delegated_user and c.user.delegated_users.count >= 2}
  @delegation = @contract.user
  step 'I edit the order'
end

Then(/^I see the delegation's name$/) do
  expect(has_content?(@contract.user.name)).to be true
end

Then(/^I see the contact person$/) do
  expect(has_content?(@contract.delegated_user.name)).to be true
end

Given(/^there is an order placed by me personally$/) do
  @contract = @current_inventory_pool.reservations_bundles.submitted.find {|c| not c.user.delegation? }
  expect(@contract).not_to be_nil
end

Then(/^the order shows the name of the user$/) do
  expect(has_content?(@contract.user.name)).to be true
end

Then(/^I don't see any contact person$/) do
  find('h2', text: @contract.user.name)
end

Given(/^there is a hand over( for a delegation)?( with assigned items)?$/) do |arg1, arg2|
  @hand_over = if arg1 and arg2
                 @current_inventory_pool.visits.hand_over.find {|v| v.user.delegation? and v.reservations.all?(&:item) and Date.today >= v.date }
               elsif arg1
                 @current_inventory_pool.visits.hand_over.find {|v| v.user.delegation? and v.reservations.any? &:item and not v.date > Date.today } # NOTE v.date.future? doesn't work properly because timezone
               else
                 @current_inventory_pool.visits.hand_over.order('RAND()').first
               end
  expect(@hand_over).not_to be_nil
end

Given(/^I open this hand over$/) do
  visit manage_hand_over_path @current_inventory_pool, @hand_over.user
end

When /^I select all reservations selecting all linegroups$/ do
  all('input[data-select-lines]').each {|el| el.click unless el.checked?}
end

When(/^I change the delegation$/) do
  expect(has_selector?('input[data-select-lines]', match: :first)).to be true
  step 'I select all reservations selecting all linegroups'
  multibutton = first('.multibutton', text: _('Hand Over Selection')) || first('.multibutton', text: _('Edit Selection'))
  multibutton.find('.dropdown-toggle').click
  find('#swap-user', match: :first).click
  find('.modal', match: :first)
  @contract ||= @hand_over.reservations.map(&:contract).uniq.first
  @old_delegation = @contract.user
  @new_delegation = @current_inventory_pool.users.find {|u| u.delegation? and u.firstname != @old_delegation.firstname}
  find('input#user-id', match: :first).set @new_delegation.name
  find('.ui-menu-item a', match: :first).click
  @contract.reservations.reload.all? {|c| c.user == @new_delegation }
end

When(/^I try to change the delegation$/) do
  expect(has_selector?('input[data-select-lines]', match: :first)).to be true
  all('input[data-select-lines]').each_with_index do |line, i|
    el = all('input[data-select-lines]')[i]
    el.click unless el.checked?
  end
  multibutton = first('.multibutton', text: _('Hand Over Selection')) || first('.multibutton', text: _('Edit Selection'))
  multibutton.find('.dropdown-toggle').click
  find('#swap-user', match: :first).click
  find('.modal', match: :first)
  find('input#user-id', match: :first)
  @wrong_delegation = User.as_delegations.find {|d| not d.access_right_for @current_inventory_pool}
  @valid_delegation = @current_inventory_pool.users.as_delegations.order('RAND()').first
end

Then(/^the hand over goes to the new delegation$/) do
  expect(has_content?(@new_delegation.name)).to be true
  expect(has_no_content?(@old_delegation.name)).to be true
end

When(/^I try to change the contact person$/) do
  expect(has_selector?('input[data-select-lines]', match: :first)).to be true
  step 'I select all reservations selecting all linegroups'
  find('button', text: _('Hand Over Selection')).click
  @delegation = @hand_over.user
  @contact = @delegation.delegated_users.order('RAND()').first
  @not_contact = @current_inventory_pool.users.find {|u| not @delegation.delegated_users.include? u}
end

When(/^I try to change the order's contact person$/) do
  click_button 'swap-user'
  @contact = @delegation.delegated_users.order('RAND()').first
  @not_contact = @current_inventory_pool.users.find {|u| not @delegation.delegated_users.include? u}
end

Then(/^I can choose only those people that belong to the delegation group$/) do
  find('input#user-id', match: :first).set @not_contact.name
  expect(has_no_selector?('.ui-menu-item a')).to be true
  find('input#user-id', match: :first).set @contact.name
  find('.ui-menu-item a', match: :first, text: @contact.name).click
  find('#selected-user', text: @contact.name)
end

Then(/^I can choose only those people as contact person for the order that belong to the delegation group$/) do
  within '#contact-person' do
    find('input#user-id', match: :first).set @not_contact.name
    expect(has_no_selector?('.ui-menu-item a')).to be true
    find('input#user-id', match: :first).set @contact.name
    find('.ui-menu-item a', match: :first, text: @contact.name).click
    find('#selected-user', text: @contact.name)
  end
end

When(/^I change the contact person$/) do
  @contact ||= (@delegation or @new_delegation).delegated_users.order('RAND()').first
  within '#contact-person' do
    find('input#user-id', match: :first).set @contact.name
    find('.ui-menu-item a', match: :first, text: @contact.name).click
    find('#selected-user', text: @contact.name)
  end
end

Then(/^I can choose only those delegations that have access to this inventory pool$/) do
  find('input#user-id', match: :first).set @wrong_delegation.name
  expect(has_no_selector?('.ui-menu-item a')).to be true
  find('input#user-id', match: :first).set @valid_delegation.name
  find('.ui-menu-item a', match: :first, text: @valid_delegation.name).click
  find('#selected-user', text: @valid_delegation.name)
end

When(/^I pick a user instead of a delegation$/) do
  @contract ||= @hand_over.reservations.map(&:contract).uniq.first
  @delegation = @contract.user
  @delegated_user = @contract.delegated_user
  @new_user = @current_inventory_pool.users.not_as_delegations.order('RAND()').first
  has_selector?('input[data-select-lines]', match: :first)
  all('input[data-select-lines]').each_with_index do |line, i|
    el = all('input[data-select-lines]')[i]
    el.click unless el.checked?
  end
  multibutton = first('.multibutton', text: _('Hand Over Selection')) || first('.multibutton', text: _('Edit Selection'))
  multibutton.find('.dropdown-toggle').click if multibutton
  find('#swap-user', match: :first).click
  within '.modal' do
    find('#user input#user-id', match: :first).set @new_user.name
    find('.ui-menu-item a', match: :first, text: @new_user.name).click
    find(".button[type='submit']", match: :first).click
  end
  step 'the modal is closed'
end

Then /^the modal is closed$/ do
  expect(has_no_selector?('.modal')).to be true
end

Then(/^the order shows the user$/) do
  find('.content-wrapper', text: @new_user.name, match: :first)
  @contract.reservations.each do |line|
    expect(line.reload.user).to eq @new_user
  end
end

Then(/^no contact person is shown$/) do
  expect(has_no_content?("(#{@delegated_user.name})")).to be true
  @contract.reservations.each do |line|
    expect(line.reload.delegated_user).to eq nil
  end
end

When(/^there is no order, hand over or contract for a delegation$/) do
  @delegations = User.as_delegations.select {|d| d.reservations_bundles.blank?}
end

When(/^that delegation has no access rights to any inventory pool$/) do
  @delegation = @delegations.find {|d| d.access_rights.empty?}
  expect(@delegation).not_to be_nil
end

Then(/^I can delete that delegation$/) do
  step %Q(I search for "%s") % @delegation.name
  line = find('.row', text: @delegation.name)
  line.find('.dropdown-toggle').click
  find("[data-method='delete']").click
  page.driver.browser.switch_to.alert.accept rescue nil
  step 'I receive a notification of success'
  expect { @delegation.reload }.to raise_error ActiveRecord::RecordNotFound
end

Then(/^I can at most give the delegation access on the customer level$/) do
  roles = all("[name='access_right[role]'] option")
  expect(roles.size).to eq 2
  values = roles.map(&:value)
  expect(values.include? 'no_access').to be true
  expect(values.include? 'customer').to be true
end

When(/^I do not enter any responsible person for the delegation$/) do
  expect(find("input[name='user[delegator_user_id]']", visible: false)['value'].empty?).to be true
end

When(/^I do not enter any name$/) do
  find("input[name='user[firstname]']").set ''
end

When(/^I change the responsible person$/) do
  expect(has_no_selector?('ul.ui-autocomplete')).to be true
  @responsible = @current_inventory_pool.users.not_as_delegations.find {|u| u != @delegation.delegator_user }
  find('.row.emboss', text: _('Responsible')).find("input[data-type='autocomplete']").set @responsible.name
  sleep(0.55) # NOTE this sleep is required waiting the search result
  find('ul.ui-autocomplete > li > a', text: @responsible.name).click
  expect(has_no_selector?('ul.ui-autocomplete')).to be true
end

When(/^I delete an existing user from the delegation$/) do
  @delegated_users = @delegation.delegated_users
  inline_user_entry = find('.row.emboss', text: _('Users')).find('[data-users-list] .row.line', match: :first)
  @removed_delegated_user = User.find {|u| u.name == inline_user_entry.find('[data-user-name]').text}
  inline_user_entry.find('button[data-remove-user]').click
  @delegated_users.delete @removed_delegated_user
end

When(/^I add a user to the delegation$/) do
  expect(has_no_selector?('ul.ui-autocomplete')).to be true
  find('[data-search-users]').set ' '
  el = find('ul.ui-autocomplete > li > a', match: :first)
  user_name = el.text
  @delegated_users << User.find {|u| u.name == user_name}
  el.click
  expect(has_no_selector?('ul.ui-autocomplete')).to be true
  find('#users .line', text: user_name)
end

Then(/^the edited delegation is saved with its current information$/) do
  expect(@delegation.reload.delegator_user).to eq @responsible
  @delegation.delegated_users.each {|du| @delegated_users.include? du}
  @delegation.delegated_users.count == (@delegated_users + [@responsible]).uniq.count
  expect(@delegation.groups).to eq @current_inventory_pool.groups
end

When(/^I edit a delegation that has access to the current inventory pool$/) do
  @delegation = @current_inventory_pool.users.find {|u| u.delegation? and not u.visits.take_back.exists? and u.inventory_pools.count >= 2}
  expect(@delegation).not_to be_nil
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @delegation)
end

When(/^I remove access to the current inventory pool from this delegation$/) do
  @ip_name = @current_inventory_pool.name
  select _('No access'), from: 'access_right[role]'
end

Then(/^no orders can be created for this delegation in the current inventory pool$/) do
  step 'I log out'
  step %Q(I am logged in as '#{@delegation.delegator_user.login}' with password 'password')
  find('.dropdown-holder', text: @current_user.lastname).click
  find(".dropdown-item[href*='delegations']").click
  find('.row.line', text: @delegation.name).click_link _('Switch to')
  FastGettext.set_locale @delegation.language.locale_name # switch the locale in order to translate properly in the next step
  find('.topbar-item', text: _('Inventory Pools')).click
  expect(has_no_content?(@ip_name)).to be true
end

When(/^I create an order for a delegation$/) do
  steps %{
    When I hover over my name
    And I click on "Delegations"
    Then I see the delegations I am assigned to
    When I pick a delegation to represent
    Then I am logged in as that delegation
    Given I am listing models
    When I add an existing model to the order
    Then the calendar opens
    When everything I input into the calendar is valid
    Then the model has been added to the order with the respective start and end date, quantity and inventory pool
    When I open my list of orders
    And I enter a purpose
    And I take note of the contract
    And I submit the order
    And I reload the order
    Then the order's status changes to submitted
    And the delegation is saved as borrower
  }
end

When(/^I hand over the items ordered for this delegation to "(.*?)"$/) do |contact_person|
  @contract = @delegation.reservations_bundles.submitted.first
  @contract.approve Faker::Lorem.sentence
  visit manage_hand_over_path(@current_inventory_pool, @delegation)
  expect(has_selector?('input[data-assign-item]')).to be true
  all('input[data-assign-item]').detect{|el| not el.disabled?}.click
  find('.ui-autocomplete .ui-menu-item', match: :first).click
  expect(has_selector? '[data-remove-assignment]').to be true
  find('.multibutton button[data-hand-over-selection]').click
  @contact = User.find_by_login(contact_person.downcase)
  #step "ich die Kontaktperson wechsle"
  step 'I change the contact person'
  within '.modal' do
    find('.button.green[data-hand-over]', text: _('Hand Over')).click
    expect(has_content?(_('Hand over completed'))).to be true
    expect(has_no_selector?('button[data-hand-over]')).to be true
  end
end

Then(/^"(.*?)" is the new contact person for this contract$/) do |contact_person|
  expect(@delegation.reservations_bundles.signed.first.delegated_user).to eq @contact
end

Then(/^the hand over shows the user$/) do
  find('.content-wrapper', text: @new_user.name, match: :first)
  expect(current_path).to eq manage_hand_over_path(@current_inventory_pool, @new_user)
  expect(@delegation.visits.hand_over.where(inventory_pool_id: @current_inventory_pool).empty?).to be true
end

Then(/^I open a hand over for a delegation$/) do
  @hand_over = @current_inventory_pool.visits.hand_over.find {|v| v.user.delegation? }
  @delegation = @hand_over.user
  visit manage_hand_over_path @current_inventory_pool, @delegation
end

When(/^I pick a delegation instead of a user$/) do
  @contract ||= @hand_over.reservations.map(&:contract).uniq.first
  @user = @contract.user
  @delegation = @current_inventory_pool.users.as_delegations.order('RAND()').first
  expect(has_selector?('input[data-select-lines]', match: :first)).to be true
  step 'I select all reservations selecting all linegroups'
  multibutton = first('.multibutton', text: _('Hand Over Selection')) || first('.multibutton', text: _('Edit Selection'))
  multibutton.find('.dropdown-toggle').click if multibutton
  find('#swap-user', match: :first).click
  find('.modal', match: :first)
  find('#user input#user-id', match: :first).set @delegation.name
  find('.ui-menu-item a', match: :first, text: @delegation.name).click
end


When(/^I pick a contact person from the delegation$/) do
  @contact = @delegation.delegated_users.order('RAND()').first
  find('#contact-person input#user-id', match: :first).click
  find('#contact-person input#user-id', match: :first).set @contact.name
  find('.ui-menu-item a', match: :first, text: @contact.name).click
end

Then(/^the order shows the delegation$/) do
  expect(has_content?(@delegation.name)).to be true
end

Then(/^the order shows the name of the contact person$/) do
  expect(has_content?(@contact.name)).to be true
end

When(/^I confirm the user change$/) do
  find(".modal button[type='submit']").click
end

When(/^I hand over the items$/) do
  line = find(".line[data-line-type='item_line'] input[id*='assigned-item'][value][disabled]", match: :first).find(:xpath, 'ancestor::div[@data-line-type]')
  line.find('input[data-select-line]').click
  find('.multibutton', text: _('Hand Over Selection')).find('button').click
end

Then(/^I have to specify a contact person$/) do
  within '.modal' do
    find('.button.green[data-hand-over]', text: _('Hand Over')).click
    expect(has_selector?('#contact-person')).to be true
    expect(find('#error').text.empty?).to be false
  end
end

Then(/^the newly selected contact person is saved$/) do
  @contract.reservations.each do |line|
    expect(line.reload.delegated_user).to eq @contact
  end
end

Then(/^I see exactly one contact person field$/) do
  find('#contact-person')
end

When(/^I do not enter any contact person$/) do
  expect(find('#contact-person input#user-id', match: :first).value.empty?).to be true
end

Then(/^an error message pops up saying "(.*?)"$/) do |text|
  expect(has_selector?('.modal .red', text: text)).to be true
end

When(/^I finish this hand over$/) do
  find(:xpath, "//*[@data-line-type and descendant::*[contains(@id, 'assigned-item')]]//*[@data-select-line]", match: :first).click
  find('button[data-hand-over-selection]').click
end

When(/^I choose a suspended contact person$/) do
  delegated_user = @hand_over.user.delegated_users.order('RAND()').detect {|u| u.suspended? @current_inventory_pool}
  find('input#user-id', match: :first).set delegated_user.name
  find('.ui-menu-item a', match: :first, text: delegated_user.name).click
end

Given(/^I am editing a delegation$/) do
  @delegation = @current_inventory_pool.users.as_delegations.order('RAND()').first
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @delegation)
end

When(/^I assign a responsible person that is suspended for the current inventory pool$/) do
  @responsible = @current_inventory_pool.users.order('RAND()').detect {|u| u.suspended? @current_inventory_pool}
  #step 'ich genau einen Verantwortlichen eintrage'
  step 'I enter exactly one responsible person'
end

Given(/^I swap the user$/) do
  click_button 'swap-user'
  find('.modal', match: :first)
end

Given(/^I pick a delegation$/) do
  @delegation = @current_inventory_pool.users.as_delegations.order('RAND()').first
  find('#user input#user-id', match: :first).set @delegation.name
  find('.ui-menu-item a', match: :first, text: @delegation.name).click
end

When(/^I pick a contact person that is suspended for the current inventory pool$/) do
  delegated_user = @delegation.delegated_users.order('RAND()').detect {|u| u.suspended? @current_inventory_pool}
  delegated_user ||= begin
    user = @delegation.delegated_users.order('RAND()').first
    ensure_suspended_user(user, @current_inventory_pool)
    user
  end
  find('input#user-id', match: :first).set delegated_user.name
  find('.ui-menu-item a', match: :first, text: delegated_user.name).click
end


And(/^I take note of the contract$/) do
  @contracts = @current_user.reservations_bundles.unsubmitted
end


And(/^I reload the order$/) do
  reloaded_contracts = @contracts.map do |contract|
    contract.user.reservations_bundles.find_by(status: :submitted, inventory_pool_id: contract.inventory_pool)
  end
  @contracts = reloaded_contracts
end

When(/^I switch from my user to a delegation$/) do
  steps %{
          When I hover over my name
          And I click on "Delegations"
          Then I see the delegations I am assigned to
          When I pick a delegation to represent
          Then I am logged in as that delegation
        }
end

When(/^that delegation is enabled for an inventory pool$/) do
  @inventory_pool = @delegation.inventory_pools.where(id: @delegated_user.inventory_pools).order("RAND()").first
end

When(/^I am suspended in that inventory pool$/) do
  ensure_suspended_user(@delegated_user, @inventory_pool)
end

Then(/^I cannot place any reservations in this inventory pool$/) do
  steps %{
          And I add a model to an order
          When I open my list of orders
          When I enter a purpose
          And I submit the order
          And I see an error message
        }
end
