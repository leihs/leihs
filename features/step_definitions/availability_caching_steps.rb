When "he checks his basket" do
  # access a method, that is being called by the EJS frontend code to
  # update the OrderLine availabilites
  get "user/order.ext_json"
  @order = @last_user.orders.first # TODO: .first => not nice
end

When "$who deletes the first line" do | who|
  # I tried to use order_backup_steps.rb -> When "$who deletes $size order line$s"
  # but I couldn't get it to run
  # TODO: we should be passing through the controller/view here
  @order.remove_line( @order.order_lines.first.id, @order.user.id )
end

Then "the availability of all $document_type lines should be cached" do |document_type|
  case document_type
    when "order";    @document = @order
    when "contract"; @document = @contract
  end
  # we *must* reload here - thus the "true" - otherwise Rails will cache
  # the old order_lines values and muss the fact that one of them has been
  # updated. See Rails docu -> Associations -> Caching
#tmp#8#old-availability#
#  @document.lines(true).each do |l|
#    l.cached_available.should_not be_nil
#  end
end

#tmp#8#old-availability#
Then "the availability of the respective orderline should be cached" do 
  # uh, dirty...
  Then "the availability of all order lines should be cached"
end

#tmp#8#old-availability#
Then "the availability cache of $quantifier $document_type lines should have been invalid$ated" do |quantifier,document_type,ated|
  case document_type
    when "order";    @document = @order
    when "contract"; @document = @contract
  end
#tmp#8#old-availability#
#  @document.lines(true).each do |l|
#    l.cached_available.should be_nil
#  end
end

