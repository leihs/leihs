require_relative 'shared/common_steps'
require_relative 'shared/dataset_steps'
require_relative 'shared/navigation_steps'
require_relative 'shared/personas_steps'

steps_for :roles do
  include CommonSteps
  include DatasetSteps
  include NavigationSteps
  include PersonasSteps

  step 'I am not a procurement admin' do
    access = Procurement::Access.admins.find_by(user_id: @current_user.id)
    expect(access).to be nil
  end

  step 'I am not a requester' do
    access = Procurement::Access.requesters.find_by(user_id: @current_user.id)
    expect(access).to be nil
  end

  step 'I am not an inspector' do
    bool = Procurement::Category.inspector_of_any_category? @current_user
    expect(bool).to be false
  end

  step 'I can create a request for myself' do
    visit procurement.overview_requests_path
    find("a[href*='requests/new']").click
    find('.panel-info .panel-heading', match: :first).click
    find("a[href*='new_request']").click
  end

  step 'I can edit my request' do
    prepare_request
    go_to_request
    find("[name='requests[#{@request.id}][article_name]']").set Faker::Lorem.word
    step 'I click on save'
    step 'I see the saved message'
  end

  step 'I can delete my request' do
    prepare_request
    go_to_request
    find(".row[data-request_id='#{@request.id}'] button .fa-gear").click
    accept_alert do
      click_link _('Delete')
    end
    expect(page).to have_content _('Deleted')
  end

  step 'I can not see the field "order quantity"' do
    prepare_request
    go_to_request
    expect(page).to have_no_selector "input[name*='order_quantity']"
  end

  step 'I can not see the field "approved quantity"' do
    prepare_request
    go_to_request
    expect(page).to have_no_selector "input[name*='approved_quantity']"
  end

  step 'I can not see the field "inspection comment"' do
    prepare_request
    go_to_request
    expect(page).to have_no_selector "input[name*='inspection_comment']"
  end

  step 'I :boolean modify the field of other person\'s request' do |boolean, table|
    table.raw.flatten.each do |field|
      requester = FactoryGirl.create(:user)
      FactoryGirl.create(:procurement_access,
                         user: requester,
                         organization: \
                         FactoryGirl.create(:procurement_organization))
      prepare_request requester: requester
      @category.inspectors << @current_user
      go_to_request user: requester

      if boolean
        case field
        when 'order quantity'
          find("[name='requests[#{@request.id}][order_quantity]']").set 5
        when 'approved quantity'
          find("[name='requests[#{@request.id}][approved_quantity]']").set 5
        when 'inspection comment'
          find("[name='requests[#{@request.id}][inspection_comment]']")
              .set Faker::Lorem.word
        end

        step 'I click on save'
        step 'I see the saved message'

      else
        case field
        when 'motivation'
          expect(page).to have_no_selector \
            "[name='requests[#{@request.id}][motivation]']"
          within '.form-group', text: _('Motivation') do
            find '.col-xs-8', text: @request.motivation
          end
        when 'priority'
          expect(page).to have_no_selector \
            "[name='requests[#{@request.id}][priority]']"
          within '.form-group', text: _('Priority') do
            find '.col-xs-8', text: _(@request.priority.capitalize)
          end
        when 'requested quantity'
          expect(page).to have_no_selector \
            "[name='requests[#{@request.id}][requested_quantity]']"
          within '.form-group', text: _('Requested quantity') do
            find '.col-xs-4', text: @request.requested_quantity
          end
        end
      end
    end
  end

  step 'I can export the data' do
    FactoryGirl.create(:procurement_request)
    step 'I navigate to procurement'
    find('button', text: _('CSV export')).click
    find('body').click
  end

  step 'I can write an email to a group from the view of my request' do
    prepare_request
    go_to_request
    find("a[href*='mailto:#{@group.email}']")
  end

  step 'I can write an email to a group from the view of other\'s request' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    unless Procurement::Access.admins.find_by(user_id: @current_user.id)
      @group.inspectors << @current_user
    end
    go_to_request user: requester
    find("a[href*='mailto:#{@group.email}']")
  end

  step 'I can move requests to other budget periods' do
    new_budget_period = FactoryGirl.create(:procurement_budget_period)
    prepare_request
    go_to_request
    find(".row[data-request_id='#{@request.id}'] button .fa-gear").click
    find("a[href*='move?to_budget_period_id=#{new_budget_period.id}']")
      .click
    expect(page).to have_content _('Request moved')
  end

  step 'I can move requests to other categories' do
    new_category = FactoryGirl.create :procurement_category
    prepare_request
    go_to_request
    find(".row[data-request_id='#{@request.id}'] button .fa-gear").click
    find("a[href*='move?to_category_id=#{new_category.id}']").click
    expect(page).to have_content _('Request moved')
  end

  step 'I can not inspect requests' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    expect(@category.inspectors).not_to include @current_user
    go_to_request user: requester
    expect(page).to have_no_selector ".row[data-request_id='#{@request.id}']"
  end

  # step 'I can not inspect requests of my own group' do
  #   requester = FactoryGirl.create(:user)
  #   FactoryGirl.create(:procurement_access,
  #                      user: requester,
  #                      organization: \
  #                        FactoryGirl.create(:procurement_organization))
  #   prepare_request requester: requester
  #   @group.inspectors << @current_user
  #   go_to_request user: requester
  #   step 'I can not inspect certain fields'
  # end

  step 'I can not add requester' do
    expect(find('.navbar').text).not_to match _('Admin')
    visit procurement.users_path
    expect(page).to have_content _('You are not authorized for this action.')
  end

  step 'I can add requesters' do
    visit procurement.users_path
    expect(page).not_to have_content _('You are not authorized for this action.')
    expect(page).to have_selector 'form .fa-plus-circle'
  end

  step 'I can add admins' do
    visit procurement.users_path
    expect(page).not_to have_content _('You are not authorized for this action.')
    find("input[name='admin_ids']", visible: false)
  end

  step 'I can not add administrators' do
    expect(find('.navbar').text).not_to match _('Admin')
    visit procurement.users_path
    expect(page).to have_content _('You are not authorized for this action.')
  end

  step 'I can not add categories' do
    expect(find('.navbar').text).not_to match _('Admin')
    visit procurement.categories_path
    expect(page).to have_content _('You are not authorized for this action.')
  end

  step 'I can not add budget periods' do
    expect(find('.navbar').text).not_to match _('Admin')
    visit procurement.budget_periods_path
    expect(page).to have_content _('You are not authorized for this action.')
  end

  # step 'I can not manage templates' do
  #   group = FactoryGirl.create(:procurement_group)
  #   expect(find('.navbar').text).not_to match _('Templates')
  #   visit procurement.group_templates_path(group_id: group.id)
  #   expect(page).to have_content _('You are not authorized for this action.')
  # end

  step 'I can not create requests for another person' do
    @budget_period = FactoryGirl.create(:procurement_budget_period)
    @category = FactoryGirl.create :procurement_category
    visit procurement.overview_requests_path
    expect(page).to have_no_selector "a[href*='users/choose']"

    visit procurement.choose_category_budget_period_users_path \
      category_id: @category.id,
      budget_period_id: @budget_period.id
    expect(page).to have_content _('You are not authorized for this action.')
  end

  step 'I can not create a request for myself' do
    @budget_period = FactoryGirl.create(:procurement_budget_period)
    @category = FactoryGirl.create :procurement_category
    visit procurement.overview_requests_path
    expect(page).to have_no_selector("a[href*='new_request']")

    visit procurement.choose_category_budget_period_users_path \
      category_id: @category.id,
      budget_period_id: @budget_period.id
    expect(page).to have_content _('You are not authorized for this action.')
  end

  step 'I can not see budget limits' do
    prepare_request
    FactoryGirl.create(:procurement_budget_limit,
                       main_category: @category.main_category,
                       budget_period: @budget_period)
    go_to_request
    expect(page).to have_no_selector '.budget_limit'
  end

  step 'I can edit a request of a category where I am an inspector' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    @category.inspectors << @current_user
    go_to_request user: requester
    find("[name='requests[#{@request.id}][article_name]']").set Faker::Lorem.word
    step 'I click on save'
    step 'I see the saved message'
  end

  step 'I can delete a request of a category where I am an inspector' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    @category.inspectors << @current_user
    go_to_request user: requester
    find(".row[data-request_id='#{@request.id}'] button .fa-gear").click
    accept_alert do
      click_link _('Delete')
    end
    expect(page).to have_content _('Deleted')
  end

  step 'I can move requests of my own category to other budget periods' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    @category.inspectors << @current_user
    new_budget_period = FactoryGirl.create(:procurement_budget_period)
    go_to_request user: requester
    find(".row[data-request_id='#{@request.id}'] button .fa-gear").click
    find("a[href*='move?to_budget_period_id=#{new_budget_period.id}']")
      .click
    expect(page).to have_content _('Request moved')
  end

  step 'I can move requests of my own category to other categories' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    @category.inspectors << @current_user
    new_category = FactoryGirl.create(:procurement_category)
    go_to_request user: requester
    find(".row[data-request_id='#{@request.id}'] button .fa-gear").click
    find("a[href*='move?to_category_id=#{new_category.id}']").click
    expect(page).to have_content _('Request moved')
  end

  step 'I can create requests for my category/categories for another person' do
    @category = FactoryGirl.create :procurement_category
    @category.inspectors << @current_user
    @budget_period = FactoryGirl.create(:procurement_budget_period)
    visit procurement.overview_requests_path
    close_popup_if_present
    step 'I expand all the sub categories'
    expect(page).to have_selector "a[href*='users/choose']"

    visit procurement.choose_category_budget_period_users_path \
      category_id: @category.id,
      budget_period_id: @budget_period.id
    expect(page).not_to have_content _('You are not authorized for this action.')
  end

  step 'I can manage templates for categories I am inspector' do
    @category = FactoryGirl.create :procurement_category
    @category.inspectors << @current_user
    step 'I navigate to procurement'
    click_link _('Templates')
    expect(current_path).to be == procurement.templates_path
    expect(page).not_to have_content _('You are not authorized for this action.')

    categories = Procurement::Category.all.select do |category|
      category.inspectable_by?(@current_user)
    end
    expect(categories).to include @category

    categories.each do |category|
      within '.panel', text: category.main_category.name do
        current_scope.click

        # NOTE trick preventing panel to stay under the fixed navbar
        if has_no_selector? '.panel .panel-heading', text: category.name
          page.execute_script 'window.scrollBy(0,-100)'
          current_scope.click
        end

        find '.panel .panel-heading', text: category.name
      end
    end
  end

  step 'I can see all budget limits' do
    prepare_request
    FactoryGirl.create(:procurement_budget_limit,
                       main_category: @category.main_category,
                       budget_period: @budget_period)
    visit procurement.overview_requests_path
    expect(page).to have_selector '.budget_limit'
  end

  step 'I can create a budget period' do
    step 'I navigate to the budget periods'
    expect(page).to have_selector 'form .fa-plus-circle'
  end

  step 'I can create main categories' do
    name = Faker::Lorem.sentence
    step 'I navigate to the categories page'
    find('form > .h3 > .fa-plus-circle').click
    find(".panel-default input[name='main_categories[new][name]']").set name
    step 'I click on save'
    step 'I see the saved message'
    find ".panel-info input[value='#{name}']"
  end

  step 'I can create sub categories' do
    name = Faker::Lorem.sentence
    step 'I navigate to the categories page'
    within '.panel-info', match: :first do
      find('.collapsed').click
      find('.fa-plus-circle').click
      all("input[name*='[categories_attributes]'][name*='[name]']",
          minimum: 1).last.set name
    end
    step 'I click on save'
    step 'I see the saved message'
    within '.panel-info', match: :first do
      find('.collapsed').click
      find("input[name*='[name]'][value='#{name}']")
    end
  end

  step 'I can assign inspectors to sub categories' do
    user = User.not_as_delegations.where.not(id: @current_user).first \
            || FactoryGirl.create(:user)
    step 'I navigate to the categories page'
    within '.panel-info', match: :first do
      find('.collapsed').click
      find('.token-input-list .token-input-input-token input#token-input-',
           match: :first).set user.name
    end
    within '.token-input-dropdown' do
      find('li', text: user.name).click
    end
    step 'I click on save'
    step 'I see the saved message'
    within '.panel-info', match: :first do
      find('.collapsed').click
      within '.token-input-list', match: :first do
        find 'li.token-input-token', text: user.to_s
      end
    end
  end

  step 'I can assign budget limits to main categories' do
    3.times { FactoryGirl.create(:procurement_budget_period) }
    amounts = []
    step 'I navigate to the categories page'
    within '.panel-info', match: :first do
      find('.collapsed').click
      all("input[name*='[budget_limits_attributes]']", minimum: 1).each do |el|
        amount = Faker::Number.number(5).to_i
        el.set amount
        amounts << amount
      end
    end
    step 'I click on save'
    step 'I see the saved message'
    within '.panel-info', match: :first do
      find('.collapsed').click
      amounts.each do |amount|
        find("input[name*='[budget_limits_attributes]'][value='#{amount}']")
      end
    end
  end

  step 'I can read only the request of someone else' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    go_to_request user: requester
  end

  step 'I can assign the first admin of the procurement' do
    step 'I navigate to the users page'
    step 'I can add admins'
  end

  private

  def prepare_request(requester: @current_user)
    @budget_period = FactoryGirl.create(:procurement_budget_period)
    @category = FactoryGirl.create :procurement_category
    if requester == @current_user and not \
        Procurement::Access.requesters.find_by(user_id: @current_user.id)
      FactoryGirl.create :procurement_access, :requester, user: @current_user
    end
    @request = FactoryGirl.create(:procurement_request,
                                  user: requester,
                                  category: @category,
                                  budget_period: @budget_period)
  end

  def go_to_request(user: @current_user)
    visit procurement.category_budget_period_user_requests_path \
      category_id: @category,
      budget_period_id: @budget_period.id,
      user_id: user,
      request_id: @request.id

    close_popup_if_present
  end

  def close_popup_if_present
    page.driver.browser.switch_to.alert.accept rescue nil
  end
end
