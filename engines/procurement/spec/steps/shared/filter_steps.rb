# rubocop:disable Metrics/ModuleLength
module FilterSteps

  step 'all groups in the filter groups are selected' do
    within '#filter_panel' do
      within 'select[name="filter[group_ids][]"]', visible: false do
        Procurement::Group.all.each do |group|
          expect(find "option[value='#{group.id}']", visible: false).to \
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
    within '#filter_panel .form-group', text: _('Priority') do
      ['high', 'normal'].each do |priority|
        expect(find "input[value='#{priority}']").to be_selected
      end
    end
  end

  step 'I do not see the filter "Only show my own requests"' do
    within '#filter_panel' do
      expect(page).to have_no_selector 'input[name="user_id"]'
      expect(page).to have_no_selector('div', text: _('Only show my own requests'))
    end
  end

  step 'I enter a search string' do
    @filter ||= {}
    request = Procurement::Request.where(
      budget_period_id: @filter[:budget_period_ids],
      group_id: @filter[:group_ids],
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
           when 'groups'
               _('Groups')
           when 'budget periods'
               _('Budget periods')
           when 'organisations'
               _('Organisations')
           when 'states'
               _('State of Request')
           else
               raise
           end
    within '#filter_panel .form-group', text: text do
      case string_with_spaces
      when 'states'
          all(:checkbox, minimum: 4).each { |x| x.set true }
      else
          within '.btn-group' do
            find('button.multiselect').click # NOTE open the dropdown
            within '.dropdown-menu' do
              case string_with_spaces
              when 'organisations'
                  choose _('All')
              else
                  check _('Select all')
              end
            end
            find('button.multiselect').click # NOTE close the dropdown
          end
      end
    end
  end

  step 'I select both priorities' do
    @filter ||= {}
    within '#filter_panel .form-group', text: _('Priority') do
      @filter[:priorities] = all(:checkbox, count: 2).map do |x|
        x.set true
        x[:value]
      end
    end
  end

  step 'I select one ore both priorities' do
    @filter ||= {}
    if [true, false].sample
      step 'I select both priorities'
    else
      within '#filter_panel .form-group', text: _('Priority') do
        @filter[:priorities] = [find(:checkbox, match: :first)].map do |x|
          x.set true
          x[:value]
        end
      end
    end
  end

  step 'I select one or more :string_with_spaces' do |string_with_spaces|
    @filter ||= {}
    text, key = case string_with_spaces
                when 'groups'
                  [_('Groups'), :group_ids]
                when 'budget periods'
                  [_('Budget periods'), :budget_period_ids]
                when 'states'
                  [_('State of Request'), :states]
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
              @filter[key] = all(:checkbox, minimum: 1).sample(2).map do |x|
                x.set true
                x[:value]
              end
              @filter[key].delete('multiselect-all')
            end
            find('button.multiselect').click # NOTE close the dropdown
          end
      end
    end
  end

  step 'I select "Only show my own requests"' do
    within '#filter_panel .form-group', text: _('Requests') do
      check _('Only show my own requests')
    end
  end

  step 'I select "Only show my own requests" if present' do
    if has_selector? '#filter_panel .form-group', text: _('Requests')
      step 'I select "Only show my own requests"'
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

  step 'only my groups are selected' do
    my_groups, other_groups = Procurement::Group.all.partition do |group|
      group.inspectable_by?(@current_user)
    end
    within '#filter_panel' do
      within 'select[name="filter[group_ids][]"]', visible: false do
        my_groups.each do |group|
          expect(find "option[value='#{group.id}']", visible: false).to \
            be_selected
        end
        other_groups.each do |group|
          expect(find "option[value='#{group.id}']", visible: false).not_to \
            be_selected
        end
      end
    end
  end

  step 'the checkbox "Only show my own request" is not marked' do
    within '#filter_panel .form-group', text: _('Requests') do
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

  step 'the filter "Only show my own requests" is selected' do
    within '#filter_panel .form-group', text: _('Requests') do
      expect(find('input[name="user_id"]')).to be_checked
    end
  end

  step 'the filter settings have not changed' do
    step 'the filter "Only show my own requests" is selected'
    step 'the current budget period is selected'
    step 'all groups in the filter groups are selected'
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
end
# rubocop:enable Metrics/ModuleLength
