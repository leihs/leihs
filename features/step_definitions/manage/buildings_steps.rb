Then(/^I see a list of buildings$/) do
  find("nav .active", text: _("Buildings"))
  within ".list-of-lines" do
    Building.order("RAND()").limit(5).each do |building|
      find(".line > .col2of6", text: building.name)
    end
  end
end

When(/^I create a new building( not)? providing all required values$/) do |arg1|
  find(".button", text: _("Create %s") % _("Building")).click
  if arg1
    # not providing building[name]
  else
    @name = Faker::Address.street_address
    @code = Faker::Address.building_number
    find("input[name='building[name]']").set @name
    find("input[name='building[code]']").set @code
  end
end

When(/^I see the (new|edited) building$/) do |arg1|
  within ".list-of-lines" do
    find(".line > .col2of6", text: @name)
  end
end

Then(/^I see the building form$/) do
  within "form" do
    find("input[name='building[name]']")
  end
end

When(/^I edit an existing building$/) do
  within ".list-of-lines" do
    all(".line > .col1of6 > .button", text: _("Edit")).sample.click
  end

  @name = Faker::Address.street_address
  @code = Faker::Address.building_number
  find("input[name='building[name]']").set @name
  find("input[name='building[code]']").set @code
end

Given(/^there is a deletable building$/) do
  @building = Building.order("RAND ()").detect {|b| b.can_destroy? }
  @building ||= FactoryGirl.create(:building, name: Faker::Address.street_address, code: Faker::Address.building_number)
  expect(@building).not_to be_nil
  expect(@building.can_destroy?).to be true
end

When(/^I delete a building$/) do
  within ".list-of-lines" do
    within(".line", text: @building.name) do
      find(".dropdown-holder").hover
      find("a.dropdown-item", text: _("Delete")).click
      alert = page.driver.browser.switch_to.alert
      alert.accept
    end
  end
end

Then(/^I don't see the deleted building$/) do
  within ".list-of-lines" do
    expect(has_no_selector?(".line > .col2of6", text: @building.name)).to be true
  end
end

