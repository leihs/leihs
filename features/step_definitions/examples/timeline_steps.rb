# -*- encoding : utf-8 -*-
Wenn /^ich eine Bestellung bearbeite$/ do
  step 'I open a contract for acknowledgement'
end

Dann /^kann ich für jedes sichtbare Model die Timeline anzeigen lassen$/ do

  lines = if not all("#edit-contract-view").empty?
    ".order-line"
  elsif not all("#hand-over-view").empty?
    ".line[data-line-type='item_line']"
  elsif not all("#take-back-view").empty?
    ".line[data-line-type='item_line']"
  elsif not all("#search-overview").empty?
    ".line[data-type='model']"
  elsif not all("#inventory").empty?
    ".line[data-type='model']"
  else
    raise "unknown page"
  end

  raise "no lines found for this page" if lines.size.zero?

  page.has_selector?(lines).should be_true
  all(lines, visible: true)[0..5].each do |line|
    line.find(".multibutton .dropdown-toggle").click
    line.find(".multibutton .dropdown-toggle").hover
    sleep(0.88)
    line.find(".multibutton .dropdown-item", text: _("Timeline")).click
    find(".modal iframe")
    evaluate_script %Q{ $(".modal iframe").contents().first("#my_timeline").length; }
    find(".modal .button", text: _("Close")).click
    page.has_no_selector?(".modal", visible: true).should be_true
  end
end
