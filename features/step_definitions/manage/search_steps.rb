# -*- encoding : utf-8 -*-

Given /^I search for the inventory code of an item that is in a contract$/ do
  @contract = @current_user.inventory_pools.first.reservations_bundles.signed.first
  @item = @contract.items.first
end

Then /^I see the contract this item is assigned to in the list of results$/ do
  expect(@current_user.inventory_pools.first.reservations_bundles.search(@item.inventory_code)).to include @contract
end

Given(/^there is a user with contracts who no longer has access to the current inventory pool$/) do
  @user = User.find {|u| u.access_rights.find {|ar| ar.inventory_pool == @current_inventory_pool and ar.deleted_at} and !u.reservations_bundles.blank?}
  expect(@user).not_to be_nil
end

Then(/^I see all that user's contracts$/) do
  @user.reservations_bundles.each {|c| find("#contracts .line[data-id='#{c.id}']") }
end

Then(/^I see that user's signed and closed contracts$/) do
  @user.reservations_bundles.signed_or_closed.where(inventory_pool: @current_inventory_pool).each {|c| find("#contracts .line[data-id='#{c.id}']") }
end

Then(/^the name of that user is shown on each contract line$/) do
  within '#contracts' do
    all('.line').each {|el| el.text.include? @user.name }
  end
end

Then(/^that user's personal details are shown in the tooltip$/) do
  hover_for_tooltip find("#contracts [data-type='user-cell']", match: :first)
  within '.tooltipster-base' do
    [@user.name, @user.email, @user.address, @user.phone, @user.badge_id].each {|info| has_content? info}
  end
end

Given(/^there is a user with an unapproved order$/) do
  @user = @current_inventory_pool.users.find {|u| u.reservations_bundles.submitted.exists? }
end

When(/^I search for that user$/) do
  within '#search' do
    find('input#search_term').set @user.name
    find("button[type='submit']").click
  end
end

Then(/^I cannot hand over the unapproved order unless I approve it first$/) do
  contract = @user.reservations_bundles.submitted.first
  line = find(".line[data-id='#{contract.id}']")
  expect(line.find('.multibutton').has_no_selector?('li', text: _('Hand Over'), visible: false)).to be true
end

Given(/^there is a user with at least (\d+) and less than (\d+) contracts$/) do |min, max|
  @user = @current_inventory_pool.users.find do |u|
    u.reservations_bundles.signed_or_closed.where(inventory_pool: @current_inventory_pool).to_a.size.between? min.to_i, max.to_i # NOTE count returns a Hash because the group() in default scope
  end
  expect(@user).not_to be_nil
end

Then(/^I don't see a link labeled 'Show all matching contracts'$/) do
  expect(has_no_selector?("#contracts [data-type='show-all']")).to be true
end

Given(/^there is a "(.*?)" item in my inventory pool$/) do |arg1|
  items = @current_inventory_pool.items
  @item = case arg1
          when 'Broken'
            items.find &:is_broken
          when 'Retired'
            items.find &:retired
          when 'Incomplete'
            items.find &:is_incomplete
          when 'Unborrowable'
            items.find {|i| not i.is_borrowable}
          end
  expect(@item).not_to be_nil
end

When(/^I search globally after this item with its inventory code$/) do
  within '#topbar #search' do
    find('input#search_term').set @item.inventory_code
    find("button[type='submit']").click
  end
end

Then(/^I see the item in the items container$/) do
  expect(find('#items')).to have_selector(".line[data-type='item']", text: @item.inventory_code)
end

Given(/^there exists a closed contract with a retired item$/) do
  @contract = @current_inventory_pool.reservations_bundles.closed.find do |c|
    @item = c.items.find &:retired
  end
  expect(@contract).not_to be_nil
end


Then(/^I see the item in the items area$/) do
  find('#items .line', text: @item.inventory_code)
end

Then(/^I hover over the list of items on the contract line$/) do
  find("#contracts .line [data-type='lines-cell']", match: :first).hover
end

Then(/^I see in the tooltip the model of this item$/) do
  find('.tooltipster-base', text: @item.model.name)
end

Given(/^there exists a closed contract with an item, for which an other inventory pool is responsible and owner$/) do
  @contract = @current_inventory_pool.reservations_bundles.closed.find do |c|
    @item = c.items.find {|i| i.inventory_pool != @current_inventory_pool and i.owner != @current_inventory_pool }
  end
  expect(@contract).not_to be_nil
end

Then(/^I do not see the items container$/) do
  expect(page).to have_no_selector '#items'
end

Given(/^enough data for "(.*?)" having "(.*?)" exists$/) do |subsection, search_string|
  amount = 25
  @results = []
  make_string = proc { "#{Faker::Lorem.characters(8)} #{search_string} #{Faker::Lorem.characters(8)}" }

  amount.times do
    @results << \
      case subsection
      when 'Models'
        FactoryGirl.create(:model, product: make_string.call)
      when 'Software'
        FactoryGirl.create(:software, product: make_string.call)
      when 'Items'
        FactoryGirl.create(:item, note: make_string.call, inventory_pool: @current_inventory_pool)
      when 'Licenses'
        FactoryGirl.create(:license, note: make_string.call, inventory_pool: @current_inventory_pool)
      when 'Options'
        FactoryGirl.create(:option, product: make_string.call, inventory_pool: @current_inventory_pool)
      when 'Users'
        user = FactoryGirl.create(:user, lastname: make_string.call)
        FactoryGirl.create(:access_right, user: user, inventory_pool: @current_inventory_pool, role: 'customer')
        user
      when 'Contracts'
        user = FactoryGirl.create(:user, lastname: make_string.call)
        FactoryGirl.create(:access_right, user: user, inventory_pool: @current_inventory_pool, role: 'customer')
        FactoryGirl.create(:closed_contract, user: user, inventory_pool: @current_inventory_pool)
        user
      when 'Orders'
        user = FactoryGirl.create(:user, lastname: make_string.call)
        FactoryGirl.create(:access_right, user: user, inventory_pool: @current_inventory_pool, role: 'customer')
        FactoryGirl.create(:reservation, user: user, inventory_pool: @current_inventory_pool, status: :submitted)
        user
      end
  end
end

When(/^I search globally for "(.*?)"$/) do |search_string|
  within '#search' do
    find('input#search_term').set search_string
    find("button[type='submit']").click
  end
end

Then(/^the search results for "(.*?)" are displayed$/) do |search_string|
  expect(page).to have_content _('Search Results')
end

When(/^I click on the tab named "(.*?)"$/) do |subsection|
  find('.navigation-tab-item', text: _(subsection)).click
end

Then(/^the first page of results is shown$/) do
  expect(page).to have_selector '.row.line'
end

Then(/^I see all the entries matching "(.*?)" in the "(.*?)"$/) do |search_string, subsection|
  @results.each do |r|
    case subsection
    when 'Models', 'Software', 'Users', 'Contracts', 'Orders'
      find '.row.line', text: r.name
    when 'Items', 'Licenses', 'Options'
      find '.row.line', text: r.inventory_code
    end
  end
end

Then(/^the items container shows the item line with the following information:$/) do |table|
  # table is a Cucumber::Ast::Table
  within "#items .line[data-id='#{@item.id}']" do
    table.raw.flatten.each do |field|
      expect(page).to have_content \
        case field
        when 'Inventory Code'
          @item.inventory_code
        when 'Model name'
          @item.model.name
        when 'Responsible inventory pool'
          @item.inventory_pool.name
        end
    end
  end
end
  #
Then(/^I don't see the button group on the item line$/) do
  within "#items .line[data-id='#{@item.id}']" do
    expect(page).not_to have_selector '.multibutton'
  end
end
