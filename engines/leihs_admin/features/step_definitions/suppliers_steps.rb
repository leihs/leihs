Then(/^I see a list of suppliers$/) do
  find('.nav-tabs .active', text: _('Suppliers'))
  within '.list-of-lines' do
    Supplier.order('RAND()').limit(5).each do |supplier|
      find('.row > .col-sm-6', match: :prefer_exact, text: supplier.name)
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
  @supplier = Supplier.all.detect {|b| b.can_destroy? }
  @supplier ||= FactoryGirl.create(:supplier)
  expect(@supplier).not_to be_nil
  expect(@supplier.can_destroy?).to be true
end

When(/^I delete a supplier$/) do
  ############################################################
  # NOTE: removing header and footer
  # they are causing problems on Cider => covering the element
  # we want to click on
  page.execute_script %($('header').remove();)
  page.execute_script %($('footer').remove();)
  ############################################################

  within '.list-of-lines' do
    el = find('.row', text: @supplier.name)

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

