require_relative 'shared/common_steps'
require_relative 'shared/dataset_steps'
require_relative 'shared/filter_steps'
require_relative 'shared/navigation_steps'
require_relative 'shared/personas_steps'

steps_for :periods_and_states do
  include CommonSteps
  include DatasetSteps
  include FilterSteps
  include NavigationSteps
  include PersonasSteps

  step 'a budget period without any requests exists' do
    @budget_period = FactoryGirl.create(:procurement_budget_period)
    expect(@budget_period.requests).to be_empty
  end

  step 'a request exists' do
    @request = if Procurement::Access.requesters.find_by(user_id: @current_user.id)
                 FactoryGirl.create(:procurement_request, user: @current_user)
               else
                 FactoryGirl.create(:procurement_request)
               end
  end

  step 'for every budget period I see the total of all requested amounts ' \
       'with status "New"' do
    Procurement::BudgetPeriod.all.each do |budget_period|
      next if budget_period.requests.empty?
      within(:xpath, "//input[@value='#{budget_period.name}']/ancestor::tr") do
        total = budget_period.requests
                .where(approved_quantity: nil)
                    .map { |r| r.total_price(@current_user) }.sum
        find('.label-info', text: currency(total))
      end
    end
  end

  step 'for every budget period I see the total of all ordered amounts ' \
       'with status "Approved" or "Partially approved"' do
    Procurement::BudgetPeriod.all.each do |budget_period|
      next if budget_period.requests.empty?
      within(:xpath, "//input[@value='#{budget_period.name}']/ancestor::tr") do
        total = budget_period.requests
                .where.not(approved_quantity: nil)
                    .map { |r| r.total_price(@current_user) }.sum
        find('.label-success', text: currency(total))
      end
    end
  end

  step 'I add a new line' do
    within 'tfoot' do
      find('i.fa-plus-circle').click
    end
  end

  step 'I can delete the line' do
    elements = all('form table tbody tr', minimum: 1)
    n = elements.count
    within elements.last do
      find('.fa-minus-circle').click
    end
    expect(all('form table tbody tr', minimum: 0).count).to be < n
  end

  step 'I can not create any request for the budget period which has ended' do
    path = \
      procurement.new_user_budget_period_request_path(@current_user,
                                                      @request.budget_period)
    visit path

    find '.flash .alert-danger', text: _('The budget period is closed')

    expect do
      FactoryGirl.create :procurement_request,
                         user: @current_user,
                         budget_period: @request.budget_period

    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  step 'I can not delete any requests for the budget period which has ended' do
    expect(page).to have_no_selector '.btn-group .fa-gear'

    @request.destroy
    expect(@request.destroyed?).to be false
  end

  step 'I can not delete the request' do
    if @el
      @el.click
    else
      visit_request(@request)
    end
    if has_selector? '.btn-group .fa-gear'
      link_on_dropdown(_('Delete'), false)
    else
      expect(page).to have_no_selector "form [type='submit']"
      expect(@request.editable?(@current_user)).to be false
    end
  end

  step 'I can not modify any request for the budget period which has ended' do
    step 'I can not modify the request'
  end

  step 'I can not modify the request' do
    if @el
      @el.click
    else
      visit_request(@request)
    end
    expect(page).to have_no_selector "form [type='submit']"
    expect(@request.editable?(@current_user)).to be false
  end

  step 'I can not move a request of a budget period ' \
       'which has ended to another budget period' do
    request = Procurement::BudgetPeriod.all
                  .detect { |bp| bp.past? and bp.requests.exists? }
                  .requests.first
    visit_request(request)
    budget_period = Procurement::BudgetPeriod.last

    expect(page).to have_no_selector '.btn-group .fa-gear'

    request.update_attributes budget_period: budget_period
    expect(request).to_not be_valid
    expect(request.reload.budget_period).to_not be budget_period
  end

  step 'I can not move a request of a budget period ' \
       'which has ended to another procurement group' do
    request = Procurement::BudgetPeriod.all
                  .detect { |bp| bp.past? and bp.requests.exists? }
                  .requests.first
    visit_request(request)
    group = Procurement::Group.where.not(id: request.group).first

    expect(page).to have_no_selector '.btn-group .fa-gear'

    request.update_attributes group: group
    expect(request).to_not be_valid
    expect(request.reload.group).to_not be group
  end

  step 'I can not save the data' do
    step 'I click on save'
    expect(Procurement::BudgetPeriod.exists?).to be false
  end

  step 'I change the name of the budget period' do
    budget_period_line = find_budget_period_line_by_name(@budget_period.name)
    @new_name = 'New name'
    budget_period_line.find("input[name*='name']").set @new_name
  end

  step 'I change the inspection start date of the budget period' do
    budget_period_line = find_budget_period_line_by_name(@budget_period.name)
    @new_inspection_start_date = Time.zone.today + 5.months
    budget_period_line.find("input[name*='inspection_start_date']")
        .set format_date(@new_inspection_start_date)
  end

  step 'I change the end date of the budget period' do
    budget_period_line = find_budget_period_line_by_name(@budget_period.name)
    @new_end_date = Time.zone.today + 6.months
    budget_period_line.find("input[name*='end_date']")
        .set format_date(@new_end_date)
  end

  step 'I click on \'delete\' on the line for this budget period' do
    accept_alert do
      within 'form table tbody' do
        within "tr td:first-child input[value='#{@budget_period.name}']" do
          find(:xpath, '../..').click_on _('Delete')
        end
      end
    end
  end

  step 'I edit a budget period' do
    @budget_period = Procurement::BudgetPeriod.first
  end

  step 'I fill in the name' do
    within 'form table tbody tr' do
      find("input[name*='name']").set Time.zone.today.year + 1
    end
  end

  step 'I fill in the start date of the inspection period' do
    within 'form table tbody tr' do
      find("input[name*='inspection_start_date']")
        .set format_date(Time.zone.today + 1)
    end
  end

  step 'I fill in the end date of the budget period' do
    within 'form table tbody tr' do
      find("input[name*='end_date']")
        .set format_date(Time.zone.today + 1.month)
    end
  end

  step 'I :boolean filled the mandatory fields' do |boolean|
    within all('form table tbody tr', minimum: 1).last do
      all('input[required]', minimum: 1).each do |el|
        if boolean
          el.set Faker::Lorem.sentence
        else
          expect(el.value).to be_empty
        end
      end
    end
  end

  step 'I have not saved the data yet' do
    step 'I have filled the mandatory fields'
  end

  step 'I see the state :state' do |state|
    step 'I navigate to the requests overview page'
    step 'I select all budget periods'
    step 'I select all groups'
    step 'page has been loaded'
    @el = find(".list-group-item[data-request_id='#{@request.id}']")
    @el.find('.label', text: _(state))
  end

  step 'I see which fields are mandatory' do
    step 'the field "name" is marked red'
    step 'the field "inspection start date" is marked red'
    step 'the field "end date" is marked red'
  end

  step 'I see the status of my request is "In inspection"' do
    expect(@request.state(@current_user)).to be :in_inspection
    @el = find ".row[data-request_id='#{@request.id}']"
    within @el do
      find '.col-sm-1', text: _('In inspection')
    end
  end

  step 'I set the end date of the budget period ' \
       'earlier than the inspection start date' do
    budget_period_line = find_budget_period_line_by_name(@budget_period.name)
    @old_end_date = @budget_period.end_date
    @new_end_date = @budget_period.inspection_start_date - 1.day
    budget_period_line.find("input[name*='end_date']")
        .set format_date(@new_end_date)
  end

  # step 'I set the end date of the budget period equal or later than today' do
  #   budget_period_line = find_budget_period_line_by_name(@budget_period.name)
  #   @new_end_date = Time.zone.today + 100.days
  #   budget_period_line.find("input[name*='end_date']")
  #     .set format_date(@new_end_date)
  # end

  step 'requests with status :status exist' do |status|
    5.times do |i|
      case status
      when 'New'
          FactoryGirl.create :procurement_request,
                             budget_period: Procurement::BudgetPeriod.current,
                             requested_quantity: i + 1,
                             approved_quantity: nil
      when 'Approved'
          FactoryGirl.create :procurement_request,
                             budget_period: Procurement::BudgetPeriod.current,
                             requested_quantity: i + 1,
                             approved_quantity: i + 1
      when 'Partially approved'
          FactoryGirl.create :procurement_request,
                             budget_period: Procurement::BudgetPeriod.current,
                             requested_quantity: i + 1,
                             approved_quantity: (i / 2).to_i,
                             inspection_comment: 'just a test'
      else
          raise
      end
    end
  end

  step 'the budget periods are sorted from 0-10 and a-z' do
    names = all('form table tbody tr td:first-child input', minimum: 1) \
              .map(&:value)
    expect(names).to eq @budget_periods.map(&:name).sort
  end

  step 'the budget period line was updated successfully' do
    within find_budget_period_line_by_name(@new_name) do
      expect(find("input[name*='name']").value).to eq @new_name
      expect(find("input[name*='inspection_start_date']").value)
          .to eq format_date(@new_inspection_start_date)
      expect(find("input[name*='end_date']").value)
          .to eq format_date(@new_end_date)
    end
  end

  step 'the data for the budget period was updated successfully in the database' do
    @budget_period.reload
    expect(@budget_period.name).to eq @new_name
    expect(@budget_period.inspection_start_date)
        .to eq @new_inspection_start_date
    expect(@budget_period.end_date).to eq @new_end_date
  end

  step 'the data for the budget period was not saved to the database' do
    expect(@budget_period.reload.end_date).to eq @old_end_date
  end

  step 'the approved quantity is :string_with_spaces' do |string_with_spaces|
    new_quantity, new_comment = \
      case string_with_spaces
      when 'empty'
        [nil, nil]
      when 'equal to the requested quantity'
        [@request.requested_quantity, nil]
      when 'smaller than the requested quantity, not equal 0'
        raise if @request.requested_quantity == 1
        [@request.requested_quantity - 1, 'inspection comment']
      when 'equal 0'
        [0, 'inspection comment']
      else
        raise
      end
    @request.update_attributes approved_quantity: new_quantity,
                               inspection_comment: new_comment
  end

  step 'the current date is before the inspection date' do
    travel_to_date Procurement::BudgetPeriod.current.inspection_start_date - 1.day
    expect(Time.zone.today).to be < \
      Procurement::BudgetPeriod.current.inspection_start_date
  end

  step 'the current date is between the inspection date ' \
       'and the budget period end date' do
    travel_to_date(@request.budget_period.end_date - 1.day)
    expect(Time.zone.today).to be > @request.budget_period.inspection_start_date
    expect(Time.zone.today).to be < @request.budget_period.end_date
  end

  step 'the status of the request saved to the database is "New"' do
    expect(page).to have_no_selector ".request[data-request_id='new_request']"
    all('.request', minimum: 1).map { |el| el['data-request_id'] }.each do |id|
      request = Procurement::Request.find id
      expect(request.state(@current_user)).to be :new
    end
  end

  step 'there does not exist any budget period yet' do
    expect(Procurement::BudgetPeriod.count).to eq 0
  end

  step 'there is an empty budget period line for creating a new one' do
    within 'table tbody tr' do
      all('input', minimum: 1).each { |i| expect(i.value).to be_blank }
    end
  end

  step 'this budget period disappears from the list' do
    expect(first('form table tbody tr td:first-child input',
                 text: @budget_period.name)).not_to be
  end

  step 'this budget period was deleted from the database' do
    expect(Procurement::BudgetPeriod.find_by_id(@budget_period.id)).not_to be
  end

  private

  def find_budget_period_line_by_name(name)
    find("form table tbody tr input[value='#{name}']")
      .find(:xpath, '../..')
  end

  def format_date(date)
    date.strftime '%d.%m.%Y'
  end
end
