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
                           'features/fixtures/availability_calculation_performance.yml')))

  fixture.each do |fixture_instance|
    klass = fixture_instance.class
    mass_attrs = [:id, :unique_id, :extended_info, :created_at, :updated_at, :type]
    attrs = fixture_instance.attributes.select {|k,v| not mass_attrs.include? k.to_sym }
    o = klass.new(attrs) do |r|
      mass_attrs.each do |a|
        r.send("#{a}=", fixture_instance.send(a)) if fixture_instance.respond_to?(a)
      end
    end
    o.save(validate: false) # we skip validations because we are sequencially creating objects that are validating each other
  end

  # first item inside the fixtures is the model
  @model = Model.find fixture.first.id
end

When /^its availability is recalculate$/ do
  require 'benchmark'
  @time = Benchmark.measure {
    @model.inventory_pools.each do |ip|
      @model.availability_in(ip)
    end
  }
end

Then /^it should take at maximum (\d+) seconds$/ do |seconds|
  puts "recomputations took #{@time.total} seconds. Please delete this line here!"
  @time.real.should < seconds.to_f
end

