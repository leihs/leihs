


#itz,vca,vbk,vmk,maf,viad,ae,mfi,sfv (=ffi)
#4,12,8,3,11,6,5,7,2


it = Item.find(:all)
todelete = []
it.each do |i|
  if i.inventory_code =~ /^itz/i
    todelete << i
  end
end


# todelete should be a collection of items with inventory numbers /^itz/i
# Delete things if they are not in one of the locations/pools that should
# be keeping these items 
todelete.each do |t|
  unless [4,12,8,3,11,6,5,7,2].include?(t.location.inventory_pool_id)
    t.destroy
  end
end


fla = File.new("/tmp/lalalala.txt","w+")
todelete.each do |t|
  unless [4,12,8,3,11,6,5,7,2].include?(t.location.inventory_pool_id)
    fla.puts t
  end
end
fla.close
