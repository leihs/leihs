# -*- encoding : utf-8 -*-

Given(/^I am in the admin area's groups section$/) do
  visit manage_inventory_pool_groups_path(@current_inventory_pool)
end


Then(/^I am listing groups$/) do
  @current_inventory_pool.groups.reload.each do |group|
    find('.list-of-lines .line strong', text: group.name)
  end
end

Then(/^each group shows the number of users assigned to it$/) do
  @current_inventory_pool.groups.each do |group|
    within('.line', text: group.name) do
      find('.line-col', text: '%d %s' % [group.users.size, _('Users')])
    end
  end
end

Then(/^each group shows how many of each model are assigned to it$/) do
  @current_inventory_pool.groups.each do |group|
    within('.line', text: group.name) do
      find('.line-col', text: '%d %s' % [group.models.size, _('Models')])
      find('.line-col', text: '%d %s' % [group.partitions.to_a.sum(&:quantity), _('Allocations')])
    end
  end
end

Then(/^the list is sorted alphabetically$/) do
  expect((all('.list-of-lines .line strong').map(&:text).to_json == @current_inventory_pool.groups.map(&:name).sort.to_json)).to be true
end

When(/^I create a group$/) do
  find('.button', text: _('New Group')).click
end

When(/^I fill in the group's name$/) do
  @name = Faker::Name.name
  fill_in 'group[name]', with: @name
end


When(/^I add users to the group$/) do
  @users = @current_inventory_pool.users.customers
  @users.each do |user|
    find('input[data-search-users]').set user.name
    find('.ui-menu-item a', match: :prefer_exact, text: user.name).click
  end
end

When(/^I add models and capacities to the group$/) do
  @models = @current_inventory_pool.models[0..2]
  @partitions = []
  @models.each do |model|
    find('input[data-search-models]').set model.name
    find('.ui-menu-item a', match: :prefer_exact, text: model.name).click
    borrowable_items = model.items.where(inventory_pool_id: @current_inventory_pool.id).borrowable.size - 1
    partition = {model_id: model.id, quantity: (borrowable_items.zero? ? 0 : rand(borrowable_items)) + 1}
    @partitions.push partition
    find('.list-of-lines .line', text: model.name).fill_in 'group[partitions_attributes][][quantity]', with: partition[:quantity]
  end
end

Then(/^the group is saved$/) do
  step 'I receive a notification of success'
  @group = Group.find_by_name @name
  expect(@group).not_to be_nil
end

Then(/^the group has users as well as models and their capacities$/) do
  expect(@group.users.reload.map(&:id).sort).to eq @users.map(&:id).sort
  expect(Set.new(@group.partitions.map{|p| {model_id: p.model_id, quantity: p.quantity}})).to eq Set.new(@partitions)
end

Then(/^the group list is sorted alphabetically$/) do
  step 'I am listing groups'
  step 'the list is sorted alphabetically'
end

When(/^I edit an existing( non verifiable| verifiable)? group$/) do |arg1|
  groups = @current_inventory_pool.groups
  groups = case arg1
             when ' non verifiable'
               groups.where(is_verification_required: false)
             when ' verifiable'
               groups.where(is_verification_required: true)
             else
               groups
           end
  @group = groups.find {|g| g.models.length >= 2 and g.users.length >= 2}
  visit manage_edit_inventory_pool_group_path @group.inventory_pool_id, @group
end

When(/^I (de)?select 'Verification required'$/) do |arg1|
  select (arg1 ? _('No') : _('Yes')), from: 'group_is_verification_required'
end

Then(/^the group (requires|doesn't require) verification$/) do |arg1|
  expect(@group.is_verification_required).to be (arg1 == 'requires')
end

When(/^I change the group's name$/) do
  @name = Faker::Name.name
  fill_in 'group[name]', with: @name
end

When(/^I add and remove users from the group$/) do
  @users = @group.users
  @users.sample(@users.size/2).each do |user|
    find("input[name='group[users][][id]'][value='#{user.id}']", visible: false).first(:xpath, './..').find('.button[data-remove-user]', text: _('Remove')).click
    @users.delete user
  end
end

When(/^I add and remove models and their capacities from the group$/) do
  all("[name='group[partitions_attributes][][quantity]']").each do |existing_partition_line|
    existing_partition_line.first(:xpath, './../../..').find('.button[data-remove-group]', text: _('Remove')).click
  end
  model = (@current_inventory_pool.models-@group.models).first
  find('input[data-search-models]').set model.name
  find('.ui-menu-item a', match: :prefer_exact, text: model.name).click
  partition = {model_id: model.id, quantity: rand(1..model.items.where(inventory_pool_id: @current_inventory_pool.id).borrowable.size)}
  @partitions = [partition]
  find('.list-of-lines .line', text: model.name).fill_in 'group[partitions_attributes][][quantity]', with: partition[:quantity]
end


Then(/^I see any capacities that are still available for assignment$/) do
  @partitions.each do |partition|
    model = Model.find partition[:model_id]
    expect(all("input[value='#{model.id}']", visible: false).first.parent.has_content?("/ #{model.items.where(inventory_pool_id: @current_inventory_pool.id).borrowable.size}")).to be true
  end
end

When(/^I delete a group$/) do
  @group = @current_inventory_pool.groups.detect &:can_destroy?
  visit manage_inventory_pool_groups_path @current_inventory_pool
  within('.list-of-lines .line', text: @group.name) do
    within('.multibutton') do
      find('.dropdown-toggle').click
      find('.dropdown-item.red', text: _('Delete')).click
    end
  end
end

Then(/^the group has been deleted from the database$/) do
  expect(Group.find_by_name(@group.name)).to eq nil
end


When(/^I add one user to the group$/) do
  fill_in_autocomplete_field _('Users'), @user_name = @current_inventory_pool.users.order('RAND()').first.name
end

Then(/^the user is added to the top of the list$/) do
  find('#users .list-of-lines .line [data-user-name]', text: @user_name)
end


When(/^I add a model to the group$/) do
  @model = @current_inventory_pool.models.order('RAND()').first
  fill_in_autocomplete_field _('Models'), @model.name
end

Then(/^the model is added to the top of the list$/) do
  expect(has_selector?('#models-allocations .list-of-lines .line', text: @model.name)).to be true
  find('#models-allocations .list-of-lines .line', match: :first, text: @model.name)
end


Then(/^the already present models are sorted alphabetically$/) do
  within('#models-allocations') do
    entries = all('.list-of-lines .line', minimum: 1)
    expect(entries.map(&:text).sort).to eq entries.map(&:text)
  end
end

When(/^I add a model that is already present in the group$/) do
  @model = @group.models.order('RAND()').first
  @quantity = 2
  find('#models-allocations .list-of-lines .line', match: :prefer_exact, text: @model.name).fill_in 'group[partitions_attributes][][quantity]', with: @quantity
  fill_in_autocomplete_field _('Models'), @model.name
end

Then(/^the model is not added again$/) do
  find '.row.emboss', match: :prefer_exact, text: _('Models')
  find('#models-allocations .list-of-lines .line', text: @model.name)
end

When(/^I add a user that is already present in the group$/) do
  @user = @group.users.order('RAND()').first
  fill_in_autocomplete_field _('Users'), @user.name
end

Then(/^the already existing user is not added$/) do
  find('#users .list-of-lines .line', text: @user.name)
end

Then(/^the already existing model slides to the top of the list$/) do
  find('#models-allocations .list-of-lines .line', match: :first, text: @model.name)
end

Then(/^the already existing user slides to the top of the list$/) do
  find('#users .list-of-lines .line', match: :first, text: @user.name)
end

Then(/^the already existing model keeps whatever capacity was set for it$/) do
  expect(find('#models-allocations .list-of-lines .line', match: :prefer_exact, text: @model.name).find("input[name='group[partitions_attributes][][quantity]']").value.to_i).to eq @quantity
end
