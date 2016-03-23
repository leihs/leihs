Then(/^I see a list of suppliers$/) do
  find('.nav-tabs .active', text: _('Suppliers'))
  within '.list-of-lines' do
    Supplier.order('RAND()').limit(5).each do |supplier|
      find('.row > .col-sm-6', text: supplier.name)
    end
  end
end

When(/^I create a new supplier( not)? providing all required values$/) do |arg1|
  find('.btn', text: _('Create %s') % _('Supplier')).click
  if arg1
    # not providing supplier[name]        9
  else
    @name = Faker::Address.street_address
    find("input[name='supplier[name]']").set @name
  end
end

When(/^I see the (new|edited) supplier$/) do |arg1|
  within '.list-of-lines' do
    find('.row > .col-sm-6', text: @name)
  end
end

Then(/^I see the supplier form$/) do
  within 'form' do
    find("input[name='supplier[name]']")
  end
end

When(/^I edit an existing supplier$/) do
  within '.list-of-lines' do
    all('.row > .col-sm-2 > .btn', text: _('Edit')).sample.click
  end

  @name = Faker::Address.street_address
  find("input[name='supplier[name]']").set @name
end

Given(/^there is a deletable supplier$/) do
  @supplier = Supplier.order('RAND ()').detect {|b| b.can_destroy? }
  @supplier ||= FactoryGirl.create(:supplier)
  expect(@supplier).not_to be_nil
  expect(@supplier.can_destroy?).to be true
end

When(/^I delete a supplier$/) do
  within '.list-of-lines' do
    el = find('.row', text: @supplier.name)

    # NOTE trick scrolling element to the screen (not hidden by header)
    # OPTIMIZE: not working if not at least 4 previous elements
    prev_el = el.find(:xpath, "./preceding-sibling::div[4]")
    page.driver.browser.action.move_to(prev_el.native).perform

    within el do
      find('.dropdown-toggle').click
      find('.dropdown-menu a', text: _('Delete')).click
      step 'I am asked whether I really want to delete'
    end
  end
end

Then(/^I don't see the deleted supplier$/) do
  within '.list-of-lines' do
    expect(has_no_selector?('.row > .col-sm-6', text: @supplier.name)).to be true
  end
end

