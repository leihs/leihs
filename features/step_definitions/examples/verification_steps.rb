Given(/^I am on the Inventory$/) do
  visit manage_inventory_path(@current_inventory_pool)
end

When(/^I open the Inventory$/) do
  find("#topbar .topbar-navigation .topbar-item a", :text => _("Inventory")).click
  expect(current_path).to eq manage_inventory_path(@current_inventory_pool)
end

Then(/^I can export to a csv-file$/) do
  find("#csv-export")
end

Then(/^I can search and filter$/) do
  find("#inventory-index-view #filter-search-container")
end

Then(/^I can not edit models, items, options, software or licenses$/) do
  within "#inventory" do
    find(".line", match: :first)

    # clicking on all togglers via javascript is significantly faster than doing it with capybara in this case
    page.execute_script %Q( $(".button[data-type='inventory-expander']").click() )

    # ensure there is at least an ajax request and it has been completed
    expect(has_selector?("img[src='/assets/loading.gif']")).to be true
    expect(has_no_selector?("img[src='/assets/loading.gif']")).to be true

    all(".line", visible: true)[0..5].each do |line|
      within line.find(".line-actions") do
        expect(has_no_selector?("a", text: _("Edit Model"))).to be true
        expect(has_no_selector?("a", text: _("Edit Item"))).to be true
        expect(has_no_selector?("a", text: _("Edit Option"))).to be true
        expect(has_no_selector?("a", text: _("Edit Software"))).to be true
        expect(has_no_selector?("a", text: _("Edit License"))).to be true
      end
    end
  end
end

Then(/^I can not add models, items, options, software or licenses$/) do
  within "#inventory-index-view" do
    expect(has_no_selector?(".button", text: _("Add inventory"))).to be true
  end
end

When(/^I enter the timeline of a model with hand overs, take backs or pending orders$/) do
  within "#inventory" do
    find(".line[data-type='model']", match: :first)
    all(".line[data-type='model']").each do |line|
      if @current_inventory_pool.running_lines.detect { |rl| rl.model_id == line["data-id"].to_i }
        line.find(".line-actions > a", text: _("Timeline")).click
        break
      end
    end
  end
  find(".modal iframe")
end

When(/^I click on a user's name$/) do
  within_frame "timeline" do
    find(".timeline-band-events .timeline-event-label").click
  end
end

Then(/^there is no link to:$/) do |table|
  within_frame "timeline" do
    within ".simileAjax-bubble-container .simileAjax-bubble-contentContainer" do
      table.raw.flatten.each do |s1|
        s2 = case s1
               when "acknowledge"
                 _("Acknowledge")
               when "hand over"
                 _("Hand Over")
               when "take back"
                 _("Take Back")
               else
                 raise
             end
        expect(has_no_selector?("a", text: s2)).to be true
      end
    end
  end
end

When(/^I open a submitted order to be verified by a Group Manager$/) do
  @contract = @current_inventory_pool.contracts.submitted.with_verifiable_user_and_model.sample
  step "I edit this submitted contract"
end

When(/^I add a model which leads to an overbooking$/) do
  ("a".."z").each do |char|
    type_into_autocomplete "[data-add-contract-line]", char
    if has_selector?(".ui-autocomplete a.light-red")
      find(".ui-autocomplete a.light-red", match: :first).click
      break
    end
  end
end

When(/^I open a hand over editable by the Group Manager$/) do
  @contract = @current_inventory_pool.contracts.approved.with_verifiable_user_and_model.sample
  visit manage_hand_over_path(@current_inventory_pool, @contract.user)
  expect(has_selector?("#hand-over-view")).to be true
  step "the availability is loaded"
end
