# -*- encoding : utf-8 -*-

Dann /^kann ich die bestellende Person wechseln$/ do
  find("#change_orderer").click
  wait_until { find(".dialog .focus") }
  @order = Order.find page.evaluate_script('$("#order").tmplItem().data.id')
  @old_user = @order.user
  @new_user = @current_user.managed_inventory_pools.first.users.detect {|u| u.id != @old_user.id and u.visits.size > 0}
  find(".new.orderer input").set @new_user.name
  find(".ui-menu-item a").click
  find(".dialog .button[type='submit']").click
  wait_until {find("h1", :text => @new_user.name)}
  page.evaluate_script('$("#order").tmplItem().data.user.id').should == @new_user.id
  @order.reload.user.id.should == @new_user.id
end