# -*- encoding : utf-8 -*-

Given(/^I open (a|the) picking list( for a signed contract)?$/) do |arg1, arg2|
  if @hand_over and arg1 == "the"
    within "#lines" do
      @selected_lines = @current_inventory_pool.contract_lines.find all(".line input[type='checkbox'][checked='checked']").map { |x| x.find(:xpath, "./../../../../..")["data-id"] }
    end
    step "I can open the picking list"

    document_window = window_opened_by do
      click_button _("Picking List")
    end
    page.driver.browser.switch_to.window(document_window.handle)
  else
    @contract = case arg1
                  when "a"
                    @current_inventory_pool.contracts.order("RAND()").first
                  when "the"
                    if arg2
                      @current_inventory_pool.contracts.signed.order("RAND()").first
                    end
                end
    visit manage_picking_list_path(@current_inventory_pool, @contract)
  end

  @list_element = find(".picking_list")
end

Then(/^I can open the (contract|picking list|value list) of any (order|contract) line$/) do |arg1, arg2|
  s1 = case arg1
         when "contract"
           _("Contract")
         when "picking list"
           _("Picking List")
         when "value list"
           _("Value List")
         else
           raise
       end

  current_role = @current_user.access_right_for(@current_inventory_pool).role

  find("body").click # closes the toggler if already open

  within "#contracts" do
    find(".line", match: :first)
    within all(".line").sample do
      within find(".line-actions .multibutton") do
        if arg1 == "contract" and current_role == :group_manager
          find("a[target='_blank']", text: s1).click
        else
          find(".dropdown-holder").click
          find("a.dropdown-item[target='_blank']", text: s1).click
        end
      end
    end
  end
end

Then(/^the lists are sorted by (hand over|take back) date$/) do |arg1|
  @s1, @s2 = case arg1
               when "hand over"
                 ["start_date", _("Start date")]
               when "take back"
                 ["end_date", _("End date")]
               else
                 raise
             end
  find("section.list table thead tr th.#{@s1}", match: :first)
  dates = all("section.list table thead tr th.#{@s1}").map { |el| Date.parse el.text.gsub("#{@s2}: ", '') }
  expect(dates).to eq dates.sort
end

Then(/^each list contains following columns$/) do |table|
  (@selected_lines || @contract.lines).group_by { |x| x.send @s1 }.each_pair do |date, lines|
    @selected_lines_by_date = lines
    @list = find("section.list", text: "%s: %s" % [@s2, I18n.l(date)])
    step "beinhaltet die Liste folgende Spalten:", table
  end
end

Then(/^each list will sorted after (models, then sorted after )?room and shelf( of the most available locations)?$/) do |arg1, arg2|
  (@selected_lines || @contract.lines).group_by { |x| x.send @s1 }.each_key do |date|
    within find("section.list", text: "%s: %s" % [@s2, I18n.l(date)]) do
      if arg1
        model_texts = all("tbody .model_name").map(&:text)
        expect(model_texts).to eq model_texts.sort
      end

      all("tbody .location").each do |td|
        location_texts = td.all("table tr").map(&:text)
        expect(location_texts).to eq location_texts.sort
      end
    end
  end
end

Then(/^in the list, the assigned items will displayed with inventory code, room and shelf$/) do
  @selected_lines.select { |line| line.item_id }.each do |line|
    find("section.list .inventory_code", text: line.item.inventory_code).find(:xpath, "./..").find(".location", text: "%s / %s" % [line.item.location.try(:room), line.item.location.try(:shelf)])
  end
end

Then(/^in the list, the not assigned items will displayed without inventory code$/) do
  @selected_lines.select { |line| not line.item_id }.each do |line|
    expect(find("section.list .model_name", match: :prefer_exact, text: line.model.name).find(:xpath, "./..").find(".inventory_code").text).to eq ""
  end
end


Then(/^I can open the picking list$/) do
  find("[data-selection-enabled]").find(:xpath, "./following-sibling::*").click
  find("button", text: _("Picking List"))
end

Then(/^the items without location, are displayed with (the available quantity for this customer and )?"(.*?)"$/) do |arg1, arg2|
  (@selected_lines || @contract.lines).select { |line| line.is_a? ItemLine }.each do |line|
    if line.item_id
      next if line.item.location and not line.item.location.room.blank? and not line.item.location.shelf.blank?
      find("section.list .model_name", match: :prefer_exact, text: line.model.name).find(:xpath, "./..").find(".location", text: arg2)
    else
      locations = line.model.items.in_stock.where(inventory_pool_id: @current_inventory_pool).select("COUNT(items.location_id) AS count, locations.room AS room, locations.shelf AS shelf").joins(:location).group(:location_id).order("count DESC, room ASC, shelf ASC")
      locations.delete_if { |location| location.room.blank? and location.shelf.blank? }
      not_defined_count = line.model.items.in_stock.where(inventory_pool_id: @current_inventory_pool).count - locations.to_a.sum(&:count)
      if not_defined_count > 0
        find("section.list .model_name", match: :prefer_exact, text: line.model.name).find(:xpath, "./..").find(".location", text: arg2)
      end
    end
  end
end

Then(/^the missing location information for options, are displayed with "(.*?)"$/) do |arg1|
  (@selected_lines || @contract.lines).select { |line| line.is_a? OptionLine }.each do |line|
    find("section.list .model_name", match: :prefer_exact, text: line.model.name).find(:xpath, "./..").find(".location", text: _(arg1))
  end
end

Then(/^the not available items, are displayed with "(.*?)"$/) do |arg1|
  (@selected_lines || @contract.lines).select { |line| not line.available? }.each do |line|
    find("section.list .model_name", match: :prefer_exact, text: line.model.name).find(:xpath, "./..").find(".location", text: arg1)
  end
end
