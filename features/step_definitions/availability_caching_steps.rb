When "he checks his basket" do
  # access a method, that is being called by the EJS frontend code to
  # update the OrderLine availabilites
  get "user/order.ext_json"
end

Then "the availability of the respective orderline should be cached" do 
  # we *must* reload here - thus the "true" - otherwise rails will cache
  # the old order_lines values and muss the fact that one of them has been
  # updated. See Rails docu -> Associations -> Caching
  @order.order_lines(true).first.cached_available.should_not be_nil
end

