# -*- encoding : utf-8 -*-

Dann /^kann ich die bestellende Person wechseln$/ do
  first("#change_orderer").click
  first(".dialog .focus")
  @order = Order.find page.evaluate_script('$("#order").tmplItem().data.id')
  @old_user = @order.user
  @new_user = @current_user.managed_inventory_pools.first.users.detect {|u| u.id != @old_user.id and u.visits.size > 0}
  first(".new.orderer input").set @new_user.name
  first(".ui-menu-item a").click
  first(".dialog .button[type='submit']").click
  first("h1", :text => @new_user.name)
  page.evaluate_script('$("#order").tmplItem().data.user.id').should == @new_user.id
  @order.reload.user.id.should == @new_user.id
end