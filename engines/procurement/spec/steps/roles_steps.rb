require_relative 'shared/dataset_steps'
require_relative 'shared/navigation_steps'
require_relative 'shared/personas_steps'

steps_for :roles do
  include DatasetSteps
  include NavigationSteps
  include PersonasSteps

  step 'I can create a request for myself' do
    visit procurement.overview_requests_path
    find("a[href*='new_request']").click
  end

  step 'I can edit my request' do
    prepare_request
    go_to_request
    find("[name='requests[#{@request.id}][article_name]']").set Faker::Lorem.word
    find('button', text: _('Save'), match: :first).click
    expect(page).to have_content _('Saved')
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
    expect(page).not_to have_selector "input[name*='order_quantity']"
  end

  step 'I can not see the field "approved quantity"' do
    prepare_request
    go_to_request
    expect(page).not_to have_selector "input[name*='approved_quantity']"
  end

  step 'I can not see the field "inspection comment"' do
    prepare_request
    go_to_request
    expect(page).not_to have_selector "input[name*='inspection_comment']"
  end

  step 'I can modify the field "order quantity" of other person\'s request' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    @group.inspectors << @current_user
    go_to_request user: requester
    find("[name='requests[#{@request.id}][order_quantity]']").set 5
    find('button', text: _('Save'), match: :first).click
    expect(page).to have_content _('Saved')
  end

  step 'I can modify the field "approved quantity" of other person\'s request' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    @group.inspectors << @current_user
    go_to_request user: requester
    find("[name='requests[#{@request.id}][approved_quantity]']").set 5
    find('button', text: _('Save'), match: :first).click
    expect(page).to have_content _('Saved')
  end

  step 'I can modify the field "inspection comment" of other person\'s request' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    @group.inspectors << @current_user
    go_to_request user: requester
    find("[name='requests[#{@request.id}][inspection_comment]']")
      .set Faker::Lorem.word
    find('button', text: _('Save'), match: :first).click
    expect(page).to have_content _('Saved')
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

  step 'I can move requests to other groups' do
    new_group = FactoryGirl.create(:procurement_group)
    prepare_request
    go_to_request
    find(".row[data-request_id='#{@request.id}'] button .fa-gear").click
    find("a[href*='move?to_group_id=#{new_group.id}']").click
    expect(page).to have_content _('Request moved')
  end

  step 'I can not inspect requests' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    expect(@group.inspectors).not_to include @current_user
    go_to_request user: requester
    expect(page).not_to have_selector ".row[data-request_id='#{@request.id}']"
  end

  step 'I can not inspect requests of my own group' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    @group.inspectors << @current_user
    go_to_request user: requester
    step 'I can not inspect certain fields'
  end

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

  step 'I can not add groups' do
    expect(find('.navbar').text).not_to match _('Admin')
    visit procurement.groups_path
    expect(page).to have_content _('You are not authorized for this action.')
  end

  step 'I can not add budget periods' do
    expect(find('.navbar').text).not_to match _('Admin')
    visit procurement.budget_periods_path
    expect(page).to have_content _('You are not authorized for this action.')
  end

  step 'I can not manage templates' do
    group = FactoryGirl.create(:procurement_group)
    expect(find('.navbar').text).not_to match _('Templates')
    visit procurement.group_templates_path(group_id: group.id)
    expect(page).to have_content _('You are not authorized for this action.')
  end

  step 'I can not create requests for another person' do
    @budget_period = FactoryGirl.create(:procurement_budget_period)
    @group = FactoryGirl.create(:procurement_group)
    visit procurement.overview_requests_path
    expect(page).not_to have_selector "a[href*='users/choose']"

    visit procurement.choose_group_budget_period_users_path \
      group_id: @group.id,
      budget_period_id: @budget_period.id
    expect(page).to have_content _('You are not authorized for this action.')
  end

  step 'I can not create a request for myself' do
    @budget_period = FactoryGirl.create(:procurement_budget_period)
    @group = FactoryGirl.create(:procurement_group)
    visit procurement.overview_requests_path
    expect(page).not_to have_selector("a[href*='new_request']")

    visit procurement.choose_group_budget_period_users_path \
      group_id: @group.id,
      budget_period_id: @budget_period.id
    expect(page).to have_content _('You are not authorized for this action.')
  end

  step 'I can not see budget limits' do
    prepare_request
    FactoryGirl.create(:procurement_budget_limit,
                       group: @group,
                       budget_period: @budget_period)
    go_to_request
    expect(page).not_to have_selector '.budget_limit'
  end

  step 'I can edit a request of group where I am an inspector' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    @group.inspectors << @current_user
    go_to_request user: requester
    find("[name='requests[#{@request.id}][article_name]']").set Faker::Lorem.word
    find('button', text: _('Save'), match: :first).click
    expect(page).to have_content _('Saved')
  end

  step 'I can delete a request of group where I am an inspector' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    @group.inspectors << @current_user
    go_to_request user: requester
    find(".row[data-request_id='#{@request.id}'] button .fa-gear").click
    accept_alert do
      click_link _('Delete')
    end
    expect(page).to have_content _('Deleted')
  end

  step 'I can move requests of my own group to other budget periods' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    @group.inspectors << @current_user
    new_budget_period = FactoryGirl.create(:procurement_budget_period)
    go_to_request user: requester
    find(".row[data-request_id='#{@request.id}'] button .fa-gear").click
    find("a[href*='move?to_budget_period_id=#{new_budget_period.id}']")
      .click
    expect(page).to have_content _('Request moved')
  end

  step 'I can move requests of my own group to other groups' do
    requester = FactoryGirl.create(:user)
    FactoryGirl.create(:procurement_access,
                       user: requester,
                       organization: \
                         FactoryGirl.create(:procurement_organization))
    prepare_request requester: requester
    @group.inspectors << @current_user
    new_group = FactoryGirl.create(:procurement_group)
    go_to_request user: requester
    find(".row[data-request_id='#{@request.id}'] button .fa-gear").click
    find("a[href*='move?to_group_id=#{new_group.id}']").click
    expect(page).to have_content _('Request moved')
  end

  step 'I can create requests for my group for another person' do
    @group = FactoryGirl.create(:procurement_group)
    @group.inspectors << @current_user
    @budget_period = FactoryGirl.create(:procurement_budget_period)
    visit procurement.overview_requests_path
    expect(page).to have_selector "a[href*='users/choose']"

    visit procurement.choose_group_budget_period_users_path \
      group_id: @group.id,
      budget_period_id: @budget_period.id
    expect(page).not_to have_content _('You are not authorized for this action.')
  end

  step 'I can manage templates of my group' do
    @group = FactoryGirl.create(:procurement_group)
    @group.inspectors << @current_user
    step 'I navigate to procurement'
    click_link _('Templates')
    find('.dropdown li', text: @group.name).click
    expect(current_path).to be == procurement.group_templates_path(@group)
    expect(page).not_to have_content _('You are not authorized for this action.')
  end

  step 'I can see all budget limits' do
    prepare_request
    FactoryGirl.create(:procurement_budget_limit,
                       group: @group,
                       budget_period: @budget_period)
    visit procurement.overview_requests_path
    expect(page).to have_selector '.budget_limit'
  end

  step 'I can create a budget period' do
    step 'I navigate to the budget periods'
    expect(page).to have_selector 'form .fa-plus-circle'
  end

  step 'I can create a group' do
    step 'I navigate to the groups page'
    expect(page).to have_selector "a[href='#{procurement.new_group_path}']"
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
    @group = FactoryGirl.create(:procurement_group)
    if requester == @current_user and not \
        Procurement::Access.requesters.find_by(user_id: @current_user.id)
      FactoryGirl.create :procurement_access, :requester, user: @current_user
    end
    @request = FactoryGirl.create(:procurement_request,
                                  user: requester,
                                  group: @group,
                                  budget_period: @budget_period)
  end

  def go_to_request(user: @current_user)
    visit procurement.group_budget_period_user_requests_path \
      group_id: @group.id,
      budget_period_id: @budget_period.id,
      user_id: user,
      request_id: @request.id
  end
end
