When "he checks his basket" do
  # access a method, that is being called by the EJS frontend code to
  # update the OrderLine availabilites
  get "user/order.ext_json"
end

Then "the availability of all orderlines should be cached" do 
  # we *must* reload here - thus the "true" - otherwise Rails will cache
  # the old order_lines values and muss the fact that one of them has been
  # updated. See Rails docu -> Associations -> Caching
  @order.order_lines(true).each do |l|
    l.cached_available.should_not be_nil
  end
end

Then "the availability of the respective orderline should be cached" do 
  # uh, dirty...
  Then "the availability of all orderlines should be cached"
end

Then "then availability cache of both orderlines should have been invalidated" do
  @order.order_lines(true).each do |l|
    l.cached_available.should be_nil
  end
end
