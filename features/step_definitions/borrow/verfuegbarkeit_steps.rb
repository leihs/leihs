# -*- encoding : utf-8 -*-

Given(/^I have an unsubmitted order with models$/) do
  expect(@current_user.reservations_bundles.unsubmitted.to_a.count).to be >= 1
end

Given(/^the contract timeout is set to (\d+) minutes$/) do |arg1|
  expect(Contract::TIMEOUT_MINUTES).to eq arg1.to_i
end

#######################################################################

When(/^I add a model to an order$/) do
  @inventory_pool ||= @current_user.inventory_pools.first # OPTIMIZE
  @new_reservation = FactoryGirl.create(:reservation,
                                        user: @current_user,
                                        delegated_user: @delegated_user,
                                        status: :unsubmitted,
                                        inventory_pool: @inventory_pool)
  expect(@new_reservation.reload.available?).to be true
end

When(/^I add the same model to an order$/) do
  (@new_reservation.maximum_available_quantity + 1).times do
    FactoryGirl.create(:reservation,
                       status: :submitted,
                       inventory_pool: @inventory_pool,
                       start_date: @new_reservation.start_date,
                       end_date: @new_reservation.end_date,
                       model_id: @new_reservation.model_id)
  end
end

When(/^the maximum quantity of items is exhausted$/) do
  expect(@new_reservation.reload.available?).to be false
end

Then(/^the order is not submitted$/) do
  @current_user.reservations.unsubmitted.each do |reservation|
    expect(reservation.status).to eq :unsubmitted
  end
end

#######################################################################

Given(/^(a|\d+) model(?:s)? (?:is|are) not available$/) do |n|
  n = case n
        when 'a'
          1
        else
          n.to_i
      end

  reservations = @current_user.reservations.unsubmitted
  available_lines, unavailable_lines = reservations.partition {|line| line.available? }

  available_lines.take(n - unavailable_lines.size).each do |line|
    (line.maximum_available_quantity + 1).times do
      FactoryGirl.create(:item_line,
                         status: :submitted,
                         inventory_pool: line.inventory_pool,
                         model: line.model,
                         start_date: line.start_date,
                         end_date: line.end_date)
    end
  end
  expect(@current_user.reservations.unsubmitted.select{|line| not line.available?}.size).to eq n
end

When(/^I perform some activity$/) do
  visit borrow_root_path
end

Then(/^I am redirected to the timeout page$/) do
  expect(current_path).to eq borrow_order_timed_out_path
end

#######################################################################

Then(/^the models in my order (are released|remain blocked)$/) do |arg1|
  expect(@current_user.reservations.unsubmitted.all? { |line|
           case arg1
             when 'are released'
               not line.inventory_pool.running_reservations.detect { |l| l.id == line.id }
             when 'remain blocked'
               line.inventory_pool.running_reservations.detect { |l| l.id == line.id }
           end
         }).to be true
end

#######################################################################

Given(/^all models are available$/) do
  expect(@current_user.reservations.unsubmitted.all? {|line| line.available? }).to be true
end

Then(/^I can continue my order process$/) do
  expect(current_path).to eq borrow_root_path
end

When(/^a take back contains only options$/) do
  @customer = @current_inventory_pool.users.detect {|u| u.visits.take_back.empty? }
  expect(@customer).not_to be_nil
  step 'I open a hand over for this customer'
  step 'I add an option to the hand over by providing an inventory code and a date range'
  step 'the option is added to the hand over'
  step 'I click hand over'
  find('#purpose').set 'text'
  step 'I click hand over inside the dialog'
  visit manage_take_back_path @current_inventory_pool, @customer
end

Then(/^no availability will be computed for these options$/) do
  expect(find('#status').has_content? _('Availability loaded')).to be true
end

Given(/^the model "(.*)" has following partitioning in inventory pool "(.*)":$/) do |arg1, arg2, table|
  @model = Model.find_by_name arg1
  @inventory_pool = InventoryPool.find_by_name arg2
  table.hashes.each do |h|
    group_id = if h['group'] == 'General'
                 nil
               else
                 Group.find_by(name: h['group']).id
               end
    expect(@model.partitions_with_generals.find_by(group_id: group_id, inventory_pool_id: @inventory_pool.id).quantity).to eq h['quantity'].to_i
  end
end

When(/^I am( not)? member of group "(.*?)"$/) do |arg1, arg2|
  group = Group.find_by_name arg2
  if arg1
    group.users.delete(@current_user)
  else
    group.users << @current_user unless group.users.include? @current_user
  end
end

When(/^I am not member of any group$/) do
  @current_user.groups.clear
  expect(@current_user.groups.reload).to be_empty
end

Then(/^the maximum available quantity of this model for me is (\d+)$/) do |n|
  m = @model.availability_in(@inventory_pool).maximum_available_in_period_summed_for_groups(Date.today+99.years, Date.today+99.years, @current_user.groups.reload.map(&:id))
  expect(m).to eq n.to_i
end

Then(/^the general group is used last in assignments$/) do
  av = @model.availability_in(@inventory_pool.reload) # NOTE reload is to refresh the running_lines association
  date = av.changes.to_a.last.first
  quantity_in_general = av.partitions[Group::GENERAL_GROUP_ID]
  quantity_not_in_general = av.partitions.values.sum - av.partitions[Group::GENERAL_GROUP_ID]

  quantity_not_in_general.times.map { FactoryGirl.create :reservation, status: :approved, user: @current_user, inventory_pool: @inventory_pool, model: @model, start_date: date, end_date: date }
  av = @model.availability_in(@inventory_pool.reload) # NOTE reload is to refresh the running_lines association
  expect(av.changes[date][Group::GENERAL_GROUP_ID][:in_quantity]).to eq quantity_in_general

  FactoryGirl.create :reservation, status: :approved, user: @current_user, inventory_pool: @inventory_pool, model: @model, start_date: date, end_date: date
  av = @model.availability_in(@inventory_pool.reload) # NOTE reload is to refresh the running_lines association
  expect(av.changes[date][Group::GENERAL_GROUP_ID][:in_quantity]).to eq quantity_in_general - 1
end

When(/^I have (\d+) approved reservations for this model in this inventory pool$/) do |arg1|
  @date = Date.today + 1.year
  @reservations = arg1.to_i.times.map { FactoryGirl.create :reservation, status: :approved, user: @current_user, inventory_pool: @inventory_pool, model: @model, start_date: @date, end_date: @date }
  @av = @model.availability_in(@inventory_pool.reload) # NOTE reload is to refresh the running_lines association
end

Then(/^(\d+) of these reservations (is|are) allocated to group "(.*?)"$/) do |arg1, arg2, arg3|
  group_id = arg3 == "General" ? Group::GENERAL_GROUP_ID : Group.find_by_name(arg3).id
  expect(@av.changes[@date][group_id][:running_reservations]["ItemLine"].size).to eq arg1.to_i
  expect(@av.changes[@date][group_id][:running_reservations]["ItemLine"].all? {|id| @reservations.map(&:id).include? id }).to be true
end

Then(/^all these reservations are available$/) do
  expect(@reservations.all? &:available?).to be true
end
