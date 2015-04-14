# Given "a signed contract by '$who' for item '$inventory_code'" do | who, inventory_code |
#   user     = LeihsFactory.create_user( :login => who ); user.save
#   item     = Item.find_by_inventory_code( inventory_code )
#   contract = FactoryGirl.create :contract, :user => user, :status => :approved
#   contract.contract_lines << FactoryGirl.create(:contract_line, contract: contract, model: item.model, quantity: 1)
#   cl = contract.contract_lines.first
#   cl.update_attribute(:item, item) # don't validate - allow creation of *invalid* records!
#   contract.reload
#   contract.sign(@user)
#   contract.save
# end

# Given "there is only a signed contract by '$who' for item '$inventory_code'" do | who, inventory_code |
#   step "there are no contracts"
#   step "a signed contract by '#{who}' for item '#{inventory_code}'"
# end

# copied from hand_over_steps
When "$who clicks on 'take_back'" do | who |
  get send("backend_inventory_pool_take_back_path", @inventory_pool)
  @visits = assigns(:visits)
  response.should render_template("backend/take_back/index")
  @contract = assigns(:contract)
end

When "$manager chooses to take back $customer's entry" do | manager, customer |
  @user = User.find_by_login( customer )
  get manage_take_back_path( @inventory_pool, @user )
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
  expect(contract.status).to eq :closed
end
