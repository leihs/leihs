# -*- encoding : utf-8 -*-

Dann /^for each visible model I can see the Timeline$/ do

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

  find(".line", match: :first)

  all(lines, visible: true)[0..5].each do |line|
    within line.find(".multibutton") do
      find(".dropdown-toggle").click
      find(".dropdown-item", text: _("Timeline")).click
    end
    find(".modal iframe")
    evaluate_script %Q{ $(".modal iframe").contents().first("#my_timeline").length; }
    find(".modal .button", text: _("Close")).click
    expect(has_no_selector?(".modal", visible: true)).to be true
  end
end
