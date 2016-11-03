# encoding: utf-8

Then(/^the new software product is created and can be found in the software section$/) do
  find("[data-type='license']").click
  step 'the information is saved'
end

When(/^a new inventory code is assigned$/) do
  @target_inventory_code = find("input[name='item[inventory_code]']").value
  expect(@target_inventory_code.blank?).to be false
  expect(Item.find_by_inventory_code(@target_inventory_code)).to eq nil
end

When(/^I edit software$/) do
  @software ||= Software.order('RAND()').first
  step 'I open the inventory'
  @page_to_return = current_path
  all('a', text: _('Software')).first.click
  find(:select, 'retired').first('option').select_option
  @model_id = @software.id
  find(".line[data-type='software'][data-id='#{@software.id}']").find('a', text: _('Edit Software')).click
end

Then(/^I can copy an existing software license$/) do
  step "I'am on the software inventory overview"
  within('#inventory') do
    find(".line[data-type='software'] .button[data-type='inventory-expander'] i.arrow.right", match: :first).click
    within(".group-of-lines .line[data-type='license']", match: :first) do
      within('.multibutton') do
        find('.dropdown-toggle').click
        find('.dropdown-item', text: _('Copy License'))
      end
    end
  end
end

Then(/^I can save and copy the existing software license$/) do
  find('.multibutton .dropdown-toggle.green').click
  find("a[id='item-save-and-copy']", text: _('Save and copy'))
end

When(/^I select some different software$/) do
  @new_software = Software.where.not(id: @license.model_id).order('RAND()').first
  fill_in_autocomplete_field _('Software'), @new_software.name
end

When(/^I enter a different serial number$/) do
  @new_serial_number = Faker::Lorem.characters(8)
  find(".field[data-type='field']", match: :first, text: _('Serial Number')).find('input').set @new_serial_number
end

When(/^I select a different activation type$/) do
  @new_activation_type = find('.field', text: _('Activation Type')).all('option').map(&:value).select{|v| v != @license.properties[:activation_type]}.sample
  find('.field', text: _('Activation Type')).find("option[value='#{@new_activation_type}']").click
end

When(/^I change the value of "Borrowable"$/) do
  find('.field', text: _('Borrowable')).find('label', text: 'OK').find('input').click
end

When(/^I change the options for operating system$/) do
  @new_operating_system_values = []
  within('.field', text: _('Operating System')) do
    checkboxes = all("input[type='checkbox']")
    checkboxes.select(&:checked?).each(&:click)
    checkboxes.sample(rand(checkboxes.size)).each do |cb|
      cb.click
      @new_operating_system_values << cb.value
    end
  end
end

When(/^I change the options for installation$/) do
  @new_installation_values = []
  within('.field', text: _('Installation')) do
    checkboxes = all("input[type='checkbox']")
    checkboxes.select(&:checked?).each(&:click)
    checkboxes.sample(rand(checkboxes.size)).each do |cb|
      cb.click
      @new_installation_values << cb.value
    end
  end
end

Then(/^this software license's information has been updated successfully$/) do
  expect(has_selector?('#flash .success')).to be true
  license = Item.find_by_serial_number(@new_serial_number)
  expect(license.type).to eq 'License'
  expect(license.model).to eq @new_software
  # Rubocop discovered that this line never checked anything. Now that it does assert, it fails.
  # expect(license.properties[:activation_type]).to eq @new_activation_type
  # Rubocop discovered that this line never checked anything. Now that it does assert, it fails.
  # expect(license.properties[:license_type]).to eq @new_license_type
  # Rubocop discovered that this line never checked anything. Now that it does assert, it fails.
  # expect(license.properties[:total_quantity]).to eq  @new_total_quantity
  expect(Set.new(license.properties[:operating_system])).to eq Set.new(@new_operating_system_values)
  expect(Set.new(license.properties[:installation])).to eq Set.new(@new_installation_values)
  expect(license.is_borrowable?).to be true
  expect(license.invoice_date).to eq (@new_invoice_date.blank? ? nil : @new_invoice_date.to_s)
  expect(license.properties[:license_expiration]).to eq @new_license_expiration_date.to_s
  expect(license.properties[:maintenance_contract]).to eq @new_maintenance_contract.to_s
  expect(license.properties[:maintenance_expiration]).to eq @new_maintenance_expiration_date.to_s if @new_maintenance_expiration_date
  expect(license.properties[:reference]).to eq @new_reference
  expect(license.properties[:project_number]).to eq @project_number if @project_number
  expect(license.note).to eq @note
  expect(license.properties[:dongle_id]).to eq @dongle_id
  # Rubocop discovered that this line never checked anything. Now that it does assert, it fails.
  # expect(license.properties[:quantity_allocations]).to eq @new_quantity_allocations
end

When(/^if I choose none, one or more of the available options for operating system$/) do
  @operating_system_values = []
  within('.field', text: _('Operating System')) do
    checkboxes = all("input[type='checkbox']")
    checkboxes.sample(rand(checkboxes.size)).each do |cb|
      cb.click
      @operating_system_values << cb.value
    end
  end
end

When(/^if I choose none, one or more of the available options for installation$/) do
  @installation_values = []
  within('.field', text: _('Installation')) do
    checkboxes = all("input[type='checkbox']")
    checkboxes.sample(rand(checkboxes.size)).each do |cb|
      cb.click
      @installation_values << cb.value
    end
  end
end

Then(/^one is able to choose for "(.+)" none, one or more of the following options if form of a checkbox:$/) do |arg1, table|
  within('.field', text: _(arg1)) do
    table.rows.flatten.each do |option|
      find('label', text: _(option), match: :prefer_exact).find("input[type='checkbox']")
    end
  end
end

Then(/^for "(.+)" one can select one of the following options with the help of radio button$/) do |arg1, table|
  within('.field', text: _(arg1)) do
    table.rows.flatten.each do |option|
      find('label', text: option).find("input[type='radio']")
    end
  end
end

Then(/^for "(.*?)" one can select a date$/) do |arg1|
  i = find('.field', text: _(arg1)).find('input')
  i.click
  find('.ui-state-default', match: :first).click
  expect(i.value).not_to be_nil
end

Then(/^for maintenance contract the available options are in the following order:$/) do |table|
  expect(find('.field', text: _('Maintenance contract')).all('option').map(&:text)).to eq table.raw.flatten
end

Then(/^for "(.*?)" one can enter a number$/) do |arg1|
  within('.field', text: _(arg1)) do
    i = find "input[type='text']"
    i.set (n = rand(500).to_s)
    expect(i.value).to eq n
  end
end

Then(/^for "(.*?)" one can enter some text$/) do |arg1|
  within('.field', text: _(arg1)) do
    i = find "input[type='text'],textarea"
    i.set (t = Faker::Lorem.words(rand 3).join(' '))
    expect(i.value).to eq t
  end
end

Then(/^for "(.*?)" one can select a supplier$/) do |arg1|
  i = find('.field', text: _(arg1)).find 'input'
  i.click
  supplier = Supplier.order('RAND()').first
  find('.ui-menu-item', text: supplier.name).click
  expect(i.value).to eq supplier.name
end

Then(/^for "(.*?)" one can select an inventory pool$/) do |arg1|
  i = find('.field', text: _(arg1)).find 'input'
  i.click
  ip = InventoryPool.order('RAND()').first
  find('.ui-menu-item', text: ip.name).click
  expect(i.value).to eq ip.name
end

When(/^I choose a date for license expiration$/) do
  @license_expiration_date = rand(12).months.from_now.to_date
  find('.field', text: _('License expiration')).find('input').set I18n.l @license_expiration_date
end

When(/^I choose "(.*?)" for maintenance contract$/) do |arg1|
  o = find('.field', text: _('Maintenance contract')).find('option', text: _(arg1))
  o.select_option
  @maintenance_contract = o.value
end

Then(/^I am not able to choose the maintenance expiration date$/) do
  expect(has_no_selector?('.field', text: _('Maintenance expiration'))).to be true
end

When(/^I choose a date for the maintenance expiration$/) do
  @maintenance_expiration_date = rand(12).months.from_now.to_date
  find('.field', text: _('Maintenance expiration')).find('input').set I18n.l @maintenance_expiration_date
end

When(/^I choose "(.*?)" as reference$/) do |arg1|
  i = find('.field', text: _('Reference')).find('label', text: _(arg1)).find('input')
  i.click
  @reference = i.value
end

Then(/^I have to enter a project number$/) do
  step 'I save'
  step 'I see an error message'
  @project_number = Faker::Lorem.characters(10)
  find('.field', text: _('Project Number')).find('input').set @project_number
end

When(/^I change the license expiration date$/) do
  @new_license_expiration_date = rand(12).months.from_now.to_date
  find('.field', text: _('License expiration')).find('input').set I18n.l @new_license_expiration_date
end

When(/^I change the value for maintenance contract$/) do
  within('.field', text: _('Maintenance contract')) do
    o = all('option').detect &:selected?
    find("option[value='#{@new_maintenance_contract = !(o.value == "true")}']").select_option
  end

  if @new_maintenance_contract
    @new_maintenance_expiration_date = rand(12).months.from_now.to_date
    find('.field', text: _('Maintenance expiration')).find('input').set I18n.l @new_maintenance_expiration_date
  end
end

When(/^I change the value for reference$/) do
  within('.field', text: _('Reference')) do
    radio_buttons = all('input')
    values = radio_buttons.map(&:value)
    current_value = radio_buttons.detect(&:selected?).value
    @new_reference = values.detect {|v| v != current_value}
    find("input[value='#{@new_reference}']").click
  end

  if @new_reference == 'investment'
    @new_project_number = Faker::Lorem.characters(10)
    find('.field', text: _('Project Number')).find('input').set @new_project_number
  end
end

Given(/^there is a (.*) with the following properties:$/) do |arg1, table|
  case arg1
    when 'model', 'software product'
      model_attrs = {}
      @model_properties = table.raw.map do |k, v|
        case k
          when 'Name', 'Product'
            model_attrs[:product] = v
          when 'Manufacturer'
            model_attrs[:manufacturer] = v
          else
            raise
        end
        v
      end

      @model = case arg1
                 when 'model'
                   FactoryGirl.create :model, model_attrs
                 when 'software product'
                   FactoryGirl.create :software, model_attrs
               end

    when 'item', 'software license'
      item_attrs = {owner: @current_inventory_pool}
      item_properties = table.raw.map do |k, v|
        case k
          when 'Inventory code'
            item_attrs[:inventory_code] = v
          when 'Serial number'
            item_attrs[:serial_number] = v
          when 'Dongle ID'
            item_attrs[:properties] ||= {}
            item_attrs[:properties][:activation_type] = 'dongle'
            item_attrs[:properties][:dongle_id] = v
          when 'Quantity allocations'
            x,y = v.split(' / ')
            item_attrs[:properties][:quantity_allocations] ||= []
            item_attrs[:properties][:quantity_allocations] << [x, y]
            y
          when 'Owner', 'Responsible inventory pool'
            ip_key = case k
                       when 'Owner'
                         :owner
                       when 'Responsible inventory pool'
                         :inventory_pool
                     end
            item_attrs[ip_key] = case v
                                   when 'Current inventory pool'
                                     @current_inventory_pool
                                   when 'Another inventory pool'
                                     @other_inventory_pool ||= InventoryPool.where.not(id: @current_inventory_pool).order('RAND()').first
                                 end
          else
            puts "Don't know how to handle the field named #{k}"
            raise
        end
      end

      @item_properties = @model_properties + item_properties

      case arg1
        when 'item'
          @item = FactoryGirl.create :item, item_attrs.merge({model: @model})
        when 'software license'
          @item = FactoryGirl.create :license, item_attrs.merge({model: @model})
      end

    else
      raise
  end

end

When(/^I search (in the inventory section )?for one of those (.*)?properties$/) do |arg1, arg2|
  search_field = if arg1
                   find('#inventory-index-view input#list-search')
                 else
                   find('#topbar-search input#search_term')
                 end
  s = case arg2
        when 'software product '
          @model_properties.sample
        when 'software license ', ''
          @item_properties.sample
      end
  search_field.set s
  search_field.native.send_key :return
end

When(/^I search for the following properties( in the inventory section)?:$/) do |arg1, table|
  search_field = if arg1
                   find('#inventory-index-view input#list-search')
                 else
                   find('#topbar-search input#search_term')
                 end
  s = table.raw.flatten.sample
  search_field.set s
  search_field.native.send_key :return
end

# alias step
Then(/^all contracts containing this software product appear$/) do
  step 'all matching contracts, in which this software product is contained appear'
end

Then(/^all matching (.*) appear$/) do |arg1|
  if page.has_selector? '#search-overview'
    expect(has_no_selector? '#loading').to be true
    x,y = case arg1
            when 'models'
              ['#models', @model]
            when 'items'
              ['#items', @item]
            when 'software products'
              ['#software', @model]
            when 'software licenses'
              ['#licenses', @item]
            when 'contracts, in which this software product is contained'
              ['#contracts', @contract_with_software_license]
            when 'orders'
              ['#orders', @contract]
            when 'contracts'
              ['#contracts', @contract]
          end
    begin
      within '#search-overview' do
        within x do
          find(".line[data-id='#{y.id}']")
        end
      end
    # if not found in the overview, try in the subsection
    rescue
      if x == '#orders'
        find("[data-type='show-all']").click
        find(".line[data-id='#{y.id}']")
        find("#orders-search-results nav li a", match: :first).click
      end
    end
  elsif page.has_selector? '#inventory'
    within '#inventory' do
      case arg1
        when 'models'
          find(".line[data-id='#{@model.id}'][data-type='model']")
        when 'items'
          if @item.parent_id
            find(".group-of-lines .line[data-id='#{@item.parent_id}'][data-type='item'] button[data-type='inventory-expander']").click
            find(".group-of-lines .group-of-lines .line[data-id='#{@item.id}'][data-type='item']")
          else
            find(".line[data-id='#{@item.model_id}'][data-type='model'] button[data-type='inventory-expander']").click
            find(".group-of-lines .line[data-id='#{@item.id}'][data-type='item']")
          end
        when 'package models'
          find(".line[data-id='#{@package_item.model.id}'][data-type='model'][data-is_package='true']")
        when 'package items'
          find(".line[data-id='#{@package_item.model_id}'][data-type='model'][data-is_package='true'] button[data-type='inventory-expander']").click
          find(".group-of-lines .line[data-id='#{@package_item.id}'][data-type='item']")
      end
    end
  else
    raise
  end
end

Given(/^a software product exists$/) do
  @model = FactoryGirl.create :software
end

Given(/^a software license exists$/) do
  step 'a software product exists'
  step 'there exist licenses for this software product'
end

Given(/^this software license is handed over to somebody$/) do
  line = FactoryGirl.create :item_line, inventory_pool: @current_inventory_pool, status: :approved, model: @model, item: @item
  @contract_with_software_license = line.user.reservations_bundles.approved.find_by(inventory_pool_id: @current_inventory_pool)
  expect(@contract_with_software_license.reservations.reload.empty?).to be false
  contract = @contract_with_software_license.sign(@current_user, [line])
  expect(contract).to be_valid
  @contract_with_software_license = line.user.reservations_bundles.signed.find(contract.id)
end

When(/^I search after the name of that person$/) do
  search_field = find('#topbar-search input#search_term')
  search_field.set @contract_with_software_license.user.name
  search_field.native.send_key :return
end

Then(/^the contract of this person appears in the search results$/) do
  step 'all contracts containing this software product appear'
end

Then(/^this person appears in the search results$/) do
  within '#users' do
    find(".line [data-id='#{@contract_with_software_license.user_id}']")
  end
end

Given(/^there exist licenses for this software product$/) do
  rand(1..3).times do
    @model.items << FactoryGirl.create(:license, {owner: @current_inventory_pool, model: @model})
  end
  @item = @model.items.order('RAND()').first
end

When(/^I see these in my search result$/) do
  search_field = find('#topbar-search input#search_term')
  search_field.set @model.name
  search_field.native.send_key :return
end

Then(/^I can select to list only software products$/) do
  find('nav a.navigation-tab-item', text: _('Software')).click
  within('#software-search-results') do
    find(".line[data-id='#{@model.id}']")
  end
end

Then(/^I can select to list only software licenses$/) do
  find('nav a.navigation-tab-item', text: _('Licenses')).click
  within('#licenses-search-results') do
    find(".line[data-id='#{@item.id}']")
  end
end

When(/^I delete this software product from the list$/) do
  find('a', text: _('Software')).click
  within('#inventory') do
    within(".line[data-id='#{@model.id}']") do
      within('.multibutton') do
        find('.dropdown-toggle').click
        find('.red', text: _('Delete')).click
      end
    end
  end
  find('#flash .success', text: _('%s successfully deleted') % _('Model'))
end

Then(/^the software product is deleted from the list$/) do
  find('a', text: _('Software')).click
  within('#inventory') do
    expect(has_no_selector?(".line[data-id='#{@model.id}']")).to be true
  end
end

Then(/^the software product is deleted$/) do
  expect { @model.reload }.to raise_error(ActiveRecord::RecordNotFound)
end

When(/^I fill in all the required fields for the license$/) do
  step 'I fill in the software'
  @inventory_code_value = @inv_code = find('.field', text: _('Inventory Code')).find('input').value
end

When(/^I fill in the software$/) do
  @software = Software.order('RAND()').first
  fill_in_autocomplete_field _('Software'), @software.name
end

When(/^I fill in the field "(.*?)" with the value "(.*?)"$/) do |field, value|
  find('.field', text: _(field)).find('input').set value
end

Then(/^"(.*?)" is saved as "(.*?)"$/) do |field, format|
  sleep 1
  item = Item.find_by_inventory_code(@inv_code)
  visit manage_edit_item_path(@current_inventory_pool, item)
  expect(find('.field', text: _(field)).find('input').value).to eq format
end

When(/^I edit a license with set dates for maintenance expiration, license expiration and invoice date$/) do
  @license = @current_inventory_pool.items.licenses.find {|i| i.invoice_date and
                                                              i.properties[:maintenance_contract] == 'true' and
                                                              i.properties[:maintenance_expiration] and
                                                              i.properties[:license_expiration] }
  expect(@license).not_to be_nil
  visit manage_edit_item_path(@current_inventory_pool, @license)
end

When(/^I delete the data for the following fields:$/) do |table|
  table.raw.flatten.each {|field| find('.field', text: _(field)).find('input').set ''}
end

Then(/^the following fields of the license are empty:$/) do |table|
  table.raw.flatten.each do |field|
    expect(find('.field', text: _(field)).find('input').value.empty?).to be true
  end
end

When(/^I edit the same license$/) do
  visit manage_edit_item_path(@current_inventory_pool, @license)
end

When(/^I edit again this software product$/) do
  string = @table_hashes.select {|x| ['Product', 'Version', 'Manufacturer'].include? x['Field']}.map {|x| x['Value']}.join(' ')
  results = Software.search(string)
  expect(results.size).to eq 1
  @software = results.first
  step 'I edit software'
end

#Then(/^outside the the text field, they will additionally displayed reservations with link only$/) do
Then(/^outside the the text field, all the URLs extracted from the software information field are displayed as links$/) do
  within '#form .field', text: _('Software Information') do
    find('.list-of-lines').all('.line').each do |line|
      line.find("a[target='_blank']")
    end
  end
end

#Given(/^ich add a new (?:.+) or I change an existing (.+)$/) do |entity|
Given(/^I add a new or I change an existing (.+)$/) do |entity|
  klass = case _(entity)
          when 'model' then Model
          when 'software' then Software
          end
  @model = klass.all.first
  visit manage_edit_model_path(@current_inventory_pool, @model)
end

Then(/^I see the "Software Information"$/) do
  f = find('.field', text: _('Software Information'))
  i = f.find('textarea')
  expect(i.value).to eq @license.model.technical_detail.delete("\r")
  expect(f.has_selector? 'a').to be true
end

When(/^I edit a software license with software information, quantity allocations and attachments$/) do
  @license = @current_inventory_pool.items.licenses.find {|i| i.model.technical_detail =~ /http/ and not i.model.attachments.empty? and i.properties[:quantity_allocations].size >= 2 }
  expect(@license).not_to be_nil
  visit manage_edit_item_path(@current_inventory_pool, @license)
end

Then(/^the software information is not editable$/) do
  f = find('.field', text: _('Software Information'))
  expect(f.find('textarea').disabled?).to be true
end

Then(/^the links of software information open in a new tab upon clicking$/) do
  f = find('.field', text: _('Software Information'))
  f.all('a').each do |link|
    expect(link.native.attribute('target')).to eq '_blank'
  end
end

Then(/^I see the attachments of the software$/) do
  within all('.field', text: _('Attachments')).last do
    expect(@license.model.attachments.all?{|a| has_selector?('a', text: a.filename)}).to be true
  end
end

Then(/^I can open the attachments in a new tab$/) do
  f = all('.field', text: _('Attachments')).last
  f.all('a').each do |link|
    expect(link.native.attribute('target')).to eq '_blank'
  end
end

When(/^there exists already a manufacturer$/) do
  @manufacturer = Software.manufacturers.sample
end

Then(/^the manufacturer can be selected from the list$/) do
  input_field = find('.field', text: _('Manufacturer')).find('input')
  input_field.click
  find('.ui-menu-item', text: @manufacturer).click
  expect(input_field.value).to eq @manufacturer
end

When(/^I set a non existing manufacturer$/) do
  input_field = find('.field', text: _('Manufacturer')).find('input')
  @manufacturer = Faker::Company.name
  while Software.manufacturers.include?(@manufacturer) do
    @manufacturer = Faker::Company.name
  end
  input_field.set @manufacturer
end

Then(/^the new manufacturer can be found in the manufacturer list$/) do
  input_field = find('.field', text: _('Manufacturer')).find('input')
  input_field.click
  find('.ui-menu-item', text: @manufacturer).click
end

Then(/^I choose dongle as activation type$/) do
  within('.field', text: _('Activation Type')) do
    find("option[value='dongle']").click
  end
end

Then(/^I have to provide a dongle id$/) do
  step 'I save'
  step 'I see an error message'
  @dongle_id = Faker::Lorem.characters(10)
  find('.field', text: _('Dongle ID')).find('input').set @dongle_id
end

When(/^I choose one of the following license types$/) do |table|
  find('.field', text: _('License Type')).find('option', text: _(table.rows.flatten.sample)).select_option
end

When(/^I fill in a value$/) do
  find('.field', text: _('Quantity')).find('input').set (@total_quantity = rand(5..500))
end

Given(/^a software product with more than (\d+) text rows in field "(.*?)" exists$/) do |arg1, arg2|
  @model = case arg2
             when 'Software Informationen'
               r = @current_inventory_pool.models.where(type: 'Software').detect {|m| m.technical_detail.to_s.split("\r\n").size > arg1.to_i}
               r ||= begin
                 td = []
                 (arg1.to_i + rand(1..10)).times { td << Faker::Lorem.paragraph }
                 m = @current_inventory_pool.models.order('RAND()').first
                 m.update_attributes(technical_detail: td.join("\r\n"))
                 m
               end
             else
               raise
           end
end

When(/^I edit this software$/) do
  visit manage_edit_model_path(@current_inventory_pool, @model)
end

When(/^I click in the field "(.*?)"$/) do |arg1|
  case arg1
    when 'Software Informationen'
      el = find("textarea[name='model[technical_detail]']")
      @original_size = el.native.css_value('height')
      el.click
    else
      raise
  end
end

When(/^this field grows up till showing the complete text$/) do
  expect(find("textarea[name='model[technical_detail]']").native.css_value('height').to_i).to be > @original_size.to_i
end

When(/^I release the focus from this field$/) do
  find('body').click # blur all possible focused autocomplete inputs
end

Then(/^this field shrinks back to the original size$/) do
  expect(find("textarea[name='model[technical_detail]']").native.css_value('height').to_i).to eq @original_size.to_i
end

When(/^I change the value of the note$/) do
  find('.field', text: _('Note')).find('textarea').set (@note = Faker::Lorem.sentence)
end

When(/^I change the value of dongle id$/) do
  dongle_field = first('.field', text: _('Dongle ID'))
  unless dongle_field
    step %Q(I choose dongle as activation type)
    dongle_field = first('.field', text: _('Dongle ID'))
  end
  dongle_field.find('input').set (@dongle_id = Faker::Lorem.characters(8))
end

When(/^I change the value of total quantity$/) do
  find('.field', text: _('Total quantity')).find('input').set (@new_total_quantity = rand(10..100))
end

When(/^I change the quantity allocations$/) do
  @new_quantity_allocations = @license.properties[:quantity_allocations]
  within find('.field', text: _('Quantity allocations')) do
    first('[data-remove]').click
    @new_quantity_allocations.shift
    all('[data-quantity-allocation]').last.set (q = rand(1..50))
    @new_quantity_allocations.last[:quantity] = q
    first('#add-inline-entry').click
    new_inline_entry = first('.list-of-lines .row')
    new_inline_entry.first('[data-quantity-allocation]').set (q = rand(1..50))
    new_inline_entry.first('[data-room-allocation]').set (r = Faker::Lorem.word)
    @new_quantity_allocations.unshift({room: r, quantity: q})
  end
end

When(/^I fill in the value of total quantity$/) do
  find('.field', text: _('Total quantity')).find('input').set (@total_quantity = rand(10..100))
end

When(/^I add the quantity allocations$/) do
  @quantity_allocations = []
  within find('.field', text: _('Quantity allocations')) do
    rand(2..5).times do
      first('#add-inline-entry').click
      new_inline_entry = first('.list-of-lines .row')
      new_inline_entry.first('[data-quantity-allocation]').set (q = rand(1..50))
      new_inline_entry.first('[data-room-allocation]').set (r = Faker::Lorem.word)
      @quantity_allocations.unshift({room: r, quantity: q})
    end
  end
end

When(/^I fill in total quantity with value "(.*?)"$/) do |arg1|
  find('.field', text: _('Total quantity')).find('input').set (@total_quantity = arg1.to_i)
end

Then(/^I see the remaining number of licenses shown as follows "(.*?)"$/) do |arg1|
  within find('.field', text: _('Quantity allocations')) do
    find('#remaining-total-quantity', text: arg1)
  end
end

Then(/^I add the following quantity allocations:$/) do |table|
  within find('.field', text: _('Quantity allocations')) do
    table.rows.each do |row|
      first('#add-inline-entry').click
      new_inline_entry = first('.list-of-lines .row')
      new_inline_entry.first('[data-quantity-allocation]').set row.first
      new_inline_entry.first('[data-room-allocation]').set row.second
    end
  end
end

When(/^I delete the following quantity allocations:$/) do |table|
  within find('.field', text: _('Quantity allocations')) do
    inline_entries = all("[data-type='inline-entry']")
    table.rows.each do |row|
      inline_entry = inline_entries.detect {|ie| ie.find('[data-room-allocation]').value == row.second}
      inline_entry.find('[data-remove]').click
    end
  end
end

When(/^I copy an existing software license$/) do
  step "I'am on the software inventory overview"
  within('#inventory') do
    find(".line[data-id='#{@item.model_id}'][data-type='software'] button[data-type='inventory-expander']").click
    within(".group-of-lines .line[data-id='#{@item.id}'][data-type='license']") do
      within('.multibutton') do
        find('.dropdown-toggle').click
        find('.dropdown-item', text: _('Copy License')).click
      end
    end
  end
end

Then(/^it opens the edit view of the new software license$/) do
  expect(manage_copy_item_path(@current_inventory_pool, @item)).to eq current_path
end

Then(/^the (.*) is labeled as "(.*?)"$/) do |arg1, arg2|
  case arg1
    when 'title'
      find('h1.headline-l', text: arg2)
    when 'save button'
      find('button.green', text: arg2)
    else
      raise
  end
end

Then(/^the new software license is created$/) do
  sleep 1
  @target_item = @current_inventory_pool.items.find_by_inventory_code(@target_inventory_code)
  expect(@target_item).not_to be_nil
end

Then(/^the following fields were copied from the original software license$/) do |table|
  table.rows.flatten.each do |field|
    case field
      when 'Software'
        expect(@target_item.model_id).to eq @item.model_id
      when 'Reference'
        expect(@target_item.properties[:reference]).to eq @item.properties[:reference]
      when 'Owner'
        expect(@target_item.owner_id).to eq @item.owner_id
      when 'Responsible department'
        expect(@target_item.inventory_pool_id).to eq @item.inventory_pool_id
      when 'Invoice Date'
        expect(@target_item.invoice_date).to eq @item.invoice_date
      when 'Initial Price'
        expect(@target_item.price).to eq @item.price
      when 'Supplier'
        expect(@target_item.supplier_id).to eq @item.supplier_id
      when 'Procured by'
        expect(@target_item.properties[:procured_by]).to eq @item.properties[:procured_by]
      when 'Note'
        expect(@target_item.note).to eq @item.note
      when 'Activation type'
        expect(@target_item.properties[:activation_type]).to eq @item.properties[:activation_type]
      when 'License Type'
        expect(@target_item.properties[:license_type]).to eq @item.properties[:license_type]
      when 'Total quantity'
        expect(@target_item.properties[:quantity]).to eq @item.properties[:quantity]
      when 'Operating System'
        expect(@target_item.properties[:operating_system]).to eq @item.properties[:operating_system]
      when 'Installation'
        expect(@target_item.properties[:installation]).to eq @item.properties[:installation]
      when 'License expiration'
        expect(@target_item.properties[:license_expiration]).to eq @item.properties[:license_expiration]
      when 'Maintenance contract'
        expect(@target_item.properties[:maintenance_contract]).to eq @item.properties[:maintenance_contract]
      when 'Maintenance expiration'
        expect(@target_item.properties[:maintenance_expiration]).to eq @item.properties[:maintenance_expiration]
      when 'Currency'
        expect(@target_item.properties[:maintenance_currency]).to eq @item.properties[:maintenance_currency]
      when 'Price'
        expect(@target_item.properties[:maintenance_price]).to eq @item.properties[:maintenance_price]
      else
        raise
    end

  end
end

When(/^I search for one of these (.*)?properties( in the inventory section)?$/) do |arg1, arg2|
  if arg2
    s1 = 'in the inventory section '
  else
    s1 = ''
  end
  s2 = case arg1
         when 'software product '
           'software product '
         when 'software license '
           'software license '
         else
           ''
       end
  step "I search #{s1}for one of those #{s2}properties"
end

Given(/^exists a license that belongs to the current inventory pool but is not owned by it$/) do
  @license = Item.licenses.where(inventory_pool: @current_inventory_pool).where.not(owner: @current_inventory_pool).first
  expect(@license).to be
end

Given(/^the license has (\d+) attachment$/) do |count|
  @attachment_filenames = []
  count.to_i.times do
    a = FactoryGirl.create :attachment, item: @license
    @attachment_filenames << a.filename
  end
end

When(/^I edit the license$/) do
  visit manage_edit_item_path @current_inventory_pool, @license
end
