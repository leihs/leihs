# -*- encoding : utf-8 -*-
Wenn /^ich eine Bestellung bearbeite$/ do
  step 'I open an order for acknowledgement'
end

Dann /^kann ich für jedes sichtbare Model die Timeline anzeigen lassen$/ do

  lines = if not all("#acknowledge").empty?
    ".order_line"
  elsif not all("#hand_over").empty?
    ".item_line"
  elsif not all("#take_back").empty?
    ".item_line"
  elsif not all("#search_results").empty?
    first(".line.toggler.model.toggle.show_more").click
    ".line.model:not(.toggle)"
  elsif not all("#inventory").empty?
    ".line.model"
  else
    raise "unknown page"
  end

  raise "no lines found for this page" if lines.size.zero?

  all(lines, visible: true)[0..5].each do |line|
    line.first(".trigger").click
    while all(".button", :text => _("Timeline")).empty?
      line.first(".trigger").click
      sleep(0.5)
    end
    line.first(".button", :text => _("Timeline")).click
    first(".dialog iframe")
    evaluate_script %Q{ $(".dialog iframe").contents().first("#my_timeline").length; }
    first(".dialog .button.close_dialog").click
    all(".dialog", visible: true).size.should == 0
  end
end

Wenn /^ich eine Suche mache$/ do
  step 'ich suche'
end
