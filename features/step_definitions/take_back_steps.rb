Given "a signed contract by '$who' for item '$inventory_code'" \
do | who, inventory_code |
  user     = Factory.create_user( :login => who ); user.save
  item     = Item.find_by_inventory_code( inventory_code )
  contract = Factory.create_contract( :user_id => user.id )
  contract.contract_lines << Factory.create_contract_line(:model_name => item.model.name,
                                                          :quantity => 1 )
  cl = contract.contract_lines.first
  cl.update_attribute(:item, item) # don't validate - allow creation of *invalid* records!
  contract.reload
  contract.sign
  contract.save
end

Given "there is only a signed contract by '$who' for item '$inventory_code'" \
do | who, inventory_code |
  Given "there are no contracts"
  Given "a signed contract by '#{who}' for item '#{inventory_code}'"
end

# copied from hand_over_steps
When "$who clicks on 'take_back'" do | who |
  get send("backend_inventory_pool_take_back_path", @inventory_pool)
  @visits = assigns(:visits)
  response.should render_template("backend/take_back/index")
  @contract = assigns(:contract)
end

When "$manager chooses to take back $customer's entry" do | manager, customer |
  @user = User.find_by_login( customer )
  get backend_inventory_pool_user_take_back_path( @inventory_pool, @user )
  @contract_lines = assigns(:contract_lines)
end

When "$who selects all lines and takes the items back" do | who |
  post close_contract_backend_inventory_pool_user_take_back_path(
	 @inventory_pool, @user,
         :lines => @contract_lines.map { |cl| cl.id } )
  @response = response
  @flash = flash
end

Then "$who's contract should be closed" do |who|
  user = User.find_by_login( who )
  contract = Contract.find_by_user_id user.id
  contract.status_const.should == Contract::CLOSED
end
