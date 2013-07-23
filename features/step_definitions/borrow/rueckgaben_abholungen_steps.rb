# -*- encoding : utf-8 -*-

Dann(/^sehe ich die Anzahl meiner "(.*?)" auf jeder Seite$/) do |visit_type|
  find("a[href*='borrow/#{case visit_type
                          when "Rückgaben"
                            "returns"
                          when "Abholungen"
                            "to_pick_up"
                          end}'] > span", text: case visit_type
                                                when "Rückgaben"
                                                  @current_user.visits.take_back
                                                when "Abholungen"
                                                  @current_user.visits.hand_over
                                                end.count.to_s)
end

Angenommen(/^man befindet sich im Ausleihen\-Bereich$/) do
  visit borrow_root_path
end

Dann(/^sehe ich den "(.*?)" Button nicht$/) do |visit_type|
  page.should_not have_selector("a[href*='borrow/#{case visit_type
                                                   when "Rückgaben"
                                                     "returns"
                                                   when "Abholungen"
                                                     "to_pick_up"
                                                   end}']")
end

Wenn(/^ich auf den "(.*?)" Link drücke$/) do |visit_type|
  find("a[href*='borrow/#{case visit_type
                          when "Rückgaben"
                            "returns"
                          when "Abholungen"
                            "to_pick_up"
                          end}']").click
end

Dann(/^sehe ich meine "(.*?)"$/) do |visit_type|
  case visit_type
  when "Rückgaben"
    @current_user.visits.take_back
  when "Abholungen"
    @current_user.visits.hand_over
  end.each do |visit|
    page.should have_selector(".row h3", text: I18n.l(visit.date).to_s)
    page.should have_selector(".row h2", text: visit.inventory_pool.name)
  end
end

Dann(/^die "(.*?)" sind nach Datum und Gerätepark sortiert$/) do |visit_type|
  all(".row h3").map(&:text).should == case visit_type
                                       when "Rückgaben"
                                         @current_user.visits.take_back
                                       when "Abholungen"
                                         @current_user.visits.hand_over
                                       end.order(:date).map(&:date).map {|d| I18n.l d}
end

Dann(/^jede der "(.*?)" zeigt die (?:.+) Geräte$/) do |visit_type|
  case visit_type
  when "Rückgaben"
    @current_user.visits.take_back
  when "Abholungen"
    @current_user.visits.hand_over
  end.each do |visit|
    visit.lines.each do |line|
      page.should have_selector(".row.line", text: line.model.name)
    end
  end
end

Dann(/^die Geräte sind alphabetisch sortiert und gruppiert nach Modellname mit Anzahl der Geräte$/) do
  temp = if current_path == borrow_returns_path
           @current_user.visits.take_back
         elsif current_path == borrow_to_pick_up_path
           @current_user.visits.hand_over
         end.joins(:inventory_pool).order("date", "inventory_pools.name").map(&:lines)

  temp.map{|visit_lines| visit_lines.to_a.uniq(&:model_id)}.
    map{|visit_lines| visit_lines.map(&:model)}.
    map{|visit_models| visit_models.map(&:name)}.
    map{|visit_model_names| visit_model_names.sort}.
    flatten.
    should == all(".row.line .col6of10").map(&:text)

  temp.map{|visit_lines| visit_lines.group_by(&:model_id)}.
    map {|h| h.sort_by {|k, v| Model.find(k).name}}.
    flatten(1).
    map{|vl| [Model.find(vl.first).name, vl.second.length]}.
    each do |element|
      page.should have_selector(".row.line", text: /#{element.second}[\sx]*#{element.first}/)
    end
end

Dann(/^die Geräte sind alphabetisch sortiert nach Modellname$/) do
  @current_user.visits
    .take_back
    .joins(:inventory_pool)
    .order("date", "inventory_pools.name")
    .map(&:lines)
    .map{|visit_lines| visit_lines.map(&:model)}
    .map{|visit_models| visit_models.map(&:name)}
    .map{|visit_model_names| visit_model_names.sort}
    .flatten
    .should == all(".row.line .col6of10").map(&:text)
end

Dann(/^jedes Gerät zeigt seinen Inventarcode$/) do
  @current_user.contract_lines.to_take_back.each do |line|
    find(".line.row", text: line.model.name).should have_content line.item.inventory_code
  end
end
