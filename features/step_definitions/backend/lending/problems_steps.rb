Given /^a line that is overbooked$/ do
  @ip = @current_user.managed_inventory_pools.first
  @overbookings = @ip.overbooking_availabilities
  raise "overbookings are needed for this test" if @overbookings.empty?
end