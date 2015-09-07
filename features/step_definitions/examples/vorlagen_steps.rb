# -*- encoding : utf-8 -*-

When(/^I click on "Templates" in the inventory area$/) do
  @current_inventory_pool = @current_user.inventory_pools.managed.select {|ip| ip.templates.exists? }.sample
  step 'I open the inventory'
  click_link _('Templates')
end

Then(/^I see a list of currently available templates for the current inventory pool$/) do
  expect(has_content?(_('List of templates'))).to be true
  @current_inventory_pool.templates.each do |t|
    expect(has_content?(t.name)).to be true
  end
end

Then(/^the templates are ordered alphabetically by their names$/) do
  find('.line .col3of4 strong', match: :first)
  all_names = all('.line .col3of4 strong').map(&:text)
  expect(all_names.sort).to eq @current_inventory_pool.templates.sort.map(&:name)
  expect(all_names.count).to eq @current_inventory_pool.templates.count
end

Given(/^I am listing templates$/) do
  visit manage_templates_path(@current_inventory_pool)
end

When(/^I click the button "New Template"$/) do
  click_link _('New Template')
end

Then(/^I can create a new template$/) do
  expect(current_path).to eq manage_new_template_path(@current_inventory_pool)
end

When(/^I enter the template's name$/) do
  @new_name = Faker::Lorem.word
  find('.row.emboss.padding-inset-s', match: :prefer_exact, text: _('Name')).find('input').set @new_name
end

When(/^I add some models to the template$/) do
  @changed_model = @current_inventory_pool.models.find {|m| m.items.borrowable.size > 1}
  fill_in_autocomplete_field("#{_("Quantity")} / #{_("Models")}", @changed_model.name)
end

Then(/^each model shows the maximum number of available items$/) do
  within '#models' do
    line = find('.line div[data-model-name]', text: @changed_model.name).find(:xpath, './..')
    count = @changed_model.items.borrowable.where(inventory_pool_id: @current_inventory_pool).count
    line.find("input[name='template[model_links_attributes][][quantity]'][max='#{count}']")
  end
end

Then(/^each model I've added has the minimum quantity (\d+)$/) do |n|
  within '#models' do
    all('.line').each do |line|
      expect(line.find("input[name='template[model_links_attributes][][quantity]']").value).to eq n
    end
  end
end

Then(/^the minimum quantity for the newly added model is (\d+)$/) do |n|
  within '#models' do
    expect(find('.line', match: :first, text: @additional_model.name).find("input[name='template[model_links_attributes][][quantity]']").value).to eq n
  end
end

When(/^I enter a quantity for each model$/) do
  @new_value ||= 1
  within '#models' do
    all('.line').each do |line|
      line.find("input[name='template[model_links_attributes][][quantity]']").set @new_value
    end
  end
end

Then(/^the new template and all the entered information are saved$/) do
  @template = @current_inventory_pool.templates.find_by_name(@new_name)
  expect(@template.model_links.size).to eq 1
  expect(@template.model_links.first.model).to eq @changed_model
  expect(@template.model_links.first.quantity).to eq @new_value
end


Given(/^a template with at least two models exists$/) do
  @template = @current_inventory_pool.templates.find do |t|
    t.models.size >= 2 and t.models.any? {|m| m.borrowable_items.size >= 2}
  end
  expect(@template).not_to be_nil
  @template_models_count_original = @template.models.count
end

When(/^I click the button "Edit"$/) do
  find('.line', text: @template.name).click_link _('Edit')
end

Then(/^I am editing an existing template$/) do
  expect(current_path).to eq manage_edit_template_path(@current_inventory_pool, @template)
end

When(/^I change the name$/) do
  @new_name = Faker::Lorem.word
  find('.row.emboss.padding-inset-s', match: :prefer_exact, text: _('Name')).find('input').set @new_name
end

When(/^I add an additional model$/) do
  @additional_model = @current_inventory_pool.models.find do |m|
    m.items.borrowable.size > 1 and not @template.models.include? m
  end
  fill_in_autocomplete_field("#{_("Quantity")} / #{_("Models")}", @additional_model.name)
end

When(/^I delete a model from the list$/) do
  within '#models' do
    within all('.line').to_a.sample do
      @changed_model = Model.find_by_name(find('[data-model-name]').text)
      find('.button[data-remove]').click
    end
  end
end

When(/^I change the quantity for one of the models$/) do
  within '#models' do
    within all('.line:not(.striked)').to_a.sample do
      @changed_model = Model.find_by_name(find('[data-model-name]').text)
      @new_value = find('input').value.to_i + 1
      find('input').set @new_value
    end
  end
end

Then(/^the edited template and all the entered information are saved$/) do
  @template.reload
  expect(@template.models.map(&:name)).not_to include @removed_model.name if @removed_model
  expect(@template.models.map(&:name)).to include @additional_model.name if @additional_model
  expect(@template.model_links.find_by_model_id(@changed_model.id).quantity).to eq @new_value
  expect(@template.models.count).to eq @template_models_count_original if @template_models_count_original
end

Then(/^I can delete any template directly from this list$/) do
  @template = @current_inventory_pool.templates.order('RAND()').first
  within('.line', text: @template.name) do
    within('.multibutton') do
      find('.dropdown-toggle').click
      find(".red[data-method='delete']", text: _('Delete')).click
    end
  end
end

When(/^the template has at least one model$/) do
  fill_in_autocomplete_field("#{_("Quantity")} / #{_("Models")}", @current_inventory_pool.models.first.name)
end

Then(/^the template has been deleted from the database$/) do
  expect{@template.reload}.to raise_exception
end

Given(/^I am creating a template$/) do
  visit manage_new_template_path(@current_inventory_pool)
end

When(/^the name is not filled in$/) do
  within('.row.emboss.padding-inset-s', match: :prefer_exact, text: _('Name')) do
    find('input').set ''
    expect(find('input').value.empty?).to be true
  end
end

When(/^I fill in the name$/) do
  within('.row.emboss.padding-inset-s', match: :prefer_exact, text: _('Name')) do
    find('input').set Faker.name
  end
end

When(/^I have not added any models$/) do
  within '#models' do
    all('.line').each {|e| e.find('.button[data-remove]').click}
  end
end

Given(/^I am editing a template$/) do
  visit manage_edit_template_path(@current_inventory_pool, @current_inventory_pool.templates.first)
end

Given(/^I am creating a new template$/) do
  #step 'ich befinde mich auf der Liste der Vorlagen'
  #step 'ich auf den Button "Neue Vorlage" klicke'
  #step 'öffnet sich die Seite zur Erstellung einer neuen Vorlage'
  step 'I am listing templates'
  step 'I click the button "New Template"'
  step 'I can create a new template'
end

When(/^I enter a quantity for a model which exceeds its maximum number of borrowable items for this model$/) do
  l = find('#models .line', match: :prefer_exact, text: @changed_model.name)
  max = l.find('[data-quantities]:nth-child(2)').text.gsub(/\D/, '').to_i
  @new_value = max + 1
  l.find("input[name='template[model_links_attributes][][quantity]']").set @new_value
end

Then(/^the template is (not )?marked as unaccomplishable in the list$/) do |n|
  within('.line', text: @template.name) do
    if n
      expect(has_no_selector?('.line-info.red')).to be true
    else
      expect(has_selector?('.line-info.red')).to be true
    end
  end
end

When(/^I edit the same template$/) do
  find('.line', text: @template.name).click_link _('Edit')
end

When(/^I use correct quantities$/) do
  within('#models .line', match: :prefer_exact, text: @changed_model.name) do
    max = find('[data-quantities]:nth-child(2)').text.gsub(/\D/, '').to_i
    @new_value = max
    find("input[name='template[model_links_attributes][][quantity]']").set @new_value
  end
end

Then(/^I am warned that this template cannot never be ordered due to available quantities being too low$/) do
  find('.red', text: _('The highlighted entries are not accomplishable for the intended quantity.'))
end
