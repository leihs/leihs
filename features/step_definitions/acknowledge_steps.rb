When "$who clicks on 'acknowledge'" do | who |
  get backend_inventory_pool_acknowledge_index_path(@inventory_pool)
  @contracts = assigns(:contracts)
#0402#  
  @response = response 
end

When "$who chooses $name's order" do | who, name |
  contract = @contracts.detect { |o| o.user.login == name }
  get manage_edit_contract_path(@inventory_pool, contract)
  response.should render_template('backend/acknowledge/show')
  @contract = assigns(:contract)
  @response = response
end

When "$who rejects order with reason '$reason'" do |who, reason|
  post "/manage/#{@inventory_pool.id}/contracts/#{@contract.id}/reject", {:comment => reason}
  @contract = assigns(:contract)
  expect(@contracts).not_to be_nil
  expect(@contract).not_to be_nil
  @response = response
  expect(response.redirect_url).to eq "http://www.example.com/backend/inventory_pools/#{@inventory_pool.id}/acknowledge"
end

When "$who adds $quantity item '$model'" do |who, quantity, model|
  model_id = Model.find_by_name(model).id
  post add_line_backend_inventory_pool_acknowledge_path(@inventory_pool, @contract, :model_id => model_id, :quantity => quantity)
  @contract = assigns(:contract)
  @contract.contract_lines.each do | line |
    expect(line.model).not_to be_nil
  end
  @response = response #new#
  expect(@response.redirect_url).to include("backend/inventory_pools/#{@inventory_pool.id}/acknowledge/#{@contract.id}")
end


When "$who adds a personal message: '$message'" do |who, message|
  @comment = message
end

When "$who chooses 'swap' on order line '$model'" do |who, model|
  line = find_line(model)
  get swap_model_line_backend_inventory_pool_acknowledge_path(@inventory_pool, @contract, :line_id => line.id)
  @contract_line_id = line.id
  @response = response    
end

When "$who searches for '$model'" do |who, model|
  get manage_inventory_path(@inventory_pool, :query => model, :user_id => @contract.user_id,
                                        :source_path => swap_model_line_backend_inventory_pool_acknowledge_path(@inventory_pool, @contract, :line_id => @contract_line_id),
                                        :contract_line_id => @contract_line_id )
  @models = assigns(:models)
  expect(@models).not_to be_nil
end

When "$who selects '$model'" do |who, model|
  model_id = Model.find_by_name(model).id
  post swap_model_line_backend_inventory_pool_acknowledge_path(@inventory_pool, @contract, :line_id => @contract_line_id, :model_id => model_id)
  @contract = assigns(:contract)
  expect(@contract).not_to be_nil
end

Then /^(.*) see(s)? ([0-9]+) order(s?)$/ do | who, foo, size, s |
  find(".table-overview .fresh")
end

# NOTE this is not actually what he sees on the first page, but the total submitted contracts
#Then /^(.*) sees ([0-9]+) order(s?)$/ do | who, size, s |
##old#0402  @contracts.total_entries.should == size.to_i
#  When "#{who} clicks on 'acknowledge'" unless assigns(:contracts)
#  assigns(:contracts).total_entries.should == size.to_i
#end

#Then "$name's order is shown" do |name|
#  # TODO: we should be passing through the controller/view here!
#  user = User.find_by_login(name)
#  @contract.user.login.should == user.login
#  @contract.user.id.should == user.id
#end

Then "Swap Item screen opens" do 
  expect(@response.redirect_url).to include("/backend/inventory_pools/#{@inventory_pool.id}/models?layout=modal&contract_line_id=#{@contract_line_id}&source_path=%2Fbackend%2Finventory_pools%2F#{@inventory_pool.id}%2Facknowledge%2F#{@contract.id}%2Fswap_model_line%3Fline_id%3D#{@contract_line_id}")
end

Then "a choice of $size item appears" do |size|
  expect(@models.size).to eq size.to_i
end

Then "$who sees $quantity items of model '$model'" do |who, quantity, model|
  line = find_line(model)
  expect(line).not_to be_nil
  expect(line.quantity).to eq quantity.to_i
end

Then "all '$what' order lines are marked as invalid" do |what|
  # TODO: VERY ugly - we need have_tag "td.valid_false"
  expect(@response.body).to match /valid_false/
end

Then /the order should( not)? be approvable(.*)/ do |arg1, reason|
  if arg1
    expect(@response).to be_bad_request
    expect(@contract).to be_nil
  else
    expect(@response).to be_ok

    expect(@contract.approvable?).to be false
    @contract.lines.reload.each { |line| line.purpose = Purpose.first }
    expect(@contract.approvable?).to be true
  end
end
