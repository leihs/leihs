# -*- encoding : utf-8 -*-

Then /^for each visible model I can see the Timeline$/ do

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

  current_role = @current_user.access_right_for(@current_inventory_pool).role

  all(lines, visible: true)[0..5].each do |line|
    if current_role == :group_manager and (@contract.nil? or [:signed].include? @contract.status)
      line.find(".line-actions > a", text: _("Timeline")).click
    else
      within line.find(".line-actions .multibutton") do
        find(".dropdown-toggle").click
        find(".dropdown-item", text: _("Timeline")).click
      end
    end
    find(".modal iframe")
    evaluate_script %Q{ $(".modal iframe").contents().first("#my_timeline").length; }
    find(".modal .button", text: _("Close")).click
    step "the modal is closed"
  end
end
