require_relative 'shared/common_steps'
require_relative 'shared/dataset_steps'
require_relative 'shared/filter_steps'
require_relative 'shared/navigation_steps'
require_relative 'shared/personas_steps'

steps_for :inspection do
  include CommonSteps
  include DatasetSteps
  include FilterSteps
  include NavigationSteps
  include PersonasSteps

  step 'a point of delivery exists' do
    FactoryGirl.create :location
  end

  step 'I can not move any request to the old budget period' do
    within '.request', match: :first do
      link_on_dropdown(@past_budget_period.to_s, false)
    end
  end

  step 'I can not save the request' do
    step 'I click on save'
    step 'I do not see a success message'
  end

  step 'I can not submit the data' do
    find 'button[disabled]', text: _('Save'), match: :first
  end

  step 'I press on the Userplus icon of a group I am inspecting' do
    within '#filter_target' do
      within '.panel-success .panel-body' do
        within '.row .h4', text: @group.name do
          find('.fa-user-plus').click
        end
      end
    end
  end

  step 'I see both my requests' do
    within '#filter_target' do
      Procurement::Request.where(user_id: @current_user).pluck(:id).each do |id|
        find "[data-request_id='#{id}']"
      end
    end
  end

  step 'I see the budget limits of all groups' do
    within '.panel-success .panel-body' do
      displayed_groups.each do |group|
        within '.row', text: group.name do
          amount = \
            group.budget_limits \
              .find_by(budget_period_id: Procurement::BudgetPeriod.current)
              .try(:amount) || 0
          find '.budget_limit',
               text: amount
        end
      end
    end
  end

  step 'I see the percentage of budget used ' \
       'compared to the budget limit of my group' do
    within '.panel-success .panel-body' do
      displayed_groups.each do |group|
        within '.row', text: group.name do
          amount = \
            group.budget_limits \
              .find_by(budget_period_id: Procurement::BudgetPeriod.current)
              .try(:amount).to_i
          used = Procurement::BudgetPeriod.current.requests
                     .where(group_id: group)
                     .map { |r| r.total_price(@current_user) }.sum.to_i
          percentage = if amount > 0
                         used * 100 / amount
                       elsif used > 0
                         100
                       else
                         0
                       end
          find('.progress-radial',
               text: format('%d%', percentage))
        end
      end
    end
  end

  step 'I see the total of all ordered amounts of a budget period' do
    total = Procurement::BudgetPeriod.current.requests
              .where(group_id: displayed_groups)
              .map { |r| r.total_price(@current_user) }.sum

    find '.panel-success > .panel-heading .label-primary.big_total_price',
         text: number_with_delimiter(total.to_i)
  end

  step 'I see the total of all ordered amounts of each group' do
    within '.panel-success .panel-body' do
      displayed_groups.each do |group|
        within '.row', text: group.name do
          total = Procurement::BudgetPeriod.current.requests
                      .where(group_id: group)
                      .map { |r| r.total_price(@current_user) }.sum
          find '.label-primary.big_total_price',
               text: number_with_delimiter(total.to_i)
        end
      end
    end
  end

  step 'only my groups are shown' do
    my_groups = Procurement::Group.all.select do |group|
      group.inspectable_by?(@current_user)
    end
    expect(displayed_groups).to eq my_groups
  end

  step 'several requests exist for my groups' do
    my_groups = Procurement::Group.all.select do |group|
      group.inspectable_by?(@current_user)
    end
    n = 3
    n.times do
      FactoryGirl.create :procurement_request,
                         group: my_groups.sample
    end
    expect(Procurement::Request.count).to eq n
  end

  step 'templates for my group exist' do
    3.times do
      FactoryGirl.create :procurement_template_category,
                         :with_templates,
                         group: @group
    end
  end

  step 'the "Approved quantity" is copied to the field "Order quantity"' do
    expect(find("input[name*='[order_quantity]']").value).to eq \
      find("input[name*='[approved_quantity]']").value
  end

  step 'the current budget period is in inspection phase' do
    current_budget_period = Procurement::BudgetPeriod.current
    travel_to_date(current_budget_period.inspection_start_date + 1.day)
    expect(Time.zone.today).to be > current_budget_period.inspection_start_date
    expect(Time.zone.today).to be < current_budget_period.end_date
  end

  step 'the following information is deleted from the request' do |table|
    table.raw.flatten.each do |value|
      case value
      when 'Approved quantity'
          expect(@request.approved_quantity).to be_nil
      when 'Order quantity'
          expect(@request.order_quantity).to be_nil
      when 'Inspection comment'
          expect(@request.inspection_comment).to be_nil
      else
          raise
      end
    end
  end

  step 'the list of requests is adjusted immediately' do
    step 'page has been loaded'
  end

  step 'the ordered amount and the price are multiplied and the result is shown' do
    total = find("input[name*='[price]']").value.to_i * \
              find("input[name*='[order_quantity]']").value.to_i
    expect(find('.label.label-primary.total_price').text).to eq currency(total)
  end

  step 'there is a budget period which has already ended' do
    current_budget_period = Procurement::BudgetPeriod.current
    @past_budget_period = \
      FactoryGirl.create \
        :procurement_budget_period,
        inspection_start_date: \
          current_budget_period.inspection_start_date - 2.months,
        end_date: current_budget_period.inspection_start_date - 1.month
  end

end
