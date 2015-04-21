# -*- encoding : utf-8 -*-

#Dann /^kann ich die reservierende Person für eine Auswahl an Linien wechseln$/ do
Then /^I can change the borrower for all the lines I've selected$/ do
  step 'I select all lines of an linegroup'
  find(".multibutton [data-selection-enabled] + .dropdown-holder").click
  find("a", :text => _("Change Borrower")).click
  find(".modal")
  @line_ids = @linegroup.all(".line").map {|l| l[:'data-id'].to_i }
  @new_user = @current_inventory_pool.users.detect {|u| u.id != @customer.id and u.visits.where.not(status: :submitted).exists? }
  find("input#user-id").set @new_user.name
  find(".ui-menu-item a", :visible => true, :text => @new_user.name).click
  find(".modal .button[type='submit']").click
  find("h1", :text => @new_user.name)
  @line_ids.each do |l|
    expect(Reservation.find(l).user).to eq @new_user
  end
end
