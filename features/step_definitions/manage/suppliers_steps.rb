Then(/^I see a list of suppliers$/) do
  find('nav .active', text: _('Suppliers'))
  within '.list-of-lines' do
    Supplier.order('RAND()').limit(5).each do |supplier|
      find('.line > .col2of4', text: supplier.name)
    end
  end
end

When(/^I create a new supplier( not)? providing all required values$/) do |arg1|
  find('.button', text: _('Create %s') % _('Supplier')).click
  if arg1
    # not providing supplier[name]
  else
    @name = Faker::Address.street_address
    find("input[name='supplier[name]']").set @name
  end
end

When(/^I see the (new|edited) supplier$/) do |arg1|
  within '.list-of-lines' do
    find('.line > .col2of4', text: @name)
  end
end

Then(/^I see the supplier form$/) do
  within 'form' do
    find("input[name='supplier[name]']")
  end
end

When(/^I edit an existing supplier$/) do
  within '.list-of-lines' do
    all('.line > .col1of4 > .button', text: _('Edit')).sample.click
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
    within('.line', text: @supplier.name) do
      find('.dropdown-holder').hover
      find('a.dropdown-item', text: _('Delete')).click
      alert = page.driver.browser.switch_to.alert
      alert.accept
    end
  end
end

Then(/^I don't see the deleted supplier$/) do
  within '.list-of-lines' do
    expect(has_no_selector?('.line > .col2of4', text: @supplier.name)).to be true
  end
end

