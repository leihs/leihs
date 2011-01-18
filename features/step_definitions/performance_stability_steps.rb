@wip
# TODO: What we do here is basically whitebox testing. This kind of test
# does goes counter to the very idea of of BDD/cucumber at all. However
# I'll check in spite of that in order to have some performance
# test *at all*.
#
Given /^the MacBook availability as of (\d+\-\d+\-\d+)$/ do |date|
  fixture = YAML::load( 
              File.open(
                File.join( Rails.root,
                           'test/fixtures/availabilit_calculation_performance.yml')))

  # suspend Availability recomputation - we only want to import data
  Availability::Observer.class_eval \
    "alias_method :orig_recompute, :recompute;" \
    "def recompute(foo); end"

  # suspend reindexing within the loop to save time
  #Availability::Quantity.suspended_delta do
    Contract.suspended_delta do
  #    ContractLine.suspended_delta do
        User.suspended_delta do
          InventoryPool.suspended_delta do
            Group.suspended_delta do
              Item.suspended_delta do
                Model.suspended_delta do
                  fixture.each do |fixture_instance|
                    puts fixture_instance #debug
                    new_instance = fixture_instance.clone
                    new_instance.id = fixture_instance.id
                    new_instance.save!
                  end
                end
              end
            end
          end
        end
  #    end
    end
  #end

  # re-enable Availability recomputation
  Availability::Observer.class_eval \
    "alias_method :recompute, :orig_recompute"

  # first item inside the fixtures is the model
  @model = Model.find fixture.first.id
end

When /^its availability is recalculate$/ do
  require 'benchmark'
  @time = Benchmark.measure {
    @model.inventory_pools.each do |ip|
      @model.availability_changes.in(ip).recompute
    end
  }
end

Then /^it should take at maximum (\d+) seconds$/ do |seconds|
  puts "recomputations took #{@time.total} seconds. Please delete this line here!"
  @time.real.should < seconds.to_f
end

