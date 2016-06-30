# rubocop:disable Metrics/ModuleLength
module CommonSteps

  step 'a receiver exists' do
    FactoryGirl.create :user
  end

  step 'a request with following data exist' do |table|
    @changes = {
      category: @category
    }
    table.hashes.each do |hash|
      hash['value'] = nil if hash['value'] == 'random'
      case hash['key']
      when 'budget period'
          @changes[:budget_period] = if hash['value'] == 'current'
                                       Procurement::BudgetPeriod.current
                                     else
                                       Procurement::BudgetPeriod.all.sample
                                     end
      when 'user'
          @changes[:user] = case hash['value']
                            when 'myself'
                                @current_user
                            else
                                find_or_create_user(hash['value'], true)
                            end
      when 'requested amount'
          @changes[:requested_quantity] = \
            (hash['value'] || Faker::Number.number(2)).to_i
      when 'approved amount'
          @changes[:approved_quantity] = \
            (hash['value'] || Faker::Number.number(2)).to_i
      when 'inspection comment'
          @changes[:inspection_comment] = hash['value'] || Faker::Lorem.sentence
      else
          raise
      end
    end
    @request = FactoryGirl.create :procurement_request, @changes
  end

  step 'following requests exist for the current budget period' do |table|
    current_budget_period = Procurement::BudgetPeriod.current
    table.hashes.each do |value|
      n = value['quantity'].to_i
      user = case value['user']
             when 'myself' then @current_user
             else
                 find_or_create_user(value['user'], true)
             end
      h = {
        user: user,
        budget_period: current_budget_period
      }
      if value['category'] == 'inspected' or not @category.nil?
        h[:category] = @category || Procurement::Category.detect do |category|
          not category.inspectable_by?(@current_user)
        end
      end

      n.times do
        FactoryGirl.create :procurement_request, h
      end
      expect(current_budget_period.requests.where(user_id: user).count).to eq n
    end
  end

  step 'for each request I see the following information' do |table|
    step 'I expand all the sub categories'
    elements = all('[data-request_id]', minimum: 1)
    expect(elements).not_to be_empty
    elements.each do |element|
      request = Procurement::Request.find element['data-request_id']
      within element do
        table.raw.flatten.each do |value|
          case value
          when 'article name'
              find '.col-sm-2', text: request.article_name
          when 'name of the requester'
              find '.col-sm-2', text: request.user.to_s
          when 'department'
              find '.col-sm-2', text: request.organization.parent.to_s
          when 'organisation'
              find '.col-sm-2', text: request.organization.to_s
          when 'price'
              find '.col-sm-1 .total_price', text: request.price.to_i
          when 'requested amount'
              within all('.col-sm-2.quantities div', count: 3)[0] do
                expect(page).to have_content request.requested_quantity
              end
          when 'approved amount'
              within all('.col-sm-2.quantities div', count: 3)[1] do
                expect(page).to have_content request.approved_quantity
              end
          when 'order amount'
              within all('.col-sm-2.quantities div', count: 3)[2] do
                expect(page).to have_content request.order_quantity
              end
          when 'total amount'
              find '.col-sm-1 .total_price',
                   text: request.total_price(@current_user).to_i
          when 'priority'
              find '.col-sm-1', text: _(request.priority.capitalize)
          when 'state'
              state = request.state(@current_user)
              find '.col-sm-1', text: _(state.to_s.humanize)
          else
              raise
          end
        end
      end
    end
  end

  step 'I choose the following :field value' do |field, table|
    el = if @template
           ".request[data-template_id='#{@template.id}']"
         else
           '.request[data-request_id="new_request"]'
         end
    within el do
      label = case field
              when 'priority'
                _('Priority')
              when 'replacement'
                format('%s / %s', _('Replacement'), _('New'))
              else
                raise
              end
      within '.form-group', text: label do
        table.raw.flatten.each do |value|
          choose _(value)
        end
      end
    end
  end
  # alias
  step 'I can choose the following :field values' do |field, table|
    step "I choose the following #{field} value", table
  end

  step 'I can not save' do
    step 'I click on save'
    step 'I do not see a success message'
  end
  step 'I can not save the request' do
    step 'I can not save'
  end

  step 'I choose the name of a receiver' do
    @receiver = User.not_as_delegations.where.not(id: @current_user).sample

    # find('.form-group', text: _('Name of receiver')). \
    #   find('input').set @receiver.to_s
    fill_in _('Name of receiver'), with: @receiver.name
    # not working#
    # within '.ui-autocomplete' do
    #   find('.ui-menu-item', text: @receiver.name).click
    # end
  end

  step 'I choose the point of delivery' do
    @location = Location.all.sample

    fill_in _('Point of Delivery'), with: @location.to_s
  end

  step 'I click on save' do
    within 'article .page-content-wrapper' do
      el = all('button', text: _('Save'), minimum: 1).last
      el.click
    end
  end

  # step 'I enter the section :section' do |section|
  #   case section
  #     when 'My requests'
  #       step 'I navigate to the requests overview page'
  #     else
  #       raise
  #   end
  # end

  step 'I delete the following fields' do |table|
    el1 = if @template
            find('.panel-info', text: @template.category.main_category.name)
          else
            find('.panel-body')
          end

    within el1 do
      find('.collapsed').click if el1.has_selector? '.collapsed'

      el2 = if @template
              find(:xpath,
                   "//input[@value='#{@template.article_name}']/ancestor::tr")
            elsif @request
              ".request[data-request_id='#{@request.id}']"
            else
              ".request[data-request_id='new_request']"
            end

      within el2 do
        table.raw.flatten.each do |value|
          case value
          when 'Price'
              find("input[name*='[price]']").set ''
          else
              fill_in _(value), with: ''
          end
        end
      end
    end
  end

  step 'I expand all the main categories' do
    all('.row.main_category', minimum: 1).each do |el|
      el.click if el.has_no_selector? 'a[aria-expanded="true"]'
      target_id = el.find('a')['href'].gsub(/.*#/, '')
      find ".panel-body .collapse##{target_id} .col-sm-8.h4"
    end
  end

  step 'I expand all the sub categories' do
    step 'page has been loaded'
    step 'I expand all the main categories'
    all('.panel-body .collapse .col-sm-8.h4', minimum: 1).each do |el|
      next if el.has_no_selector? 'i.fa-caret-right'
      if el.has_no_selector? '.toggler[aria-expanded="true"]'
        el.find('a.toggler', match: :first).click
      end
    end
  end

  step 'I fill in all mandatory information' do
    @changes = {}
    request_el = if @template
                   ".request[data-template_id='#{@template.id}']"
                 else
                   ".request[data-request_id='new_request']"
                 end
    within request_el do
      selector = if has_selector? '[data-to_be_required]:invalid'
                   '[data-to_be_required]:invalid'
                 else
                   '[data-to_be_required]'
                 end
      all(selector, minimum: 1).each do |el|
        key = el['name'].match(/.*\[(.*)\]\[(.*)\]/)[2]

        case key
        when 'requested_quantity'
            el.set v = Faker::Number.number(2).to_i
        when 'replacement'
            find("input[name*='[replacement]'][value='#{v = 1}']").click
        else
            el.set v = Faker::Lorem.sentence
        end

        @changes[key.to_sym] = v
      end
    end
  end

  step 'I fill in the following fields' do |table|
    @changes ||= {}

    el = if @template
           'article .page-content-wrapper ' \
           ".request[data-template_id='#{@template.id}']"
         else
           'article .page-content-wrapper'
         end
    table.hashes.each do |hash|
      within el do
        hash['value'] = nil if hash['value'] == 'random'
        case hash['key']
        when 'Price'
          v = (hash['value'] || Faker::Number.number(4)).to_i
          find("input[name*='[price]']").set v
        when /quantity/
          v = (hash['value'] || Faker::Number.number(2)).to_i
          fill_in _(hash['key']), with: v
        when 'Replacement / New'
          v = hash['value'] || [0, 1].sample
          find("input[name*='[replacement]'][value='#{v}']").click
        else
          v = hash['value'] || Faker::Lorem.sentence
          fill_in _(hash['key']), with: v
        end
        @changes[mapped_key(hash['key'])] = v
      end

      # NOTE trigger change event
      find('body').native.send_keys(:tab) # find('body').click
    end
  end

  step 'I move a request to the future budget period' do
    within all('.request', minimum: 1).last do
      @request = Procurement::Request.find current_scope['data-request_id']
      link_on_dropdown(@future_budget_period.to_s).click
    end

    @changes = {
      budget_period_id: @future_budget_period.id
    }
  end

  step 'I move a request to the other category' do
    within all('.request', minimum: 1).last do
      @request = Procurement::Request.find current_scope['data-request_id']
      categories = Procurement::Category.where.not(id: @request.category_id)

      @other_category = if @not_inspected_category
                          categories.detect do |category|
                            not category.inspectable_by?(@current_user)
                          end
                        else
                          categories.first
                        end

      link_on_dropdown(@other_category.name).click
    end

    @changes = {
      category_id: @other_category.id
    }
  end

  step 'I move a request to the other category where I am not inspector' do
    @not_inspected_category = true
    step 'I move a request to the other category'
  end

  step 'I press on a main category having sub categories' do
    @main_category = Procurement::Category.all.sample.main_category
    find('.panel-info > .panel-heading.collapsed h4',
         text: @main_category.name).click
  end

  step 'I press on the plus icon of a sub category' do
    @category ||= Procurement::Category.first
    step 'I deselect "Only categories with requests"'
    step 'I select all categories'
    step 'I expand all the sub categories'
    within '#filter_target' do
      within '.panel-success .panel-body' do
        within '.row .h4', text: @category.name do
          find('i.fa-plus-circle').click
        end
      end
    end
  end

  step 'I press on the plus icon of one of its sub categories' do
    @category = @main_category.categories.first
    within '.panel-info', text: @main_category.name do
      within '.panel-default .panel-heading', text: @category.name do
        find('i.fa-plus-circle').click
      end
    end
  end

  step 'I press on the plus icon of the current budget period' do
    within '#filter_target' do
      within '.panel-success > .panel-heading',
             text: Procurement::BudgetPeriod.current.name do
        find('i.fa-plus-circle').click
      end
    end
  end

  step 'I see the saved message' do
    expect(page).to have_content _('Saved')
  end

  step 'I :boolean a success message' do |boolean|
    if boolean
      Capybara.using_wait_time(8) do
        expect(page).to have_selector '.flash .alert-success'
      end
    else
      expect(page).to have_no_selector '.flash .alert-success'
    end
  end

  step 'I see an error message' do
    find '.flash .alert-danger', match: :first
  end

  step 'I see all main categories' do
    within '.panel-success .panel-body' do
      Procurement::MainCategory.all.each do |category|
        find '.row', text: category.name
      end
    end
  end
  # not alias, but same implementation
  # step 'I see all main categories listed' do
  #   step 'I see all main categories'
  # end

  step 'I see the amount of requests listed' do
    within '#filter_target' do
      find 'h4', text: /^\d #{_('Requests')}$/
    end
  end

  step 'I see the amount of requests which are listed is :n' do |n|
    within '#filter_target' do
      find 'h4', text: /^#{n} #{_('Requests')}$/
    end
  end

  step 'I see the current budget period' do
    find '.panel-success > .panel-heading .h4',
         text: Procurement::BudgetPeriod.current.name
  end
  # alias
  step 'I see the budget period' do
    step 'I see the current budget period'
  end

  step 'I see the headers of the columns of the overview' do
    find '#column-titles'
  end

  step 'I see the requested amount per budget period' do
    requests = Procurement::BudgetPeriod.current.requests
                .where(category_id: displayed_categories)
    requests = requests.where(user_id: @current_user) if filtered_own_requests?
    total = requests.map { |r| r.total_price(@current_user) }.sum
    find '.panel-success > .panel-heading .label-primary.big_total_price',
         text: number_with_delimiter(total.to_i)
  end

  step 'I see the requested amount per category of each budget period' do
    displayed_categories.each do |category|
      requests = Procurement::BudgetPeriod.current.requests
                     .where(category_id: category)
      requests = requests.where(user_id: @current_user) if filtered_own_requests?
      total = requests.map { |r| r.total_price(@current_user) }.sum
      within '.panel-success .panel-body' do
        within '.row', text: category.name do
          find '.label-primary.big_total_price',
               text: number_with_delimiter(total.to_i)
        end
      end
    end
  end

  step 'I see when the requesting phase of this budget period ends' do
    within '.panel-success > .panel-heading' do
      find '.row',
           text: _('requesting phase until %s') \
                  % I18n.l(Procurement::BudgetPeriod.current.inspection_start_date)
    end
  end

  step 'I see when the inspection phase of this budget period ends' do
    within '.panel-success > .panel-heading' do
      find '.row',
           text: _('inspection phase until %s') \
                  % I18n.l(Procurement::BudgetPeriod.current.end_date)
    end
  end

  step 'I upload a file' do
    field = find "input[name*='[attachments_attributes][][file]']"
    attach_file(field[:name], # _('Attachments'),
                "#{Rails.root}/features/data/images/image1.jpg")
  end

  step 'I want to create a new request' do
    step 'I navigate to the requests overview page'
    step 'I press on the plus icon of the current budget period'
    step 'I press on a main category having sub categories'
    step 'I press on the plus icon of one of its sub categories'
  end

  step ':count main categories exist' do |count|
    n = case count
        when 'several'
            3
        else
            count.to_i
        end
    @main_categories = []
    n.times do
      @main_categories << FactoryGirl.create(:procurement_main_category)
    end
  end

  step ':count sub categories exist' do |count|
    n = case count
        when 'several'
            3
        else
            count.to_i
        end
    @sub_categories = []
    n.times do
      @sub_categories << FactoryGirl.create(:procurement_category,
                                            main_category: @main_categories.sample)
    end
  end

  step 'page has been loaded' do
    # NOTE trick waiting page load
    if has_selector? '#filter_target.transparency'
      expect(page).to have_no_selector '#filter_target.transparency'
    end

    within '#filter_target' do
      expect(page).to have_no_selector '.spinner'
    end
  end

  step 'several budget periods exist' do
    current_year = Time.zone.today.year
    @budget_periods = []
    (1..3).each do |num|
      @budget_periods << \
        FactoryGirl.create(
          :procurement_budget_period,
          name: current_year + num,
          inspection_start_date: Date.new(current_year + num, 1, 1),
          end_date: Date.new(current_year + num, 1, 2)
        )
    end
  end

  step 'several requests created by myself exist' do
    budget_period = Procurement::BudgetPeriod.current
    h = {
      user: @current_user,
      budget_period: budget_period
    }
    h[:category] = @category if @category

    n = 5
    n.times do
      FactoryGirl.create :procurement_request, h
    end
    requests = Procurement::Request.where(user_id: @current_user,
                                          budget_period_id: budget_period)
    expect(requests.count).to eq n
  end

  step 'several categories exist' do
    3.times do
      FactoryGirl.create :procurement_category
    end
  end

  step 'several template articles in sub categories exist' do
    Procurement::Category.all.each do |category|
      @category = category
      step 'the category contains template articles'
    end
  end

  step 'the changes are saved successfully to the database' do
    @request.reload
    @changes.each_pair do |k, v|
      expect(@request.send(k)).to eq v
    end
  end

  step 'the current date is after the budget period end date' do
    travel_to_date @request.budget_period.end_date + 1.day
    expect(Time.zone.today).to be > @request.budget_period.end_date
  end
  # alias
  step 'the budget period has ended' do
    step 'the current date is after the budget period end date'
  end

  step 'the field :field is marked red' do |field|
    el = if @request
           ".request[data-request_id='#{@request.id}']"
         elsif has_selector? ".request[data-request_id='new_request']"
          ".request[data-request_id='new_request']"
         elsif has_selector? '#new_main_category.panel-default'
           '#new_main_category.panel-default'
         else
           all('form table tbody tr', minimum: 1).last
         end
    within el do
      case field
      when 'new/replacement'
          input_field = find("input[name*='[replacement]']", match: :first)
          label_field = \
            input_field.find(:xpath,
                             "./following-sibling::div[contains(@class, 'label')]")
      else
          input_field = case field
                        when 'requester name', 'name'
                            find("input[name*='[name]']")
                        when 'department'
                            find("input[name*='[department]']")
                        when 'organization'
                            find("input[name*='[organization]']")
                        when 'inspection start date'
                            find("input[name*='[inspection_start_date]']")
                        when 'end date'
                            find("input[name*='[end_date]']")
                        when 'article'
                            find("input[name*='[article_name]']")
                        when 'requested quantity'
                            find("input[name*='[requested_quantity]']")
                        when 'motivation'
                            find("textarea[name*='[motivation]']")
                        when 'inspection comment'
                            find("textarea[name*='[inspection_comment]']")
                        end
      end
      expect(input_field['required']).to eq 'true' # ;-)
      color = (label_field || input_field).native.css_value('background-color')
      expect(color).to eq 'rgba(242, 222, 222, 1)'
    end
  end

  step 'the request with all given information ' \
       'was created successfully in the database' do
    user = @user || @current_user
    if price = @changes.delete(:price)
      @changes[:price_cents] = price * 100
    end
    expect(@category.requests.where(user_id: user).find_by(@changes)).to be
  end

  step 'the status is set to :state' do |state|
    within '.form-group', text: _('State') do
      find '.label', text: _(state)
    end
  end

  step 'the category contains template articles' do
    3.times do
      FactoryGirl.create :procurement_template, category: @category
    end
  end

  step 'there is a future budget period' do
    current_budget_period = Procurement::BudgetPeriod.current
    @future_budget_period = \
      FactoryGirl.create(:procurement_budget_period,
                         inspection_start_date: \
                           current_budget_period.end_date + 1.month,
                         end_date: current_budget_period.end_date + 2.months)
  end

  def visit_request(request)
    visit \
      procurement.category_budget_period_user_requests_path(request.category,
                                                            request.budget_period,
                                                            request.user)
  end

  def travel_to_date(datetime = nil)
    if datetime
      Timecop.travel datetime
    else
      Timecop.return
    end

    # The minimum representable time is 1901-12-13,
    # and the maximum representable time is 2038-01-19
    ActiveRecord::Base.connection.execute \
      "SET TIMESTAMP=unix_timestamp('#{Time.now.iso8601}')"
    mysql_now = ActiveRecord::Base.connection \
    .exec_query('SELECT CURDATE()').rows.flatten.first
    if mysql_now != Time.zone.today
      raise 'MySQL current datetime has not been changed'
    end
  end

  def link_on_dropdown(link_string, present = true)
    el = find('.btn-group .fa-gear')
    btn = el.find(:xpath, './/parent::button')
    wrapper = btn.find(:xpath, './/parent::div')
    btn.click unless wrapper['class'] =~ /open/
    within wrapper do
      if present
        find('a', text: link_string)
      else
        expect(page).to have_no_selector('a', text: link_string)
      end
    end
  end

  def currency(amount)
    ActionController::Base.helpers.number_to_currency(
      amount,
      unit: Setting.local_currency_string,
      precision: 0)
  end

  def mapped_key(from)
    case from
    when 'Article or Project'
        :article_name
    when 'Article nr. or Producer nr.'
        :article_number
    when 'Replacement / New'
        :replacement
    when 'Supplier'
        :supplier_name
    else
        from.parameterize.underscore.to_sym
    end
  end

  def number_with_delimiter(n)
    ActionController::Base.helpers.number_with_delimiter(n)
  end

  private

  def displayed_categories
    Procurement::Category.where(name: all('div.row .h4', minimum: 0).map(&:text))
  end

  def filtered_own_requests?
    Procurement::Access.requesters.where(user_id: @current_user).exists? and \
      (has_no_selector?('#filter_panel input[name="user_id"]') or \
        find('#filter_panel input[name="user_id"]').checked?)
  end

end
# rubocop:enable Metrics/ModuleLength
