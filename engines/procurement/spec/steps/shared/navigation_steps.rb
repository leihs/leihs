# rubocop:disable Metrics/ModuleLength
module NavigationSteps

  step 'I navigate to leihs' do
    visit main_app.root_path
  end

  step 'I navigate to procurement' do
    visit procurement.root_path
  end

  step 'I am navigated to the new request form' do
    @user = @current_user
    step 'I am navigated to the new request form for the requester'
  end
  # alias
  # step 'I am navigated to the new request form of the specific group' do
  #   step 'I am navigated to the new request form'
  # end

  step 'I am navigated to the new request form for the requester' do
    # NOTE this doesn't match the query params
    # expect(current_path).to eq

    # NOTE instead this matches the query params
    expect(page).to have_current_path \
      procurement.category_budget_period_user_requests_path(
        @category,
        Procurement::BudgetPeriod.current,
        @user,
        request_id: :new_request)
  end

  step 'I am navigated to the request form' do
    expect(page).to have_current_path \
      procurement.category_budget_period_user_requests_path(
        @category,
        @budget_period,
        @current_user,
        request_id: :new_request)
  end

  step 'I am navigated to the request form highlighting the template' do
    expect(page).to have_current_path \
      procurement.category_budget_period_user_requests_path(
        @category,
        @budget_period,
        @current_user,
        template_id: @template)
  end

  step 'I am navigated to the requester list' do
    expect(current_path).to eq \
      procurement.choose_category_budget_period_users_path(
        @category,
        Procurement::BudgetPeriod.current)

    within '.panel-success .list-group' do
      Procurement::Access.requesters.each do |requester|
        find('a', text: requester.user.to_s)
      end
    end
  end

  step 'I am navigated to the template request form of the specific group' do
    expect(page).to have_current_path \
      procurement.category_budget_period_user_requests_path(
        @template.category,
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
      find('h4', text: _('Choose a suggested article or a category'))
    end
  end

  step 'I am on the request form of a sub category' do
    @category ||= Procurement::Category.first
    visit procurement.category_budget_period_user_requests_path(
      @category,
      Procurement::BudgetPeriod.current,
      @current_user)
  end

  step 'I am navigated to the users page' do
    expect(page).to have_selector('h1', text: _('Users'))
  end

  step 'I am redirected to leihs' do
    expect(current_path).not_to include 'procurement'
  end

  step 'I confirm the alert popup' do
    alert = page.driver.browser.switch_to.alert
    alert.accept
    expect { page.driver.browser.switch_to.alert }.to \
      raise_error Selenium::WebDriver::Error::NoSuchAlertError
  end

  step 'I do not see a link to procurement' do
    within 'header .topbar-navigation.float-right' do
      current_scope.click
      expect(current_scope).to \
        have_no_selector '.dropdown-item', text: _('Procurement')
    end
  end

  step 'I navigate to the templates overview' do
    visit procurement.new_user_budget_period_request_path(
      @current_user,
      Procurement::BudgetPeriod.current)
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
    path = procurement.category_budget_period_user_requests_path(
      @category,
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

  step 'I navigate to the categories (edit )page' do
    if has_no_selector? '.navbar .navbar-right', text: _('Procurement')
      visit procurement.root_path
    end
    within '.navbar' do
      click_on _('Admin')
      click_on _('Categories')
    end
    expect(page).to have_selector('h1', text: _('Categories'))
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
  step 'I navigate to the users page:confirm' do |confirm|
    if has_no_selector? '.navbar .navbar-right', text: _('Procurement')
      visit procurement.root_path
    end
    within '.navbar' do
      click_on _('Admin')
      click_on _('Users')
    end
    step 'I confirm the alert popup' if confirm
    step 'I am navigated to the users page'
  end

  step 'I navigate to the templates page' do
    # NOTE refresh the page
    if has_no_selector? '.navbar', text: _('Templates')
      visit procurement.root_path
    end

    within '.navbar' do
      click_on _('Templates')
    end

    expect(current_path).to be == procurement.templates_path
    expect(page).to have_selector('h3', text: _('Templates'))
  end

  step 'I navigate to the settings page' do
    if has_no_selector? '.navbar .navbar-right', text: _('Procurement')
      visit procurement.root_path
    end
    within '.navbar' do
      click_on _('Admin')
      click_on _('Settings')
    end
    expect(page).to have_selector('h1', text: _('Settings'))
  end

  step 'I pick a requester' do
    within '.panel-success .list-group' do
      requester = Procurement::Access.requesters
                  .where.not(user_id: @current_user).first
      @user = requester.user
      find('a', text: @user.to_s).click
    end
  end

  step 'I type the procurement URL' do
    visit procurement.root_path
  end
end
# rubocop:enable Metrics/ModuleLength
