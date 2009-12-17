
items = Item.all

#items = Item.find(:all, :conditions => { :inventory_pool_id => 3 } )

items = Item.find(:all, :conditions => { :inventory_pool_id => 2, :owner_id => 51  } )

exportable_items = []


items.each do |i| 
    exportable_items << i
end

item_array = []
item_array << ['inventory_code', 
      'inventory_pool',
      'serial_number', 
      'model_name', 
      'borrowable',
      'owner',
      'categories',
      'required_level',
      'invoice_number',
      'invoice_date',
      'last_check',
      'retired',
      'retired_reason',
      'price',
      'is_broken',
      'is_incomplete',
      'is_borrowable',
      'created_at',
      'updated_at',
      'needs_permission',
      'is_inventory_relevant',
      'responsible',
      'supplier']


exportable_items.each do |i|

  puts "Trying item " + i.inventory_code.to_s + " (ID: " + i.id.to_s + ")"

  if i.inventory_pool.nil?
    ip = "UNBEKANNT"
  else
    ip = i.inventory_pool.name 
  end

  if i.model.nil?
  mod = "UNBEKANNT/VERAENDERT"
  else
  mod = i.model.name.gsub(/\"/, '""')
  end

  if i.owner.nil?
  own = "UNBEKANNT"
  else
    own = i.owner.name
  end

  categories = []
  i.model.categories.each do |c|
    categories << c.name + "|"
  end

  item_array << [ i.inventory_code,
    ip,                 
    i.serial_number,
    mod,
    i.is_borrowable,
    own,
    categories,
    i.required_level,
    i.invoice_number,
    i.invoice_date,
    i.last_check,
    i.retired,
    i.retired_reason,
    i.price,
    i.is_broken,
    i.is_incomplete,
    i.is_borrowable,
    i.created_at,
    i.updated_at,
    i.needs_permission,
    i.is_inventory_relevant,
    i.responsible,
    i.supplier.name
  ]

if i.in_stock? == false
  if i.contract_lines.count > 0
    i.contract_lines.each do |c|
      item_array << [ i.inventory_code,
          c.contract.user.name,
          c.start_date.to_s,
          c.end_date.to_s,
          "null",
          "null", 
          "null" ]
    end
  end
end

end



require 'faster_csv'

FasterCSV.open("/tmp/ffi_von_av-technik.csv","w", { :col_sep => ";", :quote_char => "\"", :force_quotes => true } ) do |csv|
  item_array.each do |i|
    csv << i
  end
end
