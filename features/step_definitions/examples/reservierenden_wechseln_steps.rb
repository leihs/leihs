# -*- encoding : utf-8 -*-

Dann /^kann ich die reservierende Person für eine Auswahl an Linien wechseln$/ do
  step 'I select all lines of an linegroup'
  find(".multibutton [data-selection-enabled] + .dropdown-holder").hover
  find("a", :text => _("Change Borrower")).click
  find(".modal")
  @line_ids = @linegroup.all(".line").map {|l| l[:'data-id'].to_i }
  @new_user = @ip.users.detect {|u| u.id != @customer.id and u.visits.size > 0}
  find("input#user-id").set @new_user.name
  find(".ui-menu-item a", :visible => true, :text => @new_user.name).click
  find(".modal .button[type='submit']").click
  find("h1", :text => @new_user.name)
  @line_ids.each {|l| ContractLine.find(l).user.should == @new_user}
end
