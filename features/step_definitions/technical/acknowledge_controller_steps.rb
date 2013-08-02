Given /^test data setup for acknowledge controller test$/ do
  @admin = User.find_by_login "ramon"
  @inventory_manager =  User.find_by_login "mike"
  @lending_manager =  User.find_by_login "pius"
  @user = User.find_by_login "normin"
  @inventory_pool = (@user.inventory_pools & @lending_manager.inventory_pools).first
  @order = FactoryGirl.create :order, :user => @user, :status_const => 2, :inventory_pool => @inventory_pool
  @model = FactoryGirl.create :model
  @item = FactoryGirl.create :item, :model => @model, :owner => @inventory_pool 
end

When /^one adds a line to an order by providing a inventory code$/ do
  @response = post add_line_backend_inventory_pool_acknowledge_path(@inventory_pool.id, @order.id), {:format => :json,
                                                                                                     :quantity => 1,
                                                                                                     :start_date => Date.today.to_s,
                                                                                                     :end_date => Date.tomorrow.to_s,
                                                                                                     :code => @item.inventory_code}
end

Then /^the response from this action should be successful$/ do
  @response.should be_successful
end

Given /^prerequisites for scenario test "An added line has the same purpose of the existing lines" fullfilled$/ do
  @order = FactoryGirl.create :order_with_lines, :status_const => 2, :inventory_pool => @inventory_pool, :user => @user
  purposes = @order.lines.map(&:purpose)
  purposes.uniq.size.should == 1
  purposes.each {|p| p.description.blank?.should be_false }
end

Then /^the added line has the same purpose of the existing lines$/ do
  purposes = @order.reload.lines.map(&:purpose)
  purposes.uniq.size.should == 1
  purposes.each {|p| p.description.blank?.should be_false }
end
