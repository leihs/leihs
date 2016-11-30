require_relative 'shared/common_steps'
require_relative 'shared/dataset_steps'
require_relative 'shared/navigation_steps'
require_relative 'shared/personas_steps'

steps_for :csv do
  include CommonSteps
  include DatasetSteps
  include NavigationSteps
  include PersonasSteps

  step 'I export the shown information' do
    # NOTE not really downloading the file,
    # but invoking directly the model class method

    within '.sidebar-wrapper' do
      # click_on _('CSV export')
      expect(page).to have_selector 'button', text: _('CSV export')
    end
  end

  step 'the following fields are exported' do |table|
    # NOTE not really downloading the file,
    # but invoking directly the model class method

    step 'I expand all the sub categories'

    @request_ids = all('[data-request_id]', minimum: 1).map do |el|
      el['data-request_id'].to_i
    end
    @csv_requests = Procurement::Request.find @request_ids

    require 'csv'
    @csv = CSV.parse Procurement::Request.csv_export(@csv_requests, @current_user),
                     col_sep: ';',
                     quote_char: "\"",
                     force_quotes: true,
                     headers: :first_row
    headers = @csv.headers

    table.raw.flatten.each do |value|
      expect(headers).to include case value
                                 when 'Replacement / New'
                                   format('%s / %s', _('Replacement'), _('New'))
                                 when 'Price'
                                   format('%s %s', _('Price'), _('incl. VAT'))
                                 when 'Total'
                                   format('%s %s', _('Total'), _('incl. VAT'))
                                 else
                                    _(value)
                                 end
    end

    expect(@csv.count).to eq @csv_requests.count
  end

  step 'the values for the following fields are not exported' do |table|
    table.raw.flatten.each do |column|
      @csv.map(&:to_h).each do |h|
        expect(h[_(column)]).to be_blank
      end
    end
  end

  step 'the values for the following fields are exported ' \
       'when the budget period has ended' do |table|
    @csv_requests.each do |request|
      request.budget_period.update_attributes(
        inspection_start_date: Date.yesterday - 1,
        end_date: Date.yesterday
      )
    end

    table.raw.flatten.each do |column|
      @csv.map(&:to_h).each do |h|
        expect(h[_(column)]).not_to be_blank
      end
    end
  end

  step 'following requests with all values filled in ' \
       'exist for the current budget period' do |table|
    Procurement::Request.destroy_all

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
      n.times do
        FactoryGirl.create :procurement_request, :full, h
      end
      expect(current_budget_period.requests.where(user_id: user).count).to eq n
    end
  end

  step 'I see the excel export button' do
    expect(page).to have_selector('button', text: _('Excel export'))
  end
end
