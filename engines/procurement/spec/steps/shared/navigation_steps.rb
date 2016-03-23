# rubocop:disable Metrics/ModuleLength
module NavigationSteps

  step 'I navigate to procurement' do
    visit procurement.root_path
  end

  step 'I am navigated to the new request form' do
    @user = @current_user
    step 'I am navigated to the new request form for the requester'
  end
  # alias
  step 'I am navigated to the new request form of the specific group' do
    step 'I am navigated to the new request form'
  end

  step 'I am navigated to the new request form for the requester' do
    # NOTE this doesn't match the query params
    # expect(current_path).to eq

    # NOTE instead this matches the query params
    expect(page).to have_current_path \
      procurement.group_budget_period_user_requests_path(
        @group,
        Procurement::BudgetPeriod.current,
        @user,
        request_id: :new_request)
  end

  step 'I am navigated to the requester list' do
    expect(current_path).to eq \
      procurement.choose_group_budget_period_users_path(
        @group,
        Procurement::BudgetPeriod.current)

    within '.panel-success .list-group' do
      Procurement::Access.requesters.each do |requester|
        find('a', text: requester.user.to_s)
      end
    end
  end

  step 'I am navigated to the template request form of the specific group' do
    expect(page).to have_current_path \
      procurement.group_budget_period_user_requests_path(
        @template.template_category.group,
        Procurement::BudgetPeriod.current,
        @current_user,
        template_id: @template.id)
  end

  step 'I am navigated to the templates overview' do
    expect(page).to have_current_path \
      procurement.new_user_budget_period_request_path(
        @current_user,
        Procurement::BudgetPeriod.current)

    within '.panel-success .panel-body' do
      find('h4', text: _('Choose an article/project'))
      find('h4', text: _('Add article for specific group'))
    end
  end

  step 'I navigate to the templates overview' do
    visit procurement.new_user_budget_period_request_path(
      @current_user,
      Procurement::BudgetPeriod.current)
  end

  step 'I am on the new request form of a group' do
    @group ||= Procurement::Group.first.name
    visit procurement.group_budget_period_user_requests_path(
      @group,
      Procurement::BudgetPeriod.current,
      @current_user)
  end

  step 'I navigate to the requests overview page' do
    if has_no_selector? '.navbar .navbar-right', text: _('Procurement')
      visit procurement.root_path
    end
    within '.navbar' do
      click_on _('Requests')
    end
    step 'page has been loaded'
    expect(page).to have_selector('h4', text: _('Requests'))
  end
  # alias
  step 'I navigate back to the request overview page' do
    step 'I navigate to the requests overview page'
  end

  step 'I navigate to the requests form of :name' do |name|
    user = case name
           when 'myself' then @current_user
           else
               User.find_by(firstname: name)
           end
    path = procurement.group_budget_period_user_requests_path(
      @group,
      Procurement::BudgetPeriod.current,
      user)
    visit path
    expect(page).to have_current_path path
    find '.panel-heading h4', text: user.name
  end

  step 'I navigate to the budget periods' do
    if has_no_selector? '.navbar .navbar-right', text: _('Procurement')
      visit procurement.root_path
    end
    within '.navbar' do
      click_on _('Admin')
      click_on _('Budget periods')
    end
    expect(page).to have_selector('h1', text: _('Budget periods'))
  end

  step 'I navigate to the groups page' do
    if has_no_selector? '.navbar .navbar-right', text: _('Procurement')
      visit procurement.root_path
    end
    within '.navbar' do
      click_on _('Admin')
      click_on _('Groups')
    end
    expect(page).to have_selector('h1', text: _('Groups'))
  end

  step 'I navigate to the organisation tree page' do
    if has_no_selector? '.navbar .navbar-right', text: _('Procurement')
      visit procurement.root_path
    end
    within '.navbar' do
      click_on _('Admin')
      click_on _('Organisations')
    end
    expect(page).to have_selector('h1', text: _('Organisations of the requesters'))
  end

  # step 'I navigate to the users list' do
  #   visit procurement.users_path
  # end
  step 'I navigate to the users page' do
    if has_no_selector? '.navbar .navbar-right', text: _('Procurement')
      visit procurement.root_path
    end
    within '.navbar' do
      click_on _('Admin')
      click_on _('Users')
    end
    expect(page).to have_selector('h1', text: _('Users'))
  end

  step 'I navigate to the templates page of my group' do
    # NOTE refresh the page
    if has_no_selector? '.navbar', text: _('Templates')
      visit procurement.root_path
    end

    within '.navbar' do
      click_on _('Templates')
      click_on @group.name
    end
    expect(page).to have_selector('h1', text: _('Templates'))
  end
  # alias
  step 'I navigate to the templates page' do
    step 'I navigate to the templates page of my group'
  end

  step 'I pick a requester' do
    within '.panel-success .list-group' do
      requester = Procurement::Access.requesters
                  .where.not(user_id: @current_user).first
      @user = requester.user
      find('a', text: @user.to_s).click
    end
  end

end
# rubocop:enable Metrics/ModuleLength
