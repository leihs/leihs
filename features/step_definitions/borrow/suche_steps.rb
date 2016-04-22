# -*- encoding : utf-8 -*-

Then(/^I can see the search box$/) do
  visit borrow_root_path
  expect(has_selector?('.topbar .topbar-search')).to be true
end

Then(/^I see image, name and manufacturer of the first 6 matching models$/) do
  within '#search-autocomplete' do
    within '.ui-autocomplete' do
      matches = all('.ui-autocomplete a', minimum: 1)
      expect(matches.length).to be >= 6
      matches[0,6].each do |match|
        within match do
          text = find('strong', text: @search_term).text
          model = @current_user.models.borrowable.find {|m| [m.name, m.product].include? text }
          find('div > div:nth-child(2)', text: model.manufacturer)
          find("div > img[src='/models/#{model.id}/image_thumb']")
        end
      end
    end
  end
end

Then(/^I see a link labeled 'Show all search results'$/) do
  expect(has_selector?('.ui-autocomplete a', text: _('Show all search results'))).to be true
end

Given(/^I pick a model from the ones suggested$/) do
  #step 'man einen Suchbegriff eingibt'
  step 'I enter a search term'
  @model = @current_user.models.find {|m| [m.name, m.product].include? find('.ui-autocomplete a strong', match: :first).text }
  find('.ui-autocomplete a', match: :first, text: @model.name).click
end

Then(/^I see the model's detail page$/) do
  expect(current_path).to eq borrow_model_path(@model)
end

Given(/^I enter a search term$/) do
  @model ||= @current_user.models.borrowable.detect {|m| @current_user.models.borrowable.where("models.product LIKE '%#{m.name[0..3]}%'").length >= 6}
  @search_term = @model.name[0..3]
  fill_in 'search_term', with: @search_term
end

When(/^I search for models giving at least two space separated terms$/) do
  @models = @current_user.models.borrowable.where.not(product: nil).where.not(version: nil)
  @search_term = @models.order('RAND()').first.name
  expect(@search_term.split(' ').size).to be >= 2
  fill_in 'search_term', with: @search_term
end

Given(/^I press the Enter key$/) do
  find("#search input[name='search_term']").native.send_keys(:return)
end

Then(/^the search result page is shown$/) do
  find("nav .navigation-tab-item.active span[title=\"%s\"]" % _("Search for '%s'") % @search_term)
  expect(current_path).to eq borrow_search_results_path
end

Then(/^I see image, name and manufacturer of all matching models$/) do
  @models = @current_user.models.borrowable.search(@search_term, [:manufacturer, :product, :version]).default_order.paginate(page: 1, per_page: 20)
  @models.each do |model|
    within "#model-list .line[data-id='#{model.id}']" do
      find('div .col1of6', text: model.manufacturer, match: :prefer_exact)
      find('div .col3of6', text: model.name, match: :prefer_exact)
      find("div .col1of6 img[src='/models/#{model.id}/image_thumb']")
    end
  end
end

Then(/^the suggestions have disappeared$/) do
  expect(has_no_selector?('.ui-autocomplete')).to be true
end

When(/^I search for a model that I can't borrow$/) do
  @model = (@current_user.models.order('RAND()') - @current_user.models.borrowable).first
end

Then(/^that model is not shown in the search results$/) do
  #step 'man einen Suchbegriff eingibt'
  step 'I enter a search term'
  expect(has_no_content?(@model.name)).to be true
  #step 'drückt ENTER'
  step 'I press the Enter key'
  expect(has_no_content?(@model.name)).to be true
end
