When /^I manually assign an inventory code to an item$/ do
  step 'I click an inventory code input field of an item line'
  step 'I select one of those'
end

Then /^the item is selected and the box is checked$/ do
  find('#flash')
  within(".line[data-id='#{@item_line.id}']") do
    find("input[data-assign-item][value='#{@selected_inventory_code}']")
    find("input[type='checkbox'][data-select-line]:checked")
    expect(@item_line.reload.item.inventory_code).to eq @selected_inventory_code
  end
  step 'the count matches the amount of selected reservations'
end

When /^I try to complete a hand over that contains a model with unborrowable items$/ do
  @reservation = nil
  @contract = @current_inventory_pool.reservations_bundles.approved.detect do |c|
    @reservation = c.item_lines.where(item_id: nil).detect do |l|
      l.model.items.unborrowable.where(inventory_pool_id: @current_inventory_pool).first
    end
  end
  @model = @reservation.model
  @customer = @contract.user
  step 'I open a hand over for this customer'
  expect(has_selector?('#hand-over-view', visible: true)).to be true
end

When /^I try to assign an inventory code to this model$/ do
  @item_line_element = find(".line[data-id='#{@reservation.id}']", visible: true)
  @item_line_element.find('[data-assign-item]').click
end

Then /^the system suggests a list of items$/ do
  find('.ui-autocomplete .ui-menu-item', match: :first)
end

Then /^unborrowable items are highlighted$/ do
  @model.items.unborrowable.in_stock.each do |item|
    find('.ui-autocomplete .ui-menu-item a.light-red', text: item.inventory_code)
  end
end

Given /^I (open|return to) the daily view$/ do |arg1|
  @current_inventory_pool = @current_user.inventory_pools.managed.order('RAND()').detect {|ip| ip.visits.hand_over.where(date: Date.today).exists? }
  visit manage_daily_view_path(@current_inventory_pool)
  find('#daily-view')
end

When(/^I edit an order$/) do
  @event = 'order'
  @contract = @current_inventory_pool.reservations_bundles.submitted.order('RAND()').first
  @user = @contract.user
  @customer = @contract.user
  step 'I edit the order'
end

When(/^I edit the order$/) do
  visit manage_edit_contract_path(@current_inventory_pool, @contract)
end

Then(/^the user appears under last visitors$/) do
  visit manage_daily_view_path @current_inventory_pool
  find('#last-visitors a', text: @user.name)
end

When /^the chosen items contain some from a future hand over$/ do
  find('#add-start-date').set I18n.l(Date.today+2.days)
  step 'I add an item to the hand over by providing an inventory code'
end

Then /^I see an error message( within the booking calendar)?$/ do |arg1|
  if arg1
    within '.modal' do
      find('#booking-calendar-errors', text: /.*/)
    end
  else
    find('#flash .error')
  end
end

Then /^I cannot hand over the items$/ do
  expect(has_no_selector?('.hand_over .summary')).to be true
end


Given /^the customer is in multiple groups$/ do
  @customer = @current_inventory_pool.users.detect{|u| u.groups.exists? }
  expect(@customer).not_to be_nil
end


When /^I open a hand over to this customer$/ do
  visit manage_hand_over_path(@current_inventory_pool, @customer)
  expect(has_selector?('#hand-over-view')).to be true
  step 'the availability is loaded'
end


When /^I edit a line containing group partitions$/ do
  @inventory_code = @current_inventory_pool.models.detect {|m| m.partitions.size > 1}.items.in_stock.borrowable.first.inventory_code
  @model = Item.find_by_inventory_code(@inventory_code).model
  step 'I assign an item to the hand over by providing an inventory code and a date range'
  find(:xpath, "//*[contains(@class, 'line') and descendant::input[@data-assign-item and @value='#{@inventory_code}']]", match: :first).find('button[data-edit-lines]').click
end


When /^I expand the group selector$/ do
  find('#booking-calendar-partitions')
end


Then /^I see which groups the customer is a member of$/ do
  @customer_group_ids = @customer.groups.map(&:id)
  @model.partitions.each do |partition|
    next if partition.group_id.nil?
    if @customer_group_ids.include? partition.group_id
      expect(find("#booking-calendar-partitions optgroup[label='#{_("Groups of this customer")}']").has_content? partition.group.name).to be true
    end
  end
end

Then /^I see which groups the customer is not a member of$/ do
  @model.partitions.each do |partition|
    next if partition.group_id.nil?
    unless @customer_group_ids.include?(partition.group_id)
      expect(find("#booking-calendar-partitions optgroup[label='#{_("Other groups")}']").has_content? partition.group.name).to be true
    end
  end
end


When /^I open a hand over for a customer that has things to pick up today as well as in the future$/ do
  @customer = @current_inventory_pool.users.detect{|u| u.visits.hand_over.to_a.size > 1} # NOTE count returns a Hash because the group() in default scope
  step 'I open a hand over to this customer'
end

When /^I scan something \(assign it using its inventory code\) and it is already assigned to a future contract$/ do
  @model = @customer.reservations_bundles.approved.find_by(inventory_pool_id: @current_inventory_pool).models.order('RAND()').detect do |model|
    @item = model.items.borrowable.in_stock.where(inventory_pool: @current_inventory_pool).order('RAND()').first
  end
  find('#assign-or-add-input input').set @item.inventory_code
  find('#assign-or-add button').click
  @assigned_line = find("[data-assign-item][disabled][value='#{@item.inventory_code}']")
end


Then /^it is assigned \(whether it is selected or not\)$/ do
  @assigned_line.find(:xpath, './../../..').find("input[type='checkbox'][data-select-line]:checked")
end

When /^it doesn't exist in any future contracts$/ do
  @model_not_in_contract = (@current_inventory_pool.items.borrowable.in_stock.map(&:model).uniq -
                              @customer.reservations_bundles.approved.find_by(inventory_pool_id: @current_inventory_pool).models).sample
  @item = @model_not_in_contract.items.borrowable.in_stock.order('RAND()').first
  find('#add-start-date').set I18n.l(Date.today+7.days)
  find('#add-end-date').set I18n.l(Date.today+8.days)
  find('#assign-or-add-input input').set @item.inventory_code
  @amount_lines_before = all('.line').size
  find('#assign-or-add button').click
end

Then /^it is added for the selected time span$/ do
  find('#flash')
  find('.line', match: :first, text: @model)
  expect(@amount_lines_before).to be < all('.line').size
end


Given /^I am doing a hand over$/ do
  @event = 'hand_over'
  step 'I open a hand over'
end

When(/^I click on "(.*?)"$/) do |arg1|
  case arg1
    when 'Continue this order'
      find('.button', text: _('Continue this order')).click
    when 'Continue with available models only'
      find('.dropdown-item', text: _('Continue with available models only')).click
    when 'Delegations'
      find('.dropdown-item', text: _('Delegations')).click
    else
      step %Q(I press "#{arg1}")
  end
end

When /^I open a hand over for this customer$/ do
  visit manage_hand_over_path(@current_inventory_pool, @customer)
  expect(has_selector?('#hand-over-view')).to be true
  step 'the availability is loaded'
end

When(/^I fill in all the necessary information in hand over dialog$/) do
  if has_css?('#contact-person')
    contact_field = find('#contact-person').all('input#user-id').first
    contact_field.click
    find('.ui-menu-item', match: :first).click
  end
  fill_in 'purpose', with: Faker::Lorem.sentence
end

Then(/^there are inventory codes for item and license in the contract$/) do
  # Sleeps are not sexy, but for some reason on busy systems, the contract
  # window opens very slowly and then this test is reliably red.
  if page.driver.browser.window_handles.count < 2
    sleep 2
  end
  page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
  @inventory_codes.each {|inv_code|
    expect(has_content?(inv_code)).to be true
  }
end


Then /^I can inspect each item$/ do
  line_ids = all(".line[data-line-type='item_line']", minimum: 1).map {|l| l['data-id']}
  line_ids.each do |id|
    within find(".line[data-id='#{id}'] .multibutton") do
      find('.dropdown-toggle').click
      find('.dropdown-holder .dropdown-item', text: _('Inspect'))
    end
  end
end


When /^I inspect an item$/ do
  within all(".line[data-line-type='item_line']", minimum: 1).to_a.sample.find('.multibutton') do
    @item = Reservation.find(JSON.parse(find('[data-ids]')['data-ids']).first).item
    find('.dropdown-toggle').click
    find('.dropdown-holder .dropdown-item', text: _('Inspect')).click
  end
  find('.modal')
end

Then /^I can set the state of "(.*?)" to "(.*?)" or "(.*?)"$/ do |arg1, arg2, arg3|
  within('.col1of3', text: arg1) do
    find('option', text: arg2)
    find('option', text: arg3)
  end
end

When /^I change values during inspection$/ do
  @is_borrowable = true
  find("select[name='is_borrowable'] option[value='true']").select_option
  @is_broken = true
  find("select[name='is_broken'] option[value='true']").select_option
  @is_incomplete = true
  find("select[name='is_incomplete'] option[value='true']").select_option
end

When /^I save the inspection$/ do
  find(".modal button[type='submit']").click
end

Then /^the item is saved with the currently set states$/ do
  visit current_path
  @item.reload
  expect(@item.is_borrowable).to eq @is_borrowable
  expect(@item.is_broken).to eq @is_broken
  expect(@item.is_incomplete).to eq @is_incomplete
end

Then /^the print dialog opens automatically$/ do
  step 'I select an item line and assign an inventory code'
  step 'I click hand over'
  within '.modal' do
    find('.button.green[data-hand-over]', text: _('Hand Over')).click
  end
  check_printed_contract(page.driver.browser.window_handles, @current_inventory_pool, @item_line)
end

When(/^start and end date are set to the corresponding dates of the hand over's first time window$/) do
  first_dates = find('#hand-over-view #lines [data-selected-lines-container]', match: :first).find('.row .col1of2 p.paragraph-s', match: :first).text
  start_date, end_date = first_dates.split('-').map{|x| Date.parse x}
  expect(Date.parse find('#add-start-date').value).to eq [start_date, Date.today].max
  expect(Date.parse find('#add-end-date').value).to eq [end_date, Date.today].max
end

Given /^I search for '(.*)'$/ do |arg1|
  @search_term = arg1
  find('#search_term').set(@search_term)
  find('#search_term').native.send_key :enter
end


Then /^I see search results in the following categories:$/ do |table|
  within '#search-overview' do
    table.hashes.each do |t|
      case t[:category]
        when 'Users'
          find('#users .list-of-lines .line', match: :first)
        when 'Models'
          find('#models .list-of-lines .line', match: :first)
        when 'Items'
          find('#items .list-of-lines .line', match: :first)
        when 'Contracts'
          find('#contracts .list-of-lines .line', match: :first)
        when 'Orders'
          find('#orders .list-of-lines .line', match: :first)
        when 'Options'
          find('#options .list-of-lines .line', match: :first)
      end
    end
  end
end

Then /^I see at most the first (\d+) results from each category$/ do |amount|
  amount = (amount.to_i+2)
  expect(all('.user .list .line:not(.toggle)', visible: true).size).to be <= amount
  expect(all('.model .list .line:not(.toggle)', visible: true).size).to be <= amount
  expect(all('.item .list .line:not(.toggle)', visible: true).size).to be <= amount
  expect(all('.contract .list .line:not(.toggle)', visible: true).size).to be <= amount
  expect(all('.order .list .line:not(.toggle)', visible: true).size).to be <= amount
end

When /^a category has more than (\d+) results$/ do |amount|
  @lists = []
  all('.list').each do |list|
    @lists.push(list) unless list.all('.hidden .line:not(.show-all)').empty?
  end
end

Then /^I can choose to see more results from that category$/ do

  @lists.each do |list|
    list.find('.toggle', match: :first)
  end
end

When /^I choose to see more results$/ do
  @lists.each do |list|
    list.find('.toggle .text', match: :first).click
  end
end


Then /^I see the first (\d+) results$/ do |amount|
  amount = amount.to_i + 2
  @lists.each do |list|
    if list.all('.show-all').size > 0
      expect(list.all('.line').size).to eq amount
    end
  end
end

When /^the category has more than (\d+) results$/ do |amount|
  amount = amount.to_i
  @list_with_more_matches = all('.inlinetabs .badge').map do |badge|
    badge.first(:xpath, '../../..').find('.list', match: :first) if badge.text.to_i > amount
  end.compact
end

Then /^I can choose to see all results$/ do
  @links_of_more_results = @list_with_more_matches.map do |list|
    list.find('.line.show-all a', visible: false)[:href]
  end
end

When /^I choose to see all results, I receive a separate list with all results from this category$/ do
  @links_of_more_results.each do |link|
    visit link
    find('#search_results.focused')
  end
end

Given /^I hover over the number of items in a line$/ do
  find(".line [data-type='lines-cell']", match: :first).hover
  @lines = all(".line [data-type='lines-cell']")
end

Then /^all these items are listed$/ do
  all('button[data-collapsed-toggle]').each(&:click)
  hover_for_tooltip @lines.to_a.sample
end

Then /^I see one line per model$/ do
  within('.tooltipster-default', match: :first, visible: true) do
    all('.exclude-last-child', minimum: 1).each do |div|
      model_names = div.all('.row .col7of8:nth-child(2) strong', text: /.+/).map &:text
      expect(model_names.size).to eq model_names.uniq.size
    end
  end
end

Then /^each line shows the sum of items of the respective model$/ do
  within('.tooltipster-default', match: :first, visible: true) do
    quantities = all('.row .col1of8:nth-child(1)', minimum: 1, text: /.+/).map{|x| x.text.to_i}
    expect(quantities.sum).to be >= quantities.size
  end
end

Then /^I open an order( placed by "(.*?)")$/ do |arg0, arg1|
  step %Q(I uncheck the "No verification required" button)

  if arg0
    @contract = @current_inventory_pool.reservations_bundles.find find('.line', match: :prefer_exact, text: arg1)['data-id']
    within('.line', match: :prefer_exact, text: arg1) do
      find('.line-actions .multibutton .dropdown-holder').click
      find('.dropdown-item', text: _('Edit')).click
    end
  else
    @contract = @current_inventory_pool.reservations_bundles.submitted.order('RAND()').first
    visit manage_edit_contract_path(@current_inventory_pool, @contract)
  end
  @user = @contract.user
  find('h1', text: _('Edit %s') % _('Order'))
  find('h2', text: @user.to_s)
end

Then /^I see the last visitors$/ do
  find('#daily-view strong', text: _('Last Visitors:'))
end


Then(/^I see the previously opened order's user as last visitor$/) do
  find('#daily-view #last-visitors', text: @contract.user.name)
end

When(/^I click on the last visitor's name$/) do
  find('#daily-view #last-visitors a', text: @contract.user.name).click
end

Then(/^I see search results matching that user's name$/) do
  find('#search-overview h1', text: _("Search Results for \"%s\"") % @contract.user.name)
end

When(/^I enter something in the "(.*?)" field$/) do |field_label|
  case field_label
    when 'Inventory Code/Name'
      find('#assign-or-add-input input, #assign-input').set ' '
    else
      raise
  end
end

When(/^I open a take back that contains options$/) do
  @customer = @current_inventory_pool.users.all.select {|x| x.reservations_bundles.signed.exists? and !x.reservations_bundles.signed.detect{|c| c.options.exists? }.nil? }.first
  visit manage_take_back_path(@current_inventory_pool, @customer)
  expect(has_selector?('#take-back-view')).to be true
end

When(/^I manually change the number of options to return$/) do
  @option_line = find(".line[data-line-type='option_line']", match: :first)
  @option_line.find('[data-quantity-returned]').set 1
end

Then(/^the option is selected and the box is checked$/) do
  @option_line.find('input[data-select-line]:checked')
  step 'the count matches the amount of selected reservations'
end
