require_relative 'shared/common_steps'
require_relative 'shared/dataset_steps'
require_relative 'shared/filter_steps'
require_relative 'shared/navigation_steps'
require_relative 'shared/personas_steps'

steps_for :categories do
  include CommonSteps
  include DatasetSteps
  include FilterSteps
  include NavigationSteps
  include PersonasSteps

  step 'a main category with a picture exists' do
    path = "#{Rails.root}/features/data/images/image1.jpg"
    @main_category = FactoryGirl.create :procurement_main_category,
                                        image: File.open(path)
  end

  step 'a sub category exists' do
    @category = FactoryGirl.create(:procurement_category)
  end

  step 'I add a new main category' do
    find('form > .h3 > i.fa-plus-circle').click
  end
  step 'I click on the add button' do
    step 'I add a new main category'
  end

  step 'I add a new sub category' do
    within 'form .panel-info', match: :first do
      find('.collapsed').click if has_selector? '.collapsed'
      find('i.fa-plus-circle').click
    end
  end
  step 'I click on the add sub category button' do
    step 'I add a new sub category'
  end

  step 'I add a second sub category' do
    step 'I add a new sub category'
  end

  step 'there exist(s) :count user(s) to become the inspector(s)' do |count|
    @inspectors = []
    count.to_i.times do
      @inspectors << find_or_create_user(Faker::Name.first_name)
    end
  end

  step 'I delete the picture of the main category' do
    # to expand the panel
    el = find("input[name*='[name]'][value='#{@main_category.name}']")
    el.find(:xpath, ".//ancestor::div[contains(@class, 'panel-info')]") \
      .find('.collapsed').click

    accept_alert do
      find('a.delete').click
    end
  end

  step 'I do not save' do
    # do nothing
  end

  step 'I fill in the main category name' do
    @m_name = Faker::Lorem.word
    find(".panel-default input[name='main_categories[new][name]']").set @m_name
  end

  step 'I fill in the sub category name' do
    @s_names ||= []
    @s_names << s_name = Faker::Lorem.word
    within 'form .panel-info', match: :first do
      all("input[name*='[categories_attributes]'][name*='[name]']",
          minimum: 1).last.set s_name
    end
  end

  step "I fill in the inspectors' names" do
    el = find('form .panel-info', match: :first) \
      .find('.col-xs-8', text: _('Subcategories')) \
      .all('table tbody tr', minimum: 1).last
    @inspectors.each do |inspector|
      add_to_inspectors_field el, inspector
    end
  end

  # step 'I fill in the email' do
  #   @email = Faker::Internet.email
  #   find("input[name='group[email]']").set @email
  # end

  step 'I fill in the budget limit for the current budget period' do
    @limit = 1000
    set_budget_limit @budget_period.name, @limit
  end

  step 'I fill in the budget limit for the upcoming budget period' do
    @limit = 2000
    set_budget_limit @upcoming_budget_period.name, @limit
  end

  step 'a budget period exist' do
    @budget_period = FactoryGirl.create(:procurement_budget_period)
  end

  step 'a current budget period exists' do
    @budget_period = \
      FactoryGirl.create :procurement_budget_period,
                         inspection_start_date: Date.today + 1.day,
                         end_date: Date.today + 2.days
  end

  step 'an upcoming budget period exists' do
    @upcoming_budget_period = \
      FactoryGirl.create :procurement_budget_period,
                         inspection_start_date: @budget_period.end_date + 6.months
  end

  # step 'I am redirected to the groups index page' do
  #   expect(current_path).to eq '/procurement/groups'
  # end

  step 'I stay on the main categories edit page' do
    expect(current_path).to eq '/procurement/categories'
  end

  step 'I upload a picture' do
    field = find "input[name*='[image]']"
    attach_file(field[:name], "#{Rails.root}/features/data/images/image1.jpg")
  end

  step 'the new main category is not saved to the database' do
    category = Procurement::MainCategory.find_by_name(@m_name)
    expect(category).not_to be
  end

  step 'the new main category was created in the database' do
    category = Procurement::MainCategory.find_by_name(@m_name)
    expect(category).to be
    expect(category.name).to eq @m_name
    expect(category.budget_limits.first.amount_cents).to eq (@limit * 100)
  end

  step 'both new sub category with its inspectors were created in the database' do
    @s_names.each do |s_name|
      category = Procurement::Category.find_by_name(s_name)
      expect(category).to be
      expect(category.name).to eq s_name
      @inspectors.each do |inspector|
        expect(category.inspectors).to include inspector
      end
    end
  end

  step 'the procurement groups are sorted 0-10 and a-z' do
    names = all('table tbody tr td:first-child', minimum: 1).map(&:text)

    # sorted_numbers_strings = @groups.map(&:name)
    #           .partition { |x| not x.is_a? String }
    #           .map(&:sort).flatten
    # expect(names).to eq sorted_numbers_strings

    expect(names).to eq names.sort
  end

  step 'there exists :count budget limits for the category' do |count|
    @main_category.budget_limits.delete_all
    count.to_i.times do
      @main_category.budget_limits << \
        FactoryGirl.create(:procurement_budget_limit,
                           main_category: @main_category)
    end
  end

  # step 'the procurement group has :count inspectors' do |count|
  #   @group.inspectors.delete_all
  #   count.to_i.times do
  #     @group.inspectors << find_or_create_user(Faker::Name.first_name)
  #   end
  # end

  # step 'I navigate to the group\'s edit page' do
  #   visit procurement.edit_group_path(@group)
  # end

  step 'I modify the name' do
    @new_name = Faker::Lorem.word

    # to expand the panel
    el = find("input[name*='[name]'][value='#{@main_category.name}']")
    el.find(:xpath, ".//ancestor::div[contains(@class, 'panel-info')]") \
      .find('.collapsed').click

    el.set @new_name
  end

  step 'I modify the name of the sub category' do
    @new_name = Faker::Lorem.word
    within(:xpath, "//input[@value='#{@category.main_category.name}']/ancestor::" \
                   "div[contains(@class, 'panel-info')]") do
      find('.collapsed').click

      find("input[name*='[name]'][value='#{@category.name}']").set @new_name
    end
  end

  step 'I delete the inspector' do
    @deleted_inspector = @inspector
    @rest_inspectors = (@category.inspectors - [@inspector])

    within(:xpath, "//input[@value='#{@category.name}']/ancestor::tr") do
      find('.token-input-token', text: @inspector.name)
          .find('.token-input-delete-token')
          .click
    end
  end

  step 'I add another inspector' do
    @new_inspector = find_or_create_user(Faker::Name.first_name)
    el = find(:xpath, "//input[@value='#{@category.name}']/ancestor::tr")
    add_to_inspectors_field el, @new_inspector
  end

  step 'I delete a budget limit' do
    @deleted_budget_limit = @main_category.budget_limits.first
    set_budget_limit @deleted_budget_limit.budget_period.name, 0
  end

  step 'I add a budget limit' do
    @new_limit = 2000
    set_budget_limit @extra_budget_period.name, @new_limit
  end

  step 'I modify a budget limit' do
    @modified_limit = 3000
    @modified_budget_limit = @main_category.budget_limits.last
    set_budget_limit @modified_budget_limit.budget_period.name, @modified_limit
  end

  step 'I modify the email address' do
    @new_email = Faker::Internet.email
    find("input[name='group[email]']").set @new_email
  end

  step 'I see that the all the information ' \
       'of the procurement group was updated correctly' do
    group_line = find('table tr', text: @new_name)
    expect(group_line.text).to have_content @new_inspector.name
    expect(group_line.text).not_to have_content @deleted_inspector.name
    @rest_inspectors.each do |r_inspector|
      expect(group_line.text).to have_content r_inspector.name
    end
    expect(group_line.text).to have_content @new_email
  end

  step 'all the information of the main category ' \
       'was successfully updated in the database' do
    @main_category.reload
    expect(@main_category.name).to eq @new_name
    expect(@main_category.budget_limits.count).to eq 3
    expect(
      @main_category
      .budget_limits
      .find_by_budget_period_id(@extra_budget_period.id)
      .amount_cents
    ).to eq (@new_limit * 100)
    expect(
      @main_category
      .budget_limits
      .find_by_budget_period_id(@modified_budget_limit.budget_period_id)
      .amount_cents
    ).to eq (@modified_limit * 100)
    expect(
      @main_category
      .budget_limits
      .find_by_budget_period_id(@deleted_budget_limit.budget_period_id)
      .amount_cents
    ).to eq 0
  end

  step 'all the information of the sub category ' \
       'was successfully updated in the database' do
    @category.reload
    expect(@category.name).to eq @new_name
    expect(@category.inspectors.map(&:name)).to include @new_inspector.name
    expect(@category.inspectors.map(&:name)).not_to include @deleted_inspector.name
    @rest_inspectors.each do |r_inspector|
      expect(@category.inspectors.map(&:name)).to include r_inspector.name
    end
  end

  step 'each main category has two sub categories' do
    Procurement::MainCategory.all.each do |main_category|
      2.times do
        FactoryGirl.create(:procurement_category, main_category: main_category)
      end
      expect(main_category.reload.categories.count).to eq 2
    end
  end

  step 'the default picture of the category is used' do
    step 'there exists a sub category for this main category'
    step 'there exist requests for this sub category'

    visit procurement.overview_requests_path
    step 'I select all categories'

    within '.main_category', text: @main_category.name do
      find 'i.main_category_image.fa-outdent'
    end
  end

  step 'the main category line contains the name of the category' do
    find "input[value='#{@main_category.name}']"
  end

  step 'the picture was deleted in the database' do
    expect(@main_category.reload.image).not_to exist
  end

  step 'the sub category line contains the name of the category' do
    within(:xpath, "//input[@value='#{@main_category.name}']/ancestor::" \
                   "div[contains(@class, 'panel-heading')]") do
      find('.collapsed').click
      @main_category.categories.each do |category|
        find("input[name*='[name]'][value='#{category.name}']")
      end
    end
  end

  step 'the sub category line contains the names of the inspectors' do
    within(:xpath, "//input[@value='#{@main_category.name}']/ancestor::" \
                   "div[contains(@class, 'panel-heading')]") do
      # current_scope.click
      @main_category.categories.each do |category|
        within(:xpath, "//input[@value='#{category.name}']/ancestor::tr") do
          within '.token-input-list' do
            category.inspectors.each do |user|
              find 'li.token-input-token', text: user.to_s
            end
          end
        end
      end
    end
  end

  step 'there exists a sub category without any requests' do
    step 'there exists a sub category'
    expect(@category.requests).to be_empty
  end

  step 'there exist requests for this sub category' do
    3.times do
      FactoryGirl.create(:procurement_request, category: @category)
    end
    expect(@category.reload.requests.count).to eq 3
  end

  step 'there exist templates for this sub category' do
    3.times do
      FactoryGirl.create(:procurement_template, category: @category)
    end
    expect(@category.reload.templates.count).to eq 3
    @templates = @category.templates
  end

  step 'I can not delete the main category' do
    @main_category ||= @category.main_category
    within(:xpath, "//input[@value='#{@main_category.name}']/ancestor::" \
                   "div[contains(@class, 'panel-heading')]") do
      expect(page).to have_no_selector 'i.fa-minus-circle'
    end
  end

  step 'I confirm to delete the main and the sub category' do
    step 'I confirm the alert popup'

    within(:xpath, "//input[@value='#{@main_category.name}']/ancestor::" \
                   "div[contains(@class, 'panel-heading')]") do
      color = current_scope.native.css_value('background-color')
      expect(color).to eq 'rgba(242, 222, 222, 1)'
    end
  end

  step 'I delete the main category' do
    @main_category ||= @category.main_category
    within(:xpath, "//input[@value='#{@main_category.name}']/ancestor::" \
                   "div[contains(@class, 'panel-heading')]") do
      find('i.fa-minus-circle').click
    end
  end

  step 'I delete the sub category' do
    within(:xpath, "//input[@value='#{@category.main_category.name}']/ancestor::" \
                   "div[contains(@class, 'panel-heading')]") do
      find('.collapsed').click

      within(:xpath, "//input[@value='#{@category.name}']/ancestor::tr") do
        find('i.fa-minus-circle').click
      end
    end
  end

  step 'I am asked whether I really want to delete' do
    step 'I confirm the alert popup'
  end

  step 'I leave the name empty' do
    expect(find("input[name='group[name]']").value).to be_empty
  end

  step 'I see the name field marked red' do
    expect(find("input[name='group[name]']")['required']).to eq 'true' # ;-)
  end

  step 'the sub category disappears from the list' do
    expect(find('table')).not_to have_content @category.name
  end

  step 'the :level category is successfully deleted from the database' do |level|
    target = case level
             when 'main'
               @main_category
             when 'sub'
               @category
             else
               raise
             end
    expect { target.reload }.to raise_error ActiveRecord::RecordNotFound
  end

  step 'the templates are sucessfully deleted from the database' do
    @templates.each do |template|
      expect { template.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  step 'there does not exist any category yet' do
    expect(Procurement::Category.exists?).to be false
  end

  step 'the main categories are sorted 0-10 and a-z' do
    texts = all('.panel-heading input', minimum: 1).map &:value
    texts.delete('')
    expect(texts).to eq texts.sort
  end

  step 'the sub categories are sorted 0-10 and a-z' do
    all('.panel-info', minimum: 1).each do |panel|
      within panel do
        find('.collapsed').click

        within '.panel-body .col-xs-8', text: _('Subcategories') do
          texts = all("input[name*='[name]']", minimum: 1).map &:value
          texts.delete('')
          expect(texts).to eq texts.sort
        end
      end
    end
  end

  step 'the name is still marked red' do
    step 'I see the name field marked red'
  end

  step 'the new category has not been created' do
    # TODO: split into separate steps
    expect(Procurement::MainCategory.exists?).to be false
    expect(Procurement::Category.exists?).to be false
  end

  step 'the new main category appears in the list' do
    find ".panel-info input[value='#{@m_name}']"
  end

  step 'the new sub category is not saved to the database' do
    @s_names.each do |s_name|
      category = Procurement::Category.find_by_name(s_name)
      expect(category).not_to be
    end
  end

  step 'the sub category has an inspector' do
    @inspector = FactoryGirl.create(:procurement_category_inspector,
                                    category: @category).user
  end

  step 'the sub category turns red' do
    within(:xpath, "//input[@value='#{@category.name}']/ancestor::tr") do
      color = current_scope.native.css_value('background-color')
      expect(color).to eq 'rgba(242, 222, 222, 1)'
    end
  end

  step 'the sub category disappears' do
    within(:xpath, "//input[@value='#{@category.main_category.name}']/ancestor::" \
                   "div[contains(@class, 'panel-info')]") do
      find('.collapsed').click

      expect(page).to have_no_selector \
        "input[name*='[name]'][value='#{@category.name}']"
    end
  end

  step 'there exists an extra budget period' do
    @extra_budget_period = FactoryGirl.create(:procurement_budget_period)
  end

  private

  def add_to_inspectors_field(el, inspector)
    within el do
      find('.token-input-list .token-input-input-token input#token-input-',
           match: :first).set inspector.name
    end
    sleep 0.5 # NOTE: the dropdown is too fast
    within '.token-input-dropdown' do
      find('li', text: inspector.name).click
    end
    within el do
      within '.token-input-list' do
        find 'li.token-input-token', text: inspector.name
      end
    end
  end

  def set_budget_limit(name, limit)
    within '.row', text: _('Budget limits') do
      find('.row', text: name)
          .find("input[name*='[budget_limits_attributes]']")
          .set limit
    end
  end
end
