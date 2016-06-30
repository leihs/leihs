require_relative 'shared/common_steps'
require_relative 'shared/dataset_steps'
require_relative 'shared/navigation_steps'
require_relative 'shared/personas_steps'

steps_for :templates do
  include CommonSteps
  include DatasetSteps
  include NavigationSteps
  include PersonasSteps

  step "a sub category which I'm inspector exists" do
    @category = Procurement::Category.all.detect do |category|
      category.inspectable_by?(@current_user)
    end
    expect(@category).to be
  end

  step 'all categories and all articles are listed again' do
    step 'I see all main categories of the sub categories I am assigned to'
    step 'I see all sub categories I am assigned to'
  end

  step 'all main categories where the name of ' \
       'the main category matches the search string are shown' do
    find '.panel-info', text: @search_string
  end

  step 'all sub categories are expanded where the name ' \
       'of the sub category matches the search string' do
    all('.panel-info', minimum: 1).each do |el|
      if el.has_selector? \
        '.panel-heading[data-searchable*="' + @search_string.downcase + '"]'
        expect(el).to have_selector '.collapse.in'
      end
    end
  end

  step 'all sub categories are expanded which contain ' \
       'article names matching the search string' do
    all('.panel-info', minimum: 1).each do |el|
      if el.has_selector? \
        'td[data-searchable*="' + @search_string.downcase + '"]'
        expect(el).to have_selector '.collapse.in'
      end
    end
  end

  step 'I add a new template' do
    main_category = @main_categories.first
    @category = main_category.categories.first
    within '.panel-info', text: main_category.name do
      within '.panel-default', text: @category.name do
        find('i.fa-plus-circle').click
      end
    end
  end

  step 'I delete one of the template articles' do
    @template = @category.templates.first

    within '.panel-info', text: @category.main_category.name do
      current_scope.click

      within '.panel-default', text: @category.name do
        within(:xpath,
               "//input[@value='#{@template.article_name}']/ancestor::tr") do
          find('i.fa-minus-circle').click
        end
      end
    end
  end

  step 'I delete the search string' do
    within '#filter_panel' do
      find("input[name='search']").set ''
    end
  end

  # step 'I delete the category' do
  #   within(:xpath, "//input[@value='#{@category.name}']/ancestor::" \
  #                  "div[contains(@class, 'panel-heading')]") do
  #     find('i.fa-minus-circle').click
  #   end
  # end

  # step 'I edit the category' do
  #   find("input[value='#{@category.name}']").click
  # end

  step 'I enter the category name' do
    @name = Faker::Lorem.sentence
    within @el do
      fill_in _('Category'), with: @name
    end
  end

  step 'I expand the main categories' do
    @main_categories.each do |main_category|
      find('.panel-info .panel-heading.collapsed h4',
           text: main_category.name).click
    end
  end

  # NOTE override
  step 'I fill in the following fields' do |table|
    @changes ||= {}
    table.raw.flatten.each do |name|
      case name
      when 'Article or Project'
        v = Faker::Lorem.sentence
        find("input[name*='[article_name]']").set v
      when 'Article nr. or Producer nr.'
        v = Faker::Lorem.sentence
        find("input[name*='[article_number]']").set v
      when 'Price'
        v = Faker::Number.number(4).to_i
        find("input[name*='[price]']").set v
      when 'Supplier'
        v = Faker::Lorem.sentence
        find("input[name*='[supplier_name]']").set v
      else
        raise
      end
      @changes[mapped_key(name)] = v

      # NOTE trigger change event
      find('body').native.send_keys(:tab) # find('body').click
    end
  end

  # step 'I modify the category name' do
  #   @el = find(:xpath, "//input[@value='#{@category.name}']/ancestor::" \
  #                      "div[contains(@class, 'panel-heading')]")
  #   step 'I enter the category name'
  # end

  step 'I see all main categories of the sub categories I am assigned to' do
    categories = Procurement::Category.all.select do |category|
      category.inspectable_by?(@current_user)
    end
    @main_categories = categories.map(&:main_category).uniq
    @main_categories.each do |main_category|
      find '.panel-info .panel-heading h4', text: main_category.name
    end
  end

  step 'I see all sub categories I am assigned to' do
    @main_categories.each do |main_category|
      within '.panel-info', text: main_category.name do
        current_scope.click

        categories = main_category.categories.select do |category|
          category.inspectable_by?(@current_user)
        end

        categories.each do |category|
          find '.panel-default .panel-heading', text: category.name
        end
      end
    end
  end

  step 'I type a search string into the search field' do
    categories = Procurement::Category.all.select do |category|
      category.inspectable_by?(@current_user)
    end
    @search_string = categories.map(&:main_category).uniq.sample.name

    within '#filter_panel' do
      find("input[name='search']").set @search_string
    end
  end

  step 'the template is already used in many requests' do
    3.times do
      FactoryGirl.create :procurement_request,
                         template: @template
    end
    expect(@template.requests).to be_exists
  end

  # step 'the article of the category is marked red' do
  #   within '.panel-info', text: @template.category.main_category.name do
  #     find ".bg-danger input[name*='[article_name]']" \
  #          "[value='#{@template.article_name}']"
  #   end
  # end

  step 'the articles inside a sub category are sorted 0-10 and a-z' do
    all('.panel-default', minimum: 1).each do |panel|
      within panel do
        texts = all("tbody tr input[name*='[article_name]']", minimum: 1) \
                  .map &:value
        texts.delete('')
        expect(texts).to eq texts.sort
      end
    end
  end

  step 'the categories are sorted 0-10 and a-z' do
    all('.panel-info', minimum: 1).each do |el|
      el.click
      within el do
        texts = all('.panel-default .panel-heading b', minimum: 1).map &:value
        texts.delete('')
        expect(texts).to eq texts.sort
      end
    end
  end

  step 'the article is deleted from the database' do
    expect { @template.reload }.to raise_error ActiveRecord::RecordNotFound
  end

  step 'the category is saved to the database' do
    category = Procurement::TemplateCategory.find_by_name(@name)
    expect(category).to be
    expect(category.name).to eq @name
  end

  step 'the data entered is saved to the database' do
    if price = @changes.delete(:price)
      @changes[:price_cents] = price * 100
    end
    expect(@category.reload.templates.find_by(@changes)).to be
  end

  step 'the data modified is saved to the database' do
    @template.reload
    @changes.each_pair do |k, v|
      stored_value = @template.send k
      stored_value = stored_value.to_i if k == :price
      expect(stored_value).to eq v
    end
  end

  step 'the data is deleted from the database' do
    @template.reload

    expect(@template.article_name).not_to be_empty

    expect(@template.article_number).to be_nil
    expect(@template.price).to be_zero
    expect(@template.supplier).to be_nil
  end

  step 'the deleted category is deleted from the database' do
    expect { @category.reload }.to raise_error ActiveRecord::RecordNotFound
  end

  step 'the following fields are filled' do |table|
    within '.panel-info', text: @template.category.main_category.name do
      current_scope.click

      el = if @template
             find(:xpath,
                  "//input[@value='#{@template.article_name}']/ancestor::tr")
           else
             all('tbody tr', minimum: 1).last
           end
      within el do
        @changes = {}
        table.raw.flatten.each do |value|
          case value
          when 'Price'
              find("input[name*='[price]']").set @changes[mapped_key(value)] = 123
          else
              fill_in(_(value),
                      with: @changes[mapped_key(value)] = Faker::Lorem.sentence)
          end
        end
      end
    end
  end
  # alias
  step 'the following fields are modified' do |table|
    step 'the following fields are filled', table
  end

  step 'the main categories are collapsed' do
    @main_categories.each do |main_category|
      find '.panel-info .panel-heading.collapsed h4', text: main_category.name
    end
  end

  step 'the requests references are not nullified' do
    expect(@template.reload.requests).not_to be_empty
  end

  step 'the category has one template article' do
    @template = FactoryGirl.create(:procurement_template, category: @category)
    expect(@category.reload.templates.count).to eq 1
  end

  step 'the sub category contains template articles' do
    3.times do
      FactoryGirl.create :procurement_template, category: @category
    end
  end

  # step 'the category is marked red' do
  #   find ".panel-danger .panel-heading input[value='#{@category.name}']"
  # end

  step 'there is an empty category line for creating a new category' do
    @el = all('.panel-default', minimum: 1).last
    within @el do
      expect(find("input[name*='[name]']").value).to be_empty
    end
  end

  step 'this article is marked red' do
    within(:xpath, "//input[@value='#{@template.article_name}']/ancestor::tr") do
      color = current_scope.native.css_value('background-color')
      expect(color).to eq 'rgba(242, 222, 222, 1)'
    end
  end

end
