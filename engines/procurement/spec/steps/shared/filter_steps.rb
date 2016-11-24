# rubocop:disable Metrics/ModuleLength
module FilterSteps

  step 'all categories are selected' do
    within '#filter_panel' do
      within 'select[name="filter[category_ids][]"]', visible: false do
        Procurement::Category.all.each do |category|
          expect(find "option[value='#{category.id}']", visible: false).to \
            be_selected
        end
      end
    end
  end

  step 'all organisations are selected' do
    within '#filter_panel .form-group', text: _('Organisations') do
      within '.btn-group' do
        find 'button', text: _('All')
      end
    end
  end

  step 'all states are selected' do
    within '#filter_panel .form-group', text: _('State of Request') do
      all('input[name="filter[states][]"]', minimum: 4).each do |cb|
        expect(cb).to be_selected
      end
    end
  end

  step 'both priorities are selected' do
    within('#filter_panel .form-group',
           text: _('Priority'),
           match: :prefer_exact) do
      ['high', 'normal'].each do |priority|
        expect(find "input[value='#{priority}']").to be_selected
      end
    end
  end

  step 'I enter a search string' do
    @filter ||= get_filter
    request = Procurement::Request.where(
      budget_period_id: @filter[:budget_period_ids],
      category_id: @filter[:category_ids],
      priority: @filter[:priorities]
    ).all.sample
    text = request.article_name[0, 6]
    within '#filter_panel .form-group', text: _('Search') do
      find('input[name="filter[search]"]').set text
      @filter[:search] = text
    end
  end

  step 'I leave the search string empty' do
    within '#filter_panel .form-group', text: _('Search') do
      find('input[name="filter[search]"]').set ''
    end
  end

  step 'I select a specific organisation' do
    selected_organization = Procurement::Organization.where(parent_id: nil).first
    within '#filter_panel .form-group', text: _('Organisations') do
      within '.btn-group' do
        find('button.multiselect').click # NOTE open the dropdown
        within '.dropdown-menu' do
          choose selected_organization.name
        end
        find('button.multiselect').click # NOTE close the dropdown
      end
    end
  end

  step 'I select all :string_with_spaces' do |string_with_spaces|
    text = case string_with_spaces
           when 'categories'
               _('Categories')
           when 'budget periods'
               _('Budget periods')
           when 'organisations'
               _('Organisations')
           when 'states'
               _('State of Request')
           else
               raise
           end
    within '#filter_panel .form-group', text: text, match: :prefer_exact do
      case string_with_spaces
      when 'states'
          all(:checkbox, minimum: 4).each { |x| x.set true }
      else
          within '.btn-group' do
            find('button.multiselect').click # NOTE open the dropdown
            expect(current_scope[:class]).to include 'open'

            within '.dropdown-menu' do
              check _('Select all')
            end

            # NOTE close the dropdown
            find("button.multiselect[aria-expanded='true']").click
            expect(current_scope[:class]).not_to include 'open'
          end
      end
    end
  end

  step 'I select both priorities' do
    @filter ||= get_filter
    within('#filter_panel .form-group',
           text: _('Priority'),
           match: :prefer_exact) do
      @filter[:priorities] = all(:checkbox, count: 2).map do |x|
        x.set true
        x[:value]
      end
    end
  end

  step 'I select one ore both priorities' do
    @filter ||= get_filter
    if [true, false].sample
      step 'I select both priorities'
    else
      within('#filter_panel .form-group',
             text: _('Priority'),
             match: :prefer_exact) do
        @filter[:priorities] = [find(:checkbox, match: :first)].map do |x|
          x.set true
          x[:value]
        end
      end
    end
  end

  step 'I select one or more :string_with_spaces' do |string_with_spaces|
    @filter ||= get_filter
    text, key = case string_with_spaces
                when 'main categories', 'sub categories'
                  [_('Categories'), :category_ids]
                when 'budget periods'
                  [_('Budget periods'), :budget_period_ids]
                when 'states'
                  [_('State of Request'), :states]
                when 'departments', 'organisations'
                  [_('Organisations'), :organization_ids]
                else
                  raise
                end
    within '#filter_panel .form-group', text: text do
      case string_with_spaces
      when 'states'
          @filter[key] = all(:checkbox, minimum: 1).map do |x|
              x.set true
              x[:value]
          end
      else
          within '.btn-group' do
            find('button.multiselect').click # NOTE open the dropdown
            within '.dropdown-menu' do
              selector = case string_with_spaces
                         when 'main categories'
                           "li.multiselect-group input[type='checkbox']"
                         else
                           'li:not(.multiselect-group):not(.multiselect-all) ' \
                           "input[type='checkbox']"
                         end
              @filter[key] = all(selector, minimum: 1).sample(2).map do |x|
                x.set true
                x[:value]
              end
              # @filter[key].delete('multiselect-all')
            end
            find('button.multiselect').click # NOTE close the dropdown
          end
      end
    end
  end

  step 'I :boolean the filter :special_filter' do |boolean, special_filter|
    if boolean
      within '#filter_panel .form-group', text: _('Special filters') do
        expect(page).to have_selector 'ul label .label', text: _(special_filter)
      end
    else
      expect(page).to have_no_selector \
        '#filter_panel .form-group ul label .label', text: _(special_filter)
    end
  end

  step 'I deselect :special_filter' do |special_filter|
    within '#filter_panel .form-group', text: _('Special filters') do
      uncheck _(special_filter)
    end
  end

  step 'I select :special_filter' do |special_filter|
    within '#filter_panel .form-group', text: _('Special filters') do
      check _(special_filter)
    end
  end

  step 'I select "Only my own requests" if present' do
    if has_selector? '#filter_panel .form-group', text: _('Special filters')
      step 'I select "Only my own requests"'
    end
  end

  step 'I select the current budget period' do
    budget_period = Procurement::BudgetPeriod.current
    within '#filter_panel .form-group', text: _('Budget periods') do
      within '.btn-group' do
        find('button.multiselect').click # NOTE open the dropdown
        within '.dropdown-menu' do
          check budget_period.name
        end
        find('button.multiselect').click # NOTE close the dropdown
      end
    end
  end

  step 'only my categories are selected' do
    my_categories, other_categories = \
    Procurement::Category.all.partition do |category|
      category.inspectable_by?(@current_user)
    end
    within '#filter_panel' do
      within 'select[name="filter[category_ids][]"]', visible: false do
        my_categories.each do |category|
          expect(find "option[value='#{category.id}']", visible: false).to \
            be_selected
        end
        other_categories.each do |category|
          expect(find "option[value='#{category.id}']", visible: false).not_to \
            be_selected
        end
      end
    end
  end

  step 'only categories having requests are selected' do
    cats_with, cats_without = \
    Procurement::Category.all.partition do |category|
      category.requests.exists?
    end
    within '#filter_panel' do
      within 'select[name="filter[category_ids][]"]', visible: false do
        cats_with.each do |category|
          expect(find "option[value='#{category.id}']", visible: false).to \
            be_selected
        end
        cats_without.each do |category|
          expect(find "option[value='#{category.id}']", visible: false).not_to \
            be_selected
        end
      end
    end
  end

  step 'the checkbox "Only show my own request" is not marked' do
    within '#filter_panel .form-group', text: _('Special filters') do
      expect(find('input[name="user_id"]')).not_to be_checked
    end
  end

  step 'the current budget period is selected' do
    budget_period = Procurement::BudgetPeriod.current
    within '#filter_panel' do
      within 'select[name="filter[budget_period_ids][]"]', visible: false do
        expect(find "option[value='#{budget_period.id}']", visible: false).to \
          be_selected
      end
    end
  end

  step 'the filter "Only my own requests" is not selected' do
    within '#filter_panel .form-group', text: _('Special filters') do
      expect(find('input[name="user_id"]')).not_to be_checked
    end
  end

  step 'the filter settings have not changed' do
    step 'the filter "Only my own requests" is not selected'
    step 'the current budget period is selected'
    step 'all categories are selected'
    step 'all organisations are selected'
    step 'both priorities are selected'
    step 'all states are selected'
    step 'the search field is empty'
  end

  step 'the search field is empty' do
    within '#filter_panel .form-group', text: _('Search') do
      expect(find('input[name="filter[search]"]').value).to be_empty
    end
  end

  step 'the state :state :boolean present' do |state, boolean|
    expect(Procurement::Request::STATES.map { |state| _(state.to_s.humanize) })
      .to include _(state)

    within '#filter_panel .form-group', text: _('State of Request') do
      if boolean
        expect(page).to have_selector 'ul li label .label', text: _(state)
      else
        expect(page).to have_no_selector 'ul li label .label', text: _(state)
      end
    end
  end

  def found_requests
    @filter ||= get_filter
    h = { budget_period_id: @filter[:budget_period_ids],
          category_id: @filter[:category_ids],
          priority: @filter[:priorities] }
    h[:user_id] = @filter[:user_id] if @filter[:user_id]

    Procurement::Request.search(@filter[:search]).where(h).select do |r|
      @filter[:states].map(&:to_sym).include? r.state(@current_user)
    end
  end

  def get_filter
    params_string = page.evaluate_script %{ $('form#filter_panel').serialize() }
    params_hash = CGI::parse params_string
    h = { budget_period_ids: params_hash['filter[budget_period_ids][]'],
          category_ids: params_hash['filter[category_ids][]'],
          organization_ids: params_hash['filter[organization_ids]'],
          priorities: params_hash['filter[priorities][]'],
          states: params_hash['filter[states][]'],
          search: params_hash['filter[search][]'] }
    h[:user_id] = @current_user.id unless params_hash['user_id'].blank?

    h[:budget_period_ids].delete('multiselect-all')
    h[:organization_ids].delete('multiselect-all')

    if h[:search].blank?
      h.delete(:search)
    end

    h
  end

end
# rubocop:enable Metrics/ModuleLength
