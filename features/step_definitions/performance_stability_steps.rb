Given(/^the model "(.*?)" exists$/) do |arg1|
  @model = Model.find_by_name arg1
end

Given(/^it has at least (\d+) items in the current inventory pool$/) do |arg1|
  arg1.to_i.times do
    FactoryGirl.create(:item,
                       model: @model,
                       owner: @current_inventory_pool,
                       supplier: FactoryGirl.create(:supplier,
                                                    name: Faker::Lorem.characters(20)))
  end
  expect(@model.items.where(inventory_pool_id: @current_inventory_pool).count).to be >= arg1.to_i
end

Given(/^it has at least (\d+) group partitions in the current inventory pool$/) do |arg1|
  (@current_inventory_pool.groups - @model.partitions.map(&:group)).take(arg1.to_i).each do |group|
    @model.partitions << Partition.create(model: @model,
                                          inventory_pool: @current_inventory_pool,
                                          group: group,
                                          quantity: rand(10..20))
  end
  expect(@model.partitions.where(inventory_pool_id: @current_inventory_pool).count).to be >= arg1.to_i
end

Given(/^it has at least (\d+) (unsubmitted|submitted|approved|signed) reservations in the current inventory pool$/) do |arg1, status|
  attrs = { status: status.to_sym,
            inventory_pool: @current_inventory_pool,
            model: @model }
  arg1.to_i.times do
    if status.to_sym == :signed
      attrs[:status] = :approved
      attrs[:item] = @model.items.where(inventory_pool_id: @current_inventory_pool).detect{|item| item.reservations.empty? }
    end

    attrs[:start_date] = Date.today + rand(0..10).days
    attrs[:end_date] = Date.today + rand(10..20).days
    cl = FactoryGirl.create :reservation, attrs

    if status.to_sym == :signed
      contract_container = cl.user.reservations_bundles.approved.find_by(inventory_pool_id: cl.inventory_pool)
      contract = contract_container.sign(@current_user, [cl])
      expect(contract.valid?).to be true
    end
  end
  expect(@model.reservations.send(status.to_sym).count).to be >= arg1.to_i
end

When /^its availability is recalculate$/ do
  require 'benchmark'
  @time = Benchmark.measure {
    @model.availability_in(@current_inventory_pool)
  }
end

Then /^it should take maximum (\d+\.\d+) seconds$/ do |seconds|
  puts @time.real
  expect(@time.real).to be < seconds.to_f
end

Given /^approve each submitted contract with more than (.*) reservations should take maximum (.*) seconds$/ do |arg1, seconds|
  require 'benchmark'

  seconds = seconds.to_f

  contracts = ReservationsBundle.submitted.select do |rb|
    rb.reservations.count > arg1.to_i
  end
  expect(contracts).not_to be_empty

  contracts.each do |contract|
    time = Benchmark.measure {
      contract.approve(Faker::Lorem.sentence)
    }
    puts time.real
    puts contract.inspect if time.real >= seconds
    expect(time.real).to be < seconds
  end

end

Then /^approvable check on single approvable reservation should take maximum (\d+\.\d+) seconds$/ do |seconds|
  require 'benchmark'

  seconds = seconds.to_f

  reservations = Reservation.submitted.order('RAND()')

  b = false
  reservations.each do |reservation|
    time = Benchmark.measure {
      b = reservation.approvable?
    }
    puts time.real
    puts reservation.inspect if time.real >= seconds
    expect(time.real).to be < seconds
    break if b
  end

  expect(b).to be true
end

Then /^availability check on single submitted reservation should take maximum (\d+\.\d+) seconds$/ do |seconds|
  require 'benchmark'

  seconds = seconds.to_f

  reservations = Reservation.submitted.order('RAND()').limit(200)

  reservations.each do |reservation|
    time = Benchmark.measure {
      reservation.available?
    }
    puts time.real
    puts reservation.inspect if time.real >= seconds
    expect(time.real).to be < seconds
  end
end
