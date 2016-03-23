require_relative 'shared/common_steps'
require_relative 'shared/dataset_steps'
require_relative 'shared/navigation_steps'
require_relative 'shared/personas_steps'

steps_for :procurement_groups do
  include CommonSteps
  include DatasetSteps
  include NavigationSteps
  include PersonasSteps

  step 'I click on the add button' do
    click_on _('Add')
  end

  step 'there exist(s) :count user(s) to become the inspector(s)' do |count|
    @inspectors = []
    count.to_i.times do
      @inspectors << find_or_create_user(Faker::Name.first_name)
    end
  end

  step 'I fill in the name' do
    @name = Faker::Lorem.word
    find("input[name='group[name]']").set @name
  end

  step 'I fill in the inspectors\' names' do
    @inspectors.each do |inspector|
      add_to_inspectors_field inspector.name
    end
  end

  step 'I fill in the email' do
    @email = Faker::Internet.email
    find("input[name='group[email]']").set @email
  end

  step 'I fill in the budget limit' do
    @limit = 1000
    set_budget_limit @budget_period.name, @limit
  end

  step 'a budget period exist' do
    @budget_period = FactoryGirl.create(:procurement_budget_period)
  end

  step 'I am redirected to the groups index page' do
    expect(current_path).to eq '/procurement/groups'
  end

  step 'the new group appears in the list' do
    find('table').find('tr', text: @name)
  end

  step 'the new group was created in the database' do
    group = Procurement::Group.find_by_name(@name)
    expect(group).to be
    expect(group.name).to eq @name
    expect(group.email).to eq @email
    @inspectors.each do |inspector|
      expect(group.inspectors).to include inspector
    end
    expect(group.budget_limits.first.amount_cents).to eq (@limit * 100)
  end

  step 'the procurement groups are sorted 0-10 and a-z' do
    names = all('table tbody tr td:first-child', minimum: 1).map(&:text)

    # sorted_numbers_strings = @groups.map(&:name)
    #           .partition { |x| not x.is_a? String }
    #           .map(&:sort).flatten
    # expect(names).to eq sorted_numbers_strings

    expect(names).to eq names.sort
  end

  step 'there exists :count budget limits for the procurement group' do |count|
    @group.budget_limits.delete_all
    count.to_i.times do
      @group.budget_limits << FactoryGirl.create(:procurement_budget_limit)
    end
  end

  step 'the procurement group has :count inspectors' do |count|
    @group.inspectors.delete_all
    count.to_i.times do
      @group.inspectors << find_or_create_user(Faker::Name.first_name)
    end
  end

  step 'I navigate to the group\'s edit page' do
    visit procurement.edit_group_path(@group)
  end

  step 'I modify the name' do
    @new_name = Faker::Lorem.word
    find("input[name='group[name]']").set @new_name
  end

  step 'I delete an inspector' do
    @deleted_inspector = @group.inspectors.first
    @rest_inspectors = (@group.inspectors - [@deleted_inspector])
    find('.row', text: _('Inspectors'))
      .find('.token-input-token', text: @deleted_inspector.name)
      .find('.token-input-delete-token')
      .click
  end

  step 'I add an inspector' do
    @new_inspector = find_or_create_user(Faker::Name.first_name)
    add_to_inspectors_field @new_inspector.name
  end

  step 'I modify the email address' do
    @new_email = Faker::Internet.email
    find("input[name='group[email]']").set @new_email
  end

  step 'I delete a budget limit' do
    @deleted_budget_limit = @group.budget_limits.first
    set_budget_limit @deleted_budget_limit.budget_period.name, 0
  end

  step 'I add a budget limit' do
    @new_limit = 2000
    set_budget_limit @extra_budget_period.name, @new_limit
  end

  step 'I modify a budget limit' do
    @modified_limit = 3000
    @modified_budget_limit = @group.budget_limits.last
    set_budget_limit @modified_budget_limit.budget_period.name, @modified_limit
  end

  step 'there exists an extra budget period' do
    @extra_budget_period = FactoryGirl.create(:procurement_budget_period)
  end

  step 'I see that the all the information ' \
       'of the procurement group was updated correctly' do
    group_line = find('table tr', text: @new_name)
    expect(group_line.text).to have_content @new_inspector.name
    expect(group_line.text).not_to have_content @deleted_inspector.name
    @rest_inspectors.each do |r_inspector|
      expect(group_line.text).to have_content r_inspector.name
    end
    expect(group_line.text).to have_content @new_email
  end

  step 'all the information of the procurement group ' \
       'was successfully updated in the database' do
    @group.reload
    expect(@group.name).to eq @new_name
    expect(@group.inspectors.map(&:name)).to include @new_inspector.name
    expect(@group.inspectors.map(&:name)).not_to include @deleted_inspector.name
    @rest_inspectors.each do |r_inspector|
      expect(@group.inspectors.map(&:name)).to include r_inspector.name
    end
    expect(@group.email).to eq @new_email
    expect(@group.budget_limits.count).to eq 3
    expect(
      @group
      .budget_limits
      .find_by_budget_period_id(@extra_budget_period.id)
      .amount_cents
    )
      .to eq (@new_limit * 100)
    expect(
      @group
      .budget_limits
      .find_by_budget_period_id(@modified_budget_limit.budget_period_id)
      .amount_cents
    )
      .to eq (@modified_limit * 100)
    expect(
      @group
      .budget_limits
      .find_by_budget_period_id(@deleted_budget_limit.budget_period_id)
      .amount_cents
    )
      .to eq 0
  end

  step 'there exists a procurement group without any requests' do
    @group = FactoryGirl.create(:procurement_group)
    expect(@group.requests).to be_empty
  end

  step 'I delete the group' do
    group_line = find('table tbody tr', text: @group.name)
    group_line.find('.dropdown-toggle').click
    accept_alert { group_line.click_on _('Delete') }
  end

  step 'the group disappears from the list' do
    expect(find('table')).not_to have_content @group.name
  end

  step 'the group was successfully deleted from the database' do
    expect { @group.reload }.to raise_error ActiveRecord::RecordNotFound
  end

  step 'the group line contains the name of the group' do
    group_line = find('table tbody tr', text: @group.name)
    expect(group_line).to have_content @group.name
  end

  step 'the group line contains the name of the group\'s inspectors' do
    group_line = find('table tbody tr', text: @group.name)
    @group.inspectors.each do |inspector|
      expect(group_line).to have_content inspector.name
    end
  end

  step 'the group line contains the email of the group' do
    group_line = find('table tbody tr', text: @group.email)
    expect(group_line).to have_content @group.name
  end

  step 'there does not exist any procurement group yet' do
    expect(Procurement::Group.exists?).to be false
  end

  step 'I leave the name empty' do
    expect(find("input[name='group[name]']").value).to be_empty
  end

  step 'I see the name field marked red' do
    expect(find("input[name='group[name]']")['required']).to eq 'true' # ;-)
  end

  step 'the name is still marked red' do
    step 'I see the name field marked red'
  end

  step 'the new group has not been created' do
    expect(Procurement::Group.exists?).to be false
  end

  private

  def add_to_inspectors_field(name)
    within '.row', text: _('Inspectors') do
      find('input').set name
    end
    # OPTIMIZE: click should be on a <li>
    find('.token-input-dropdown', text: name).click
  end

  def set_budget_limit(name, limit)
    find('.row', text: name)
      .find("input[name*='amount']")
      .set limit
  end
end
