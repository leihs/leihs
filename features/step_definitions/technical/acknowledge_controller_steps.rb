Given /^test data setup for acknowledge controller test$/ do
  @admin = User.find_by_login "ramon"
  @inventory_manager =  User.find_by_login "mike"
  @lending_manager =  User.find_by_login "pius"
  @user = User.find_by_login "normin"
  @inventory_pool = (@user.inventory_pools & @lending_manager.inventory_pools).first
  @contract = FactoryGirl.create :contract, :user => @user, :status => :submitted, :inventory_pool => @inventory_pool
  @model = FactoryGirl.create :model
  @item = FactoryGirl.create :item, :model => @model, :owner => @inventory_pool 
end

When /^one adds a line to a contract by providing a inventory code$/ do
  @response = post add_line_backend_inventory_pool_acknowledge_path(@inventory_pool.id, @contract.id), {:format => :json,
                                                                                                     :quantity => 1,
                                                                                                     :start_date => Date.today.to_s,
                                                                                                     :end_date => Date.tomorrow.to_s,
                                                                                                     :code => @item.inventory_code}
end

Then /^the response from this action should be successful$/ do
  @response.should be_successful
end

Given /^prerequisites for scenario test "An added line has the same purpose of the existing lines" fullfilled$/ do
  @contract = FactoryGirl.create :contract_with_lines, :status => :submitted, :inventory_pool => @inventory_pool, :user => @user
  rand(1..3).times do
    model = FactoryGirl.create :model_with_items, :inventory_pool => @inventory_pool
    @contract.add_lines(1, model, @user, Date.today, @inventory_pool.next_open_date(Date.tomorrow) )
  end
  purposes = @contract.lines.map(&:purpose)
  purposes.uniq.size.should == 1
  purposes.each {|p| p.description.blank?.should be_false }
end

Then /^the added line has the same purpose of the existing lines$/ do
  purposes = @contract.reload.lines.map(&:purpose)
  purposes.uniq.size.should == 1
  purposes.each {|p| p.description.blank?.should be_false }
end
