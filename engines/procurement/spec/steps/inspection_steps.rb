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
      current_scope.click # NOTE trick to scroll element into view

      link_on_dropdown(@past_budget_period.to_s, false)
    end
  end

  step 'I can not submit the data' do
    find 'button[disabled]', text: _('Save'), match: :first
  end

  step 'I press on the Userplus icon of a sub category I am inspecting' do
    step 'I expand all the sub categories'
    within '#filter_target' do
      within '.panel-success .panel-body' do
        within '.row .h4', text: @category.name do
          find('.fa-user-plus').click
        end
      end
    end
  end

  step 'I see all requests' do
    step 'I expand all the sub categories'
    within '#filter_target' do
      Procurement::Request.ids.each do |id|
        find "[data-request_id='#{id}']"
      end
    end
  end

  step 'I see only my own requests' do
    step 'I expand all the sub categories'
    within '#filter_target' do
      all('[data-request_id]', minimum: 1).each do |el|
        r = Procurement::Request.find(el['data-request_id'])
        expect(r.user_id).to eq @current_user.id
      end
    end
  end

  step 'I see the budget limit of each main category for each budget period' do
    @filter[:budget_period_ids].each do |id|
      budget_period = Procurement::BudgetPeriod.find id
      @filter[:category_ids].each do |id|
        main_category = Procurement::Category.find(id).main_category
        within '.panel-success > .panel-body .main_category',
               text: main_category.name do
          amount = main_category.budget_limits \
            .find_by(budget_period_id: budget_period) \
            .try(:amount) || 0
          find '.budget_limit', text: amount
        end
      end
    end
  end

  step 'I see the percentage of budget used ' \
       'compared to the budget limit of the main categories' do
    @main_categories.each_pair do |main_cat, cats|
      within '.panel-success > .panel-body .main_category',
             text: main_cat.name do
        limit = main_cat.budget_limits \
          .find_by(budget_period_id: Procurement::BudgetPeriod.current) \
          .try(:amount).to_i
        used = cats.map do |cat|
          @categories_totals[cat][:total]
        end.sum
        percentage = if limit > 0
                       used * 100 / limit
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

  step 'I see the total amount of each main category for each budget period' do
    @filter[:budget_period_ids].each do |id|
      budget_period = Procurement::BudgetPeriod.find id
      @filter[:category_ids].each do |id|
        main_category = Procurement::Category.find(id).main_category
        within '.panel-success > .panel-body .main_category',
               text: main_category.name do
          requests = @found_requests.select do |r|
            r.budget_period_id = budget_period.id \
              and main_category.category_ids.include? r.category_id
          end
          total = requests.map { |r| r.total_price(@current_user) }.sum.to_i
          find '.big_total_price', text: number_with_delimiter(total)
        end
      end
    end
  end

  step 'I see the total amount of each sub category for each budget period' do
    @found_requests = found_requests
    categories = Procurement::Category.find @filter[:category_ids]
    @categories_totals = {}
    categories.each do |category|
      parent_el = find('.row.main_category', text: category.main_category.name)
      parent_el.click if parent_el.has_no_selector? 'a[aria-expanded="true"]'

      @categories_totals[category] = {}
      within '.row', text: category.name do
        requests = @found_requests.select { |r| r.category_id = category.id }
        @categories_totals[category][:requests] = requests
        total = requests.map { |r| r.total_price(@current_user) }.sum.to_i
        @categories_totals[category][:total] = total
        find '.big_total_price', text: number_with_delimiter(total)
      end
    end
  end

  step 'I see the total of all budget limits of ' \
       'the shown main categories for each budget period' do
    @filter[:budget_period_ids].each do |id|
      budget_period = Procurement::BudgetPeriod.find id
      within '.panel > .panel-heading', text: budget_period.name do
        main_categories = @filter[:category_ids].map do |id|
          Procurement::Category.find(id).main_category
        end.uniq
        amount = main_categories.map do |mc|
          mc.budget_limits \
            .find_by(budget_period_id: budget_period) \
            .try(:amount) || 0
        end.sum
        find '.budget_limit', text: amount
      end
    end
  end

  step 'I see the total of all ordered amounts of a budget period' do
    total = Procurement::BudgetPeriod.current.requests
              .where(category_id: displayed_categories)
              .map { |r| r.total_price(@current_user) }.sum

    find '.panel-success > .panel-heading .label-primary.big_total_price',
         text: number_with_delimiter(total.to_i)
  end

  step 'I see the total of all ordered amounts of each group' do
    within '.panel-success .panel-body' do
      displayed_categories.each do |category|
        within '.row', text: category.name do
          total = Procurement::BudgetPeriod.current.requests
                      .where(category_id: category)
                      .map { |r| r.total_price(@current_user) }.sum
          find '.label-primary.big_total_price',
               text: number_with_delimiter(total.to_i)
        end
      end
    end
  end

  def my_categories
    Procurement::Category.all.select do |category|
      category.inspectable_by?(@current_user)
    end
  end

  step 'only categories having requests are shown' do
    expect(page).to have_no_selector \
      '.panel-body .label-primary.big_total_price', text: /^0$/
  end

  step 'only my categories are shown' do
    expect(displayed_categories).to eq my_categories
  end

  step 'several requests exist for my categories' do
    n = 3
    n.times do
      FactoryGirl.create :procurement_request,
                         category: my_categories.sample
    end
    expect(Procurement::Request.count).to eq n
  end

  step 'templates for my categories exist' do
    my_categories.each do |category|
      3.times do
        FactoryGirl.create :procurement_template, category: category
      end
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

  step 'the following fields are not editable' do |table|
    table.raw.flatten.each do |value|
      within '.form-group', text: _(value) do
        case value
        when 'Motivation'
          expect(page).to have_no_selector \
            "[name='requests[#{@request.id}][motivation]']"
          find '.col-xs-8', text: @request.motivation
        when 'Priority'
          expect(page).to have_no_selector \
            "[name='requests[#{@request.id}][priority]']"
          find '.col-xs-8', text: _(@request.priority.capitalize)
        when 'Requested quantity'
          expect(page).to have_no_selector \
            "[name='requests[#{@request.id}][requested_quantity]']"
          find '.col-xs-4', text: @request.requested_quantity
        end
      end
    end
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

  step 'the total amount is calculated by adding all totals of the sub category' do
    @main_categories = @categories_totals.keys.group_by(&:main_category)
    @main_categories.each_pair do |main_cat, cats|
      within '.panel-success > .panel-body .main_category',
             text: main_cat.name do
        total = cats.map do |cat|
          @categories_totals[cat][:total]
        end.sum
        find '.big_total_price', text: number_with_delimiter(total)
      end
    end
  end

  step 'the total amount is calculated by adding the following amounts' do |table|
    @categories_totals.each_pair do |category, v|
      total = 0
      table.hashes.each do |hash|
        requests = v[:requests].select do |r|
          r.state(@current_user) == hash['state'].to_sym
        end
        total += requests.map do |r|
          (r.price * r.send("#{hash['quantity']}_quantity")).to_i
        end.sum
      end
      expect(total).to eq v[:total]
    end
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
