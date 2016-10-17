# -*- encoding : utf-8 -*-

Given /^the availability is loaded$/ do
  within '#status' do
    unless has_content? _('No hand overs found')
      find('.fa.fa-check')
      find('p', text: _('Availability loaded'))
    end
  end
end


Given(/^there is a hand over with at least (\d+) assigned items for a user$/) do |count|
  @hand_over = @current_inventory_pool.visits.hand_over.find {|ho| ho.reservations.select(&:item).size >= count.to_i}
  expect(@hand_over).not_to be_nil
end

When(/^I open the hand over$/) do
  visit manage_hand_over_path(@current_inventory_pool, @hand_over.user)
  step 'the availability is loaded'
end

Then(/^I see the already assigned items and their inventory codes$/) do
  @hand_over.reservations.each do |line|
    next if not line.is_a?(ItemLine) or line.item_id.nil?
    find("[data-assign-item][disabled][value='#{line.item.inventory_code}']")
  end
end


When(/^the user in this hand over is suspended$/) do
  ensure_suspended_user(@customer, @current_inventory_pool)
  step 'I open a hand over to this customer'
end

# Superseded by sign_contract_steps.rb
Given(/^I open a hand over containing software$/) do
  @hand_over = @current_inventory_pool.visits.hand_over.order('RAND ()').detect {|v| v.reservations.any?{|cl| cl.model.is_a? Software } }
  step 'I open the hand over'
end

Given(/^there is a hand over with at least one unproblematic model( and an option)?$/) do |arg1|
  @models_in_stock = @current_inventory_pool.items.in_stock.map(&:model).uniq
  @hand_over = @current_inventory_pool.visits.hand_over.detect do |v|
    b = v.reservations.select do |line|
      !line.start_date.past? and !line.item and @models_in_stock.include?(line.model)
    end.count >= 1
    if arg1 and b
      b = (b and v.reservations.any? {|line| line.is_a? OptionLine })
    end
    b
  end
  expect(@hand_over).not_to be_nil
end


Given(/^there is a hand over with at least (one problematic line|an item without room or shelf)$/) do |arg1|
  @hand_over = @current_inventory_pool.visits.hand_over.find do |ho|
    ho.reservations.any? do |l|
      if l.is_a? ItemLine
        case arg1
          when 'one problematic line'
            #old#
            # av = l.model.availability_in(@current_inventory_pool).maximum_available_in_period_summed_for_groups(l.start_date, l.end_date, ho.user.group_ids)
            # l.start_date.past? and av > 1
            not l.complete?
          when 'an item without room or shelf'
            l.item and (l.item.location.nil? or (l.item.location.room.blank? and l.item.location.shelf.blank?))
          else
            raise
        end
      end
    end
  end
  expect(@hand_over).not_to be_nil
end

When(/^I assign an inventory code to the unproblematic model$/) do
  @reservation = @hand_over.reservations.find {|l| !l.start_date.past? and !l.item and @models_in_stock.include?(l.model) }
  @line_css = ".line[data-id='#{@reservation.id}']"
  within @line_css do
    find('input[data-assign-item]').click
    find('li.ui-menu-item a', match: :first).click
  end
end

Then(/^the item is assigned to the line$/) do
  find('#flash')
  expect(@reservation.reload.item).not_to be_nil
end


Then(/^the line is selected$/) do
  find(@line_css).find('input[type=checkbox]:checked')
end

Then(/^the line is highlighted in green$/) do
  expect(find(@line_css).native.attribute('class')).to include 'green'
end


When(/^I deselect the line$/) do
  within @line_css do
    find('input[type=checkbox]').click
    expect(find('input[type=checkbox]').checked?).to be false
  end
end

Then(/^the line is no longer highlighted in green$/) do
  expect(find(@line_css).native.attribute('class')).not_to include 'green'
end

When(/^I reselect the line$/) do
  within @line_css do
    find('input[type=checkbox]').click
    find('input[type=checkbox]:checked')
  end
end

When(/^I remove the assigned item from the line$/) do
  find(@line_css).find('.fa.fa-times-circle').click
end

Then(/^problem notifications are shown for the problematic model$/) do
  @reservation = @hand_over.reservations.find do |l|
    if l.is_a? ItemLine
      #old#
      # av = l.model.availability_in(@current_inventory_pool).maximum_available_in_period_summed_for_groups(l.start_date, l.end_date, @hand_over.user.group_ids)
      # l.start_date.past? and av > 1
      not l.complete?
    end
  end
  @line_css = ".line[data-id='#{@reservation.id}']"
  step 'the problem notifications remain on the line'
end

When(/^I manually assign an inventory code to that line$/) do
  within @line_css do
    find('input[data-assign-item]').click
    find('li.ui-menu-item a', match: :first).click
  end
end

Then(/^the problem notifications remain on the line$/) do
  within @line_css do
    expect(has_selector?('.line-info.red')).to be true
    expect(has_selector?('.tooltip.red')).to be true
  end
end

When(/^I assign an already added item$/) do
  @reservation = @hand_over.reservations.find {|l| l.is_a? ItemLine and l.item}
  @number_of_lines_with_item_model = \
    all(".line", text: @reservation.model.name).size
  @line_css = ".line[data-id='#{@reservation.id}']"
  find(@line_css).find("input[type='checkbox']").click

  find('#assign-or-add-input input').set @reservation.item.inventory_code
  find('form#assign-or-add button .fa.fa-plus', match: :first).click
end



Then(/^I see the error message 'XY is already assigned to this contract'$/) do
  find '#flash', text: _('%s is already assigned to this contract') % @reservation.item.inventory_code
end


Given(/^I open a hand over with at least one assigned item$/) do
  @hand_over = @current_inventory_pool.visits.hand_over.find {|ho| ho.reservations.any? &:item_id}
  step 'I open the hand over'
end

Then(/^the line remains selected$/) do
  expect(has_selector?("#{@line_css} input[type='checkbox']:checked")).to be true
end

Then(/^the line remains highlighted in green$/) do
  expect(has_selector?("#{@line_css}.green")).to be true
end

Then(/^no new line for this model is added$/) do
  visit manage_hand_over_path(@current_inventory_pool, @hand_over.user)
  find(".line", text: @reservation.model.name)
  expect(all(".line", text: @reservation.model.name).size)
    .to be == @number_of_lines_with_item_model
end

Given(/^there is a default contract note for the inventory pool$/) do
  expect(@current_inventory_pool.default_contract_note).not_to be_nil
end


Then(/^a hand over dialog appears$/) do
  expect(has_selector?('.modal [data-hand-over]')).to be true
end

Then(/^a dialog appears$/) do
  expect(has_selector?('.modal')).to be true
end


Then(/^the contract note field in this dialog is already filled in with the default note$/) do
  find("textarea[name='note']", text: @current_inventory_pool.default_contract_note)
end

Then(/^I can enter some text in the contract note field$/) do
  find("textarea[name='note']")
end

When(/^I enter "(.*?)" in the contract note field$/) do |string|
  field = find("textarea[name='note']")
  fill_in field[:id], with: string
end


When(/^I change the quantity to "(.*?)"$/) do |arg1|
  within @line_css do
    find('input[data-line-quantity]').set arg1
    sleep(0.66) # NOTE this sleep is required in order to fire the change
  end
end

Then(/^the quantity will be restored to the original value$/) do
  within @line_css do
    expect(find("input[data-line-quantity]").value).to eq @option_line.reload.quantity.to_s
  end
end

Then(/^the quantity will be stored to the value "(.*?)"$/) do |arg1|
  step 'the quantity will be restored to the original value'
  expect(@option_line.quantity.to_s).to eq arg1
end

Given(/^a line has no item assigned yet and this line is marked$/) do
  step 'I can add models'
  @reservation = @hand_over.reservations.order(created_at: :desc).first
  @line_css = ".line[data-id='#{@reservation.id}']"
end

Given(/^a line with an assigned item which doesn't have a location is marked$/) do
  @reservation = @hand_over.reservations.where(type: 'ItemLine').find {|l| l.item and (l.item.location.nil? or (l.item.location.room.blank? and l.item.location.shelf.blank?)) }
  @line_css = ".line[data-id='#{@reservation.id}']"
  step 'I reselect the line'
end

Given(/^an option line is marked$/) do
  @reservation = @hand_over.reservations.where(type: 'OptionLine').order('RAND()').first
  @line_css = ".line[data-id='#{@reservation.id}']"
  step 'I reselect the line'
end

When(/^I select at least one line$/) do
  @line_css = all('.line[data-id]').to_a.sample
  step 'I reselect the line'
end

Given(/^there is a model with a problematic item$/) do
  @item = @current_inventory_pool.items.borrowable.in_stock.find {|item| item.is_broken? or item.is_incomplete?}
  expect(@item).not_to be_nil
  @model = @item.model
  expect(@model).not_to be_nil
end

Then(/^"(.*?)" appears on the contract$/) do |string|
  new_window = page.driver.browser.window_handles.last
  page.driver.browser.switch_to.window new_window
  contract_element = find('.contract')
  note_field = contract_element.find('section.note')
  expect(note_field.text.match(/#{string}/)).not_to be_nil
end

When(/^I open the item choice list on the model line$/) do
  within '#lines' do
    find('[data-line-type]', text: @model.name).find('[data-assign-item]').click
    expect(has_selector?('.ui-menu')).to be true
  end
end

Then(/^the problematic item is displayed red$/) do
  find('.ui-menu .ui-menu-item .light-red', text: @item.inventory_code)
end

Given(/^there is a model with a retired and a borrowable item$/) do
  @model = @current_inventory_pool.models.find { |m| m.items.borrowable.where(retired: nil).exists? and m.items.retired.exists? }
  expect(@model).not_to be_nil
  @item = @model.items.retired.order('RAND()').first
end

Then(/^the retired item is not displayed in the list$/) do
  expect(page).not_to have_selector('.ui-menu .ui-menu-item', text: @item.inventory_code)
end

Given(/^there exists an item owned by the current inventory pool but in responsibility of pool "(.*?)"$/) do |arg1|
  @item = FactoryGirl.create(:item,
                             owner: @current_inventory_pool,
                             inventory_pool: FactoryGirl.create(:inventory_pool,
                                                                name: arg1))
end

When(/^I assign an owned item where other inventory pool is responsible$/) do
  find('#assign-or-add-input input').set @item.inventory_code
  find('#assign-or-add button').click
end
