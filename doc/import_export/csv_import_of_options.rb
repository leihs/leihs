


ip = InventoryPool.find(169)
log = File.open('/tmp/optionen.log', 'a+')

CSV.open('/tmp/optionen.csv', 'r', { col_sep: "\t", quote_char: "\"", headers: true}).each do |csv|
  if csv['price']
    price = BigDecimal.new(csv['price'])
  else
    price = 0.0
  end

  option = ip.options.find_or_create_by(inventory_code: csv['inventory_code'], product: csv['model_name'], price: price)
  if option
    log.puts "Success: #{csv['inventory_code']}"
  else
    log.puts "Error: #{csv['inventory_code']}: #{option.errors.full_messages}"
  end

end

log.close
