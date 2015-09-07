# -*- encoding : utf-8 -*-

Then(/^I see the number of "(.*?)" on each page$/) do |visit_type|
  find("a[href*='borrow/#{case visit_type
                          when "Returns"
                            "returns"
                          when "Pick ups"
                            "to_pick_up"
                          end}'] > span", match: :first, text: case visit_type
                                                                when 'Returns'
                                                                  @current_user.visits.take_back
                                                                when 'Pick ups'
                                                                  @current_user.visits.hand_over
                                                                end.count.to_s)
end

Given(/^I am in the borrow section$/) do
  visit borrow_root_path
end


Then(/^I don't see the "(.*?)" button$/) do |visit_type|
  s = case visit_type
        when 'Returns'
          'returns'
        when 'Pick ups'
          'to_pick_up'
      end
  expect(has_no_selector?("a[href*='borrow/#{s}']")).to be true
end

When(/^I press the "(.*?)" link$/) do |visit_type|
  find("a[href*='borrow/#{case visit_type
                          when "Returns"
                            "returns"
                          when "Pick ups"
                            "to_pick_up"
                          end}']", match: :first).click
end

Then(/^I see my "(.*?)"$/) do |visit_type|
  case visit_type
  when 'Returns'
    @current_user.visits.take_back
  when 'Pick ups'
    @current_user.visits.hand_over
  end.each do |visit|
    expect(has_selector?('.row h3', text: I18n.l(visit.date).to_s)).to be true
    expect(has_selector?('.row h2', text: visit.inventory_pool.name)).to be true
  end
end

Then(/^the "(.*?)" are sorted by date and inventory pool$/) do |visit_type|
  expect(all('.row h3').map(&:text)).to eq case visit_type
                                       when 'Returns'
                                         @current_user.visits.take_back
                                       when 'Pick ups'
                                         @current_user.visits.hand_over
                                       end.order(:date).map(&:date).map {|d| I18n.l d}
end

Then(/^each of the "(.*?)" shows items to (?:.+)$/) do |visit_type|
  case visit_type
  when 'Returns'
    @current_user.visits.take_back
  when 'Pick ups'
    @current_user.visits.hand_over
  end.each do |visit|
    visit.reservations.each do |line|
      expect(has_selector?('.row.line', text: line.model.name)).to be true
    end
  end
end

Then(/^the items are sorted alphabetically and grouped by model name and number of items$/) do
  temp = if current_path == borrow_returns_path
           @current_user.visits.take_back
         elsif current_path == borrow_to_pick_up_path
           @current_user.visits.hand_over
         end.joins(:inventory_pool).order('date', 'inventory_pools.name').map(&:reservations)

  t = temp.map{|reservations| reservations.map(&:model).uniq.map(&:name).sort }.flatten
  expect(t).to eq all('.row.line .col6of10').map(&:text)

  temp.
    map{|reservations| reservations.group_by {|l| l.model.name}}.
    map {|h| h.sort}.
    flatten(1).
    map{|vl| [vl.first, (if vl.second.first.is_a? OptionLine then vl.second.first.quantity else vl.second.length end)]}.
    each do |element|
      expect(has_selector?('.row.line', text: /#{element.second}[\sx]*#{element.first}/)).to be true
    end
end


Then(/^the items are sorted alphabetically by model name$/) do
  t = @current_user.visits.take_back.
        joins(:inventory_pool).order('date', 'inventory_pools.name').
        map(&:reservations).map{|reservations| reservations.map(&:model)}.
        map{|visit_models| visit_models.map(&:name)}.
        map{|visit_model_names| visit_model_names.sort}.flatten
  expect(t).to eq all('.row.line .col6of10').map(&:text)
end
