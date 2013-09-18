# -*- encoding : utf-8 -*-

Dann /^kann ich die reservierende Person für eine Auswahl an Linien wechseln$/ do
  step 'I select all lines of an linegroup'
  find("#selection_actions .alternatives .trigger").click
  find("#selection_actions #change_borrower").click
  wait_until { find(".dialog .focus") }
  @line_ids = @linegroup.all(".line").map {|l| l[:'data-id'].to_i }
  @old_user = User.find page.evaluate_script('$(".line").tmplItem().data.contract.user.id')
  @new_user = @current_user.managed_inventory_pools.first.users.detect {|u| u.id != @old_user.id and u.visits.size > 0}
  find(".new input").set @new_user.name
  find(".ui-menu-item a").click
  find(".dialog .button[type='submit']").click
  wait_until {find("h1", :text => @new_user.name)}
  wait_until {find(".line")}
  page.evaluate_script('$(".line").tmplItem().data.contract.user.id').should == @new_user.id
  @line_ids.each {|l| ContractLine.find(l).user.should == @new_user}
end