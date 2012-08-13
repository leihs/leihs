# -*- encoding : utf-8 -*-
Wenn /^ich eine Bestellung bearbeite$/ do
  step 'I open an order for acknowledgement'
end

Dann /^kann ich für jedes sichtbare Model die Timeline anzeigen lassen$/ do

  lines = if not all("#acknowledge").empty?
    all(".order_line", :visible => true)
  elsif not all("#hand_over").empty?
    all(".item_line", :visible => true)
  elsif not all("#take_back").empty?
    all(".item_line", :visible => true)
  elsif not all("#search_results").empty?
    all(".line.model", :visible => true)
  elsif not all("#inventory").empty?
    all(".line.model", :visible => true)
  else
    raise "unknown page"
  end

  raise "no lines found for this page" if lines.size.zero?

  lines.each do |line|
    if not line.all(".trigger", :visible => true).empty?
      line.find(".trigger").click
      line.find(".button", :text => "Timeline").click
      wait_until { find(".dialog iframe") }
      wait_until { evaluate_script %Q{ $(".dialog iframe").contents().find("#my_timeline").length; } }
      find(".dialog .button.close_dialog").click
      wait_until{ all(".dialog", :visible=>true).size == 0 }
    end
  end
end

Wenn /^ich eine Suche mache$/ do
  step 'ich suche'
end
